param([int]$Group,[int]$Layer,[switch]$Preview)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$d=$PSScriptRoot
if(-not ('ScrollBlend' -as [type])){Add-Type -Path (Join-Path $d 'blend.cs') -ReferencedAssemblies System.Drawing.Common,System.Drawing.Primitives,System.Runtime.InteropServices}
$source=@((Get-Content -Raw -LiteralPath (Join-Path $d 'items.json') | ConvertFrom-Json) | Where-Object {$_.j -eq $Layer})
$starts=@(0,12,25,37)
$ends=@(12,25,37,50)
$titles=@('序章','第一章','第二章','第三章与尾声')
$kinds=@('表层规矩浓墨实景','里层白描宣纸底稿')
$start=$starts[$Group];$end=$ends[$Group];$kind=$kinds[$Layer]
$project='D:\留白output\双轨效果图'
$output=Join-Path $project '全章节连续长卷'
$folder=Join-Path $output $titles[$Group]
$trans=Join-Path $folder '逐幕过渡'
$sample=Join-Path (Join-Path $project '无缝衔接样图') "0-01 至 0-02 连续长卷 - $kind.png"
$W=1914;$H=822;$pad=$W
$extra=0
if($Group -eq 0){$extra=$W}
$length=($end-$start)*$W+$extra
$canvas=[Drawing.Bitmap]::new(($length+2*$pad),$H,[Drawing.Imaging.PixelFormat]::Format32bppPArgb)
$g=[Drawing.Graphics]::FromImage($canvas)
$g.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode=[Drawing.Drawing2D.PixelOffsetMode]::Half
function Open-Image($path){
 return [Drawing.Image]::FromFile($path)
}
function Draw-Panel($path,$left,$width){
 $p=Open-Image $path
 try{$g.DrawImage($p,[Drawing.Rectangle]::new($left,0,$width,$H))}finally{$p.Dispose()}
}
function Draw-Band($path,$left,$width,$feather,$leftBlend,$rightBlend){
 $p=Open-Image $path
 $strip=[Drawing.Bitmap]::new($width,$H,[Drawing.Imaging.PixelFormat]::Format32bppPArgb)
 $sg=[Drawing.Graphics]::FromImage($strip)
 $sg.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
 $sg.PixelOffsetMode=[Drawing.Drawing2D.PixelOffsetMode]::Half
 $sg.DrawImage($p,0,0,$width,$H)
 $sg.Dispose();$p.Dispose()
 $g.Flush(); [ScrollBlend]::Apply($canvas,$strip,$left,$feather,$leftBlend,$rightBlend); $strip.Dispose()
}
function Get-Location($n){
 return ($pad+($n-$start)*$W+$extra)
}
for($i=[Math]::Max(0,$start-1);$i -lt [Math]::Min($source.Count,$end+1);$i++){
 if($Group -eq 0 -and $i -lt 2){continue}
 $file=Join-Path $d "norm-$($source[$i].id)-$Layer.png"
 Draw-Panel $file (Get-Location $i) $W
}
if($Group -eq 0){
 Draw-Band $sample $pad (3*$W) 620 $false $true
}
for($i=[Math]::Max(1,$start-1);$i -lt [Math]::Min($source.Count-1,$end);$i++){
 $file=Join-Path $d "edit-$i-$Layer.png"
 $mid=Get-Location ($i+1)
 Draw-Band $file ($mid-760) 1520 440 $true $true
}
$g.Dispose()
if($Preview){
 $w=2400;$h=[int]($H*$w/$length)
 $mini=[Drawing.Bitmap]::new($w,$h)
 $mg=[Drawing.Graphics]::FromImage($mini)
 $mg.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
 $part=$canvas.Clone([Drawing.Rectangle]::new($pad,0,$length,$H),[Drawing.Imaging.PixelFormat]::Format32bppPArgb); $mg.DrawImage($part,0,0,$w,$h); $part.Dispose()
 $mg.Dispose()
 $file=Join-Path $d "check-$Group-$Layer.png"
 $mini.Save($file,[Drawing.Imaging.ImageFormat]::Png)
 $mini.Dispose();$canvas.Dispose()
 $file
 exit
}
[void][IO.Directory]::CreateDirectory($trans)
$chapter=$canvas.Clone([Drawing.Rectangle]::new($pad,0,$length,$H),[Drawing.Imaging.PixelFormat]::Format32bppPArgb)
$out=Join-Path $folder "$($titles[$Group]) 连续长卷 - $kind.png"
$chapter.Save($out,[Drawing.Imaging.ImageFormat]::Png);$chapter.Dispose()
for($i=$start;$i -lt [Math]::Min($source.Count-1,$end);$i++){
 if($i -eq 0){$x=$pad+$W}
 else{$x=(Get-Location ($i+1))-($W/2)}
 $chunk=$canvas.Clone([Drawing.Rectangle]::new([int]$x,0,$W,$H),[Drawing.Imaging.PixelFormat]::Format32bppPArgb)
 $file=Join-Path $trans "$($source[$i].id) 至 $($source[$i+1].id) - $kind.png"
 $chunk.Save($file,[Drawing.Imaging.ImageFormat]::Png)
 $chunk.Dispose()
}
$canvas.Dispose()
$out


