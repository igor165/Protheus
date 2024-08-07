#include "Ofioa170.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIOA170 � Autor �  MIL                  � Data � 10/08/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Historico Salarial                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIOA170

Private aRotina := MenuDef()                     
Private cCadastro := OemToAnsi(STR0006)   // Historico Salarial
Private cIndVAI , cChave , cCond , nIndVAI

cIndVAI := CriaTrab(Nil, .F.)
cChave  := "VAI_FILIAL+VAI_CODTEC"
cCond   := "VAI->VAI_FUNPRO == '1'"        
IndRegua("VAI",cIndVAI,cChave,,cCond,OemToAnsi(STR0006) ) // Historico Salarial
                                                                  
DbSelectArea("VAI")
nIndVAI := RetIndex("VAI")
#IFNDEF TOP
   dbSetIndex(cIndVAI+ordBagExt())
#ENDIF
dbSetOrder(nIndVAI+1)

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"VAI")

DbSelectArea("VAI")
RetIndex()

#IFNDEF TOP
   If File(cIndVAI+OrdBagExt())
      fErase(cIndVAI+OrdBagExt())
   Endif
#ENDIF

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AP170    � Autor � MIL                   � Data � 06/06/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Visualiza, inclui e altera dadoas do VAI/VOY               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Oficina                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ap170(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) } , nCntFor := 0 , _ni := 0 
Local  cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk 
Local nPosRec := 0
Private aTELA[0][0],aGETS[0] 
Private aCpoEnchoice  :={} , aCols := {} , aHeader := {}
Private nLenAcols := 0
Private nOpcX := nOpc
Private nUsado := 0
if VAI->(Reccount()) == 0
   MsgInfo(STR0007,STR0008) //E necessario incluir um tecnico para cadastrar o Historico Salarial... # Atencao
   Return (.t.)
Endif   

//��������������������������������������������������������������Ŀ
//� Cria variaveis M->????? da Enchoice                          �
//����������������������������������������������������������������
RegToMemory("VAI",.T.)
DbSelectArea("VAI")
For nCntFor := 1 TO FCount()
   M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

if nOpc == 3         //Inclui
   nOpcE := 2
   nOpcG := 3
elseif nOpc == 4     //Altera     
   nOpcE := 2
   nOpcG := 4
elseif nOpc == 2     //Visualiza
   nOpcE := 2
   nOpcG := 2
else                //Exclui
   nOpcE := 2
   nOpcG := 5
endif

//��������������������������������������������������������������Ŀ
//� Cria aHeader e aCols da GetDados                             �
//����������������������������������������������������������������
nUsado:=0
dbSelectArea("SX3")  
DbSetOrder(1)
dbSeek("VOY")
aHeader:={}
While !Eof().And.(x3_arquivo=="VOY")
   If X3USO(x3_usado).And.cNivel>=x3_nivel .And. (!Alltrim(x3_campo) $ [VOY_FUNPRO/VOY_TIPALT])       // !(X3_ORDEM $ [02/03])
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
   Endif
   &("M->"+x3_campo) := CriaVar(x3_campo)
   dbSkip()
End

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VOY")
ADHeadRec("VOY",aHeader)
// Posicao do registro
nPosRec:=Len(aHeader)
nUsado :=Len(aHeader)

dbSelectArea("VOY")
dbSetOrder(1)
dbSeek(xFilial()+M->VAI_CODTEC+"S")

//If Inclui .Or. !Found()
If !Found()    // Para ficar padr�o com os demais, est� deixando carregar os registros j� cadastrados
   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VOY"
		Else	
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		EndIf
   Next
Else
   aCols:={}
   While !Eof() .And. VOY->VOY_FILIAL == xFilial("VOY") .And. VOY->VOY_FUNPRO == M->VAI_CODTEC .And. VOY->VOY_TIPALT == "S"
       AADD(aCols,Array(nUsado+1))
       For _ni:=1 to nUsado
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VOY->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VOY"
			Else
				aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
			EndIf	
       Next
       aCols[Len(aCols),nUsado+1]:=.F.
       DbSkip()
   End
   nLenaCols     := Len(aCols)
