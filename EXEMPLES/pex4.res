ce programme  est correct


 L'arbre de syntaxe astraite: 
Mp Se Se Af X1 + X2 10 skip Af X1 * X1 3 

Le code C3A: 
ET2       :Sk    :          :          :X2        
ET3       :Afc   :10        :          :CT4       
ET1       :Pl    :X2        :CT4       :VA5       
ET0       :Af    :X1        :VA5       :
ET6       :Sk    :          :          :
ET9       :Sk    :          :          :X1        
ET10      :Afc   :3         :          :CT11      
ET8       :Mu    :X1        :CT11      :VA12      
ET7       :Af    :X1        :VA12      :
ET13      :St    :          :          :


Le code Y86: 
                  .pos      0         #debut zone code 
INIT      :irmovl Data,     %edx      #adresse de la zone de donnees
           irmovl 256,      %eax      #espace pile
           addl   %edx,     %eax                
           rrmovl %eax,     %esp      #init pile 
           rrmovl %eax,     %ebp                
ET2       :nop                        #trad Sk                         X2        
ET3       :irmovl 10,       %eax      #trad Afc    10                  CT4       
           rmmovl %eax,     16(%edx)            
ET1       :mrmovl 20(%edx), %eax      #trad Pl     X2        CT4       VA5       
           mrmovl 16(%edx), %ebx                
           addl   %eax,     %ebx                
           rmmovl %ebx,     12(%edx)            
ET0       :mrmovl 12(%edx), %eax      #trad Af     X1        VA5        
           rmmovl %eax,     24(%edx)            
ET6       :nop                        #trad Sk                          
ET9       :nop                        #trad Sk                         X1        
ET10      :irmovl 3,        %eax      #trad Afc    3                   CT11      
           rmmovl %eax,     8(%edx)             
ET8       :mrmovl 24(%edx), %eax      #trad Mu     X1        CT11      VA12      
           mrmovl 8(%edx),  %ebx                
           pushl  %ebx                          
           pushl  %eax                          
           call   MUL                           
           popl   %eax                          
           popl   %ebx                          
           mrmovl 0(%edx),  %eax                
           rmmovl %eax,     4(%edx)             
ET7       :mrmovl 4(%edx),  %eax      #trad Af     X1        VA12       
           rmmovl %eax,     24(%edx)            
ET13      :halt                       #trad St                          
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
