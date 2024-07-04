#INCLUDE "protheus.ch"
#INCLUDE "FRTA080.ch"
#INCLUDE 'FWMVCDEF.CH'

#define H_TITULO	1
#define H_CAMPO		2
#define H_PICTURE	3
#define H_TAMANHO	4
#define H_DECIMAL	5
#define H_VALID		6
#define H_USADO		7
#define H_TIPO		8
#define H_F3		9
#define H_CONTEXT	10
#define H_CBOX		11
#define H_RELACAO	12
#define H_WHEN		13
#define H_VISUAL	14
#define H_VLDUSER	15
#define H_PICTVAR	16
#define H_OBRIGAT	17
Static oTimer 											// Objeto de evento (de tempos em tempos o evento e ativado) do TIME do relogio.Local oHora
Static cTabPad		:= SuperGetMV("MV_TABPAD")			// Tabela de preco padrao
Static lCenVenda	:= SuperGetMv("MV_LJCNVDA",,.F.)	// Uso do cenario de vendas
Static aTotais		:= {0,0,0}							// Totais da venda (Valor,Perc.Desc,Val.Desc)
Static oGet			:= NIL								// Objeto get
Static oEnch		:= NIL								// Objeto get
Static oDlg 		:= NIL 								// OBJETO DE TELA
Static cDesVlTot	:= STR0010                         	// Descri��o
Static cVlTot		:= '0'								// soma valor total
Static oPanVA1		:= Nil								// Tela
Static oValor		:= Nil								// Tela
Static aFonCont		:= {}								// controla font
Static	lTotvsPdv	:= STFIsPOS()   

/*���������������������������������������������������������������������������
���Programa  �FRTA080   �Autor  �Microsiga           � Data �  06/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
���������������������������������������������������������������������������*/
Function FRTA080
Local oBrowse	:= Nil // Tela MVC
Local lEmtRdz	:= .F.
Local lTemRedZ	:= .F.
Local lReturn	:= .F. //Impedir o Acesso dessa rotina de qualquer modulo, por isso .F. direto
Local lSair		:= .F.
Local lFwBrowse := .F.
Local cPDV		:= ""

If LjNfPafEcf(SM0->M0_CGC)
	MsgAlert("Rotina n�o pode ser acessada - Requisito Removido do PAF-ECF","PAF-ECF")
Else
	MsgAlert("Rotina n�o pode ser acessada - Fun��es Removidas","PROTHEUS")
EndIf

IF lReturn
	If lFwBrowse
		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias('SL1')
		oBrowse:SetDescription(STR0012) // "Contingencia de ECF - Venda"
		oBrowse:Activate()
	Else
		lReturn := .T.
	    DbSelectArea("SL1")
	    
	    If LjNfPafEcf(SM0->M0_CGC)
	                                                                                  
			// S� pode efetuar nota Manual depois da Redu��o Z
			IFVenda(lEmtRdz)
			
			//Verifica se fora efetuada a redu��o Z de hoje, nesse PDV
			DbSelectArea("SFI")
			SFI->(DbSetOrder(3)) //FI_FILIAL, FI_PDV, FI_DTMOVTO, R_E_C_N_O_, D_E_L_E_T_
			cPDV := AllTrim(LjGetStation("PDV"))
			SFI->(DbSeek(xFilial("SFI") + PadR(cPDV, TamSX3("FI_PDV")[1])))
			While !SFI->(Eof()) .And. !lTemRedZ
				If SFI->(FI_FILIAL+AllTrim(FI_PDV)) == xFilial("SFI")+cPDV .And. SFI->FI_DTREDZ == dDatabase
					lTemRedZ := .T.
				EndIf
				SFI->(DbSkip())
			End
			
			//Valida se houve a primeira venda, pois entre a Redu��o Z
			//do dia anterior e a primeira venda do dia atual eu posso fazer venda manual
			If !lTemRedZ
				SL1->(DbSetOrder(4)) //L1_FILIAL + L1_EMISSAO
				If SL1->(DbSeek(xFilial("SL1")+Dtos(dDatabase)))
				 	While !SL1->(Eof()) .And. (SL1->L1_FILIAL == xFilial("SL1")) .And. (SL1->L1_EMISSAO == dDatabase) .And. !lSair
				 		If AllTrim(SL1->L1_ESPECIE) == "NFM"
				 			lTemRedZ := .T. //Ou seja permite fazer venda de nota manual
				 		EndIf
				 		
				 		//ou seja, foi feita outra venda sem ser manual, via ECF com isso n�o permite a nota manual
						If lTemRedZ	.And. AllTrim(SL1->L1_ESPECIE) <> "NFM" 		
							lTemRedZ:= .F.
							lSair	:= .T.
						EndIf
						
						SL1->(DbSkip())
					End
				EndIf		
			EndIf
			
		 	If !lEmtRdz .And. !lTemRedZ
		 		Alert("N�o � possivel registrar Nota Manual, ECF em condi��es de uso")
		 		lReturn := .T.
		 	EndIf
			
			If lReturn
				Return Nil
			EndIf 
		EndIf
	EndIf
EndIf

If lReturn
	Private cCadastro := STR0001   //"NF Manual"
	Private aRotina := { {STR0001	,"AxPesqui"		,0,1} ,;   //"Pesquisar"
			             {STR0003	,"FRTA080MAN"	,0,3}}     //"Incluir"
	
	SL1->(DbSetOrder(1))
	mBrowse(6,1,22,75,"SL1")
EndIf

Return Nil         

/*���������������������������������������������������������������������������
���Programa  �FRTA080   �Autor  �Microsiga           � Data �  06/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
���������������������������������������������������������������������������*/
Function FRTA080MAN(cAlias,nReg,nOpcx)
Local aArea		:=	GetArea()
Local aObjects  := {}
Local aPosObj   := {}
Local aInfo		:= {}
Local aSizeAut  := MsAdvSize()
Local nGd1,nGd2,nGd3,nGd4
Local nOpcGd	:= IIF(!INCLUI.And.!ALTERA,0,GD_INSERT+GD_UPDATE+GD_DELETE)
Local nOpcA		:= 0
Local cSeek		:= ""
Local bWhile	:= Nil
Local nX   		:= 0
Local aHead		:= {}
Local aCol		:= {}     
Local aCposGD	:= {}
Local aYesUsado	:= {}
Local nSaveSx8 	:= GetSx8Len()
Local aField	:= F080Field()
Local nTamItem	:= TamSX3("LR_ITEM")[1]
Local cNumCaixa := xNumCaixa()													// Codigo do usuario ativo
Local cHora
Local oDoc
Local cDoc
Local oPDV
Local cPDV
Local nLastTotal
Local nVlrTotal
Local nLastItem	
Local nTotItens
Local nVlrBruto
Local oVlrTotal
Local oCupom
Local oTotItens
Local oOnOffLine
Local lOcioso
Local lLocked
Local aItens
Local aMoeda
Local aSimbs
Local nMoedaCor
Local aTotVen
Local oMensagem
Local oFntMoeda
Local cMensagem
Local nRPCInt := 5 
Local WAITID

Fr8Fontes()

//�������������������������������������������������������������������������Ŀ
//� Verifica se o usuario eh um caixa para poder efetuar atendimentos       �
//���������������������������������������������������������������������������
If !IsCaixaLoja( cNumCaixa ) .AND. (nOpcx == 3)
	Aviso( STR0005, STR0006+(cUserName) + ;  //"Atencao" ### "O usuario "
	STR0007, {STR0008} ) //" nao poder� fazer vendas. Utilize a opcao Senhas/Caixas no Menu Miscelanea para incluir um Caixa. Caso j� exista um cadastrado, re-entre no sistema com uma senha de Caixa."    "OK"
	Return Nil	
EndIf

//������������������������������������������������������Ŀ
//� Inicializa a Variaveis da Enchoice.                  �
//��������������������������������������������������������
RegToMemory("SLQ",INCLUI,.T.)

//��������������������������������Ŀ
//�Monta vetores da getdados do DA1�
//����������������������������������
aYesUsado		:= {"LR_ITEM"	, "LR_PRCTAB" }

aCposGD			:= {"LR_ITEM"	, "LR_PRODUTO", "LR_DESCRI"	, "LR_QUANT", ;
					"LR_VRUNIT"	, "LR_VLRITEM",	"LR_UM"		, "LR_DESC"	, ;
					"LR_VALDESC", "LR_TES"	  , "LR_PRCTAB" , "LR_MARCA", ;
					"LR_TIPO"   , "LR_MODELO" , "LR_ESPECIE", "LR_QUALIDA"	}
If HasTemplate("OTC")	//Estes campos s�o fundamentais na hora de incluir produtos no Template de Otica caso haja valida��o T_LimpaVA no campo LR_PRODUTO
	AAdd( aCposGD, "LR_RECEITA" )
	AAdd( aCposGD, "LR_CODGENE" )
	AAdd( aCposGD, "LR_DESCRI2" )
	AAdd( aCposGD, "LR_OLHO"    )
