#DEFINE CRLF chr( 13 ) + chr( 10 )

#include "fileIO.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP1350
Importação PTU A1350

@author    Lucas Nonato
@since     14/12/2016
/*/
//------------------------------------------------------------------------------------------
Function PLSP1350()
Local aCoors		:=	FWGetDialogSize( oMainWnd )
Local oPanelMain, oFWLayer

Private oDlgPrinc
Private oRelacB5C
Private oBrwPrinc

Private aRet		:= {}

B5C->( dbSetOrder( 1 ) )

DEFINE MSDIALOG oDlgPrinc TITLE ".:: Importação PTU A1350 ::." FROM aCoors[ 1 ], aCoors[ 2 ] TO aCoors[ 3 ], aCoors[ 4 ] PIXEL

//--< Montagem da tela principal >---
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc,.F.,.T. )
	
	oFWLayer:AddLine( 'LIN_MAIN',100,.F. )
	oFWLayer:AddCollumn( 'COL_MAIN',100,.T.,'LIN_MAIN' )
	oPanelMain := oFWLayer:GetColPanel( 'COL_MAIN','LIN_MAIN' )
	
	//--< Browse Principal >---
	oBrwPrinc := FWMBrowse():New()
	oBrwPrinc:SetOwner( oPanelMain )
	oBrwPrinc:SetDescription( "Importação PTU A1350" )
	oBrwPrinc:SetAlias( "B5C" )
	oBrwPrinc:SetMenuDef( "PLSP1350" )
	oBrwPrinc:DisableDetails()
	oBrwPrinc:ForceQuitButton()
	oBrwPrinc:SetProfileID( '0' )
	oBrwPrinc:SetWalkthru( .F. )
	oBrwPrinc:SetAmbiente( .F. )

/*** CORES DISPONIVEIS PARA LEGENDA ***
GREEN	- Para a cor Verde
RED		- Para a cor Vermelha
YELLOW	- Para a cor Amarela
ORANGE	- Para a cor Laranja
BLUE	- Para a cor Azul
GRAY	- Para a cor Cinza
BROWN	- Para a cor Marrom
BLACK	- Para a cor Preta
PINK	- Para a cor Rosa
WHITE	- Para a cor Branca*/

oBrwPrinc:addLegend( "B5C_STATUS == '1'", "BLUE",	"Arquivo Importado" )
oBrwPrinc:addLegend( "B5C_STATUS == '2'", "ORANGE",	"Arquivo Auditado Parcial" )
oBrwPrinc:addLegend( "B5C_STATUS == '3'", "GREEN",	"Arquivo Auditado Completo" )

oBrwPrinc:Activate()

activate msDialog oDlgPrinc Center
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef - MVC

@author    Lucas Nonato
@since     14/12/2016
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
	
	ADD OPTION aRotina Title 'Importar'		Action 'PLImp1350'  OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina Title 'Auditar'		Action 'PLSPMA1350'	OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina Title 'Excluir'		Action 'PLExc1350'	OPERATION MODEL_OPERATION_INSERT ACCESS 0
	
Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    Lucas Nonato
@since     14/12/2016
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oStruB5C := FWFormStruct( 1,'B5C',/*bAvalCampo*/,/*lViewUsado*/ )
Local oModel
	
	//--< DADOS DO LOTE >---
	oModel := MPFormModel():New( 'PTU A1350' )
	oModel:AddFields( 'MODEL_B5C',,oStruB5C )
		
	oModel:SetDescription( "Importação PTU A1350" )
	oModel:GetModel( 'MODEL_B5C' ):SetDescription( ".:: Importação PTU A1350 ::." ) 
	//oModel:SetPrimaryKey( { "B5C_FILIAL","B5C_SUSEP","B5C_CMPLOT","B5C_NUMLOT","B5C_NMAREN" } )
Return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef - MVC

@author    Lucas Nonato
@since     14/12/2016
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView     := nil
	Local oModel	:= FWLoadModel( 'PLSP1350' )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
Return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLImp1350
Processa importação do arquivo

