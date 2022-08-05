package util;
import java.math.BigInteger;


public class BIUtil {
	
	//set the digit of 'k' bit 'val' in the 'index' position of x
	public static BigInteger setDigit(BigInteger X , int index, int k, BigInteger val){		
		for (int i = 0; i < k; i++)
			X = val.testBit(i)? X.setBit(index * k + i): X.clearBit(index * k + i);			
		return X;
	}	

	//get digit 'i' of 'k' bits from X
	public static BigInteger getDigit(BigInteger X, int i, int k) {
		return setDigit(new BigInteger("0"), 0, k , X.shiftRight(i * k));
	}
}