EndIf					

aAlter			:= {"LR_PRODUTO", "LR_QUANT"	, "LR_TES"	, "LR_UM" 	,;
					"LR_DESC"	, "LR_VALDESC"	, "NOUSER"	, "LR_MARCA", ;
					"LR_TIPO"   , "LR_MODELO" 	, "LR_ESPECIE", "LR_QUALIDA"	}
					
cSeek 			:= 	xFilial("SLR")+SLQ->LQ_NUM
bWhile			:=	{||SLQ->LQ_FILIAL+SLQ->LQ_NUM}  
bAfterHeader	:= 	{|aHeader|F080OrHead(@aHeader,@aCposGD)}

FillGetDados(nOpcx,"SLR",1,cSeek,bWhile,,/*aCpoNao*/,aCposGD,,,,,@aHead,@aCol,,,bAfterHeader,,,,aYesUsado)  

nX		:=  aScan(aHead,{|x|AllTrim(x[2]) == "LR_ITEM"})

If (nX > 0) .AND. (Len(aCol) == 1) .AND. Empty(aCol[1][nX])
	aCol[1][nX]	:= StrZero(1,nTamItem)
EndIf

//���������������������������Ŀ
//�Calcula posicao dos objetos�
//�����������������������������
AAdd( aObjects, { 100, 40, .T., .T. } )
AAdd( aObjects, { 100, 60, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects, .T. ) 

//������������������������������������������������������Ŀ
//� Define as posicoes da Getdados a partir do folder    �
//��������������������������������������������������������
nGd1 := aPosObj[2,1]
nGd2 := aPosObj[2,2]
nGd3 := aPosObj[2,3]-15
nGd4 := aPosObj[2,4]-4

//���������������������Ŀ
//�Define objeto da tela�
//�����������������������
DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

//������������������������������Ŀ
//� TIME para ativar samafaro    �
//��������������������������������
DEFINE TIMER oTimer INTERVAL 0 ACTION FR080Timer( ) OF oDlg                           
oTimer:Activate()

//��������������Ŀ
//�Monta Enchoice�
//����������������
oEnch := MsMGet():New("SLR",nReg,nOpcx,,,,,aPosObj[1],,3,,,,,,.T.,,,,,aField)

//����������������Ŀ
//�Cria as GetDados�
//������������������
oGet := MsNewGetDados():New(nGd1,nGd2,nGd3,nGd4,nOpcGd,{||Frt080LOk(@oGet)},{||Frt080TOk(@oGet)},"+LR_ITEM",aAlter,,,,,,oDlg,aHead,aCol) 


oPanVA1  := TPanel():New(nGd3+1, 004, "", oDlg, NIL, .T., .F.,;
								 NIL, NIL, 900, 800, .T., .F. )



@ 002 ,004 SAY cDesVlTot SIZE 100, 008 OF oPanVA1 PIXEL  FONT aFonCont[1]   
@ 002 ,090 MsGet  oValor   VAR cVlTot SIZE 100, 008 OF oPanVA1 PIXEL  RIGHT COLOR CLR_HRED  FONT aFonCont[1] 

oValor:DIsable()

//������������Ŀ
//�Exibe a tela�
//��������������
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Iif(Frt080TOk(@oGet),(nOpca := 1,oDlg:End()),.F.)},{|| nOpca := 0,ODlg:End()})

If ( nOpcA == 1 ) .AND. (nOpcx == 2)    
   Grava(oGet,aField) 
   ConfirmSx8()
EndIf

While (GetSx8Len() > nSaveSX8)
	RollBackSx8()
End

RestArea(aArea)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Grava     �Autor  �Norbert Waage Junior� Data �  06/07/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Gravacao dos dados                                          ���
�������������������������������������������������������������������������͹��
���Uso       �Treinamento AdvPL                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Grava(oGet,aField)

Local nCntFor
Local aAreaSX3	:=	SX3->(GetArea())
Local aDadosProd:= {}
Local aDadosTES	:= {}
Local nDadosMarca		:= {}
Local nDadosTipo		:= {}
Local aDadosModelo		:= {}
Local aDadospecie		:= {}
Local aDadosQualida		:= {}

Local aParcelas	:= {}
Local nLin		:= 0
Local nCpo		:= 0
Local nPosRecNo	:= aScan(oGet:aHeader,{|x|AllTrim(x[2])=="LR_REC_WT"})
Local nPosProd	:= aScan(oGet:aHeader,{|x|AllTrim(x[2])=="LR_PRODUTO"})
Local nPosTES	:= aScan(oGet:aHeader,{|x|AllTrim(x[2])=="LR_TES"})

Local cPafMd5	:= ""
Local cCampo	:= "" 
Local cProduto	:= "" 
Local cForma1	:= ""
Local cForma2	:= ""
Local cForma3	:= ""
Local nX		:= 0 	// Contador                      
Local nPosMarca			:= aScan(oGet:aHeader,{|x|AllTrim(x[2])=="LR_MARCA"})
Local nPosTipo			:= aScan(oGet:aHeader,{|x|AllTrim(x[2])=="LR_TIPO"})
Local nPosModelo		:= aScan(oGet:aHeader,{|x|AllTrim(x[2])=="LR_MODELO"})
Local nPosEspecie		:= aScan(oGet:aHeader,{|x|AllTrim(x[2])=="LR_ESPECIE"})
Local nPosQualida		:= aScan(oGet:aHeader,{|x|AllTrim(x[2])=="LR_QUALIDA"})
Local cNum				:= ""
Local nSaveSx8			:= 0

SX3->(DbSetOrder(1))
SX3->(DbSeek("SL2"))

BEGIN TRANSACTION

nSaveSx8:= GetSx8Len()
cNum	:= GetSx8Num("SL1","L1_NUM")
While (GetSX8Len() > nSaveSx8)
	ConfirmSx8()
End
	
//������������������Ŀ
//�Gravacao dos itens�
//��������������������
For nLin := 1 to Len(oGet:aCols) 

	If !aTail(oGet:aCols[nLin])
		
		cProduto := oGet:aCols[nLin][nPosProd]
		
		If !Empty(cProduto)

			If nModulo == 12 .Or. lTotvsPdv
				aDadosProd	:= GetAdvFVal("SB1",{"B1_LOCPAD"},xFilial("SB1")+cProduto,1,{""})	
			Else 
				aDadosProd	:= GetAdvFVal("SBI",{"BI_LOCPAD"},xFilial("SBI")+cProduto,1,{""})				
			EndIf
			aDadosTES	:= GetAdvFVal("SF4",{"F4_CF"},xFilial("SF4")+oGet:aCols[nLin][nPosTES],1,{""})

			RecLock("SL2",.T.)

			For nCpo := 1 To Len(oGet:aHeader)				
				If (oGet:aHeader[nCpo][H_CONTEXT] != "V" )
					cCampo	:= StrTran(oGet:aHeader[nCpo][H_CAMPO],"LR_","L2_")
					SL2->&(cCampo) := oGet:aCols[nLin][nCpo]
				EndIf				
			Next nCpo

			SL2->L2_FILIAL	:= xFilial("SL2")
			SL2->L2_NUM		:= cNum    
			SL2->L2_CF		:= aDadosTES[1]
			SL2->L2_LOCAL	:= aDadosProd[1]
			SL2->L2_VENDIDO	:= "S"
			SL2->L2_DOC		:= M->LQ_DOC
			SL2->L2_SERIE	:= M->LQ_SERIE
			SL2->L2_EMISSAO	:= dDataBase
			SL2->L2_GRADE	:= "N"
			SL2->L2_VEND	:= M->LQ_VEND
			SL2->L2_SITTRIB := If(SB1->B1_PICM > 0 ,'T'+StrTran(StrTran(StrZero(SB1->B1_PICM,5,2),","),"."),'S'+StrTran(StrTran(StrZero(SB1->B1_ALIQISS,5,2),","),".") )
			SL2->L2_POSIPI	:= SB1->B1_POSIPI
			SL2->L2_VALICM	:= (SB1->B1_PICM/100) * SL2->L2_VLRITEM 
			SL2->L2_VALISS	:= (SB1->B1_ALIQISS/100) * SL2->L2_VLRITEM
			SL2->L2_BASEICM	:= SL2->L2_VLRITEM
			
			//�����������������������������$�
			//�Verifica se executou Upd upd �
			//�----������������������������$�
			If FR080VeUpd("LR")
				SL2->L2_MARCA	:= oGet:aCols[nLin][nPosMarca]
				SL2->L2_TIPO	:= oGet:aCols[nLin][nPosTipo]
				SL2->L2_MODELO	:= oGet:aCols[nLin][nPosModelo]
				SL2->L2_ESPECIE	:= oGet:aCols[nLin][nPosEspecie]
				SL2->L2_QUALIDA	:= oGet:aCols[nLin][nPosQualida]
            EndIf

			If lTotvsPdv
				SL2->L2_SERPDV	:=	STFGetStat("LG_SERPDV")
			Else
				SL2->L2_SERPDV	:= 	LjGetStation("LG_SERPDV")
			EndIf

			cPafMd5 := STxPafMd5("SL2")
			SL2->L2_PAFMD5 := cPafMd5
			SL2->(MsUnlock())
		EndIf

	EndIf

