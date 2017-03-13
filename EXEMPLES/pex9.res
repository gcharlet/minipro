ce programme  est correct


 L'arbre de syntaxe astraite: 
Mp Se Se Se Af X1 1 Af X2 1 Af N 3 Wh N Se Se Se Af AUX X1 Af X1 X2 Af X2 + AUX X2 Af N - N 1 

Le code C3A: 
ET1       :Afc   :1         :          :CT2       
ET0       :Af    :X1        :CT2       :
ET4       :Afc   :1         :          :CT5       
ET3       :Af    :X2        :CT5       :
ET7       :Afc   :3         :          :CT8       
ET6       :Af    :N         :CT8       :
ET9       :Sk    :          :          :N         
ET26      :Jz    :N         :          :ET27      
ET11      :Sk    :          :          :X1        
ET10      :Af    :AUX       :X1        :
ET13      :Sk    :          :          :X2        
ET12      :Af    :X1        :X2        :
ET16      :Sk    :          :          :AUX       
ET17      :Sk    :          :          :X2        
ET15      :Pl    :AUX       :X2        :VA18      
ET14      :Af    :X2        :VA18      :
ET21      :Sk    :          :          :N         
ET22      :Afc   :1         :          :CT23      
ET20      :Mo    :N         :CT23      :VA24      
ET19      :Af    :N         :VA24      :
ET25      :Jp    :          :          :ET9       
ET27      :Sk    :          :          :
ET28      :St    :          :          :


Le code Y86: 
                  .pos      0         #debut zone code 
INIT      :irmovl Data,     %edx      #adresse de la zone de donnees
           irmovl 256,      %eax      #espace pile
           addl   %edx,     %eax                
           rrmovl %eax,     %esp      #init pile 
           rrmovl %eax,     %ebp                
ET1       :irmovl 1,        %eax      #trad Afc    1                   CT2       
           rmmovl %eax,     24(%edx)            
ET0       :mrmovl 24(%edx), %eax      #trad Af     X1        CT2        
           rmmovl %eax,     40(%edx)            
ET4       :irmovl 1,        %eax      #trad Afc    1                   CT5       
           rmmovl %eax,     20(%edx)            
ET3       :mrmovl 20(%edx), %eax      #trad Af     X2        CT5        
           rmmovl %eax,     36(%edx)            
ET7       :irmovl 3,        %eax      #trad Afc    3                   CT8       
           rmmovl %eax,     16(%edx)            
ET6       :mrmovl 16(%edx), %eax      #trad Af     N         CT8        
           rmmovl %eax,     32(%edx)            
ET9       :nop                        #trad Sk                         N         
ET26      :mrmovl 32(%edx), %eax      #trad Jz     N                   ET27      
           andl   %eax,     %eax                
           je     ET27                          
ET11      :nop                        #trad Sk                         X1        
ET10      :mrmovl 40(%edx), %eax      #trad Af     AUX       X1         
           rmmovl %eax,     28(%edx)            
ET13      :nop                        #trad Sk                         X2        
ET12      :mrmovl 36(%edx), %eax      #trad Af     X1        X2         
           rmmovl %eax,     40(%edx)            
ET16      :nop                        #trad Sk                         AUX       
ET17      :nop                        #trad Sk                         X2        
ET15      :mrmovl 28(%edx), %eax      #trad Pl     AUX       X2        VA18      
           mrmovl 36(%edx), %ebx                
           addl   %eax,     %ebx                
           rmmovl %ebx,     12(%edx)            
ET14      :mrmovl 12(%edx), %eax      #trad Af     X2        VA18       
           rmmovl %eax,     36(%edx)            
ET21      :nop                        #trad Sk                         N         
ET22      :irmovl 1,        %eax      #trad Afc    1                   CT23      
           rmmovl %eax,     8(%edx)             
ET20      :mrmovl 32(%edx), %ebx      #trad Mo     N         CT23      VA24      
           mrmovl 8(%edx),  %eax                
           subl   %eax,     %ebx                
           rmmovl %ebx,     4(%edx)             
ET19      :mrmovl 4(%edx),  %eax      #trad Af     N         VA24       
           rmmovl %eax,     32(%edx)            
ET25      :jmp    ET9                 #trad Jp                         ET9       
ET27      :nop                        #trad Sk                          
ET28      :halt                       #trad St                          
MUL       :nop                        #ssprog mult:M[M[%edx]]:=X*Y
           mrmovl 4(%esp),  %eax      #A := X   
           mrmovl 8(%esp),  %ebx      # B:= Y   
           andl   %eax,     %eax      # si A==0 return 0
           je     END                           
SIGN      :nop                        #si A <= 0 alors (X:= -A,Y:= -B)
           jg     MULPLUS             #cas ou A > 0
           irmovl 0,        %ecx                
           subl   %eax,     %ecx                
           rrmovl %ecx,     %eax                
           rmmovl %eax,     4(%esp)   #X := -A  
           irmovl 0,        %ecx                
           subl   %ebx,     %ecx                
           rrmovl %ecx,     %ebx                
           rmmovl %ebx,     8(%esp)   #Y := -B  
MULPLUS   :nop                        #ssprog X>0->M[M[%edx]]:=X*Y
           mrmovl 4(%esp),  %eax      #A := X   
           andl   %eax,     %eax      # si X==0 return 0
           je     END                           
           irmovl 1,        %esi      # A:=A-1  
           subl   %esi,     %eax                
           mrmovl 8(%esp),  %ebx      # B:= Y   
           pushl  %ebx                # empiler B, puis A
           pushl  %eax                          
           call   MULPLUS             # M[%edx]:= A * B=(X-1) * Y
           popl   %eax                # depiler A puis B
           popl   %eax                          
           mrmovl 0(%edx),  %eax      # M[%edx]:= M[%edx] + Y
           mrmovl 8(%esp),  %ebx                
           addl   %ebx,     %eax                
           rmmovl %eax,     0(%edx)   #end MUL(X<>0) ret(Z)
           ret                                  
END       :irmovl 0,        %eax      #end MUL(X==0) ret(Z)
           rmmovl %eax,     0(%edx)             
           ret                                  
                  .align    8         #debut zone donnees
Data      :                                     
