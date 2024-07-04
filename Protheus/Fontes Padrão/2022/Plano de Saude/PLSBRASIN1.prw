#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'Totvs.CH'
#Include 'topconn.ch'
#include 'PLSBRASIN1.ch'

static cTxtTmp	:= "CALTTXTSIN"
static aOperLog	:= {}
static cOperad	:= ""
static cDataLog	:= dtoc(msdate())
static cFonte   := alltrim(iif(IsInCallStack('PLSBRASIN1'),STR0057,iif(IsInCallStack('PLSSIMPRO'),STR0058,STR0059))) + "|" //BRASINDICE , SIMPRO  ou A900

//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSBRASIN1
Tela inicial de Importações da Brasíndice
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSBRASIN1(lAutoma)
Local oBrowse   := nil
Local cCodOpe	:= PlsIntpad()
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )

cOperad	:= upper( alltrim(UsrRetName(RetCodUsr())) )
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B6F')
oBrowse:SetFilterDefault("@(B6F_FILIAL = '" + xFilial("B6F") + "' AND B6F_CODOPE = '" + cCodOpe + "') AND B6F_TPARQ = '1' ")
oBrowse:SetDescription(STR0001) //Importações Tabela Brasíndice®
iif( !lAutoma, oBrowse:Activate(), "")

Return nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menus
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title  STR0003 	Action 'PLSBRASIN2(.f.)' 	    Operation 3 Access 0  //Configurar
Add Option aRotina Title  STR0002   Action 'staticCall(PLSBRASIN1, PergIniImport, .f.,{})'  Operation 3 Access 0  //Importar
Add Option aRotina Title  STR0004	Action 'VIEWDEF.PLSBRASIN1' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title  STR0005	Action 'staticCall(PLSBRASIN1, ExcBrasindice, .f.)'     Operation 9 Access 0  //Excluir

Return aRotina



//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados.
@since 04/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB6F	:= FWFormStruct(1,'B6F')
Local oStrBD4	:= FWFormStruct(1,'BD4')

PLwhoami()

oModel := MPFormModel():New( 'PLSBRASIN1') 

oStrB6F:AddField('CODRELAC', 'Código Relação', 'CODRELAC', 'C', 30, 0, , {||.T.}, {}, .F., ;
{||cFonte + B6F->B6F_EDICBR + '|' + B6F->B6F_TIPPRO + '|' + B6F->B6F_TIPO}, .F., .F., .T., , )

oModel:AddFields( 'B6FMASTER', /*cOwner*/, oStrB6F )
oModel:AddGrid('BD4Detail', 'B6FMASTER', oStrBD4)
oModel:SetRelation( 'BD4Detail', { { 'BD4_FILIAL', 'xFilial( "BD4" ) ' } , ;
								   { 'BD4_CHVIMP', 'CODRELAC' }} , ;
									BD4->(indexkey(4)) )

oStrBD4:AddField('Procedimento', 'Procedimento', 'DESCPRO' , 'C', 200, 0, , , {}, .F.,{||Posicione("BR8",1,xFilial("BR8")+BD4->(BD4_CDPADP+BD4_CODPRO),"BR8_DESCRI") } , .F., .F., .T., , )
oModel:GetModel( 'BD4Detail' ):SetOptional(.t.)
oModel:GetModel('BD4Detail'):SetOnlyView(.t.)
oModel:GetModel( 'B6FMASTER' ):SetDescription( STR0001 )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface.
@since 04/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView 
Local oModel	:= FWLoadModel( 'PLSBRASIN1' )
Local oStrB6F	:= FWFormStruct(2,'B6F', {|cCampo|PlCmpTab(cCampo, 'B6F')})
Local oStrBD4	:= FWFormStruct(2,'BD4', {|cCampo|PlCmpTab(cCampo, 'BD4')})

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'ViewB6F', oStrB6F, 'B6FMASTER' )
oView:AddGrid( 'ViewBD4' , oStrBD4,'BD4Detail' )
oStrB6F:AddField( 'CODRELAC' ,'15','Código Relação'	,'Código Relação'	  ,, 'C' ,"@!",,,,,,,,,.t.,, )
oStrBD4:AddField( 'DESCPRO' , '50','Descrição do Procedimento', 'Descrição do Procedimento',, 'Get' ,"@!",,,.F.,,,,,,.t.,, ) //'Procedimento'
oStrBD4:SetProperty('BD4_CODPRO', MVC_VIEW_TITULO, "Código Procedimento")
oStrBD4:SetProperty('BD4_CODIGO', MVC_VIEW_TITULO, "Unidade Medida Valor")