Next nLin


//������������������������Ŀ
//�Atualizacao do CAbecalho�
//��������������������������
DbSelectArea("SL1")
SL1->(DbSetOrder(1))

//������������������������������������������Ŀ
//�RecLock considerando inclusao ou alteracao�
//��������������������������������������������
RecLock("SL1",.T.)

//�����������������������������Ŀ
//�Descarga dos campos na tabela�
//������������������������������� 
For nCpo := 1 to Len(aField)
	
	cCampo := StrTran(aField[nCpo][2],"LQ_","L1_")
	
	If AllTrim(cCampo) == "L1_NUM"
		SL1->L1_NUM := cNum
	Else	
		SL1->&(cCampo) := M->&(aField[nCpo][2])
	EndIf
	
Next nCpo

SL1->L1_FILIAL	:= xFilial("SL1")
SL1->L1_TIPOCLI	:= Posicione("SA1",1,xFilial("SA1")+M->LQ_CLIENTE+M->LQ_LOJA,"A1_PESSOA")
SL1->L1_VLRTOT	:= aTotais[1]
SL1->L1_VLRLIQ	:= aTotais[1]
SL1->L1_VALBRUT	:= aTotais[1]
SL1->L1_VALMERC	:= aTotais[1]
SL1->L1_DTLIM	:= dDataBase
SL1->L1_EMISNF	:= dDataBase
SL1->L1_EMISSAO	:= dDataBase
SL1->L1_HORA	:= Left(Time(),TamSX3("L1_HORA")[1])
SL1->L1_TIPO	:= "V"
SL1->L1_OPERADO	:= xNumCaixa()
SL1->L1_ESTACAO	:= cEstacao
SL1->L1_IMPRIME := "2S"
//SL1->L1_TABELA	:= cTabPad
SL1->L1_DINHEIR	:= aTotais[1] 
SL1->L1_ESPECIE	:= "NFM"

If lTotvsPdv
	SL1->L1_SERPDV	:=	STFGetStat("LG_SERPDV")
Else
	SL1->L1_SERPDV	:= 	LjGetStation("LG_SERPDV")
EndIf

SL1->(MsUnLock())

//����������Ŀ
//�Pagamentos�
//������������
aParcelas := Condicao(	aTotais[1]	, M->LQ_CONDPG	, 0			, dDataBase	,;
		 			 	0			, Nil			, Nil		, 0			)

DbSelectArea("SE4")
SE4->(DbSetOrder(1))
SE4->(DbSeek(xFilial("SE4")+M->LQ_CONDPG))

//�������������������������������������������������������������������������Ŀ
//�Pega a Forma de Pagamento										        �
//���������������������������������������������������������������������������
If Empty(SE4->E4_FORMA)
	cForma1 := "CH"
Else
	cForma1 := SE4->E4_FORMA
EndIf   

If Empty(SE4->E4_FORMA)
	cForma2 := cForma1
Elseif Empty(SubStr(SE4->E4_FORMA,1,3))
	cForma2 := cForma1
Else
	cForma2 := SubStr(SE4->E4_FORMA,1,3)
Endif

//�����������������������������������������������������Ŀ
//� Grava informacoes do arquivo de forma de pagamento  �
//�������������������������������������������������������
If (Len(aParcelas) > 0)

	For nLin := 1 TO Len(aParcelas)

		If nLin == 1
			cForma3 := cForma1
		Else
			cForma3 := cForma2
		EndIf    
		
		If Empty(cForma3)
			cForma3 := "CH"
		EndIf
	
		Reclock("SL4",.T.)   
		
		Replace L4_NUM	   With cNum
		Replace L4_FILIAL  With xFilial("SL4")
		Replace L4_DATA    With aParcelas[nLin][1]
		Replace L4_VALOR   With aParcelas[nLin][2]
		Replace L4_FORMA   With cForma3
		Replace L4_DOC	    With SL1->L1_DOC
		
		SL4->(MsUnlock())
	Next nLin
Endif

END TRANSACTION
RestArea(aAreaSX3)
	
SL4->(DbSeek(xFilial('SL4')+SL1->L1_NUM))
While SL4->(Eof()) .And. (SL4->L4_FILIAL+SL4->L4_NUM == xFilial('SL4')+SL1->L1_NUM)
	RecLock("SL4",.F.)
	REPLACE	L4_SERPDV	WITH	SL1->L1_SERPDV
	REPLACE	L4_CONTDOC	WITH	SL1->L1_CONTDOC
	REPLACE	L4_CONTONF	WITH	SL1->L1_CONTONF	
	SL4->(MSUnlock())
	
	RecLock("SL4",.F.)
	cPafMd5 := STxPafMd5('SL4') 
	Replace L4_PAFMD5 	With cPafMd5
	SL4->(MsUnlock())
	
	SL4->(DbSkip())
EndDo

RecLock("SL1",.F.)	
cPafMd5 		:= STxPafMd5('SL1')     
SL1->L1_PAFMD5 	:= cPafMd5
SL1->L1_SITUA	:= "00"
SL1->(MsUnlock())

cVlTot := '0'

Return Nil

/*���������������������������������������������������������������������������
���Programa  �Frt080LOk �Autor  �Venda Crm           � Data �  06/07/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida inclusao                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
���������������������������������������������������������������������������*/

Static Function Frt080LOk(oGet)

Local lRet	:= .T.			// Retorno da fun��o

Return lRet 

/*���������������������������������������������������������������������������
���Programa  �Frt080TOk �Autor  �Venda Crm           � Data �  06/07/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida inclusao                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
���������������������������������������������������������������������������*/
Static Function Frt080TOk(oGet)
Local nX 		:= 0
Local nPosVTot	:= aScan(oget:aHeader,{|x| AllTrim(x[2]) == "LR_VLRITEM"})

aTotais := {0,0,0}

For nX := 1 to Len(oGet:aCols)   
	If !aTail(oGet:aCols[nX])
		aTotais[1] += oGet:aCols[nX][nPosVTot]
	EndIf
Next nX

Return .T.

/*���������������������������������������������������������������������������
���Programa  �F080Field �Autor  �Vendas CRM          � Data �  08/06/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta a lista de campos a serem exibidos no cabecalho da te-���
���          �la de venda off-line.                                       ���
�������������������������������������������������������������������������͹��
���Uso       �FRTA080                                                     ���
���������������������������������������������������������������������������*/
Static Function F080Field()

Local aCampos 	:= {} 				// Campos Cabe�ario
Local aArea		:= GetArea()		// Amazena area da tabela
Local nX		:= 	0				// Contador
Local aCpos		:= {} 				// Array de Cabe�ario

//�������������������������������Ŀ
//�Verifica se foi executado upd38�
//���������������������������������

If FR080VeUpd("LQ")
	aCpos := {"LQ_NUM","LQ_VEND","LQ_CLIENTE","LQ_LOJA","LQ_DOC","LQ_SERIE","LQ_CONDPG",  "LQ_SUBSERI"}
Else
	aCpos := {"LQ_NUM","LQ_VEND","LQ_CLIENTE","LQ_LOJA","LQ_DOC","LQ_SERIE","LQ_CONDPG", "LQ_VLRTOT"}
EndIf

DbSelectArea("SX3")
DbSetOrder(2)

For nX := 1 to Len(aCpos)
	If SX3->(DbSeek(aCpos[nX])) //.AND. X3USO(SX3->X3_USADO) 
	   	Aadd( aCampos, {SX3->X3_TITULO,;
						SX3->X3_CAMPO,;
						SX3->X3_TIPO,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_PICTURE,;
						&("{||" + AllTrim(SX3->X3_VALID)+ "}"),;
						X3Obrigat(SX3->X3_CAMPO),;
                    						SX3->X3_NIVEL,;
						SX3->X3_RELACAO,;
						SX3->X3_F3,;
						&("{||" + AllTrim(SX3->X3_WHEN) + "}"),;
						SX3->X3_VISUAL=="V",;
						.F.,; 
						SX3->X3_CBOX,;
						VAL(SX3->X3_FOLDER),;
						.F.,;
						""} )
	Endif
Next nX

