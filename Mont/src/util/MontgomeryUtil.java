package util;
import java.math.BigInteger;

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;

public class MontgomeryUtil {

	private static Logger log = LogManager.getLogger(MontgomeryUtil.class);
	
	//pPrima computation
	public static BigInteger computeMprima(BigInteger p, int k) {
		BigInteger menosM = p.negate();
		BigInteger pow = new BigInteger("2").pow(k);
		return menosM.modInverse(pow);
	}
	
	public static void printData(BigInteger X, BigInteger Y, BigInteger P, int yk, int xk, int size){
		log.info(computeMprima(P, yk).toString(16));
		
		int yn = size/yk;
		int xn = size/xk;
		
		int sizeHexY = yk/4;
		int sizeHexX = xk/4;
				
		for (int i = 0; i < yn; i++) {
			
			System.out.print( fill(  BIUtil.getDigit(Y, i, yk).toString(16), sizeHexY ));	
			
			if(i < xn){
				System.out.print( " " +  fill( BIUtil.getDigit(X, i, xk).toString(16), sizeHexX ));
				System.out.println( " " +  fill(BIUtil.getDigit(P, i, xk).toString(16), sizeHexX ));
			}
			else
				System.out.println();	
		}	
	} 
	
	public static String fill(String cad, int lengh){
		while(cad.length() < lengh)
			cad = "0" + cad;
		return cad;
	}
	
}
