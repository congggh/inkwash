using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public static class ScrollBlend {
 public static void Apply(Bitmap canvas, Bitmap strip, int left, int feather, bool leftBlend, bool rightBlend) {
   var rect = new Rectangle(left,0,strip.Width,strip.Height);
   var target = canvas.LockBits(rect,ImageLockMode.ReadWrite,PixelFormat.Format32bppPArgb);
   var source = strip.LockBits(new Rectangle(0,0,strip.Width,strip.Height),ImageLockMode.ReadOnly,PixelFormat.Format32bppPArgb);
   try {
     int bytes=strip.Width*4;
     var a=new byte[bytes];var b=new byte[bytes];
     var weights=new int[strip.Width];
     for(int x=0;x<strip.Width;x++){
       double t=1;
       if(leftBlend) t=Math.Min(t,x/(double)feather);
       if(rightBlend) t=Math.Min(t,(strip.Width-1-x)/(double)feather);
       weights[x]=(int)Math.Round(256*t*t*(3-2*t));
     }
     for(int y=0;y<strip.Height;y++){
       var dst=IntPtr.Add(target.Scan0,y*target.Stride);
       Marshal.Copy(dst,a,0,bytes);
       Marshal.Copy(IntPtr.Add(source.Scan0,y*source.Stride),b,0,bytes);
       for(int x=0;x<strip.Width;x++){
         int w=weights[x];
         for(int c=0;c<4;c++){int i=4*x+c;a[i]=(byte)((a[i]*(256-w)+b[i]*w+128)>>8);}
       }
       Marshal.Copy(a,0,dst,bytes);
     }
   } finally {strip.UnlockBits(source);canvas.UnlockBits(target);}
 }
}