@author    Lucas Nonato
@since     14/12/2016
/*/
//------------------------------------------------------------------------------------------
Function PLImp1350()
Local cErro 	:= ""
Local cAviso 	:= ""
Local cTitulo	:= "Importar arquivo XML - PTU A1350"
Local aRet		:= {}
Local aPergs	:= {}
Local cRootPath := ""
Local cFilePath	:= space( 250 )
Local cArq 		:= ""

aAdd(aPergs,{ 6,"Buscar arquivo",cFilePath,"","","",60,.T.,"Arquivos XML |*.XML"})

paramBox( aPergs,cTitulo,aRet,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSA1350X1',/*lCanSave*/.T.,/*lUserSave*/ ) 

If ( len( aRet ) > 0 ) 
	valPathPTU( @cErro )
	
	If Empty(cErro)
		// O nome do arquivo deve seguir o padrão CBddmmaas.uuu onde CB eh fixo indicando Cadastro do Beneficiário (atualização).
		If !("CB" $ UPPER(AllTrim(substr(aRet[1], rAt("\", aRet[1]) + 1, len(aRet[1]) - rAt("\", aRet[1]))))) 
			ApMsgInfo("Arquivo Inválido.")
			Return
		EndIf
		
	Else
		MsgAlert(cErro)
		Return
	EndIf  
	If (valXml1350( aRet[ 1 ], @cErro, @cAviso ) )
	    oProcess := msNewProcess():New( { | lEnd | PlProA1350( @lEnd,AllTrim(aRet[ 1 ]) ) } , "Processando" , "Aguarde..." , .F. )
	    oProcess:Activate()	 
   EndIf
EndIf
	
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlProA1350
Processa PTU A1350

@author    Lucas Nonato
@since     18/08/2016
/*/
//------------------------------------------------------------------------------------------
Static Function PlProA1350( lEnd,cArq )
Local nTotReg	:= 0
Local nX		:= 0

Local cError	:= ""
Local cWarning	:= ""
Local cNameSpace:= "_MI_"
Local cCodB5C 	:= GETSX8NUM("B5C","B5C_CODIGO")
Local cPath 	:= "\PLSPTU\"
Local cNameArq	:= AllTrim(SubStr(cArq, rAt("\", cArq) + 1, len(cArq) - rAt("\", cArq)))
Local cArqTmp	:= ""
Local cCodUni	:= ""
Local cIdBen	:= ""
Local cNomComp	:= ""
Local cNomSoc	:= ""
Local cNomMae	:= ""
Local cDatNasc	:= ""
Local cTpSexo	:= ""
Local cEstCiv	:= ""
Local cCpf		:= ""
Local cRG		:= ""
Local cOrgEmi	:= ""
Local cCodPais	:= ""
Local cCNS		:= ""
Local cPIS		:= ""
Local cMunPe	:= ""
Local cIndRes	:= ""
Local cTipEnd	:= ""
Local cTipLog	:= ""
Local cDesLog	:= ""
Local cNumLog	:= ""
Local cCompLog  := ""
Local cBairro	:= ""
Local cMunBen   := ""
Local cNumCep	:= ""
Local cTipTel	:= ""
Local cNumDDD	:= ""
Local cNumTel	:= ""
Local cTpEmail 	:= ""
Local cEmail	:= ""
Local cValue	:= ""

Local lUnico	:= .F.

Local bBen    := {||Iif(lUnico,"","["+cValtoChar(nX)+"]")}

oObjXml	:= nil
DEFAULT lEnd	:= .F.

B5C->(dbSetOrder(1)) // B5C_FILIAL+B5C_CODIGO
B5D->(dbSetOrder(1)) // B5D_FILIAL+B5D_CODIGO+B5D_CODINT+B5D_MATRIC

If( lEnd )
	MsgAlert( 'Execução cancelada pelo usuário.' )
	Return
EndIf
		
If( cpyT2S( cArq, cPath ) )
	cArqTmp := cPath + substr( cArq,rat( "\",cArq ) + 1 )	
EndIf

oObjXml := XmlParserFile( cArqTmp, "", @cError, @cWarning )
If !Empty(cError)
	MsgAlert(cError)
	Return
EndIf

B5C->(RecLock('B5C', .T.))
		B5C->B5C_FILIAL	:= xFilial( "B5C" ) // Filial
		B5C->B5C_CODIGO	:= cCodB5C 	 		// Codigo
		B5C->B5C_STATUS	:= "1"				// Status
		B5C->B5C_NOMARQ	:= cNameArq			// Nome Arquivo
B5C->(MsUnlock())

//Define a regra caso tenha somente um beneficiario enviado
If Type("oObjXml:"+cNameSpace+"mensagemXML:"+cNameSpace+"corpoMensagem:"+cNameSpace+"mensagemEnvio:"+cNameSpace+"dadosBeneficiarios:TEXT") <> "U"
	cValue := "classDataArr(oObjXml:"+cNameSpace+"mensagemXML:"+cNameSpace+"corpoMensagem:"+cNameSpace+"mensagemEnvio)"
	lUnico := .T.
Else
	cValue := "oObjXml:"+cNameSpace+"mensagemXML:"+cNameSpace+"corpoMensagem:"+cNameSpace+"mensagemEnvio:"+cNameSpace+"dadosBeneficiarios"
EndIf

If  Type("oObjXml:"+cNameSpace+"mensagemXML:"+cNameSpace+"corpoMensagem:"+cNameSpace+"mensagemEnvio:"+cNameSpace+"dadosBeneficiarios") <> "U" .And. ;
	   	 	(nTot := Iif(lUnico,len( &cValue ) - 3,len( &cValue )) ) >= 1
	
	For nX := 1 to nTot
		
		// Dados Pessoa
		cCodUni		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosPessoa\codigoUnimed")
		cIdBen		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosPessoa\idBenef")
		cNomComp	:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosPessoa\nomeCompletoBeneficiario")
		cNomSoc		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosPessoa\nomeSocial")
		cNomMae		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosPessoa\nomeMaeBeneficiario")
		cDatNasc	:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosPessoa\dataNascimentoBeneficiario")
		cTpSexo		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosPessoa\tipoSexo")
		cEstCiv		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosPessoa\codigoEstadoCivil")
		cCpf		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosPessoa\codigoCPF")
		cRG			:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosPessoa\codigoRG")
		cOrgEmi		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosPessoa\orgaoEmissor")
		cCodPais	:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosPessoa\codigoPais")
		cCNS		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosPessoa\codigoNacionalSaude")
		cPIS		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosPessoa\pisPasep")
		cMunPe		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosPessoa\codigoMunicipal")
		 
		 // Endereco Beneficiario		
		cIndRes		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\enderecoBeneficiario\indicaResidencia")
		cTipEnd		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\enderecoBeneficiario\tipoEndereco")
		cTipLog		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\enderecoBeneficiario\tipoLogradouro")
		cDesLog		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\enderecoBeneficiario\descricaoLogradouro")
		cNumLog		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\enderecoBeneficiario\numeroLogradouro")
		cCompLog	:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\enderecoBeneficiario\complementoLogradouro")
		cBairro		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\enderecoBeneficiario\descricaoBairro")		
		cMunBen		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\enderecoBeneficiario\codigoMunicipal")
		cNumCep		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\enderecoBeneficiario\numeroCep")		
		 
		 //Dados Contato Beneficiario
		cTipTel		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosContatoBeneficiario\tipoTelefone")
		cNumDDD		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosContatoBeneficiario\numeroDDD")
		cNumTel		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosContatoBeneficiario\numeroTelefone")
		cTpEmail	:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosContatoBeneficiario\tipoEmail")
		cEmail		:= PLRetTagWB(oObjXml,cNameSpace,"mensagemXML\corpoMensagem\mensagemEnvio\dadosBeneficiarios"+Eval(bBen)+ "\dadosContatoBeneficiario\enderecoEmail")
		
		B5D->(RecLock('B5D', .T.))
			B5D->B5D_FILIAL	:= xFilial( "B5D" ) 	// Filial
			B5D->B5D_CODIGO	:= cCodB5C 	 			// Codigo
			B5D->B5D_CODINT	:= PadL(cCodUni,4,'0')	// Cod Unimed
			B5D->B5D_MATRIC	:= PadL(cIdBen,13,'0') 	// Matricula
			B5D->B5D_NOMBEN	:= cNomComp				// Nome Completo
			B5D->B5D_NOMSOC	:= cNomSoc	        	// Nome Social
			B5D->B5D_NOMMAE	:= cNomMae				// Nome Mãe Beneficiario
			B5D->B5D_DTNASC	:= SToD(cDatNasc)		// Data Nascimento Beneficiario
			B5D->B5D_SEXO	:= cTpSexo				// Tipo Sexo
			B5D->B5D_ECIVIL	:= cEstCiv	        	// Cod Estado Civil
			B5D->B5D_CPF	:= cCpf					// CPF
			B5D->B5D_IDENTI	:= cRG		        	// RG
			B5D->B5D_ORGEMI	:= cOrgEmi				// Orgao Emissor
			B5D->B5D_CDPAIS	:= cCodPais	        	// Codigo Pais
			B5D->B5D_CDCNS	:= cCNS					// CNS
			B5D->B5D_CDPIS	:= cPIS		        	// PIS
			B5D->B5D_NATMUN	:= cMunPe				// Cod Mun
			B5D->B5D_INDRES	:= cIndRes	       		// Indica Residencia
			B5D->B5D_TPENDE	:= cTipEnd				// Tipo Endereco
			B5D->B5D_TPLOGR	:= cTipLog	        	// Tipo Logradouro
			B5D->B5D_LOGRAD	:= cDesLog				// Descricao Logradouro
			B5D->B5D_NUMRES	:= cNumLog	        	// Numero Logradouro
			B5D->B5D_COMPLE	:= cCompLog				// Complento Logradouro
			B5D->B5D_BAIRRO	:= cBairro	        	// Descricao Bairro			
			B5D->B5D_MUNRES	:= cMunBen	        	// Cod Mun
			B5D->B5D_CEP	:= cNumCep				// Cep
			B5D->B5D_TPFONE	:= cTipTel				// Tipo Tel
			B5D->B5D_DDD	:= cNumDDD	        	// DDD
			B5D->B5D_NUMTEL	:= cNumTel				// Telefone
			B5D->B5D_TPEMAIL:= cTpEmail         	// Tip Email
			B5D->B5D_EMAIL	:= cEmail	        	// Email
		B5D->(MsUnlock())		
		 					
	Next   
EndIf

If( fErase( cArqTmp ) == -1 )	//--< EXCLUI ARQUIVO TEMPORARIO >---
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "[ERRO]: PLSP1350 - falha na exclusao do arquivo temporario: '" + cArqTmp + "'"   , 0, 0, {})
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PlExc1350
Trata a exclusão de uma importacao
@author Lucas Nonato
@since 	13/12/2016
@version P11
/*/
//-------------------------------------------------------------------

Function PlExc1350
Local cChave    := B5C->B5C_CODIGO


If !MsgYesNo("Confirma a exclusão de todos os itens importados do XML " + AllTrim(B5C->B5C_NOMARQ) + " ? ")
	Return()
EndIf

If B5C->B5C_STATUS <> '1'
	MsgInfo("Não será possível a exclusão. Os itens ja foram auditados!.")
	Return
Endif

Begin Transaction

B5C->(dbSetOrder(1)) // B5C_FILIAL+B5C_CODIGO
B5D->(dbSetOrder(1)) // B5D_FILIAL+B5D_CODIGO+B5D_CODINT+B5D_MATRIC
If 	B5C->(MsSeek(xFilial('B5C') + cChave)) 
	B5C->(RecLock("B5C",.F.))
	B5C->(DbDelete())
	B5C->(MsUnLock())
EndIf

While B5D->(MsSeek(xFilial('B5D') + cChave)) 
	B5D->(RecLock("B5D",.F.))
	B5D->(DbDelete())
	B5D->(MsUnLock())
EndDo

End Transaction

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} valPathPTU
Valida Estrutura de Pastas \plsptu\A1350\schemas

@author    Francisco Edcarlo
@since     15/12/2016
/*/
//------------------------------------------------------------------------------------------
static Function valPathPTU(cErro)
local cRootPath  := ""
If !ExistDir( "\plsptu")
	If MakeDir( "\plsptu") != 0  
	  cErro := "Não foi possivel criar o diretorio " + "\plsptu"     
	EndIf
EndIf    
If !ExistDir( "\plsptu\A1350")
	If MakeDir( "\plsptu\A1350") != 0  
	  cErro := "Não foi possivel criar o diretorio " + "\plsptu\A1350"     
	EndIf
EndIf 
If !ExistDir( "\plsptu\A1350\schemas")  
	If MakeDir("\plsptu\A1350\schemas") != 0  
	  cErro := "Não foi possivel criar o diretorio " + "\plsptu\A1350\schemas"     
	EndIf
EndIf 
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} valXml1350
Valida schema do arquivo XML 1350

@author    Francisco Edcarlo
@since     15/12/2016
/*/
//------------------------------------------------------------------------------------------
static Function valXml1350(cFilePath, cErro, cAviso)
local cPath1350 	:= "\plsptu\A1350\schemas\"
local cXml 			:= ""
local cSchemaMiT 	:= "mi_Transacoes-" + GetNewPar("MV_PT1350V","V1_00_00") + ".xsd"
local cSchemaSim 	:= "mi_SimpleTypes-" + GetNewPar("MV_PT1350V","V1_00_00") + ".xsd"
local cSchemaCom 	:= "mi_ComplexTypes-" + GetNewPar("MV_PT1350V","V1_00_00") + ".xsd"
local cNomArq 	:= AllTrim(substr(cFilePath, rAt("\", cFilePath) + 1))
local cPath		:= "\plsptu\A1350\"
local cArqTemp	:= cPath + cNomArq
local lRet			:= .T.
cErro := "Arquivo de schema não encontrado: "
Do Case
	Case !File(cPath1350 + cSchemaMiT, 0, .T.)
		cErro := cErro + cSchemaMiT
	Case !File(cPath1350 + cSchemaSim, 0, .T.)
		cErro := cErro + cSchemaSim
	Case !File(cPath1350 + cSchemaCom, 0, .T.)
		cErro := cErro + cSchemaCom
	OtherWise
		cErro := ""
EndCase

If Empty(cErro)
	If( cpyT2S( cFilePath, cPath ) )
		B5C->(dbSetOrder(2))
		If B5C->(MsSeek(xFilial( "B5C" ) + cNomArq ))
			MsgAlert("Arquivo já importado")
			lRet := .F.
		ElseIf (!XmlFVldSch( cArqTemp, "\plsptu\A1350\schemas\" + cSchemaMiT, @cErro,@cAviso))
		if( msgYesNo( "Existem erros na validação do arquivo XML. Deseja salvar o arquivo de LOG?" ) )
			aErrors := strTokArr( cErro,CRLF )
			geraLogErro( cErro )
		endIf
		lRet := .F.
	EndIf
		If( fErase( cArqTemp ) == -1 )	//--< EXCLUI ARQUIVO TEMPORARIO >---
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "[ERRO]: PLSP1350 - falha na exclusao do arquivo temporario: '" + cArqTemp + "'"   , 0, 0, {})
		EndIf
	EndIf
Else
	lRet := .F.
	MsgAlert(cErro)
EndIf
Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraLogErro
Grava arquivo de log

@author    Jonatas Almeida
@version   1.xx
@since     8/09/2016
@param     cError = lista de erros encontrados

/*/
//------------------------------------------------------------------------------------------
static function geraLogErro( cError )
	local cMascara	:= "Arquivos .LOG | *.log"
	local cTitulo	:= "Selecione o local"
	local nMascpad	:= 0
	local cRootPath	:= ""
	local lSalvar	:= .F.	//.F. = Salva || .T. = Abre
	local nOpcoes	:= nOR( GETF_LOCALHARD,GETF_ONLYSERVER,GETF_RETDIRECTORY )
	local l3Server	:= .T.	//.T. = apresenta o árvore do servidor || .F. = não apresenta
	local cAnoComp	:= allTrim( str( year( dDataBase ) ) )
	local cMesComp	:= allTrim( strZero( month( dDataBase ),2 ) )
	local cNomeArq	:= cAnoComp + cMesComp + strTran( allTrim( time() ),":","_" ) + ".log"
	local cPathLOG	:= ""

	cPathLOG	:= cGetFile( cMascara,cTitulo,nMascpad,cRootPath,lSalvar,nOpcoes,l3Server )
		If !Empty(cPathLOG)
			nArqLog		:= fCreate( cPathLOG+cNomeArq,FC_NORMAL )	
			fWrite( nArqLog,cError )
			fClose( nArqLog )	
			MsgAlert( "Arquivo de log gerado com sucesso. (" + cNomeArq + ")" )
		EndIF
return
/**/