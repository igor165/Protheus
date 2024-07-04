#INCLUDE "TMSA990.CH"
#Include "PROTHEUS.CH"

#define nMarcado   1    //Flag marcado ou nao
#define nFiliNegoc 2    //Filial Negociacao - caso parametro mv_par09 ( tipo de filial seja origem nao haverá esta posicao)
#define nCliente   3    //Codigo do cliente
#define nLojaCli   4    //Loja do cliente
#define nNomeCliD  5    //Nome do cliente devedor
#define nVlFrete   6    //Valor do Frete
#define nQtdDoc    7    //Quantidade de documentos
#define nPesoR     8    //Peso real
#define nIniV      9   //inicio da vigencia do contrato
#define nDTpTransp 10   //descricao do tipo de transporte
#define nContrato  11   //numero do contrato do cliente
#define nCliDev    12   //codido do cliente devedor
#define nLojaDev   13   //loja do cliente devedor
#define nFilial    14   //filial
#define nVlMerc    15   //valor da mercadoria
#define nPCubado   16   //peso cubado
#define nPCobrado  17   //peso cobrado
#define nVolOrig   18   //volume original
#define nTpTransp  19   //tipo de transporte 
#define nTpFrete   20   //tipo de Frete 
#define nServico   21   //servico
#define nCodNeg    22   //codigo da negociacao

Static lTMA990GRV   := ExistBlock("TMA990GRV")
Static aCtrProc     := {}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA990   ³ Autor ³Wellington A Santos    ³ Data ³15/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Encerramento de contrato de clientes sem movimento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA990()

Local aSays		 := {}
Local aButtons	 := {}
Local nOpca     := 0
Local cCadastro := STR0004 //'Encerramento de contrato de cliente sem movimento'
Local cPerg     := "TMA990"

aCtrProc     := {}

Pergunte(cPerg,.F.)

Aadd( aSays, STR0001 ) //'Este programa tem como objetivo, verificar o movimento dos clientes de acordo com os'
Aadd( aSays, STR0002 ) //'parametros e se seu movimento de frete for abaixo do esperado será dada opurtunidade de'
Aadd( aSays, STR0003 ) //'encerrar seu contrato'

Aadd( aButtons, { 1, .T., {|o| Tma990Prc(cCadastro),  o:oWnd:End() } } )
Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )
Aadd( aButtons, { 5, .T., {|| Pergunte(cPerg,.T.) } } )

FormBatch( cCadastro, aSays, aButtons )

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tma990Prc ³ Autor ³Wellington A Santos    ³ Data ³15/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Processamento para selecionar contrato de clientes          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA990                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tma990prc(cCadastro)
Local cTitle     := STR0005 //Selecione os clientes que terao seus contratos encerrados
Local aObjects   := {}
Local aSize      := {}
Local aInfo      := {}
Local aPosObjsH  := {}
Local aButtons   := {}
Local nOpca      := 0
Private aHContrt := {}
Private aContrt  := {}
Private oDlgEsp
Private oLbx1
Private oLbxDocto
Private oNoMarked := LoadBitmap( GetResources(),'LBNO')
Private oMarked   := LoadBitmap( GetResources(),'LBOK')

Aadd(aHContrt,' ' )
If mv_par09 == 3
	Aadd(aHContrt,GetSX3Cache('DT6_FILNEG', "X3_Titulo"))
EndIf
Aadd(aHContrt,GetSX3Cache('AAM_CODCLI', "X3_Titulo"))
Aadd(aHContrt,GetSX3Cache('AAM_LOJA'  , "X3_Titulo"))
Aadd(aHContrt,GetSX3Cache('AAM_NOMCLI', "X3_Titulo"))
Aadd(aHContrt,GetSX3Cache('DT6_TIPFRE', "X3_Titulo"))
Aadd(aHContrt,STR0010)//Qtd Documentos
Aadd(aHContrt,STR0009)//Faturamento 
Aadd(aHContrt,GetSX3Cache('DT6_PESO'  , "X3_Titulo"))
Aadd(aHContrt,GetSX3Cache('AAM_INIVIG', "X3_Titulo"))
Aadd(aHContrt,GetSX3Cache('DT6_TIPTRA', "X3_Titulo"))
Aadd(aHContrt,GetSX3Cache('DDA_CODNEG', "X3_Titulo"))
Aadd(aHContrt,GetSX3Cache('DT6_SERVIC', "X3_Titulo"))

Aadd(aButtons, {'EDIT'     ,{||TmsA990bt1()}, STR0005 , STR0006 }) //"Contrato do Cliente"
Aadd(aButtons, {'RELATORIO',{||TmsA990bt2()}, STR0007 , STR0008 }) //"Impressao"
Aadd(aButtons, {'PESQUISA' ,{||TmsA990Psq()}, STR0013 })		//'Pesquisa'
	
Processa({||	aContrt := tmsa990Qry('1'),cCadastro})

If Empty(aContrt)
	Help(' ', 1, 'TMSA99001' )	//-- Não foram encontrados registros para processar !
	Return Nil
EndIf

//-- Calcula as dimensoes dos objetos
aSize  := MsAdvSize( .T. )

aObjects	:= {}
AAdd(aObjects,{100,80,.T.,.T.,.T.})							//-- Horizontal superior
aInfo	   := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
aPosObjH	:= MsObjSize(aInfo,aObjects,.T.,.F.)

DEFINE MSDIALOG oDlgEsp FROM aSize[7],00 TO aSize[6],aSize[5] TITLE cTitle OF oMainWnd PIXEL
	//-- Apresenta as rotas da viagem
	If mv_par09 <> 3
		@ aPosObjH[1,1], aPosObjH[1,2] LISTBOX oLbx1 VAR cLbx1 FIELDS HEADER aHContrt[1],aHContrt[2],aHContrt[3],aHContrt[4],aHContrt[5],;
		aHContrt[6],aHContrt[7],aHContrt[8],aHContrt[9],aHContrt[10],aHContrt[11],aHContrt[12]  SIZE aPosObjH[1,3], aPosObjH[1,4] OF oDlgEsp ON DBLCLICK (TmsA990Mrk()) PIXEL
		
	Else
		@ aPosObjH[1,1], aPosObjH[1,2] LISTBOX oLbx1 VAR cLbx1 FIELDS HEADER aHContrt[1],aHContrt[2],aHContrt[3],aHContrt[4],aHContrt[5],;
		aHContrt[6],aHContrt[7],aHContrt[8],aHContrt[9],aHContrt[10],aHContrt[11],aHContrt[12],aHContrt[13]  SIZE aPosObjH[1,3], aPosObjH[1,4] OF oDlgEsp ON DBLCLICK (TmsA990Mrk()) PIXEL	

	EndIf
	oLbx1:SetArray( aContrt )
	//-- Monta o bLine do listbox
	TmsA990bLi( 1 )
ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||oDlgEsp:cCaption := cCadastro, oDlgEsp:Refresh(),nOpca := 1,oDlgEsp:End() },{|| oDlgEsp:cCaption := cCadastro, oDlgEsp:Refresh(), nOpca == 0, oDlgEsp:End()},, aButtons )
If	nOpca == 1
	Processa({||	tmsa990Grv(),STR0011})
EndIf


