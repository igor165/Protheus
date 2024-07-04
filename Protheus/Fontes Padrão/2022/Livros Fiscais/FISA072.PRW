#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA072.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA072
Cadastro de Codigos de Reflexos da Apuracao de ICMS

@author Luccas Curcio
@since 07/04/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA072()
Local   oBrowse

If AliasInDic('CE0')
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "CE0" )
	oBrowse:SetDescription( STR0001 ) //"Códigos de Reflexo - Apuração de ICMS"
	oBrowse:Activate()
Else
	Alert( STR0002 )	//"Tabela CE0 não existe no Dicionário de Dados!"
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return FWMVCMenu - Opcoes de menu

@author Luccas Curcio
@since 07/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef
Return FWMVCMenu( "FISA072" )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Luccas Curcio
@since 07/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef
Local oModel
Local oStruCE0 := FWFormStruct( 1 , "CE0" )

oModel	:=	MPFormModel():New( 'FISA072' , , { |oModel| X72VldForm( oModel ) } )
oModel:AddFields( 'FISA072' , , oStruCE0 )
oModel:SetPrimaryKey( { 'CE0_FILIAL' } , { 'CE0_CODIGO' } )
oModel:SetDescription( STR0001 ) //"Códigos de Reflexo - Apuração de ICMS"