oView:CreateHorizontalBox( 'SUPERIOR', 25 )
oView:CreateHorizontalBox( 'INFERIOR', 75 )
oView:SetOwnerView( 'ViewB6F', 'SUPERIOR' )
oView:SetOwnerView( 'ViewBD4', 'INFERIOR' )
oView:SetProgressBar(.t.)
oView:EnableTitleView('ViewBD4', "Eventos - Tabela BD4")
oView:SetViewProperty("ViewBD4", "GRIDSEEK",    {.T.})
oView:SetViewProperty("ViewBD4", "GRIDFILTER",  {.T.})

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PlCmpTab
Campos que devem ser exibidos no form
@since 04/2020
@version P12
/*/
//-------------------------------------------------------------------
static function PlCmpTab(cCampo, cTab)
Local lRet := .f.
default cTab := "B6F"

if cTab == "B6F" .and. alltrim(cCampo) $ 'B6F_EDICBR,B6F_DATIMP,B6F_USUARI,B6F_ARQUIV,B6F_TIPPRO, B6F_TIPO'
	lRet := .t.
elseif cTab == "BD4" .and. alltrim(cCampo) $ 'BD4_CODPRO,BD4_CODTAB,BD4_CODIGO,BD4_VALREF'
    lRet := .t.
endif

return lRet


//-------------------------------------------------------------------
/*/ {Protheus.doc} PergIniImport
Pergunte inicial da importação da Brasíndice
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function PergIniImport(lAuto, aDadAuto)
local aPergs 		:= {}
local aRetPerg		:= {}
local aCabec 		:= { {'Data',"@C",10}, {'Tipo de Erro',"@C",2 }, {'Erro',"@C",300 }, {'Usuário',"@C",100 } } 
local aRetCri		:= {}
local aRetAut		:= {.t., {}}
local cRodape		:= STR0046//"Tipo de Erro: 0=Arquivo em duplicidade com regra / 1=Arquivos Orfãos sem 'match' / 2=Erro Importação / 3=Registro não importado"
local cMensLog		:= ""
local cNomeLog		:= ""
local lExecuta		:= .t.
default lAuto		:= .f.
default aDadAuto	:= {}

aadd(aPergs,{ 6, STR0016 , Space(100) , "@!","","",90,.t., STR0015 + " |*.*",,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ), .t.}) //Diretório dos arquivos / Arquivos
aadd(aPergs,{ 1, STR0017 , Space(6)   , "@!",'.T.',,nil,40,.t. } )  //Número da Edição
aadd(aPergs,{ 1, STR0018 , dDatabase  , "99/99/9999",'.T.',,'.t.',60,.t. } ) //"Data Publicação"
aadd(aPergs,{ 2, STR0019 , Space(1)   ,{ STR0020, STR0021 },100,,.t. } ) //"Tipo de Operação" / 1=Inclusão / 2=Exclusão
 
if lAuto
	aRetPerg := aDadAuto     
elseIf !paramBox( aPergs,STR0022,aRetPerg,,,.t.,,,,'PLBRASIND',.t.,.t. ) //"Importação Brasíndice -
	lExecuta := .f.
endIf

if lExecuta .and. aRetPerg[4] == "1"
	ImpTabBrasindice(aRetPerg, lAuto)
	if ( len(aOperLog) > 0 .and. !lAuto)
		aRetCri := PLSCRIGEN(aOperLog, aCabec, STR0040, .f., cRodape) //'Problemas Encontrados'
		if ( aRetCri[1] )
			cMensLog := STR0045 + cDataLog + STR0044 + cOperad + CRLF //"Importação realizada no dia: /, pelo usuário: "
			cNomeLog := "erros_importacao_brasindice_" + strtran(cDataLog, "/", "_") + "_" + strtran(time(), ":","_")
			GrvLogPc( alltrim(aRetPerg[1]), cNomeLog, cMensLog, ".log", .t., len(aCabec) )
		endif
	elseif lAuto .and. len(aOperLog) > 0
		aRetAut[1] := .f.
		aRetAut[2] := aclone(aOperLog)	
	endif
elseif lExecuta .and. aRetPerg[4] == "2"
	PlExclEdicao(aRetPerg, lAuto)
endif 

LimpaArray(aOperLog)
LimpaArray(aRetPerg)

return aRetAut


//-------------------------------------------------------------------
/*/ {Protheus.doc} ImpTabBrasindice
Rotina de Importação dos arquivos Brasíndice
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function ImpTabBrasindice(aRetPerg, lAuto)
local aArqDir	:= {} 
local aRetFun	:= {}
local aArqOrf	:= {}
Local cCodOpe	:= PlsIntpad()
local aDadImp	:= staticCall(PLSBRASIN2, ChkVlrDup, "1", nil, cCodOpe,lAuto)
local cCaminho	:= alltrim(aRetPerg[1])
local cVersao	:= alltrim(aRetPerg[2])
local cExtArq	:= "*.txt"
local lRet		:= .t.
local lContinua	:= .t.
local nFor		:= 0
local aTFrmOrf 	:= {}
local oRegua	:= nil
default lAuto	:= .f.

/*ATENÇÃO 
O array aDadImp contêm as informações da tabela B6G de configuração, bem como irá armazenar as regras de importação e os arquivos
que deram 'match' com as regras. Abaixo, a estrutura desse array, usado em todas as operações:
aDadImp = {lRet, aDadRet}, onde: 
	1ª) lRet é o retorno lógico, usado na rotina PLSBRASIN2
	2ª) aDadRet, contêm o array com os dados para a rotina de importação.
	* aDadRet = {B6G_TIPPRO, B6G_TIPO, B6G_REGIMP, REC, {}, {}}
		1ª) B6G_TIPPRO - Tipo do Item: "1=Materiais","2=Medicamentos","3=Soluções"
		2ª) B6G_TIPO - Tipo de Preço: 1=PMC;2=PFB
		3ª) B6G_REGIMP - Regras de Importação, para validação do nome do arquivo
		4ª) REC - RECNO da regra de importação da B6G
		5ª) Array preenchido na função ChkRegImport, que gera array com o desmembramento das regras de importação: {MATERIAL, PMC}, {MATERIAIS, PMC}
		6ª) Array que armazena os arquivos que deram match com a regra, ou seja, válidos.
*/
if empty(aDadImp[2])
	Help(nil, nil , STR0006, nil, STR0008, 1, 0, nil, nil, nil, nil, nil, {STR0009} ) //"Não existe configurações de importações de arquivos Brasíndice válidos para a Operadora."
	lContinua := .f.
