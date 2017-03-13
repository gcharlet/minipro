ce programme  est correct


 L'arbre de syntaxe astraite: 
Mp Se Se Af u 11 Af v 7 Wh - u v Se Se Se Af x - u v Af y - v u Wh * x y Se Af x + x 1 Af y + y 1 IfThEl x  Af u - u v Af v - v u 

Le code C3A: 
ET1       :Afc   :11        :          :CT2       
ET0       :Af    :u         :CT2       :
ET4       :Afc   :7         :          :CT5       
ET3       :Af    :v         :CT5       :
ET7       :Sk    :          :          :u         
ET8       :Sk    :          :          :v         
ET6       :Mo    :u         :v         :VA9       
ET53      :Jz    :VA9       :          :ET54      
ET12      :Sk    :          :          :u         
ET13      :Sk    :          :          :v         
ET11      :Mo    :u         :v         :VA14      
ET10      :Af    :x         :VA14      :
ET17      :Sk    :          :          :v         
ET18      :Sk    :          :          :u         
ET16      :Mo    :v         :u         :VA19      
ET15      :Af    :y         :VA19      :
ET21      :Sk    :          :          :x         
ET22      :Sk    :          :          :y         
ET20      :Mu    :x         :y         :VA23      
ET37      :Jz    :VA23      :          :ET38      
ET26      :Sk    :          :          :x         
ET27      :Afc   :1         :          :CT28      
ET25      :Pl    :x         :CT28      :VA29      
ET24      :Af    :x         :VA29      :
ET32      :Sk    :          :          :y         
ET33      :Afc   :1         :          :CT34      
ET31      :Pl    :y         :CT34      :VA35      
ET30      :Af    :y         :VA35      :
ET36      :Jp    :          :          :ET21      
ET38      :Sk    :          :          :
ET39      :Sk    :          :          :x         
ET51      :Jz    :x         :          :ET47      
ET42      :Sk    :          :          :u         
ET43      :Sk    :          :          :v         
ET41      :Mo    :u         :v         :VA44      
ET40      :Af    :u         :VA44      :
ET52      :Jp    :          :          :ET50      
ET47      :Sk    :          :          :v         
ET48      :Sk    :          :          :u         
ET46      :Mo    :v         :u         :VA49      
ET45      :Af    :v         :VA49      :
ET50      :Jp    :          :          :ET7       
ET54      :Sk    :          :          :
ET55      :St    :          :          :


Le code Y86: 
                  .pos      0         #debut zone code 
INIT      :irmovl Data,     %edx      #adresse de la zone de donnees
           irmovl 256,      %eax      #espace pile
           addl   %edx,     %eax                
           rrmovl %eax,     %esp      #init pile 
           rrmovl %eax,     %ebp                
ET1       :irmovl 11,       %eax      #trad Afc    11                  CT2       
           rmmovl %eax,     48(%edx)            
ET0       :mrmovl 48(%edx), %eax      #trad Af     u         CT2        
           rmmovl %eax,     64(%edx)            
ET4       :irmovl 7,        %eax      #trad Afc    7                   CT5       
           rmmovl %eax,     44(%edx)            
ET3       :mrmovl 44(%edx), %eax      #trad Af     v         CT5        
           rmmovl %eax,     60(%edx)            
ET7       :nop                        #trad Sk                         u         
ET8       :nop                        #trad Sk                         v         
ET6       :mrmovl 64(%edx), %ebx      #trad Mo     u         v         VA9       
           mrmovl 60(%edx), %eax                
           subl   %eax,     %ebx                
           rmmovl %ebx,     40(%edx)            
ET53      :mrmovl 40(%edx), %eax      #trad Jz     VA9                 ET54      
           andl   %eax,     %eax                
           je     ET54                          
ET12      :nop                        #trad Sk                         u         
ET13      :nop                        #trad Sk                         v         
ET11      :mrmovl 64(%edx), %ebx      #trad Mo     u         v         VA14      
           mrmovl 60(%edx), %eax                
           subl   %eax,     %ebx                
           rmmovl %ebx,     36(%edx)            
