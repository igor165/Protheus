#INCLUDE "veica620.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � VEICA620 � Autor �  Fabio                � Data � 07/10/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Vendedores por Regiao                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico  (Modelo3)                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VEICA620

PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0006)   // //"Vendedores por Regiao"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"VCB")

Return


/////////////////////////////////
Function COV620(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) },lRet := .T.
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk 
Local nCntFor,_ni := 0
Private aTELA[0][0],aGETS[0]
Private aCols := {}, aHeader := {} , aCpoEnchoice  :={}
Private nLenaCols:=0

//��������������������������������������������������������������Ŀ
//� Cria variaveis M->????? da Enchoice                          �
//����������������������������������������������������������������
RegToMemory("VCB",.t.)

aCpoEnchoice  :={}

dbSelectArea("SX3")
dbSeek("VCB")
While !Eof().and.(x3_arquivo=="VCB")
   if X3USO(x3_usado).and.cNivel>=x3_nivel
      AADD(aCpoEnchoice,x3_campo)
   Endif
   dbSkip()
EndDo

DbSelectArea("VCB")
For nCntFor := 1 TO FCount()
   M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

if nOpc == 3   // inclusao
   nOpcE := 2
   nOpcG := 3
elseif nOpc == 4  // alteracao
   nOpcE := 2
   nOpcG := 4
elseif nOpc == 5  // exclusao
   nOpcE := 2
   nOpcG := 5
else
   nOpcE := 2
   nOpcG := 2
endif

//��������������������������������������������������������������Ŀ
//� Cria aHeader e aCols da GetDados                             �
//����������������������������������������������������������������
nUsado:=0
dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VCD")
aHeader:={}

While !Eof().And.(x3_arquivo=="VCD")
   
  	If X3USO(x3_usado).And.cNivel>=x3_nivel.And.(Alltrim(x3_campo) $ [VCD_TIPAGE/VCD_CODVEN/VCD_NOMVEN])

     	nUsado:=nUsado+1
     	Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
  	  	x3_tamanho, x3_decimal,x3_valid,;
    	x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )

  	Endif  
   
	&("M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)

  	dbSkip()
   
EndDo

dbSelectArea("VCD")
dbSetOrder(1)
dbseek(xFilial("VCD")+VCB->VCB_CODREG)

If nOpc == 3 .Or. !Found()

	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.

	For _ni:=1 to nUsado

		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])

 	Next

Else

  	aCols:={}
   
  	While !eof() .and. VCD->VCD_FILIAL == xFilial("VCD") .and. VCD->VCD_CODREG == M->VCB_CODREG

		AADD(aCols,Array(nUsado+1))
			
	  	For _ni:=1 to nUsado
	
	  		aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
	
	  	Next
	       	
	  	aCols[Len(aCols),nUsado+1]:=.F.
		
		dbSkip()

  	EndDo

	nLenaCols:=Len(aCols)
	   	
EndIf

If Len(aCols)>0
   //��������������������������������������������������������������Ŀ
   //� Executa a Modelo 3                                           �
   //����������������������������������������������������������������
   cTitulo       :=STR0006   //"Grupo de Servico"
   cAliasEnchoice:="VCB"
   cAliasGetD    :="VCD"
   cLinOk        :="If( FS_VLVEND(nOpcG) , FG_OBRIGAT() , .f. )"
   cTudOk        :="Allwaystrue()"
   cFieldOk      :="FG_MEMVAR()"

   DEFINE MSDIALOG oDlg1 TITLE cTitulo From 9,0 to 28,80	of oMainWnd

      EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,1,70,315},,3,,,,,,.F.)
      oGetDados := MsGetDados():New(75,1,143,315,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
      oGetDados:oBrowse:bChange    := {|| FG_AALTER("VCD",nLenaCols,oGetDados) }

   ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| if(oGetDados:TudoOk().And.obrigatorio(aGets,aTela).And.FS_GRCA620(nOpcG),oDlg1:End(),.f.) },{|| oDlg1:End() })

Endif

Return

/////////////////////
Function FS_GRCA620(nOpc)

Local lRet := .t. , i := 0  /*aVetValid := {}, nPos := 0 */
Private lMsHelpAuto := .t., lMsFinalAuto := .f.
                  
//��������������������������������������������������������������Ŀ
//� Executar processamento                                       �
//����������������������������������������������������������������
If nOpc # 2

   Begin Transaction
          
   && Grava arquivo filho
	For i:=1 to len(aCols)

      dbselectArea("VCD")               
      DbSetOrder(1)
      dbseek(xFilial("VCD")+VCB->VCB_CODREG+aCols[I,FG_POSVAR("VCD_TIPAGE")]+aCols[I,FG_POSVAR("VCD_CODVEN")])
		
		If (nOpc == 3 .or. nOpc == 4) .And. !aCols[i,len(aCols[i])]
			
			dbSelectArea("VCD")
			If !RecLock("VCD", !Found() )
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf
			
         FG_GRAVAR("VCD",aCols,aHeader,i)
         VCD->VCD_FILIAL := xFilial("VCD")
         VCD->VCD_CODREG := M->VCB_CODREG
         MsUnlock()
			
		ElseIf Found() .and. nLenaCols>=i
			
			// Deleta
			If !RecLock("VCD",.F.,.T.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf
			
			dbdelete()
			MsUnlock()
			WriteSx2("VCD")
			
		EndIf
		
	Next

   End Transaction
   
Endif                        
lMsHelpAuto := .f. 

      
If !lRet
   MostraErro()
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_VLVEND �Autor  �Andre Luis          � Data �  15/08/01   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se o vendedor ja foi cadastrado na mesma regiao e ���
���          � com o mesmo tipo de agenda.                                ���
�������������������������������������������������������������������������͹��
���Uso       � Oficina / Veiculos / Pecas                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function FS_VLVEND(nOpc)

Local nValLin:=0

FG_MEMVAR()
        
If !aCols[n,Len(aCols[n])]   

	If nOpc==3 .And. !ExistChav("VCD",M->VCB_CODREG+M->VCD_TIPAGE+M->VCD_CODVEN)
	
		Return(.f.)     
	
	EndIf
	
	For nValLin:=1 to Len(aCols)
	    
		If !aCols[nValLin,Len(aCols[nValLin])] .And. aCols[nValLin,FG_POSVAR("VCD_TIPAGE")]+aCols[nValLin,FG_POSVAR("VCD_CODVEN")] == M->VCD_TIPAGE+M->VCD_CODVEN .and. nValLin#n
           
			Help("  ",1,"EXISTCHAV")
			Return(.f.)

		EndIf
	                           
	Next          

EndIf

Return( .t. )

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},;  //Pesquisar
                     { STR0002 ,"COV620", 0 , 2},;  //Visualizar
                     { STR0003 ,"COV620", 0 , 3},;  //Incluir
                     { STR0004 ,"COV620", 0 , 4},;	//Alterar
                     { STR0005 ,"COV620", 0 , 5}}	//Excluir
Return aRotina