Return Nil

 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA990bLi³ Autor ³Wellington A Santos    ³ Data ³15.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o bLine dos objetos listbox                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Tmsa990                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA990bLi(  )
dbSelectArea("DTC")
If mv_par09 <> 3
	oLbx1:bLine	:= { || { Iif(aContrt[oLbx1:nAT,nMarcado] , oMarked, oNoMarked ),;
									Transform(aContrt[oLbx1:nAT,nCliente],PesqPict('SA1','A1_COD'))  ,;
									Transform(aContrt[oLbx1:nAT,nLojaCli],PesqPict('SA1','A1_LOJA'))  ,;
									Transform(aContrt[oLbx1:nAT,nNomeCliD],PesqPict('SA1','A1_NREDUZ'))  ,;
									Transform(aContrt[oLbx1:nAT,nTpFrete],PesqPict('DT6','DT6_TIPFRE'))  ,;
									Transform(aContrt[oLbx1:nAT,nVlFrete],PesqPict('DT6','DT6_VALFRE'))  ,;
									Transform(aContrt[oLbx1:nAT,nVolOrig],PesqPictQt('DTC_QTDVOL'))     ,;
									Transform(aContrt[oLbx1:nAT,nPesoR],PesqPict('DT6','DT6_PESO'))  ,;
									Transform(aContrt[oLbx1:nAT,nIniV],PesqPict('AAM','AAM_INIVIG' )) ,;
									Transform(aContrt[oLbx1:nAT,nDTpTransp],PesqPict('DT6','DT6_TIPTRA')) ,;
									Transform(aContrt[oLbx1:nAT,nCodNeg],PesqPict('DDA','DDA_CODNEG')) ,;
									Transform(aContrt[oLbx1:nAT,nServico],PesqPict('DT6','DT6_SERVIC')) } }
Else
	oLbx1:bLine	:= { || { Iif(aContrt[oLbx1:nAT,nMarcado] , oMarked, oNoMarked ),;
									Transform(aContrt[oLbx1:nAT,nFiliNegoc],PesqPict('DT6','DT6_FILNEG'))  ,;
									Transform(aContrt[oLbx1:nAT,nCliente],PesqPict('SA1','A1_COD'))  ,;
									Transform(aContrt[oLbx1:nAT,nLojaCli],PesqPict('SA1','A1_LOJA'))  ,;
									Transform(aContrt[oLbx1:nAT,nNomeCliD],PesqPict('SA1','A1_NREDUZ'))  ,;
									Transform(aContrt[oLbx1:nAT,nTpFrete],PesqPict('DT6','DT6_TIPFRE'))  ,;
									Transform(aContrt[oLbx1:nAT,nVlFrete],PesqPict('DT6','DT6_VALFRE'))  ,;
									Transform(aContrt[oLbx1:nAT,nVolOrig],PesqPictQt('DTC_QTDVOL'))     ,;
									Transform(aContrt[oLbx1:nAT,nPesoR],PesqPict('DT6','DT6_PESO'))  ,;
									Transform(aContrt[oLbx1:nAT,nIniV],PesqPict('AAM','AAM_INIVIG' )) ,;
									Transform(aContrt[oLbx1:nAT,nDTpTransp],PesqPict('DT6','DT6_TIPTRA')) ,;
									Transform(aContrt[oLbx1:nAT,nCodNeg],PesqPict('DDA','DDA_CODNEG')) ,;
		   							Transform(aContrt[oLbx1:nAT,nServico],PesqPict('DT6','DT6_SERVIC')) } }
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA990Grv³ Autor ³Wellington A Santos    ³ Data ³15.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Concretiza o encerramento dos contratos selecionados        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Tmsa990                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA990Grv()
Local nCount   := 0
Local nCount0  := 0
Local cContrat := ''
Local cCodCli  := ''
Local cLojCli  := ''
Local cTipTra  := ''
Local cAliasQry:= CriaTrab(NIL,.F.)
Local cQuery   := ''

For nCount := 1 To Len(aContrt)
	If aContrt[nCount,nMarcado] .And. !Empty(aContrt[nCount,nContrato]) .And. !Empty(aContrt[nCount,nTpTransp])
		cContrat := aContrt[nCount,nContrato]
		cCodCli  := aContrt[nCount,nCliente]
		cLojCli  := aContrt[nCount,nLojaCli]
		cTipTra  := aContrt[nCount,nTpTransp]
		cQuery := "SELECT SA11.A1_NREDUZ NOMEPAI ,SA12.A1_NREDUZ NOMEFILHO,AAM1.AAM_CONTRT CTRPAI ,AAM2.AAM_CONTRT CTRFILHO,AAM2.AAM_CODCLI CODFILHO, "
		cQuery += " AAM2.AAM_LOJA LOJAFILHO, AAM1.AAM_CODCLI CODPAI, AAM1.AAM_LOJA LOJAPAI "
		cQuery += " FROM " + RetSqlName("AAM") + " AAM1 "
		cQuery += " JOIN " + RetSqlName("SA1") + " SA11 "
		cQuery += " ON SA11.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery += " AND SA11.A1_COD   = AAM1.AAM_CODCLI "
		cQuery += " AND SA11.A1_LOJA  = AAM1.AAM_LOJA   "
		cQuery += " AND SA11.D_E_L_E_T_ = ' '  "
		cQuery += " JOIN " + RetSqlName("DE4") + " DE4 "
		cQuery += " ON DE4_FILIAL = '" + xFilial("DE4") + "' "
		cQuery += " AND DE4_CNPJ  = A1_CGC "
		cQuery += " AND DE4.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN " + RetSqlName("SA1") + " SA12 "
		cQuery += " ON SA12.A1_FILIAL    = '" + xFilial("SA1") + "' "
		cQuery += " AND SA12.A1_CGC = DE4_CNPJ1 "
		cQuery += " AND SA12.D_E_L_E_T_ = ' '  "
		cQuery += " JOIN " + RetSqlName("AAM") + " AAM2 "
		cQuery += " ON AAM2.AAM_FILIAL  = '" + xFilial("AAM") + "' "
		cQuery += " AND AAM2.AAM_CODCLI = SA12.A1_COD "
		cQuery += " AND AAM2.AAM_LOJA   = SA12.A1_LOJA "
		If mv_par04 <> 3
			cQuery += " AND ( AAM2.AAM_TIPFRE = '" + StrZero(mv_par04,Len(AAM->AAM_TIPFRE)) + "' OR AAM2.AAM_TIPFRE = '" + StrZero(3,Len(AAM->AAM_TIPFRE)) + "') " 
		EndIf
		cQuery += " AND AAM2.AAM_STATUS = '" + StrZero(1,Len(AAM->AAM_STATUS)) + "' "
		cQuery += " AND ( AAM2.AAM_FIMVIG = '       ' OR AAM2.AAM_FIMVIG >= '" + Dtos(dDataBase) + "') " 
		cQuery += " AND AAM2.D_E_L_E_T_ = ' ' " 
		cQuery += " WHERE AAM1.AAM_FILIAL = '" + xFilial("AAM") + "' "
		cQuery += " AND AAM1.AAM_CODCLI = '" + cCodCli + "' "
		cQuery += " AND AAM1.AAM_LOJA   = '" + cLojCli + "' "
		cQuery += " AND AAM1.D_E_L_E_T_ = ' ' " 
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
		If (cAliasQry)->( !Eof() )
			Begin Transaction
			While (cAliasQry)->( !Eof() )
				cContrat := (cAliasQry)->CTRFILHO
				cCtrPai  := (cAliasQry)->CTRPAI
				TMA990Ctr(cContrat,cTipTra)
   			(cAliasQry)->( dbSkip() )
			EndDo
			TMA990Ctr(cCtrPai,cTipTra)
			End Transaction
		Else
			Begin Transaction
			TMA990Ctr(cContrat,cTipTra)
			End Transaction
		EndIf
		(cAliasQry)->( dbCloseArea() )
	EndIf
