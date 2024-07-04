// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 08     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#include "OFINJD20.CH"

#define STR0025 "Altera Senha"

#DEFINE NTAMMATRIZ        26

#DEFINE POS_COD           01
#DEFINE POS_LOJA          02
#DEFINE POS_CDJDTIP       03
#DEFINE POS_CDJDCLI       04
#DEFINE POS_CDJDEND       05
#DEFINE POS_NOME          06
#DEFINE POS_CGC           07
#DEFINE POS_CGC_FORMATADO 08
#DEFINE POS_INSCR         09
#DEFINE POS_CEP           10
#DEFINE POS_END           11
#DEFINE POS_COMPLEM       12
#DEFINE POS_NUMERO        13
#DEFINE POS_TELEFONE      14
#DEFINE POS_COD_MUN       15
#DEFINE POS_MUN           16
#DEFINE POS_DISTRITO      17
#DEFINE POS_EST           18
#DEFINE POS_PAIS          19
#DEFINE POS_EMAIL         20
#DEFINE POS_PESSOA        21
#DEFINE POS_RECNO         22
#DEFINE POS_SEL           23
#DEFINE POS_TIPEND        24
#DEFINE POS_MUN_IGUAL     25
#DEFINE POS_CXPOSTAL      26


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFINJD20 º Autor ³ Rubens Takahashi    º Data ³ 18/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualização de Endereço de Cliente                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/{Protheus.doc} OFINJD20
Atualização de Endereço de Clientes na Extranet da John Deere.
Atualização se faz necessária para marcar um equipamento como vendido

@author Rubens
@since 18/10/2013
@version 1.0

@param lNoMBrowse, booleano , Indica se deve ser exibido a MBrowse inicial - Não Obrigatório.

/*/
Function OFINJD20(lNoMBrowse)

Default lNoMBrowse := .f.

Private aRotina   := MenuDef()
Private cCadastro := STR0001 // "Atualização de Endereço de Cliente"

Private cCodBateria

Private lA1CDJDTIP := (SA1->(FieldPos("A1_CDJDTIP")) <> 0)

Private lALTCDTIP := .f. // Controla se o campo A1_CDJDTIP pode ser alterado ...

SA1->(dbSetOrder(1))

mBrowse( 6, 1,22,75,"SA1",,,,,,)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFNJD20EXEC º Autor ³ Andre Luis / Rubens º Data ³ 14/05/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualização de Endereço de Cliente                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFNJD20EXEC(cAlias,nReg,nOpc)

Local cAuxA1COD

Local aEndPR := {}
Local aEndJD := {}

Local oSizePrinc
Local oSizeInfPR
Local oSizeInfJD
Local oDlgEndJD

Local nPos
Local aAuxEnd

Local cPartnerFunction

Local aFClieProtheus  := {}
Local aFClieJohnDeere := {}

Local aCpoProtheus  := {}
Local aCpoJohnDeere := {}

Private oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oVerde    := LoadBitmap( GetResources(), "BR_VERDE" )

Private oBranco   := LoadBitmap( GetResources(), "BR_BRANCO" )
Private oAmarelo  := LoadBitmap( GetResources(), "BR_AMARELO" )

Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

Private lNovoEnd := .f.

SA1->(dbGoTo(nReg))

// Monta Array com os Enderecos Cliente e Clientes Relacionados ...
OFNJD20CLI(@aEndPR,SA1->A1_COD,SA1->A1_LOJA)
//

// Procura todos os enderecos do cliente na John Deere...
OFNJD20FJD(SA1->A1_PESSOA, SA1->A1_CGC, SA1->A1_PAIS, @aEndJD, .f.)
//

If Len(aEndJD) == 0
	AADD(aEndJD,Array(NTAMMATRIZ))
	aEval( aEndJD[1] , { |x| x := "" } )
	aEndJD[1,POS_SEL] := .F. 
	aEndJD[1,POS_MUN_IGUAL] := .F. 
EndIf

// Calculo da Janela Principal
oSizePrinc := FwDefSize():New(.f.)
oSizePrinc:AddObject("PROTHEUS" , 100 , 100 , .T. , .T. )
oSizePrinc:AddObject("JOHNDEERE", 100 , 100 , .T. , .T. )
oSizePrinc:lProp := .t. 	// Mantem proporcao entre objetos redimensionaveis
oSizePrinc:lLateral := .t.	// Calcula em colunas
oSizePrinc:Process()		// Calcula Coordenadas
//

// Calculo da Area de Informacoes - Protheus
oSizeInfPR := FwDefSize():New(.f.)
oSizeInfPR:aWorkArea := oSizePrinc:GetNextCallArea("PROTHEUS")
oSizeInfPR:AddObject("LISTBOX" ,080,100,.T.,.F.)
oSizeInfPR:AddObject("ENCHOICE",100,200,.T.,.T.)
oSizeInfPR:AddObject("BOTAO"   ,100,012,.T.,.F.)
oSizeInfPR:lProp := .t. 		// Mantem proporcao entre objetos redimensionaveis
oSizeInfPR:Process()	// Calcula Coordenadas
//
// Calculo da Area de Informacoes
oSizeInfJD := FwDefSize():New(.f.)
oSizeInfJD:aWorkArea := oSizePrinc:GetNextCallArea("JOHNDEERE")
oSizeInfJD:AddObject("LISTBOX" ,080,100,.T.,.F.)
oSizeInfJD:AddObject("ENCHOICE",100,200,.T.,.T.)
oSizeInfJD:AddObject("BOTAO"   ,100,012,.T.,.F.)
oSizeInfJD:lProp := .t. 		// Mantem proporcao entre objetos redimensionaveis
oSizeInfJD:Process()	// Calcula Coordenadas
//

// Cria matriz com campos do Protheus que serao exibidos na Enchoice
OFNJD20CPO(@aFClieProtheus,"PR")
// Cria matriz com campos da John Deere que serao exibidos na Enchoice
//aFClieJohnDeere := aClone(aFClieProtheus)
OFNJD20CPO(@aFClieJohnDeere,"JD")
// Ajusta campos na matriz do Protheus e da John Deere
aEval(aFClieProtheus , { |x| AADD( aCpoProtheus  , x[2] ) , &("M->"+AllTrim(x[2])+" := Space("+Str(x[4])+")") } )
aEval(aFClieJohnDeere, { |x| AADD( aCpoJohnDeere , x[2] ) , &("M->"+AllTrim(x[2])+" := Space("+Str(x[4])+")") } )
//

DEFINE MSDIALOG oDlgEndJD TITLE STR0001 OF oMainWnd PIXEL;
	FROM oSizePrinc:aWindSize[1],oSizePrinc:aWindSize[2] TO oSizePrinc:aWindSize[3],oSizePrinc:aWindSize[4]

// Protheus
TGroup():New( oSizePrinc:GetDimension("PROTHEUS","LININI") , oSizePrinc:GetDimension("PROTHEUS","COLINI") , oSizePrinc:GetDimension("PROTHEUS","LINEND") , oSizePrinc:GetDimension("PROTHEUS","COLEND") , STR0004 , oDlgEndJD ,,,.t., ) // "Endereço - Protheus"

oPREnchCli := MsmGet():New(,,2 /* Visualizar */,;
	/*aCRA*/,/*cLetras*/,/*cTexto*/,aCpoProtheus ,;
	{ oSizeInfPR:GetDimension("ENCHOICE","LININI") , oSizeInfPR:GetDimension("ENCHOICE","COLINI") + 2, oSizeInfPR:GetDimension("ENCHOICE","LINEND") - 2, oSizeInfPR:GetDimension("ENCHOICE","COLEND") - 2 },;
	aCpoProtheus, 3 /*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlgEndJD , .f. /*lF3*/, .t. /* lMemoria */ , .f. /*lColumn*/,;
	/*caTela*/, .t. /*lNoFolder*/, .f. /*lProperty*/,;
	aFClieProtheus , /* aFolder */ , .f. /* lCreate */ , .t. /*lNoMDIStretch*/,/*cTela*/)