else
	//Preenche a partir da 5ª posição do array de configuração com as strings de pesquisa
	ChkRegImport( @aDadImp[2] )
endif

if lContinua

	aArqDir := directory(cCaminho+cExtArq)

	if len(aArqDir) > 0
		for nFor := 1 to len(aArqDir)
			if ( !(cVersao $ aArqDir[nFor,1]) ) .and. (!lAuto .and. !msgyesno( ExibeMensagem("1", alltrim(aArqDir[nFor,1]), cVersao), STR0006 ) )
				lContinua := .f.	
			endif

			if lContinua
				ExecRegImp(aArqDir[nFor,1], @aDadImp[2], @aArqOrf)	
			endif
			lContinua := .t.
		next

		//Exibir janela de Desambiguação de Arquivos X Cadastros, pois temos arquivos orfãos :-(
		if len(aArqOrf) > 0  
			Telaorfaos(aArqOrf, @aDadImp[2], aTFrmOrf, lAuto)
		endif

		//Começa a importação
		if !lAuto
			oRegua := MsNewProcess():New( { || PLSBRASIMP(cCaminho, aDadImp[2], lAuto, @oRegua, aRetPerg[3], cVersao) } , STR0055 , STR0056 , .f. )//"Processando Configurações e arquivos / Espere..."
			oRegua:Activate()
		else
			PLSBRASIMP(cCaminho, aDadImp[2], lAuto, @oRegua, aRetPerg[3], cVersao)
		endif
	else
		Help(nil, nil , STR0006, nil, STR0007, 1, 0, nil, nil, nil, nil, nil, {""} ) //"Não existe arquivos com extensão .txt na pasta indicada no Pergunte."
		lRet := .f.
	endif

endif

LimpaArray(aDadImp)
LimpaArray(aArqOrf)

return ( {lRet, aRetFun} )


//-------------------------------------------------------------------
/*/ {Protheus.doc} ExibeMensagem
Montagem das mensagens exibidas
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function ExibeMensagem(cTipo, cNome, cVersao, aDadosGer)
local cMensagem	:= ""

if cTipo == "1"
	cMensagem := STR0010 + cNome + STR0011 + cVersao + "). " + CRLF //" não possui a mesma versão Brasíndice informada no pergunte ("
	cMensagem += STR0012 + cVersao + STR0013 + CRLF //" Caso continue a importação, será gravada a versão" # " - na chave de referência, na tabela BD4."
	cMensagem += STR0014 //" Se tiver certeza que deseja importar, clique no botão Sim. Caso não, o arquivo será ignorado."
elseif cTipo == "2"
	cMensagem := STR0010 + cNome + STR0029 + alltrim(RetcBox("B6G_TIPPRO", aDadosGer[1])) +; //" possui as regras da configuração: "
				 STR0030 + alltrim(aDadosGer[3]) + STR0031 + aDadosGer[6,1] //"Regra(s): " / ", mas a presente regra já possui arquivo herdado, de nome"
endif
return cMensagem


//-------------------------------------------------------------------
/*/ {Protheus.doc} ChkRegImport
Executa a montagem dinâmica das regras
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function ChkRegImport (aDadB6G, aTFrmOrf)
local aDadSep	:= {}
local aDadBusc	:= {}
local nFor 		:= 0
local nFor2		:= 0
local nFor3		:= 0
local cRet		:= ''
default aTFrmOrf:= {}

for nFor := 1 to len(aDadB6G)
	aDadSep := StrTokArr(aDadB6G[nFor,3], ";")
	for nFor2 := 1 to len(aDadSep)
		cRet := ''
		aDadBusc := StrTokArr(aDadSep[nFor2], "+")
		for nFor3 := 1 to len(aDadBusc)
			cRet += "'" + alltrim(aDadBusc[nFor3]) + "'" + " $ '" + cTxtTmp + "' .AND. "
		next
		cRet := SUBSTR(cRet, 1, Len(cRet) - 7)
		aadd(aDadB6G[nFor,5], cRet)
	next	 
next 

return 


//-------------------------------------------------------------------
/*/ {Protheus.doc} ExecRegImp
Executa segunda parte da checagem dos nomes nos arquivos encontrados no diretório
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function ExecRegImp(cNomeArq, aDadPesq, aArqOrf)	
local nFor 		:= 0
local nFor2		:= 0
local lRet 		:= .f.

for nFor := 1 to len(aDadPesq)
	for nFor2 := 1 to len(aDadPesq[nFor,5])
		if ( &( strtran(aDadPesq[nFor, 5, nFor2], cTxtTmp, cNomeArq) ) )
			if (empty(aDadPesq[nFor,6]))
				aadd(aDadPesq[nFor,6], cNomeArq)
				lRet := .t.
				exit
			else
				OprLogSist("0", ExibeMensagem("2", cNomeArq, '', aDadPesq[nFor]))	
			endif	
		endif	
	next
next

if !lRet
	aadd(aArqOrf, {cNomeArq,''})
endif

return 


//-------------------------------------------------------------------
/*/ {Protheus.doc} Telaorfaos
Tela para definir arquivo vs configuração Brasíndice
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function TelaOrfaos (aArqOrf, aDadImp, aTFrmOrf, lAuto)
local aArquivos := aclone(aArqOrf)
local oPanelOrf	:= nil
local btnOK		:= { ||oPanelOrf:End(), nOpca := 1  }
local bCanc		:= { ||oPanelOrf:End()}  
local nFor 		:= 0   
local nPos		:= 0
local nOpca     := 0
local lRetExb	:= .t.
local oGrdOrf	:= nil   
default lAuto	:= .f.      

