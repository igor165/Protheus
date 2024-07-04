#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA117.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA117
Cadastro de Códigos Extras utilizado na GNRE Web Service

@author Simone Oliveira
@since 24/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
function FISA117()

local oBrw := FWmBrowse():New()

private oRetorno := Nil

dbselectarea("F0N")
If  AliasIndic("F0N")
	oBrw := FWMBrowse():New()
	oBrw:SetAlias("F0N")
	oBrw:SetDescription(STR0001) //Cadastro Informações Extras GNRE WS
	oBrw:activate()
else
	help("",1,"Help","Help",STR0002,1,0) //Tabela F0N não cadastrada no sistema!
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Simone Oliveira
@since 24/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
static function MenuDef()

local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.FISA117'	OPERATION  2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'		ACTION 'VIEWDEF.FISA117'	OPERATION  3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'		ACTION 'VIEWDEF.FISA117'	OPERATION  4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'		ACTION 'VIEWDEF.FISA117'	OPERATION  5 ACCESS 0
	ADD OPTION aRotina TITLE 'Importar'		ACTION 'ImpCad()'			OPERATION  3 ACCESS 0
	ADD OPTION aRotina TITLE 'Sincronizar'	ACTION 'SincrInfExtra()'	OPERATION 10 ACCESS 0
	ADD OPTION aRotina TITLE 'Wiz. Config.'	ACTION 'Fisa117CFG()'		OPERATION  1 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Simone Oliveira
@since 25/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
static function ModelDef()

local oStru	:=	FWFormStruct(1, 'F0N')
local oModel 	:=	MPFormModel():New('FISA117')

	oModel	:=	MPFormModel():New('FISA117MOD', ,{ |oModel| ValidForm(oModel) }  )
	
	oModel:AddFields( 'FISA117MOD' ,, oStru )	   
	
	oModel:SetPrimaryKey({"F0N_FILIAL"},{"F0N_UF"},{"F0N_CODREC"},{"F0N_AMBWS"},{"F0N_TITULO"})
	
	oModel:SetDescription("Informações Extras GNRE WS") 
	
return oModel   

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Simone Oliveira
@since 25/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
static function ViewDef()

local	oModel	:=	FWLoadModel('FISA117')
local	oStru		:=	FWFormStruct(2, 'F0N')
local	oView 	:=	FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW', oStru, 'FISA117MOD')

oView:EnableTitleView('VIEW', STR0001) //Cadastro Informações Extras GNRE WS
oView:CreateHorizontalBox('FIELDS', 100)
oView:SetOwnerView('VIEW', 'FIELDS')

return oView   

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Validacao das informacoes digitadas no form.

@author Simone dos Santos de Oliveira
@since 25/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
static function ValidForm(oModel)

local lRet			:=	.T.
local cUF			:=	oModel:GetValue ('FISA117MOD','F0N_UF')
local cCodRec		:=	alltrim(oModel:GetValue ('FISA117MOD','F0N_CODREC'))
local cAmbiente		:=	alltrim(oModel:GetValue ('FISA117MOD','F0N_AMBWS'))
local cTitulo		:=	alltrim(oModel:GetValue ('FISA117MOD','F0N_TITULO'))        
local nOperation 	:=	oModel:GetOperation()

	if nOperation == 3  //Inclusão de informações ou alterações. 
	
		dbselectarea ("F0N")
		F0N->(dbsetorder(1))

		if F0N->(dbseek(xFilial("F0N")+cUF+cCodRec+cAmbiente+cTitulo))			
			lRet := .F.			
			Help("",1,"Help","Help",STR0003,1,0) //Informações já cadastradas! Se necessário, realize uma alteração.
		endif    
  	elseif nOperation == 4  //Alteração                   
	   	RecLock("F0N")
		F0N->F0N_ATUALI:= "3" 
		F0N->F0N_DTATLZ	:= date()	 	
		F0N->(MsUnlock())
	endif

return lRet   

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpCad
Importação da tabela csv.

@author Simone dos Santos de Oliveira
@since 25/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
function ImpCad()

local bExec
local oDlg
local oRadio
local nOpcf		:= 0
local nRadio	:= 1
local cFile		:= ''
local cType		:= ''
local nBcoHdl	:= 0

DEFINE MSDIALOG oDlg FROM  94,1 TO 223,293 TITLE OemToAnsi(STR0004) PIXEL //Importação da Tabela de Inf. Extras Gnre WS

@ 07,07 TO 38, 139 OF oDlg  PIXEL