oStruCE0:SetProperty( 'CE0_CODIGO' 	, MODEL_FIELD_WHEN		, {|| (oModel:GetOperation()==3) })
oStruCE0:SetProperty( 'CE0_PROPRI' 	, MODEL_FIELD_WHEN		, {|| (oModel:GetOperation()==3) })
oStruCE0:SetProperty( 'CE0_CODIGO' 	, MODEL_FIELD_OBRIGAT	, .T.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Luccas Curcio
@since 07/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef
Local oView		:= FWFormView():New()
Local oModel	:= FWLoadModel( 'FISA072' )
Local oStruCE0	:= FWFormStruct( 2 , 'CE0' )

oView:SetModel( oModel )
oView:AddField( 'VIEW_CE0' , oStruCE0 , 'FISA072' )
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_CE0' , 'TELA' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkCE0PK
Valida Primary Key do Modelo da tabela CE0

@return lRet -> Indica se a chave eh valida

@author Luccas Curcio
@since 07/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function X72VldForm( oModel )
Local lRet			:= .T.
Local cCodigo		:= oModel:GetValue ( 'FISA072' , 'CE0_CODIGO' )
Local cBase 		:= AllTrim(oModel:GetValue ( 'FISA072' , 'CE0_NFBASE' ))
Local cAliq         := AllTrim(oModel:GetValue ( 'FISA072' , 'CE0_NFALIQ' ))
Local cValor        := Alltrim(oModel:GetValue ( 'FISA072' , 'CE0_NFVALO' ))
Local lCE0_TRGEN    := CE0->(FieldPos("CE0_TRGEN")) > 0
Local cTrbGen       := IIf(lCE0_TRGEN, oModel:GetValue ( 'FISA072' , 'CE0_TRGEN' ), "")

If oModel:GetOperation() == MODEL_OPERATION_INSERT  //Inclusão

	DbSelectArea( 'CE0' )
	CE0->( DbSetOrder ( 1 ) )

	If CE0->( MsSeek( xFilial( 'CE0' ) + cCodigo ) )
		lRet := .F.
		Help("" , 1 , 'Help' , 'Help' , STR0003 , 1 , 0 ) //"Código de reflexo já cadastrado!"
	Endif

Endif

// Inclusão ou alteração
// Verifica se o tributo genérico foi informado caso tenha sido configurada a utilização de valores do mesmo
// em alguma das opções de base, alíquota ou valor.
If (lCE0_TRGEN .And. (oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE))

	If ((cBase $ "E|F" .Or. cAliq == "D" .Or. cValor == "N") .And. Empty(cTrbGen))
		lRet := .F.
		Help("" , 1 , 'Help' , 'Help' , STR0004 , 1 , 0 )	
	EndIf

EndIf

Return lRet


/*/{Protheus.doc} X72BRefelx
Função que irá retornar a lista do combo para o campo CE0_NFBASE
@author Rafael.soliveira
@since 21/11/2017
/*/
Function X72BRefelx()
Local cRet	:= ''
Local cCampo	:= "CE0_NFBASE"

if !FWIsInCallStack("FISA072") .OR. (FWIsInCallStack("VIEWDEF") .AND. FWIsInCallStack("MODELDEF")) //Se for dentro da rotina não altero a estrutua da string q sera apresentada
	cCampo:="" //Com o campo em branco não será alterado 
endif

cRet	+= X72AjusStr('1=Base ICMS;',cCampo)
cRet	+= X72AjusStr('2=Valor Contabil;',cCampo)
cRet	+= X72AjusStr('3=Valor do ICMS;',cCampo)
cRet	+= X72AjusStr('4=Base Sol.;',cCampo)
cRet	+= X72AjusStr('5=Frete Aut.;',cCampo)
cRet	+= X72AjusStr('6=Cred.Estimulo;',cCampo)
cRet	+= X72AjusStr('7=Base Destino Difal;',cCampo)
cRet	+= X72AjusStr('8=Base Original ICMS;',cCampo)
cRet	+= X72AjusStr('9=Base IPI;',cCampo)
cRet	+= X72AjusStr('A=Frete ST;',cCampo)
cRet	+= X72AjusStr('B=ICMS Frete ST;',cCampo)
cRet	+= X72AjusStr('C=Redução ICMS;',cCampo)
cRet	+= X72AjusStr('D=Base Calc.Feef;',cCampo)


//Somente adiciona a opção do tributi genérico se a tabela F2D existir e a função de cálculo também existir
If AliasIndic('F2D') .AND. FindFunction("xFisTrbGen")
	cRet	+= X72AjusStr('E=Base do Tributo Genérico;',cCampo)
	cRet	+= X72AjusStr('F=Valor do Tributo Genérico;',cCampo)
EndIF


cRet	+= X72AjusStr('G=Base ICMS Efetivo;',cCampo)
cRet	+= X72AjusStr('H=Valor do IPI;',cCampo)
cRet	+= X72AjusStr('I=Base ICMS Recolhido Anteriormente;',cCampo)
cRet	+= X72AjusStr('J=Base ICMS Desonerado ALC;',cCampo)
cRet	+= X72AjusStr('K=Base ICMS Desonerado ALC com desconto de PIS e COFINS;',cCampo)
cRet	+= X72AjusStr('Z=Zero',cCampo)


Return cRet

/*/{Protheus.doc} X72ARefelx
Função que irá retornar a lista do combo para o campo CE0_NFALIQ
@author Rafael.soliveira
@since 21/11/2017
/*/

Function X72ARefelx()
Local cRet		:= ''
Local cCampo	:= "CE0_NFALIQ"

if !FWIsInCallStack("FISA072") .OR. (FWIsInCallStack("VIEWDEF") .AND. FWIsInCallStack("MODELDEF")) //Se for dentro da rotina não altero a estrutua da string q sera apresentada
	cCampo:="" //Com o campo em branco não será alterado 
endif

cRet	+= X72AjusStr('1=Alq.ICMS;',cCampo)
cRet	+= X72AjusStr('2=Cred.Pres.;',cCampo)
cRet	+= X72AjusStr('3=Alq.Solid.;',cCampo)
cRet	+= X72AjusStr('4=Est.Cred.;',cCampo)
cRet	+= X72AjusStr('5=Alq.Compl.;',cCampo)
cRet	+= X72AjusStr('6=Informado;',cCampo)
cRet	+= X72AjusStr('7=Fecp;',cCampo)
cRet	+= X72AjusStr('8=Fecp-ST;',cCampo)
cRet	+= X72AjusStr('9=Alq.Compl./Simp.Nac.;',cCampo)
cRet	+= X72AjusStr('A=Alq.IPI;',cCampo)
cRet	+= X72AjusStr('B=Frete ST;',cCampo)
cRet	+= X72AjusStr('C=Alq. Feef;',cCampo)
//Somente adiciona a opção do tributi genérico se a tabela F2D existir e a função de cálculo também existir
If AliasIndic('F2D') .AND. FindFunction("xFisTrbGen")
	cRet	+= X72AjusStr('D=Tributo Genérico;',cCampo)
EndIF
cRet	+= X72AjusStr('E=Alq. ICMS Efetivo;',cCampo)
cRet	+= X72AjusStr('F=Alq.ICMS-Aliq.FECP;',cCampo)
cRet	+= X72AjusStr('G=Alíquota ICMS Recolhido Anteriormente;',cCampo)
cRet	+= X72AjusStr('H=Alíquota da antecipação do ICMS em operações internas;',cCampo)
cRet	+= X72AjusStr('I=Alíquota definida no Estado destino para cálculo do ICMS complementar;',cCampo)
cRet	+= X72AjusStr('Z=Zero',cCampo)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} X72VRefelx
Função que irá retornar a lista do combo para o campo CE0_NFVALO

@author Erick G Dias
@since 20/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function X72VRefelx()

Local cRet		:= ""
Local cCampo	:= "CE0_NFVALO"

if !FWIsInCallStack("FISA072") .OR. (FWIsInCallStack("VIEWDEF") .AND. FWIsInCallStack("MODELDEF")) //Se for dentro da rotina não altero a estrutua da string q sera apresentada
	cCampo:="" //Com o campo em branco não será alterado 
endif