//Criar a opção em branco
aadd(aTFrmOrf,'')
for nFor := 1 to len(aDadImp)
	if ( empty(aDadImp[nFor,6]) )
		aadd(aTFrmOrf, cValtochar(nFor) + "=" + alltrim(RetcBox("B6G_TIPPRO",aDadImp[nFor,1])) + " e " + alltrim(RetcBox("B6G_TIPO",aDadImp[nFor,2])) +;
	         STR0032 + alltrim( strtran(aDadImp[nFor,3], ";", " | " ) ) ) // - Regra Imp: 
	endif
next

if len(aTFrmOrf) <= 1
	lRetExb := .f.
endif 

if lRetExb
	if !lAuto
		DEFINE MSDIALOG oPanelOrf TITLE STR0024 FROM 0,0 TO 300,700 PIXEL //"Arquivos sem correspondência"
	endif
	oGrdOrf := fwBrowse():New()
	oGrdOrf:setDataArray()
	oGrdOrf:setArray( aArquivos )
	oGrdOrf:disableConfig()
	oGrdOrf:disableReport()
	oGrdOrf:setOwner( oPanelOrf )
	oGrdOrf:SetDescription(STR0024) //"Arquivos sem correspondência"

	oGrdOrf:addColumn({STR0025, {||aArquivos[oGrdOrf:nAt,1]}, "C", "@!", 1, 30, 0 , .f. , , .F., , "CARQ", , .F., .T., , "CARQ" }) //"Nome Arquivo"
	oGrdOrf:addColumn({STR0026, {||aArquivos[oGrdOrf:nAt,2]}, "C", "@!", 1, 1, 0, .t. , , .F., , "CCONFIG" , , .F., .T., aTFrmOrf, "CCONFIG" }) //"Configuração Brasíndice"

	oGrdOrf:setEditCell( .T., {|| AjustaDados(aArquivos, @oGrdOrf)} )
	oGrdOrf:aColumns[2]:setEdit(.t.)
	oGrdOrf:aColumns[2]:SetReadVar("CCONFIG")

	oGrdOrf:setInsert( .F. )

	if !lAuto
		oGrdOrf:activate()
	
		ACTIVATE MSDIALOG oPanelOrf CENTERED ON INIT Eval({ || EnChoiceBar(oPanelOrf,btnOK,bCanc,.F.) })
	endif
	
	if nOpca == 1
		for nFor := 1 to len(aArquivos)
			if ( empty(aArquivos[nFor,2]) )
				OprLogSist("1", STR0027 + aArquivos[nFor,1] + STR0028) //"Arquivo: " / " não foi dado 'match' manual"
			else 
				nPos := val(aArquivos[nFor,2])
				if ( empty(aDadImp[nPos,6]) )
					aadd(aDadImp[nPos,6], aArquivos[nFor,1])
				else
					OprLogSist("1", STR0027 + aArquivos[nFor,1] + STR0054) //"Arquivo: " / " não será processado, por já existir arquivo atríbuido."
				endif
			endif  
		next
	endif
endif
return .t.


//----------------------------------------------------------------
/*/ {Protheus.doc} AjustaDados
Ajusta dados do array, após edição pelo usuário
@since 04/2020
@version P12 
/*/
//----------------------------------------------------------------
static function AjustaDados(aArray, oGrdOrf)
local lRet	:= .t.

if upper(Readvar()) == "CCONFIG"
    aArray[oGrdOrf:nAt,2] := &(Readvar())
endif

return lRet


//----------------------------------------------------------------
/*/ {Protheus.doc} OprLogSist
Armazenar no array aOperLog informações do sistema
Deve ter a seguinte estrutura: Data / Nível Log* / Informação / Usuário
*Nível Log: 0=Arquivo duplicado regras / 1=Info Arquivos Orfãos / 2=Erro Importação /
3=Registro não importado
@since 04/2020
@version P12 
/*/
//----------------------------------------------------------------
static function OprLogSist(cNivLog, cMsgErro)
aadd(aOperLog, {cDataLog, cNivLog, cMsgErro, cOperad})
return 


//-------------------------------------------------------------------
/*/ {Protheus.doc} LimpaArray
Função para limpar arrays
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function LimpaArray (aLmpArray)
default aLmpArray   := {}

if len(aLmpArray) > 0
	while Len(aLmpArray) > 0
		aDel(aLmpArray, len(aLmpArray))
		aSize(aLmpArray, len(aLmpArray)-1)	
	enddo
	aLmpArray := {}
endif

return


//-------------------------------------------------------------------
/*/ {Protheus.doc} ExcBrasindice
Função que inicia o processo de exclusão de uma tabela Brasíndice ou outra
@since 05/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function ExcBrasindice(lAutoma)
local aRetQry	:= {}
local aRetFnc	:= {.t., ''}
local cVersao	:= B6F->B6F_EDICBR
local nRecB6F	:= B6F->(recno())
default lAutoma	:= .f.

aRetQry := QryExcBrasin(B6F->B6F_CODOPE, B6F->B6F_TPARQ, B6F->B6F_EDICBR, B6F->B6F_TIPPRO, B6F->B6F_TIPO) 
if !aRetQry[1]
	Help(nil, nil , STR0006, nil, STR0033 + aRetQry[2], 1, 0, nil, nil, nil, nil, nil, {} ) //Atenção / "Não foi possível excluir o registro, pois existe edição mais recente importada no sistema, de número " 