//��������������������Ŀ
//�Validacao do cliente�
//����������������������
If (nX := aScan(aCampos,{|x| AllTrim(x[2]) == "LQ_CLIENTE" })) > 0
	aCampos[nX][7] := {||EXISTCPO("SA1", M->LQ_CLIENTE+PADR(M->LQ_LOJA,2))}
EndIf

//�����������������Ŀ
//�Validacao da loja�
//�������������������
If (nX := aScan(aCampos,{|x| AllTrim(x[2]) == "LQ_LOJA" })) > 0
	aCampos[nX][7] := {||EXISTCPO("SA1", M->LQ_CLIENTE+PADR(M->LQ_LOJA,2))}
EndIf  

//����������������������������������Ŀ
//�Validacao da condicao de pagamento�
//������������������������������������
If (nX := aScan(aCampos,{|x| AllTrim(x[2]) == "LQ_CONDPG" })) > 0
	aCampos[nX][7] := {||EXISTCPO("SE4",M->LQ_CONDPG)}
	aCampos[nX][11]:= "SE4"
EndIf

RestArea(aArea)

Return aCampos

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F080OrHead�Autor  �Vendas CRM          � Data �  09/06/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ordena o aHeader de acordo com a estrutura do aCposGD e de- ���
���          �fine as propriedades de cada campo editado.                 ���
�������������������������������������������������������������������������͹��
���Parametros�ExpA1 - aHeader montado pela FillGetDados                   ���
���          �ExpA2 - Lista dos campos a serem exibidos ordenada          ���
�������������������������������������������������������������������������͹��
���Uso       �FRTA080                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function F080OrHead(aHeader,aCposGD)

Local aTMP		:= {}
Local nX		:= 0
Local nPos		:= 0
Local cCampo	:= ""

For nX := 1 to Len(aCposGD)
	If (nPos := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim(aCposGD[nX])}) ) > 0
		AAdd(aTMP,aClone(aHeader[nPos]))
	EndIf
Next nX

aHeader := aClone(aTMP)

