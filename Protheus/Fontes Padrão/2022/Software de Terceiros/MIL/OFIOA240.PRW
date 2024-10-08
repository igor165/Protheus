#INCLUDE "ofioa240.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIOA240 � Autor �  Renata               � Data � 02/05/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de peca de acao de oficina/chamadas               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � oficina/garantia                                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIOA240
Private aMemos := {{"VOP_ASSMEM","VOP_ASSCAM"}}
Private aRotina := MenuDef()
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemToAnsi(STR0006)   //"Pecas de Acao de Oficina/Chamadas"
//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"VOP")

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �OA240     � Autor �Renata                 � Data � 06/06/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Visualiza, inclui e altera dadoas do VSD/VOP               ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � OA240(CALIAS,NREG,NOPC)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � OFICINA                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OA240(cAlias,nReg,nOpc)
Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor := 0 , _ni := 0 , nUsado := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Local nPosRec := 0
Private aTELA[0][0],aGETS[0] 
Private aCpoEnchoice  :={} , aCols := {} , aHeader := {}
Private aMemos := {{"VOP_ASSMEM","VOP_ASSCAM"}}
//��������������������������������������������������������������Ŀ
//� Cria variaveis M->????? da Enchoice                          �
//����������������������������������������������������������������
RegToMemory("VOP",.t.)

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VOP")
While !Eof().and.(x3_arquivo=="VOP")
   If X3USO(x3_usado).and.cNivel>=x3_nivel.and. x3_campo # "VOP_TIPPEN"
      AADD(aCpoEnchoice,x3_campo)
   Endif
   &("M->"+x3_campo) := CriaVar(x3_campo)
   dbSkip()
End

If nOpc # 3 

	DbSelectArea("VOP")

	For nCntFor := 1 TO FCount()
	   M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
    
EndIf

If nOpc == 3      // Incluir
   nOpcE := 3
   nOpcG := 3
ElseIf nOpc == 4  // Alterar
   nOpcE := 4
   nOpcG := 4
ElseIf nOpc == 5  // Excluir
   nOpcE := 5
   nOpcG := 5
Else               // Visualizar
   nOpcE := 2
   nOpcG := 2
EndIf

//��������������������������������������������������������������Ŀ
//� Cria aHeader e aCols da GetDados                             �
//����������������������������������������������������������������
nUsado:=0

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VSD")

aHeader:={}

While !Eof().And.(x3_arquivo=="VSD")
   If X3USO(x3_usado).And.cNivel>=x3_nivel.AND.!(x3_campo $ "VSD_NUMCAM/VSD_TIPPEN/VSD_PECINT/VSD_SERINT")
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
      x3_tamanho, x3_decimal,x3_valid,;
      x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
   EndIf
   
   &("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
   
   dbSkip()
End

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VSD")
ADHeadRec("VSD",aHeader)
// Posicao do registro
nPosRec:=Len(aHeader)
nUsado :=Len(aHeader)

aCols:={}  
DbSelectArea("VSD")
DbSetOrder(1)
DbSeek(xFilial("VSD")+VOP->VOP_NUMCAM)

If nOpc ==3 .Or. !Found()
   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VSD"
		Else	
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		EndIf	
   Next
Else
   While !Eof() .And. VSD->VSD_FILIAL == xFilial("VSD") .And. VSD->VSD_NUMCAM == VOP->VOP_NUMCAM
       AADD(aCols,Array(nUsado+1))
       For _ni:=1 to nUsado
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VSD->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VSD"
			Else
				aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
			EndIf
       Next
       aCols[Len(aCols),nUsado+1]:=.F.
       dbSkip()
   End
Endif

If Len(aCols)>0
   //��������������������������������������������������������������Ŀ
   //� Executa a Modelo 3                                           �
   //����������������������������������������������������������������
   cTitulo       :=STR0006   //"Pecas de Acao de oficina/chamada"
   cAliasEnchoice:="VOP"
   cAliasGetD    :="VSD"
   cLinOk        :="If(FS_VALOA240(nOpcG),FG_OBRIGAT(),.f.)"
   cTudOk        :="AllwaysTrue()"
   cFieldOk      :="FG_MEMVAR()"
   //aCpoEnchoice  :={}

   dbSelectArea("SX3")
   dbSeek("VOP")

   DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,80	of oMainWnd   
   EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,1,70,315},,3,,,,,,.F.)
   oGetDados := MsGetDados():New(75,1,143,315,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(oGetDados:TudoOk().And.obrigatorio(aGets,aTela).And.FS_OA240GRA(nOpc),oDlg:End(),.f.) },{|| oDlg:End() })

Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_OA240GR�Autor  �Fabio               � Data �  08/30/00   ���
�������������������������������������������������������������������������͹��
���Desc.     �Grava                                                       ���
�������������������������������������������������������������������������͹��
���Uso       �Oficina                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_OA240GRA(nOpc)
Private  lMsHelpAuto := .T., lMsFinalAuto := .f.