Next nCount

TMSR550(.T.,aContrt)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA990Qry³ Autor ³Wellington A Santos    ³ Data ³15.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Faz a query para a tela e o relatorio                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Tmsa990,tmsr550                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function tmsa990Qry(cTipo)
Local cCliGen   := Substr(GetMv("MV_CLIGEN"),1,Len(SA1->A1_COD))
Local cLojGen   := Substr(GetMv("MV_CLIGEN"),Len(SA1->A1_COD)+ 1,Len(SA1->A1_LOJA))
Local cQuery    := ''
Local cAliasQry := CriaTrab(NIL,.F.)
Local aRet      := {}
Local cTipTra   := ''
Local nDel      := 0
Local nCount    := 0
Local nPosCli   := 0
Local cAliasNeg := CriaTrab(NIL,.F.)
Local cFilNeg   := ''

cQuery += " SELECT (SELECT Min(A1_NREDUZ) FROM " + RetSqlName("SA1") 
cQuery += "				WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
cQuery += "             AND A1_COD  = AAM_CODCLI "
cQuery += "             AND A1_LOJA = AAM_LOJA "
cQuery += "             AND D_E_L_E_T_ = ' ') NOMCLIDEV , "
cQuery += " AAM_TIPFRE TIPFRE, AAM_INIVIG INIVIG , AAM_CONTRT CONTRT, "
cQuery += " AAM_CODCLI ,AAM_LOJA , "
cQuery += " DT6_VALFRE VAL_FRE, QTD_DOC, DC5_TIPTRA TIPTRA, "     
cQuery += " DT6_PESO PESO,DT6_CLIDEV CLIDEV,DT6_LOJDEV LOJDEV, "
If mv_par09 <> 3 //tipo de filial que sera filtrada
	cQuery += " CASE "
	cQuery += "      WHEN FILIAL IS NULL THEN "
	cQuery += "  			(SELECT MIN(DUY_FILDES) FROM " + RetSqlName("DUY") + " DUY, "
	cQuery +=            RetSqlName("SA1") + " SA1 "
	cQuery +=            " WHERE DUY_FILIAL = '" + xFilial("DUY") + "' "   
	cQuery +=            " AND A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery +=            " AND DUY_GRPVEN = A1_CDRDES "
	cQuery +=            " AND A1_COD = AAM_CODCLI "
	cQuery +=            " AND A1_LOJA = AAM_LOJA "
	cQuery +=            " AND DUY.D_E_L_E_T_ = ' ' "
	cQuery +=            " AND SA1.D_E_L_E_T_ = ' ' ) "
	cQuery += "      ELSE "
	cQuery += "         FILIAL "
	cQuery += "      END "      
EndIf	
cQuery += " FILIAL, "
cQuery += " DT6_PESOM3 PESOM3, DT6_PESCOB PESCOB,DT6_VALMER VALMER , DT6_VOLORI VOLORI,"
cQuery += " DDA_SERVIC SERVIC, DDA_CODNEG CODNEG "

cQuery += " FROM " + RetSqlName("AAM") + " AAM "
cQuery += " JOIN " + RetSqlName("DDA") + " DDA "
cQuery += "   ON DDA_FILIAL     = '" + xFilial("DDA") + "' "
cQuery += "  AND DDA_NCONTR     = AAM_CONTRT "
cQuery += "  AND DDA.D_E_L_E_T_ = ' ' "

cQuery += " LEFT JOIN (
cQuery += " SELECT 
cQuery += " Sum(DT6_VALFRE) DT6_VALFRE,Count(*) QTD_DOC, "
cQuery += " Sum(DT6_PESO) DT6_PESO "
If cTipo == "1"
	If mv_par09 == 1// tipo de filial
		cQuery += ", Max(DT6_FILORI) FILIAL "
	ElseIf mv_par09 == 2
		cQuery += ", Max(DT6_FILDES) FILIAL "
	ElseIf mv_par09 == 3
		cQuery += ", Max(DT6_FILNEG) FILIAL "
	EndIf
Else
	If mv_par09 == 1// tipo de filial
		cQuery += ", DT6_FILORI FILIAL"
	ElseIf mv_par09 == 2
		cQuery += ", DT6_FILDES FILIAL"
	ElseIf mv_par09 == 3
		cQuery += ", DT6_FILNEG FILIAL"
	EndIf
EndIf
cQuery += ",Sum(DT6_PESOM3) DT6_PESOM3, Sum(DT6_PESCOB) DT6_PESCOB,Sum(DT6_VALMER) DT6_VALMER , Sum(DT6_VOLORI) DT6_VOLORI"
cQuery += ",Max(DT6_NCONTR) DT6_NCONTR, DT6_SERVIC "
cQuery += ",DT6_CODNEG "
cQuery += ",DT6_CLIDEV,DT6_LOJDEV,DT6_TIPTRA "
cQuery += " FROM " + RetSqlName("DT6") + " DT6 "
cQuery += " WHERE DT6_FILIAL   = '" + xFilial("DT6") + "' " 
If mv_par05 == mv_par06//de ate do tipo de transporte
	cQuery += " AND DT6_TIPTRA = '" + mv_par05 + "' " 
Else
	cQuery += " AND DT6_TIPTRA BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
EndIf
If mv_par07 == mv_par08
	If mv_par09 == 1//tipo de filial que sera filtrada
		cQuery += " AND DT6_FILORI = '" + mv_par07 + "' " 
	ElseIf mv_par09 == 2
		cQuery += " AND DT6_FILDES = '" + mv_par07 + "' " 	
	ElseIf mv_par09 == 3
		cQuery += " AND DT6_FILNEG = '" + mv_par07 + "' "
	EndIf
ElseIf mv_par07 <> '  ' .And. UPPER(mv_par08) <> 'ZZ'
	If mv_par09 == 1//tipo de filial que sera filtrada
		cQuery += " AND DT6_FILORI BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' "
	ElseIf mv_par09 == 2
		cQuery += " AND DT6_FILDES BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' "	
	ElseIf mv_par09 == 3
		cQuery += " AND DT6_FILNEG BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' "
	EndIf
EndIf
cQuery += " AND DT6_DATEMI BETWEEN '" + Dtos(mv_par01) + "' AND '" + Dtos(mv_par02) + "' "
cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
cQuery += " AND DT6_DOCTMS NOT IN ('A','1') " //ctrcs diferentes de cortesia e coleta
cQuery += " AND DT6_SERIE  NOT IN ('PED') " //ctrcs diferentes de pedidos bloqueados

