#INCLUDE "PROTHEUS.CH"
#INCLUDE "TAFOBRIGA.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCOModal

Interface para exibição das informações da Obrigação Fiscal.

@Param	aConteudos	-	Array com as informações da obrigação Fiscal

@Author	Vitor Ferreira
@Since
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFCOModal( aConteudos )

Local oModal		:=	Nil
Local oContainer	:=	Nil
Local oFontModal	:=	TFont():New( ,, 15, .T., .T. )
Local oSay1		:=	Nil
Local oSay2		:=	Nil
Local oSay3		:=	Nil
Local oSay4		:=	Nil
Local oSay5		:=	Nil
Local oSay6		:=	Nil
Local oSay7		:=	Nil
Local oMultiGet1	:=	Nil
Local oMultiGet2	:=	Nil
Local oMultiGet3	:=	Nil
Local oMultiGet4	:=	Nil
Local oMultiGet5	:=	Nil
Local oMultiGet6	:=	Nil
Local oMultiGet7	:=	Nil
Local cTexto1		:=	""
Local cTexto2		:=	""
Local cTexto3		:=	""
Local cTexto4		:=	""
Local cTexto5		:=	""
Local cTexto6		:=	""
Local cTexto7		:=	""

oModal := FWDialogModal():New()
oModal:SetEscClose( .T. )
oModal:SetTitle( STR0001 + " - " + aConteudos[1] ) // "Informações da Obrigação Fiscal"
oModal:SetFreeArea( 200, 250 )
oModal:SetBackground( .T. )
oModal:CreateDialog()

oContainer := TPanel():New( ,,, oModal:GetPanelMain() )
oContainer:Align := CONTROL_ALIGN_ALLCLIENT

oScroll := TScrollArea():New( oModal:oPanelMain, 01, 01, 240, 200 )
oScroll:SetFrame( oContainer )

oSay1		:=	TSay():New( 05,01, { || Space( 5 ) + STR0002 }, oContainer,, oFontModal,,,, .T.,,, 200, 20,,,,,, .T. ) //"Descrição Completa"
cTexto1	:=	Iif( !Empty( aConteudos[2] ), aConteudos[2], STR0009 ) //"Não se aplica."
oMultiGet1	:=	TMultiGet():New( 15, 05, { |u| Iif( PCount() > 0, cTexto1 := u, cTexto1 ) }, oContainer, 180, 22,, .T.,,,, .T.,,,,,, .T.,,,, .F., .T. )

oSay2		:=	TSay():New( 40, 01, { || Space( 5 ) + STR0003 }, oContainer,, oFontModal,,,, .T.,,, 200, 20,,,,,, .T. ) //"Destinatário"
cTexto2	:=	Iif( !Empty( aConteudos[3] ), aConteudos[3], STR0009 ) //"Não se aplica."
oMultiGet2	:=	TMultiGet():New( 50, 05, { |u| Iif( PCount() > 0, cTexto2 := u, cTexto2 ) }, oContainer, 180, 22,, .T.,,,, .T.,,,,,, .T.,,,, .F., .T. )

oSay3		:=	TSay():New( 75, 01, { || Space( 5 ) + STR0004 }, oContainer,, oFontModal,,,, .T.,,, 200, 20,,,,,, .T. ) //"Objetivo"
cTexto3	:=	Iif( !Empty( aConteudos[4] ), aConteudos[4], STR0009 ) //"Não se aplica."
oMultiGet3	:=	TMultiGet():New( 85, 05, { |u| Iif( PCount() > 0, cTexto3 := u, cTexto3 ) }, oContainer, 180, 22,, .T.,,,, .T.,,,,,, .T.,,,, .F., .T. )

