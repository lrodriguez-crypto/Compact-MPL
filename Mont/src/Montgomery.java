import java.math.BigInteger;

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;

import util.BIUtil;
import util.MontgomeryUtil;

public class Montgomery {
	
	private static Logger log = LogManager.getLogger(Montgomery.class);

	// Walter's Algorithm
	public BigInteger montWalter(BigInteger X, BigInteger Y, BigInteger M, int numBits, int k, BigInteger Mprima) {
		BigInteger A = new BigInteger("0");
		BigInteger B = new BigInteger("2").pow(k);
		BigInteger qi = new BigInteger("0");
		int n = numBits / k;

		BigInteger X0 = BIUtil.getDigit(X, 0, k);
		BigInteger A0, Yi, XY, qiM;

		for (int i = 0; i < n; i++) {
			A0 = BIUtil.getDigit(A, 0, k);
			Yi = BIUtil.getDigit(Y, i, k);

			qi = (A0.add(X0.multiply(Yi)).multiply(Mprima)).mod(B);

			XY = X.multiply(Yi);
			qiM = qi.multiply(M);
			A = (A.add(XY).add(qiM)).divide(B);
		}
		return A;
	}
	
	// L-Rodríguez's Algorithm
	public BigInteger montCompact(BigInteger X, BigInteger Y, BigInteger M, int numBits, int k, BigInteger Mprima) {

		BigInteger A = new BigInteger("0");
		BigInteger B = new BigInteger("2").pow(k);
		BigInteger qi = new BigInteger("0");
		BigInteger c;

		int index = 0;
		int n = numBits / k;

		for (int i = 0; i < n; i++) {
			c = new BigInteger("0");
			for (int j = 0; j < n; j++) {
				BigInteger sj = BIUtil.getDigit(A, j, k).add(
						BIUtil.getDigit(X, j, k).multiply(BIUtil.getDigit(Y, i, k)));
				if (j == 0)
					qi = BIUtil.getDigit(sj.multiply(Mprima), 0, k); // k-LSB

				BigInteger rj = qi.multiply(BIUtil.getDigit(M, j, k));

				BigInteger t6j = sj.add(rj.add(c)); // {c+1,t6j} = sj + rj + cj
				c = t6j.shiftRight(k);

				if (j > 0)
					A = BIUtil.setDigit(A, j - 1, k, t6j);

				//log.trace("A -> " + A.toString(16));
			}
			A = BIUtil.setDigit(A, n - 1, k, c);

			log.trace("End iteration A -> " + A.toString(16));
		}
		return A;
	}

	
	/*
	 * MPL exponentiator, the partial multiplications can be accomplished with Walters or L-Rodriguez 
	 * algorithm. To test only the exponentiatior is recomended Walter algorithm since is faster. 
	 */
	public BigInteger poweringLadder(BigInteger x , BigInteger exp, BigInteger p , int size , int k, BigInteger pPrima,BigInteger unoMont){		
		BigInteger R0 = unoMont; // R0 = 1 ; R0 = uno en el dominio de montgomery		
		BigInteger R1 = x;
		
		for(int i= exp.bitLength() - 1; i >= 0 ; --i){
			if( exp.testBit(i) ){				
				R0 = montCompact( R0 , R1 , p , size, k, pPrima);
				R1 = montCompact( R1 , R1 , p , size, k, pPrima); 
				//R0 = montWalter( R0 , R1 , p , size, k, pPrima);
				//R1 = montWalter( R1 , R1 , p , size, k, pPrima); 
			}else{				
				R1 = montCompact( R0 , R1 , p , size, k, pPrima); 
				R0 = montCompact( R0 , R0 , p , size, k, pPrima); 
				//R1 = montWalter( R0 , R1 , p , size, k, pPrima); 
				//R0 = montWalter( R0 , R0 , p , size, k, pPrima); 
			}
			log.debug("R0 [" + i + "]->  RO * " + (exp.testBit(i)? "R1 -> ":"R0 -> ") + R0.toString(16));
			log.debug("R1 [" + i + "]->  R1 * " + (exp.testBit(i)? "R1 -> ":"R0 -> ") + R1.toString(16));
			log.debug("------------------------------------------------------");
		}			
		return R0;
	}
}