If mv_par11 == 1//se usa agrupamento de clientes
	cQuery += " AND NOT EXISTS( SELECT '1' FROM " + RetSqlName("SA1") + " SA1 "
	cQuery += "                            JOIN " + RetSqlName("DE4") + " DE4 "
	cQuery += "                            ON DE4_FILIAL = '" + xFilial("DE4") + "' "
	cQuery += "                            AND DE4_CNPJ1 = A1_CGC "
	cQuery += "                            AND DE4.D_E_L_E_T_ = ' ' "
	cQuery += " 									WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery += "                            AND A1_COD    = DT6_CLIDEV "
	cQuery += "                            AND A1_LOJA   = DT6_LOJDEV "
	cQuery += "                            AND SA1.D_E_L_E_T_ = ' ' )"

	If cTipo == '1'//query para tela ou  relatorio
		cQuery += " GROUP BY DT6_CODNEG,DT6_SERVIC,DT6_CLIDEV,DT6_LOJDEV,DT6_TIPTRA "
	Else
		If mv_par09 == 1// tipo de filial
			cQuery += " GROUP BY DT6_FILORI,DT6_CLIDEV,DT6_LOJDEV,DT6_TIPTRA,DT6_SERVIC,DT6_CODNEG "
		ElseIf mv_par09 == 2
			cQuery += " GROUP BY DT6_FILDES,DT6_CLIDEV,DT6_LOJDEV,DT6_TIPTRA,DT6_SERVIC,DT6_CODNEG "		
		ElseIf mv_par09 == 3
			cQuery += " GROUP BY DT6_FILNEG,DT6_CLIDEV,DT6_LOJDEV,DT6_TIPTRA,DT6_SERVIC,DT6_CODNEG "		
		EndIf
	EndIf

	cQuery += " UNION ALL "

	cQuery += " SELECT  "
	cQuery += " Sum(DT6_VALFRE) ,Count(*) , "
	cQuery += " Sum(DT6_PESO) "
	If cTipo == "1"
		If mv_par09 == 1// tipo de filial
			cQuery += ", Max(DT6_FILORI) FILIAL "
		ElseIf mv_par09 == 2
			cQuery += ", Max(DT6_FILDES) FILIAL "
		ElseIf mv_par09 == 3
			cQuery += ", Max(DT6_FILNEG) FILIAL "
		EndIf
	Else
		If mv_par09 == 1// tipo de filial
			cQuery += ", DT6_FILORI FILIAL"
		ElseIf mv_par09 == 2
			cQuery += ", DT6_FILDES FILIAL"
		ElseIf mv_par09 == 3
			cQuery += ", DT6_FILNEG FILIAL"
		EndIf
	EndIf
	cQuery += ",Sum(DT6_PESOM3) , Sum(DT6_PESCOB) ,Sum(DT6_VALMER) , Sum(DT6_VOLORI) "
	cQuery += ",Max(DT6_NCONTR) ,Max(DT6_CLIDEV) , Max(DT6_LOJDEV), DT6_SERVIC, DT6_TIPTRA "
	cQuery += ",DT6_CODNEG "
	cQuery += " FROM " + RetSqlName("DT6") + " DT6 "
	cQuery += " JOIN " + RetSqlName("SA1") + " SA11 "
	cQuery += " ON SA11.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery += " AND SA11.A1_COD   = DT6_CLIDEV "
	cQuery += " AND SA11.A1_LOJA  = DT6_LOJDEV "
	cQuery += " AND SA11.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN " + RetSqlName("DE4") + " DE4 "
	cQuery += " ON DE4_FILIAL = '" + xFilial("DE4") + "' "
	cQuery += " AND DE4_CNPJ1 = SA11.A1_CGC "
	cQuery += " AND DE4.D_E_L_E_T_ = ' ' "
	cQuery += " JOIN " + RetSqlName("SA1") + " SA12 "
	cQuery += " ON SA12.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery += " AND SA12.A1_CGC = DE4_CNPJ "
	cQuery += " AND SA12.D_E_L_E_T_ = ' '	"

	cQuery += " WHERE DT6_FILIAL  = '" + xFilial("DT6") + "' " 
	If mv_par05 == mv_par06//de ate do tipo de transporte
		cQuery += " AND DT6_TIPTRA = '" + mv_par05 + "' " 
	Else
		cQuery += " AND DT6_TIPTRA BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
	EndIf                                                     	
	If mv_par07 == mv_par08
		If mv_par09 == 1//tipo de filial que sera filtrada
			cQuery += " AND DT6_FILORI = '" + mv_par07 + "' " 
		ElseIf mv_par09 == 2
			cQuery += " AND DT6_FILDES = '" + mv_par07 + "' " 		
		ElseIf mv_par09 == 3
			cQuery += " AND DT6_FILNEG = '" + mv_par07 + "' "
		EndIf
	ElseIf mv_par07 <> '  ' .And. UPPER(mv_par08) <> 'ZZ'
		If mv_par09 == 1//tipo de filial que sera filtrada
			cQuery += " AND DT6_FILORI BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' "
		Else
			cQuery += " AND DT6_FILNEG BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' "
		EndIf
	EndIf
	cQuery += " AND DT6_DATEMI BETWEEN '" + Dtos(mv_par01) + "' AND '" + Dtos(mv_par02) + "' "
	cQuery += " AND DT6_DOCTMS NOT IN ('A','1') " //ctrcs diferentes de cortesia e coleta      
	cQuery += " AND DT6_SERIE  NOT IN ('PED') " //ctrcs diferentes de pedidos bloqueados
	cQuery += " AND DT6.D_E_L_E_T_ = ' ' "	

	If cTipo == '1'//query para tela ou  relatorio
		cQuery += " GROUP BY SA12.A1_COD,SA12.A1_LOJA,DT6_CODNEG,DT6_SERVIC,DT6_TIPTRA "
	Else
		If mv_par09 == 1// tipo de filial
			cQuery += " GROUP BY DT6_FILORI,SA12.A1_COD,SA12.A1_LOJA,DT6_TIPTRA,DT6_SERVIC,DT6_CODNEG "//
		ElseIf mv_par09 == 2
			cQuery += " GROUP BY DT6_FILDES,SA12.A1_COD,SA12.A1_LOJA,DT6_TIPTRA,DT6_SERVIC,DT6_CODNEG "
		ElseIf mv_par09 == 3
			cQuery += " GROUP BY DT6_FILNEG,SA12.A1_COD,SA12.A1_LOJA,DT6_TIPTRA,DT6_SERVIC,DT6_CODNEG "
		EndIf
	EndIf
                    
Else
	If cTipo == '1'//query para tela ou  relatorio
		cQuery += " GROUP BY DT6_CLIDEV,DT6_LOJDEV,DT6_CODNEG,DT6_SERVIC,DT6_TIPTRA "
	Else
		If mv_par09 == 1// tipo de filial
			cQuery += " GROUP BY DT6_FILORI,DT6_CLIDEV,DT6_LOJDEV,DT6_TIPTRA,DT6_SERVIC,DT6_CODNEG "
		ElseIf mv_par09 == 2
			cQuery += " GROUP BY DT6_FILDES,DT6_CLIDEV,DT6_LOJDEV,DT6_TIPTRA,DT6_SERVIC,DT6_CODNEG "		
		ElseIf mv_par09 == 3
			cQuery += " GROUP BY DT6_FILNEG,DT6_CLIDEV,DT6_LOJDEV,DT6_TIPTRA,DT6_SERVIC,DT6_CODNEG "		
		EndIf
	EndIf