oSay4		:=	TSay():New( 110, 01, { || Space( 5 ) + STR0005 }, oContainer,, oFontModal,,,, .T.,,, 200, 20,,,,,, .T. ) //"Prazo de Entrega"
cTexto4	:=	Iif( !Empty( aConteudos[5] ), aConteudos[5], STR0009 ) //"Não se aplica."
oMultiGet4	:=	TMultiGet():New( 120, 05, { |u| Iif( PCount() > 0, cTexto4 := u, cTexto4 ) }, oContainer, 180, 22,, .T.,,,, .T.,,,,,, .T.,,,, .F., .T. )

oSay5		:=	TSay():New( 145, 01, { || Space( 5 ) + STR0006 }, oContainer,, oFontModal,,,, .T.,,, 200, 20,,,,,, .T. ) //"App. Disp. pelo Fisco"
cTexto5	:=	Iif( !Empty( aConteudos[6] ), aConteudos[6], STR0009 ) //"Não se aplica."
oMultiGet5	:=	TMultiGet():New( 155, 05, { |u| Iif( PCount() > 0, cTexto5 >= u, cTexto5 ) }, oContainer, 180, 22,, .T.,,,, .T.,,,,,, .T.,,,, .F., .T. )

oSay6		:=	TSay():New( 180, 01, { || Space( 5 ) + STR0007 }, oContainer,, oFontModal,,,, .T.,,, 200, 20,,,,,, .T. ) //"Versão do Aplicativo"
cTexto6	:=	Iif( !Empty( aConteudos[7] ), aConteudos[7], STR0009 ) //"Não se aplica."
oMultiGet6	:=	TMultiGet():New( 190, 05, { |u| Iif( PCount() > 0, cTexto6 := u, cTexto6 ) }, oContainer, 180, 22,, .T.,,,, .T.,,,,,, .T.,,,, .F., .T. )

oSay7		:=	TSay():New( 215, 01, { || Space( 5 ) + STR0008 }, oContainer,, oFontModal,,,, .T.,,, 200, 20,,,,,, .T. ) //"Comentários"
cTexto7	:=	Iif( !Empty( aConteudos[8] ), aConteudos[8], STR0009 ) //"Não se aplica."
oMultiGet7	:=	TMultiGet():New( 225, 05, { |u| Iif( PCount() > 0, cTexto7 := u, cTexto7 ) }, oContainer, 180, 22,, .T.,,,, .T.,,,,,, .T.,,,, .F., .T. )

oModal:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCOWizOb

Rotina para criar Painéis da Obrigação Fiscal.

@Param	aPar	-	Array com informações necessárias para construção da Wizard

@Author	Vitor Ferreira
@Since
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFCOWizOb( aPar )

Local lRet	:=	.T.

aTxtApre	:=	aPar[1]
aPaineis	:=	aPar[2]
cNomWiz	:=	aPar[3]
cNomeAnt	:=	aPar[4]
nTamSay	:=	aPar[5]
lBackIni	:=	aPar[6]
bFinalExec	:=	aPar[7]

lRet := xFunWizard( aTxtApre, aPaineis, cNomWiz, cNomeAnt, nTamSay, lBackIni, bFinalExec )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCOVldOp

Rotina para certificar que apenas um elemento esteja selecionado
em um objeto de seleção.

@Param		oObj - Objeto a ser avaliado

@Author	Vitor Ferreira
@Since
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFCOVldOp( oObj )

Local nI	:=	0

For nI := 1 to Len( oObj:aArray )
	If nI <> oObj:nAt
		oObj:aArray[nI,1] := .F.
	EndIf
Next nI

oObj:Refresh()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCOVldOb

Rotina para verificar existência de elemento selecionado em um objeto.

@Param		oObj - Objeto a ser avaliado

@Author	Vitor Ferreira
@Since
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFCOVldOb( oObj )

Local nI			:=	0  
Local lRet			:=	.f. 
Local lRetSlcObr	:=	.f.
Local lRetProcDt	:=	.t.
Local lValProtDt	:=	.f.
Local cConcatMsg	:=	" "
Local cMsgErr2		:=	" "
Local cMsgErr1		:=	" "
Local cTitConcat	:=	" "
Local nTiti1		:=	" "
Local nTiti2		:=	" "
Local cMSgSoluc1	:=	" "
Local cMSgSoluc2	:=	" " 
Local cAlias 		:=	"C1H"
Local lMethod		:= .f.
DbSelectArea(cAlias) 