elseif !lAutoma
	Processa( {|| AtuBD4Exc(nRecB6F, cVersao, lAutoma, B6F->B6F_TIPPRO) }, STR0034, STR0035 ,.F.) //"Aguarde..." / "Efetuando a exclusão dos itens e demais processos..."
else
	aRetFnc := AtuBD4Exc(nRecB6F, cVersao, lAutoma, B6F->B6F_TIPPRO) 
endif
return aRetFnc


//-------------------------------------------------------------------
/*/ {Protheus.doc} AtuBD4Exc
Função que exclui o registro atual da BD4 e  no fim, o registro B6F posicionado.
@since 05/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function AtuBD4Exc(nRecB6F, cVersao, lAutoma, cTipPro)
local aCabec 	:= { {'Data',"@C",10}, {'Tipo de Erro',"@C",1 }, {'Erro',"@C",300 }, {'Usuário',"@C",100 } } 
local aRetCri	:= {}
local aRetFnc	:= {.t., ''}
local cRodape	:= STR0042 //"Tipo de Erro: DL=Problema na exclusão. Nenhum registro foi excluído."
local cFile		:= ""
local cMensLog	:= STR0043 + cDataLog + STR0044 + cOperad + CRLF //"Tentativa de exclusão realizada no dia: / ", pelo usuário: "
local cNomeLog	:= "erro_deletar_tabela_" + strtran(cDataLog, "/", "_") + "_" + strtran(time(), ":","_")
local lExecExc	:= .f.
local lRetFun	:= .t.
local nTamReg	:= iif(cTipPro != "E", 5, 2)
default lAutoma := .f.

PLwhoami()

//"Deseja realmente exluir a importação dessa tabela? / Todos os dados referentes à essa importação serão excluídos do sistema!
if lAutoma
	lExecExc := .t.
elseif ( !lAutoma  .and. msgyesno( STR0038 + CRLF + STR0039, STR0006 ) ) 
	lExecExc := .t.
endif

if lExecExc
	ProcRegua(nTamReg)
	BEGIN TRANSACTION
		if cTipPro != "E"
			lRetFun := QryDELETA()
		else
			lRetFun := QryDelExcluidos()	
		endif

		if lRetFun
			if B6F->(recno()) != nRecB6F
				B6F->( dbgoto(nRecB6F) )
			endif

			B6F->(RecLock("B6F", .f.))
				B6F->B6F_EXCIMP := dtoc(msdate()) + " " + time() + " - PC: " + alltrim(getcomputername()) + " - Usuário: " + cOperad
				B6F->(dbdelete())
			B6F->(MsUnlock())
			Incproc()
		endif

	END TRANSACTION

	if lRetFun
		Help(nil, nil , STR0006, nil, STR0036 + SUBSTR(cFonte,1,len(cFonte)-1)+space(1) + cVersao + STR0037, 1, 0, nil, nil, nil, nil, nil, {} ) //"Registro da Edição Brasíndice XXX e seus itens foram excluídos com sucesso."
	else
		Help(nil, nil , STR0006, nil, STR0041, 1, 0, nil, nil, nil, nil, nil, {} ) //Ocorreu algum problema na hora de deletar os procedimentos. Consulte o Log 	
		aRetFnc[1] := .f.
		aRetFnc[2] := aClone(aOperLog)
		if !lAutoma
			aRetCri := PLSCRIGEN(aOperLog, aCabec, STR0040,.f., cRodape) //'Problemas Encontrados'
			if ( aRetCri[1] )
				cFile    := cGetFile('Arquivo *|*.*|Arquivo Log|*.log','Selecione onde gravar o Log',0,'C:\',.T.,GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
				GrvLogPc( alltrim(cFile), cNomeLog, cMensLog, ".log", .t., len(aCabec) )
			endif
		endif
	endif	
endif	
LimpaArray(aOperLog)
return aRetFnc


//-------------------------------------------------------------------
/*/ {Protheus.doc} QryExcBrasin
Query que verifica se não existe versão superior do tipo de tabela que está tentando excluir.
Ou seja, se temos duas importações da tabela de medicamentos e tipo PFB, onde uma é a edição 100 e a outra 200,
mas ao tenta excluir a edição 100, o sistema critica, pois existe versão superior já importada.
@since 05/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function QryExcBrasin(cOperad, cTpArq, cEdicImp, cTipPro, cTipo)
local cSql		:= ""
local cUltVer	:= ""
local lRet 		:= .t.

cSql := " SELECT B6F_EDICBR ULTEDC "
cSql += "   FROM " + RetsqlName("B6F") 
cSql += " WHERE "
cSql += "   B6F_FILIAL = '" + xFilial("B6F") + "' "
cSql += "   AND B6F_CODOPE = '" + cOperad	 + "' "
cSql += "   AND B6F_TPARQ  = '" + cTpArq	 + "' "
cSql += "   AND B6F_EDICBR > '" + cEdicImp	 + "' "
cSql += "   AND B6F_TIPPRO = '" + cTipPro	 + "' "
cSql += "   AND B6F_TIPO   = '" + cTipo		 + "' "
cSql += "   AND D_E_L_E_T_ = ' ' "
cSql += " ORDER BY B6F_EDICBR DESC"

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSql)),"QRULTEDIC",.f.,.t.)