EndIf

If Len(aCols)>0
   //��������������������������������������������������������������Ŀ
   //� Executa a Modelo 3                                           �
   //����������������������������������������������������������������
   cTitulo       :=STR0006   //Historico Salarial
   cAliasEnchoice:="VAI"
   cAliasGetD    :="VOY"
   cLinOk        :="FG_OBRIGAT()"
   cLinOk        :="If( FS_VLHISSAL() , FG_OBRIGAT() , .f. )"
   cTudOk        :="FS_VALSAL()"
   cFieldOk      :="FG_MEMVAR().and. FS_170Fieldok()"

   dbSelectArea("SX3")
   DbSetOrder(1)
   dbSeek("VAI")
   While !Eof().and.(x3_arquivo=="VAI")
      If X3USO(x3_usado).and.cNivel>=x3_nivel
         AADD(aCpoEnchoice,x3_campo)
      Endif
      DbSkip()
   EndDo

   DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,80	of oMainWnd   
   
      EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,1,70,315},,3,,,,,,.F.)
      oGetDados := MsGetDados():New(75,1,143,315,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
      oGetDados:oBrowse:bChange    := {|| FG_AALTER("VOY",nLenaCols,oGetDados) }
      If nOpcX== 2 .or. nOpcX == 5
        oGetDados:oBrowse:bDelete := { || .T. }
      Endif  
      
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(oGetDados:TudoOk().And.obrigatorio(aGets,aTela).And.FS_OA170GRA(nOpc),oDlg:End(),.f.) },{|| oDlg:End() })

EndIf

DbSelectArea("VAI")
//dbSetOrder(nIndVAI+1)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_OA170GR�Autor  �Fabio               � Data �  08/30/00   ���
�������������������������������������������������������������������������͹��
���Descricao �Grava Historico salarial                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Oficina                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_OA170GRA(nOpc)
           
Local lRet := .t. , i := 0
Private lMsHelpAuto := .f., lMsFinalAuto := .f.
                  
If nOpc # 2
  
   Begin Transaction
   
      For i:=1 to len(aCols)
	
         If i > nLenaCols .and. aCols[i,Len(aCols[i])]
            Loop
         EndIf

         DbSelectArea("VOY")
         DbSetOrder(1)
		 DbSeek(xFilial("VOY")+M->VAI_CODTEC+"S"+dtos(aCols[I,FG_POSVAR("VOY_DATALT")]))

         If (nOpc == 3 .Or. nOpc == 4) .And. !(aCols[i,Len(aCols[i])])

            If !RecLock("VOY", !Found() )
               Help("  ",1,"REGNLOCK")
               lRet := .f.
               DisarmTransaction()
               Break               
            EndIf
            
            FG_GRAVAR("VOY",aCols,aHeader,i)
            VOY->VOY_FILIAL := xFilial("VOY")
            VOY->VOY_FUNPRO := M->VAI_CODTEC
            VOY->VOY_TIPALT := "S"
            MsUnlock()

         ElseIf Found()
         
            If !RecLock("VOY",.F.,.T.)
               Help("  ",1,"REGNLOCK")
               lRet := .f.
               DisarmTransaction()
               Break               
            EndIf

            DbDelete()
            MsUnlock()
            WriteSx2("VOY")

         EndIf

      Next
   
   End Transaction
   
EndIf           

If !lRet
   MostraErro()
EndIf
lMsHelpAuto := .f. 


Return(lRet)	


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AP17C    � Autor �  Andre                � Data � 01/10/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Pesquisa no Borwse                                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AP17C

Local nIndex := IndexOrd()

AxPesqui()

DbsetOrder(nIndex)