For nI := 1 to Len( oObj:aArray )    

	if oObj:aArray[nI][1] .and. FindFunction( "FindClass" )
		//lMethod	:= TAFFindClass("FwProtectedDataUtil") 
		lMethod	:= FindClass("FWPROTECTEDDATAUTIL") // a função FindClass está mtravando o sistema se escrita em minusculo 
		if lMethod
			lValProtDt := TafProtObrig(oObj:aArray[nI][2])  // Define se devo validar ou não a determinada obrigação      
		endif 
	EndIf 
	  
	If aScan( oObj:aArray[nI], .T. ) > 0  
		lRetSlcObr := .T. 
		If lValProtDt .and. Findfunction( "ProtData" ) .and. oObj:aArray[nI][1]  
			lRetProcDt := ProtData(.f.)
			if !lRetProcDt
				nTiti2		:=	STR0010 //"Dados Pessoais Sensíveis"
				cMsgErr2 	:= 	STR0011 //"Usuário sem permissão para acessar dados pessoais e/ou sensíveis!" 
				cMSgSoluc2 	:= 	STR0012 //"Solicite a liberação de acesso ao administrador do sistema"  
				cConcatMsg	+=	" "  
			Endif 	
		EndIf 
	EndIf
Next nI

lRet := (lRetSlcObr .and. lRetProcDt)
if !lRetSlcObr
	nTiti1		:=	STR0013//"Obrigação em Branco "
	cMsgErr1	:=	STR0014//"Nenhuma obrigação selecionada"	
	cMSgSoluc1 	:=	STR0015//"Por favor, selecione uma Obrigação"
	if !lRetProcDt
		cTitConcat	+=	" / "
		cConcatMsg	:=	STR0016//" e "
	Endif 
Endif 

if !lRet
	Help(,,nTiti1+cTitConcat+nTiti2,, alltrim(cMsgErr1+cConcatMsg+cMsgErr2), 1, 0,,,,,,{cMSgSoluc1+cConcatMsg+cMSgSoluc2}) 	   
Endif 	


Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCOAjSX1

Compatibilização de Wizard - SX1 para o Sintegra.

@Param	aParam	-	Array com os valores preenchidos na Wizard

@Author	Vitor Henrique
@Since
@Version	1.0