ET10      :mrmovl 36(%edx), %eax      #trad Af     x         VA14       
           rmmovl %eax,     56(%edx)            
ET17      :nop                        #trad Sk                         v         
ET18      :nop                        #trad Sk                         u         
ET16      :mrmovl 60(%edx), %ebx      #trad Mo     v         u         VA19      
           mrmovl 64(%edx), %eax                
           subl   %eax,     %ebx                
           rmmovl %ebx,     32(%edx)            
ET15      :mrmovl 32(%edx), %eax      #trad Af     y         VA19       
           rmmovl %eax,     52(%edx)            
ET21      :nop                        #trad Sk                         x         
ET22      :nop                        #trad Sk                         y         
ET20      :mrmovl 56(%edx), %eax      #trad Mu     x         y         VA23      
           mrmovl 52(%edx), %ebx                
           pushl  %ebx                          
           pushl  %eax                          
           call   MUL                           
           popl   %eax                          
           popl   %ebx                          
           mrmovl 0(%edx),  %eax                
           rmmovl %eax,     28(%edx)            
ET37      :mrmovl 28(%edx), %eax      #trad Jz     VA23                ET38      
           andl   %eax,     %eax                
           je     ET38                          
ET26      :nop                        #trad Sk                         x         
ET27      :irmovl 1,        %eax      #trad Afc    1                   CT28      
           rmmovl %eax,     24(%edx)            
ET25      :mrmovl 56(%edx), %eax      #trad Pl     x         CT28      VA29      
           mrmovl 24(%edx), %ebx                
           addl   %eax,     %ebx                
           rmmovl %ebx,     20(%edx)            
ET24      :mrmovl 20(%edx), %eax      #trad Af     x         VA29       
           rmmovl %eax,     56(%edx)            
ET32      :nop                        #trad Sk                         y         
ET33      :irmovl 1,        %eax      #trad Afc    1                   CT34      
           rmmovl %eax,     16(%edx)            
ET31      :mrmovl 52(%edx), %eax      #trad Pl     y         CT34      VA35      
           mrmovl 16(%edx), %ebx                
           addl   %eax,     %ebx                
           rmmovl %ebx,     12(%edx)            
ET30      :mrmovl 12(%edx), %eax      #trad Af     y         VA35       
           rmmovl %eax,     52(%edx)            
ET36      :jmp    ET21                #trad Jp                         ET21      
ET38      :nop                        #trad Sk                          
ET39      :nop                        #trad Sk                         x         
ET51      :mrmovl 56(%edx), %eax      #trad Jz     x                   ET47      
           andl   %eax,     %eax                
           je     ET47                          
ET42      :nop                        #trad Sk                         u         
ET43      :nop                        #trad Sk                         v         
ET41      :mrmovl 64(%edx), %ebx      #trad Mo     u         v         VA44      
           mrmovl 60(%edx), %eax                
           subl   %eax,     %ebx                
           rmmovl %ebx,     8(%edx)             
ET40      :mrmovl 8(%edx),  %eax      #trad Af     u         VA44       
           rmmovl %eax,     64(%edx)            
ET52      :jmp    ET50                #trad Jp                         ET50      
ET47      :nop                        #trad Sk                         v         
ET48      :nop                        #trad Sk                         u         
ET46      :mrmovl 60(%edx), %ebx      #trad Mo     v         u         VA49      
           mrmovl 64(%edx), %eax                
           subl   %eax,     %ebx                
           rmmovl %ebx,     4(%edx)             
ET45      :mrmovl 4(%edx),  %eax      #trad Af     v         VA49       
           rmmovl %eax,     60(%edx)            
ET50      :jmp    ET7                 #trad Jp                         ET7       
ET54      :nop                        #trad Sk                          
ET55      :halt                       #trad St                          
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