cRet	+= X72AjusStr('1=ICMS;',cCampo)
cRet	+= X72AjusStr('2=Complem.;',cCampo)
cRet	+= X72AjusStr('3=Merc.;',cCampo)
cRet	+= X72AjusStr('4=Antecip.;',cCampo)
cRet	+= X72AjusStr('5=Crd.Pres.;',cCampo)
cRet	+= X72AjusStr('6=Solid.;',cCampo)
cRet	+= X72AjusStr('7=Est.Cred.;',cCampo)
cRet	+= X72AjusStr('8=Difer.;',cCampo)
cRet	+= X72AjusStr('9=Calc.;',cCampo)
cRet	+= X72AjusStr('A=Fecp;',cCampo)
cRet	+= X72AjusStr('B=Fecp-ST;',cCampo)
cRet	+= X72AjusStr('C=Fre.Aut.;',cCampo)
cRet	+= X72AjusStr('D=Dif.Dest.(Difal);',cCampo)
cRet	+= X72AjusStr('E=Dif.Orig.(Difal);',cCampo)
cRet	+= X72AjusStr('F=FECP (Difal);',cCampo)
cRet	+= X72AjusStr('G=Ajuste.ICMS.ST;',cCampo)
cRet	+= X72AjusStr('H=Antecipação Operações Subsequentes;',cCampo)
cRet	+= X72AjusStr('I=Ressarcimento;',cCampo)
cRet	+= X72AjusStr('J=ICMS - Crédito Presumido;',cCampo)
cRet	+= X72AjusStr('K=IPI;',cCampo)
cRet	+= X72AjusStr('L=Frete ST;',cCampo)
cRet	+= X72AjusStr('M=ICMS Reduzido;',cCampo)

//Somente adiciona a opção do tributi genérico se a tabela F2D existir e a função de cálculo também existir
If AliasIndic('F2D') .AND. FindFunction("xFisTrbGen")
	cRet	+= X72AjusStr('N=Tributo Genérico;',cCampo)
EndIF

cRet	+= X72AjusStr('O=Isentas/Não Trib;',cCampo)
cRet	+= X72AjusStr('P=Valor Contabil;',cCampo)
cRet	+= X72AjusStr('Q=Valor da coluna Outras;',cCampo)
cRet	+= X72AjusStr('R=Crédito Presumido Prodepe;',cCampo)
cRet	+= X72AjusStr('S=Valor Feef;',cCampo)
cRet	+= X72AjusStr('T=ICMS Recolhido Anteriormente;',cCampo)
cRet	+= X72AjusStr('U=Valor ICMS Efetivo;',cCampo)
cRet	+= X72AjusStr('V=ICMS + ICMS Solidário;',cCampo)
cRet	+= X72AjusStr('W=ICMS + ICMS Recolhido Anteriormente;',cCampo)
cRet	+= X72AjusStr('X=Credito Presumido do ICMS;',cCampo)
cRet	+= X72AjusStr('Y=ICMS Próprio - FECP;',cCampo)
cRet	+= X72AjusStr('Z=ICMS Desonerado Base Composta;',cCampo)
cRet	+= X72AjusStr('AA=ICMS ST Desonerado Base Composta;',cCampo)
cRet	+= X72AjusStr('AB=ICMS Desonerado ALC;',cCampo)
cRet	+= X72AjusStr('AC=ICMS Desonerado ALC com desconto de PIS e Cofins;',cCampo)
cRet	+= X72AjusStr('AD=Valor Outras - ICMS Recolhido Anteriormente;',cCampo)

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} X72AjusStr
Função para ajustar a string de acordo com o tamanho do campo, exemplo de utilização: 
	Tamanho do campo 2
	1=barbaridade; depois de passar na função 
	1 =barbaridade;

@parametros
cStr - String que será trabalhada
cCampo - Campo que verificaremos o tamanho
cOper - Operador utilizado para saber onde sera adicionado o espaço em branco

@author Matheus Massarotto
@since 12/02/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function X72AjusStr(cStr,cCampo,cOper)
Local cRet		:=""
Local aTamSx3	:= 0
Local nAt		:= 0 
Local oError    := ErrorBlock({|e| Conout("FISA072: " +e:Description +"- Filial " + FWGETCODFILIAL + " " + Time()+ "ERRORSTACK:"	+ Chr(10)+Chr(13) + e:ErrorStack , cRet:=cStr)})

Default cStr 	:= ""
Default cCampo	:= ""
Default cOper	:= "=" //Operador que será utilizado para buscar item na string

begin sequence //tratamento para não apresentar error log
	if !empty(cCampo) .and. !empty(cStr)
		aTamSx3:= TAMSX3(cCampo) //Tamanho do campo no X3
		cStr:= alltrim(cStr)

		if ValType(aTamSx3)=="A"
			if aTamSx3[1] > 0 .and. !empty(cStr) //Tamanho do campo
				nAt:= AT(cOper,cStr)-1 //Encontro a posição do operador na string
				
				cRet:=PADR(Substring(cStr,1,nAt),aTamSx3[1])+RIGHT(cStr,len(cStr)-nAt) //adiciono o espaço do tamanho do campo a direita do caracter antes do operador
			endif
		endif
	else
		cRet:=cStr
	endif
end sequence

ErrorBlock(oError) //Se der erro, chama o bloco de código, mostra no console o erro e atribui cRet:=cStr

Return(cRet)

