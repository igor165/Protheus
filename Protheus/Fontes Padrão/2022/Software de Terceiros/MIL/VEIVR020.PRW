// 浜様様様曜様様様様�
// � Versao � 02     �
// 藩様様様擁様様様様�
#INCLUDE "veivr020.ch"
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � VEIVR020 � Autor �  Manoel               � Data � 10/08/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Copia da Proposta de Venda de Veiculos                     咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe   �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       �                                                            咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
#Include "protheus.ch"
#Include "FileIO.ch"
Function VEIVR020

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0003) //"Copia de Proposta de Venda de Veiculos"
Private aCores    	:= 	{	{'VV9->VV9_STATUS == "A" .AND. VXA018VEIVD()','lbok_ocean'},;  // Em Aberto com Veiculo ja Vendido
							{'VV9->VV9_STATUS == "A"','BR_VERDE'},;	   						// Em Aberto
							{'VV9->VV9_STATUS == "P"','BR_AMARELO'},;						// Pendente de Aprovacao
							{'VV9->VV9_STATUS == "O"','BR_BRANCO'},;						// Pre-Aprovado
							{'VV9->VV9_STATUS == "L"','BR_AZUL'},;							// Aprovado
							{'VV9->VV9_STATUS == "R"','BR_LARANJA'},;						// Reprovado
							{'VV9->VV9_STATUS == "F"','BR_PRETO'},;							// Finalizado
							{'VV9->VV9_STATUS == "C"','BR_VERMELHO'}}						// Cancelado
INCLUI := .F.
nReg := 0

mBrowse( 6, 1,22,75,"VV9",,,,,,aCores)

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � VR020COP � Autor �  Manoel               � Data � 10/08/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o �Copia de Proposta de Venda de Veiculos                      咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe   �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
FUNCTION VR020COP()
////////////////////
Local bCampo4		:= { |nCPO| Field(nCPO) }
Local nCntFor := 0
Local _ni := 0    
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
dbSelectArea("VV0")
dbSetOrder(1)
dbSeek(xFilial("VV0")+VV9->VV9_NUMATE)
dbSelectArea("SX3")
dbSeek("VV0")
While !Eof().and.(x3_arquivo=="VV0")
	wVar := "M->"+x3_campo
	IF Alltrim(x3_campo) # "VV0_NUMTRA"
		&wVar:= CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

if !Inclui
	RegToMemory("VV0",.f.)
	DbSelectArea("VV0")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo4,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Cria aHeader e aCols da GetDados                             �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
nUsado:=0
dbSelectArea("VVA")
dbSetOrder(1)
dbSeek(xFilial()+M->VV0_NUMTRA)
dbSelectArea("SX3")
dbSeek("VVA")
aHeader:={}
While !Eof().And.(x3_arquivo=="VVA")
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !Alltrim(x3_campo) $ [VVA_TRACPA/VVA_NUMTRA/VVA_CODORI/VVA_SIMVDA/VVA_CODIND/VVA_COMPGC]
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
	Endif
	dbSkip()
End

nOpcE:=2
nOpcG:=2


Acols:={}
dbSelectArea("VVA")
dbSetOrder(1)
dbSeek(xFilial()+M->VV0_NUMTRA)
While !eof() .and. VVA->VVA_FILIAL == xFilial("VVA") .and. M->VV0_NUMTRA == VVA_NUMTRA
	AADD(aCols,Array(nUsado+1))
	For _ni:=1 to nUsado
		aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
	Next
	aCols[Len(aCols),nUsado+1]:=.F.
	dbSkip()
EndDO

cTitulo    :=OemToAnsi(STR0003) //"Copia de Proposta de Venda de Veiculos"
cAliasEnch :="VV0"
cLinOk     :="FG_OBRIGAT"
cTudoOk     :="AllwaysTrue()"
cFieldOk   :="FG_MEMVAR()"

nOpca := 0
lVirtual := .f. //Iif(lVirtual==Nil,.F.,lVirtual)
nLinhas:= 99 //Iif(nLinhas==Nil,99,nLinhas)
         
aMyEncho     := {}
aAltEnchoice := {}
Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
nPosAnt:=9999,      nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0
cAlias2     := "VVA"

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 140 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 01, 140, .T. , .T. } )  //list box superior

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

EnChoice("VV0",nReg,nOpcE,,,,,{@ aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,2,,,,,,lVirtual)
oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,,,,nLinhas,cFieldOk)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||oDlg:End()})

if nOpca == 1
	_lRet := .t.
Else
	_lRet := .f.
Endif

DbSelectArea("VV1")
DbSetOrder(2)
DbSeek(xFilial("VV1")+VVA->VVA_CHASSI)
DbSelectArea("VV2")
DbSetOrder(1)
DbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI)

nDiasVld := str(VV2->VV2_DIAVPR,2)

DbSelectArea("VV0")
DbSetOrder(1)
if _lRet
	
	
		//Executa RdMake da Proposta de Venda
		if ExistBlock("ATENDVEI")
			ExecBlock("ATENDVEI",.f.,.f.,{VV9->VV9_FILIAL , VV9->VV9_NUMATE})
		Endif
Endif

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � MenuDef  � Autor �  Manoel               � Data � 10/08/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o �Menu									                      咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe   �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function MenuDef()
Local aRotina := {	{STR0001,"AxPesqui"		,0,1},; 		// Pesquisar
					{OemToAnsi(STR0002), "VR020COP",0,2},; //"Emitir Copia"
					{STR0009,"VXA018LEG"	,0,4,2,.f.},;	// Legenda
					{STR0010,"VXA018PESQ"	, 0, 1 }}		// Pesq.Avancada

Return aRotina