/*/
//-------------------------------------------------------------------
Function TAFCOAjSX1( aParam )

MV_PAR01 := aParam[1,3,1]
MV_PAR02 := aParam[1,4,1]
MV_PAR03 := aParam[1,9,1]
MV_PAR04 := aParam[1,10,1]
MV_PAR05 := aParam[1,15,1]

If aParam[1,16,1] == "Normal"
	MV_PAR06 := 1
ElseIf aParam[1,16,1] == "Ret. Total"
	MV_PAR06 := 2
ElseIf aParam[1,16,1] == "Total Rectif"
	MV_PAR06 := 3
EndIf

If aParam[1,21,1] == "Entrada"
	MV_PAR07 := 1
ElseIf aParam[1,21,1] == "Saida"
	MV_PAR07 := 2
ElseIf aParam[1,21,1] == "Ambas"
	MV_PAR07 := 3
EndIf

If aParam[1,22,1] == "Sim"
	MV_PAR08 := 1
ElseIf aParam[1,22,1] == "Não"
	MV_PAR08 := 2
EndIf

MV_PAR09 := aParam[1,27,1]

If aParam[1,28,1] == "Sim"
	MV_PAR10 := 1
ElseIf aParam[1,28,1] == "Não"
	MV_PAR10 := 2
EndIf

If aParam[1,33,1] == "Sim"
	MV_PAR11 := 1
ElseIf aParam[1,33,1] == "Não"
	MV_PAR11 := 2
EndIf

If aParam[1,34,1] == "Sim"
	MV_PAR12 := 1
ElseIf aParam[1,34,1] == "Não"
	MV_PAR12 := 2
EndIf

If aParam[1,39,1] == "Sim"
	MV_PAR13 := 1
ElseIf aParam[1,39,1] == "Não"
	MV_PAR13 := 2
EndIf

If aParam[1,40,1] == "Sim"
	MV_PAR14 := 1
ElseIf aParam[1,40,1] == "Não"
	MV_PAR14 := 2
EndIf

If aParam[1,45,1] == "Inter. ST"
	MV_PAR15 := 1
ElseIf aParam[1,45,1] == "Interestadual"
	MV_PAR15 := 2
ElseIf aParam[1,45,1] == "Totalidade"
	MV_PAR15 := 3
EndIf

If aParam[1,46,1] == "Sim"
	MV_PAR16 := 1
ElseIf aParam[1,46,1] == "Não"
	MV_PAR16 := 2
EndIf

If aParam[1,51,1] == "Sim"
	MV_PAR17 := 1
ElseIf aParam[1,51,1] == "Não"
	MV_PAR17 := 2
EndIf

Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} TafProtObrig

Valida se o usuário em questão tem a cesso a dados pessoais/senssíveis para a obrigação selecionada

@cIdObrig	cIdObrig	-	ID da obrigação em CHW

@Author	henrique.pereira
@Since 16/12/2019
@Version	1.0

/*/
//-------------------------------------------------------------------
Static Function TafProtObrig(cIdObrig) 
Local lRet 		as Logical
Local nAliasX	as numeric
Local aAlias 	as array 

Default cIdObrig := ''
 
lRet 	:= .f.
nAliasX	:= 0
aAlias 	:= {}

	Do case 
	Case cIdObrig == '000001'
		aAlias := StrTokArr("C1H|C20","|")

	Case cIdObrig == '000002'
		aAlias := StrTokArr("C0R|C1H","|")

	Case cIdObrig == '000003'
		aAlias := StrTokArr("C2J|C1H|C40|C5R|C6I|C4P|C2B|C2V|C5G|C26|C20|C3B|C32|C59","|")
		
	Case cIdObrig == '000004'
		aAlias := StrTokArr("C2J|C6I|C5R|C2B|C40|C1H|C20|C26|C37|C24|C38|C2V|C3M|LEQ|T86|C4U|C5B|T19|LEY|C4H|C32|C5K","|")

	Case cIdObrig == '000005'
		aAlias := StrTokArr("C2J|V1R|V3T|V1S|CAZ|CFX|CGM|CEM|CGO","|")

	Case cIdObrig == '000006'
		aAlias := StrTokArr("C1H|C2J","|")

	Case cIdObrig == '000007'
		aAlias := {"C2J"} //StrTokArr("C1H|C20","|")
	Case cIdObrig == '000008' //DFC - PR TAFXDFPR
		aAlias := StrTokArr("C1H|C2J","|")

	Case cIdObrig == '000009'
		aAlias := StrTokArr("C1H|C20","|")

	Case cIdObrig == '000010'
		aAlias := StrTokArr("C1H|C20","|")

	Case cIdObrig == '000012'
		aAlias := StrTokArr("C1H|C20","|")

	Case cIdObrig == '000015'
		aAlias := StrTokArr("C1H|C20","|")

	Case cIdObrig == '000017'
		aAlias := StrTokArr("C1H|C20","|")

	Case cIdObrig == '000018'
		aAlias := StrTokArr("C1H|C20","|")

	Case cIdObrig == '000019'
		aAlias := StrTokArr("C1H|C20","|")

	Case cIdObrig == '000020'	
		aAlias := StrTokArr("C1H|C20","|")
		
	EndCase 

	for nAliasX := 1 to Len(aAlias)
		lRet := Len(FwProtectedDataUtil():GetAliasFieldsInList(aAlias[nAliasX]) ) > 0
		if lRet
			exit 
		endif 
	next nAliasX	

Return lRet
