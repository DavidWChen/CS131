// import java.util.concurrent.atomic.AtomicIntegerArray;

// class GetNSetState implements State {
//     private AtomicIntegerArray value;
//     private byte maxval;

//     //https://piazza.com/class/jcb9v2yv4ek7oc?cid=95
//     private void byteToInt(byte[] v)
//     {
//         value = new AtomicIntegerArray(v.length);
//         for(int i = 0; i < v.length; i++)
//         {
//             value.set(i, v[i]);
//         }  
//     }

//     GetNSetState(byte[] v) { byteToInt(v); maxval = 127; }

//     GetNSetState(byte[] v, byte m) { byteToInt(v); maxval = m; }

//     public int size() { return value.length(); }

//     //Need to convert to byte
//     public byte[] current() 
//     { 
//         byte[] v = new byte[value.length()];
//         for(int i = 0; i < value.length(); i++)
//         {
//             v[i] = (byte) value.get(i);
//         }
//         return v; 
//     }

//     public boolean swap(int i, int j) 
//     {
//         int i_value = value.get(i);
//         int j_value = value.get(j);
//         if (i_value <= 0 || j_value >= maxval)
//         {
//             return false;
//         }
//         value.set(i, i_value-1);
//         value.set(j, j_value-1);
//         return true;
//     }
// }
import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSetState implements State {
    private byte maxval;
    private AtomicIntegerArray atomic_array;

    // Helper class to create AtomicIntegerArray from byte array
    // With an intermediate int array because the constructor only
    // takes in an int array
    private void createAtomicArray(byte[] v){
        int[] intArray = new int[v.length];
        for(int i = 0; i < v.length; i++){
            intArray[i] = v[i];
        }
        atomic_array = new AtomicIntegerArray(intArray);
    }


    GetNSetState(byte[] v) { 
        maxval = 127;
        createAtomicArray(v);
    }

    GetNSetState(byte[] v, byte m) { 
        maxval = m;
        createAtomicArray(v);
    }

    public int size() { return atomic_array.length(); }

    // Downcast the array of ints in the AtomicIntegerArray to bytes
    public byte[] current() { 
        byte[] ret = new byte[atomic_array.length()];
        for(int i = 0; i < ret.length; i++){
            ret[i] = (byte) atomic_array.get(i);
        }
        return ret;
    }

    // Use the AtomicIntegerArray to get and set the values
    // of the array in an atomic manner
    public boolean swap(int i, int j) {
        if (atomic_array.get(i) <= 0 || atomic_array.get(j) >= maxval) {
            return false;
        }
        atomic_array.getAndDecrement(i);
        atomic_array.getAndIncrement(j);
        return true;
    }
}