if ( !QRULTEDIC->(eof()) )
	lRet 	:= .f.	
	cUltVer	:= QRULTEDIC->ULTEDC	
endif
QRULTEDIC->(dbcloseArea())
return {lRet, cUltVer}


//-------------------------------------------------------------------
/*/ {Protheus.doc} QryDELETA
Querys que executam o processo de update nos registros que devem ser apagados e/ou atualizados.
Caso encontre algum errro, é feito o desarme da transação e retorna log para o usuário.
@since 05/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function QryDELETA()
local cSql 		:= ""
Local cCodOpe	:= PlsIntpad()
local cChvBD4	:= B6F->B6F_EDICBR + '|' + B6F->B6F_TIPPRO + '|' + B6F->B6F_TIPO
local cAreBD4 	:= RetSqlname("BD4")
local cAreBA8 	:= RetSqlname("BA8")
local cAreBR8 	:= RetSqlname("BR8")
local cCodTbs 	:= formatIn(cCodOpe + B6F->B6F_TDEPRO + "|" + cCodOpe + B6F->B6F_CODTDE, "|")
local lContinua	:= .t.
local nRetUpd 	:= 0

LimpaArray(aOperLog)
PLwhoami()

//Atualizar para deletado os registros BD4 que pertencem a edição deletada
cSql := " UPDATE " + cAreBD4
cSql += "   SET D_E_L_E_T_ = '*' "
cSql += iif( PLCHKRCD("BD4"), " , R_E_C_D_E_L_ = R_E_C_N_O_", "")  

cSql += " WHERE "
cSql += "   BD4_FILIAL = '" + xFilial("BD4") + "' "
cSql += "   AND BD4_CHVIMP = '" + cFonte + cChvBD4 + "' "
cSql += "   AND D_E_L_E_T_ = ' ' " 

nRetUpd := TCSqlExec(cSql)
if nRetUpd < 0
	OprLogSist("DL", "Query 1 - " + TCSQLError() + CRLF)
	lContinua := .f.
endif
Incproc() 

//Verificar se para os registros deletados existem algum BD4 anterior existente. Se sim, pegar o maior data de de BD4_VIGFIM e reabre
if lContinua
	cSql := " UPDATE " + cAreBD4
	cSql += "   SET BD4_VIGFIM = ' ' "
	cSql += " WHERE "
	cSql += "   R_E_C_N_O_ IN "

	cSql += "     ("
	cSql += "       SELECT BD4R.R_E_C_N_O_ FROM "
	cSql += "         ( "
	cSql += "           SELECT BD4T.BD4_CODPRO CODPRO, BD4T.BD4_CODTAB CODTAB, MAX(BD4T.BD4_VIGFIM) VIGFIM "
	cSql += "      	    FROM " + cAreBD4 + " BD4T "
	cSql += "           WHERE "
	cSql += "             BD4T.BD4_FILIAL = '" + xFilial("BD4") + "' "
	cSql += "             AND BD4T.BD4_CODPRO IN "   
	cSql += "               ( "
	cSql += "                  SELECT BD4C.BD4_CODPRO "
	cSql += "                    FROM " + cAreBD4 + " BD4C "
	cSql += "                  WHERE "
	cSql += "                    BD4C.BD4_FILIAL = '" + xFilial("BD4") + "' "
	cSql += "                    AND BD4C.BD4_CHVIMP = '" + cFonte + cChvBD4 + "' "
	cSql += "               ) "     
	cSql += "             AND BD4T.BD4_CODTAB IN " + cCodTbs
	cSql += "             AND BD4T.BD4_CHVIMP <> '" +cFonte + cChvBD4 + "' "
	cSql += "             AND BD4T.D_E_L_E_T_  = ' ' "
	cSql += "           GROUP BY BD4T.BD4_CODPRO, BD4T.BD4_CODTAB "
	cSql += "         ) XX4 "
	cSql += "       JOIN " + cAreBD4 + " BD4R "
	cSql += "         ON BD4R.BD4_FILIAL = '" + xFilial("BD4") + "' "
	cSql += "         AND BD4R.BD4_CODPRO = XX4.CODPRO "
	cSql += "         AND BD4R.BD4_CODTAB = XX4.CODTAB "
	cSql += "         AND BD4R.BD4_VIGFIM = XX4.VIGFIM "

	cSql += "     ) " 

	nRetUpd := TCSqlExec(cSql)
	if nRetUpd < 0
		OprLogSist("DL", "Query 2 - " + TCSQLError() + CRLF)
		lContinua := .f.
	endif
	Incproc() 
endif

//Verifica se ficou algum BA8 sem BD4. Se sim, deleta o BA8
if lContinua
	cSQL := " UPDATE " + cAreBA8 
	cSQL += "   SET D_E_L_E_T_ = '*' "
	cSql += iif( PLCHKRCD("BA8"), " , R_E_C_D_E_L_ = R_E_C_N_O_", "") 

	cSQL += " WHERE  "
	cSQL += "   R_E_C_N_O_ IN "
	cSql += "     ("
	cSql += "       SELECT BA8T.R_E_C_N_O_ FROM " + RetSqlname("BA8") + " BA8T WHERE"
	cSQL += "       BA8T.BA8_FILIAL = '" + xfilial("BA8") + "' "
	cSQL += "       AND BA8T.BA8_CODTAB IN " + cCodTbs
	cSQL += "       AND NOT EXISTS "
	cSql += "             ( "
	cSql += "  	            SELECT BD4_FILIAL FROM " + cAreBD4 + " BD4CN WHERE "
	cSQL += "  				  BD4CN.BD4_FILIAL = '" + xFilial("BD4") + "' AND "
	cSQL += "  				  BD4CN.BD4_CODTAB = BA8T.BA8_CODTAB AND "
	cSQL += "  				  BD4CN.BD4_CDPADP = BA8T.BA8_CDPADP AND "
	cSQL += "  				  BD4CN.BD4_CODPRO = BA8T.BA8_CODPRO AND "
	cSQL += "  				  BD4CN.D_E_L_E_T_ = ' ' "
	cSql += "             ) " 
	cSql += "       AND BA8T.D_E_L_E_T_ = ' '
	cSql += "     )"
	cSql += "   AND D_E_L_E_T_ = ' ' "

	nRetUpd := TCSqlExec(cSql)
	if nRetUpd < 0
		OprLogSist("DL", "Query 3 - " + TCSQLError() + CRLF)
		lContinua := .f.
	endif
	Incproc() 
endif

//Atualiza a BR8, caso algum BA8 tenha sido deletado, marcando BR8_BENUTL como Não.
if lContinua
	cSql := " UPDATE " + cAreBR8 
	cSql += "   SET BR8_BENUTL = '0' "
	cSql += " WHERE "
	cSql += "   R_E_C_N_O_ IN "
	cSql += "   ("
	cSql += "     SELECT DISTINCT BR8D.R_E_C_N_O_ FROM " + cAreBR8 + " BR8D "
	cSql += "       INNER JOIN " + cAreBA8 + " BA8J "
	cSql += "         ON  
	cSql += "           BA8J.BA8_FILIAL = BR8D.BR8_FILIAL "
	cSql += "           AND BA8J.BA8_CDPADP = BR8D.BR8_CODPAD "
	cSql += "           AND BA8J.BA8_CODPRO = BR8D.BR8_CODPSA "
	cSql += "       WHERE "
	cSql += "         BR8D.BR8_FILIAL = '" + xfilial("BR8") + "' "
	cSql += "         AND BA8J.BA8_CODTAB IN " + cCodTbs
	cSql += "         AND NOT EXISTS "
	cSql += "           ( "
	cSql += "             SELECT BA8_FILIAL FROM " + cAreBA8 + " BA8D "
	cSql += "               WHERE "
	cSql += "                 BA8D.BA8_FILIAL = BR8D.BR8_FILIAL "
	cSql += "                 AND BA8D.BA8_CDPADP = BR8D.BR8_CODPAD "
	cSql += "                 AND BA8D.BA8_CODPRO = BR8D.BR8_CODPSA "
	cSql += "                 AND BA8D.BA8_CODTAB IN " + cCodTbs 
	cSql += "                 AND BA8D.D_E_L_E_T_ = ' '  "
	cSql += "           ) " 
	cSql += "         AND BR8D.D_E_L_E_T_ = ' ' "		
	cSql += "   ) "
	cSql += "   AND D_E_L_E_T_ = ' ' "

	nRetUpd := TCSqlExec(cSql)
	if nRetUpd < 0
		OprLogSist("DL", "Query 4 - " + TCSQLError() + CRLF)
		lContinua := .f.
	endif
	Incproc() 
endif 	

if !lContinua
	DisarmTransaction()
endif 

return lContinua


//-------------------------------------------------------------------
/*/ {Protheus.doc} GrvLogPc
Função que executa o processo de gravar em arquivo os erros/observações encontrados no processo de importação
e exclusão das tabelas Brasíndice, na pasta determinada pelo usuário.
@since 05/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function GrvLogPc(cCaminho, cNomeLog, cMensagem, cExtensao, lBaseCab, nTamCab)
local oFileGrv		:= nil
local nFor1			:= 0
local nFor2			:= 0
local cTexto		:= ""
default cNomeLog 	:= "Arquivo_LOG_"
default cMensagem	:= ""
default cExtensao 	:= ".log"
default lBaseCab	:= .t.
default aDados		:= ""
default nTamCab		:= 4

