import asyncio
import sys
import logging
import datetime
import time
import json
import aiohttp
import re

'''GOOGLE PLACES'''
API_KEY = 'AIzaSyAXqqpkOaQiPyld_rtFq2b6yD_PP9WGoO8'
API_ENDPOINT = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'

def handler(loop, context):
    try:
        exception = context['exception']
        logger.error('Exception Thrown: {}'.format(exception))
    except:
        logger.error('Error: {}'.format(context['message']))

class ServerClientProtocol(asyncio.Protocol):
    client_dict = {}

    def __init__(self, server_name, portno, flood_targ):
         self.name = server_name
         self.portno = portno
         self.flood_targ = flood_targ

    def connection_made(self, transport):
        peername = transport.get_extra_info('peername')
        logger.info('Connection from {}'.format(peername))
        self.transport = transport

    def data_received(self, data):
        message = data.decode()
        logger.info('Data received: {!r}'.format(message))
        message_array = message.split()
        command = message_array[0]
        args = message_array[1:]

        if (command == 'IAMAT' and self.valid_IAMAT(args)):
            resp = self.handle_IAMAT(args[0], args[1], args[2])
        elif (command == 'WHATSAT' and self.valid_WHATSAT(args)):
            self.handle_WHATSAT(args[0], args[1], args[2])
            return
        elif (command == 'AT'):
            self.handle_AT(message_array)
            return
        else:
            resp= '? ' + message + '\n'
                
        self.transport.write(resp.encode())
        logger.info('Data sent: {!r}'.format(resp))
        self.transport.close()
        peername = self.transport.get_extra_info('peername')
        logger.info('Closing client socket: {}'.format(peername))


    '''Client AT && Flooding'''
    def valid_IAMAT(self, args):
        if (len(args) != 3):
            logger.error('IAMAT: Expected 3 arguments')
            return False
        if (not self.valid_ISO6709(args[1])):
            logger.error('IAMAT: Invalid ISO 6709 location')
            return False
        if (not self.valid_POSIX(args[2])):
            logger.error('IAMAT: Invalid POSIX time')
            return False
        return True

    def valid_ISO6709(self, iso_str):
        #Check Format
        match = re.match(r'^[+-]\d+(\.\d+)?[+-]\d+(\.\d+)?$', iso_str)
        if not match:
            return False
        #Check Value
        i = 1
        for char in iso_str[1:]:
            if char == '+' or char == '-':
                break
            i += 1
        lat = float(iso_str[:i])
        lon = float(iso_str[i:])
        if lat > 90 or lat < -90 or lon > 180 or lon < -180:
            return False
        return True

    def valid_POSIX(self, posix_str):
        try:
            time = float(posix_str)
            datetime.datetime.utcfromtimestamp(time)
        except ValueError:
            return False
        return True

    def handle_IAMAT(self, client_id, iso_str, posix_str):
        # Calculate time difference
        time_diff = time.time() - float(posix_str)
        if time_diff < 0:
            time_diff = '-' + time_diff
        else:
            time_diff = '+' + str(time_diff) 

        # Update client_dict
        info = 'AT {} {} {} {} {}'.format(self.name, time_diff, client_id, iso_str, posix_str)
        if self.update_client_info(client_id, info):
            logging.info('Flooding Servers: {}'.format(info))
            self.flood(info)

        return info

    def handle_AT(self, message_array):
        message = ' '.join(message_array[:6])
        client_id = message_array[3]
        if(self.update_client_info(client_id, message)):
            logging.info('Flooding Servers: {}'.format(message))
            self.flood(message)
        else:
            return

    def update_client_info(self, client_id, info):
        time = float(info.split()[5])
        try:
            if time > float(ServerClientProtocol.client_dict[client_id].split()[5]):
                ServerClientProtocol.client_dict[client_id] = info
                logging.info('Updating entry for: {}'.format(client_id))
                return True
        except KeyError:
            ServerClientProtocol.client_dict[client_id] = info
            logging.info('Updating entry for: {}'.format(client_id))
            return True
        return False

    def flood(self, info):
        for server_name in flood_targ:
            if server_name == "Goloman":
                portno = 16675
            elif server_name == "Hands":
                portno = 16676
            elif server_name == "Wilkes":
                portno = 16677
            elif server_name == "Holiday":
                portno = 16678
            elif server_name == "Welsh":
                portno = 16679
            self.send_AT(info, server_name, portno)

    def send_AT(self, info, targ_name, portno):
        coro = loop.create_connection(lambda: HerdProtocol(info, targ_name), '127.0.0.1', portno)
        loop.create_task(coro)

    '''Google Places'''
    def valid_WHATSAT(self, args):
        if (len(args) != 3):
            logger.error('WHATSAT: Expected 3 arguments')
            return False
        try:
            ServerClientProtocol.client_dict[args[0]]
        except KeyError:
            logger.error('WHATSAT: Client not found')
            return False

        radius = float(args[1])
        bound = int(args[2])
        if radius > 50 or radius < 0:
            logger.error('WHATSAT: 0 <= Radius <= 50')
            return False
        if bound > 20 or bound < 0:
            logger.error('WHATSAT: 0 <= Bound <= 20')
            return False
        return True

    def handle_WHATSAT(self, client_id, radius, bound):
        iso_str = ServerClientProtocol.client_dict[client_id].split()[4]
        i = 1
        for char in iso_str[1:]:
            if char == '+' or char == '-':
                break
            i += 1
        lat = str(float(iso_str[:i]))
        lon = str(float(iso_str[i:]))
        location = lat + ',' + lon
        radius = str(float(radius) * 1000)

        logger.info('GET: Google Places for {}'.format(client_id))
        asyncio.ensure_future(self.go(loop, client_id, location, radius, bound))

    async def fetch(self, session, location, radius):
        params = {'location': location, 'radius': radius, 'key': API_KEY}
        async with session.get(API_ENDPOINT, params=params) as resp:
            return await resp.json()

    async def go(self, loop, client_id, location, radius, bound):
        async with aiohttp.ClientSession(loop=loop) as session:
            data = await self.fetch(session, location, radius)
            logger.info('Data received from Google Places')
            bound = int(bound)
            if len(data['results']) > bound:
                 data['results'] = data['results'][:bound]

            resp = ServerClientProtocol.client_dict[client_id] + '\n' + json.dumps(data, indent = 3) + '\n\n'
            self.transport.write(resp.encode())
            logger.info('Data sent to Client:({}) Google Places'.format(client_id))
            self.transport.close()
            logger.info('Closing socket: Google Places')
            await session.close()
    