If M->VOP_DATCAM > M->VOP_DATVEN
                 
   Help("  ",1,"DATA2MOATU") 
	Return( .f. )

EndIf

If !FS_VALGRAOA240( nOpc , .t. )
     
   MostraErro()
	Return( .f. )

EndIf                               
                    
Begin Transaction

FS_VALGRAOA240(nOpc)

End Transaction
lMsHelpAuto := .f. 

Return( .t. )

Static Function FS_VALGRAOA240( nOpc , lValid )
Local lRet := .t. , i := 0 , aVetValid := {}
Private lMsHelpAuto := .t.
                                              
lValid := If( lValid == NIL , .f. , lValid )                  
                  
If nOpc # 2
   
   DbSelectArea("VOP")
   DbSetOrder(1)
   DbSeek(xFilial("VOP")+M->VOP_NUMINT)
                                  
   // Grava arquivo pai
   If Inclui .or. Altera
   
		If !lValid

         If !RecLock("VOP", !Found() )
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break               
         EndIf
         
         FG_GRAVAR("VOP")
         VOP->VOP_TIPPEN := "4"
         cVar := aMemos[1][2]
         MSMM(,TamSx3("VOP_ASSCAM")[1],,&cVar,1,,,"VOP","VOP_ASSMEM")

         ConfirmSx8()
         MsUnlock()
         
		EndIf         
                          
   EndIf

   // Grava arquivo filho
   For i:=1 to len(aCols)

      DbSelectArea("SB1")
      DbSetOrder(7)
      DbSeek( xFilial() + aCols[I,FG_POSVAR('VSD_GRUITE')] + aCols[I,FG_POSVAR('VSD_CODITE')] )

      DbSelectArea("VO6")
      DbSetOrder(2)
      DbSeek( xFilial() + VOP->VOP_CODMAR + aCols[I,FG_POSVAR('VSD_CODSER')] )

      DbSelectArea("VSD")
      DbSetOrder(1)
      DbSeek(xFilial() + VOP->VOP_NUMCAM + VOP->VOP_TIPPEN + aCols[I,FG_POSVAR('VSD_GRUITE')] + aCols[I,FG_POSVAR('VSD_CODITE')] )
         
      If (nOpc == 3 .Or. nOpc == 4) .And. !aCols[i,Len(aCols[i])]

         If !lValid
			
            If !RecLock("VSD", !Found() )
               Help("  ",1,"REGNLOCK")
               lRet := .f.
               DisarmTransaction()
               Break               
            EndIf
            
            FG_GRAVAR("VSD",aCols,aHeader,i)
            VSD->VSD_FILIAL := xFilial("VSD")
            VSD->VSD_NUMCAM := VOP->VOP_NUMCAM
            VSD->VSD_TIPPEN := VOP->VOP_TIPPEN             
            VSD->VSD_PECINT := SB1->B1_COD
            VSD->VSD_SERINT := VO6->VO6_SERINT
            
            MsUnlock()    
                   
			EndIf            
            
      ElseIf Found()   

      	If lValid

            aVetValid := {}
            Aadd(aVetValid,{"VG5" , "VG5_PECINT" , VSD->VSD_PECINT  , NIL })

            If !FG_DELETA(aVetValid)
					Return( .f. )
            EndIf
                  
			Else
                        
            If !RecLock("VSD",.F.,.T.)
               Help("  ",1,"REGNLOCK")
               lRet := .f.
               DisarmTransaction()
               Break               
            EndIf

            dbdelete()
            MsUnlock()
            WriteSx2("VSD")
        
			EndIf

      EndIf

   Next          
      
Endif

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_VALOA24�Autor  �Fabio               � Data �  08/30/00   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida duplicidade                                          ���
�������������������������������������������������������������������������͹��
���Uso       � Oficina                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                    
Function FS_VALOA240(nOpc)
Local nValLin:=0

FG_MEMVAR()
        
If !aCols[n,Len(aCols[n])]   

	If nOpc==3 .And. !ExistChav("VSD",VOP->VOP_NUMCAM + VOP->VOP_TIPPEN + M->VSD_GRUITE + M->VSD_CODITE )
	
		Retu�rn(.f.)     
	
	EndIf
	
	For nValLin:=1 to Len(aCols)
	    
		If !aCols[nValLin,Len(aCols[nValLin])] .And. aCols[nValLin,FG_POSVAR("VSD_GRUITE")]+aCols[nValLin,FG_POSVAR("VSD_CODITE")] == M->VSD_GRUITE + M->VSD_CODITE .and. nValLin#n
           
			Help("  ",1,"EXISTCHAV")
			Return(.f.)

		EndIf
	                           
	Next          

EndIf

Return(.t.)

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},; //Pesquisar
                     { STR0002 ,"OA240", 0 , 2},;  //Visualizar
                     { STR0003 ,"OA240", 0 , 3},;  //Incluir
                     { STR0004 ,"OA240", 0 , 4},;  //Alterar
                     { STR0005 ,"OA240", 0 , 5}}   //Excluir
Return aRotina