cNomeLog := cNomeLog + cExtensao
oFileGrv := FWFileWriter():New( cCaminho + cNomeLog, .t.)
oFileGrv:setBufferSize(16384)
oFileGrv:create()
if !empty(cMensagem)
	oFileGrv:write(cMensagem + CRLF)
endif

for nFor1 := 1 to len(aOperLog)
	cTexto := ""
	for nFor2 := 1 to nTamCab
		cTexto += alltrim(aOperLog[nFor1, nFor2]) + " - "
	next
	oFileGrv:write(cTexto + CRLF)
next
oFileGrv:close()

return 


static function PlExclEdicao(aRetPerg, lAuto)
local aArqDir	:= {}
local aCabec 	:= { {'Data',"@C",10}, {'Tipo de Erro',"@C",1 }, {'Erro',"@C",300 }, {'Usuário',"@C",100 } } 
local aRetCri	:= {}
local aNomeAce	:= {"EXCLUSAO", "EXCLUIDOS"}
local aRetQry	:= {}
local aRetFun	:= {.t., ''}
local cCaminho	:= alltrim(aRetPerg[1])
local cVersao	:= alltrim(aRetPerg[2])
local cArqExc	:= ""
local cExtArq	:= "*.txt"
local cRodape	:= STR0042 //"Tipo de Erro: DL=Problema na exclusão. Nenhum registro foi excluído."
local cFile		:= ""
local cNomeLog	:= "erro_importacao_eventos_excluidos_" + strtran(cDataLog, "/", "_") + "_" + strtran(time(), ":","_")
local cMensLog	:= STR0043 + cDataLog + STR0044 + cOperad + CRLF //"Tentativa de importação do arquivo de Excluídos, realizada no dia:" / "pelo usuário"
local cData		:= dtos(aRetPerg[3])
local nFor		:= 0
local lExecExc	:= .f.
local lRetFun   := .f.
Local cCodOpe	:= PlsIntpad()