EndIf

cQuery += " ) DT6  "

cQuery += " ON DT6_NCONTR  = DDA_NCONTR "
cQuery += " AND DT6_SERVIC  = DDA_SERVIC "
cQuery += " AND DT6_CODNEG  = DDA_CODNEG "

cQuery += " JOIN " + RetSqlName("Dc5") + " DC5 " 
cQuery += " ON DC5_SERVIC = DDA_SERVIC "
cQuery += " AND DC5.D_E_L_E_T_ = ' ' "

cQuery += " WHERE AAM_FILIAL  = '" + xFilial("AAM") + "' "
cQuery += " AND (DT6_VALFRE IS NULL OR DT6_VALFRE <= " + Str(mv_par03) +" )"
cQuery += " AND AAM_INIVIG <= '" + Dtos(dDatabase) + "' "
If mv_par04 <> 3
	cQuery += " AND ( AAM_TIPFRE = '" + StrZero(mv_par04,Len(AAM->AAM_TIPFRE)) + "' OR AAM_TIPFRE = '" + StrZero(3,Len(AAM->AAM_TIPFRE)) + "') " 
EndIf
cQuery += " AND AAM_STATUS = '" + StrZero(1,Len(AAM->AAM_STATUS)) + "' "
cQuery += " AND ( AAM_FIMVIG = '       ' OR AAM_FIMVIG >= '" + Dtos(dDataBase) + "') " 
cQuery += " AND AAM.D_E_L_E_T_ = ' '  "
cQuery += " ORDER BY NOMCLIDEV "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
TCSetField(cAliasQry,"INIVIG" ,"D",TamSx3("DT6_DATEMI")[1],TamSx3("DT6_DATEMI")[2])
TCSetField(cAliasQry,"VAL_FRE","N",TamSx3("DT6_VALFRE")[1],TamSx3("DT6_VALFRE")[2])
TCSetField(cAliasQry,"PESO"   ,"N",TamSx3("DT6_PESO")[1]  ,TamSx3("DT6_PESO")[2])
TCSetField(cAliasQry,"PESOM3" ,"N",TamSx3("DT6_PESOM3")[1],TamSx3("DT6_PESOM3")[2])
TCSetField(cAliasQry,"PESCOB" ,"N",TamSx3("DT6_PESCOB")[1],TamSx3("DT6_PESCOB")[2])

/*
Formato do array contrt
aContrt[,1] = Flag marcado ou nao
aContrt[,2] = Filial Negociacao // caso parametro mv_par09 ( tipo de filial seja origem esta posicao ficara em branco)
aContrt[,3] = Codigo do cliente
aContrt[,4] = Loja do cliente
aContrt[,5] = Nome do cliente devedor
aContrt[,6] = Valor total
aContrt[,7] = Quantidade de documentos
aContrt[,8] = Peso real
aContrt[,9] = inicio da vigencia do contrato
aContrt[,10] = descricao do tipo de transporte
aContrt[,11] = numero do contrato do cliente
aContrt[,12] = codido do cliente devedor
aContrt[,13]= loja do cliente devedor
aContrt[,14]= filial
aContrt[,15]= valor da mercadoria
aContrt[,16]= peso cubado
aContrt[,17]= peso cobrado
aContrt[,18]= volume original
aContrt[,19]= tipo de transporte 
aContrt[,20]= tipo de frete
aContrt[,21]= servico
aContrt[,22]= codigo da negociacao
*/