Return (.t.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_170Fieldok     �Ricardo Farinelli   � Data �  15/08/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida a existencia de itens j� digitados                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao de Concessionarias                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_170Fieldok()
Local cStr := ""
Local nwnk := 0
Local nwnk2:= 0

If nOpcX == 5 .or. nOpcX == 2 .or. aCols[n,Len(aCols[n])]
  Return (.T.)
Endif  

nwnk2 := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="VOY_DATALT"}) 
If nwnk2 > 0 .and. ReadVar()=="M->VOY_DATALT"

   If !aCols[n,Len(aCols[n])]
   	If Empty(M->VOY_DATALT)
	   	Help(" ",1,"OBRIGAT")
		   Return lRet := .F.
   	Endif
   Endif	
   cStr := "|"

	For nwnk := 1 To Len(aCols)
      If nwnk <> n
  		   cStr += IIf(!aCols[nwnk,Len(aCols[nwnk])],Dtoc(aCols[nwnk,nwnk2])+"|","|")
	  		If aCols[nwnk,nwnk2] > M->VOY_DATALT
				Help(" ",1,"DATNMENOR")
				Return lRet := .F.
	  		EndIf
  		Endif  
	Next
	
	If dToc(M->VOY_DATALT) $ cStr
		Help(" ",1,"JAGRAVADO")
		Return lRet := .F.
	Endif

   If nOpcX == 3
      If VOY->(Dbseek(xFilial("VOY")+M->VAI_CODTEC+"S"+DTOS(M->VOY_DATALT),.T.))
   	   Help(" ",1,"JAGRAVADO")
	      Return lRet := .F.
	   ElseIf VOY->VOY_FILIAL+VOY->VOY_FUNPRO+VOY->VOY_TIPALT+DtoS(VOY->VOY_DATALT) == xFilial("VOY")+M->VAI_CODTEC+"S"+DTOS(M->VOY_DATALT)
	   	If VOY->VOY_DATALT > M->VOY_DATALT
				Help(" ",1,"DATNMENOR")
				Return lRet := .F.
	  		EndIf
	   Endif   	   
  	Endif
       
Endif

Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_VLHISSAL�Autor  �Fabio               � Data �  04/10/01  ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida se a Historico salarial ja foi cadastrado           ���
�������������������������������������������������������������������������͹��
���Uso       � Oficina                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_VLHISSAL()

Local nReg    := 0   
Local ix1     := 0   
              
FG_MEMVAR()
               
For ix1 := 1 to len(aCols)

   If aCols[ix1,nUsado+1]
      loop
   EndIf     
   If aCols[ix1,FG_POSVAR("VOY_DATALT")] == M->VOY_DATALT
      nReg ++
      If nReg > 1
         Help("  ",1,"EXISTCHAV")
         Return( .f. )
      EndIf
   Else 
      Loop
   EndIf
   
Next              

Return( .t. )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_VLVALSAL�Autor  �Fabio               � Data �  04/10/01  ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida se a Historico salarial e valido                    ���
�������������������������������������������������������������������������͹��
���Uso       � Oficina                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_VALSAL()

Local ix1     := 0   
              
FG_MEMVAR()
               
For ix1 := 1 to len(aCols)
   If aCols[ix1,nUsado+1]
      loop
   EndIf     
   If aCols[ix1,FG_POSVAR("VOY_PECSAL")] == 0
      Help("  ",1,"A170SEMSAL")
      Return( .f. )
   EndIf
Next              

Return( .t. )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_WSalar �Autor  �Fabio               � Data �  10/20/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida se pode ser alterado o valor do Salario              ���
�������������������������������������������������������������������������͹��
���Uso       � Oficina                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                    
Function FS_WSALARIO()
            
If M->VOY_DATALT <= dDataBase
   Return(.f.)                           
EndIf

Return(.t.)

Static Function MenuDef()
Local aRotina := { { STR0001 ,"Ap17C", 0 , 1}    ,;   //Pesquisar
                      { STR0002 ,"Ap170", 0 , 2} ,;   //Visualizar
                      { STR0003 ,"Ap170", 0 , 3} ,;   //Incluir
                      { STR0004 ,"Ap170", 0 , 4} ,;   //Alterar
                      { STR0005 ,"Ap170", 0 , 5}}     //Excluir
Return aRotina