LimpaArray(aOperLog)

//Verificamos se não existe arquivo mais recente de excluídos importado. Se sim, barramos o processo, pois os códigos são "reaproveitados"
aRetQry := QryExcBrasin(cCodOpe, "1", cVersao, "E", "E")

if aRetQry[1]
	aArqDir := directory(cCaminho+cExtArq)
else
	//"Não foi possível importar o arquivo de Excluídos, pois existe edição mais recente importada no sistema, de número "
	Help(nil, nil , STR0006, nil, STR0047 + aRetQry[2], 1, 0, nil, nil, nil, nil, nil, {} )
endif

if len(aArqDir) > 0
	for nFor := 1 to len(aArqDir)
		if ( ((aNomeAce[1] $ aArqDir[nFor,1]) .or. (aNomeAce[2] $ aArqDir[nFor,1])) .and. ( (cVersao $ aArqDir[nFor,1]) .or. (!(cVersao $ aArqDir[nFor,1]) .and. ;
			 (!lAuto .and. msgyesno(ExibeMensagem("1", alltrim(aArqDir[nFor,1]), cVersao), STR0006)) ) ) )
			cArqExc  := aArqDir[nFor,1]
			exit
		endif 
	next
endif

if !empty(cArqExc) 
	if lAuto
		lExecExc := .t.
	elseif (!lAuto .and. msgyesno(STR0048 + CRLF + STR0050) ) //"Deseja mesmo realizar a Importação do arquivo de Excluídos?"/"O sistema localizará os eventos em todas as TDEs cadastradas, finalizando as unidades de saúde com a data de vigência informada no Pergunte."
		lExecExc := .t.
	endif
endif 

if lExecExc
	if !lAuto
		Processa( {||lRetFun := PLSBRAAEXC(cCaminho, cArqExc, lAuto, cData, cVersao) }, STR0034, STR0035 ,.F.) //"Aguarde..." / "Efetuando a exclusão dos itens e demais processos..."
	else
		lRetFun := PLSBRAAEXC(cCaminho, cArqExc, lAuto, cData, cVersao)	
		aRetFun[1] := lRetFun
		aRetFun[2] := iif( len(aOperLog) > 0, aClone(aOperLog), "") 
	endif 

	if lRetFun
		Help(nil, nil , STR0006, nil, STR0051 + cVersao, 1, 0, nil, nil, nil, nil, nil, {} ) //"Arquivo de Excluídos da Brasíndice importado para o sistema, na edição: "
	else
		Help(nil, nil , STR0006, nil, STR0041, 1, 0, nil, nil, nil, nil, nil, {} ) //Ocorreu algum problema na hora de deletar os procedimentos. Consulte o Log 	
		
		if !lAuto
			aRetCri := PLSCRIGEN(aOperLog, aCabec, STR0040,.f., cRodape) //'Problemas Encontrados'
			if ( aRetCri[1] )
				cFile    := cGetFile('Arquivo *|*.*|Arquivo Log|*.log','Selecione onde gravar o Log',0,'C:\',.T.,GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
				GrvLogPc( alltrim(cFile), cNomeLog, cMensLog, ".log", .t., len(aCabec) )
			endif
		endif 	
	endif
else
	//"Nenhum arquivo de Excluídos da Brasíndice foi encontrado no diretório." / "Certifique-se que existe arquivo com o nome 'excluidos' ou 'exclusao' - mais a versão da Brasíndice - no diretório informado." 
	Help(nil, nil , STR0006, nil, STR0052, 1, 0, nil, nil, nil, nil, nil, {STR0053} ) 	
endif

return aRetFun


static function QryDelExcluidos()
local cSql      := ""
local cChvBD4	:= "BRASINDICE|" + B6F->B6F_EDICBR + '|' + B6F->B6F_TIPPRO + '|' + B6F->B6F_TIPO
local nRetUpd   := 0
local lContinua := .t.

cSql := " UPDATE " + RetSqlName("BD4")
cSql += "   SET BD4_VIGFIM = ' ', "
cSql += "   BD4_CHVIMP = ' ' "
cSql += " WHERE "
cSql += "   BD4_FILIAL = '" + xFilial("BD4") + "' "
csql += "   AND BD4_CHVIMP = '" + cChvBD4 + "' "
cSql += "   AND D_E_L_E_T_ = ' ' " 

nRetUpd := TCSqlExec(cSql)
if nRetUpd < 0
	OprLogSist("DL", "Query E - " + TCSQLError() + CRLF)
	lContinua := .f.
    DisarmTransaction()
endif
Incproc() 
return lContinua

// Realizado este ajuste pois quando a rotina é chamada pelo sigapls e não sigamdi não é carregada a static em tempo de execução
static function PLwhoami()
	cFonte := alltrim(iif(IsInCallStack('PLSBRASIN1'),STR0057,iif(IsInCallStack('PLSSIMPRO'),STR0058,STR0059))) + "|"
	cOperad	:= upper( alltrim(UsrRetName(RetCodUsr())) ) 
return