While (cAliasQry)->( !Eof() )
	If cCliGen == (cAliasQry)->AAM_CODCLI .And. cLojGen == (cAliasQry)->AAM_LOJA
		(cAliasQry)->( dbSkip() )
		Loop
	EndIf
	cTipTra := TmsValField(cAliasQry+"->TIPTRA",.F.,"DT6_DESTPT")
	cFilNeg := (cAliasQry)->FILIAL
	If Alltrim(cFilNeg) <> ''
		If mv_par07 == mv_par08
			If cFilNeg <>  mv_par07
				(cAliasQry)->( dbSkip() )
				Loop
			EndIf
		ElseIf mv_par07 <> '  ' .And. UPPER(mv_par08) <> 'ZZ'
			If !(cFilNeg >= mv_par07 .And. cFilNeg <= mv_par08)
				(cAliasQry)->( dbSkip() )
				Loop
			EndIf
		EndIf
	EndIf
		
	If mv_par10 == 1//se agrupa cnpj
		If cTipo == '1'
			nPosCli := Ascan(aRet,{|x| x[12]+x[13] == (cAliasQry)->AAM_CODCLI+(cAliasQry)->AAM_LOJA})
			If nPosCli > 0	
				aRet[nPosCli,nVlFrete]  += (cAliasQry)->VAL_FRE
				aRet[nPosCli,nQtdDoc]  += (cAliasQry)->QTD_DOC
				aRet[nPosCli,nPesoR]  += (cAliasQry)->PESO
				aRet[nPosCli,nPCubado] += (cAliasQry)->PESOM3
				aRet[nPosCli,nPCobrado] += (cAliasQry)->PESCOB
				aRet[nPosCli,nVolOrig] += (cAliasQry)->VOLORI
			EndIf			
		EndIf
	EndIf
	If cTipo == '1' .And. mv_par09 == 3
      //-- Tratamento para Filial de Negociacao
	   cFilNeg := (cAliasQry)->FILIAL
		If Alltrim(cFilNeg) = '' 		     
			cQuery := " SELECT DW3_FILNEG, DUY_FILDES  "
			cQuery += " 	FROM  "+ RetSqlName("DUY") +" DUY JOIN  "+ RetSqlName("SA1") +" SA1 ON A1_FILIAL = '"+xFilial("SA1")+"'" 
			cQuery += " 	 AND A1_COD = '"+(cAliasQry)->AAM_CODCLI+"'"
			cQuery += " 	 AND A1_LOJA = '"+(cAliasQry)->AAM_LOJA+"'"
			cQuery += " 	 AND SA1.D_E_L_E_T_ = ' ' LEFT JOIN "+ RetSqlName("DW3") +" DW3 ON DW3_FILIAL = '"+xFilial("DW3")+"'" 
			cQuery += " 	 AND DW3_CODCLI = A1_COD"
			cQuery += " 	 AND DW3_LOJCLI = A1_LOJA"
			cQuery += " 	 AND DW3.D_E_L_E_T_ = ' '"
			cQuery += " 	WHERE DUY_FILIAL = '"+xFilial("DUY")+"'"
			cQuery += " 	 AND DUY_GRPVEN = A1_CDRDES"
			cQuery += " 	 AND DUY.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNeg,.T.,.T.)
			If (cAliasNeg)->( !Eof() )
				cFilNeg := IIf(Trim((cAliasNeg)->DW3_FILNEG) <> '',(cAliasNeg)->DW3_FILNEG,(cAliasNeg)->DUY_FILDES)						
			EndIf	    
			(cAliasNeg)->(DbCloseArea())			
			If mv_par07 == mv_par08
				If cFilNeg <>  mv_par07
					(cAliasQry)->( dbSkip() )
					Loop
				EndIf
			ElseIf mv_par07 <> '  ' .And. UPPER(mv_par08) <> 'ZZ'
				If !(cFilNeg >= mv_par07 .And. cFilNeg <= mv_par08)
					(cAliasQry)->( dbSkip() )
					Loop
				EndIf
			EndIf			
		EndIf
	
		Aadd(aRet,{ .F. ,;        //1
		 cFilNeg   ,; 					//2
		 (cAliasQry)->AAM_CODCLI,; //3
		 (cAliasQry)->AAM_LOJA ,; //4
       (cAliasQry)->NOMCLIDEV ,; //5
		 (cAliasQry)->VAL_FRE  ,; //6
		 (cAliasQry)->QTD_DOC  ,; //7				
		 (cAliasQry)->PESO     ,; //8
		 (cAliasQry)->INIVIG   ,; //9 
		 cTipTra                ,; //10
		 (cAliasQry)->CONTRT   ,; //11
		 (cAliasQry)->CLIDEV   ,; //12
		 (cAliasQry)->LOJDEV   ,; //13
		 (cAliasQry)->FILIAL   ,; //14
		 (cAliasQry)->VALMER   ,; //15
		 (cAliasQry)->PESOM3   ,; //16
		 (cAliasQry)->PESCOB   ,; //17
		 (cAliasQry)->VOLORI   ,; //18
		 (cAliasQry)->TIPTRA   ,; //19
		 (cAliasQry)->TIPFRE   ,; //20
		 (cAliasQry)->SERVIC   ,; //21
		 (cAliasQry)->CODNEG   }) //22
		 
	ElseIf cTipo == '1'
		Aadd(aRet,{ .F. ,;        //1
		 "",;                      //2
		 (cAliasQry)->AAM_CODCLI,; //3
		 (cAliasQry)->AAM_LOJA  ,; //4
       (cAliasQry)->NOMCLIDEV ,; //5
		 (cAliasQry)->VAL_FRE  ,; //6
		 (cAliasQry)->QTD_DOC  ,; //7 
		 (cAliasQry)->PESO     ,; //8
		 (cAliasQry)->INIVIG   ,; //9 
		 cTipTra                ,; //10
		 (cAliasQry)->CONTRT   ,; //11
		 (cAliasQry)->CLIDEV   ,; //12
		 (cAliasQry)->LOJDEV   ,; //13
		 (cAliasQry)->FILIAL   ,; //14
		 (cAliasQry)->VALMER   ,; //15
		 (cAliasQry)->PESOM3   ,; //16
		 (cAliasQry)->PESCOB   ,; //17
		 (cAliasQry)->VOLORI   ,; //18
		 (cAliasQry)->TIPTRA   ,; //19
		 (cAliasQry)->TIPFRE   ,; //20
 		 (cAliasQry)->SERVIC   ,; //21
 		 (cAliasQry)->CODNEG   }) //22
	Else  //Relatorio
		Aadd(aRet,{ .F. ,;        //1
		 ""						,;	//2
		 ""                     ,;	//3
		 ""                     ,;	//4
	     (cAliasQry)->NOMCLIDEV ,; //5
		 (cAliasQry)->VAL_FRE  ,; //6
		 (cAliasQry)->QTD_DOC  ,; //7
		 (cAliasQry)->PESO     ,; //8
		 (cAliasQry)->INIVIG   ,; //9
		 cTipTra                ,; //10
		 (cAliasQry)->CONTRT   ,; //11
		 (cAliasQry)->AAM_CODCLI,; //12
		 (cAliasQry)->AAM_LOJA  ,; //13
		 (cAliasQry)->FILIAL   ,; //14
		 (cAliasQry)->VALMER   ,; //15
		 (cAliasQry)->PESOM3   ,; //16
		 (cAliasQry)->PESCOB   ,; //17
		 (cAliasQry)->VOLORI   ,; //18
		 (cAliasQry)->TIPTRA   ,; //19
		 (cAliasQry)->TIPFRE   ,; //20
		 (cAliasQry)->SERVIC   ,; //21
		 (cAliasQry)->CODNEG   }) //22
		 		 
	EndIf
	(cAliasQry)->( dbSkip() )
EndDo        

If mv_par10 == 1 .And. (cAliasQry)->( !Eof() )
	For nCount := 1 To Len(aRet)
		If aRet[nCount,3] > mv_par03
			nDel ++
			aDel(aRet,nCount)
		EndIf
	Next nCount
	If nDel > 0
		aSize(aRet,nDel)
	EndIf
EndIf
(cAliasQry)->( dbCloseArea() )
Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA990Mrk³ Autor ³Wellington A Santos    ³ Data ³15.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³No evento do click coloca um [x] no quadro                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Tmsa990                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA990Mrk()
aContrt[oLbx1:nAT,1] := !aContrt[oLbx1:nAT,1]
oLbx1:Refresh()
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA990Ctr ³ Autor ³Wellington A Santos    ³ Data ³ 20/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera Novos Contratos daqueles tiverem mais de um tipo de   ³±±
±±³          ³ transporte                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A990GerCtr()                             	    			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA990  												              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA990Ctr(cContrat,cTiptra)

Local aAreaAAM    := AAM->(GetArea())
Local aAreaDUX    := {}
Local aAreaDT9    := {}
Local aAreaDDA    := {}
Local aAreaDDC    := {}
Local aCampos     := {}
Local cNewContrat := ""
Local lExistDux   := .F.

Local cNegAnt   := ""
Local nLinha    := 0
Local lCont     := .T.

If Ascan(aCtrProc,{|x| x == cContrat}) > 0
	Return
EndIf

Aadd(aCtrProc,cContrat)

	DbSelectArea("DDA")
	DbSetOrder(2)
	bSeek  := {|| DDA->(MsSeek(xFilial("DDA") + cContrat))}
	bWhile := {|| DDA->(!Eof()) .And. DDA->DDA_FILIAL + DDA->DDA_NCONTR == xFilial("DDA") + cContrat}
	bSkip  := {|| DDA->(DbSkip())}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Copia Itens do Contrato						     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Eval(bSeek)
	While Eval(bWhile)

		//-- Verifica se o servico devera fazer parte de outro contrato
		lCont := .T.
		If (nLinha := Ascan(aContrt,{|x| x[nContrato] + x[nCodNeg] + x[nServico] == DDA->(DDA_NCONTR + DDA_CODNEG + DDA_SERVIC)})) > 0 .And. ;
					aContrt[nLinha,nMarcado]
			lCont := .F.
		EndIf

		If lCont
			If Empty(cNewContrat) 
				cNewContrat := CriaVar("AAM_CONTRT")
			EndIf	
			lExistDux := .T.		
			aCampos   := {}
			Aadd( aCampos, { "DDA_NCONTR", cNewContrat } )
	
			//-- Copia Negociacoes do Cliente
			If DDA->(DDA_NCONTR + DDA_CODNEG) != cNegAnt
				
				DDC->(DbSetOrder(2))
				If DDC->(DbSeek(xFilial("DDC") + DDA->(DDA_NCONTR + DDA_CODNEG)))

					aAreaDDC := DDC->(GetArea())     

					DDC->(TmsCopyReg({{"DDC_NCONTR",cNewContrat}}))
				
					RestArea( aAreaDDC )
	
				EndIf
									
				cNegAnt := DDA->(DDA_NCONTR + DDA_CODNEG)
			EndIf
	
			//-- Copia Itens da Negociacao do Contrato
			aAreaDDA := DDA->(GetArea())
	
			DDA->(TmsCopyReg(aCampos))
		
			RestArea( aAreaDDA )
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Copia Configuracao de componentes por contrato ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCampos := {}
			Aadd( aCampos, { "DT9_NCONTR", cNewContrat } )
	
			cAliasDT9 := GetNextAlias()
			cQuery := " SELECT DT9.R_E_C_N_O_ REGISTRO "
			cQuery += "   FROM " + RetSqlName("DT9") + " DT9 "
			cQuery += "  WHERE DT9_FILIAL = '" + xFilial("DT9") + "'"
			cQuery += "    AND DT9_NCONTR = '" + cContrat + "' "
			cQuery += "    AND DT9_CODNEG = '" + DDA->DDA_CODNEG + "' "
			cQuery += "    AND DT9_SERVIC = '" + DDA->DDA_SERVIC + "' "
			cQuery += "    AND DT9.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDT9,.F.,.T.)
			While (cAliasDT9)->(!Eof())
				DT9->(DbGoTo((cAliasDT9)->REGISTRO))
			
				aAreaDT9 := DT9->(GetArea())
				
				DT9->(TmsCopyReg(aCampos))
				
				RestArea( aAreaDT9 )
			
				(cAliasDT9)->(DbSkip())
			EndDo
	
			(cAliasDT9)->(DbCloseArea())
	
			DbSelectArea("DDA")

		EndIf
		
		DbSkip()

	EndDo
