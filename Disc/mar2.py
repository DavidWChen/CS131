def isogram(word):
    word = word.lower()
    for char in word:
        if word.count(char) > 1:
            print('False')
            return False
        else:
            print('True')
            return True



def main():
    isogram('lumberjack')

if __name__ == "__main__":
    main()