//���������������������Ŀ
//�Validacoes do produto�
//�����������������������
If (nPos := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_PRODUTO"})) > 0
	If nModulo <> 12 .And. !lTotvsPdv 
		aHeader[nPos][H_F3] 	:= "FRT"
	EndIf
	aHeader[nPos][H_VALID]	:= "FRT080Prod(M->LR_PRODUTO)"
EndIf

//������������������������Ŀ
//�Validacoes da quantidade�
//��������������������������
If (nPos := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_QUANT"})) > 0
	aHeader[nPos][H_VALID]	:= "FRT080Qtd(M->LR_QUANT)"
EndIf

//������������������������Ŀ
//�Validacoes do desconto %�
//��������������������������
If (nPos := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_DESC"})) > 0
	aHeader[nPos][H_VALID]	:= "FRT080Desc(M->LR_DESC,1)"
EndIf

//������������������������������Ŀ
//�Validacoes do desconto (valor)�
//��������������������������������
If (nPos := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_VALDESC"})) > 0
	aHeader[nPos][H_VALID]	:= "FRT080Desc(M->LR_VALDESC,2)"
EndIf

//�����������������Ŀ
//�Validacoes da TES�
//�������������������
If (nPos := aScan(aHeader,{|x| AllTrim(x[2]) == "LR_TES"})) > 0
	aHeader[nPos][H_VALID]	:= "ExistCpo('SF4')"
EndIf

Return Nil

/*���������������������������������������������������������������������������
���Programa  �Frt080Prod�Autor  �Vendas CRM          � Data �  09/06/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Preenche os dados no aCols baseado no produto escolhido     ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Codigo do produto vendido                           ���
�������������������������������������������������������������������������͹��
���Uso       �FRTA080                                                     ���
���������������������������������������������������������������������������*/
Function Frt080Prod(cProduto)

Local lRet		:= .T.
Local aArea		:= GetArea()
Local nPosDescr	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_DESCRI"	})
Local nPosUM	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_UM" 	})
Local nPosTS	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_TES" 	})
Local nPosVlUn	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_VRUNIT"	})
Local nPosQuant	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_QUANT"  })  
Local nPosDesc	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_DESC"   })
Local nPosVTot	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_VLRITEM"})
Local nPosPTab	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_PRCTAB"})
Local nPrecoTab	:= 0
Local nRegDesc	:= 0
Local cTs		:= SuperGetMV("MV_TESSAI")

Default cProduto	:= &(ReadVar())

If nModulo == 12 .Or. lTotvsPdv
	DbSelectArea("SB1")
	DbSetOrder(1)
	lRet :=	DbSeek(xFilial("SB1")+cProduto)
Else
	DbSelectArea("SBI")
	DbSetOrder(1)
	lRet :=	DbSeek(xFilial("SBI")+cProduto)
EndIf

If lRet
	
	DbSelectArea("SF4")
	SF4->(DbSetOrder(1))
	
	If nModulo == 12 .Or. lTotvsPdv
		aCols[N][nPosDescr]	:= SB1->B1_DESC
		aCols[N][nPosUM] 	:= SB1->B1_UM
		aCols[N][nPosQuant]	:= 1
			
		If SF4->(DbSeek(xFilial("SF4")+SB1->B1_TS))
			aCols[N][nPosTS]:= SB1->B1_TS
		Else
		    aCols[N][nPosTS]:= cTs
		EndIf       
	Else 
		aCols[N][nPosDescr]	:= SBI->BI_DESC
		aCols[N][nPosUM] 	:= SBI->BI_UM
		aCols[N][nPosQuant]	:= 1

		If SF4->(DbSeek(xFilial("SF4")+SBI->BI_TS))
			aCols[N][nPosTS]:= SBI->BI_TS
		Else
			aCols[N][nPosTS]:= cTs
		EndIf
	EndIf
	
	LjxeValPre(@nPrecoTab, cProduto, M->LQ_CLIENTE, M->LQ_LOJA )
	If nModulo == 12 .Or. lTotvsPdv
		aCols[N][nPosDescr]	:= SB1->B1_DESC
		aCols[N][nPosUM] 	:= SB1->B1_UM
	Else
		aCols[N][nPosDescr]	:= SBI->BI_DESC
		aCols[N][nPosUM] 	:= SBI->BI_UM
	EndIf
	aCols[N][nPosQuant]	:= 1

	aCols[N][nPosVlUn]	:= nPrecoTab 
	aCols[N][nPosPTab]	:= nPrecoTab

	If lCenVenda
		//���������������������������������������������������������Ŀ
		//�Calcula o desconto a partir da regra de descontos - ITENS�
		//�����������������������������������������������������������
		nRegDesc := LjRgrDesc(cProduto,M->LQ_CLIENTE,M->LQ_LOJA,cTabPad,aCols[N][nPosQuant],1)
		If nRegDesc > 0 
			aCols[n][nPosDesc] := nRegDesc 
			FRT080Desc(nRegDesc,1)
		Else
			aCols[N][nPosVTot]	:= aCols[N][nPosQuant] * aCols[N][nPosVlUn]
		EndIf
	Else
		aCols[N][nPosVTot]	:= aCols[N][nPosQuant] * aCols[N][nPosVlUn]
	EndIf
	
EndIf

RestArea(aArea)


FR080SOMA()

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Frt080Qtd �Autor  �Vendas CRM          � Data �  06/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo dos valores na alteracao da quantidade              ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Quantidade vendida                                  ���
�������������������������������������������������������������������������͹��
���Uso       �FRTA080                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Frt080Qtd(nQuant)

Local lRet		:= .T.
Local aArea		:= GetArea()
Local nPosVlUn	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_VRUNIT" })
Local nPosVTot	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_VLRITEM"})
Local nPosDesc	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_DESC"   })
Local nPosVDesc	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_VALDESC"})
Local nPosProd	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_PRODUTO"})

Default nQuant	:= &(ReadVar())

lRet := nQuant > 0

If lRet

	aCols[N][nPosVTot]	:= nQuant * aCols[N][nPosVlUn]
	aCols[N][nPosDesc]	:= 0
	aCols[N][nPosVDesc]	:= 0

	If lCenVenda
		//���������������������������������������������������������Ŀ
		//�Calcula o desconto a partir da regra de descontos - ITENS�
		//�����������������������������������������������������������
		nRegDesc := LjRgrDesc(aCols[n][nPosProd],M->LQ_CLIENTE,M->LQ_LOJA,cTabPad,nQuant,1)
		If nRegDesc > 0
			aCols[n][nPosDesc] := nRegDesc 
			FRT080Desc(nRegDesc,1)
		EndIf
	EndIf
	
EndIf

RestArea(aArea)

FR080SOMA()

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FRT080Desc�Autor  �Vendas CRM          � Data �  09/06/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Aplica os descontos no item                                 ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Desconto ou % de desconto, dependendo de ExpN2      ���
���          �ExpN2 - Tipo de desconto (1 - Percentual,2 - Valor)         ���
�������������������������������������������������������������������������͹��
���Uso       �FRTA080                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FRT080Desc(nDesc,nTpDesc)

Local lRet		:= .T.
Local nPosVlUn	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_VRUNIT" })
Local nPosVTot	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_VLRITEM"})
Local nPosDesc	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_DESC"   })
Local nPosVDesc	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_VALDESC"})
Local nPosQuant	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_QUANT"  })
Local nPosPTab	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_PRCTAB"})
Local nValBrut	:= 0
Local nValLiq	:= 0

//������������������Ŀ
//�Obtem a quantidade�
//��������������������
If AllTrim(ReadVar()) == "M->LR_QUANT"
	nQuant	:= M->LR_QUANT
Else
	nQuant	:= aCols[N][nPosQuant]
EndIf

//������������������������������Ŀ
//�Calculo de desconto percentual�
//��������������������������������
If nTpDesc == 1

	nValBrut	:= (nQuant * aCols[N][nPosPTab])
	nValLiq		:= (nQuant * aCols[N][nPosPTab]) * (1 - (nDesc/100))
	
	aCols[N][nPosVTot]	:= nValLiq
	aCols[N][nPosVDesc]	:= nValBrut-nValLiq
	aCols[N][nPosVlUn]	:= nValLiq/nQuant
	
//�����������������������������Ŀ
//�Calculo de desconto por valor�
//�������������������������������
ElseIf nTpDesc == 2

	nValBrut	:= (nQuant * aCols[N][nPosPTab])
	nValLiq		:= (nQuant * aCols[N][nPosPTab]) - nDesc
	
	aCols[N][nPosVTot]	:= nValLiq
	aCols[N][nPosDesc]	:= (1-(nValLiq/nValBrut)) * 100
	aCols[N][nPosVlUn]	:= nValLiq/nQuant
	
EndIf

FR080SOMA()

Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FR080Timer�Autor  �Vendas CRM          � Data �  09/06/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ativa semafaro			                                  ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FRTA080 - time                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function FR080Timer()
    
    IpcGo('FRONTVENDA')

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FR080SOMA �Autor  �Vendas CRM          � Data �  04/01/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Soma Valor Total			                                  ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FRTA080                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FR080SOMA()

Local nPosVTot	:= 0
Local nX 		:= 0
Local nValor 	:= 0



nPosVTot	:= aScan(aHeader,{|x| AllTrim(x[2]) == "LR_VLRITEM"})
	
For nX := 1 to Len(aCols)   
	If !(aCols[nX,Len(aHeader)+1])
		nValor += aCols[nX][nPosVTot]
	EndIf
Next nX	
	
	
cVlTot := TRANSFORM(nValor,'@E 99,999,999.99')
	
oValor:CtrlRefresh()	

Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FR080VeUpd�Autor  �Vendas CRM          � Data �  04/01/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se foi rodado Upd 38 ou 34                         ���
�������������������������������������������������������������������������͹��
���Parametros�1 - Se � itens ou cabe�ario                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FRTA080                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FR080VeUpd(cTipo)

Local lRet	  := .F.	// Retorno da variavel

Default cTipo := "" 	// Verifica se � cabe�ario ou itens

If cTipo == ""
	lRet := .F.
ElseIf cTipo == "LR"
	lRet :=  (	SLR->( FieldPos( "LR_MARCA") ) 		> 0		.AND. ;
				SLR->( FieldPos( "LR_TIPO") ) 		> 0		.AND. ;
				SLR->( FieldPos( "LR_MODELO") )		> 0 	.AND. ;
				SLR->( FieldPos( "LR_ESPECIE"))		> 0 	.AND. ;
				SLR->( FieldPos( "LR_QUALIDA"))		> 0		.AND. ;
				SL2->( FieldPos( "L2_MARCA") ) 		> 0		.AND. ;
				SL2->( FieldPos( "L2_TIPO") ) 		> 0		.AND. ;
				SL2->( FieldPos( "L2_MODELO") )		> 0 	.AND. ;
				SL2->( FieldPos( "L2_ESPECIE"))		> 0 	.AND. ;
				SL2->( FieldPos( "L1_QUALIDA"))		> 0)
ElseIf cTipo == "LQ"
	lRet := (SLQ->( FieldPos( "LQ_SUBSERI"))		> 0)
Else
	lRet := .F.
EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � LjFontes	 � Autor � Vendas Cliente       � Data � 01/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Carrega no array PRIVATE aFontes os fontes que serao usados���
���			 � na exibicao das telas.									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � LjFontes()					                         	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � LOJA701 													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Fr8Fontes()

Local oFonte1
Local oFonte2
Local oFonte3

DEFINE FONT oFonte1 NAME "Arial" SIZE 12,17 BOLD 
DEFINE FONT oFonte2 NAME "Arial" SIZE 08,17 BOLD
DEFINE FONT oFonte3 NAME "Courier New"

aAdd(aFonCont, oFonte1)
aAdd(aFonCont, oFonte2)
aAdd(aFonCont, oFonte3)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � LjFontes	 � Autor � Vendas Cliente       � Data � 01/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Carrega no array PRIVATE aFontes os fontes que serao usados���
���			 � na exibicao das telas.									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � LjFontes()					                         	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � LOJA701 													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aRotina := {} // Carrega menu

ADD OPTION aRotina Title STR0014    Action 'VIEWDEF.FRTA080' OPERATION 3 ACCESS 0 // 'Incluir'

Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � LjFontes	 � Autor � Vendas Cliente       � Data � 01/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Carrega no array PRIVATE aFontes os fontes que serao usados���
���			 � na exibicao das telas.									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � LjFontes()					                         	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � LOJA701 													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oStruSLQ 	:= 	Nil // Estrutura SLQ
Local oStruSLR 	:= 	Nil // Estrutura SLR
Local oModel 	:= 	Nil // Model  
Local aTabela  	:= {}	// Informacoes da tabela

//����������������������������������������
//�Monta estrutura de tabela de cabecario�
//����������������������������������������
aTabela		:= {"LQ_NUM","LQ_VEND","LQ_CLIENTE","LQ_LOJA",;
				"LQ_DOC","LQ_SERIE","LQ_CONDPG","LQ_SUBSERI",;
				"LQ_FILIAL", "LQ_NUM"}

oStruSLQ 	:= Frt8MvcField('SLQ', aTabela)

//��������������������������������Ŀ
//�Monta estrura de tabela de Itens�
//����������������������������������
aTabela		:= {"LR_ITEM"	, "LR_PRODUTO", "LR_DESCRI"	, "LR_QUANT", ;
				"LR_VRUNIT"	, "LR_VLRITEM",	"LR_UM"		, "LR_DESC"	, ;
				"LR_VALDESC", "LR_TES"	  , "LR_PRCTAB" , "LR_MARCA", ;
				"LR_TIPO"   , "LR_MODELO" , "LR_ESPECIE", "LR_QUALIDA",;
				"LR_FILIAL"	, "LR_NUM"}

oStruSLR	:= Frt8MvcField('SLR', aTabela)

//���������������Ŀ
//�Instacia Objeto�
//�����������������
oModel 	:= 	MPFormModel():New( 'COMP021MODEL', /*bPreValidacao*/, /*bPosValidacao*/, { |oMdl| Frt80MvcGr( oMdl ) }, /*bCancel*/ )

oModel:AddFields( 'SLQMASTER', /*cOwner*/, oStruSLQ ) 

oModel:AddGrid( 'SLRDETAIL'    , 'SLQMASTER',  oStruSLR, /*B*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:AddCalc( 'COMP022CALC1' , 'SLQMASTER', 'SLRDETAIL', 'LR_VLRITEM', 'LQTOTAL', 'SUM', {||.T.} )

oModel:SetRelation( 'SLRDETAIL', { { 'LR_FILIAL', 'xFilial( "SLR" )' }, { 'LR_NUM', 'LQ_NUM' } }, 'LR_FILIAL + LR_NUM' )

oModel:GetModel( 'SLRDETAIL' ):SetOptional(.T.)

oModel:SetDescription( 'Contigencia' )

oModel:GetModel( 'SLQMASTER' ):SetDescription(STR0015) // "Dados da nota"
oModel:GetModel( 'SLRDETAIL' ):SetDescription(STR0016) // "Dados dos itens da nota"

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ViewDef	 � Autor � Vendas Cliente       � Data � 01/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Model View                                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � LjFontes()					                         	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � LOJA701 													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()

Local oStruSLQ 	:= Nil	// Estrutura SLQ
Local oStruSLR 	:= Nil	// Estrutura SLR
Local oModel 	:= Nil	// Model  
Local aTabela	:= {}	// Informacoes da tabela
Local oView 	:= Nil	// Objeto para model view

//����������������������������������������
//�Monta estrutura de tabela de cabecario�
//����������������������������������������
aTabela		:= {"LQ_VEND","LQ_CLIENTE","LQ_DOC","LQ_SERIE",;
				"LQ_SUBSERI","LQ_CONDPG"}

oStruSLQ 	:= Frt8FieldV('SLQ', aTabela)

//��������������������������������Ŀ
//�Monta estrura de tabela de Itens�
//����������������������������������
aTabela		:= {"LR_ITEM"	, "LR_PRODUTO", "LR_DESCRI"	, "LR_QUANT", ;
				"LR_VRUNIT"	, "LR_VLRITEM",	"LR_UM"		, "LR_MARCA", ;
				"LR_TIPO"   , "LR_MODELO" , "LR_ESPECIE", "LR_QUALIDA"}

 
oStruSLR	:= Frt8FieldV('SLR', aTabela)

//���������������Ŀ
//�Instacia Objeto�
//�����������������
oModel   	:= FWLoadModel( 'FRTA080' )
oView 		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_SLQ', oStruSLQ, 'SLQMASTER' )
                                                                                      	

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_SLR', oStruSLR, 'SLRDETAIL' )


oCalc1 := FWCalcStruct( oModel:GetModel( 'COMP022CALC1') )
oCalc1:SetProperty( 'LQTOTAL', MVC_VIEW_TITULO, STR0013 )  // 'Valor Total:'

oView:AddField( 'VIEW_CALC', oCalc1, 'COMP022CALC1' )


// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 25 )
oView:CreateHorizontalBox( 'INFERIOR', 55 )
oView:CreateHorizontalBox( 'INFERIOR2', 20 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_SLQ', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_SLR', 'INFERIOR' )
oView:SetOwnerView( 'VIEW_CALC', 'INFERIOR2' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_SLR', 'LR_ITEM' )


// Liga a identificacao do componente
oView:EnableTitleView('VIEW_SLQ',STR0015) // 'DADOS DA VENDA'
oView:EnableTitleView('VIEW_SLR',STR0016) // 'DADOS DOS ITENS'


Return oView

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Frt8MvcField� Autor � Vendas Cliente      � Data � 01/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Carrega no array PRIVATE aFontes os fontes que serao usados���
���			 � na exibicao das telas.									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � LjFontes()					                         	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � LOJA701 													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Frt8MvcField(cAlias, aTabela)

Local oStruct 	:= FWFormModelStruct():New()	// Estrutura
Local nX		:= 0							// Contador
Local cValid	:= ''							// Validacao para o bValid
Local bValid	:= {}							// Validades ��o X3
Local bWhen		:= {}							// Em quanto do x3
Local bRelac	:= {}							// Relacao do x3
Local cX2Unico  := "LR_FILIAL+LR_NUM+LR_ITEM+LR_ITEMSD1" // X2_UNICO da tabela SLR

Default cAlias 	:= 'LR'							// alias que criara estrutura													
Default aTabela := {}                           // campos da tabelas

If ExistFunc('FWX2Unico') 
	cX2Unico := FWX2Unico(cAlias) 
EndIf

oStruct:AddTable( 							;
FWX2CHAVE()	                			, 	;  	// [01] Alias da tabela
StrTokArr( cX2Unico, ' + ' ) 		, 	;  	// [02] Array com os campos que correspondem a primary key
FWX2Nome( cAlias ) )                 					// [03] Descri��o da tabela

//������������������������������Ŀ
//�Carrega informa��es dos campos�
//��������������������������������
DbSelectArea('SX3')
SX3->(DbSetOrder(2))

For nX := 1 To Len(aTabela)

     If DbSeek(aTabela[nX])
     
         cValid := Frt80CrBVa(aTabela[nX])  
          
          bValid := FwBuildFeature(1, AllTrim(cValid) )
     
          bWhen  := FwBuildFeature(2, AllTrim(SX3->X3_WHEN) )
          
          If AllTrim(SX3->X3_CAMPO) == 'LR_NUM'
                bRelac := FwBuildFeature(3,'00')
          ElseIf AllTrim(SX3->X3_CAMPO) == 'LQ_NUM'
                bRelac := FwBuildFeature(3,'00' )
          Else
                bRelac := FwBuildFeature( 3, AllTrim( SX3->X3_RELACAO ) )
          EndIf
          
          oStruct:AddField(                                   ;
                     AllTrim( X3Titulo()  )         ,     ;              // [01] Titulo do campo
                     AllTrim( X3Descric() )         ,     ;              // [02] ToolTip do campo
                     AllTrim( SX3->X3_CAMPO )       ,     ;              // [03] Id do Field
                     SX3->X3_TIPO                   ,     ;              // [04] Tipo do campo
                     SX3->X3_TAMANHO                ,     ;              // [05] Tamanho do campo
                     SX3->X3_DECIMAL                ,     ;              // [06] Decimal do campo
                     bValid                         ,     ;              // [07] Code-block de valida��o do campo
                     bWhen                          ,     ;              // [08] Code-block de valida��o When do campo
                     StrTokArr( AllTrim( X3CBox() ),';') , ;                  // [09] Lista de valores permitido do campo
                     X3Obrigat( SX3->X3_CAMPO )     , ;                  // [10] Indica se o campo tem preenchimento obrigat�rio
                     bRelac                         , ;                  // [11] Code-block de inicializacao do campo
                     NIL                            , ;                  // [12] Indica se trata-se de um campo chave
                     NIL                            , ;                  // [13] Indica se o campo pode receber valor em uma opera��o de update.
                     ( SX3->X3_CONTEXT == 'V' )     )                    // [14] Indica se o campo � virtual
          EndIf     

Next nX




If cAlias == 'SLR'
	oStruct:AddTrigger( ;
	'LR_PRODUTO'  , ;                  	// [01] Id do campo de origem
	'LR_DESCRI'  , ;                   	// [02] Id do campo de destino
	 { || .T. } , ; 					// [03] Bloco de codigo de valida��o da execu��o do gatilho
	 &('{ |x| Fr8ValfPro() }') )		// [04] Bloco de codigo de execu��o do gatilho
EndIf


If cAlias == 'SLR'
	oStruct:AddTrigger( ;
	'LR_PRODUTO'  , ;                  	// [01] Id do campo de origem
	'LR_TES'  , ;                       // [02] Id do campo de destino
	 { || .T. } , ; 					// [03] Bloco de codigo de valida��o da execu��o do gatilho
	 &('{ |x| Fr8Tes() }') )   		// [04] Bloco de codigo de execu��o do gatilho
EndIf


If cAlias == 'SLR'
	oStruct:AddTrigger( ;
	'LR_PRODUTO'  , ;                	// [01] Id do campo de origem
	'LR_QUANT'  , ;                     // [02] Id do campo de destino
	{ || .T. } , ; 						// [03] Bloco de codigo de valida��o da execu��o do gatilho
	{ |oModel| 1 } )   					// [04] Bloco de codigo de execu��o do gatilho
EndIf

If cAlias == 'SLR'
	oStruct:AddTrigger( ;
	'LR_PRODUTO'  , ;              		// [01] Id do campo de origem
	'LR_UM'  , ;                     	// [02] Id do campo de destino
	{ || .T. } , ; 						// [03] Bloco de codigo de valida��o da execu��o do gatilho
	{ |oModel| Fr8VaUn() } )   			// [04] Bloco de codigo de execu��o do gatilho
EndIf


If cAlias == 'SLR'
	oStruct:AddTrigger( ;
	'LR_PRODUTO'  , ;               	// [01] Id do campo de origem
	'LR_VRUNIT'  , ;                  	// [02] Id do campo de destino
	{ || .T. } , ; 						// [03] Bloco de codigo de valida��o da execu��o do gatilho
	{ |oModel| Fr8VaVl() } )   			// [04] Bloco de codigo de execu��o do gatilho
EndIf

If cAlias == 'SLR' 
	oStruct:AddTrigger( ;
	'LR_PRODUTO'  , ;                 	// [01] Id do campo de origem
	'LR_VLRITEM'  , ;                  	// [02] Id do campo de destino
	{ || .T. } , ; 						// [03] Bloco de codigo de valida��o da execu��o do gatilho
	{ |oModel| Fr8VaVl() } )   			// [04] Bloco de codigo de execu��o do gatilho
EndIf

If cAlias == 'SLR'
	oStruct:AddTrigger( ;
	'LR_QUANT'  , ;                		// [01] Id do campo de origem
	'LR_VLRITEM'  , ;              		// [02] Id do campo de destino
	{ || .T. } , ; 						// [03] Bloco de codigo de valida��o da execu��o do gatilho
	&('{ |x| Fr8VaQt(x) }') )  			// [04] Bloco de codigo de execu��o do gatilho
 
EndIf


If cAlias == 'SLR'
	oStruct:AddTrigger( ;
	'LR_VRUNIT'  , ;                	// [01] Id do campo de origem
	'LR_VLRITEM'  , ;              		// [02] Id do campo de destino
	{ || .T. } , ; 						// [03] Bloco de codigo de valida��o da execu��o do gatilho
	&('{ |x| Fr8VaVu(x) }') )  			// [04] Bloco de codigo de execu��o do gatilho
 
EndIf

If cAlias == 'SLQ'
	oStruct:AddTrigger( ;
	'LQ_CLIENTE'  , ;                	// [01] Id do campo de origem
	'LQ_LOJA'  , ;              		// [02] Id do campo de destino
	{ || .T. } , ; 						// [03] Bloco de codigo de valida��o da execu��o do gatilho
	&('{ |x| Fr8Valj(x) }') )  			// [04] Bloco de codigo de execu��o do gatilho
 
EndIf


Return(oStruct)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Frt8MvcField� Autor � Vendas Cliente      � Data � 01/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Valida o campos do mvc                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Frt8FieldV()					                         	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � LOJA701 													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Frt8FieldV(cAlias, aTabela)

Local oStruct 	:= FWFormViewStruct():New()		// Estrutura
Local nX		:= 0							// Contador
Local aArea     := GetArea()					// reserva area
Local aAreaSX3  := SX2->( GetArea() )			// reserva area
Local aCombo    := {}							// informa��es de combo
Local nInitCBox := 0 							// numeros de combo
Local nMaxLenCb := 0 							// Numero maximo de combo
Local aAux      := {}							// Array auxiliar
Local nI        := 0							// contador
Local cGSC      := ''							// CGC
Local bPictVar	:= {}							// Picvar do X3

Default cAlias 	:= 'LR'							// Alias Padrao	
Default aTabela := {}							// Campos da tabelas

//������������������������������Ŀ
//�Carrega informa��es dos campos�
//��������������������������������
DbSelectArea('SX3')
SX3->(DbSetOrder(2))

For nX := 1 To Len(aTabela)

	If DbSeek(aTabela[nX])
	
		aCombo := {}
	
		If !Empty( X3Cbox() )
	
			nInitCBox := 0
			nMaxLenCb := 0
	
			aAux := RetSX3Box( X3Cbox() , @nInitCBox, @nMaxLenCb, SX3->X3_TAMANHO )
	
			For nI := 1 To Len( aAux )
				aAdd( aCombo, aAux[nI][1] )
			Next nI
	
		EndIf
	
		bPictVar := IIf( Empty( SX3->X3_PICTVAR ), NIL , &( ' { | oModel, cID, xValue | ' + AllTrim( SX3->X3_PICTVAR ) + ' } ' ) )
	
		cGSC     := IIf( Empty( X3Cbox() ) , IIf( SX3->X3_TIPO == 'L', 'CHECK', 'GET' ) , 'COMBO' )
	
		If AllTrim(SX3->X3_CAMPO) $ "|LQ_CONDPG|LQ_SUBSERI|LQ_SERIE|"
	    	cPicture := '@!'
		Else
			cPicture := SX3->X3_PICTURE	
		EndIf	
		
		oStruct:AddField( ;
		AllTrim( SX3->X3_CAMPO  )   	, ;    	// [01] Campo
		SX3->X3_ORDEM               	, ;    	// [02] Ordem
		AllTrim( X3Titulo()  )       	, ;    	// [03] Titulo
		AllTrim( X3Descric() )       	, ;     // [04] Descricao
		NIL                          	, ;     // [05] Help
		'GET'                         	, ;    	// [06] Tipo do campo   COMBO, Get ou CHECK
		cPicture               			, ;    	// [07] Picture
		bPictVar                    	, ;     // [08] PictVar
		SX3->X3_F3                   	, ;    	// [09] F3
		SX3->X3_VISUAL <> 'V'   	 	, ;    	// [10] Editavel
		SX3->X3_FOLDER               	, ;    	// [11] Folder
		SX3->X3_FOLDER               	, ;    	// [12] Group
		aCombo                       	, ;    	// [13] Lista Combo
		nMaxLenCb                    	, ;    	// [14] Tam Max Combo
		SX3->X3_INIBRW               	, ;    	// [15] Inic. Browse
		.T.     )                				// [16] Virtual
	EndIf
Next nX

Return(oStruct)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FrtBVerda   � Autor � Vendas Cliente      � Data � 01/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Bloco que retorna verdadeiro                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FrtBVerda() 					                         	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � FRTA080 - MVC                                    		  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FrtBVerda()
Return(.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Frt80CrBVa  � Autor � Vendas Cliente      � Data � 01/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cria bloco de validacao                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Frt80CrBVa()					                         	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � LOJA701 													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Frt80CrBVa(cCampo)

Local cRet		// Retorno

	If cCampo == 'LQ_CLIENTE'
		cRet := 'EXISTCPO("SA1", FwFldGet("LQ_CLIENTE"))'
	ElseIf cCampo == 'LQ_CONDPG'
	     cRet := 'EXISTCPO("SE4", FwFldGet("LQ_CONDPG"))'
	ElseIf cCampo == 'LQ_VEND'
	     cRet := 'EXISTCPO("SA3", FwFldGet("LQ_VEND"))'
	ElseIf cCampo == 'LR_PRODUTO'
	     cRet := 'EXISTCPO("SB1", FwFldGet("LR_PRODUTO"))'
	Else
		cRet := 'FrtBVerda()' 	
	EndIF
	
Return cRet     
/*���������������������������������������������������������������������������
���Funcao    �Fr8ValfPro  � Autor � Vendas Cliente      � Data � 01/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Gatilho de produto                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fr8ValfPro()					                         	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � FRTA080 - MVC            								  ���
���������������������������������������������������������������������������*/
Function Fr8ValfPro()

Local cRet :=  '' 	// Retorno
                                     
If nModulo == 12 .Or. lTotvsPdv
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+M->LR_PRODUTO)
	cRet := SB1->B1_DESC
Else                    
	DbSelectArea("SBI")
	DbSetOrder(1)
	DbSeek(xFilial("SBI")+M->LR_PRODUTO)
	cRet := SBI->BI_DESC
EndIf

Return cRet

/*���������������������������������������������������������������������������
���Funcao    �Fr8Tes      � Autor � Vendas Cliente      � Data � 01/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Gatilho de produto                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fr8ValfPro()					                         	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � FRTA080 - MVC            								  ���
���������������������������������������������������������������������������*/
Function Fr8Tes()

Local cRet :=  ''  	// Retorno
                        
If nModulo == 12 .Or. lTotvsPdv
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+M->LR_PRODUTO)
	cRet := SB1->B1_TS
Else                    
	DbSelectArea("SBI")
	DbSetOrder(1)
	DbSeek(xFilial("SBI")+M->LR_PRODUTO)
	cRet := SBI->BI_TS
EndIf

Return cRet

/*���������������������������������������������������������������������������
���Funcao    �Fr8VaUn     � Autor � Vendas Cliente      � Data � 01/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Gatilho Unidade de produto                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fr8VaUn()					                         	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � FRTA080 - MVC  											  ���
���������������������������������������������������������������������������*/
Function Fr8VaUn()
Local cRet :=  ''
     
If nModulo == 12 .Or. lTotvsPdv
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+M->LR_PRODUTO)
	cRet := SB1->B1_UM
Else                    
	DbSelectArea("SBI")
	DbSetOrder(1)
	DbSeek(xFilial("SBI")+M->LR_PRODUTO)
	cRet := SBI->BI_UM
EndIf

Return cRet

/*���������������������������������������������������������������������������
���Funcao    �Fr8VaVl     � Autor � Vendas Cliente      � Data � 01/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Gatilho de Valida��o                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fr8VaVl()					                         	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � FRTA080 													  ���
���������������������������������������������������������������������������*/
Function Fr8VaVl()

Local cRet :=  ''	// Retorno

If nModulo == 12 .Or. lTotvsPdv
	DbSelectArea("SB0")
	DbSetOrder(1)
	DbSeek(xFilial("SB0")+M->LR_PRODUTO)
	cRet := SB0->B0_PRV1
Else                    
	DbSelectArea("SBI")
	DbSetOrder(1)
	DbSeek(xFilial("SBI")+M->LR_PRODUTO)
	cRet := SBI->BI_PRV1
EndIf

Return cRet

/*���������������������������������������������������������������������������
���Funcao    �Fr8VaQt     � Autor � Vendas Cliente      � Data � 01/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Gatilho de Valida��o                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fr8VaVl()					                         	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � FRTA080 													  ���
���������������������������������������������������������������������������*/
Function Fr8VaQt(x)

Local nRet :=  x:GetModel():GetValue( 'SLRDETAIL', 'LR_VRUNIT') // Valor de retorno

If X:GetModel():GetValue( 'SLRDETAIL', 'LR_QUANT') > 0
	nRet := (x:GetModel():GetValue( 'SLRDETAIL', 'LR_QUANT') * x:GetModel():GetValue( 'SLRDETAIL', 'LR_VRUNIT'))
EndIf

Return nRet

/*
�����������������������������������������������������������������������������
���Funcao    �Fr8VaVu     � Autor � Vendas Cliente      � Data � 01/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Gatilho de Valida��o                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fr8VaVl()					                         	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � FRTA080 													  ���
���������������������������������������������������������������������������*/
Function Fr8VaVu(x)

Local nRet :=  x:GetModel():GetValue( 'SLRDETAIL', 'LR_VRUNIT') // Valor de retorno

If x:GetModel():GetValue( 'SLRDETAIL', 'LR_QUANT') > 0
	nRet := (x:GetModel():GetValue( 'SLRDETAIL', 'LR_QUANT') * x:GetModel():GetValue( 'SLRDETAIL', 'LR_VRUNIT'))
EndIf

Return nRet

/*���������������������������������������������������������������������������
���Funcao    �Fr8VaVu     � Autor � Vendas Cliente      � Data � 01/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Gatilho de Valida��o                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fr8VaVl()					                         	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � FRTA080 													  ���
���������������������������������������������������������������������������*/
Function Frt80MvcGr(oModel)

Local nI         	:= 0						// Contador
Local nLin			:= 0						// Contador
Local aDadosTES		:= {} 						// Dados da TES
Local cProdu		:= ''						// Produto da venda		
Local nTot			:= oModel:GetModel( 'COMP022CALC1' ):GetValue( "LQTOTAL" ) 	// Total da venda
Local cTesSai		:= SuperGetMV("MV_TESSAI")

DbSelectArea("SL1")
DbSetOrder(1)

RecLock("SL1",.T.)

cNum := GetSxENum("SL1","L1_NUM")  

ConFirmSX8()

Replace L1_FILIAL		With  xFilial("SL1")
Replace L1_NUM			With  cNum
Replace L1_VEND			With  FwFldGet('LQ_VEND')'
Replace L1_CLIENTE		With  FwFldGet('LQ_CLIENTE')'
Replace L1_LOJA			With  FwFldGet('LQ_LOJA')'
Replace L1_DOC			With  FwFldGet('LQ_DOC')'
Replace L1_CONDPG		With  FwFldGet('LQ_CONDPG')'
Replace L1_SERIE		With  FwFldGet('LQ_SERIE')'

If SL1->( ColumnPos( "L1_SUBSERI") ) > 0
	Replace L1_SUBSERI	With  FwFldGet('LQ_SUBSERI')'
EndIf

Replace L1_TIPOCLI		With  Posicione("SA1",1,xFilial("SA1")+FwFldGet('LQ_CLIENTE')+FwFldGet('LQ_CLIENTE'),"A1_PESSOA")
Replace L1_VLRTOT		With  oModel:GetModel( 'COMP022CALC1' ):GetValue( "LQTOTAL" )
Replace L1_VLRLIQ		With  oModel:GetModel( 'COMP022CALC1' ):GetValue( "LQTOTAL" )
Replace L1_VALBRUT		With  oModel:GetModel( 'COMP022CALC1' ):GetValue( "LQTOTAL" )
Replace L1_VALMERC		With  oModel:GetModel( 'COMP022CALC1' ):GetValue( "LQTOTAL" )
Replace L1_DTLIM		With  dDataBase
Replace L1_EMISNF		With  dDataBase
Replace L1_EMISSAO		With  dDataBase
Replace L1_HORA			With  Left(Time(),5)
Replace L1_TIPO			With  "V"
Replace L1_OPERADO		With  xNumCaixa()
Replace L1_SITUA		With  "00"
Replace L1_ESTACAO		With  '001'
Replace L1_IMPRIME 		With  "2S"
Replace L1_DINHEIR		With  nTot
Replace L1_ESPECIE		With  "NFM" 

SL1->(MsUnlock())

oModelSLR := oModel:GetModel( 'SLRDETAIL' )

For nI := 1 To oModelSLR:GetQtdLine()


	oModelSLR:GoLine( nI )
	
	cProduto := FwFldGet( 'LR_PRODUTO' )
	aDadosTES	:= GetAdvFVal("SF4",{"F4_CF"},xFilial("SF4")+FwFldGet('LR_TES'),1,{""})

	
	If nModulo == 12 .Or. lTotvsPdv
		aDadosProd	:= GetAdvFVal("SB1",{"B1_LOCPAD"},xFilial("SB1")+cProduto,1,{""})	
	Else 
		aDadosProd	:= GetAdvFVal("SBI",{"BI_LOCPAD"},xFilial("SBI")+cProduto,1,{""})				
	EndIf
	
	RecLock("SL2",.T.)
	
	Replace L2_FILIAL	With   xFilial("SL2")
	Replace L2_NUM		With   cNum
	Replace L2_ITEM		With   FwFldGet('LR_ITEM')	
	Replace L2_PRODUTO	With   FwFldGet('LR_PRODUTO')		
	Replace L2_CF		With   aDadosTES[1]
	Replace L2_TES		With   cTesSai
	Replace L2_LOCAL	With   aDadosProd[1]
	Replace L2_VENDIDO	With   "S"
	Replace L2_VRUNIT	With   FwFldGet('LR_VRUNIT')	
	Replace L2_VLRITEM	With   FwFldGet('LR_VLRITEM')
	Replace L2_DOC		With   FwFldGet('LQ_NUM')
	Replace L2_SERIE	With   FwFldGet('LQ_SERIE')
	Replace L2_EMISSAO	With   dDataBase
	If SL2->( FieldPos( "L2_GRADE") ) > 0
		Replace L2_GRADE	With   "N"
	EndIf
	Replace L2_VEND		With   FwFldGet('LQ_VEND')
	If SL2->( FieldPos( "L2_MARCA") ) > 0
		Replace L2_MARCA	With   FwFldGet('LR_MARCA')
	EndIf
	If SL2->( FieldPos( "L2_TIPO") ) > 0
		Replace L2_TIPO		With   FwFldGet('LR_TIPO' )
	EndIf
	If SL2->( FieldPos( "L2_MODELO") ) > 0
		Replace L2_MODELO	With   FwFldGet('LR_MODELO' )
	EndIf
	If SL2->( FieldPos( "L2_ESPECIE") ) > 0
		Replace L2_ESPECIE	With   FwFldGet('LR_ESPECIE' )
	EndIf
	If SL2->( FieldPos( "L2_QUALIDA") ) > 0	
		Replace L2_QUALIDA	With   FwFldGet('LR_QUALIDA' )
	EndIf
	SL2->(MsUnlock())
	
Next nI


//����������Ŀ
//�Pagamentos�
//������������
aParcelas := Condicao( oModel:GetModel( 'COMP022CALC1' ):GetValue( "LQTOTAL" )	, FwFldGet('LQ_CONDPG')	, 0			, dDataBase	,;
		 			 	0			, Nil			, Nil		, 0			)

DbSelectArea("SE4")
DbSetOrder(1)
DbSeek(xFilial("SE4")+FwFldGet('LQ_CONDPG'))

//�������������������������������������������������������������������������Ŀ
//�Pega a Forma de Pagamento										        �
//���������������������������������������������������������������������������
If Empty(SE4->E4_FORMA)
	cForma1 := "CH"
Else
	cForma1 := SE4->E4_FORMA
EndIf   

If Empty(SE4->E4_FORMA)
	cForma2 := cForma1
Elseif Empty(SubStr(SE4->E4_FORMA,1,3))
	cForma2 := cForma1
Else
	cForma2 := SubStr(SE4->E4_FORMA,1,3)
Endif

//�����������������������������������������������������Ŀ
//� Grava informacoes do arquivo de forma de pagamento  �
//�������������������������������������������������������
If (Len(aParcelas) > 0)

	For nLin := 1 TO Len(aParcelas)

		If nLin == 1
			cForma3 := cForma1
		Else
			cForma3 := cForma2
		EndIf    
		
		If Empty(cForma3)
			cForma3 := "CH"
		EndIf
	
		Reclock("SL4",.T.)   
		
		Replace L4_NUM	   With cNum
		Replace L4_FILIAL  With xFilial("SL4")
		Replace L4_DATA    With aParcelas[nLin][1]
		Replace L4_VALOR   With aParcelas[nLin][2]
		Replace L4_FORMA   With cForma3
			
		SL4->(MsUnlock())                

	Next nLin
Endif

Return (.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Fr8Valj     � Autor � Vendas Cliente      � Data � 01/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Gatilho de Valida��o                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fr8Valj()					                         	  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � FRTA080 													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fr8Valj()

Local cRet :=  ''	// Retorno

cRet := SA1->A1_LOJA

Return(cRet)
