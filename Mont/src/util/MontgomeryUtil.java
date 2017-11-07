package util;
import java.math.BigInteger;


public class MontgomeryUtil {
	
	//pPrima computation
	public static BigInteger calcularMprima(BigInteger p, int k) {
		BigInteger menosM = p.negate();
		BigInteger pow = new BigInteger("2").pow(k);
		return menosM.modInverse(pow);
	}
	
	public static void printData(BigInteger X, BigInteger Y, BigInteger P, int yk, int xk, int size){
		
		System.out.println(calcularMprima(P, yk).toString(16));
		
		int yn = size/yk;
		int xn = size/xk;
		
		int sizeHexY = yk/4;
		int sizeHexX = xk/4;
				
		for (int i = 0; i < yn; i++) {
			
			System.out.print( rellenar(  BIUtil.getDigit(Y, i, yk).toString(16), sizeHexY ));	
			
			if(i < xn){
				System.out.print( " " +  rellenar( BIUtil.getDigit(X, i, xk).toString(16), sizeHexX ));
				System.out.println( " " +  rellenar(BIUtil.getDigit(P, i, xk).toString(16), sizeHexX ));
			}
			else
				System.out.println();	
		}	
	} 
	
	public static String rellenar(String cad, int lengh){
		while(cad.length() < lengh)
			cad = "0" + cad;
		return cad;
	}
	
}