@ 14,19 Say OemToAnsi(STR0005) SIZE 170,9 OF oDlg PIXEL  //Campos extras que devem ser preenchidos para
@ 22,19 Say OemToAnsi(STR0006) SIZE 120,9 OF oDlg PIXEL  //as devidas receitas conforme layout GNRE.

DEFINE SBUTTON FROM 45, 080 TYPE 1 ENABLE OF oDlg ACTION(ChangeFile(.T.,@cFile) , nOpcf := 1, oDlg:End())
DEFINE SBUTTON FROM 45, 113 TYPE 2 ENABLE OF oDlg ACTION(oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcf == 1
	Processa({|| AtuF0N(cFile)},'Processando....')
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuF0N
Importação da Tabela de Inf. Extras Gnre WS

@author Simone dos Santos de Oliveira
@since 26/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
static function AtuF0N(cFile)

local aCSVFile 		:= {} 
local bOldError		:= ErrorBlock( {|x| VerErro(x) } ) // muda code-block de erro 
local cRootPath 	:= StrTran(GetSrvProfString("RootPath","")+IIf(!IsSrvUnix(),"\","/"),IIf(!IsSrvUnix(),"\\","//"),IIf(!IsSrvUnix(),"\","/"))
local cDescErro		:= ''   // Variavel para tratamento de erro
local cDrive		:= '' 	// Resultado: "c:"
local cDir			:= ''   // Resultado: "\path\"
local cNomeArq		:= ''   // Resultado: "arquivo"
local cExt			:= ''   // Resultado: ".ext" 
local cAmbWS		:= '' 
local cUF 			:= '' 
local cCodRec		:= '' 
local cObrigat 		:= ''  
local cCódigo		:= ''  
local cTipo			:= '' 
local cTamanho		:= '' 
local cDecimal		:= '' 
local cTitulo  		:= '' 
local cCodInt		:= ''
local cAtualiza		:= ''
local dDataAtu		:= date()
local nRegs			:= 0 
local nX 			:= 0  

//Verifica se a tabela F0N existe     
If  !AliasIndic("F0N")
	MSGStop(STR0007, STR0008) //Tabela de Cadastro Informações Extras GNRE WS (F0N) ainda não foi criada, atualize o Dicionário de Dados.###Atualização Cadastro Informações Extras GNRE WS
	return .F.
endif	

//Grava o arquivo CSV em array
aCSVFile	:= CFG57Csv(cFile)
nRegs		:= Len(aCSVFile)
if nRegs == 0
	MSGStop(STR0009, STR0008) //Arquivo com dados Informações Extras não encontrado!###Atualização Cadastro Informações Extras GNRE WS
	Return .F.
EndIf

if len(aCSVFile[1]) <> 10
	MSGStop(STR0010, STR0008) //Estrutura do Arquivo Informações Extras Incorreta!###Atualização Cadastro Informações Extras GNRE WS
	return .F.
endif

//Importação
procregua(nRegs)                

//Processa arquivo 
begin Transaction
	begin sequence    		
		for nX := 2 to  len(aCSVFile)     					
			incproc("Processando Registro : "+  alltrim(str(nX)) + ' do arquivo '  + cFile)	 
				
				cAmbWS	:= alltrim( aCSVFile[nX][1] )
				cUF 	:= alltrim( aCSVFile[nX][2] )
				cCodRec	:= alltrim( aCSVFile[nX][3] )
				cObrigat:= alltrim( aCSVFile[nX][4] ) 
				cCódigo	:= alltrim( aCSVFile[nX][5] ) 
				cTipo	:= substr(alltrim( aCSVFile[nX][6] ),1,1)
				cTamanho:= alltrim( aCSVFile[nX][7] )
				cDecimal:= alltrim( aCSVFile[nX][8] )
				cTitulo	:= upper(alltrim( aCSVFile[nX][9] ))   
				
				//Tratamento para código interno 
				cTitulo	:= NoAcento( Upper(cTitulo) )  
				
				cCodInt := RetCodInt( cTitulo )
											
				F0N->(dbsetorder(1))
				if !F0N->(dbseek(xFilial('F0N') + cUF + cCodRec + cAmbWS + cTitulo))
					RecLock('F0N',.T.)                             
						F0N->F0N_FILIAL	:= xFilial('F0N')
						F0N->F0N_UF		:= cUF
						F0N->F0N_CODREC	:= cCodRec
						F0N->F0N_AMBWS	:= cAmbWS		
						F0N->F0N_CODSEF	:= cCódigo
						F0N->F0N_TIPO	:= cTipo
						F0N->F0N_TAMANH := cTamanho
						F0N->F0N_DECIMA := cDecimal
						F0N->F0N_TITULO	:= cTitulo
						F0N->F0N_OBRIGA := cObrigat
						F0N->F0N_CODINT	:= cCodInt
						F0N->F0N_DTATLZ	:= dDataAtu
						F0N->F0N_ATUALI := '1' 			//Atualizado por: 1-Importação # 2-TSS # 3-Usuário
					F0N->(MsUnlock())	
				else	                               
					//Verifico se foi alterado ou incluso pelo usuário, caso tenha sido não será atualizado.
					if F0N->F0N_ATUALIZ <> '3'  
					
						RecLock('F0N',.F.)
							F0N->F0N_CODSEF	:= cCódigo
							F0N->F0N_TIPO	:= cTipo
							F0N->F0N_TAMANH := cTamanho
							F0N->F0N_DECIMA := cDecimal
							F0N->F0N_OBRIGA := cObrigat
							F0N->F0N_CODINT	:= cCodInt
							F0N->F0N_DTATLZ	:= dDataAtu
							F0N->F0N_ATUALI := '1'		 //Atualizado por: 1-Importação # 2-TSS # 3-Usuário
						F0N->(MsUnlock())  
				    endif
				endif						
		next
		MSGINFO(STR0011, STR0008) //Importação da Tabela concluída!Estrutura do Arquivo Informações Extras Incorreta!###Atualização Cadastro Informações Extras GNRE WS
		recover		
		DisarmTransaction() //Caso tenha ocorrido erro a transaçao sera desfeita
		MSGStop(STR0012 , STR0008) //Ocorreu erro na transação de importação.###Atualização Cadastro Informações Extras GNRE WS
	end sequence
	ErrorBlock(bOldError)
end Transaction 

// limpando Array
aCSVFile := aSize(aCSVFile,0)
aCSVFile := nil

return .T.       

//-------------------------------------------------------------------
/*/{Protheus.doc} VerErro
Rotina analizadora do erro
/*/
//-------------------------------------------------------------------
static function VerErro(e)

local cDescErro := ''

if e:gencode > 0  
	cDescErro := 'DESCRIPTION: ' + e:DESCRIPTION + Chr(10)+Chr(13)
  	cDescErro += 'ERRORSTACK:'	+ Chr(10)+Chr(13)  
  	cDescErro += e:ERRORSTACK
	Alert(Alltrim(cDescErro))
  	return .F.
endif

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ChangeFile
Escolhe arquivo
/*/
//-------------------------------------------------------------------
static function ChangeFile(lOpen,cFile)

local cFileChg       

default lOpen := .T.

cType    	:= oemtoansi('CSV|')+'*.CSV'
cFileChg	:= cGetFile(cType, oemtoansi( STR0008 ), 1,, lOpen, 1+16+32, .T.) //Atualização Cadastro Informações Extras GNRE WS

if empty(cFileChg)
	cFile := ''
	return 
endif

if '.'$cFileChg
	cFileChg := substr(cFileChg,1,rat('.', cFileChg)-1)
endif

cFileChg    := alltrim(cFileChg)
cFile       := Alltrim(cFileChg+Right(cType,4))

return

//-------------------------------------------------------------------
/*/{Protheus.doc} SincrInfExtra
Importação da Tabela de Inf. Extras Gnre WS

@author Simone dos Santos de Oliveira
@since 26/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
function SincrInfExtra()

local cURL      := Padr(GetNewPar('MV_SPEDURL','http://'),250)  

if IsReadyGNRE( cURL )    //Verifico comunicação com TSS
	
	TssSincroniza(cURL)	
   
else
	//Realiza a configuração do Wizard TSS 
	Fisa117CFG()  
	
endif          

return         

//-------------------------------------------------------------------
/*/{Protheus.doc} TssSincroniza
Busca sincronização através do TSS.

@author Simone dos Santos de Oliveira
@since 27.02.2015
@version 1.0

/*/
//-------------------------------------------------------------------
static function TssSincroniza(cURL)

local aPerg   	:= {}
local aInfAdic	:= {}
local aParam  	:= {Space(Len(F0N->F0N_UF)),Space(Len(F0N->F0N_CODREC)),Space(Len('2-Homologação'))}

local cVerTSS	:= ''  
local cTitulo	:= ''
local cCodInt	:= ''
local cUF		:= '' 
local cCodRec 	:= '' 
local cAmbWS	:= ''
local cCodAtu	:= ''
local cCodNAtu	:= ''
local cMsg		:= ''
local cIdEnt	:= FSA095IDEnt() 
local cParSinc	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"FISA117SIN"
local cTela		:= STR0018 + cIdEnt  //"Monitoramento da GNRE" + " - Entidade : "

local lOkParam	:= .f.
local lSinc		:= .t.
local lTSS		:= .f.

local nX		:= 0

default cURL	:= ''

//Realiza Conexão com TSS
oWs:= WsSpedCfgNFe():New()
oWs:cUSERTOKEN      := 'TOTVS'
oWs:cID_ENT         := cIdEnt
oWS:_URL            := AllTrim(cURL)+'/SPEDCFGNFe.apw'
lOk                 := oWs:CfgTSSVersao()

if lOk
	cVerTss := oWs:cCfgTSSVersaoResult   

	lTss:= ( substr(cVerTss,1,2) == '12' .and. cVerTss >= "12.1.007" ) .Or. ( substr(cVerTss,1,2) <> '12' .and. cVerTss >= "2.55" ) //tratamento para a versão 11 e 12 do TSS

	If !lTSS 
		lSinc := .F.
   		Alert(STR0014) //Versão do TSS não atende a sincronização de Informações Extras. Realize a atualização do TSS.
	endif 
	
else
	Aviso('GNRE',iif(empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0013},3) //OK
	return
endif


MV_PAR01 := aParam[01] := PadR(ParamLoad(cParSinc,aPerg,1,aParam[01]),len(F0N->F0N_UF))
MV_PAR02 := aParam[02] := PadR(ParamLoad(cParSinc,aPerg,2,aParam[02]),len(F0N->F0N_CODREC))
MV_PAR03 := aParam[03] := PadR(ParamLoad(cParSinc,aPerg,3,aParam[03]),len('2-Homologação'))


aadd(aPerg,{1,STR0015,aParam[01],'','.T.','12','.T.',40,.T.}) //"UF : "
aadd(aPerg,{1,STR0016,aParam[02],'','.T.','','.T.',40,.T.})	 //"Cód. Receita: "
aadd(aPerg,{2,STR0017,aParam[03],{'1=Produção','2=Homologação'},60,'.T.',.T.,'.T.'}) //"Ambiente:"	"1-Produção" "2-Homologação"  

if lSinc 

	lOkParam 	:= ParamBox(aPerg,cTela,@aParam,,,,,,,cParSinc,.T.,.T.)
	
	if lOkParam
	
		cUF		:= aParam[01]  
		cCodRec:= aParam[02]  
		cAmbWS	:= alltrim( aParam[03] ) 
		
		TssRetInfAdic( cIdEnt, cURL, cUF, cCodRec, cAmbWS, @aInfAdic)
		
		if len( aInfAdic ) > 0
		
			dbselectarea('F0N')							
			F0N->(dbsetorder(1))
			
			//estrutura do array aInfAdic
			//{	cUF, cCodRec, cAmbWS, cCodigo, cTipo, cTam, cDec, cTitulo, cObrg})
			
			for nX:= 1 to len( aInfAdic )
			
				//Tratamento para código interno 
				cTitulo	:= NoAcento( Upper(aInfAdic[nX][8]) )  
				cCodInt 	:= RetCodInt( cTitulo )
							
				if !F0N->(dbseek(xFilial("F0N") + cUF + cCodRec + cAmbWS + cTitulo))
					
					RecLock('F0N',.T.)                             
						F0N->F0N_FILIAL	:= xFilial('F0N')
						F0N->F0N_UF		:= aInfAdic[nX][1]
						F0N->F0N_CODREC	:= aInfAdic[nX][2]
						F0N->F0N_AMBWS	:= aInfAdic[nX][3]		
						F0N->F0N_CODSEF	:= aInfAdic[nX][4]
						F0N->F0N_TIPO	:= aInfAdic[nX][5]
						F0N->F0N_TAMANH := aInfAdic[nX][6]
						F0N->F0N_DECIMA := aInfAdic[nX][7]
						F0N->F0N_TITULO	:= cTitulo
						F0N->F0N_OBRIGA := aInfAdic[nX][9]
						F0N->F0N_CODINT	:= cCodInt
						F0N->F0N_DTATLZ	:= date()
						F0N->F0N_ATUALI := "2" //Atualizado por: 1-Importação # 2-TSS # 3-Usuário
					F0N->(MsUnlock())	
					
				else	
				                               
					//Verifico se foi alterado ou incluso pelo usuário, caso tenha sido não será atualizado.
					if F0N->F0N_ATUALIZ <> "3"  
					
						RecLock('F0N',.F.)
							F0N->F0N_CODSEF	:= aInfAdic[nX][4]
							F0N->F0N_TIPO	:= aInfAdic[nX][5]
							F0N->F0N_TAMANH := aInfAdic[nX][6]
							F0N->F0N_DECIMA := aInfAdic[nX][7]
							F0N->F0N_OBRIGA := aInfAdic[nX][9]
							F0N->F0N_CODINT	:= cCodInt
							F0N->F0N_DTATLZ	:= date()
							F0N->F0N_ATUALI := "2" //Atualizado por: 1-Importação # 2-TSS # 3-Usuário
						F0N->(MsUnlock())  
				   endif
				endif	
			next
			MsgInfo(STR0021) //Sincronização efetuada com sucesso!
		endif
	else
		return
	endif	
endif	

return

//-------------------------------------------------------------------
/*/{Protheus.doc} TssRetInfAdic
Realiza a consulta através do TSS

@author Simone dos Santos de Oliveira
@since 02/03/2016
@version 1.0

/*/
//-------------------------------------------------------------------  
static function TssRetInfAdic( cIdEnt, cURL, cUF, cCodRec, cAmbWS, aInfAdic)

local cCodigo	:= ''	
local cTipo		:= ''
local cTam		:= ''
local cDec		:= ''
local cTitulo	:= ''
local cObrg		:= ''

local lOk		:= .F.

local nY		:= 0

default cIdEnt	:= ''
default cURL	:= ''
default cUF		:= ''
default cCodRec	:= ''
default cAmbWS	:= ''
default aInfAdic:= {}


if !( empty(cIdEnt) .and. empty(cURL) .and. empty(cUF) .and. empty(cCodRec) .and. empty(cAmbWS) )
	oWS:= WSTSSGNRE():New()
	oWS:cUSERTOKEN	:= 'TOTVS'
	oWS:cIDENT	  	:= cIdEnt
	oWS:cAMBIENTE 	:= cAmbWS
	oWS:cUF			:= cUF
	oWS:cCODRECEITA	:= alltrim(cCodRec)
	oWS:_URL	  	:= allTrim(cURL)+'/TSSGNRE.apw'
	
	lOk := oWS:GETCONFGNREUF()     
	
	
	if (lOk <> nil .Or. lOk)
	
		if type('oWS:OWSGETCONFGNREUFRESULT:LSUCESSO') <> 'U' .and. oWS:OWSGETCONFGNREUFRESULT:LSUCESSO  //verifico se a consulta foi realizada com sucesso
			
			if type('OWS:OWSGETCONFGNREUFRESULT:OWSCAMPOSADICIONAIS:OWSINFCAMPOSADIC') <> 'U'  //verifico se tem informações adicionais 
				
				oRetorno := OWS:OWSGETCONFGNREUFRESULT:OWSCAMPOSADICIONAIS:OWSINFCAMPOSADIC 
												
				//Atribuo os devidos valores referente a consulta para atualizar tabela.
				for nY:= 1 to len(oRetorno)
				
					cCodigo		:= oRetorno[nY]:CCODIGO
					cTipo		:= oRetorno[nY]:CTIPO
					cTam		:= oRetorno[nY]:CTAMANHO
					cDec		:= oRetorno[nY]:CDECIMAL
					cTitulo		:= oRetorno[nY]:CTITULO
					cObrg		:= oRetorno[nY]:COBRIGATORIO
					
					//dados para atualização da base
					aadd(aInfAdic, {	cUF,;
										alltrim(cCodRec),;
										cAmbWS,;
										cCodigo,;	
										cTipo,;
										cTam,;
										cDec,;
										cTitulo,;
										cObrg})
				next
			else	
				Alert(STR0020) //Não há campos adicionais para esta UF, Ambiente e Código de Receita!
			endif	
		else
			Alert(STR0019) //Problema de comunicação com a UF. Refaça a consulta. 
		endif
	
	endif
endif

return
//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa117CFG
Rotina de Configuração do Web Service - GNRE

@author Simone dos Santos de Oliveira
@since 27.02.2015
@version 1.0

/*/
//-------------------------------------------------------------------     
function Fisa117CFG()
	
	SpedNFeCFG()
	
return 

