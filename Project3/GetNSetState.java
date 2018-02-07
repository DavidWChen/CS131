import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSetState implements State {
    private AtomicIntegerArray value;
    private byte maxval;

    //https://piazza.com/class/jcb9v2yv4ek7oc?cid=95
    private void byteToInt(byte[] v)
    {
        value = new AtomicIntegerArray(v.length);
        for(int i = 0; i < v.length; i++)
        {
            value.set(i, v[i]);
        }  
    }

    GetNSetState(byte[] v) { byteToInt(v); maxval = 127; }

    GetNSetState(byte[] v, byte m) { byteToInt(v); maxval = m; }

    public int size() { return value.length(); }

    //Need to convert to byte
    public byte[] current() 
    { 
        byte[] v = new byte[value.length()];
        for(int i = 0; i < value.length(); i++)
        {
            v[i] = (byte) value.get(i);
        }
        return v; 
    }

    public boolean swap(int i, int j) 
    {
        int i_value = value.get(i);
        int j_value = value.get(j);
        if (i_value <= 0 || j_value >= maxval)
        {
            return false;
        }
        value.set(i, i_value-1);
        value.set(j, j_value-1);
        return true;
    }
}
