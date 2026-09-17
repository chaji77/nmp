package kr.co.funology.fw.util;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;

import javax.imageio.ImageIO;

import org.apache.commons.codec.binary.Base64;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.client.j2se.MatrixToImageConfig;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.oned.Code128Writer;
import com.google.zxing.qrcode.QRCodeWriter;

public class BarCodeUtil {

    public static String getQRCodeBase64Format(String content, int intSize, int intForegroundColor, int intBackgroundColor) {
        String str = "data:image/bmp;base64,";
        try {
            QRCodeWriter cw = new QRCodeWriter();
            BitMatrix bitmatrix = cw.encode(content, BarcodeFormat.QR_CODE, intSize, intSize);
            MatrixToImageConfig matrixToImageConfig = new MatrixToImageConfig(intForegroundColor, intBackgroundColor);
            BufferedImage bufferdImage = MatrixToImageWriter.toBufferedImage(bitmatrix, matrixToImageConfig);

            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ImageIO.write(bufferdImage, "png", bos);

            str += new Base64().encodeAsString(bos.toByteArray());
            bos.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return str;
    }

    public static String getBarCodeBase64Format(String content, int intWidth, int intHeight, int intForegroundColor, int intBackgroundColor) {
        String str = "data:image/bmp;base64,";
        try {
            // QRCodeWriter qrCodeWriter = new QRCodeWriter();
            Code128Writer cw = new Code128Writer();
            BitMatrix bitmatrix = cw.encode(content, BarcodeFormat.CODE_128, intWidth, intHeight);
            MatrixToImageConfig matrixToImageConfig = new MatrixToImageConfig(intForegroundColor, intBackgroundColor);
            BufferedImage bufferdImage = MatrixToImageWriter.toBufferedImage(bitmatrix, matrixToImageConfig);

            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ImageIO.write(bufferdImage, "png", bos);

            str += new Base64().encodeAsString(bos.toByteArray());
            bos.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return str;
    }

    public static void main(String[] args) {
        System.out.println(getQRCodeBase64Format("hello", 150, 0xff000000, 0xffffffff));
        System.out.println(getBarCodeBase64Format("hello", 200, 50, 0xff000000, 0xffffffff));
    }
}