EndIf		
dbSelectArea("AAM")
dbSetOrder(1)
MsSeek(xFilial("AAM") + cContrat)
	
If lExistDux
	aCampos := {}
	Aadd( aCampos, { "AAM_CONTRT", cNewContrat  } )
	Aadd( aCampos, { "AAM_TPCONT", "1"          } )
	Aadd( aCampos, { "AAM_INIVIG", dDataBase    } )
	
	AAM->(TmsCopyReg(aCampos))
	ConfirmSx8()
Else
	RollbackSx8()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o Fim da vigencia o Atualiza para tempo Determinado. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("AAM",.F.)
AAM->AAM_FIMVIG := dDataBase - 1
AAM->AAM_TPCONT := StrZero(2,Len(AAM->AAM_TPCONT))
AAM->AAM_STATUS := "3" 
MsUnLock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se Utilizar Negociacao por Cliente Grava o Fim da vigencia o Atualiza para tempo Determinado. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DDC->(DbSetOrder(2))
	If DDC->(DbSeek(xFilial("DDC") + cContrat))
		While DDC->(!Eof()) .And. DDC->(DDC_FILIAL + DDC_NCONTR) == xFilial("DDC") + cContrat
			RecLock("DDC",.F.)
			If DDC->DDC_INIVIG >= dDataBase
				DDC->DDC_INIVIG := dDataBase - 1
			EndIf
			DDC->DDC_FIMVIG := dDataBase - 1
			DDC->DDC_TPCONT := StrZero(2,Len(DDC->DDC_TPCONT))
			DDC->DDC_STATUS := StrZero(3,Len(DDC->DDC_STATUS))
			DDC->(MsUnLock())
			DDC->(DbSkip())
		EndDo
	EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada utilizado para gravacao complementar.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTMA990GRV
	ExecBlock("TMA990GRV",.F.,.F.)
EndIf

RestArea( aAreaAAm )
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA990Bt1³ Autor ³Wellington A Santos    ³ Data ³15.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamada para o botao 1 ( contrato do cliente)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Tmsa990                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA990bt1(cTipo,cContrat)
Local cCodCli     := ''
Local cLojCli     := ''
Local cQuery      := ''
Local cAliasQry   := CriaTrab(NIL,.F.)
Local cCampos     := "AAM_CODCLI/AAM_LOJA/AAM_CONTRT/AAM_NOMCLI"
Local aButtons    := {}
Local aInfo       := {},aSize := {},aObjects := {},aPosObj := {}
Local nUsado      := 0
Local nCntFor     := 0
Local nCont		  := 0
Local aAAMStru    := FwFormStruct(2,"AAM")
Private cCadastro := ''
Private INCLUI    := .F.
Private ALTERA    := .F.
Private aHeader   := {}
Private aCols     := {}
Private aRotina	:= {	{ 	,'',0,1},; //
								{ ,'',0,2},; //
								{ ,'',0,3},; //
								{ ,'',0,4},; //
								{ ,'',0,5}} //
Default cTipo := '1'
Aadd(aButtons, {'EDIT'     ,{||TmsA990bt1('2',aCols[n,1])}, STR0005 , STR0006 }) //"Contrato do Cliente"

If cTipo == '1'
	cContrat := aContrt[oLbx1:nAT,nContrato]
	cCodCli  := aContrt[oLbx1:nAT,nCliente]
	cLojCli  := aContrt[oLbx1:nAT,nLojaCli]
EndiF
	
cQuery := "SELECT SA11.A1_NREDUZ NOMEPAI ,SA12.A1_NREDUZ NOMEFILHO,AAM1.AAM_CONTRT CTRPAI ,AAM2.AAM_CONTRT CTRFILHO,AAM2.AAM_CODCLI CODFILHO, "
cQuery += " AAM2.AAM_LOJA LOJAFILHO, AAM1.AAM_CODCLI CODPAI, AAM1.AAM_LOJA LOJAPAI "
cQuery += " FROM " + RetSqlName("AAM") + " AAM1 "
cQuery += " JOIN " + RetSqlName("SA1") + " SA11 "
cQuery += " ON SA11.A1_FILIAL = '" + xFilial("SA1") + "' "
cQuery += " AND SA11.A1_COD   = AAM1.AAM_CODCLI "
cQuery += " AND SA11.A1_LOJA  = AAM1.AAM_LOJA   "
cQuery += " AND SA11.D_E_L_E_T_ = ' '  "
cQuery += " JOIN " + RetSqlName("DE4") + " DE4 "
cQuery += " ON DE4_FILIAL = '" + xFilial("DE4") + "' "
cQuery += " AND DE4_CNPJ  = A1_CGC "
cQuery += " AND DE4.D_E_L_E_T_ = ' ' "
cQuery += " JOIN " + RetSqlName("SA1") + " SA12 "
cQuery += " ON SA12.A1_FILIAL    = '" + xFilial("SA1") + "' "
cQuery += " AND SA12.A1_CGC = DE4_CNPJ1 "
cQuery += " AND SA12.D_E_L_E_T_ = ' '  "
cQuery += " JOIN " + RetSqlName("AAM") + " AAM2 "
cQuery += " ON AAM2.AAM_FILIAL  = '" + xFilial("AAM") + "' "
cQuery += " AND AAM2.AAM_CODCLI = SA12.A1_COD "
cQuery += " AND AAM2.AAM_LOJA   = SA12.A1_LOJA "
If mv_par04 <> 3
	cQuery += " AND ( AAM2.AAM_TIPFRE = '" + StrZero(mv_par04,Len(AAM->AAM_TIPFRE)) + "' OR AAM2.AAM_TIPFRE = '" + StrZero(3,Len(AAM->AAM_TIPFRE)) + "') " 