class HerdProtocol(asyncio.Protocol):
    def __init__(self, message, target):
        self.message = message
        self.targ = target

    def connection_made(self, transport):
        logger.info('New connection with Server: {}'.format(self.targ))
        self.transport = transport
        self.transport.write(self.message.encode())
        logger.info('Data sent to Server:({}) {}'.format(self.targ, self.message))

    def connection_lost(self, exc):
        self.transport.close()
        logger.info('Dropped connection with Server: {}\n'.format(self.targ))

if __name__ == '__main__':

    #Determine Server
    if (len(sys.argv) != 2):
        print('Error: Expected 1 argument')
        exit(1)

    server_name = sys.argv[1]
    portno = None
    flood_targ =[]
    
    if server_name == "Goloman":
        portno = 16675
        flood_targ =['Holiday', 'Wilkes', 'Hands']
    elif server_name == "Hands":
        portno = 16676
        flood_targ =['Goloman', 'Wilkes']
    elif server_name == "Wilkes":
        portno = 16677
        flood_targ =['Goloman', 'Hands', 'Holiday']
    elif server_name == "Holiday":
        portno = 16678
        flood_targ =['Goloman', 'Wilkes', 'Welsh']
    elif server_name == "Welsh":
        portno = 16679
        flood_targ =['Holiday']
    else:
        print('Error: Invalid Server Name')
        exit(1)

    #Logging
    logger = logging.getLogger(server_name)
    logger.setLevel(logging.DEBUG)
    # create file handler which logs even debug messages
    fh = logging.FileHandler(server_name + '.log', mode = 'w')
    fh.setLevel(logging.DEBUG)
    # create console handler with a higher log level
    ch = logging.StreamHandler()
    ch.setLevel(logging.ERROR)
    # create formatter and add it to the handlers
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    fh.setFormatter(formatter)
    ch.setFormatter(formatter)
    # add the handlers to the logger
    logger.addHandler(fh)
    logger.addHandler(ch)

    #Server
    loop = asyncio.get_event_loop()
    loop.set_exception_handler(handler)
    coro = loop.create_server(lambda: ServerClientProtocol(server_name, portno, flood_targ), '127.0.0.1', portno)
    server = loop.run_until_complete(coro)

    #Serve requests until Ctrl+C is pressed
    logger.info('Serving on {}'.format(server.sockets[0].getsockname()))
    try:
        loop.run_forever()
    except KeyboardInterrupt:
        logger.info('Recieved KeyboardInterrupt: Closing Server')
        pass

    # Close the server
    server.close()
    loop.run_until_complete(server.wait_closed())
    loop.close()