oEndPR := TWBrowse():New( oSizeInfPR:GetDimension("LISTBOX","LININI") + 8, ;
							oSizeInfPR:GetDimension("LISTBOX","COLINI") + 2,;
							oSizeInfPR:GetDimension("LISTBOX","XSIZE") -4 ,;
							oSizeInfPR:GetDimension("LISTBOX","YSIZE") -10,,,,oDlgEndJD,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oEndPR:AddColumn( TCColumn():New( " "                    , { || IIf(aEndPR[oEndPR:nAT,POS_SEL],oOk,oNo) }	,,,,"LEFT" ,10,.T.,.F.,,,,.F.,) )
oEndPR:AddColumn( TCColumn():New( STR0010                , { || IIf(!Empty(aEndPR[oEndPR:nAT,POS_CDJDEND]),oVerde,oVermelho) } ,,,,"LEFT"  ,10,.T.,.F.,,,,.F.,) ) // "Status"
oEndPR:AddColumn( TCColumn():New( RetTitle("A1_COD")     , { || aEndPR[oEndPR:nAT,POS_COD]+"-"+aEndPR[oEndPR:nAT,POS_LOJA] } ,,,,"LEFT"  ,30,.F.,.F.,,,,.F.,) )
oEndPR:AddColumn( TCColumn():New( RetTitle("A1_CDJDCLI") , { || aEndPR[oEndPR:nAT,POS_CDJDCLI      ] } ,,,,"LEFT"  ,40,.F.,.F.,,,,.F.,) )
oEndPR:AddColumn( TCColumn():New( RetTitle("A1_CDJDEND") , { || aEndPR[oEndPR:nAT,POS_CDJDEND      ] } ,,,,"LEFT"  ,40,.F.,.F.,,,,.F.,) )
oEndPR:AddColumn( TCColumn():New( RetTitle("A1_CGC")     , { || aEndPR[oEndPR:nAT,POS_CGC_FORMATADO] } ,,,,"LEFT"  ,50,.F.,.F.,,,,.F.,) )
oEndPR:AddColumn( TCColumn():New( RetTitle("A1_INSCR")   , { || aEndPR[oEndPR:nAT,POS_INSCR        ] } ,,,,"LEFT"  ,50,.F.,.F.,,,,.F.,) )
oEndPR:AddColumn( TCColumn():New( RetTitle("A1_MUN")     , { || aEndPR[oEndPR:nAT,POS_MUN          ] } ,,,,"LEFT"  ,70,.F.,.F.,,,,.F.,) )
oEndPR:nAt := 1
oEndPR:SetArray(aEndPR)
oEndPR:bLDblClick := { || OFNJD20SEL( "PR", @aEndPR , oEndPR:nAT , @aEndJD  ) }
oEndPR:bChange := { || OFNJD20TELA("PR",aEndPR,oEndPR:nAT) , OFNJD20CSL( @aEndPR , @aEndJD ) }

oBtnAtuJDC := TButton():Create( oDlgEndJD , oSizeInfPR:GetDimension("BOTAO","LININI") , oSizeInfPR:GetDimension("BOTAO","COLINI"),;
	STR0015,{ || OFNJD20JD(oEndPR:nAt,aEndPR,aEndJD,1) },70,10,,,,.T.,,STR0016,,,,) // "Atualiza End. Cobrança"

oBtnAtuJDE := TButton():Create( oDlgEndJD , oSizeInfPR:GetDimension("BOTAO","LININI") , oSizeInfPR:GetDimension("BOTAO","COLINI") + 80,;
	STR0017,{ || OFNJD20JD(oEndPR:nAt,aEndPR,aEndJD,2) },70,10,,,,.T.,,STR0018,,,,) // "Atualiza End. Entrega"

// John Deere
TGroup():New( oSizePrinc:GetDimension("JOHNDEERE","LININI") , oSizePrinc:GetDimension("JOHNDEERE","COLINI") , oSizePrinc:GetDimension("JOHNDEERE","LINEND") , oSizePrinc:GetDimension("JOHNDEERE","COLEND") , STR0005 , oDlgEndJD ,,,.t., ) // "Endereço - John Deere"

oJDEnchCli := MsmGet():New(,,2 /* Visualizar */,;
	/*aCRA*/,/*cLetras*/,/*cTexto*/,aCpoJohnDeere ,;
	{ oSizeInfJD:GetDimension("ENCHOICE","LININI") , oSizeInfJD:GetDimension("ENCHOICE","COLINI") + 2, oSizeInfJD:GetDimension("ENCHOICE","LINEND") - 2, oSizeInfJD:GetDimension("ENCHOICE","COLEND") - 2 },;
	aCpoJohnDeere, 3 /*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlgEndJD , .f. /*lF3*/, .t. /* lMemoria */ , .f. /*lColumn*/,;
	/*caTela*/, .t. /*lNoFolder*/, .f. /*lProperty*/,;
	aFClieJohnDeere, /* aFolder */ , .f. /* lCreate */ , .t. /*lNoMDIStretch*/,/*cTela*/)

oEndJD := TWBrowse():New( oSizeInfJD:GetDimension("LISTBOX","LININI") + 8, ;
							oSizeInfJD:GetDimension("LISTBOX","COLINI") + 2,;
							oSizeInfJD:GetDimension("LISTBOX","XSIZE") -4 ,;
							oSizeInfJD:GetDimension("LISTBOX","YSIZE") -10,,,,oDlgEndJD,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oEndJD:AddColumn( TCColumn():New( " "                    , { || IIf( aEndJD[oEndJD:nAT,POS_SEL],oOk,oNo) }	,,,,"LEFT" ,10,.T.,.F.,,,,.F.,) )
oEndJD:AddColumn( TCColumn():New( " "                    , { || IIf( aEndJD[oEndJD:nAt,POS_MUN_IGUAL] , oAmarelo , oBranco ) } ,,,,"LEFT"  ,05,.T.,.F.,,,,.F.,) ) 
oEndJD:AddColumn( TCColumn():New( "P/E"                  , { || IIf( aEndJD[oEndJD:nAT,POS_TIPEND] == "AG" , "P" , "E" ) } ,,,,"LEFT"  ,15,.F.,.F.,,,,.F.,) ) // Tip. Endereço [P]rincipal / [E]ntrega
oEndJD:AddColumn( TCColumn():New( RetTitle("A1_CDJDCLI") , { || aEndJD[oEndJD:nAT,POS_CDJDCLI      ] } ,,,,"LEFT"  ,40,.F.,.F.,,,,.F.,) )
oEndJD:AddColumn( TCColumn():New( RetTitle("A1_CDJDEND") , { || aEndJD[oEndJD:nAT,POS_CDJDEND      ] } ,,,,"LEFT"  ,40,.F.,.F.,,,,.F.,) )
oEndJD:AddColumn( TCColumn():New( RetTitle("A1_CGC")     , { || aEndJD[oEndJD:nAT,POS_CGC_FORMATADO] } ,,,,"LEFT"  ,50,.F.,.F.,,,,.F.,) )
oEndJD:AddColumn( TCColumn():New( RetTitle("A1_MUN")     , { || aEndJD[oEndJD:nAT,POS_MUN          ] } ,,,,"LEFT"  ,70,.F.,.F.,,,,.F.,) )
oEndJD:nAt := 1
oEndJD:SetArray(aEndJD)
oEndJD:bLDblClick := { || OFNJD20SEL("JD", @aEndJD , oEndJD:nAT , @aEndPR ) }
oEndJD:bChange := { || OFNJD20TELA("JD",aEndJD,oEndJD:nAT) }

//oBtnAtuJDC := TButton():Create( oDlgEndJD , oSizeInfJD:GetDimension("BOTAO","LININI") , oSizeInfJD:GetDimension("BOTAO","COLINI"),;
//	"Atualiza End. Protheus",{ || OFNJD20JD(oEndPR:nAt,aEndPR,aEndJD,1) },70,10,,,,.T.,,"Atualiza endereço de cobrança do cliente selecionado",,,,)
oEndPR:Refresh()
oEndJD:Refresh()

ACTIVATE MSDIALOG oDlgEndJD

Return



/*/{Protheus.doc} OFNJD20JD
	
@author Takahashi
@since 01/11/2013
@version 1.0
		
@param nPosEndPR, numérico, (Descrição do parâmetro)
@param aEndPR, array, (Descrição do parâmetro)
@param aEndJD, array, (Descrição do parâmetro)
@param nTPAtu, numérico, (Descrição do parâmetro)

/*/
Static Function OFNJD20JD(nPosEndPR,aEndPR,aEndJD,nTPAtu)

Local oWS
Local nPosWS
Local cSAPCode
Local cAdrCode
Local lCadNovo := .t.
Local nAuxPos
Local cMethod

If !Obrigatorio(oPREnchCli:aGets,oPREnchCli:aTela)
	Return .f.
EndIf

nPosEndPR := aScan( aEndPR , { |x| x[POS_SEL] } )
nPosEndJD := aScan( aEndJD , { |x| x[POS_SEL] } )

If nPosEndPR <= 0
	Help(" ",1,"OBRIGAT",,STR0028,4,1) // "Selecione um endereço"
	Return .f.
EndIf

If !MsgYesNo(STR0019) // "Deseja atualizar o endereço do cliente selecionado na John Deere"
	Return .t.
EndIf

cSAPCode := aEndPR[nPosEndPR,POS_CDJDCLI]
cAdrCode := aEndPR[nPosEndPR,POS_CDJDEND]
cActType := aEndPR[nPosEndPR,POS_CDJDTIP]

If !Empty(cSAPCode) .and. !Empty(cAdrCode)
	If aScan(aEndJD , { |x| x[POS_SEL] }) == 0
		MsgInfo(STR0026,STR0027 ) // "É necessário selecionar um endereço na base da John Deere."
		Return .t.
	EndIf
EndIf

// Verifica se ja existe cadastro do cliente no Portal ...
cMethod := "INS"
cPartnerFunction := IIF( nTPAtu == 1 , "AG" , "WE")
If Len(aEndJD) >= 1 .or. !Empty(aEndJD[1,POS_CDJDCLI])
	// Foi selecionado algum registro da John Deere para atualização 
	If nPosEndJD > 0
		cSAPCode := aEndJD[nPosEndJD,POS_CDJDCLI]
		cMethod := "UPD"
	Else
		// Procura endereco com o mesmo documento para os casos em que esta cadastrando endereco de entrega ...
		If nTPAtu == 2 .and. (nPosEndJD := aScan(aEndJD,{ |x| x[POS_CGC] == AllTrim(aEndPR[nPosEndPR,POS_CGC]) })) <> 0 
			cSAPCode := aEndJD[nPosEndJD,POS_CDJDCLI]
		EndIf
	EndIf
EndIf

oWS := WSJohnDeere_Customer():New()
oWS:SetDebug()

nPosJD := 0

// Se o method for UPD, deve enviar o registro antigo ...
If cMethod == "UPD"

	nPosJD := aScan(aEndJD, { |x| x[POS_SEL] } )
	
	If nPosJD <> 0
	
		// Se nao houver codigo de Cliente JD, o Cliente no Protheus é Novo e ja existe um endereco no Portal da John Deere
//		If Empty(aEndPR[nPosEndPR,POS_CDJDCLI]) .or. Empty(aEndPR[nPosEndPR,POS_CDJDEND]) .or. Empty(aEndPR[nPosEndPR,POS_CDJDEND])
//			OFNJD20ATC( aEndPR[nPosEndPR,POS_RECNO], ;
//							AllTrim(aEndJD[nPosJD,POS_CDJDCLI]),;
//							AllTrim(aEndJD[nPosJD,POS_CDJDEND]),;
//							AllTrim(aEndJD[nPosJD,POS_CDJDTIP]),)
//		EndIf
		If Empty(cSAPCode)
			cSAPCode := AllTrim(aEndJD[nPosJD,POS_CDJDCLI])
		EndIf
		If Empty(cAdrCode)
			cAdrCode := AllTrim(aEndJD[nPosJD,POS_CDJDEND])
		EndIf
		IF Empty(cActType)
			cActType := AllTrim(aEndJD[nPosJD,POS_CDJDTIP])
		EndIf
		//
	
		oAuxWSCliente := JD_Customer_ClienteSAP():New()
		oAuxWSCliente:cmethod          := "OLD"
		oAuxWSCliente:cSAPCustomerCode := AllTrim(aEndJD[nPosJD,POS_CDJDCLI])
		oAuxWSCliente:caddressCode     := AllTrim(aEndJD[nPosJD,POS_CDJDEND])
		oAuxWSCliente:cpartnerFunction := cPartnerFunction
		oAuxWSCliente:cname            := AllTrim(aEndJD[nPosJD,POS_NOME   ])
		oAuxWSCliente:cPOBox           := AllTrim(aEndJD[nPosJD,POS_CXPOSTAL])
		oAuxWSCliente:cactivityType    := AllTrim(aEndJD[nPosJD,POS_CDJDTIP]) // 1 = Produtor Agricola / 2 = Governamental / 3 = Grupo Especial
		oAuxWSCliente:cpersonType      := IIf( aEndJD[nPosJD,POS_PESSOA] == "J" , "2" , "1" )
		oAuxWSCliente:ccnpj            := IIf( aEndJD[nPosJD,POS_PESSOA] == "J" , AllTrim(aEndJD[nPosJD,POS_CGC]) , "" )
		oAuxWSCliente:ccpf             := IIf( aEndJD[nPosJD,POS_PESSOA] == "F" , AllTrim(aEndJD[nPosJD,POS_CGC]) , "" )
		oAuxWSCliente:cpostalCode      := Transform(AllTrim(aEndJD[nPosJD,POS_CEP]),"@R 99999-999")
		oAuxWSCliente:cstreet          := AllTrim(aEndJD[nPosJD,POS_END])
		oAuxWSCliente:ccomplement      := AllTrim(aEndJD[nPosJD,POS_COMPLEM])
		oAuxWSCliente:ccity            := AllTrim(aEndJD[nPosJD,POS_MUN     ])
		oAuxWSCliente:cdistrict        := AllTrim(aEndJD[nPosJD,POS_DISTRITO])
		oAuxWSCliente:cregion          := AllTrim(aEndJD[nPosJD,POS_EST     ])
		oAuxWSCliente:ccountry         := IIf( aEndJD[nPosJD,POS_PAIS] == "105" , "BR" , "" )
		oAuxWSCliente:cemail           := AllTrim(aEndJD[nPosJD,POS_EMAIL])
		oAuxWSCliente:cIBGECityCode    := AllTrim(aEndJD[nPosJD,POS_COD_MUN])
		oAuxWSCliente:cie              := AllTrim(aEndJD[nPosJD,POS_INSCR])
		oAuxWSCliente:cnumber          := AllTrim(aEndJD[nPosJD,POS_NUMERO])
	
		//oAuxWSCliente:cstatusMessage   := aEndJD[nPosJD,]
		oAuxWSCliente:ctelephone       := AllTrim(aEndJD[nPosJD,POS_TELEFONE])
		nPosWS := oWS:oJDCustomer_CreateRequest:oCustomer_clienteSAP:ADDClienteSAP()
		oWS:oJDCustomer_CreateRequest:oCustomer_clienteSAP:oClienteSAP[nPosWS] := oAuxWSCliente
	EndIf
	
EndIf

oAuxWSCliente := JD_Customer_ClienteSAP():New()
oAuxWSCliente:cmethod          := cMethod
//oAuxWSCliente:cSAPCustomerCode := AllTrim(cSAPCode)
//oAuxWSCliente:caddressCode     := AllTrim(aEndPR[nPosEndPR,POS_CDJDEND])
oAuxWSCliente:cSAPCustomerCode := AllTrim(cSAPCode)
oAuxWSCliente:caddressCode     := AllTrim(cAdrCode)
oAuxWSCliente:cpartnerFunction := cPartnerFunction
oAuxWSCliente:cname            := AllTrim(aEndPR[nPosEndPR,POS_NOME    ])
oAuxWSCliente:cPOBox           := AllTrim(aEndPR[nPosEndPR,POS_CXPOSTAL])
//oAuxWSCliente:cactivityType := "1" // aEndPR[nPosEndPR,] - Verifiacr como controlar  -	1 = Produtor Agricola / 2 = Governamental / 3 = Grupo Especial
//  1 = Produtor Agricola / 2 = Governamental / 3 = Grupo Especial
If lA1CDJDTIP .and. cMethod == "INS"
	oAuxWSCliente:cactivityType := M->PR_CDJDTIP
	cActType := M->PR_CDJDTIP
Else
	oAuxWSCliente:cactivityType := cActType
EndIf
oAuxWSCliente:cpersonType   := IIf( aEndPR[nPosEndPR,POS_PESSOA] == "J" , "2" , "1" )
oAuxWSCliente:ccnpj         := IIf( aEndPR[nPosEndPR,POS_PESSOA] == "J" , AllTrim(aEndPR[nPosEndPR,POS_CGC]) , "" )
oAuxWSCliente:ccpf          := IIf( aEndPR[nPosEndPR,POS_PESSOA] == "F" , AllTrim(aEndPR[nPosEndPR,POS_CGC]) , "" )
oAuxWSCliente:cpostalCode   := Transform(AllTrim(aEndPR[nPosEndPR,POS_CEP]),"@R 99999-999")
oAuxWSCliente:cstreet       := AllTrim(aEndPR[nPosEndPR,POS_END])
oAuxWSCliente:ccomplement   := AllTrim(aEndPR[nPosEndPR,POS_COMPLEM])
oAuxWSCliente:ccity         := AllTrim(aEndPR[nPosEndPR,POS_MUN     ])
oAuxWSCliente:cdistrict     := AllTrim(aEndPR[nPosEndPR,POS_DISTRITO])
oAuxWSCliente:cregion       := AllTrim(aEndPR[nPosEndPR,POS_EST     ])
oAuxWSCliente:ccountry      := IIf( aEndPR[nPosEndPR,POS_PAIS] == "105" , "BR" , "" )
oAuxWSCliente:cemail        := AllTrim(aEndPR[nPosEndPR,POS_EMAIL])
oAuxWSCliente:cIBGECityCode := AllTrim(aEndPR[nPosEndPR,POS_COD_MUN])
oAuxWSCliente:cie           := AllTrim(aEndPR[nPosEndPR,POS_INSCR])
oAuxWSCliente:cnumber       := AllTrim(aEndPR[nPosEndPR,POS_NUMERO])

//oAuxWSCliente:cstatusMessage   := aEndPR[nPosEndPR,]
oAuxWSCliente:ctelephone       := AllTrim(aEndPR[nPosEndPR,POS_TELEFONE])

nPosWS := oWS:oJDCustomer_CreateRequest:oCustomer_clienteSAP:ADDClienteSAP()
oWS:oJDCustomer_CreateRequest:oCustomer_clienteSAP:oClienteSAP[nPosWS] := oAuxWSCliente

lProcessado:= .f.
MsgRun(STR0012,STR0013,{|| lProcessado := oWS:create() }) // "Atualizando Cliente"
If !lProcessado
	oWS:ExibeErro()
	Return .f.
EndIf

If Len(oWS:oJDCustomer_CreateReturn:oCustomer_clienteSAP:oClienteSAP) == 0
	Alert(oWS:oJDCustomer_CreateReturn:oCustomer_Header:cmensagemErro)
	Return .f.
EndIf

oAuxWSCliente := oWS:oJDCustomer_CreateReturn:oCustomer_clienteSAP:oClienteSAP[1]

// Se nao tiver codigo SAP, aconteceu algum problema
If Empty(oAuxWSCliente:cSAPCustomerCode)
	MsgStop(oAuxWSCliente:cstatusMessage)
	Return .f.
EndIf

If AllTrim(UPPER(oAuxWSCliente:cstatusMessage)) = "OK"

	If Empty(aEndPR[nPosEndPR,POS_CDJDCLI])
	
		SA1->(dbGoTo(aEndPR[nPosEndPR,POS_RECNO]))
		RecLock("SA1",.f.)
		SA1->A1_CDJDCLI := oAuxWSCliente:cSAPCustomerCode
		SA1->A1_CDJDEND := oAuxWSCliente:caddressCode
		If lA1CDJDTIP
//			SA1->A1_CDJDTIP := oAuxWSCliente:cactivityType
			SA1->A1_CDJDTIP := cActType
		EndIf
		SA1->(MsUnLock())
		
		aEndPR[nPosEndPR,POS_CDJDCLI] := oAuxWSCliente:cSAPCustomerCode
		aEndPR[nPosEndPR,POS_CDJDEND] := oAuxWSCliente:caddressCode
//		aEndPR[nPosEndPR,POS_CDJDTIP] := oAuxWSCliente:cactivityType
		aEndPR[nPosEndPR,POS_CDJDTIP] := cActType
		
		nPosJD := aScan(aEndJD, { |x| x[POS_COD] == aEndPR[nPosEndPR, POS_COD] .and. x[POS_LOJA] == aEndPR[nPosEndPR,POS_LOJA] } )
		If nPosJD <> 0
			oEndJD:nAt := nPosJD
		Else
			nPosJD := aScan(aEndJD, { |x| x[POS_CDJDCLI] == aEndPR[nPosEndPR, POS_CDJDCLI] .and. x[POS_CDJDEND] == aEndPR[nPosEndPR,POS_CDJDEND] } )
			If nPosJD <> 0
				oEndJD:nAt := nPosJD
			Else
				If Len(aEndJD) == 1 .and. Empty(aEndJD[1,POS_CDJDCLI])
					oEndJD:nAt := 1
				Else
					AADD(aEndJD, aClone(aEndPR[nPosEndPR]) )
					oEndJD:nAt := Len(aEndJD)
				EndIf
			EndIf
		EndIf
	Else
		oEndJD:nAt := aScan(aEndJD,{ |x| x[POS_SEL] })
	EndIf
	
	aEndJD[ oEndJD:nAt , POS_TIPEND]  := oAuxWSCliente:cPartnerFunction
			
	aEndJD[ oEndJD:nAt , POS_COD           ] := aEndPR[ nPosEndPR , POS_COD           ]
	aEndJD[ oEndJD:nAt , POS_LOJA          ] := aEndPR[ nPosEndPR , POS_LOJA          ]
	aEndJD[ oEndJD:nAt , POS_CDJDTIP       ] := aEndPR[ nPosEndPR , POS_CDJDTIP       ]
	aEndJD[ oEndJD:nAt , POS_CDJDCLI       ] := aEndPR[ nPosEndPR , POS_CDJDCLI       ]
	aEndJD[ oEndJD:nAt , POS_CDJDEND       ] := aEndPR[ nPosEndPR , POS_CDJDEND       ]
	aEndJD[ oEndJD:nAt , POS_NOME          ] := aEndPR[ nPosEndPR , POS_NOME          ]
	aEndJD[ oEndJD:nAt , POS_CGC           ] := aEndPR[ nPosEndPR , POS_CGC           ]
	aEndJD[ oEndJD:nAt , POS_CGC_FORMATADO ] := aEndPR[ nPosEndPR , POS_CGC_FORMATADO ]
	aEndJD[ oEndJD:nAt , POS_INSCR         ] := aEndPR[ nPosEndPR , POS_INSCR         ]
	aEndJD[ oEndJD:nAt , POS_CEP           ] := aEndPR[ nPosEndPR , POS_CEP           ]
	aEndJD[ oEndJD:nAt , POS_END           ] := aEndPR[ nPosEndPR , POS_END           ]
	aEndJD[ oEndJD:nAt , POS_COMPLEM       ] := aEndPR[ nPosEndPR , POS_COMPLEM       ]
	aEndJD[ oEndJD:nAt , POS_NUMERO        ] := aEndPR[ nPosEndPR , POS_NUMERO        ]
	aEndJD[ oEndJD:nAt , POS_TELEFONE      ] := aEndPR[ nPosEndPR , POS_TELEFONE      ]
	aEndJD[ oEndJD:nAt , POS_COD_MUN       ] := aEndPR[ nPosEndPR , POS_COD_MUN       ]
	aEndJD[ oEndJD:nAt , POS_MUN           ] := aEndPR[ nPosEndPR , POS_MUN           ]
	aEndJD[ oEndJD:nAt , POS_DISTRITO      ] := aEndPR[ nPosEndPR , POS_DISTRITO      ]
	aEndJD[ oEndJD:nAt , POS_EST           ] := aEndPR[ nPosEndPR , POS_EST           ]
	aEndJD[ oEndJD:nAt , POS_PAIS          ] := aEndPR[ nPosEndPR , POS_PAIS          ]
	aEndJD[ oEndJD:nAt , POS_EMAIL         ] := aEndPR[ nPosEndPR , POS_EMAIL         ]
	aEndJD[ oEndJD:nAt , POS_PESSOA        ] := aEndPR[ nPosEndPR , POS_PESSOA        ]
	aEndJD[ oEndJD:nAt , POS_RECNO         ] := aEndPR[ nPosEndPR , POS_RECNO         ]
	aEndJD[ oEndJD:nAt , POS_SEL           ] := .f.
			
	oEndPR:Refresh()
	oEndJD:Refresh()

	aEval( aEndJD , { |x| x[POS_SEL] := .F. } )
	aEval( aEndPR , { |x| x[POS_SEL] := .F. } )

	OFNJD20TELA("PR",aEndPR,oEndPR:nAT)	
	oPREnchCli:Refresh()
	
	OFNJD20TELA("JD",aEndJD,oEndJD:nAT)
	oJDEnchCli:Refresh()
		
	MsgInfo(STR0020) // "Endereço atualizado"
Else
	MsgStop(oAuxWSCliente:cstatusMessage)
	Return .f.
EndIf
//

Return .t.

/*/{Protheus.doc} OFNJD20FJD
Pesquisa os endereços cadastrados na John Deere mesmo que não esteja cadastrado no Protheus.

@author Rubens
@since 23/10/2013
@version 1.0

@param cTipoPessoa, character, Indica se a pesquisa será feita por pessoa [F]ísica ou [J]urídica
@param cDoc, character, Informa o número do documento a ser pesquisado (CPF ou CNPJ).
@param cCodPais, character, Codigo do PAIS ("105" = Brasil).
@param aEndJD, array, Matriz de endereços cadastrados na John Deere.

@example
<br/>
1) Pesquisa por pessoa fisica<br/>
&nbsp&nbsp&nbspOFNJD20FJD("F","50367316978")
<br/><br/>
2) Pesquisa por pessoa jurídica<br/>
&nbsp&nbsp&nbspOFNJD20FJD("J","38862843000170")
/*/
Static Function OFNJD20FJD(cTipoPessoa,cDoc,cCodPais,aEndJD,lExibeErro)

Local oAuxWSCliente
Local oCloneWSCli

Local nAuxPos
Local cAuxMsg

Local cQuery := ""
Local cAliasSA1 := "TSA1"

Local aArea := GetArea()

Private aWSCliTP1 := {}
Private aWSCliTP2 := {}
Private aWSCliTP3 := {}

Default lExibeErro := .t.

If lA1CDJDTIP
	cQuery := "SELECT DISTINCT A1_PESSOA, A1_CGC, A1_CDJDTIP "
	cQuery +=  " FROM " + RetSQLName("SA1")
	cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery +=   " AND ( "
	If cTipoPessoa == "J"
		cQuery +=   " ( A1_CGC LIKE '" + Left(cDoc,8) + "%' )"
	Else
		cQuery +=   " ( A1_CGC    = '" + PadR(cDoc,TamSX3("A1_CGC")[1]) + "' )"
	EndIf
	cQuery +=         " OR A1_INSCR IN ( SELECT DISTINCT A1_INSCR "
	cQuery +=                            " FROM " + RetSQLName("SA1")
	cQuery +=                           " WHERE A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery +=                             " AND A1_CGC     = '" + PadR(cDoc,TamSX3("A1_CGC")[1]) + "'"
	cQuery +=                             " AND A1_INSCR  <> '  '"
	cQuery +=                             " AND A1_INSCR  <> 'ISENTO'"
	cQuery +=                             " AND D_E_L_E_T_ = ' ' )"
	cQuery +=       " ) AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSA1 , .F., .T. )
	While !(cAliasSA1)->(Eof())
	
		// Monta um cliente dentro dos paramentros
		oAuxWSCliente := JD_Customer_ClienteSAP():New()
		oAuxWSCliente:cmethod := "VER"
		oAuxWSCliente:cpartnerFunction := "AG" 
		oAuxWSCliente:cpersonType   := IIf( (cAliasSA1)->A1_PESSOA == "J" , "2" , "1" )
		oAuxWSCliente:ccnpj         := IIf( (cAliasSA1)->A1_PESSOA == "J" , AllTrim((cAliasSA1)->A1_CGC) , "" )
		oAuxWSCliente:ccpf          := IIf( (cAliasSA1)->A1_PESSOA == "F" , AllTrim((cAliasSA1)->A1_CGC) , "" )
		oAuxWSCliente:ccountry      := IIf( cCodPais == "105" , "BR" , "" )
		
		// Se ja possuir tipo de cliente cadastrado..
		If !Empty((cAliasSA1)->A1_CDJDTIP)
			oAuxWSCliente:cactivityType := (cAliasSA1)->A1_CDJDTIP
			AADD( &("aWSCliTP" + (cAliasSA1)->A1_CDJDTIP) , oAuxWSCliente )
			
		// Senao, deve enviar uma consulta com o tipo "1" e tipo "3"...
		Else
			oAuxWSCliente:cactivityType := "1"
			AADD( aWSCliTP1 , oAuxWSCliente )
			
			oCloneWSCli := oAuxWSCliente:Clone()
			oCloneWSCli:cactivityType := "3"
			AADD( aWSCliTP3 , oCloneWSCli )
		EndIf

		(cAliasSA1)->(dbSkip())
	End
	(cAliasSA1)->(dbCloseArea())
	dbSelectArea("SA1")
EndIf

//If !lA1CDJDTIP .or. Len(oWS:oJDCustomer_CreateRequest:oCustomer_clienteSAP:oClienteSAP) == 0
If !lA1CDJDTIP .or. Len(aWSCliTP3) == 0
	// Monta um cliente dentro dos paramentros
	oAuxWSCliente := JD_Customer_ClienteSAP():New()
	oAuxWSCliente:cmethod := "VER"
	oAuxWSCliente:cpartnerFunction := "AG" 
	oAuxWSCliente:cpersonType := IIf( cTipoPessoa == "J" , "2" , "1" )
	oAuxWSCliente:ccnpj       := IIf( cTipoPessoa == "J" , AllTrim(cDoc) , "" )
	oAuxWSCliente:ccpf        := IIf( cTipoPessoa == "F" , AllTrim(cDoc) , "" )
	oAuxWSCliente:ccountry    := IIf( cCodPais == "105" , "BR" , "" )

	AADD( aWSCliTP1 , oAuxWSCliente )

//	// Adiciona um cliente dentro da matriz de paramentros 
//	nPosWS := oWS:oJDCustomer_CreateRequest:oCustomer_clienteSAP:ADDClienteSAP()
//	oWS:oJDCustomer_CreateRequest:oCustomer_clienteSAP:oClienteSAP[nPosWS] := oAuxWSCliente
//	//

EndIf

// Pesquisa enderecos de tipo 1 - Produto Agricola
If Len(aWSCliTP1) > 0
	OFNJD20CJD("1",aWSCliTP1,@aEndJD,lExibeErro)
EndIf

// Pesquisa enderecos de tipo 3 - Grupo Especial
If Len(aWSCliTP3) > 0
	OFNJD20CJD("3",aWSCliTP3,@aEndJD,lExibeErro)
EndIf

If Len(aEndJD) > 0
	cQuery := "SELECT A1_COD, A1_LOJA, A1_CDJDCLI, A1_CDJDEND "
	cQuery +=  " FROM " + RetSQLName("SA1")
	cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery +=   " AND A1_CGC = '" + PadR(cDoc,TamSX3("A1_CGC")[1]) + "'"
	cQuery +=   " AND A1_CDJDCLI <> '     '"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSA1 , .F., .T. )
	While !(cAliasSA1)->(Eof())
	
		nAuxPos := aScan(aEndJD, { |x| x[POS_CDJDCLI] == (cAliasSA1)->A1_CDJDCLI .and. x[POS_CDJDEND] == (cAliasSA1)->A1_CDJDEND } )
		If nAuxPos <> 0
			aEndJD[nAuxPos,POS_COD]  := (cAliasSA1)->A1_COD
			aEndJD[nAuxPos,POS_LOJA] := (cAliasSA1)->A1_LOJA
		EndIf
	
		(cAliasSA1)->(dbSkip())
	End
	(cAliasSA1)->(dbCloseArea())
EndIf

RestArea(aArea)

Return (Len(aEndJD) > 0)

Static Function OFNJD20CJD(cTipoCli, aCliParam,aEndJD,lExibeErro)

Local oWS
Local nPosWS

oWS := WSJohnDeere_Customer():New()
oWS:oJDCustomer_CreateRequest:oCustomer_clienteSAP:oClienteSAP := aClone(aCliParam)
oWS:SetDebug()

lProcessado:= .f.
MsgRun(STR0014,STR0013,{|| lProcessado := oWS:create() }) // "Consultando Cliente"
If !lProcessado
	oWS:ExibeErro()
	Return .f.
EndIf

If Len(oWS:oJDCustomer_CreateReturn:oCustomer_clienteSAP:oClienteSAP) == 0
	Alert(oWS:oJDCustomer_CreateReturn:oCustomer_Header:cmensagemErro)
	Return .f.
EndIf

For nPosWS := 1 to Len(oWS:oJDCustomer_CreateReturn:oCustomer_clienteSAP:oClienteSAP)
	oAuxWSCliente := oWS:oJDCustomer_CreateReturn:oCustomer_clienteSAP:oClienteSAP[nPosWS]
	
	If Empty(oAuxWSCliente:cSAPCustomerCode)
		If lExibeErro
			cAuxMsg := oAuxWSCliente:cstatusMessage + chr(13) + chr(10) + chr(13) + chr(10) + RetTitle("A1_CGC") + ": "
			If oAuxWSCliente:cpersonType == "2"
				cAuxMsg += Transform(oAuxWSCliente:ccnpj, "@R 99.999.999/9999-99" )
			Else
				cAuxMsg += Transform(oAuxWSCliente:ccpf,"@R 999.999.999-99")
			EndIf
			MsgInfo(cAuxMsg)
		EndIf
		Loop
	EndIf
	
	nAuxPos := aScan( aEndJD , { |x| x[POS_CDJDCLI] == oAuxWSCliente:cSAPCustomerCode .and. x[POS_CDJDEND] == oAuxWSCliente:caddressCode } )
	If nAuxPos == 0
		AADD(aEndJD, Array(NTAMMATRIZ))
		nAuxPos := Len(aEndJD)
//		aEndJD[nAuxPos,POS_CDJDTIP] := AllTrim(oAuxWSCliente:cactivityType)
		aEndJD[nAuxPos,POS_CDJDTIP] := cTipoCli
		aEndJD[nAuxPos,POS_CDJDCLI] := oAuxWSCliente:cSAPCustomerCode
		aEndJD[nAuxPos,POS_CDJDEND] := oAuxWSCliente:caddressCode
	EndIf
	
	aEndJD[nAuxPos,POS_NOME]     := AllTrim(oAuxWSCliente:cname)
	
	// Pessoa Juridica
	If oAuxWSCliente:cpersonType == "2"
		aEndJD[nAuxPos,POS_PESSOA]        := "J"
		aEndJD[nAuxPos,POS_CGC]           := oAuxWSCliente:ccnpj
		aEndJD[nAuxPos,POS_CGC_FORMATADO] := Transform(oAuxWSCliente:ccnpj,"@R 99.999.999/9999-99")
	// Pessoa Fisica
	Else
		aEndJD[nAuxPos,POS_PESSOA]        := "F"
		aEndJD[nAuxPos,POS_CGC]           := oAuxWSCliente:ccpf
		aEndJD[nAuxPos,POS_CGC_FORMATADO] := Transform(oAuxWSCliente:ccpf,"@R 999.999.999-99")
	EndIf
	//

	aEndJD[nAuxPos,POS_CEP]       := StrTran(oAuxWSCliente:cpostalCode,"-","")
	aEndJD[nAuxPos,POS_END]       := oAuxWSCliente:cstreet 
	aEndJD[nAuxPos,POS_COMPLEM]   := oAuxWSCliente:ccomplement      
	aEndJD[nAuxPos,POS_MUN]       := oAuxWSCliente:ccity            
	aEndJD[nAuxPos,POS_DISTRITO]  := oAuxWSCliente:cdistrict        
	aEndJD[nAuxPos,POS_EST]       := oAuxWSCliente:cregion          
	aEndJD[nAuxPos,POS_PAIS]      := IIf( oAuxWSCliente:ccountry == "BR" , "105" , "" )
	aEndJD[nAuxPos,POS_EMAIL]     := oAuxWSCliente:cemail           
	aEndJD[nAuxPos,POS_COD_MUN]   := oAuxWSCliente:cIBGECityCode
	aEndJD[nAuxPos,POS_INSCR]     := oAuxWSCliente:cie              
	aEndJD[nAuxPos,POS_NUMERO]    := oAuxWSCliente:cnumber          
	aEndJD[nAuxPos,POS_TELEFONE]  := oAuxWSCliente:ctelephone
	aEndJD[nAuxPos,POS_SEL]       := .F.
	aEndJD[nAuxPos,POS_TIPEND]    := oAuxWSCliente:cPartnerFunction
	aEndJD[nAuxPos,POS_MUN_IGUAL] := .F.
	aEndJD[nAuxPos,POS_CXPOSTAL]  := oAuxWSCliente:cPOBox

Next nPosWS

Return .t.

//nPosWS := oWS:oJDCustomer_CreateRequest:oCustomer_clienteSAP:ADDClienteSAP()
//oWS:oJDCustomer_CreateRequest:oCustomer_clienteSAP:oClienteSAP[nPosWS] := oAuxWSCliente


/*/{Protheus.doc} OFNJD20SEL
Seleciona linha da Listbox
	
@author Takahashi
@since 01/11/2013
@version 1.0
		
@param cPrefixo, character, (Descrição do parâmetro)
@param aEnd, array, (Descrição do parâmetro)
@param nPosEnd, numérico, (Descrição do parâmetro)
@param aEndSeg, array, (Descrição do parâmetro)

/*/ 
Static Function OFNJD20SEL( cPrefixo , aEnd , nPosEnd , aEndSeg )

	Local nAuxPos
	Local cPrefAux := IIf( cPrefixo == "PR" , "JD" , "PR" )
	Local cCodMun
	Local cChave

	If !aEnd[nPosEnd,POS_SEL]
		aEval(aEnd, { |x| x[POS_SEL] := .F. } )
		aEnd[nPosEnd,POS_SEL] := .t.
	Else
		aEnd[nPosEnd,POS_SEL] := .f.
	EndIf

	If aEnd[nPosEnd,POS_SEL]

		nAuxPos := 0
		cChave  := cValToChar(aEnd[nPosEnd, POS_CGC]) + cValToChar(aEnd[nPosEnd, POS_INSCR])
		// Se tiver codigo de endereco JD ...
		if ! Empty(aEndSeg[1,1]) // verifica se tem algum endereço cadastrado
			If ! Empty(aEnd[nPosEnd,POS_CDJDCLI])
				nAuxPos := aScan( aEndSeg , { |x| ;
					cValToChar(x[POS_CGC]) + cValToChar(x[POS_INSCR]) == cChave ;
					.or. (x[POS_CDJDCLI] == aEnd[nPosEnd,POS_CDJDCLI];
					.and. x[POS_CDJDEND] == aEnd[nPosEnd,POS_CDJDEND]);
				} )
			else
				If cPrefixo == "PR"
					nAuxPos := aScan( aEndSeg , { |x| cValToChar(x[POS_CGC]) + cValToChar(x[POS_INSCR]) == cChave .and. x[POS_CEP] == aEnd[nPosEnd,POS_CEP] } )
				EndIf
			EndIf
		endif
		If nAuxPos <> 0
			aEval(aEndSeg, { |x| x[POS_SEL] := .F. } )
			aEndSeg[ nAuxPos , POS_SEL ] := .T.
			OFNJD20TELA( cPrefAux , aEndSeg , nAuxPos )

			cCodMun := IIf( cPrefixo == "PR" , aEnd[nPosEnd,POS_COD_MUN] , aEndSeg[nAuxPos,POS_COD_MUN] )
			aEval( IIf( cPrefixo == "PR" , aEndSeg , aEnd ) , { |x| x[POS_MUN_IGUAL] := (x[POS_COD_MUN] == cCodMun) } )
		else
			aEval(aEndSeg, { |x| x[POS_SEL] := .F. } )
		EndIf
		//
		
		oPREnchCli:SetFocus()
		
	Else
		aEval( aEndSeg, { |x| x[POS_SEL] := .f. , IIf( cPrefixo == "PR" , (x[POS_MUN_IGUAL] := .f.) , ) } )
	EndIf

	oEndPR:Refresh()
	oEndJD:Refresh()

Return

Static Function OFNJD20CSL( aEndPR , aEndJD )

aEval( aEndPR, { |x| x[POS_SEL] := .f. , x[POS_MUN_IGUAL] := .f. } )
oEndPR:Refresh()

aEval( aEndJD, { |x| x[POS_SEL] := .f. , x[POS_MUN_IGUAL] := .f. } )
oEndJD:Refresh()

Return


/*/{Protheus.doc} OFNJD20CON
Consulta todos os endereços de um determinado cliente no portal da John Deere.
	
@author Takahashi
@since 27/11/2013
@version 1.0
		
@param cPPessoa, character, Tipo da pessoa (A1_PESSOA) para pesquisa. 
@param cPDoc, character, Número do CPF/CNPJ para pesquisa.
@param cPPais, character, Código do País para pesquisa.
/*/
Function OFNJD20CON(cPPessoa , cPDoc , cPPais)

Local cAuxA1COD

Local aEndJD := {}

Local oSizePrinc
Local oSizeInfJD
Local oDlgCEndJD

Local nPos
Local aAuxEnd
Local cAuxPesq
Local cAuxTelefone

Local cPartnerFunction

Local aFClieJohnDeere := {}

Local aCpoJohnDeere := {}

Local aAreaCC2
Local aAreaVAM
Local aAreaAtu

Local cMsg := ""

Default cPPessoa := SA1->A1_PESSOA
Default cPDoc    := SA1->A1_CGC
Default cPPais   := SA1->A1_PAIS

Private oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oVerde    := LoadBitmap( GetResources(), "BR_VERDE" )

Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

Private lA1CDJDTIP := (SA1->(FieldPos("A1_CDJDTIP")) <> 0)

If Empty(cPPessoa) .or. Empty(cPDoc) .or. Empty(cPPais)
	cMsg += IIf( Empty(cPPessoa), STR0021 + CHR(13) + CHR(10) , "" ) // "Parâmetro de tipo de pessoa não informado."
	cMsg += IIf( Empty(cPDoc)   , STR0022 + CHR(13) + CHR(10) , "" ) // "Parâmetro de número do CPF/CNPJ não informado."
	cMsg += IIf( Empty(cPPais)  , STR0023 + CHR(13) + CHR(10) , "" ) // "Parâmetro do código do País não informado."
	MsgInfo(cMsg)
	Return .f.
EndIf

// Procura todos os enderecos do cliente na John Deere...
If !OFNJD20FJD(cPPessoa , cPDoc , cPPais, @aEndJD)
	Return .f.
EndIf
//

// Calculo da Janela Principal
oSizePrinc := FwDefSize():New(.t.)
oSizePrinc:AddObject("LISTBOX" ,080,100,.T.,.T.)
oSizePrinc:AddObject("ENCHOICE",100,200,.T.,.F.)
oSizePrinc:lProp := .t. 	// Mantem proporcao entre objetos redimensionaveis
oSizePrinc:lLateral := .f.	// Calcula em colunas
oSizePrinc:Process()		// Calcula Coordenadas
//

// Cria matriz com campos do Protheus que serao exibidos na Enchoice
OFNJD20CPO(@aFClieJohnDeere,"JD")
//aEval(aFClieJohnDeere, { |x| x[2] := "JD" + x[2] , AADD( aCpoJohnDeere , x[2] ) , &("M->"+AllTrim(x[2])+" := Space("+Str(x[4])+")") } )
aEval(aFClieJohnDeere, { |x| AADD( aCpoJohnDeere , x[2] ) , &("M->"+AllTrim(x[2])+" := Space("+Str(x[4])+")") } )
//

DEFINE MSDIALOG oDlgCEndJD TITLE STR0001 OF oMainWnd PIXEL;
	FROM oSizePrinc:aWindSize[1],oSizePrinc:aWindSize[2] TO oSizePrinc:aWindSize[3],oSizePrinc:aWindSize[4]

// John Deere
TGroup():New( oSizePrinc:GetDimension("LISTBOX","LININI") , ;
				oSizePrinc:GetDimension("LISTBOX","COLINI") , ;
				oSizePrinc:GetDimension("ENCHOICE","LINEND") , ;
				oSizePrinc:GetDimension("ENCHOICE","COLEND") , STR0005 , oDlgCEndJD ,,,.t., ) // "Endereço - John Deere"

oJDEnchCli := MsmGet():New(,,2 /* Visualizar */,;
	/*aCRA*/,/*cLetras*/,/*cTexto*/,aCpoJohnDeere ,;
	{ oSizePrinc:GetDimension("ENCHOICE","LININI") , oSizePrinc:GetDimension("ENCHOICE","COLINI") + 2, oSizePrinc:GetDimension("ENCHOICE","LINEND") - 2, oSizePrinc:GetDimension("ENCHOICE","COLEND") - 2 },;
	aCpoJohnDeere, 3 /*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlgCEndJD , .f. /*lF3*/, .t. /* lMemoria */ , .f. /*lColumn*/,;
	/*caTela*/, .t. /*lNoFolder*/, .t. /*lProperty*/,;
	aFClieJohnDeere, /* aFolder */ , .f. /* lCreate */ , .t. /*lNoMDIStretch*/,/*cTela*/)
	
oEndJD := TWBrowse():New( oSizePrinc:GetDimension("LISTBOX","LININI") + 8, ;
							oSizePrinc:GetDimension("LISTBOX","COLINI") + 2,;
							oSizePrinc:GetDimension("LISTBOX","XSIZE") -4 ,;
							oSizePrinc:GetDimension("LISTBOX","YSIZE") -10,,,,oDlgCEndJD,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oEndJD:AddColumn( TCColumn():New( " "                    , { || IIf( aEndJD[oEndJD:nAT,POS_SEL],oOk,oNo) }	,,,,"LEFT" ,10,.T.,.F.,,,,.F.,) )
oEndJD:AddColumn( TCColumn():New( " "                    , { || IIf( !Empty(aEndJD[oEndJD:nAt,POS_COD]) , oVermelho , oVerde ) } ,,,,"LEFT"  ,05,.T.,.F.,,,,.F.,) ) 
oEndJD:AddColumn( TCColumn():New( "P/E"                  , { || IIf( aEndJD[oEndJD:nAT,POS_TIPEND] == "AG" , "P" , "E" ) } ,,,,"LEFT"  ,15,.F.,.F.,,,,.F.,) ) // Tip. Endereço [P]rincipal / [E]ntrega
oEndJD:AddColumn( TCColumn():New( RetTitle("A1_COD")     , { || aEndJD[oEndJD:nAT,POS_COD          ] } ,,,,"LEFT"  ,40,.F.,.F.,,,,.F.,) )
oEndJD:AddColumn( TCColumn():New( RetTitle("A1_LOJA")    , { || aEndJD[oEndJD:nAT,POS_LOJA         ] } ,,,,"LEFT"  ,20,.F.,.F.,,,,.F.,) )
oEndJD:AddColumn( TCColumn():New( RetTitle("A1_CDJDCLI") , { || aEndJD[oEndJD:nAT,POS_CDJDCLI      ] } ,,,,"LEFT"  ,30,.F.,.F.,,,,.F.,) )
oEndJD:AddColumn( TCColumn():New( RetTitle("A1_CDJDEND") , { || aEndJD[oEndJD:nAT,POS_CDJDEND      ] } ,,,,"LEFT"  ,30,.F.,.F.,,,,.F.,) )
oEndJD:AddColumn( TCColumn():New( RetTitle("A1_CGC")     , { || aEndJD[oEndJD:nAT,POS_CGC_FORMATADO] } ,,,,"LEFT"  ,50,.F.,.F.,,,,.F.,) )
oEndJD:AddColumn( TCColumn():New( RetTitle("A1_MUN")     , { || aEndJD[oEndJD:nAT,POS_MUN          ] } ,,,,"LEFT"  ,70,.F.,.F.,,,,.F.,) )
oEndJD:nAt := 1
oEndJD:SetArray(aEndJD)
//oEndJD:bLDblClick := { || aEndJD[oEndJD:nAt, POS_SEL] := !aEndJD[oEndJD:nAt, POS_SEL] }
oEndJD:bLDblClick := { || IIf( aEndJD[oEndJD:nAt,POS_SEL] , ;
								aEndJD[oEndJD:nAt,POS_SEL] := .F. , ;
								( IIf( Empty(aEndJD[oEndJD:nAt,POS_COD]) , ( aEval( aEndJD, { |x| x[POS_SEL] := .F. } ), aEndJD[oEndJD:nAt, POS_SEL] := .t. ) , MsgInfo(STR0024,STR0027)) );
							  ) }
oEndJD:bChange := { || OFNJD20TELA("JD",aEndJD,oEndJD:nAT) }
oEndJD:Refresh()

lOk := .f.
nPosEndJD := 0
ACTIVATE MSDIALOG oDlgCEndJD ON INIT EnchoiceBar(oDlgCEndJD,{|| lOk := .t. , nPosEndJD := oEndJD:nAt , oDlgCEndJD:End()},{|| lOk := .f. , oDlgCEndJD:End()})

If lOk 

	aAreaCC2 := CC2->(GetArea())
	aAreaVAM := VAM->(GetArea())
	aAreaAtu := GetArea()

	M->A1_CDJDTIP := aEndJD[ nPosEndJD , POS_CDJDTIP ]
	M->A1_CDJDCLI := aEndJD[ nPosEndJD , POS_CDJDCLI ]
	M->A1_CDJDEND := aEndJD[ nPosEndJD , POS_CDJDEND ]
	M->A1_NOME    := PadR(aEndJD[ nPosEndJD , POS_NOME ],Len(M->A1_NOME))
	M->A1_CGC     := aEndJD[ nPosEndJD , POS_CGC     ]
	M->A1_INSCR   := aEndJD[ nPosEndJD , POS_INSCR   ]
	M->A1_CEP     := aEndJD[ nPosEndJD , POS_CEP     ]
	M->A1_END     := PadR(AllTrim(aEndJD[ nPosEndJD , POS_END ]) + IIf( !Empty(aEndJD[ nPosEndJD , POS_NUMERO ]) , ", " + AllTrim(aEndJD[ nPosEndJD , POS_NUMERO ]) , "" ) ,Len(M->A1_END))
	M->A1_EST     := aEndJD[ nPosEndJD , POS_EST     ]
	M->A1_PAIS    := aEndJD[ nPosEndJD , POS_PAIS    ]
	M->A1_EMAIL   := PadR(aEndJD[ nPosEndJD , POS_EMAIL   ],Len(M->A1_EMAIL))
	M->A1_PESSOA  := aEndJD[ nPosEndJD , POS_PESSOA  ]
//	M->A1_COMPLEM := PadR(aEndJD[ nPosEndJD , POS_COMPLEM ],Len(M->A1_COMPLEM))
	M->A1_CXPOSTA := PadR(aEndJD[ nPosEndJD , POS_CXPOSTAL ],Len(M->A1_CXPOSTA))

	cAuxTelefone := AllTrim(aEndJD[ nPosEndJD , POS_TELEFONE ])
	cAuxTelefone := StrTran(cAuxTelefone,"(")
	cAuxTelefone := StrTran(cAuxTelefone,")")
	cAuxTelefone := StrTran(cAuxTelefone,"-")
	cAuxTelefone := StrTran(cAuxTelefone," ")
	If !Empty(cAuxTelefone)
		M->A1_DDD := Left(cAuxTelefone,2)
		M->A1_TEL := Right(cAuxTelefone,Len(cAuxTelefone)-2)
	EndIf
//	aEndPR[ nPos , POS_TELEFONE      ] := AllTrim(AllTrim(SA1->A1_DDD) + " " + AllTrim(SA1->A1_TEL))
	
	cAuxPesq := PadR(aEndJD[ nPosEndJD, POS_MUN ],TamSX3("A1_MUN")[1])
	
	// Procura Municipio
	CC2->(dbSetOrder(2))
	If CC2->(dbSeek(xFilial("CC2") + cAuxPesq ))
		M->A1_COD_MUN := CC2->CC2_CODMUN
		M->A1_MUN := CC2->CC2_MUN
	EndIf
	
	// Procura Distrito
//	If !Empty(aEndJD[ nPosEndJD , POS_DISTRITO ])
//		cAuxPesq := PadR(aEndJD[ nPosEndJD , POS_DISTRITO ],TamSX3("VAM_DESCID")[1])
//	Else
		cAuxPesq := PadR(aEndJD[ nPosEndJD, POS_MUN ],TamSX3("VAM_DESCID")[1])
//	EndIf
	VAM->(dbSetOrder(3))
	If VAM->(dbSeek( xFilial("VAM") + aEndJD[ nPosEndJD , POS_EST ] + cAuxPesq))
		M->A1_IBGE := VAM->VAM_IBGE
	EndIf
	
	M->A1_BAIRRO := PadR(aEndJD[ nPosEndJD , POS_DISTRITO ],Len(M->A1_BAIRRO))
	
	RestArea(aAreaCC2)
	RestArea(aAreaVAM)
	RestArea(aAreaAtu)

EndIf

Return


/*/{Protheus.doc} OFNJD20TELA
Seta variaveis M-> de acordo com o prefixo que é o nome da variavel pra aparecer na tela
	
@author Takahashi
@since 01/11/2013
@version 1.0
		
@param cPrefixo, character, se é protheus ou john deere
@param aAuxEnd, array, array contendo os dados
@param nAuxPos, numérico, posicao
/*/
Static Function OFNJD20TELA(cPrefixo,aAuxEnd,nAuxPos)

&("M->" + cPrefixo + "_CDJDTIP")  := aAuxEnd[ nAuxPos , POS_CDJDTIP      ]
&("M->" + cPrefixo + "_CDJDCLI")  := aAuxEnd[ nAuxPos , POS_CDJDCLI      ]
&("M->" + cPrefixo + "_CDJDEND")  := aAuxEnd[ nAuxPos , POS_CDJDEND      ]
&("M->" + cPrefixo + "_NOME")     := aAuxEnd[ nAuxPos , POS_NOME         ]
&("M->" + cPrefixo + "_CGC")      := aAuxEnd[ nAuxPos , POS_CGC_FORMATADO]
&("M->" + cPrefixo + "_INSCR")    := aAuxEnd[ nAuxPos , POS_INSCR        ]
&("M->" + cPrefixo + "_CEP")      := aAuxEnd[ nAuxPos , POS_CEP          ]
&("M->" + cPrefixo + "_END")      := aAuxEnd[ nAuxPos , POS_END          ]
&("M->" + cPrefixo + "_COMPLEM")  := aAuxEnd[ nAuxPos , POS_COMPLEM      ]
&("M->" + cPrefixo + "_NUMERO")   := aAuxEnd[ nAuxPos , POS_NUMERO       ]
&("M->" + cPrefixo + "_TEL")      := aAuxEnd[ nAuxPos , POS_TELEFONE     ]
&("M->" + cPrefixo + "_COD_MUN")  := aAuxEnd[ nAuxPos , POS_COD_MUN      ]
&("M->" + cPrefixo + "_MUN")      := aAuxEnd[ nAuxPos , POS_MUN          ]
&("M->" + cPrefixo + "_DISTRITO") := aAuxEnd[ nAuxPos , POS_DISTRITO     ]
&("M->" + cPrefixo + "_EST")      := aAuxEnd[ nAuxPos , POS_EST          ]
&("M->" + cPrefixo + "_PAIS")     := aAuxEnd[ nAuxPos , POS_PAIS         ]
&("M->" + cPrefixo + "_EMAIL")    := aAuxEnd[ nAuxPos , POS_EMAIL        ]
&("M->" + cPrefixo + "_CXPOSTA")  := aAuxEnd[ nAuxPos , POS_CXPOSTAL     ]


// O campo de tipo de cliente John Deere so pode ser alterado quando não houver conteudo ...
If cPrefixo == "PR"
	lALTCDTIP := Empty(aAuxEnd[ nAuxPos , POS_CDJDTIP ] )
EndIf

&("o" + cPrefixo + "EnchCli:Refresh()")

Return



/*/{Protheus.doc} OFNJD20CPO
(long_description)
	
@author Takahashi
@since 01/11/2013
@version 1.0
		
@param aAuxField, array, (Descrição do parâmetro)
/*/
Static Function OFNJD20CPO(aAuxField,cPrefixo)

aAuxField := {}

// Cria matriz aAuxField para ser utilizada na Enchoice de Registro (Sem SX3)
/* Estrutura do vetor aAuxField
	[01] - Titulo           [11] - F3
	[02] - campo            [12] - when
	[03] - Tipo	            [13] - visual
	[04] - Tamanh           [14] - chave
	[05] - Decima           [15] - box
	[06] - Pictur           [16] - folder
	[07] - Valid            [17] - nao alteravel
	[08] - Obriga           [18] - pictvar
	[09] - Nivel            [19] - gatilho
	[10] - Inicial. Padrão
*/
// Define os campos que serao exibidos na Enchoice
If lA1CDJDTIP
	SX3->(dbSetOrder(1))
	SX3->(dbSeek("A1_CDJDCLI"))
	//                  Titulo					, Campo					, TP  , Tamanho					, D , Picture	, Valid , Obr , N , IP , F3 , When  , Visual , Chave , Box       , Folder , Nao Alt , Pct Var , Gatilho
	AADD( aAuxField , { RetTitle("A1_CDJDTIP")	, cPrefixo + "_CDJDTIP"	, "C" , TamSX3("A1_CDJDTIP")[1]	, 0 , "@!"		, ""	, .T. , 1 , "" , "" , ""    , .f.    , .f.   , X3Cbox()  ,        , .f.     , ""      , "N" })
	If cPrefixo == "PR"
		aAuxField[Len(aAuxField),12] := { || lALTCDTIP }
	Else
		aAuxField[Len(aAuxField),08] := .f.
		aAuxField[Len(aAuxField),17] := .t.
	EndIf
EndIf
//                  Titulo					, Campo			        , TP  , Tamanho					, D , Picture	, Valid , Obr , N , IP , F3 , When, Visual , Chave , Box , Folder , Nao Alt , Pct Var , Gatilho
AADD( aAuxField , { RetTitle("A1_CDJDCLI")	, cPrefixo + "_CDJDCLI"	, "C" , TamSX3("A1_CDJDCLI")[1]	, 0 , "@!"		, ""	, .f. , 1 , "" , "" , ""  , .t.    , .f.   , ""  ,        , .t.     , ""      , "N" })
AADD( aAuxField , { RetTitle("A1_CDJDEND")	, cPrefixo + "_CDJDEND"	, "C" , TamSX3("A1_CDJDEND")[1]	, 0 , "@!"		, ""	, .f. , 1 , "" , "" , ""  , .t.    , .f.   , ""  ,        , .t.     , ""      , "N" })
AADD( aAuxField , { RetTitle("A1_NOME")		, cPrefixo + "_NOME"	, "C" , TamSX3("A1_NOME")[1]	, 0 , "@!"		, ""	, .f. , 1 , "" , "" , ""  , .t.    , .f.   , ""  ,        , .t.     , ""      , "N" })
AADD( aAuxField , { RetTitle("A1_CGC")		, cPrefixo + "_CGC"		, "C" , TamSX3("A1_CGC")[1]		, 0 , "@!"		, ""	, .f. , 1 , "" , "" , ""  , .t.    , .f.   , ""  ,        , .t.     , ""      , "N" })
AADD( aAuxField , { RetTitle("A1_INSCR")	, cPrefixo + "_INSCR"	, "C" , TamSX3("A1_INSCR")[1]	, 0 , "@!"		, ""	, .f. , 1 , "" , "" , ""  , .t.    , .f.   , ""  ,        , .t.     , ""      , "N" })
AADD( aAuxField , { RetTitle("A1_CEP")		, cPrefixo + "_CEP"		, "C" , TamSX3("A1_CEP")[1]		, 0 , "@!"		, ""	, .f. , 1 , "" , "" , ""  , .t.    , .f.   , ""  ,        , .t.     , ""      , "N" })
AADD( aAuxField , { RetTitle("A1_END")		, cPrefixo + "_END"		, "C" , TamSX3("A1_END")[1]		, 0 , "@!"		, ""	, .f. , 1 , "" , "" , ""  , .t.    , .f.   , ""  ,        , .t.     , ""      , "N" })
AADD( aAuxField , { RetTitle("A1_COMPLEM")	, cPrefixo + "_COMPLEM"	, "C" , TamSX3("A1_COMPLEM")[1]	, 0 , "@!"		, ""	, .f. , 1 , "" , "" , ""  , .t.    , .f.   , ""  ,        , .t.     , ""      , "N" })
AADD( aAuxField , { STR0008					, cPrefixo + "_NUMERO"	, "C" , 10						, 0 , "@!"		, ""	, .f. , 1 , "" , "" , ""  , .t.    , .f.   , ""  ,        , .t.     , ""      , "N" })
AADD( aAuxField , { RetTitle("A1_TEL")		, cPrefixo + "_TEL"		, "C" , TamSX3("A1_TEL")[1]		, 0 , "@!"		, ""	, .f. , 1 , "" , "" , ""  , .t.    , .f.   , ""  ,        , .t.     , ""      , "N" })
AADD( aAuxField , { RetTitle("A1_COD_MUN")	, cPrefixo + "_COD_MUN"	, "C" , TamSX3("A1_COD_MUN")[1]	, 0 , "@!"		, ""	, .f. , 1 , "" , "" , ""  , .t.    , .f.   , ""  ,        , .t.     , ""      , "N" })
AADD( aAuxField , { RetTitle("A1_MUN")		, cPrefixo + "_MUN"		, "C" , TamSX3("A1_MUN")[1]		, 0 , "@!"		, ""	, .f. , 1 , "" , "" , ""  , .t.    , .f.   , ""  ,        , .t.     , ""      , "N" })
AADD( aAuxField , { RetTitle("A1_BAIRRO")	, cPrefixo + "_DISTRITO", "C" , TamSX3("A1_BAIRRO")[1]	, 0 , "@!"		, ""	, .f. , 1 , "" , "" , ""  , .t.    , .f.   , ""  ,        , .t.     , ""      , "N" })
AADD( aAuxField , { RetTitle("A1_EST")		, cPrefixo + "_EST"		, "C" , TamSX3("A1_EST")[1]		, 0 , "@!"		, ""	, .f. , 1 , "" , "" , ""  , .t.    , .f.   , ""  ,        , .t.     , ""      , "N" })
AADD( aAuxField , { RetTitle("A1_PAIS")		, cPrefixo + "_PAIS"	, "C" , TamSX3("A1_PAIS")[1]	, 0 , "@!"		, ""	, .f. , 1 , "" , "" , ""  , .t.    , .f.   , ""  ,        , .t.     , ""      , "N" })
AADD( aAuxField , { RetTitle("A1_EMAIL")	, cPrefixo + "_EMAIL"	, "C" , TamSX3("A1_EMAIL")[1]	, 0 , "@!"		, ""	, .f. , 1 , "" , "" , ""  , .t.    , .f.   , ""  ,        , .t.     , ""      , "N" })
AADD( aAuxField , { RetTitle("A1_CXPOSTA")	, cPrefixo + "_CXPOSTA"	, "C" , TamSX3("A1_CXPOSTA")[1]	, 0 , "@!"		, ""	, .f. , 1 , "" , "" , ""  , .t.    , .f.   , ""  ,        , .t.     , ""      , "N" })
//AADD( aAuxField , {cSoap += WSSoapValue("POBox", ::cPOBox, ::cPOBox , "string", .F. , .T., 0 , NIL, .F.)

Return aAuxField

Static Function OFNJD20CLI(aEndPR,cCodCli,cLojCli)

Local aAuxEnd := {}
Local aAuxArea
Local cAliasSA1 := "TSA1"

dbSelectArea("SA1")
aAuxArea := GetArea()

SA1->(dbSetOrder(1))
SA1->(MsSeek(xFilial("SA1") + cCodCli + cLojCli))
cAuxA1COD := SA1->A1_COD
cAuxA1DOC := SA1->A1_CGC

cQuery := "SELECT DISTINCT R_E_C_N_O_ A1RECNO "
cQuery +=  " FROM " + RetSQLName("SA1")
cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") + "'"
cQuery +=   " AND ( "
cQuery +=             "( A1_COD = '" + cAuxA1COD + "' )"
If SA1->A1_PESSOA == 'J'
	cQuery +=      " OR ( A1_CGC LIKE '" + Left(cAuxA1DOC,8) + "%' )"
Else
	cQuery +=      " OR ( A1_CGC = '" + cAuxA1DOC + "' )"
EndIf
cQuery +=         " OR ( A1_INSCR IN ( SELECT DISTINCT A1_INSCR "
cQuery +=                              " FROM " + RetSQLName("SA1")
cQuery +=                             " WHERE A1_FILIAL = '" + xFilial("SA1") + "'"
cQuery +=                               " AND A1_CGC    = '" + cAuxA1DOC + "'"
cQuery +=                               " AND A1_INSCR  <> '  '"
cQuery +=                               " AND A1_INSCR  <> 'ISENTO'"
cQuery +=                               " AND D_E_L_E_T_ = ' ' ) )"
cQuery +=       " ) AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSA1 , .F., .T. )
While !(cAliasSA1)->(Eof())
	SA1->(dbGoTo( (cAliasSA1)->A1RECNO ))

//SA1->(dbSetOrder(3))
//SA1->(dbSeek(xFilial("SA1") + cAuxA1DOC ))
//While !SA1->(Eof()) .and. SA1->A1_FILIAL == xFilial("SA1") .and. SA1->A1_CGC == cAuxA1DOC

//	If cAuxA1DOC <> SA1->A1_CGC
//		SA1->(dbSkip())
//		Loop
//	EndIf

	// {cEnderec,nNumero,cNumero,cComplemen}
	aAuxEnd := FisGetEnd(SA1->A1_END, SA1->A1_EST)

	AADD( aEndPR , Array(NTAMMATRIZ) )
	nPos := Len(aEndPR)

	aEndPR[ nPos , POS_COD           ] := SA1->A1_COD
	aEndPR[ nPos , POS_LOJA          ] := SA1->A1_LOJA
	If lA1CDJDTIP
		aEndPR[ nPos , POS_CDJDTIP    ] := SA1->A1_CDJDTIP
	Else
		aEndPR[ nPos , POS_CDJDTIP    ] := "1"
	EndIf
	aEndPR[ nPos , POS_CDJDCLI       ] := SA1->A1_CDJDCLI
	aEndPR[ nPos , POS_CDJDEND       ] := SA1->A1_CDJDEND
	aEndPR[ nPos , POS_NOME          ] := SA1->A1_NOME
	aEndPR[ nPos , POS_CGC           ] := SA1->A1_CGC
	If SA1->A1_PESSOA == "J"
		aEndPR[nPos,POS_CGC_FORMATADO] := Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
	Else
		aEndPR[nPos,POS_CGC_FORMATADO] := Transform(SA1->A1_CGC,"@R 999.999.999-99")
	EndIf
	aEndPR[ nPos , POS_INSCR         ] := SA1->A1_INSCR
	aEndPR[ nPos , POS_CEP           ] := SA1->A1_CEP
	aEndPR[ nPos , POS_END           ] := aAuxEnd[1] // SA1->A1_END
	aEndPR[ nPos , POS_COMPLEM       ] := AllTrim(AllTrim(aAuxEnd[4]) + " " + SA1->A1_COMPLEM)
	aEndPR[ nPos , POS_NUMERO        ] := aAuxEnd[3] // NUMERO
	aEndPR[ nPos , POS_TELEFONE      ] := AllTrim(AllTrim(SA1->A1_DDD) + " " + AllTrim(SA1->A1_TEL))
	aEndPR[ nPos , POS_COD_MUN       ] := Left(SA1->A1_IBGE,6)
	aEndPR[ nPos , POS_MUN           ] := SA1->A1_MUN
	aEndPR[ nPos , POS_DISTRITO      ] := SA1->A1_BAIRRO // BAIRRO
	aEndPR[ nPos , POS_EST           ] := SA1->A1_EST
	aEndPR[ nPos , POS_PAIS          ] := SA1->A1_PAIS
	aEndPR[ nPos , POS_EMAIL         ] := SA1->A1_EMAIL
	aEndPR[ nPos , POS_PESSOA        ] := SA1->A1_PESSOA
	aEndPR[ nPos , POS_RECNO         ] := SA1->(RecNo())
	aEndPR[ nPos , POS_SEL           ] := .f.
	aEndPR[ nPos , POS_TIPEND        ] := ""
	aEndPR[ nPos , POS_MUN_IGUAL     ] := .F.
	aEndPR[ nPos , POS_CXPOSTAL      ] := SA1->A1_CXPOSTA

//	SA1->(dbSkip())
//EndDo
	(cAliasSA1)->(dbSkip())
End
(cAliasSA1)->(dbCloseArea())

dbSelectArea("SA1")
RestArea(aAuxArea)

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Rubens Takahashi      ³ Data ³ 15/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratamento do menu aRotina							      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {}

aRotina := {{ STR0002 , "AxPesqui"    , 0 , 1 },; // Pesquisar
				{ STR0003 , "OFNJD20EXEC" , 0 , 4 },;  // Atualizar
				{ STR0025 , "OFNJD15PW"   , 0 , 3 }}   // Altera Senha


Return aRotina