EndIf
cQuery += " AND AAM2.AAM_STATUS = '" + StrZero(1,Len(AAM->AAM_STATUS)) + "' "
cQuery += " AND ( AAM2.AAM_FIMVIG = '       ' OR AAM2.AAM_FIMVIG >= '" + Dtos(dDataBase) + "') " 
cQuery += " AND AAM2.D_E_L_E_T_ = ' ' " 
cQuery += " WHERE AAM1.AAM_FILIAL = '" + xFilial("AAM") + "' "
cQuery += " AND AAM1.AAM_CODCLI = '" + cCodCli + "' "
cQuery += " AND AAM1.AAM_LOJA   = '" + cLojCli + "' "
cQuery += " AND AAM1.D_E_L_E_T_ = ' ' " 
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
If (cAliasQry)->( !Eof() ) .And. cTipo == '1'
	aHeader := {}	
	For nCont := 1 to Len(aAAMStru:aFields)
		If Alltrim(aAAMStru:aFields[nCont][1]) $ cCampos
			nUsado++
			AADD(aHeader,{ TRIM(aAAMStru:aFields[nCont][3]), aAAMStru:aFields[nCont][1],aAAMStru:aFields[nCont][7],;
			GetSX3Cache(aAAMStru:aFields[nCont][1],"X3_TAMANHO"), GetSX3Cache(aAAMStru:aFields[nCont][1],"X3_DECIMAL"), '',;
			GetSX3Cache(aAAMStru:aFields[nCont][1],"X3_USADO"), GetSX3Cache(aAAMStru:aFields[nCont][1],"X3_TIPO"), GetSX3Cache(aAAMStru:aFields[nCont][1],"X3_ARQUIVO"), GetSX3Cache(aAAMStru:aFields[nCont][1],"X3_CONTEXT")})
		EndIf		
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³inicializa aCols com clientes agrupados                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols := {}
	While (cAliasQry)->(!Eof() )
		Aadd(aCols,Array(Len(aHeader)+1))
		For nCntFor := 1 To Len(aHeader)
			If AllTrim( aHeader[nCntFor,2] ) == "AAM_CODCLI"
				aCols[Len(aCols),nCntFor] := (cAliasQry)->CODFILHO
			ElseIf AllTrim( aHeader[nCntFor,2] )  == "AAM_LOJA"
				aCols[Len(aCols),nCntFor] := (cAliasQry)->LOJAFILHO
			ElseIf AllTrim( aHeader[nCntFor,2] )  == "AAM_CONTRT"
				aCols[Len(aCols),nCntFor] := (cAliasQry)->CTRFILHO
			ElseIf AllTrim( aHeader[nCntFor,2] )  == "AAM_NOMCLI"
				aCols[Len(aCols),nCntFor] := (cAliasQry)->NOMEFILHO
			EndIf
		Next
		aCols[Len(aCols),Len(aHeader)+1] := .F.
		(cAliasQry)->( dbSkip() )
	EndDo
	Aadd(aCols,{ (cAliasQry)->CODPAI,(cAliasQry)->LOJAPAI, (cAliasQry)->CTRPAI,(cAliasQry)->NOMEPAI,.F.} )
	aSize := MsAdvSize()
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T.} )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)
	DEFINE MSDIALOG odlgx TITLE STR0012 FROM 9,0 To 27.5,80 OF oMainWnd
	oMsGetx:= MSGetDados():New( 15,3,138,314,2,"AllWaysTrue",'AllWaysTrue' ,,,,,,)
	ACTIVATE MSDIALOG odlgx CENTERED ON INIT EnchoiceBar(odlgx,{||nOpca:=1, odlgx:End(),nOpca := 0},{||odlgx:End()},,aButtons )
Else
	dbSelectArea("AAM")
	dbSetOrder(1)
	MsSeek(xFilial("AAM") + cContrat )
	If FWHasModel("TECA250")
		n := 1
		FwExecView(,"TECA250",)
	Else
		At250Manut( "AAM", Recno(), 2 )
	EndIf	
EndIf
(cAliasQry)->( dbCloseArea() )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA990Bt2³ Autor ³Wellington A Santos    ³ Data ³15.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamada para o botao 2 (impressao do relatorio)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Tmsa990                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function TMSA990bt2()

TMSR550(.T.)

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA990Psq³ Autor ³Wellington A Santos    ³ Data ³28.03.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA990Psq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA990Psq()

Local aCbx		:= {}
Local cCampo	:= ''
Local cOrd
Local cData		:= ''
Local lSeek		:= .F.
Local nOrdem	:= 1
Local nSeek		:= 0
Local oCbx
Local oDlg
Local oPsqGet

If mv_par03 == 3
	cCampo := AllTrim(GetSX3Cache('DT6_FILNEG',"X3_Titulo")) + ' + ' ;
	+ AllTrim(GetSX3Cache('AAM_CODCLI',"X3_Titulo")) + ' + ' ;
	+ AllTrim(GetSX3Cache('AAM_LOJA',"X3_Titulo"))
Else
	cCampo := AllTrim(GetSX3Cache('AAM_CODCLI',"X3_Titulo")) + ' + ' ;
	+ AllTrim(GetSX3Cache('AAM_LOJA',"X3_Titulo"))
EndIf

Aadd( aCbx, cCampo )
cCampo := AllTrim(GetSX3Cache('A1_NOME',"X3_Titulo"))
Aadd( aCbx, cCampo )

cCampo := Space( 40 )

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0013		//'Pesquisa'

@ 05,05 COMBOBOX oCbx VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlg ON CHANGE nOrdem := oCbx:nAt

@ 22,05 MSGET oPsqGet VAR cCampo SIZE 206,10 PIXEL

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If	lSeek
	cCampo := AllTrim( cCampo )
	If nOrdem == 1
		If mv_par09 == 3
			//-- Fil.Neg + Cod.Cli + Loj.Cli
			ASort( aContrt ,,,{|x,y| x[2] + x[3] + x[4] < y[2] + y[3] + y[4] })
			nSeek := Ascan( aContrt,{ | x | PadR( x[2] + x[3] + x[4], Len( cCampo ) ) == cCampo } )
		Else
			//-- Cod.Cli + Loj.Cli
			ASort( aContrt ,,,{|x,y| x[2] + x[3] < y[2] + y[3] })
			nSeek := Ascan( aContrt,{ | x | PadR( x[2] + x[3] , Len( cCampo ) ) == cCampo } )
		EndIf
	ElseIf nOrdem == 2
		If mv_par09 == 3
			//-- Nome do cliente
			ASort( aContrt ,,,{|x,y| x[5] < y[5] })
			nSeek := Ascan( aContrt,{ | x | PadR( x[5] , Len( cCampo ) ) == cCampo } )
		Else
			//-- Nome do cliente
			ASort( aContrt ,,,{|x,y| x[4] < y[4] })
			nSeek := Ascan( aContrt,{ | x | PadR( x[4] , Len( cCampo ) ) == cCampo } )
		EndIf
	EndIf
EndIf

If	nSeek > 0
	oLbx1:nAT := nSeek
	oLbx1:Refresh()
EndIf
oLbx1:SetFocus()

Return(.T.)

