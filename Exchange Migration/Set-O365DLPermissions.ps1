�� # I m p o r t   M o d u l e s   r e q u i r e d  
 # N o t e   -   t h e   S c r i p t   R e q u i r e s   P o w e r S h e l l   3 . 0 !  
 I m p o r t - M o d u l e   D i r S y n c   - v e r b o s e  
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
 C o n n e c t - M s o l S e r v i c e   - C r e d e n t i a l   $ c l o u d C r e d    
  
 $ R o o m s   =   G e t - O 3 6 5 M a i l b o x   - R e c i p i e n t T y p e D e t a i l s   R o o m M a i l b o x   |   G e t - O 3 6 5 C a l e n d a r P r o c e s s i n g  
 $ R e s t r i c t e d R o o m s   =   $ R o o m s   |   w h e r e   {   $ _ . A l l B o o k I n P o l i c y   - e q   $ f a l s e }  
 $ R e s t r i c t e d R o o m s   |   w h e r e   { $ _ . I d e n t i t y   - l i k e   " * a s i m o v * " }   |   S e t - O 3 6 5 C a l e n d a r P r o c e s s i n g   - A l l B o o k I n P o l i c y   $ f a l s e   - B o o k I n P o l i c y   " d l u c a s @ i r o b o t . c o m " , " b m o n g i l l o @ i r o b o t . c o m " , " p m a r s h @ i r o b o t . c o m "
