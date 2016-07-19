��  
 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #  
 #                                                                                                                                                                                                         #  
 #   N a m e :                 T i c k l e - M a i l R e c i p i e n t s . p s 1                                                                                                                           #  
 #                                                                                                                                                                                                         #  
 #   V e r s i o n :           1 . 0                                                                                                                                                                       #  
 #                                                                                                                                                                                                         #  
 #   D e s c r i p t i o n :   A d d r e s s   L i s t s   i n   E x c h a n g e   O n l i n e   d o   n o t   a u t o m a t i c a l l y   p o p u l a t e   d u r i n g   p r o v i s i o n i n g         #  
 #                             a n d   t h e r e   i s   n o   " U p d a t e - A d d r e s s L i s t "   c m d l e t .     T h i s   s c r i p t   " t i c k l e s "   m a i l b o x e s ,   m a i l       #  
 #                             u s e r s   a n d   d i s t r i b u t i o n   g r o u p s   s o   t h e   A d d r e s s   L i s t   p o p u l a t e s .                                                     #  
 #                                                                                                                                                                                                         #  
 #   A u t h o r :             J o s e p h   P a l a r c h i o                                                                                                                                             #  
 #                                                                                                                                                                                                         #  
 #   U s a g e :               A d d i t i o n a l   i n f o r m a t i o n   o n   t h e   u s a g e   o f   t h i s   s c r i p t   c a n   f o u n d   a t   t h e   f o l l o w i n g                   #  
 #                             b l o g   p o s t :     h t t p : / / b l o g s . p e r f i c i e n t . c o m / m i c r o s o f t / ? p = 2 5 5 3 6                                                         #  
 #                                                                                                                                                                                                         #  
 #   D i s c l a i m e r :     T h i s   s c r i p t   i s   p r o v i d e d   A S   I S   w i t h o u t   a n y   s u p p o r t .   P l e a s e   t e s t   i n   a   l a b   e n v i r o n m e n t       #  
 #                             p r i o r   t o   p r o d u c t i o n   u s e .                                                                                                                             #  
 #                                                                                                                                                                                                         #  
 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #  
 # I m p o r t   M o d u l e s   r e q u i r e d  
 # N o t e   -   t h e   S c r i p t   R e q u i r e s   P o w e r S h e l l   3 . 0 !  
 I m p o r t - M o d u l e   M S O n l i n e  
  
 # O f f i c e   3 6 5   A d m i n   C r e d e n t i a l s  
 $ C l o u d U s e r n a m e   =   ' g l o b a l a d m i n @ i r b t . o n m i c r o s o f t . c o m '  
 $ C l o u d P a s s w o r d   =   C o n v e r t T o - S e c u r e S t r i n g   'P@ssw0rd'   - A s P l a i n T e x t   - F o r c e  
 $ C l o u d C r e d   =   N e w - O b j e c t   S y s t e m . M a n a g e m e n t . A u t o m a t i o n . P S C r e d e n t i a l   $ C l o u d U s e r n a m e ,   $ C l o u d P a s s w o r d  
    
 # C o n n e c t   t o   O f f i c e   3 6 5    
 $ S e s s i o n   =   N e w - P S S e s s i o n   - C o n f i g u r a t i o n N a m e   M i c r o s o f t . E x c h a n g e   - C o n n e c t i o n U r i   h t t p s : / / o u t l o o k . o f f i c e 3 6 5 . c o m / p o w e r s h e l l - l i v e i d /   - C r e d e n t i a l   $ C l o u d C r e d   - A u t h e n t i c a t i o n   B a s i c   - A l l o w R e d i r e c t i o n  
 I m p o r t - P S S e s s i o n   $ s e s s i o n   - P r e f i x   O 3 6 5  
 C o n n e c t - M s o l S e r v i c e   - C r e d e n t i a l   $ c l o u d C r e d  
  
 # A d d   P S   S n a p I n   f o r   O n - P r e m i s e   E x c h a n g e   2 0 1 0  
 a d d - p s s n a p i n   M i c r o s o f t . E x c h a n g e . M a n a g e m e n t . P o w e r S h e l l . E 2 0 1 0  
  
 # T i c k l e   O n - P r m e i s e   E x c h a n g e   E n v i r o n m e n t  
 $ m a i l b o x e s   =   G e t - M a i l b o x   - R e s u l t s i z e   U n l i m i t e d  
 $ c o u n t   =   $ m a i l b o x e s . c o u n t  
 $ i = 0  
 $ c u s t o m a t t r   =   ' t e m p 1 '  
  
 W r i t e - H o s t  
 W r i t e - H o s t   " O n - P r e m i s e   M a i l b o x e s   F o u n d : "   $ c o u n t  
  
 f o r e a c h ( $ m a i l b o x   i n   $ m a i l b o x e s ) {  
     $ i + +  
     S e t - M a i l b o x   $ m a i l b o x . a l i a s   - C u s t o m A t t r i b u t e 1   $ c u s t o m a t t r   - W a r n i n g A c t i o n   s i l e n t l y C o n t i n u e  
     W r i t e - P r o g r e s s   - A c t i v i t y   " T i c k l i n g   O n - P r e m i s e   M a i l b o x e s   [ $ c o u n t ] . . . "   - S t a t u s   $ i  
 }  
  
 $ m a i l u s e r s   =   G e t - M a i l U s e r   - R e s u l t s i z e   U n l i m i t e d  
 $ c o u n t   =   $ m a i l u s e r s . c o u n t  
 $ i = 0  
  
 W r i t e - H o s t  
 W r i t e - H o s t   " O n - P r e m i s e   M a i l   U s e r s   F o u n d : "   $ c o u n t  
  
 f o r e a c h ( $ m a i l u s e r   i n   $ m a i l u s e r s ) {  
     $ i + +  
     S e t - M a i l U s e r   $ m a i l u s e r . a l i a s   - C u s t o m A t t r i b u t e 1   $ c u s t o m a t t r   - W a r n i n g A c t i o n   s i l e n t l y C o n t i n u e  
     W r i t e - P r o g r e s s   - A c t i v i t y   " T i c k l i n g   O n - P r e m i s e   M a i l   U s e r s   [ $ c o u n t ] . . . "   - S t a t u s   $ i  
 }  
  
 $ d i s t g r o u p s   =   G e t - D i s t r i b u t i o n G r o u p   - R e s u l t s i z e   U n l i m i t e d  
 $ c o u n t   =   $ d i s t g r o u p s . c o u n t  
 $ i = 0  
  
 W r i t e - H o s t  
 W r i t e - H o s t   " O n - P r e m i s e   D i s t r i b u t i o n   G r o u p s   F o u n d : "   $ c o u n t  
  
 f o r e a c h ( $ d i s t g r o u p   i n   $ d i s t g r o u p s ) {  
     $ i + +  
     S e t - D i s t r i b u t i o n G r o u p   $ d i s t g r o u p . a l i a s   - C u s t o m A t t r i b u t e 1   $ c u s t o m a t t r   - W a r n i n g A c t i o n   s i l e n t l y C o n t i n u e  
     W r i t e - P r o g r e s s   - A c t i v i t y   " T i c k l i n g   O n - P r e m i s e   D i s t r i b u t i o n   G r o u p s .   [ $ c o u n t ] . . "   - S t a t u s   $ i  
 }  
  
 # T i c k l e   E x c h a n g e   O n l i n e   ( O 3 6 5 )   E n v i r o n m e n t  
 $ r e m o t e m a i l b o x e s   =   G e t - R e m o t e M a i l b o x   - R e s u l t s i z e   U n l i m i t e d  
 $ c o u n t   =   $ r e m o t e m a i l b o x e s . c o u n t  
 $ i = 0  
  
 W r i t e - H o s t  
 W r i t e - H o s t   " O 3 6 5   M a i l b o x e s   F o u n d : "   $ c o u n t  
  
 f o r e a c h ( $ r e m o t e m a i l b o x   i n   $ r e m o t e m a i l b o x e s ) {  
     $ i + +  
     S e t - r e m o t e M a i l b o x   $ r e m o t e m a i l b o x . a l i a s   - C u s t o m A t t r i b u t e 1   $ c u s t o m a t t r   - W a r n i n g A c t i o n   s i l e n t l y C o n t i n u e  
     W r i t e - P r o g r e s s   - A c t i v i t y   " T i c k l i n g   O 3 6 5   M a i l b o x e s   [ $ c o u n t ] . . . "   - S t a t u s   $ i  
 }  
  
 < # $ m a i l u s e r s   =   G e t - O 3 6 5 M a i l U s e r   - R e s u l t s i z e   U n l i m i t e d  
 $ c o u n t   =   $ m a i l u s e r s . c o u n t  
 $ i = 0  
  
 W r i t e - H o s t  
 W r i t e - H o s t   " M a i l   O 3 6 5   U s e r s   F o u n d : "   $ c o u n t  
  
 f o r e a c h ( $ m a i l u s e r   i n   $ m a i l u s e r s ) {  
     $ i + +  
     S e t - O 3 6 5 M a i l U s e r   $ m a i l u s e r . a l i a s   - C u s t o m A t t r i b u t e 1   $ c u s t o m a t t r   - W a r n i n g A c t i o n   s i l e n t l y C o n t i n u e  
     W r i t e - P r o g r e s s   - A c t i v i t y   " T i c k l i n g   O 3 6 5   M a i l   U s e r s   [ $ c o u n t ] . . . "   - S t a t u s   $ i  
 }  
  
 $ d i s t g r o u p s   =   G e t - O 3 6 5 D i s t r i b u t i o n G r o u p   - R e s u l t s i z e   U n l i m i t e d  
 $ c o u n t   =   $ d i s t g r o u p s . c o u n t  
 $ i = 0  
  
 W r i t e - H o s t  
 W r i t e - H o s t   " O 3 6 5   D i s t r i b u t i o n   G r o u p s   F o u n d : "   $ c o u n t  
  
 f o r e a c h ( $ d i s t g r o u p   i n   $ d i s t g r o u p s ) {  
     $ i + +  
     S e t - O 3 6 5 D i s t r i b u t i o n G r o u p   $ d i s t g r o u p . a l i a s   - C u s t o m A t t r i b u t e 1   $ c u s t o m a t t r   - W a r n i n g A c t i o n   s i l e n t l y C o n t i n u e  
     W r i t e - P r o g r e s s   - A c t i v i t y   " T i c k l i n g   O 3 6 5   D i s t r i b u t i o n   G r o u p s .   [ $ c o u n t ] . . "   - S t a t u s   $ i  
 }   # >  
  
 W r i t e - H o s t  
 W r i t e - H o s t   " T i c k l i n g   C o m p l e t e "
