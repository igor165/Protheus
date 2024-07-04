#INCLUDE "FISXSERID.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FILEIO.CH"

STATIC aCamposSer := NIL
STATIC lUsaNewKey 
Static oCposSerie := nil 

//-------------------------------------------------------------------
/*/ {Protheus.doc} SerieNfId 

Funcao que avalia qual campo da tabela devera ser retornado como campo
oficial da serie do Documento Fiscal.

@Param
cAlias   -> Alias da Tabela do campo Serie

nOpcao   -> 1 - Gravacao
			2 - Visualizacao
			3 - Retorna o nome do campo serie a ser utilizado em Querys
			4 - Retorna a Chave de Pesquisa ID ou Serie Real para utilizar em validacoes dbseeks ANTES da gravacao
			5 - Retorna o CriaVar do campo _SDOC em caso onde o campo _SERIE foi alterado tamanho para 14 para gravar o novo formato
			6 - Retorna o TamSX3 do campo  _SDOC em caso onde o campo _SERIE foi alterado tamanho para 14 para gravar o novo formato
			7 - Retorna o RetTitle do campo _SDOC em caso onde o campo _SERIE foi alterado tamanho para 14 para gravar o novo formato

cCpoOrig -> String contendo o nome do campo Serie Original
dEmissao -> Data de Emissao do Documento Fiscal (OPCIONAL Usar somente com opcao "1" - Gravacao e "4" - Validacao)
cEspecie -> Especie do Documento Fiscal (OPCIONAL Usar somente com opcao "1" - Gravacao e "4" - Validacao )
cSerieGrv-> Variavel Conteudo da Serie a ser gravada (OPCIONAL Usar somente com opcao "1" - Gravacao e "4" - Validacao)
cNewIdPai-> Campo da serie original da tabela PAI ao gravar a tabela FILHO, o foco da utilizacao e
herdar o ID gravado na tabela pai para as tabelas filho sem a necessidade de compor o ID
novamente, Exemplo: F1_SERIE = "UNI122014ESPEC" , D1_SEIRE, F3_SERIE, FT_SERIE com o mesmo conteudo
Exemplo de Uso:
SerieNfId("SF1","1","F1_SERIE",dEmissao,cEspecie,cSerieGrv) Gravando o registro Pai
SerieNfId("SD1","1","D1_SERIE",,,,SF1->F1_SERIE) Gravando o registro Filho, os parametros
dEmissao,cEspecie e cSerieGrv NAO devem ser passados, o parametro cNewPai quando referenciar
a um campo, SEMPRE devera ser apontado o alias ALIAS->CAMPO, uma variavel composta do ID de
14 posicoes também pode ser passado, contudo neste caso a varivel deve ter o mesmo formato de
gravacao do campo Id em todos os cenarios
			
!!! IMPORTANTE - ao gravar a tabela filho a tabela pai deve estar POSICIONADA.

@return

xRetCpoUso com nOpcao = 1 -> Nil
xRetCpoUso com nOpcao = 2 -> Conteudo do Campo Serie a ser Utilizado
xRetCpoUso com nOpcao = 3 -> Nome do Campo Serie a ser utilizado
xRetCpoUso com nOpcao = 4 -> Chave de Pesquisa ID ou Serie Real sempre encima do conteudo gravados nos campos _SERIE
xRetCpoUso com nOpcao = 5 -> Se com o dicionario atualizado o tamanho dos campos _SERIE for alterado para 14 retorna o CriaVar do Campo _SDOC
xRetCpoUso com nOpcao = 6 -> Se com o dicionario atualizado o tamanho dos campos _SERIE for alterado para 14 retorna o TamSX3 do campo _SDOC
xRetCpoUso com nOpcao = 7 -> Se com o dicionario atualizado o tamanho dos campos _SERIE for alterado para 14 retorna o RetTitle do campo _SDOC

@author Alexandre Lemes
@since 05/01/2015
@version 1.1
/*/                 
//-------------------------------------------------------------------
Function SerieNfId(cAlias,nOpcao,cCpoOrig,dEmissao,cEspecie,cSerieGrv,cNewIdPai)

Local aCpoSerie   := SerieToSDoc() // Array contendo todos os campos do Projeto
Local xRetCpoUso  := ""
Local cNewId      := ""
Local nField      := 0

DEFAULT dEmissao  := dDataBase
DEFAULT cCpoOrig  := ""
DEFAULT cEspecie  := ""
DEFAULT cSerieGrv := ""
DEFAULT cNewIdPai := ""

if lUsaNewKey==Nil
	lUsaNewKey  := TamSX3("F1_SERIE")[1] == 14 // Ativa o novo formato de gravacao do Id nos campos _SERIE
endIf

nField := GetSerieSDoc(AllTrim(cCpoOrig)) //aScan( aCpoSerie , { |x|  AllTrim(x[1]) == AllTrim(cCpoOrig) } )

If nField > 0

	cSerieGrv := Substr(cSerieGrv,1,3)
	
	cCpoEmUso := aCpoSerie[nField][IIf(!lUsaNewKey, 1, 2)] // Campo Original
	
	If nOpcao == 1  

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Uso para gravacao dos campos _SERIE, ao utilizar,sempre em qualquer cenario³
		//³serao gravados os dois campos, _SERIE e o _SDOC.                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If !Empty(cNewIdPai)
			
			cSerieGrv := Substr( cNewIdPai ,1 ,3 )

			If lUsaNewKey
				cNewId    := cNewIdPai
			EndIf
			
		Else
			cNewId := PadR(cSerieGrv,3)+StrZero(Month(dEmissao),2)+Str(Year(dEmissao),4)+cEspecie
		EndIf
		
		If lUsaNewKey
			
			&(cAlias+"->"+AllTrim(cCpoOrig)) := cNewId
			&(cAlias+"->"+cCpoEmUso) := cSerieGrv
			
		Else
			
			&(cAlias+"->"+AllTrim(cCpoOrig)) := cSerieGrv
			
			If (cAlias)->( FieldPos(AllTrim(aCpoSerie[nField][2])) ) > 0  // Retirar apos lancamento do Release 12.1.008 do Protheus 12
				
				&(cAlias+"->"+AllTrim(aCpoSerie[nField][2])) := cSerieGrv
				
			EndIf
			
		EndIf
		
	ElseIf nOPcao == 2  

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Uso para visualizacao dos campos serie em consulta, relatorios, .INIs³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
		xRetCpoUso := Substr(&(cAlias+"->"+cCpoEmUso),1,3)
		
	ElseIf nOPcao == 3 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retornar qual campo devera ser utilizado em Querys, Filtros, Arrays³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		xRetCpoUso := AllTrim(cCpoEmUso)
		
	ElseIf nOPcao == 4 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retornar a chave composta para o ID de Controle, util para se utilizar em rotinas com situacoes    ³
		//³especificas onde se necessite do conteudo gravado nos campos _SERIE conforme o cenario             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
		cNewId := PadR(cSerieGrv,3)+StrZero(Month(dEmissao),2)+Str(Year(dEmissao),4)+PadR(cEspecie,Len(SF1->F1_ESPECIE))
		
		If lUsaNewKey
			xRetCpoUso := cNewId // Retorna o ID composto para validar em dbseeks antes da gravacao
		Else
			xRetCpoUso := PadR(cSerieGrv,3) // Em caso de campos _SERIE com tamanho = 3 retorna a Serie Real
		EndIf
		
	ElseIf nOPcao == 5 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso o Usr estiver com o Dicionario Novo e ter alterado o grupo de campo dos campos _SERIE para 14 ³
		//³ativando assim o novo modo de gravacao, mas por algum motivo necessitar de um CriaVar com o tamanho³
		//³do campo serie real que e igual a 3.                                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
		xRetCpoUso := CriaVar( AllTrim(cCpoEmUso) )
		
		If Len(xRetCpoUso) == 14
			xRetCpoUso := CriaVar( AllTrim(aCpoSerie[nField][2]) )
		EndIf
		
	ElseIf nOPcao == 6
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso o Usr estiver com o Dicionario Novo e ter alterado o grupo de campo dos campos _SERIE para 14 ³
		//³ativando assim o novo modo de gravacao, mas por algum motivo necessitar do TAMSX3 do Novo campo    ³
		//³Serie _SDOC que e 3 para Serie Real.                                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		xRetCpoUso := TamSX3( AllTrim(cCpoEmUso))[1]
		
		If xRetCpoUso == 14  
			xRetCpoUso := TamSX3( AllTrim(aCpoSerie[nField][2]))[1]
		EndIf

	ElseIf nOPcao == 7		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso o Usr estiver com o Dicionario Novo e ter alterado o grupo de campo dos campos _SERIE para 14 ³
		//³ativando assim o novo modo de gravacao, mas por algum motivo necessitar do LABEL  do Novo campo    ³
		//³Serie _SDOC que e a Serie Real.                                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		xRetCpoUso := RetTitle(cCpoEmUso)

		If TamSX3( AllTrim(cCpoEmUso) )[1] == 14
			xRetCpoUso := RetTitle( AllTrim(aCpoSerie[nField][2]) )
		EndIf
		
	EndIf
	
EndIf


Return xRetCpoUso    

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdChvUn

Rotina de Instalacao do Novo Formato de gravacao dos campos _SERIE
para permitir a emissao e ou recebimento de documentos fiscais de
Entrada e saida com o mesmo numero e serie para um mesmo emitente
o processo e concuido em 4 Fases a partir desta funcao

Fase 1 - Altera o tamanho do SXG 094 do cliente de 3 para 14
Fase 2 - Calcula Estimativa de tempo para popular os campos _SDOC da base historica
Fase 3 - Copia o conteudo dos campos _SERIE para os campos _SDOC
Fase 4 - Altera o campo SHOWPESQ do SIX das tabelas que compoem o projeto

@Return ( Nil )

@author Alexandre Lemes
@since  21/10/2015
@version 1.0  

/*/
//------------------------------------------------------------------- 
Main Function UpdSerieNF()                                                      

DEFINE WINDOW oMainWnd FROM 001,001 TO 400,500 TITLE GetVersao(,.F.) COLOR CLR_BLACK,RGB(02,127,158) 
ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT Wizard()  

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Wizard
Wizard de chamada da MainProcess
@Return ( Nil )
@author Alexandre Lemes
@since  21/10/2015
@version 1.0  
/*/
//------------------------------------------------------------------- 
Static Function Wizard()

Local cHeader   := STR0001 // "Ativação da melhoria no processo de Emissão e/ou Recebimento de Documentos Fiscais."
Local cMessage  := STR0002 // "Esta funcionalidade atualiza o sistema com uma melhoria no processo de emissão e/ou recebimento de documentos fiscais com o mesmo número e série originados de um mesmo emitente."
Local cInforme  := "" 
Local cVerRPO   := GetRpoRelease()

Local lConcordo := .F.
Local lModoSm0  := .F.
                              
Local oBtnLink1 := Nil
Local oBtnLink2 := Nil
Local oBtnLink3 := Nil
Local oBtnEstat := Nil
Local oChkAceite:= Nil         
Local oProcess  := Nil

PRIVATE aEmpresa:= {}
PRIVATE aTotal  := {}
PRIVATE nTotReg := 0

cInforme += STR0003 // "Após a execução desta atualização, teremos a reinicialização do numerador dos documentos fiscais"
cInforme += STR0004 // " de saídas e a digitação dos documentos fiscais de entrada com mesmo número e série de forma melhorada, "
cInforme += STR0005 // "não necessitando mais de intervenções manuais caso já exista outro documento com a mesma chave na base de dados."
cInforme += "<br>"+CRLF
cInforme += STR0006 // "Atualmente no Brasil, temos duas legislações que podem demandar tal funcionalidade, o Ajuste SINIEF 07/05 referente a Nota Fiscal Eletrônica e o convênio ICMS 115/03:"
cInforme += "<br>"+CRLF
cInforme += "<br>"+CRLF
cInforme += "<br>"+CRLF
cInforme += STR0007 // "É imprescindível a leitura e o cumprimento das orientações da documentação ON-LINE, acesse o Link:"
cInforme += "<br>"+CRLF
cInforme += "<br>"+CRLF
cInforme += STR0008 // "ATENÇÃO !  Este processo só pode ser executado em modo EXCLUSIVO."
cInforme += CRLF
cInforme += STR0009 // "Faça um backup dos dicionários e da base de dados antes da atualização para eventuais falhas no processo."

SET DELETED ON

If MyOpenSm0Ex(lModoSm0) // Abre SM0 em modo Exclusivo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	O Processo so podera ser executado, caso a versao do sistema seja maior ou igual a 12.1.008³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Val(SubStr(cVerRPO,6,3)) >= 099
		
		SM0->( DbEval( {|| If(aScan(aEmpresa, {|x| x[1] == FWGrpCompany()}) == 0, AAdd(aEmpresa, {FWGrpCompany(),FWCodFil(),RecNo()}), .T.) },, {|| !SM0->(Eof())}) )

		DEFINE FONT oFont BOLD
		DEFINE WIZARD oWizard TITLE GetVersao(,.F.) ;
		HEADER I18N(cHeader);
		MESSAGE CRLF+cMessage;
		TEXT cInforme;
		PANEL NEXT {|| FWMsgRun(,{|oSay| MainProcess(oSay)},STR0010,STR0011 ) } ; //"Validando Empresas do Ambiente Protheus Aguarde..."
		FINISH {|| .T. } ;
		SIZE 000,000,600,700
		
		CREATE PANEL oWizard HEADER cHeader MESSAGE cMessage PANEL;
		BACK {|| .T.} NEXT {|| .T. } FINISH {|| .T.} EXEC {|| .T.}
		
		@085,015 SAY oBtnLink1 PROMPT "<b><u><font face='Tahoma' color='#000092' size='+1'>"+"http://http://www1.fazenda.gov.br/confaz/confaz/ajustes/2005/AJ_007_05.htm"+"</font></u></b>" SIZE 300,010 OF oWizard:oMPanel[1] HTML PIXEL
		oBtnLink1:bLClicked := {|| ShellExecute("open","http://www1.fazenda.gov.br/confaz/confaz/ajustes/2005/AJ_007_05.htm","","",1) }
		
		@105,015 SAY oBtnLink2 PROMPT "<b><u><font face='Tahoma' color='#000195' size='+1'>"+"http://www1.fazenda.gov.br/confaz/confaz/convenios/icms/2003/CV115_03.htm"+"</font></u></b>" SIZE 300,010 OF oWizard:oMPanel[1] HTML PIXEL
		oBtnLink2:bLClicked := {|| ShellExecute("open","http://www1.fazenda.gov.br/confaz/confaz/convenios/icms/2003/CV115_03.htm","","",1) }
		
		@140,015 SAY oBtnLink3 PROMPT "<b><u><font face='Tahoma' color='#000089' size='+1'>"+"http://tdn.totvs.com/pages/viewpage.action?pageId=210048797" SIZE 300,010 OF oWizard:oMPanel[1] HTML PIXEL
		oBtnLink3:bLClicked := {|| ShellExecute("open","http://tdn.totvs.com/pages/viewpage.action?pageId=210048797","","",1) }
		
		@210,015 CHECKBOX oChkAceite VAR lConcordo PROMPT STR0012 SIZE 080,010 OF oWizard:oMPanel[1] PIXEL//"Sim, li e aceito o termo acima."
		oChkAceite:bChange := {|| Iif( lConcordo , oBtnEstat:Show() , oBtnEstat:Hide() ) , Iif( lConcordo , oWizard:oNext:Enable() , oWizard:oNext:Disable() ) }
		oWizard:oNext:Disable()
		
		DEFINE FONT oFontB NAME "Arial" SIZE 0,-11 BOLD //"Estimar Performance da Atualização no Ambiente - (Estatística)"
		@210,143 BUTTON oBtnEstat PROMPT STR0013 SIZE 200, 020 OF oWizard:oMPanel[1] FONT oFontB PIXEL ; 
		ACTION {|| oProcess := MsNewProcess():New( {|| aTotal  := {} , nTotReg := 0 , Fase2_SDOC(oProcess,.T.) }, STR0014, STR0015 , .F.) , oProcess:Activate() } //"Calculando Estatistica..."
		oBtnEstat:Hide()
		
		ACTIVATE WIZARD oWizard CENTERED
		
		dbCloseAll()
		RpcClearEnv()
		Final(STR0016,STR0017) //"Término Normal","Cancelado pelo Usuário"
	Else
		AVISO( STR0018, CRLF + STR0019 + cVerRPO + "." + CRLF + CRLF + STR0020 + CRLF + CRLF + STR0021 , { "Ok" }, 3 ) // "Este processo só poderá ser executado em ambientes com repositório igual ou superior a 12.1.099."
		Final(STR0022) //"Término por repositório incompativel"
	EndIf

Else

	Final(STR0023) //"Empresa não aberta de forma exclusiva"

EndIf
           
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MainProcess

Esta rotina consulta todas as empresas do ambiente e verifica
se o Update pode ser aplicado, caso nao haja impedimentos chama
as demais funcoes para alterar o SXG, popular nos novos campos _SDOC
e alterar a SHOWPESQ dos Indices do SIX

@Return ( Nil )

@author Alexandre Lemes
@since  21/10/2015
@version 1.0  

/*/
//------------------------------------------------------------------- 
Static Function MainProcess(oSay)

Local nEmpresa 	 := 0
Local lUsaTMS    := .F.
Local cEmpresa   := ""		

For nEmpresa := 1 To Len(aEmpresa)
	
	SM0->(DbGoTo(aEmpresa[nEmpresa,3]))
	RpcSetType(3)
	RpcSetEnv( aEmpresa[nEmpresa,1] , aEmpresa[nEmpresa,2] )
	
	lMsFinalAuto:= .F.
	lMsErroAuto := .F.
	lMsHelpAuto := .F.
	__cInternet := Nil
 	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o objeto de texto do grafico de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    cEmpresa := aEmpresa[nEmpresa,1]
	oSay:cCaption := ( STR0024 + cEmpresa + "..." ) // "Validação de pré-requisitos da empresa: "
	ProcessMessages()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	O Processo nao pode ser executado em cliente que utilizam SIGATMS pois o recurso ainda nao ³
	//³	esta disponivel no Release 12.1.008. !!! Retirar apos a conclusao do modulo SIGATMS.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If IntTms()
		lUsaTMS := .T.
		Final(STR0025,STR0026) //"Este recurso ainda não está disponível para clientes que utilizam SIGATMS.""Entre em contato com a TOTVS para verificar a data de diponíbilidade."
	EndIf
	
Next nEmpresa

If !lUsaTMS
	Fase1_DIC(oSay)
	Fase2_SDOC(oSay,.F.)
EndIf

dbCloseAll()
RpcClearEnv()
Final(STR0027,STR0028) //"Processo Finalizado" "O ambiente foi atualizado com sucesso"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Fase1_DIC

Esta rotina altera o tamanho do grupo de campos SXG 
094-Id de Controle do Documentos Fiscais de 3 para 14 
LIGANDO o novo formato de gravacao do ID nos campos _SERIE
e Altera a SHOWPEQ dos indices do SIX dos campos _SERIE e _SDOC 

@Return ( Nil )

@author Alexandre Lemes
@since  21/10/2015
@version 1.0  

/*/
//------------------------------------------------------------------- 
Static Function Fase1_DIC(oSay)

Local aSIX_Serie:= ShowSixSDoc()[1]
Local aSIX_SDoc := ShowSixSDoc()[2]
Local nEmpresa  := 0
Local cEmpresa  := ""
Local nX        := 0

For nEmpresa := 1 To Len(aEmpresa)
	
	SM0->(DbGoTo(aEmpresa[nEmpresa,3]))
	RpcSetType(3)
	RpcSetEnv( aEmpresa[nEmpresa,1] , aEmpresa[nEmpresa,2] )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o objeto de texto do grafico de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cEmpresa := aEmpresa[nEmpresa,1]
	oSay:cCaption := ( STR0029 + cEmpresa + "  ..." ) //"FASE 1 - Atualizando grupo de campos do Dicionário da Empresa: "
	ProcessMessages()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FWUpdXG() - Funcao do Frame que altera o grupo de campos 094 - Id de Controle dos Documentos Fiscais³
	//³para o tamanho 14 - o que ATIVA o recurso do projeto CHAVE UNICA como LIGADO.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FWUpdXG("094",14,"!!!")
	
	DbSelectArea("SIX")
	SIX->(dBSetOrder(1))

	oSay:cCaption := ( STR0030 + cEmpresa + "  ..." ) //"FASE 1 - Atualizando os Indices do Dicionário da Empresa: "
	ProcessMessages()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desliga a apresentacao de todos os indices _SERIE.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aSIX_Serie)
		If SIX->( dbSeek( AllTrim(aSIX_Serie[nX,01]) ) )
			// *** Altera o campo SHOWPESQ na SIX ***
			If RecLock( "SIX", .F. )
				SIX->SHOWPESQ  := "N"
			EndIf
			SIX->( MsUnlock() )
		EndIf
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Liga a apresentacao de todos os indices _SDOC.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aSIX_SDoc)
		If SIX->( dbSeek( AllTrim(aSIX_SDoc[nX,01]) ) )
			// *** Altera o campo SHOWPESQ na SIX ***
			If RecLock( "SIX", .F. )
				SIX->SHOWPESQ  := "S"
			EndIf
			SIX->( MsUnlock() )
		EndIf
	Next nX

Next nEmpresa

Return

//"FASE 2 - Estimando o tempo para atualizar base histórica..."

//-------------------------------------------------------------------
/*/{Protheus.doc} Fase2_SDOC

Calcula a estimativa de tempo para realizar o UPDATE dos campos _SDOC
na base Historica do Ambiente

@Return ( Nil )

@author Fabio V Santana
@since  05/08/2015
@version 1.0  

/*/
//------------------------------------------------------------------- 
Static Function Fase2_SDOC(oProcess,lEstimativa)

Local nX       := 0
Local nY 	   := 0
Local nEmpresa := 0
Local nTotal   := 0
Local nSegundos:= 1
Local nStart   := 0
Local nElapsed := 0

Local cTable   := ""
Local cAlias   := ""
Local cMsg	   := ""

Local lModoSm0  := .T. // Abre SM0 em modo Compartilhado para o SMARTJOB

Local oDlgLogEnd:= Nil
Local oMemo     := Nil

Local aAlias   := {}
Local aCpoSerie:= SerieToSDoc() // Array contendo todos os campos e Alias do Projeto
Local aTempo   := {}

//Adiciona os Alias ao array aAlias apartir do array aCpoSerie
aEval(aCpoSerie,{|x| IIf(!Empty(x[3]),aAdd(aAlias,x[3]),)})

If Len(aTotal) == 0  
	
	//Regua de Processamento
	If lEstimativa
		oProcess:SetRegua1(Len(aEmpresa))
	EndIf	

	//Laco de filiais
	For nEmpresa := 1 To Len(aEmpresa)
		
		//Seleciono a empresa e seto o ambiente a ser processado
		SM0->(DbGoTo(aEmpresa[nEmpresa,3]))
		
		//Regua de Processamento por empresa
		If lEstimativa
			oProcess:IncRegua1( STR0031 + SM0->(M0_CODIGO + ' - ' + AllTrim(M0_NOME) )) // 'Empresa: '
		EndIf
		
		RpcSetType(3)
		RpcSetEnv(aEmpresa[nEmpresa,1])
		
		//Abre a tabela de Log CHZ ou popula caso nao exista
		GravaLog(1,aAlias,aEmpresa[nEmpresa,1])
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nesse momento, faco uma busca no sistema, para definir o tempo de execucao do UPDATE ³
		//³Apresento uma tela contendo a quantidade de registros, tabelas e tempo estimado	    ³
		//³Nesse momento ainda sera possivel cancelar o UPDATE	                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEstimativa
			oProcess:SetRegua2(Len(aAlias))
		EndIf

		For nX := 1 to Len(aAlias)
			
			//Processo somente as tabelas que existem no banco de dados
			If MsFile(RetSqlName(aAlias[nX]))
				
				If CHZ->(MsSeek(Padr(aEmpresa[nEmpresa,1],TamSx3("CHZ_FILIAL")[1])+aAlias[nX]))
					
					If CHZ->CHZ_STATUS == "2"
						
						//Regua de Processamento por tabelas
						If lEstimativa
							oProcess:IncRegua2( STR0032 + RetSqlName(aAlias[nX])  ) //'Processando tabela: '
						EndIf
						
						cAlias := GetNextAlias()
						cTable := "%"+RetSqlName(aAlias[nX])+"%"
						
						//Query contadora de registros
						BeginSql Alias cAlias
							SELECT Count(*) AS TotReg
							FROM %Exp:cTable%
						EndSql
						
						If (cAlias)->TotReg > 0
							//nTotal -> Estimativa em SEGUNDOS
							nTotal := ((cAlias)->TotReg * 0.0002)
							nSegundos += nTotal
							nTotReg	+= (cAlias)->TotReg
							
							// aTotal -> Nome da Tabela | Contador de Registro | Tempo Estimado | Empresa
							aAdd( aTotal , {aAlias[nX],(cAlias)->TotReg , nTotal, aEmpresa[nEmpresa,1]} )
						EndIF
						
						//Encerro o Alias
						If SELECT(cAlias)<>0
							(cAlias)->(DbCloseArea())
						EndIf
						
					EndIF
					
				EndIF
				
			EndIF
			
		Next nX
		
	Next nEmpresa
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao que transforma os segundo em horas:minutos ³
	//³Estabeleci como tempo minimo 1 Minuto             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTempo :=  ConvHora(nSegundos)
	
	If lEstimativa

		lMsFinalAuto:= .F.
		lMsErroAuto := .F.
		lMsHelpAuto := .F.
		__cInternet := Nil
		
		cMsg +=	"<br>"
		cMsg += STR0033 + "<b>" +Str(len(aTotal)) + "</b>" + CRLF   //"Tabelas a serem processadas: "
		cMsg +=	"<br>"
		cMsg +=	STR0034 + "<b>" +Str(nTotReg) + "</b> " + CRLF //"Quantidade de registros: "
		cMsg +=	"<br>"
		cMsg += STR0035 + "<b>" +Str(aTempo[1][1]) + "</b>" + " dia(s) " + "<b>" +Str(aTempo[1][2]) + "</b>" + " hora(s)" + " e " + "<b>" +Str(aTempo[1][3]) + "</b>" + " minuto(s)" + CRLF  //"Tempo Estimado: "
		
		MsgInfo(cMsg ,"<b>"+STR0036+"</b>")  //Resultado da análise do ambiente
	Else
		CONOUT( STR0033 + Str(len(aTotal)) )//"Tabelas a serem processadas: "
		CONOUT(	STR0034 + Str(nTotReg) ) //"Quantidade de registros: "
		CONOUT(	STR0035 + Str(aTempo[1][1]) + " dia(s) " + Str(aTempo[1][2]) + " hora(s)" + " e " + Str(aTempo[1][3]) + " minuto(s)" )
	EndIf

EndIf

lMsFinalAuto:= .F.
lMsErroAuto := .F.
lMsHelpAuto := .F.
__cInternet := Nil

If !lEstimativa
	
	If Len(aTotal) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³lModoSM0 = .T. Abre SM0 em modo Compartilhado por causa do sMartJob()³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MyOpenSm0Ex(lModoSm0) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Funcao responsavel por processar o UPDATE dos campos _SDOC.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nStart := Seconds()
			ProcUpd(aEmpresa,aTotal,aAlias,aCpoSerie,oProcess)
			nElapsed := Seconds() - nStart
			aTempo   := ConvHora(nElapsed)
		EndIf		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Mensagem de Conclusao do UPDATE dos campos _SDOC.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMsg := STR0037 + CRLF + CRLF  //"TABELAS PROCESSADAS -> TOTAL DE REGISTROS POR TABELA"
		
		For nY := 1 to len (aTotal)
			cMsg += AllTrim(RetSqlName(aTotal[nY][1])) + "     - >      " + AllTrim(Str(aTotal[nY][2])) + CRLF
		Next nY
		
		cMsg += CRLF
		cMsg += STR0038 + AllTrim(Str(len(aTotal))) + CRLF      //"TOTAL DE TABELAS: "
		cMsg += STR0039 + AllTrim(Str(nTotReg)) + CRLF        //"TOTAL DE REGISTROS: "
		cMsg += STR0040 + Str(aTempo[1][1]) + " dia(s) " + Str(aTempo[1][2]) + " hora(s)" + " e " + Str(aTempo[1][3]) + " minuto(s)" + CRLF //"TEMPO DE PROCESSAMENTO: "
		
		DEFINE WIZARD oDlgLogEnd TITLE GetVersao(,.F.) HEADER SPACE(45) + I18N(STR0041) PANEL SIZE 000,000,600,700 //"LOG DE ATUALIZAÇÃO"
		@ 005,005 GET oMemo VAR cMsg MEMO SIZE 340,220 OF oDlgLogEnd:oMPanel[1] PIXEL READONLY
		oDlgLogEnd:oCancel:Hide()
		ACTIVATE WIZARD oDlgLogEnd CENTERED
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Mensagem de que nao foi necessario o UPDATE dos campos _SDOC.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMsg += "<b>"
		cMsg += STR0042 //"O Update dos novos campos SERIE já foi concluído em todas as tabelas deste ambiente."
		cMsg += "<br><br>"
		cMsg += STR0043 // "Não será necessario realizar o Update novamente."
		cMsg += "</b><br><br>"
		MsgInfo(cMsg ,"<td colspan='5' align='center'><font face='Tahoma' size='+2'><b>Update Completo!</b></font></td>")
	EndIf
	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcUpd

Processa o UPDATE

@Return ( Nil )

@author Fabio V Santana
@since  05/08/2015
@version 1.0  

/*/
//------------------------------------------------------------------- 
Static Function ProcUpd(aEmpresa,aTotal,aAlias,aCpoSerie,oSay)

Local cTable 	:= ""
Local cWhere    := ""
Local cCampos   := ""

//Contadores
Local nFilial	:= 0
Local nPosTab	:= 0
Local nPosFil	:= 0
Local nX 		:= 0
Local nY 		:= 0

//Query
Local nLinBlock	:= 0
Local nRecSource:= 0
Local nQtSteps	:= 0

Local cEmpresa  := ""

// Tipo do banco de dados
Local cTipoDB	:= AllTrim(Upper(TcGetDb()))

//Laco de Filiais
For nFilial := 1 To Len(aEmpresa)
	
	//Posiciono na empresa e seto o ambiente a ser processado	
	SM0->(DbGoTo(aEmpresa[nFilial,3]))
	RpcSetType(3)
	RpcSetEnv(aEmpresa[nFilial,1])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o objeto de texto do grafico de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cEmpresa := aEmpresa[nFilial,1]
	oSay:cCaption := ( STR0044 + cEmpresa + "  ..." ) //"FASE 2 - Atualizando campos da base histórica da Empresa: "
	ProcessMessages()
		
	//Posiciono no registro exato para girar o array aTotal
	nPosFil:= aScan(aTotal,{|aX| aX[4]==aEmpresa[nFilial,1] })	

	If nPosFil > 0

		cEmpProc:= aTotal[nPosFil][4]		
					
		//Laco de registros ja selecionados no pre processamento
		For nX := nPosFil to Len(aTotal)
		
			//No momento em que mudar de empresa, paro de girar
			If aTotal[nPosFil][4] <> cEmpProc
				//Atualiza o Log das tabelas			
				GravaLog(2,aAlias,cEmpProc)
				Exit
			EndIf	
		
			//Limpo a variavel, pois sera utilizada para todas as querys
			cCampos := ""
			cWhere  := ""
		
			//Posiciono no registro exato para girar o aArray aCpoSerie
			nPosTab := aScan(aCpoSerie,{|aX| aX[3]==aTotal[nX][1]})		
			
			//Somente uma tabela por vez e por empresa, sera processada
			cTable := AllTrim(aCpoSerie[nPosTab][3])
			
			//Giro o array direto da posicao encontrada
			//Para evitar de girar desde a primeira aposicao
			For nY := nPosTab to Len(aCpoSerie)
				
				//No momento em que mudar de tabela, paro de girar para processar a query
				If aCpoSerie[nY][3] <> cTable
					Exit
				EndIF					
					
				//Para o primeiro campo, ainda nao adiciono a virgula
				If !Empty(cCampos)					
					cCampos += ","				
				EndIF
				
				//Faco o sustring para nao truncar a informacao
				//Pois o campo SERIE passa a possuir  14 posicoes
				If cTipoDB $ "ORACLE/DB2"
					cCampos += aCpoSerie[nY][2] + " = SUBSTR(" + aCpoSerie[nY][1] + ",1,3)"
				Else
					cCampos += aCpoSerie[nY][2] + " = SUBSTRING(" + aCpoSerie[nY][1] + ",1,3)"
				EndIf																
						
			Next nY
			
			//Limite de registros na query para evitar estourar o log do banco de dados - 4096
			nLinBlock := 4096
			
			//Total de registro da tabela a ser processada
			nRecSource := aTotal[nX][2]
			
			//Tabela a ser processada
			cTable := RetSqlName(cTable)			
			
			//nQtSteps recebe o numero de passos necessarios para poder processar a tabela em questao
			//Quantidade de registros / 10000
			nQtSteps := Int( nRecSource / nLinBlock ) + If( Empty( nRecSource % nLinBlock ), 0, 1 )
										
			CONOUT("Starting Job " + STRZERO(nX, 6))		
			CONOUT("Tabela " + cTable)
							
			//SmartJob
			SmartJob("Upd_SDOC", getEnvServer(),.T.,cTable,cCampos,cEmpProc,nLinBlock,nQtSteps,nRecSource,cEmpAnt)
			
		Next nX

	EndIf
	
	//WaitSmartJobs()
	
	CONOUT("", "Jobs finalizados!", "")
	
	//Atualiza o Log de todas as tabelas, atualizando o log de TODAS elas para "1 - Finalizada"		
	GravaLog(2,aAlias,cEmpProc)

Next nFilial

//WaitSmartJobs()
     
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Upd_SDOC

Processa a query

@Return ( Nil )

@author Fabio V Santana
@since  23/09/2015
@version 1.0  

/*/
//------------------------------------------------------------------- 
Function Upd_SDOC(cTable,cCampos,cEmpProc,nLinBlock,nQtSteps,nRecSource,cEmpAnt)

Local nStep    := 0
Local cRecStart:= ""
Local cRecEnd  := ""
Local cQuery   := ""

//Abro o ambiente
RpcSetType(3)
RpcSetEnv(cEmpAnt)

While nStep < nQtSteps
	
	//Recno inicial - de -> para
	cRecStart := AllTrim( Str( ( nStep * nLinBlock ) + 1 ) )
	
	//-------------------
	// Incrementa o passo
	//-------------------
	nStep++
	
	//Update direto na tabela selecionada
	cQuery := " UPDATE " + cTable
	cQuery += " SET " 	 + cCampos
	cQuery += " WHERE D_E_L_E_T_ = '' "
	cQuery += " AND R_E_C_N_O_>=" + cRecStart
	
	//Se ainda nao for o ultimo passo, processo do recno atual ate o Recno + 4096
	//Se for o ultimo passo, processo ate o recno final da tabela
	If !( nStep == nQtSteps )
		//--------------------------------------------------------
		// Se não for o último passo, define filtro de recno final
		//--------------------------------------------------------
		cRecEnd := AllTrim( Str( ( nStep * nLinBlock ) ) )
		cQuery += " AND R_E_C_N_O_<=" + cRecEnd
	EndIf
	
	//---------------------
	// Executa a query
	//---------------------
	If ( TCSqlExec( cQuery ) < 0)
		//Grava o Log caso o processamento da query seja abortado
		GravaLog(3,,cEmpProc,cTable,nRecSource,.F.)
		Exit
	EndIf
	
	TCRefresh(cTable)
	
EndDo

//Grava o Log da tabela atual, atualizando o STATUS para "1 - Finalizada"
GravaLog(3,,cEmpProc,cTable,nRecSource,.T.)

RpcClearEnv()

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaLog

Abre a tabela de log ou popula

@Return ( Nil )

@author Fabio V Santana
@since  06/08/2015
@version 1.0  

/*/
//------------------------------------------------------------------- 
Static Function GravaLog(nOpc,aAlias,cEmpProc,cTable,nQtdReg,lFim)

Local nY := 0
Default nOpc := 1
Default lFim := .F.

//Abro a CHZ
DbSelectArea("CHZ")
CHZ->(dBSetOrder(1))

If nOpc == 1
	//Cria a tabela CHZ e popula, caso esteja vazia.
	If ("CHZ")->(EOF()) .AND. ("CHZ")->(BOF())
		For nY := 1 to Len(aAlias)
			RecLock("CHZ",.T.)
			CHZ->CHZ_FILIAL := cEmpProc
			CHZ->CHZ_TABELA := aAlias[nY]
			CHZ->CHZ_QTDPRO := 0
			CHZ->CHZ_DTPROC := dDataBase
			CHZ->CHZ_STATUS := "2" //Status pendente
			MSUnlock()
		Next nY
	EndIf
ElseIf nOpc == 2
	//Atualiza o log de todas as tabela quando terminar o processamento,
	//ou quando termina de processar a filial corrente
	For nY := 1 to Len(aAlias)
		If CHZ->(MsSeek(Padr(cEmpProc,TamSx3("CHZ_FILIAL")[1])+aAlias[nY]))
			RecLock("CHZ",.F.)
			CHZ->CHZ_STATUS := "1" //Status ok
			MSUnlock()
		EndIf
	Next nY
	
ElseIf nOpc == 3
	//Atualiza o status de uma unica tabela, que foi processada até o fim, ou nao
	//se foi processada corretamente, gravo status 1, SENAO 2
	cTable := SubString(cTable,1,3)
	If CHZ->(MsSeek(Padr(cEmpProc,TamSx3("CHZ_FILIAL")[1])+cTable))
		If RecLock("CHZ", .F.)
			CHZ->CHZ_STATUS := If (lFim, "1" , "2" )
			CHZ->CHZ_QTDPRO := nQtdReg
			CHZ->CHZ_DTPROC := dDataBase
			MsUnlock()
		EndIf
	EndIf
EndIf

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} ConvHora

Converte segundos em dias / horas / minutos

@Return ( Nil )

@author Fabio V Santana
@since  06/08/2015
@version 1.0  

/*/
//------------------------------------------------------------------- 
Static Function ConvHora(nSegundos)

Local nMinuto	:= 0
Local nDecimal 	:= 0
Local nHora  	:= 0
Local nDias		:= 0
Local nDiasFull	:= 0
 
Local aTempo	:= {}

DEFAULT nSegundos := 0

If nSegundos > 0
	
	//3600 segundos = 1 hora
	nSegundos := nSegundos / 3600
	nDecimal := If (At(".",AllTrim(Str(nSegundos))) <= 0 , 0 , At(".",AllTrim(Str(nSegundos))))
	
	If nDecimal > 0
		nHora := Val(SubStr(AllTrim(Str(nSegundos)),1,nDecimal))
		
		nMinuto := nSegundos - Val(SubStr(AllTrim(Str(nHora)),1,nDecimal))
		nMinuto := (nMinuto * 60)
		
		nDecimal := At(".",AllTrim(Str(nMinuto)))
		
		If nDecimal > 0
			nMinuto := Val(SubStr(AllTrim(Str(nMinuto)),1,nDecimal))
		EndIF
	Else
		nHora := nSegundos
		nMinuto := 0
	EndIF
	
	If nHora > 23
		
		nDiasFull := nHora / 24
		nDecimal := If (At(".",AllTrim(Str(nDiasFull))) <= 0 , 0 , At(".",AllTrim(Str(nDiasFull))))
		
		If nDecimal > 0
			nDias := Val(SubStr(AllTrim(Str(nDiasFull)),1,nDecimal))
			nHora := nDiasFull - Val(SubStr(AllTrim(Str(nDias)),1,nDecimal))
			nHora := (nHora * 24)
			
			nDecimal := At(".",AllTrim(Str(nHora)))
			
			If nDecimal > 0
				nHora := Val(SubStr(AllTrim(Str(nHora)),1,nDecimal))
			EndIF
		Else
			nDias := nDiasFull
			nHora := 0
		EndIF
		
	EndIF
	
	If nDias + nHora + nMinuto = 0
		AADD(aTempo,{nDias,nHora,1})
	Else
		AADD(aTempo,{nDias,nHora,nMinuto})
	EndIF
	
EndIF

Return( aTempo )

//-------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0Ex

Efetua a abertura do SM0 exclusivo

@Return ( lOpen )

@author Alexandre Lemes
@since  21/10/2015
@version 1.0  
/*/
//------------------------------------------------------------------- 
Static Function MyOpenSM0Ex(lModoSm0)

Local lOpen:=.F.
Local nX   := 0

If SELECT("SM0") > 0
	SM0->(DbCloseArea())
EndIf

For nX := 1 To 20
	dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", lModoSm0, lModoSm0 ) 
	If !Empty( SELECT("SM0") ) 
		lOpen := .T. 
		dbSetIndex("SIGAMAT.IND") 
		EXIT	
	EndIf
	Sleep(500) 
Next nX 

If !lOpen 
	AVISO( STR0018 ,CRLF+CRLF+STR0045, { "Ok" }, 1 ) //"Não foi possível a abertura da tabela de empresas de forma exclusiva!"
EndIf                                 

Return(lOpen)

//-------------------------------------------------------------------
/*/{Protheus.doc} SerieToSDoc()

Retorna um array contendo todos os campos _SERIE e seus equivalentes
_SDOC e o Alias da tabela para o Porjeto Chave Unica

@Return ( aCpoSerie )

@author Alexandre Lemes
@since  21/10/2015
@version 1.0  

/*/
//------------------------------------------------------------------- 
Static Function SerieToSDoc()
Local nX as numeric 

If aCamposSer == NIL
	
	aCamposSer := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                            ATENCAO!!!                           ³
	//³Ao incluir NOVOS campos no array aCamposSer, verifique ANTES     ³
	//³de incluir se o ALIAS (Tabela) ja existe na posicao 3 dos campos ³
	//³existentes do aCamposSer. Caso ja EXISTA, ao incluir um novo ADD ³
	//³para o seu novo campo, crie a posicao 3 em BRANCO "   ". Somente ³
	//³informe o ALIAS do seu novo ADD caso ainda NAO exista a tabela   ³
	//³na posicao 3 do array aCamposSer.                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCamposSer := {	{"AA3_ULTSER","AA3_SDOC"  ,"AA3"},;
					{"AD0_SERIE" ,"AD0_SDOC"  ,"AD0"},;
					{"AFN_SERIE" ,"AFN_SDOC"  ,"AFN"},;
					{"AFO_SERIE" ,"AFO_SDOC"  ,"AFO"},;
					{"AFS_SERIE" ,"AFS_SDOC"  ,"AFS"},;
					{"AGH_SERIE" ,"AGH_SDOC"  ,"AGH"},;
					{"B19_SERIE" ,"B19_SDOC"  ,"B19"},;
					{"BM1_SERSF2","BM1_SDOCF2","BM1"},;
					{"BMN_SERSF2","BMN_SDOCF2","BMN"},;
					{"BTV_SERIE" ,"BTV_SDOC"  ,"BTV"},;
					{"CB0_SERIEE","CB0_SDOCE" ,"CB0"},;
					{"CB0_SERIES","CB0_SDOCS" ,"   "},;
					{"CB6_SERIE" ,"CB6_SDOC"  ,"CB6"},;
					{"CB7_SERIE" ,"CB7_SDOC"  ,"CB7"},;
					{"CB8_SERIE" ,"CB8_SDOC"  ,"CB8"},;
					{"CBE_SERIE" ,"CBE_SDOC"  ,"CBE"},;
					{"CBG_SERIEE","CBG_SDOCE" ,"CBG"},;
					{"CBG_SERIES","CBG_SDOCS" ,"   "},;
					{"CBK_SERIE" ,"CBK_SDOC"  ,"CBK"},;
					{"CBL_SERIE" ,"CBL_SDOC"  ,"CBL"},;
					{"CCX_SERIE" ,"CCX_SDOC"  ,"CCX"},;
					{"CD0_SERENT","CD0_SDOCE" ,"CD0"},;
					{"CD0_SERIE" ,"CD0_SDOC"  ,"   "},;
					{"CD2_SERIE" ,"CD2_SDOC"  ,"CD2"},;
					{"CD3_SERIE" ,"CD3_SDOC"  ,"CD3"},;
					{"CD4_SERIE" ,"CD4_SDOC"  ,"CD4"},;
					{"CD5_SERIE" ,"CD5_SDOC"  ,"CD5"},;
					{"CD6_SERIE" ,"CD6_SDOC"  ,"CD6"},;
					{"CD7_SERIE" ,"CD7_SDOC"  ,"CD7"},;
					{"CD8_SERIE" ,"CD8_SDOC"  ,"CD8"},;
					{"CD9_SERIE" ,"CD9_SDOC"  ,"CD9"},;
					{"CDA_SERIE" ,"CDA_SDOC"  ,"CDA"},;
					{"CDB_SERIE" ,"CDB_SDOC"  ,"CDB"},;
					{"CDC_SERIE" ,"CDC_SDOC"  ,"CDC"},;
					{"CDD_SERIE" ,"CDD_SDOC"  ,"CDD"},;
					{"CDD_SERREF","CDD_SDOCRF","   "},;
					{"CDE_SERIE" ,"CDE_SDOC"  ,"CDE"},;
					{"CDE_SERREF","CDE_SDOCRF","   "},;
					{"CDF_SERIE" ,"CDF_SDOC"  ,"CDF"},;
					{"CDG_SERIE" ,"CDG_SDOC"  ,"CDG"},;
					{"CDK_SERIE" ,"CDK_SDOC"  ,"CDK"},;
					{"CDK_SERECP","CDK_SDOCEC","   "},;
					{"CDL_SEREXP","CDL_SDOCEX","CDL"},;
					{"CDL_SERIE" ,"CDL_SDOC"  ,"   "},;
					{"CDL_SERORI","CDL_SDOCOR","   "},;
					{"CDM_SERIEE","CDM_SDOCE" ,"CDM"},;
					{"CDM_SERIES","CDM_SDOCS" ,"   "},;
					{"CDQ_SERIE" ,"CDQ_SDOC"  ,"CDQ"},;
					{"CDR_SERIE" ,"CDR_SDOC"  ,"CDR"},;
					{"CDS_SEREMB","CDS_SDOCEM","CDS"},;
					{"CDS_SERIE" ,"CDS_SDOC"  ,"   "},;
					{"CDT_SERIE" ,"CDT_SDOC"  ,"CDT"},;
					{"CDX_SERIE" ,"CDX_SDOC"  ,"CDX"},;
					{"CE2_SERINF","CE2_SDOC"  ,"CE2"},;
					{"CE5_SERIE" ,"CE5_SDOC"  ,"CE5"},;
					{"CE8_SERIE" ,"CE8_SDOC"  ,"CE8"},;
					{"CF4_SERIE" ,"CF4_SDOC"  ,"CF4"},;
					{"CF6_SERIE" ,"CF6_SDOC"  ,"CF6"},;
					{"CFF_SERIE" ,"CFF_SDOC"  ,"CFF"},;
					{"CG8_SERIE" ,"CG8_SDOC"  ,"CG8"},;
					{"CNG_SERIE" ,"CNG_SDOC"  ,"CNG"},; 
					{"CKQ_SERIE" ,"CKQ_SDOC"  ,"CKQ"},;
					{"CL5_SER"   ,"CL5_SDOC"  ,"CL5"},;
					{"CNI_SERIE" ,"CNI_SDOC"  ,"CNI"},;
					{"COG_SERIE" ,"COG_SDOC"  ,"COG"},;
					{"CPP_SERIE" ,"CPP_SDOC"  ,"CPP"},;
					{"CPQ_SERIE" ,"CPQ_SDOC"  ,"CPQ"},;
					{"D07_SERIE" ,"D07_SDOC"  ,"D07"},;
					{"D12_SERIE" ,"D12_SDOC"  ,"D12"},;
					{"D13_SERIE" ,"D13_SDOC"  ,"D13"},;
					{"DAI_SERIE" ,"DAI_SDOC"  ,"DAI"},;
					{"DAI_SERREM","DAI_SDOCRM","   "},;
					{"DB2_SERIE" ,"DB2_SDOC"  ,"DB2"},;
					{"DBB_SERIE" ,"DBB_SDOC"  ,"DBB"},;
					{"DCF_SERIE" ,"DCF_SDOC"  ,"DCF"},;
					{"DCF_SERORI","DCF_SDOCOR","   "},;
					{"DCN_SERIE" ,"DCN_SDOC"  ,"DCN"},;
					{"DCX_SERIE" ,"DCX_SDOC"  ,"DCX"},;
					{"DD9_SERIE" ,"DD9_SDOC"  ,"DD9"},;
					{"DD9_SERNFC","DD9_SDOCNF","   "},;
					{"DEB_SERIE" ,"DEB_SDOC"  ,"DEB"},;
					{"DEF_SERIE" ,"DEF_SDOC"  ,"DEF"},;
					{"DF1_SERIE" ,"DF1_SDOC"  ,"DF1"},;
					{"DF6_SERIE" ,"DF6_SDOC"  ,"DF6"},;
					{"DFN_SERIE" ,"DFN_SDOC"  ,"DFN"},;
					{"DFP_SERDCS","DFP_SDOCS" ,"DFP"},;
					{"DFP_SERDCT","DFP_SDOCT" ,"   "},;
					{"DFR_SERDCT","DFR_SDOCT" ,"DFR"},;
					{"DFS_SERDCT","DFS_SDOCT" ,"DFS"},;
					{"DFV_SERIE" ,"DFV_SDOC"  ,"DFV"},;
					{"DI9_SERIE" ,"DI9_SDOC"  ,"DI9"},;
					{"DIA_SERIE" ,"DIA_SDOC"  ,"DIA"},;
					{"DIB_SERIE" ,"DIB_SDOC"  ,"DIB"},;
					{"DIC_SERIE" ,"DIC_SDOC"  ,"DIC"},;
					{"DIH_SERIE" ,"DIH_SDOC"  ,"DIH"},;
					{"DII_SERIE" ,"DII_SDOC"  ,"DII"},;
					{"DIJ_SERIE" ,"DIJ_SDOC"  ,"DIJ"},;
					{"DIK_SERIE" ,"DIK_SDOC"  ,"DIK"},;
					{"DIM_SERIE" ,"DIM_SDOC"  ,"DIM"},;
					{"DIN_SERNFC","DIN_SDOCC" ,"DIN"},;
					{"DT5_SERIE" ,"DT5_SDOC"  ,"DT5"},;
					{"DT6_SERDCO","DT6_SDOCOR","DT6"},;
					{"DT6_SERIE" ,"DT6_SDOC"  ,"   "},;
					{"DT6_SERMAN","DT6_SDOCMN","   "},;
					{"DT8_SERIE" ,"DT8_SDOC"  ,"DT8"},;
					{"DTA_SERIE" ,"DTA_SDOC"  ,"DTA"},;
					{"DTC_SERDPC","DTC_SDOCPC","DTC"},;
					{"DTC_SERIE" ,"DTC_SDOC"  ,"   "},;
					{"DTC_SERNFC","DTC_SDOCC" ,"   "},;
					{"DTE_SERNFC","DTE_SDOCC" ,"DTE"},;
					{"DTX_SERMAN","DTX_SDOCMN","DTX"},;
					{"DU1_SERIE" ,"DU1_SDOC"  ,"DU1"},;
					{"DU1_SERNFC","DU1_SDOCC" ,"   "},;
					{"DU7_SERIE" ,"DU7_SDOC"  ,"DU7"},;
					{"DUA_SERIE" ,"DUA_SDOC"  ,"DUA"},;
					{"DUB_SERIE" ,"DUB_SDOC"  ,"DUB"},;
					{"DUD_SERBXE","DUD_SDOCBX","DUD"},;
					{"DUD_SERIE" ,"DUD_SDOC"  ,"   "},;
					{"DUD_SERMAN","DUD_SDOCMN","   "},;
					{"DUU_SERIE" ,"DUU_SDOC"  ,"DUU"},;
					{"DV4_SERIE" ,"DV4_SDOC"  ,"DV4"},;
					{"DV4_SERNFC","DV4_SDOCC" ,"   "},;
					{"DVS_SERIE" ,"DVS_SDOC"  ,"DVS"},;
					{"DVV_SERIE" ,"DVV_SDOC"  ,"DVV"},;
					{"DVX_SERIE" ,"DVX_SDOC"  ,"DVX"},;
					{"DXM_SERIE" ,"DXM_SDOC"  ,"DXM"},;
					{"DXS_SERNFS","DXS_SDOC"  ,"DXS"},;
					{"DY4_SERIE" ,"DY4_SDOC"  ,"DY4"},;
					{"DY4_SERNFC","DY4_SDOCC" ,"   "},;
					{"DYC_SERIE" ,"DYC_SDOC"  ,"DYC"},;
					{"DYJ_SERIE" ,"DYJ_SDOC"  ,"DYJ"},;
					{"DYN_SERMAN","DYN_SDOCMN","DYN"},;
					{"ED2_SERIE" ,"ED2_SDOC"  ,"ED2"},;
					{"ED8_SERIE" ,"ED8_SDOC"  ,"ED8"},;
					{"ED9_SERIE" ,"ED9_SDOC"  ,"ED9"},;
					{"EDH_SERIE" ,"EDH_SDOC"  ,"EDH"},;
					{"EE9_SERIE" ,"EE9_SDOC"  ,"EE9"},;
					{"EEM_SERIE" ,"EEM_SDOC"  ,"EEM"},;
					{"EES_SERIE" ,"EES_SDOC"  ,"EES"},;
					{"EEZ_A_SER" ,"EEZ_SDOCA" ,"EEZ"},;
					{"EEZ_SER"   ,"EEZ_SDOC"  ,"   "},;
					{"EI1_SERIE" ,"EI1_SDOC"  ,"EI1"},;
					{"EI2_SERIE" ,"EI2_SDOC"  ,"EI2"},;
					{"EI3_SE_NFC","EI3_SDOC"  ,"EI3"},;
					{"ELA_SERIE" ,"ELA_SDOC"  ,"ELA"},;
					{"EW1_SERNF" ,"EW1_SDOC"  ,"EW1"},;
					{"EW2_SERNF" ,"EW2_SDOC"  ,"EW2"},;
					{"EWI_SERIE" ,"EWI_SDOC"  ,"EWI"},;
					{"EYY_SERSAI","EYY_SDOCS" ,"EYY"},;
					{"EYY_SERENT","EYY_SDOCE" ,"   "},;
					{"FJT_SERIE" ,"FJT_SDOC"  ,"FJT"},;
					{"FN6_SERIE" ,"FN6_SDOC"  ,"FN6"},;
					{"FN8_SERIE" ,"FN8_SDOC"  ,"FN8"},;
					{"FR3_SERIE" ,"FR3_SDOC"  ,"FR3"},;
					{"FRF_SERDOC","FRF_SDOC"  ,"FRF"},;
					{"FRK_SERIE" ,"FRK_SDOC"  ,"FRK"},;
					{"GW1_ORISER","GW1_SDOCOR","GW1"},;
					{"GW1_SERDC" ,"GW1_SDOC"  ,"   "},;
					{"GW4_SERDC" ,"GW4_SDOCDC","GW4"},;
					{"GW8_SERDC" ,"GW8_SDOCDC","GW8"},;
					{"GWB_SERDC" ,"GWB_SDOCDC","GWB"},;
					{"GWE_SERDC" ,"GWE_SDOCDC","GWE"},;
					{"GWE_SERDT" ,"GWE_SDOCDT","   "},;
					{"GWH_SERDC" ,"GWH_SDOCDC","GWH"},;
					{"GWL_SERDC" ,"GWL_SDOCDC","GWL"},;
					{"GWM_SERDC" ,"GWM_SDOCDC","GWM"},;
					{"GWU_SERDC" ,"GWU_SDOC"  ,"GWU"},;
					{"GWW_SERDC" ,"GWW_SDOC"  ,"GWW"},;
					{"GXA_SERDC" ,"GXA_SDOC"  ,"GXA"},;
					{"HB6_SERIE" ,"HB6_SDOC"  ,"HB6"},;
					{"HD1_SERORI","HD1_SDOCO" ,"HD1"},;
					{"HD2_SERIE" ,"HD2_SDOC"  ,"HD2"},;
					{"HF1_SERIE" ,"HF1_SDOC"  ,"HF1"},;
					{"HF2_SERIE" ,"HF2_SDOC"  ,"HF2"},;
					{"JJ2_SERIE" ,"JJ2_SDOC"  ,"JJ2"},;
					{"MAX_SERIE" ,"MAX_SDOC"  ,"MAX"},;
					{"MB1_SERIE" ,"MB1_SDOC"  ,"MB1"},;
					{"MBJ_SERIE" ,"MBJ_SDOC"  ,"MBJ"},;
					{"MBN_SERIE" ,"MBN_SDOC"  ,"MBN"},;
					{"MBR_SERIE" ,"MBR_SDOC"  ,"MBR"},;
					{"MBZ_SERIE" ,"MBZ_SDOC"  ,"MBZ"},;
					{"MDD_SERIR" ,"MDD_SDOCRC","MDD"},;
					{"MDD_SERIV" ,"MDD_SDOCVD","   "},;
					{"MDH_SERIE" ,"MDH_SDOC"  ,"MDH"},;
					{"MDJ_SERIE" ,"MDJ_SDOC"  ,"MDJ"},;
					{"MDK_SERIE" ,"MDK_SDOC"  ,"MDK"},;
					{"MDL_SERIE" ,"MDL_SDOC"  ,"MDL"},;
					{"MDU_SERIE" ,"MDU_SDOC"  ,"MDU"},;
					{"ME4_SERIE" ,"ME4_SDOC"  ,"ME4"},;
					{"MFI_SERIE" ,"MFI_SDOC"  ,"MFI"},;
					{"NNT_SERIE" ,"NNT_SDOC"  ,"MNT"},;
					{"NOA_SERDOC","NOA_SDOC"  ,"NOA"},;
					{"NPA_NFSSER","NPA_SDOC"  ,"NPA"},;
					{"NPM_SERNFS","NPM_SDOC"  ,"NPM"},;
					{"NXA_SERIE" ,"NXA_SDOC"  ,"NXA"},;
					{"QEK_SERINF","QEK_SDOC"  ,"QEK"},;
					{"QEL_SERINF","QEL_SDOC"  ,"QEL"},;
					{"QEP_SERINF","QEP_SDOC"  ,"QEP"},;
					{"QER_SERINF","QER_SDOC"  ,"QER"},;
					{"QEY_SERINF","QEY_SDOC"  ,"QEY"},;
					{"QEZ_SERINF","QEZ_SDOC"  ,"QEZ"},;
					{"RHU_SERIE" ,"RHU_SDOC"  ,"RHU"},;
					{"B6_SERIE"  ,"B6_SDOC"   ,"SB6"},;
					{"B7_SERIE"  ,"B7_SDOC"   ,"SB7"},;
					{"B8_SERIE"  ,"B8_SDOC"   ,"SB8"},;
					{"C5_SERIE"  ,"C5_SDOC"   ,"SC5"},;
					{"C5_SERSUBS","C5_SDOCSUB","   "},;
					{"C6_D1SERIE","C6_SDOCSD1","SC6"},;
					{"C6_SERDED" ,"C6_SDOCDED","   "},;
					{"C6_SERIE"  ,"C6_SDOC"   ,"   "},;
					{"C6_SERIORI","C6_SDOCORI","   "},;
					{"C9_SERIENF","C9_SDOCNF" ,"SC9"},;
					{"C9_SERIREM","C9_SDOCREM","   "},;
					{"CU_SERNCP" ,"CU_SDOCNCP","SCU"},;
					{"CU_SERNF"  ,"CU_SDOCNF" ,"   "},;
					{"D1_SERIE"  ,"D1_SDOC"   ,"SD1"},;
					{"D1_SERIORI","D1_SDOCORI","   "},;
					{"D1_SERIREM","D1_SDOCREM","   "},;
					{"D1_SERVINC","D1_SDOCVNC","   "},;
					{"D2_SERIE"  ,"D2_SDOC"   ,"SD2"},;
					{"D2_SERIORI","D2_SDOCORI","   "},;
					{"D2_SERIREM","D2_SDOCREM","   "},;
					{"D2_SERMAN" ,"D2_SDOCMAN","   "},;
					{"D5_SERIE"  ,"D5_SDOC"   ,"SD5"},;
					{"D7_SERIE"  ,"D7_SDOC"   ,"SD7"},;
					{"D8_SERIE"  ,"D8_SDOC"   ,"SD8"},;
					{"D9_SERIE"  ,"D9_SDOC"   ,"SD9"},;
					{"DA_SERIE"  ,"DA_SDOC"   ,"SDA"},;
					{"DB_SERIE"  ,"DB_SDOC"   ,"SDB"},;
					{"DE_SERIE"  ,"DE_SDOC"   ,"SDE"},;
					{"DS_SERIE"  ,"DS_SDOC"   ,"SDS"},;
					{"DT_SERIE"  ,"DT_SDOC"   ,"SDT"},;
					{"DT_SERIORI","DT_SDOCORI","   "},;
					{"E1_SERIE"  ,"E1_SDOC"   ,"SE1"},;
					{"E1_SERREC" ,"E1_SDOCREC","   "},;
					{"E3_SERIE"  ,"E3_SDOC"   ,"SE3"},;
					{"E5_SERREC" ,"E5_SDOCREC","SE5"},;
					{"EF_SERIE"  ,"EF_SDOC"   ,"SEF"},;//{"EK_SERORI" ,"EK_SDOCORI","SEK}) Nao Foi encontrado no ATUSX Localizado Peru - Retirado do projeto Alinhado com Paulo Pouza 
					{"EL_SERIE"  ,"EL_SDOC"   ,"SEL"},;
					{"EM_SERIE"  ,"EM_SDOC"   ,"SEM"},;
					{"EU_SERCOMP","EU_SDOCCOM","SEU"},;
					{"EU_SERIE"  ,"EU_SDOC"   ,"   "},;
					{"EX_SERREC" ,"EX_SDOCREC","SEX"},;
					{"EY_SERIE"  ,"EY_SDOC"   ,"SEY"},;
					{"F1_SERIE"  ,"F1_SDOC"   ,"SF1"},;
					{"F1_SERORIG","F1_SDOCORI","   "},;
					{"F1_SERMAN" ,"F1_SDOCMAN","   "},;
					{"F2_NEXTSER","F2_SDOCNXT","SF2"},;
					{"F2_SERIE"  ,"F2_SDOC"   ,"   "},;
					{"F2_SERIORI","F2_SDOCORI","   "},;
					{"F2_SERSUBS","F2_SDOCSUB","   "},;
					{"F2_SERMAN" ,"F2_SDOCMAN","   "},;
					{"F2_SERMDF" ,"F2_SDOCMDF","   "},;
					{"F3_SERIE"  ,"F3_SDOC"   ,"SF3"},;
					{"F3_SERMAN" ,"F3_SDOCMAN","   "},;
					{"F6_SERIE"  ,"F6_SDOC"   ,"SF6"},;
					{"F8_SEDIFRE","F8_SDOCFRE","SF8"},;
					{"F8_SERORIG","F8_SDOCORI","   "},;
					{"F9_SERNFE" ,"F9_SDOCNFE","SF9"},;
					{"F9_SERNFS" ,"F9_SDOCNFS","   "},;
					{"FE_SERIE"  ,"FE_SDOC"   ,"SFE"},;
					{"FE_SERIEC" ,"FE_SDOCC"  ,"   "},;
					{"FS_SERIE"  ,"FS_SDOC"   ,"SFS"},;
					{"FT_SERIE"  ,"FT_SDOC"   ,"SFT"},;
					{"FT_SERORI" ,"FT_SDOCORI","   "},;
					{"FU_SERIE"  ,"FU_SDOC"   ,"SFU"},;
					{"FX_SERIE"  ,"FX_SDOC"   ,"SFX"},;
					{"GIC_SERNFS","GIC_SDOCNF","GIC"},;
					{"L1_SERIE"  ,"L1_SDOC"   ,"SL1"},;
					{"L1_SERPED" ,"L1_SDOCPED","   "},;
					{"L1_SERRPS" ,"L1_SDOCRPS","   "},;
					{"L1_SUBSERI","L1_SDOCSUB","   "},;
					{"L2_SERIE"  ,"L2_SDOC"   ,"SL2"},;
					{"L2_SERPED" ,"L2_SDOCPED","   "},;
					{"L6_SERIE"  ,"L6_SDOC"   ,"SL6"},;
					{"LQ_SERIE"  ,"LQ_SDOC"   ,"SLQ"},;
					{"LQ_SERPED" ,"LQ_SDOCPED","   "},;
					{"LQ_SERRPS" ,"LQ_SDOCRPS","   "},;
					{"LQ_SUBSERI","LQ_SDOCSUB","   "},;
					{"LR_SERIE"  ,"LR_SDOC"   ,"SLR"},;
					{"LR_SERPED" ,"LR_SDOCPED","   "},;
					{"LS_SERIE"  ,"LS_SDOC"   ,"SLS"},;
					{"LX_SERIE"  ,"LX_SDOC"   ,"SLX"},;
					{"N1_NSERIE" ,"N1_SDOC"   ,"SN1"},;
					{"N4_SERIE"  ,"N4_SDOC"   ,"SN4"},;
					{"N7_SERIE"  ,"N7_SDOC"   ,"SN7"},;
					{"NM_SERIE"  ,"NM_SDOC"   ,"SNM"},;
					{"TL_SERIE"  ,"TL_SDOC"   ,"STL"},;
					{"TT_SERIE"  ,"TT_SDOC"   ,"STT"},;
					{"UA_SERIE"  ,"UA_SDOC"   ,"SUA"},;
					{"W6_SE_NF"  ,"W6_SDOC"   ,"SW6"},;
					{"W6_SE_NFC" ,"W6_SDOCC"  ,"   "},;
					{"WD_SE_NFC" ,"WD_SDOCC"  ,"SWD"},;
					{"WD_SERIE"  ,"WD_SDOC"   ,"   "},;
					{"WD_SE_DOC" ,"WD_SDOCSE" ,"   "},;
					{"WN_SERIE"  ,"WN_SDOC"   ,"SWN"},;
					{"WN_SERORI" ,"WN_SDOCORI","   "},;
					{"WW_SE_NFC" ,"WW_SDOC"   ,"SWW"},;
					{"TE0_SERIE" ,"TE0_SDOC"  ,"TE0"},;
					{"TE1_SERIE" ,"TE1_SDOC"  ,"TE1"},;
					{"TE2_SERIE" ,"TE2_SDOC"  ,"TE2"},;
					{"TEW_SERENT","TEW_SDOCE" ,"TEW"},;
					{"TEW_SERSAI","TEW_SDOCS" ,"   "},;
					{"TR7_SERIE" ,"TR7_SDOC"  ,"TR7"},;
					{"VD2_SERNFI","VD2_SDOC"  ,"VD2"},;
					{"VDD_SERNFI","VDD_SDOC"  ,"VDD"},;
					{"VDR_NFESER","VDR_SDOCE" ,"VDR"},;
					{"VDR_NFSSER","VDR_SDOCS" ,"   "},;
					{"VDU_SERDOC","VDU_SDOC"  ,"VDU"},;
					{"VDV_ESERNF","VDV_SDOCE" ,"VDV"},;
					{"VDV_SSERNF","VDV_SDOCS" ,"   "},;
					{"VE6_SERNFI","VE6_SDOC"  ,"VE6"},;
					{"VEC_SERNFI","VEC_SDOC"  ,"VEC"},;
					{"VEC_SERORI","VEC_SDOCOR","   "},;
					{"VEO_SERNFI","VEO_SDOC"  ,"VEO"},;
					{"VF3_SERNFI","VF3_SDOC"  ,"VF3"},;
					{"VG5_SERENT","VG5_SDOCE" ,"VG5"},;
					{"VG5_SERIEN","VG5_SDOCS" ,"   "},;
					{"VG6_SERENT","VG6_SDOCE" ,"VG6"},;
					{"VG6_SERNFI","VG6_SDOCS" ,"   "},;
					{"VG8_SERENT","VG8_SDOCE" ,"VG8"},;
					{"VG8_SERNFC","VG8_SDOCC" ,"   "},;
					{"VG8_SERNFI","VG8_SDOCS" ,"   "},;
					{"VGA_SERFEC","VGA_SDOCC" ,"VGA"},;
					{"VGA_SERIEN","VGA_SDOCE" ,"   "},;
					{"VGC_SERFEC","VGC_SDOC"  ,"VGC"},;
					{"VI0_SERNFI","VI0_SDOC"  ,"VI0"},;
					{"VI6_SERNFI","VI6_SDOC"  ,"VI6"},;
					{"VI7_SERIE" ,"VI7_SDOC"  ,"VI7"},;
					{"VI7_SERNFI","VI7_SDOCNF","   "},;
					{"VIA_SERNFI","VIA_SDOC"  ,"VIA"},;
					{"VIE_SERNFI","VIE_SDOC"  ,"VIE"},;
					{"VIK_SERNFI","VIK_SDOC"  ,"VIK"},;
					{"VIK_SERORI","VIK_SDOCOR","   "},;
					{"VIN_SERNFI","VIN_SDOC"  ,"VIN"},;
					{"VIP_SERIE" ,"VIP_SDOC"  ,"VIP"},;
					{"VIP_SERNFI","VIP_SDOCNF","   "},;
					{"VIQ_SERNFI","VIQ_SDOC"  ,"VIQ"},;
					{"VIV_SERNFI","VIV_SDOC"  ,"VIV"},;
					{"VIW_SERNFI","VIW_SDOC"  ,"VIW"},;
					{"VJ3_SERNFI","VJ3_SDOC"  ,"VJ3"},;
					{"VJ5_SERNFI","VJ5_SDOC"  ,"VJ5"},;
					{"VJC_SERNFI","VJC_SDOC"  ,"VJC"},;
					{"VJI_SERNFI","VJI_SDOC"  ,"VJI"},;
					{"VMB_SRANTE","VMB_SDOCA" ,"VMB"},;
					{"VMB_SRVSNF","VMB_SDOC"  ,"   "},;
					{"VO3_SERNFI","VO3_SDOC"  ,"VO3"},;
					{"VO4_SERNFI","VO4_SDOC"  ,"VO4"},;
					{"VOO_SERNFI","VOO_SDOC"  ,"VOO"},;
					{"VQ1_SERNFI","VQ1_SDOC"  ,"VQ1"},;
					{"VQ2_SERNFI","VQ2_SDOC"  ,"VQ2"},;
					{"VQ4_SERNFI","VQ4_SDOC"  ,"VQ4"},;
					{"VRF_SERNFI","VRF_SDOC"  ,"VRF"},;
					{"VS1_SERNFI","VS1_SDOC"  ,"VS1"},;
					{"VSC_SERNFI","VSC_SDOC"  ,"VSC"},;
					{"VSY_SERNFI","VSY_SDOC"  ,"VSY"},;
					{"VSZ_SERNFI","VSZ_SDOC"  ,"VSZ"},;
					{"VV0_SERNFI","VV0_SDOC"  ,"VV0"},;
					{"VV0_SNFFDI","VV0_SDOCFD","   "},;
					{"VV0_SNFCOM","VV0_SDOCCO","   "},;
					{"VV9_SERNFI","VV9_SDOC"  ,"VV9"},;
					{"VVD_SERNFI","VVD_SDOC"  ,"VVD"},;
					{"VVF_SERNFI","VVF_SDOC"  ,"VVF"},;
					{"VZK_SERNFI","VZK_SDOC"  ,"VZK"},;
					{"DH_SERIE"  ,"DH_SDOC"   ,"SDH"},;
					{"F0S_SERCRE","F0S_SDOCCR","F0S"},;
					{"F0S_SERSAI","F0S_SDOCSA","   "},;
					{"CDV_SERIE" ,"CDV_SDOC"  ,"CDV"} }
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                            ATENCAO!!!                           ³
	//³Ao incluir NOVOS campos no array aCamposSer, verifique ANTES     ³
	//³de incluir se o ALIAS (Tabela) ja existe na posicao 3 dos campos ³
	//³existentes do aCamposSer. Caso ja EXISTA, ao incluir um novo ADD ³
	//³para o seu novo campo, crie a posicao 3 em BRANCO "   ". Somente ³
	//³informe o ALIAS do seu novo ADD caso ainda NAO exista a tabela   ³
	//³na posicao 3 do array aCamposSer.                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oCposSerie == nil 
		oCposSerie := JsonObject():New()
	EndIf 

	//- guarda o nome do Campo com a posição
	For nX := 1 to Len(aCamposSer)
		oCposSerie[Alltrim(aCamposSer[nX,1])]:= nX
	Next nX 
EndIf

Return aCamposSer


//-------------------------------------------------------------------
/*/{Protheus.doc} ShowSixSDoc()

Retorna 2 arrays contendo todos os indices que contem os campos _SERIE e
_SDOC que compoem o projeto Chave Unica, o primeiro array contem todos os
indices originais que contem os campos _SERIE e estao com o SHOWPESQ = "S"
indicando que estes indices serão os indices apresentados em todos os browses
de pesquisa do Protheus (Padrao ATUSX);
o Segundo aArray de retorno contem todos os indices (Clonados) dos _SERIE com
os campos _SDOC que saem no padrao do ATUSX com o SHOWPESQ = "N" indicando 
que estes indices NAO serão apresentados nos browses.

A funcao sera utilizada pelo UpdSerieNF para alterar o SHOWPESQ dos indices originais
dos campos _SERIE de "S" para "N" e dos novos indices com _SDOC de "N" para "S" quando
o programa ativa o recurso do novo formato de gravacao, quando isso ocorrer os indices
a serem apresentados nos BROWSES serao os indices com _SDOC em detrimentos dos originais 
com _SERIE

@Return ( aSIX_Serie , aSIX_SDoc )

@author Alexandre Lemes
@since  21/10/2015
@version 1.0  

/*/
//------------------------------------------------------------------- 
Static Function ShowSixSDoc()

Local aSIX_Serie:= {}
Local aSIX_SDoc := {}
Local lExistCFF := CFF->(FieldPos('CFF_TIPO')) > 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O Array aSIX_SERIE contem todos os indices originais do Protheus³
//³que possuem campos relacionados com a serie do documento fiscal ³
//³e que originalmente saem da TOTVS Nov/2015 ATUSX com o SHOWPESQ ³
//³= "S" Mostrados nos browses de pesquisa.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aSIX_Serie , {"AD01","AD0_FILIAL+AD0_CNPJ+AD0_SERIE+AD0_DOC	"})
aAdd( aSIX_Serie , {"AFN1","AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_ITEM	"})
aAdd( aSIX_Serie , {"AFN2","AFN_FILIAL+AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_ITEM+AFN_PROJET+AFN_REVISA+AFN_TAREFA	"})
aAdd( aSIX_Serie , {"AFN6","AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_ITEM	"})
aAdd( aSIX_Serie , {"AGH1","AGH_FILIAL+AGH_NUM+AGH_SERIE+AGH_FORNEC+AGH_LOJA+AGH_ITEMPD+AGH_ITEM	"})
aAdd( aSIX_Serie , {"AGH2","AGH_FILIAL+AGH_NUM+AGH_SERIE+AGH_ITEMPD+AGH_ITEM	"})
aAdd( aSIX_Serie , {"B191","B19_FILIAL+B19_DOC+B19_SERIE+B19_FORNEC+B19_LOJA	"})
aAdd( aSIX_Serie , {"CB06","CB0_FILIAL+CB0_NFENT+CB0_SERIEE+CB0_FORNEC+CB0_LOJAFO+CB0_CODPRO	"})
aAdd( aSIX_Serie , {"CB09","CB0_FILIAL+CB0_FORNEC+CB0_LOJAFO+CB0_CODPRO+CB0_NFENT+CB0_SERIEE+CB0_ITNFE	"})
aAdd( aSIX_Serie , {"CB74","CB7_FILIAL+CB7_NOTA+CB7_SERIE+CB7_LOCAL+CB7_STATUS	"})
aAdd( aSIX_Serie , {"CB85","CB8_FILIAL+CB8_NOTA+CB8_SERIE+CB8_ITEM+CB8_SEQUEN+CB8_PROD	"})
aAdd( aSIX_Serie , {"CBE1","CBE_FILIAL+CBE_CODETI+CBE_NOTA+CBE_SERIE+CBE_FORNEC+CBE_LOJA+CBE_CODPRO+CBE_LOTECT+DTOS(CBE_DTVLD)	"})
aAdd( aSIX_Serie , {"CBE2","CBE_FILIAL+CBE_NOTA+CBE_SERIE+CBE_FORNEC+CBE_LOJA+CBE_CODPRO+CBE_CODETI	"})
aAdd( aSIX_Serie , {"CBG5","CBG_FILIAL+CBG_NOTAE+CBG_SERIEE+CBG_FORN+CBG_LOJFOR+DTOS(CBG_DATA)+CBG_HORA	"})
aAdd( aSIX_Serie , {"CBG6","CBG_FILIAL+CBG_NOTAS+CBG_SERIES+DTOS(CBG_DATA)+CBG_HORA	"})
aAdd( aSIX_Serie , {"CBK1","CBK_FILIAL+CBK_DOC+CBK_SERIE+CBK_CLIENT+CBK_LOJA	"})
aAdd( aSIX_Serie , {"CBL1","CBL_FILIAL+CBL_DOC+CBL_SERIE+CBL_CODETI+CBL_PROD	"})
aAdd( aSIX_Serie , {"CBL2","CBL_FILIAL+CBL_DOC+CBL_SERIE+CBL_CLIENT+CBL_LOJA	"})
aAdd( aSIX_Serie , {"CCX1","CCX_FILIAL+CCX_DOC+CCX_SERIE+CCX_CLIENT+CCX_LOJA+CCX_ITEM	"})
aAdd( aSIX_Serie , {"CCX2","CCX_FILIAL+CCX_DOC+CCX_SERIE+CCX_CLIENT+CCX_LOJA+CCX_PROCA	"})
aAdd( aSIX_Serie , {"CCX3","CCX_FILIAL+CCX_DOC+CCX_SERIE+CCX_CLIENT+CCX_LOJA+DTOS(CCX_DTAPUR)	"})
aAdd( aSIX_Serie , {"CCX4","CCX_FILIAL+CCX_DOC+CCX_SERIE+CCX_ITEM+CCX_CLIENT+CCX_LOJA+DTOS(CCX_DTAPUR)	"})
aAdd( aSIX_Serie , {"CD01","CD0_FILIAL+CD0_TPMOV+CD0_SERIE+CD0_DOC+CD0_CLIFOR+CD0_LOJA+CD0_ITEM+CD0_COD	"})
aAdd( aSIX_Serie , {"CD21","CD2_FILIAL+CD2_TPMOV+CD2_SERIE+CD2_DOC+CD2_CODCLI+CD2_LOJCLI+CD2_ITEM+CD2_CODPRO+CD2_IMP	"})
aAdd( aSIX_Serie , {"CD22","CD2_FILIAL+CD2_TPMOV+CD2_SERIE+CD2_DOC+CD2_CODFOR+CD2_LOJFOR+CD2_ITEM+CD2_CODPRO+CD2_IMP	"})
aAdd( aSIX_Serie , {"CD31","CD3_FILIAL+CD3_TPMOV+CD3_SERIE+CD3_DOC+CD3_CLIFOR+CD3_LOJA+CD3_ITEM+CD3_COD	"})
aAdd( aSIX_Serie , {"CD32","CD3_FILIAL+CD3_ESPEC+CD3_TPMOV+CD3_SERIE+CD3_DOC+CD3_CLIFOR+CD3_LOJA+CD3_ITEM+CD3_COD	"})
aAdd( aSIX_Serie , {"CD41","CD4_FILIAL+CD4_TPMOV+CD4_SERIE+CD4_DOC+CD4_CLIFOR+CD4_LOJA+CD4_ITEM+CD4_COD	"})
aAdd( aSIX_Serie , {"CD42","CD4_FILIAL+CD4_TPMOV+CD4_ESPEC+CD4_SERIE+CD4_DOC+CD4_CLIFOR+CD4_LOJA+CD4_ITEM+CD4_COD	"})
aAdd( aSIX_Serie , {"CD51","CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_DOCIMP+CD5_NADIC	"})
aAdd( aSIX_Serie , {"CD53","CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_DOCIMP+STR(CD5_ALPIS,5,2)+STR(CD5_ALCOF,5,2)+CD5_NADIC+CD5_SQADIC	"})
aAdd( aSIX_Serie , {"CD54","CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_ITEM	"})
aAdd( aSIX_Serie , {"CD61","CD6_FILIAL+CD6_TPMOV+CD6_SERIE+CD6_DOC+CD6_CLIFOR+CD6_LOJA+CD6_ITEM+CD6_COD+CD6_PLACA+CD6_TANQUE	"})
aAdd( aSIX_Serie , {"CD71","CD7_FILIAL+CD7_TPMOV+CD7_SERIE+CD7_DOC+CD7_CLIFOR+CD7_LOJA+CD7_ITEM+CD7_COD	"})
aAdd( aSIX_Serie , {"CD81","CD8_FILIAL+CD8_TPMOV+CD8_SERIE+CD8_DOC+CD8_CLIFOR+CD8_LOJA+CD8_ITEM+CD8_COD	"})
aAdd( aSIX_Serie , {"CD91","CD9_FILIAL+CD9_TPMOV+CD9_SERIE+CD9_DOC+CD9_CLIFOR+CD9_LOJA+CD9_ITEM+CD9_COD	"})
aAdd( aSIX_Serie , {"CDA1","CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA+CDA_NUMITE+CDA_SEQ+CDA_CODLAN+CDA_CALPRO	"})
aAdd( aSIX_Serie , {"CDB1","CDB_FILIAL+CDB_TPMOV+CDB_DOC+CDB_SERIE+CDB_CLIFOR+CDB_LOJA+CDB_ITEM+CDB_COD+CDB_COMPL	"})
aAdd( aSIX_Serie , {"CDC1","CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA+CDC_GUIA+CDC_UF	"})
aAdd( aSIX_Serie , {"CDD1","CDD_FILIAL+CDD_TPMOV+CDD_DOC+CDD_SERIE+CDD_CLIFOR+CDD_LOJA+CDD_DOCREF+CDD_SERREF+CDD_PARREF+CDD_LOJREF	"})
aAdd( aSIX_Serie , {"CDE1","CDE_FILIAL+CDE_TPMOV+CDE_DOC+CDE_SERIE+CDE_CLIFOR+CDE_LOJA+CDE_CPREF+CDE_SERREF+CDE_PARREF+CDE_LOJREF	"})
aAdd( aSIX_Serie , {"CDF1","CDF_FILIAL+CDF_TPMOV+CDF_DOC+CDF_SERIE+CDF_CLIFOR+CDF_LOJA+CDF_ENTREG+CDF_LOJENT	"})
aAdd( aSIX_Serie , {"CDG1","CDG_FILIAL+CDG_TPMOV+CDG_DOC+CDG_SERIE+CDG_CLIFOR+CDG_LOJA+CDG_PROCES+CDG_TPPROC	"})
aAdd( aSIX_Serie , {"CDL1","CDL_FILIAL+CDL_DOC+CDL_SERIE+CDL_CLIENT+CDL_LOJA+CDL_NUMDE+CDL_DOCORI+CDL_SERORI+CDL_FORNEC+CDL_LOJFOR+CDL_NRREG+CDL_ITEMNF+CDL_NRMEMO	"})
aAdd( aSIX_Serie , {"CDL2","CDL_FILIAL+CDL_DOC+CDL_SERIE+CDL_CLIENT+CDL_LOJA+CDL_ITEMNF+CDL_NUMDE+CDL_DOCORI+CDL_SERORI+CDL_FORNEC+CDL_LOJFOR+CDL_NRREG	"})
aAdd( aSIX_Serie , {"CDM1","CDM_FILIAL+CDM_DOCENT+CDM_SERIEE+CDM_FORNEC+CDM_LJFOR+CDM_ITENT+CDM_PRODUT+CDM_NSEQE+CDM_TIPO	"})
aAdd( aSIX_Serie , {"CDM2","CDM_FILIAL+CDM_DOCSAI+CDM_SERIES+CDM_CLIENT+CDM_LJCLI+CDM_ITSAI+CDM_PRODUT+CDM_NSEQS+CDM_TIPO	"})
aAdd( aSIX_Serie , {"CDM3","CDM_FILIAL+CDM_DOCENT+CDM_SERIEE+CDM_PRODUT+DTOS(CDM_DTENT)+CDM_TIPO	"})
aAdd( aSIX_Serie , {"CDM4","CDM_FILIAL+DTOS(CDM_DTSAI)+CDM_DOCSAI+CDM_SERIES+CDM_NSEQS	"})
aAdd( aSIX_Serie , {"CDQ1","CDQ_FILIAL+CDQ_DOC+CDQ_SERIE+CDQ_CLIENT+CDQ_LOJA+CDQ_SEQ	"})
aAdd( aSIX_Serie , {"CDQ2","CDQ_FILIAL+CDQ_CLIENT+CDQ_LOJA+CDQ_DOC+CDQ_SERIE+CDQ_SEQ	"})
aAdd( aSIX_Serie , {"CDQ3","CDQ_FILIAL+CDQ_DOC+CDQ_SERIE+CDQ_CLIENT+CDQ_LOJA+CDQ_CODMSG	"})
aAdd( aSIX_Serie , {"CDR1","CDR_FILIAL+CDR_TPMOV+CDR_DOC+CDR_SERIE+CDR_CLIFOR+CDR_LOJA	"})
aAdd( aSIX_Serie , {"CDS1","CDS_FILIAL+CDS_TPMOV+CDS_SERIE+CDS_DOC+CDS_CLIFOR+CDS_LOJA+CDS_ITEM+CDS_PRODUT	"})
aAdd( aSIX_Serie , {"CDT1","CDT_FILIAL+CDT_TPMOV+CDT_DOC+CDT_SERIE+CDT_CLIFOR+CDT_LOJA+CDT_IFCOMP	"})
aAdd( aSIX_Serie , {"CE21","CE2_FILIAL+CE2_NUMPV+CE2_DOCNF+CE2_SERINF+CE2_ITEMNF+CE2_CODNF+CE2_FORNNF+CE2_LOJANF+CE2_NUMSEQ	"})
aAdd( aSIX_Serie , {"CF41","CF4_FILIAL+CF4_TIPMOV+CF4_SERIE+CF4_NOTA+CF4_CLIFOR+CF4_LOJA+CF4_ITEM	"})
aAdd( aSIX_Serie , {"CF62","CF6_FILIAL+CF6_CLIFOR+CF6_LOJA+CF6_SERIE+CF6_NUMDOC+CF6_TIPONF+CF6_ITEM+CF6_CFOP+CF6_NATBCC	"})
aAdd( aSIX_Serie , Iif(lExistCFF, {"CFF1","CFF_FILIAL+CFF_NUMDOC+CFF_SERIE+CFF_CLIFOR+CFF_LOJA+CFF_TPMOV+CFF_TIPO+CFF_ITEMNF+CFF_CODLEG+CFF_CODIGO+CFF_ANEXO+CFF_ART+CFF_INC+CFF_PRG "}, {"CFF1","CFF_FILIAL+CFF_NUMDOC+CFF_SERIE+CFF_CLIFOR+CFF_LOJA+CFF_CODLEG+CFF_CODIGO+CFF_ANEXO+CFF_ART+CFF_INC+CFF_ALIN+CFF_PRG+CFF_ITM+CFF_LTR	"}))
aAdd( aSIX_Serie , {"CG81","CG8_FILIAL+CG8_NUMDOC+CG8_SERIE+CG8_FORNEC+CG8_LOJA	"})
aAdd( aSIX_Serie , {"CHZ1","CHZ_FILIAL+CHZ_TABELA+DTOS(CHZ_DTPROC)	"})
aAdd( aSIX_Serie , {"CHZ2","CHZ_FILIAL+DTOS(CHZ_DTPROC)+CHZ_TABELA	"})
aAdd( aSIX_Serie , {"CKQ2","CKQ_FILIAL+CKQ_MODELO+CKQ_TP_MOV+CKQ_SERIE+CKQ_NUMERO	"})
aAdd( aSIX_Serie , {"CNG2","CNG_FILIAL+CNG_DOC+CNG_SERIE+CNG_FORNEC+CNG_LOJA	"})
aAdd( aSIX_Serie , {"COG1","COG_FILIAL+COG_DOC+COG_SERIE+COG_FORNEC+COG_LOJA+COG_CODIGO	"})
aAdd( aSIX_Serie , {"D071","D07_FILIAL+D07_CODDIS+D07_DOC+D07_SERIE+D07_FORNEC+D07_LOJA+D07_PRODUT+D07_ITEM	"})
aAdd( aSIX_Serie , {"D072","D07_FILIAL+D07_DOC+D07_SERIE+D07_FORNEC+D07_LOJA+D07_PRODUT+D07_ITEM	"})
aAdd( aSIX_Serie , {"D121","D12_FILIAL+D12_STATUS+D12_PRIORI+D12_CARGA+D12_DOC+D12_SERIE+D12_CLIFOR+D12_LOJA+D12_SERVIC+D12_ORDTAR+D12_ORDATI	"})
aAdd( aSIX_Serie , {"D132","D13_FILIAL+D13_DOC+D13_SERIE+D13_CLIFOR+D13_LOJA+D13_LOCAL+D13_ENDER	"})
aAdd( aSIX_Serie , {"DAI3","DAI_FILIAL+DAI_NFISCA+DAI_SERIE+DAI_CLIENT+DAI_LOJA	"})
aAdd( aSIX_Serie , {"DB21","DB2_FILIAL+DB2_DOC+DB2_SERIE+DB2_CLIFOR+DB2_LOJA	"})
aAdd( aSIX_Serie , {"DBB1","DBB_FILIAL+DBB_DOC+DBB_SERIE+DBB_FORNEC+DBB_LOJA	"})
aAdd( aSIX_Serie , {"DCF2","DCF_FILIAL+DCF_SERVIC+DCF_DOCTO+DCF_SERIE+DCF_CLIFOR+DCF_LOJA+DCF_CODPRO	"})
aAdd( aSIX_Serie , {"DCF3","DCF_FILIAL+DCF_SERVIC+DCF_CODPRO+DCF_DOCTO+DCF_SERIE+DCF_CLIFOR+DCF_LOJA	"})
aAdd( aSIX_Serie , {"DCF7","DCF_FILIAL+DCF_DOCORI+DCF_SERORI	"})
aAdd( aSIX_Serie , {"DCF8","DCF_FILIAL+DTOS(DCF_DATA)+DCF_SERVIC+DCF_DOCTO+DCF_SERIE	"})
aAdd( aSIX_Serie , {"DCN2","DCN_FILIAL+DCN_PROD+DCN_LOCAL+DCN_NUMSEQ+DCN_DOC+DCN_SERIE+DCN_CLIFOR+DCN_LOJA+DCN_ITEM	"})
aAdd( aSIX_Serie , {"DCX1","DCX_FILIAL+DCX_EMBARQ+DCX_DOC+DCX_SERIE+DCX_FORNEC+DCX_LOJA	"})
aAdd( aSIX_Serie , {"DCX2","DCX_FILIAL+DCX_DOC+DCX_SERIE+DCX_FORNEC+DCX_LOJA	"})
aAdd( aSIX_Serie , {"DEB1","DEB_FILIAL+DEB_CGCREM+DEB_DOC+DEB_SERIE	"})
aAdd( aSIX_Serie , {"DEF1","DEF_FILIAL+DEF_CLITXT+DEF_LOJTXT+DEF_FILDOC+DEF_DOC+DEF_SERIE	"})
aAdd( aSIX_Serie , {"DF13","DF1_FILIAL+DF1_FILDOC+DF1_DOC+DF1_SERIE	"})
aAdd( aSIX_Serie , {"DF62","DF6_FILIAL+DF6_FILDOC+DF6_DOC+DF6_SERIE+DF6_FILORI+DF6_VIAGEM	"})
aAdd( aSIX_Serie , {"DFN1","DFN_FILIAL+DFN_IDCTMS+DFN_FILDOC+DFN_DOC+DFN_SERIE+DFN_SERTMS+DFN_TIPTRA+DFN_CODDES+DFN_FILCUS	"})
aAdd( aSIX_Serie , {"DFN2","DFN_FILIAL+DFN_FILDOC+DFN_DOC+DFN_SERIE+DFN_SERTMS+DFN_TIPTRA	"})
aAdd( aSIX_Serie , {"DFP1","DFP_FILIAL+DFP_DOCDCT+DFP_SERDCT+DFP_FORNEC+DFP_LOJFOR+DFP_ITEM	"})
aAdd( aSIX_Serie , {"DFP2","DFP_FILIAL+DFP_DOCDCT+DFP_SERDCT+DFP_FORNEC+DFP_LOJFOR+DFP_FILDCS+DFP_DOCDCS+DFP_SERDCS	"})
aAdd( aSIX_Serie , {"DFR2","DFR_FILIAL+DFR_FILDCT+DFR_DOCDCT+DFR_SERDCT+DFR_NUMFAT	"})
aAdd( aSIX_Serie , {"DFS1","DFS_FILIAL+DFS_DOCDCT+DFS_SERDCT+DFS_FORNEC+DFS_LOJFOR	"})
aAdd( aSIX_Serie , {"DFV2","DFV_FILIAL+DFV_FILDOC+DFV_DOC+DFV_SERIE+DFV_STATUS	"})
aAdd( aSIX_Serie , {"DI92","DI9_FILIAL+DI9_FILDOC+DI9_DOC+DI9_SERIE+DI9_ITEM	"})
aAdd( aSIX_Serie , {"DIA2","DIA_FILIAL+DIA_FILDOC+DIA_DOC+DIA_SERIE+DIA_CODPAS	"})
aAdd( aSIX_Serie , {"DIB1","DIB_FILIAL+DIB_FILDOC+DIB_DOC+DIB_SERIE+DIB_SEQUEN+DIB_CPODOC	"})
aAdd( aSIX_Serie , {"DIB2","DIB_FILIAL+DIB_FILDOC+DIB_DOC+DIB_SERIE+DIB_CPODOC+DIB_SEQUEN	"})
aAdd( aSIX_Serie , {"DIC1","DIC_FILIAL+DIC_FILDOC+DIC_DOC+DIC_SERIE+DIC_SEQUEN	"})
aAdd( aSIX_Serie , {"DIH2","DIH_FILIAL+DIH_FILDOC+DIH_DOC+DIH_SERIE	"})
aAdd( aSIX_Serie , {"DII2","DII_FILIAL+DII_FILDOC+DII_DOC+DII_SERIE+DII_FILMIC+DII_NUMMIC	"})
aAdd( aSIX_Serie , {"DIK4","DIK_FILIAL+DIK_FILDOC+DIK_DOC+DIK_SERIE	"})
aAdd( aSIX_Serie , {"DIN1","DIN_FILIAL+DIN_FILORI+DIN_LOTNFC+DIN_NUMNFC+DIN_SERNFC+DIN_CODPRO	"})
aAdd( aSIX_Serie , {"DT61","DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE	"})
aAdd( aSIX_Serie , {"DT62","DT6_FILIAL+DT6_FILORI+DT6_LOTNFC+DT6_FILDOC+DT6_DOC+DT6_SERIE	"})
aAdd( aSIX_Serie , {"DT66","DT6_FILIAL+DT6_CLIREM+DT6_LOJREM+DT6_LOTCET+DT6_FILDOC+DT6_DOC+DT6_SERIE	"})
aAdd( aSIX_Serie , {"DT68","DT6_FILIAL+DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO	"})
aAdd( aSIX_Serie , {"DT82","DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE+DT8_CODPRO+DT8_CODPAS	"})
aAdd( aSIX_Serie , {"DT84","DT8_FILIAL+DT8_TABFRE+DT8_TIPTAB+DT8_CDRORI+DT8_CDRDES+DT8_SEQTAB+DT8_FILDOC+DT8_DOC+DT8_SERIE	"})
aAdd( aSIX_Serie , {"DTA1","DTA_FILIAL+DTA_FILDOC+DTA_DOC+DTA_SERIE+DTA_FILORI+DTA_VIAGEM	"})
aAdd( aSIX_Serie , {"DTA2","DTA_FILIAL+DTA_FILORI+DTA_VIAGEM+DTA_FILDOC+DTA_DOC+DTA_SERIE	"})
aAdd( aSIX_Serie , {"DTA3","DTA_FILIAL+DTA_LOCAL+DTA_LOCALI+DTA_UNITIZ+DTA_CODANA+DTA_FILDOC+DTA_DOC+DTA_SERIE+DTA_FILORI+DTA_VIAGEM	"})
aAdd( aSIX_Serie , {"DTA4","DTA_FILIAL+DTA_SERTMS+DTA_TIPTRA+DTA_FILORI+DTA_VIAGEM+DTA_FILDOC+DTA_DOC+DTA_SERIE	"})
aAdd( aSIX_Serie , {"DTC1","DTC_FILIAL+DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+DTC_SERVIC+DTC_CODPRO+DTC_NUMNFC+DTC_SERNFC	"})
aAdd( aSIX_Serie , {"DTC2","DTC_FILIAL+DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM+DTC_CODPRO+DTC_FILORI+DTC_LOTNFC	"})
aAdd( aSIX_Serie , {"DTC3","DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO	"})
aAdd( aSIX_Serie , {"DTC4","DTC_FILIAL+DTC_FILDOC+DTC_DOCPER+DTC_SERIE+DTC_SERVIC+DTC_CODPRO	"})
aAdd( aSIX_Serie , {"DTC5","DTC_FILIAL+DTC_CLIREM+DTC_LOJREM+DTC_NUMNFC+DTC_SERNFC	"})
aAdd( aSIX_Serie , {"DTC6","DTC_FILIAL+DTC_CLIDES+DTC_LOJDES+DTC_NUMNFC+DTC_SERNFC	"})
aAdd( aSIX_Serie , {"DTC7","DTC_FILIAL+DTC_DOC+DTC_SERIE+DTC_FILDOC+DTC_NUMNFC+DTC_SERNFC	"})
aAdd( aSIX_Serie , {"DTE1","DTE_FILIAL+DTE_FILORI+DTE_NUMNFC+DTE_SERNFC+DTE_CLIREM+DTE_LOJREM+DTE_CODPRO	"})
aAdd( aSIX_Serie , {"DTX1","DTX_FILIAL+DTX_MANIFE+DTX_SERMAN	"})
aAdd( aSIX_Serie , {"DTX2","DTX_FILIAL+DTX_FILMAN+DTX_MANIFE+DTX_SERMAN	"})
aAdd( aSIX_Serie , {"DTX3","DTX_FILIAL+DTX_FILORI+DTX_VIAGEM+DTX_FILMAN+DTX_MANIFE+DTX_SERMAN	"})
aAdd( aSIX_Serie , {"DTX6","DTX_FILIAL+DTX_TIPMAN+DTX_STATUS+DTX_FILMAN+DTX_MANIFE+DTX_SERMAN	"})
aAdd( aSIX_Serie , {"DU12","DU1_FILIAL+DU1_FILDOC+DU1_DOC+DU1_SERIE	"})
aAdd( aSIX_Serie , {"DU13","DU1_FILIAL+DU1_NUMNFC+DU1_SERNFC+DU1_CODCLI+DU1_LOJCLI	"})
aAdd( aSIX_Serie , {"DU14","DU1_FILIAL+DU1_CODCLI+DU1_LOJCLI+DU1_NUMNFC+DU1_SERNFC	"})
aAdd( aSIX_Serie , {"DU71","DU7_FILIAL+DU7_FILDOC+DU7_DOC+DU7_SERIE	"})
aAdd( aSIX_Serie , {"DUA3","DUA_FILIAL+DUA_CODOCO+DUA_FILDOC+DUA_DOC+DUA_SERIE	"})
aAdd( aSIX_Serie , {"DUA4","DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SERIE+DUA_FILORI+DUA_VIAGEM	"})
aAdd( aSIX_Serie , {"DUA7","DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SERIE+DUA_SEQOCO	"})
aAdd( aSIX_Serie , {"DUAA","DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SERIE+DUA_TIPUSO+DUA_IDENT	"})
aAdd( aSIX_Serie , {"DUB3","DUB_FILIAL+DUB_FILDOC+DUB_DOC+DUB_SERIE+DUB_STATUS	"})
aAdd( aSIX_Serie , {"DUD1","DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM	"})
aAdd( aSIX_Serie , {"DUD2","DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_SEQUEN+DUD_FILDOC+DUD_DOC+DUD_SERIE	"})
aAdd( aSIX_Serie , {"DUD5","DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_FILMAN+DUD_MANIFE+DUD_SERMAN	"})
aAdd( aSIX_Serie , {"DUD7","DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_NUMROM	"})
aAdd( aSIX_Serie , {"DUU3","DUU_FILIAL+DUU_FILDOC+DUU_DOC+DUU_SERIE+DUU_STATUS	"})
aAdd( aSIX_Serie , {"DUU5","DUU_FILIAL+DUU_FILRID+DUU_NUMRID+DUU_FILDOC+DUU_DOC+DUU_SERIE	"})
aAdd( aSIX_Serie , {"DV41","DV4_FILIAL+DV4_FILOCO+DV4_NUMOCO+DV4_FILDOC+DV4_DOC+DV4_SERIE+DV4_NUMNFC+DV4_SERNFC	"})
aAdd( aSIX_Serie , {"DV43","DV4_FILIAL+DV4_FILDOC+DV4_DOC+DV4_SERIE+DV4_NUMNFC+DV4_SERNFC	"})
aAdd( aSIX_Serie , {"DVS1","DVS_FILIAL+DVS_FILDOC+DVS_DOC+DVS_SERIE+DVS_CODPAS	"})
aAdd( aSIX_Serie , {"DVV1","DVV_FILIAL+DVV_FILDOC+DVV_DOC+DVV_SERIE+DVV_PREFIX+DVV_NUM+DVV_TIPO	"})
aAdd( aSIX_Serie , {"DVX4","DVX_FILIAL+DVX_FILDOC+DVX_DOC+DVX_SERIE+DVX_FILORI	"})
aAdd( aSIX_Serie , {"DXM3","DXM_FILIAL+DXM_NOTA+DXM_SERIE+DXM_ITEMNF	"})
aAdd( aSIX_Serie , {"DY41","DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE+DY4_NUMNFC+DY4_SERNFC+DY4_CODPRO	"})
aAdd( aSIX_Serie , {"DYC1","DYC_FILIAL+DYC_NUMROM+DYC_FILDOC+DYC_DOC+DYC_SERIE	"})
aAdd( aSIX_Serie , {"DYJ1","DYJ_FILIAL+DYJ_FILDOC+DYJ_DOC+DYJ_SERIE+DYJ_NUMAGD+DYJ_ITEAGD	"})
aAdd( aSIX_Serie , {"DYN3","DYN_FILIAL+DYN_FILMAN+DYN_MANIFE+DYN_SERMAN+DYN_STCMDF	"})
aAdd( aSIX_Serie , {"ED86","ED8_FILIAL+ED8_NF+ED8_SERIE	"})
aAdd( aSIX_Serie , {"EES1","EES_FILIAL+EES_PREEMB+EES_NRNF+EES_SERIE+EES_PEDIDO+EES_SEQUEN	"})
aAdd( aSIX_Serie , {"EEZ1","EEZ_FILIAL+EEZ_PREEMB+EEZ_CNPJ+EEZ_SER+EEZ_NF	"})
aAdd( aSIX_Serie , {"EEZ3","EEZ_FILIAL+EEZ_PREEMB+EEZ_ID	"})
aAdd( aSIX_Serie , {"EI11","EI1_FILIAL+EI1_HAWB+EI1_DOC+EI1_SERIE	"})
aAdd( aSIX_Serie , {"EI21","EI2_FILIAL+EI2_HAWB+EI2_DOC+EI2_SERIE+EI2_PGI_NU+EI2_PO_NUM+EI2_POSICA	"})
aAdd( aSIX_Serie , {"EI22","EI2_FILIAL+EI2_DOC+EI2_SERIE+EI2_HAWB+EI2_PGI_NU+EI2_PO_NUM+EI2_POSICA	"})
aAdd( aSIX_Serie , {"EW11","EW1_FILIAL+EW1_NUMNF+EW1_SERNF	"})
aAdd( aSIX_Serie , {"EW21","EW2_FILIAL+EW2_NUMNF+EW2_SERNF	"})
aAdd( aSIX_Serie , {"FN65","FN6_FILIAL+FN6_NUMNF+FN6_SERIE	"})
aAdd( aSIX_Serie , {"FR31","FR3_FILIAL+FR3_CART+FR3_DOC+FR3_SERIE+FR3_PEDIDO	"})
aAdd( aSIX_Serie , {"FR32","FR3_FILIAL+FR3_CART+FR3_CLIENT+FR3_LOJA+FR3_PREFIX+FR3_NUM+FR3_PARCEL+FR3_TIPO+FR3_DOC+FR3_SERIE+FR3_PEDIDO	"})
aAdd( aSIX_Serie , {"FR33","FR3_FILIAL+FR3_CART+FR3_FORNEC+FR3_LOJA+FR3_PREFIX+FR3_NUM+FR3_PARCEL+FR3_TIPO+FR3_DOC+FR3_SERIE+FR3_PEDIDO	"})
aAdd( aSIX_Serie , {"GW11","GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC	"})
aAdd( aSIX_Serie , {"GW19","GW1_FILIAL+GW1_NRROM+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC	"})
aAdd( aSIX_Serie , {"GW1A","GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC	"})
aAdd( aSIX_Serie , {"GW1B","GW1_FILIAL+GW1_SERDC+GW1_NRDC	"})
aAdd( aSIX_Serie , {"GW1D","GW1_EMISDC+GW1_SERDC+GW1_NRDC	"})
aAdd( aSIX_Serie , {"GW41","GW4_FILIAL+GW4_EMISDF+GW4_CDESP+GW4_SERDF+GW4_NRDF+DTOS(GW4_DTEMIS)+GW4_EMISDC+GW4_SERDC+GW4_NRDC+GW4_TPDC	"})
aAdd( aSIX_Serie , {"GW42","GW4_FILIAL+GW4_EMISDC+GW4_SERDC+GW4_NRDC+GW4_TPDC	"})
aAdd( aSIX_Serie , {"GW81","GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC+GW8_ITEM+GW8_UNINEG+GW8_INFO1	"})
aAdd( aSIX_Serie , {"GW82","GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC+GW8_SEQ	"})
aAdd( aSIX_Serie , {"GWB2","GWB_FILIAL+GWB_CDTPDC+GWB_EMISDC+GWB_SERDC+GWB_NRDC+GWB_CDUNIT	"})
aAdd( aSIX_Serie , {"GWE1","GWE_FILIAL+GWE_CDTPDC+GWE_EMISDC+GWE_SERDC+GWE_NRDC+GWE_FILDT+GWE_NRDT+GWE_SERDT	"})
aAdd( aSIX_Serie , {"GWE2","GWE_FILIAL+GWE_FILDT+GWE_NRDT+GWE_SERDT	"})
aAdd( aSIX_Serie , {"GWH1","GWH_FILIAL+GWH_NRCALC+GWH_CDTPDC+GWH_EMISDC+GWH_SERDC+GWH_NRDC	"})
aAdd( aSIX_Serie , {"GWH2","GWH_FILIAL+GWH_CDTPDC+GWH_EMISDC+GWH_SERDC+GWH_NRDC+GWH_NRCALC	"})
aAdd( aSIX_Serie , {"GWL1","GWL_FILIAL+GWL_NROCO+GWL_FILDC+GWL_EMITDC+GWL_SERDC+GWL_NRDC+GWL_TPDC	"})
aAdd( aSIX_Serie , {"GWL2","GWL_FILIAL+GWL_NRDC+GWL_FILDC+GWL_EMITDC+GWL_SERDC+GWL_TPDC+GWL_NROCO	"})
aAdd( aSIX_Serie , {"GWL5","GWL_FILDC+GWL_EMITDC+GWL_TPDC+GWL_SERDC+GWL_NRDC	"})
aAdd( aSIX_Serie , {"GWM1","GWM_FILIAL+GWM_TPDOC+GWM_CDESP+GWM_CDTRP+GWM_SERDOC+GWM_NRDOC+DTOS(GWM_DTEMIS)+GWM_CDTPDC+GWM_EMISDC+GWM_SERDC+GWM_NRDC+GWM_SEQGW8	"})
aAdd( aSIX_Serie , {"GWM2","GWM_FILIAL+GWM_CDTPDC+GWM_EMISDC+GWM_SERDC+GWM_NRDC	"})
aAdd( aSIX_Serie , {"GWU1","GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ	"})
aAdd( aSIX_Serie , {"GWU5","GWU_CDTRP+GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ	"})
aAdd( aSIX_Serie , {"GWW1","GWW_FILIAL+GWW_NRAGEN+GWW_CDTPDC+GWW_EMISDC+GWW_SERDC+GWW_NRDC	"})
aAdd( aSIX_Serie , {"GWW2","GWW_FILIAL+GWW_CDTPDC+GWW_EMISDC+GWW_SERDC+GWW_NRDC	"})
aAdd( aSIX_Serie , {"GXA1","GXA_FILIAL+GXA_NRMOV+GXA_CDPTCT+GXA_SEQ+GXA_CDTPDC+GXA_EMISDC+GXA_SERDC+GXA_NRDC	"})
aAdd( aSIX_Serie , {"GXA2","GXA_FILIAL+GXA_CDTPDC+GXA_EMISDC+GXA_SERDC+GXA_NRDC	"})
aAdd( aSIX_Serie , {"HB61","HB6_FILIAL+HB6_ID+HB6_COD+HB6_DOC+HB6_SERIE	"})
aAdd( aSIX_Serie , {"HB62","HB6_FILIAL+HB6_ID+HB6_DOC+HB6_SERIE+DTOS(HB6_DATA)	"})
aAdd( aSIX_Serie , {"HD21","HD2_FILIAL+HD2_ID+HD2_DOC+HD2_SERIE+HD2_ITEM	"})
aAdd( aSIX_Serie , {"HF11","HF1_FILIAL+HF1_ID+HF1_DOC+HF1_SERIE	"})
aAdd( aSIX_Serie , {"HF21","HF2_FILIAL+HF2_ID+HF2_DOC+HF2_SERIE	"})
aAdd( aSIX_Serie , {"MAX3","MAX_FILIAL+MAX_NUM+MAX_SERIE	"})
aAdd( aSIX_Serie , {"MB12","MB1_FILIAL+MB1_SERIE+MB1_NF+MB1_CODIGO	"})
aAdd( aSIX_Serie , {"MBJ5","MBJ_FILIAL+MBJ_DOC+MBJ_SERIE+MBJ_PROD+MBJ_ITEM	"})
aAdd( aSIX_Serie , {"MBN3","MBN_FILIAL+MBN_NUMCAR+MBN_DOC+MBN_SERIE+MBN_ITSALD	"})
aAdd( aSIX_Serie , {"MBZ1","MBZ_FILIAL+MBZ_CUPOM+MBZ_SERIE+MBZ_FORMA+MBZ_PARCEL	"})
aAdd( aSIX_Serie , {"MBZ2","MBZ_FILIAL+MBZ_SITUA+MBZ_CUPOM+MBZ_SERIE	"})
aAdd( aSIX_Serie , {"MDD2","MDD_FILIAL+MDD_SERIR+MDD_DOCR+MDD_PDVR	"})
aAdd( aSIX_Serie , {"MDJ1","MDJ_FILIAL+MDJ_DOC+MDJ_SERIE+MDJ_CLIENT+MDJ_LOJA	"})
aAdd( aSIX_Serie , {"MDK1","MDK_FILIAL+MDK_DOC+MDK_SERIE+MDK_CLIENT+MDK_LOJA	"})
aAdd( aSIX_Serie , {"MDL1","MDL_FILIAL+MDL_NFCUP+MDL_SERIE+MDL_CUPOM+MDL_SERCUP	"})
aAdd( aSIX_Serie , {"MDU2","MDU_FILIAL+MDU_DOC+MDU_SERIE+MDU_PRODUT	"})
aAdd( aSIX_Serie , {"MFI2","MFI_FILIAL+MFI_FILORI+MFI_DOC+MFI_SERIE+MFI_ITEM	"})
aAdd( aSIX_Serie , {"NOA2","NOA_FILIAL+NOA_TIPDOC+NOA_SERDOC+NOA_NUMDOC+NOA_CLIFOR+NOA_LOJACF	"})
aAdd( aSIX_Serie , {"QEKA","QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+QEK_NUMSEQ	"})
aAdd( aSIX_Serie , {"QEKB","QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+QEK_LOTE+QEK_NUMSEQ	"})
aAdd( aSIX_Serie , {"QEY4","QEY_FILIAL+QEY_FORNEC+QEY_LOJFOR+QEY_PRODUT+QEY_NTFISC+QEY_SERINF+QEY_ITEMNF+QEY_TIPONF+DTOS(QEY_DTENTR)+QEY_LOTE+QEY_ENSAIO	"})
aAdd( aSIX_Serie , {"QEZ3","QEZ_FILIAL+QEZ_FORNEC+QEZ_LOJFOR+QEZ_GRUPO+QEZ_NTFISC+QEZ_SERINF+QEZ_ITEMNF+QEZ_TIPONF+DTOS(QEZ_DTENTR)+QEZ_LOTE+QEZ_ENSAIO	"})
aAdd( aSIX_Serie , {"SC64","C6_FILIAL+C6_NOTA+C6_SERIE	"})
aAdd( aSIX_Serie , {"SC65","C6_FILIAL+C6_CLI+C6_LOJA+C6_PRODUTO+C6_NFORI+C6_SERIORI+C6_ITEMORI	"})
aAdd( aSIX_Serie , {"SC96","C9_FILIAL+C9_SERIENF+C9_NFISCAL+C9_CARGA+C9_SEQCAR	"})
aAdd( aSIX_Serie , {"SCU2","CU_FILIAL+CU_FORNECE+CU_LOJA+CU_NFISCAL+CU_SERNF	"})
aAdd( aSIX_Serie , {"SCU3","CU_FILIAL+CU_FORNECE+CU_LOJA+CU_NCRED+CU_SERNCP	"})
aAdd( aSIX_Serie , {"SD11","D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM	"})
aAdd( aSIX_Serie , {"SD12","D1_FILIAL+D1_COD+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA	"})
aAdd( aSIX_Serie , {"SD13","D1_FILIAL+DTOS(D1_EMISSAO)+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA	"})
aAdd( aSIX_Serie , {"SD1A","D1_FILIAL+D1_FORNECE+D1_LOJA+D1_SERIREM+D1_REMITO+D1_ITEMREM	"})
aAdd( aSIX_Serie , {"SD1B","D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_LOTECTL+D1_NUMLOTE+DTOS(D1_DTVALID)	"})
aAdd( aSIX_Serie , {"SD23","D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM	"})
aAdd( aSIX_Serie , {"SD27","D2_FILIAL+D2_PDV+D2_SERIE+D2_DOC+D2_CLIENTE+D2_LOJA	"})
aAdd( aSIX_Serie , {"SD29","D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_SERIREM+D2_REMITO+D2_ITEMREM	"})
aAdd( aSIX_Serie , {"SD2A","D2_FILIAL+D2_NFORI+D2_SERIORI	"})
aAdd( aSIX_Serie , {"SD91","D9_FILIAL+D9_SERIE+DTOS(D9_DTUSO)+D9_DOC	"})
aAdd( aSIX_Serie , {"SD92","D9_FILIAL+D9_SERIE+D9_DOC+DTOS(D9_DTUSO)	"})
aAdd( aSIX_Serie , {"SD93","D9_FILIAL+D9_NSU+D9_SERIE+D9_DOC	"})
aAdd( aSIX_Serie , {"SD94","D9_CNPJ+D9_SERIE+DTOS(D9_DTUSO)+D9_DOC	"})
aAdd( aSIX_Serie , {"SD95","D9_CNPJ+D9_SERIE+D9_DOC+DTOS(D9_DTUSO)	"})
aAdd( aSIX_Serie , {"SDA1","DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA	"})
aAdd( aSIX_Serie , {"SDB1","DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM	"})
aAdd( aSIX_Serie , {"SDB6","DB_FILIAL+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_SERVIC+DB_TAREFA	"})
aAdd( aSIX_Serie , {"SDB7","DB_FILIAL+DB_PRODUTO+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_SERVIC+DB_TAREFA+DB_ATIVID	"})
aAdd( aSIX_Serie , {"SDB8","DB_FILIAL+DB_STATUS+DB_SERVIC+DB_ORDTARE+DB_TAREFA+DB_ORDATIV+DB_ATIVID+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM	"})
aAdd( aSIX_Serie , {"SDB9","DB_FILIAL+DB_STATUS+DB_SERVIC+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM+DB_ORDTARE+DB_ORDATIV	"})
aAdd( aSIX_Serie , {"SDBB","DB_FILIAL+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_IDOPERA	"})
aAdd( aSIX_Serie , {"SDBC","DB_FILIAL+DB_DOC+DB_SERIE+DB_SERVIC+DB_TAREFA+DB_ATIVID+DB_ESTORNO	"})
aAdd( aSIX_Serie , {"SDBF","DB_FILIAL+DB_STATUS+DB_PRIORI+DB_CARGA+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM+DB_SERVIC+DB_ORDTARE+DB_ORDATIV	"})
aAdd( aSIX_Serie , {"SDE1","DE_FILIAL+DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF+DE_ITEM	"})
aAdd( aSIX_Serie , {"SDH2","DH_FILIAL+DH_TPMOV+DH_SERIE+DH_DOC+DH_ITEM+DH_CLIENTE+DH_LOJACLI+DH_FORNECE+DH_LOJAFOR+DH_OPER+DH_IDENTNF+DH_ITEMCOB	"})
aAdd( aSIX_Serie , {"SDS1","DS_FILIAL+DS_DOC+DS_SERIE+DS_FORNEC+DS_LOJA	"})
aAdd( aSIX_Serie , {"SDT1","DT_FILIAL+DT_CNPJ+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE	"})
aAdd( aSIX_Serie , {"SDT2","DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE+DT_PRODFOR	"})
aAdd( aSIX_Serie , {"SDT3","DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE+DT_COD	"})
aAdd( aSIX_Serie , {"SE58","E5_FILIAL+E5_ORDREC+E5_SERREC	"})
aAdd( aSIX_Serie , {"SEL4","EL_FILIAL+DTOS(EL_DTDIGIT)+EL_RECIBO+EL_TIPODOC+EL_SERIE	"})
aAdd( aSIX_Serie , {"SEL5","EL_FILIAL+EL_COBRAD+EL_RECIBO+EL_SERIE	"})
aAdd( aSIX_Serie , {"SEL7","EL_FILIAL+EL_CLIORIG+EL_LOJORIG+EL_RECIBO+EL_SERIE	"})
aAdd( aSIX_Serie , {"SEL8","EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO	"})
aAdd( aSIX_Serie , {"SEX1","EX_FILIAL+EX_NUM+DTOS(EX_EMISSAO)+EX_SERREC	"})
aAdd( aSIX_Serie , {"SEX2","EX_FILIAL+EX_COBRAD+EX_NUM+EX_TIPODOC+EX_TITULO+EX_SERREC	"})
aAdd( aSIX_Serie , {"SEX4","EX_FILIAL+EX_COBRAD+EX_NUM+DTOS(EX_EMISSAO)+EX_SERREC	"})
aAdd( aSIX_Serie , {"SF11","F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO	"})
aAdd( aSIX_Serie , {"SF15","F1_FILIAL+F1_HAWB+F1_TIPO_NF+F1_DOC+F1_SERIE	"})
aAdd( aSIX_Serie , {"SF21","F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO	"})
aAdd( aSIX_Serie , {"SF22","F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE	"})
aAdd( aSIX_Serie , {"SF23","F2_FILIAL+F2_ECF+DTOS(F2_EMISSAO)+F2_PDV+F2_SERIE+F2_MAPA+F2_DOC	"})
aAdd( aSIX_Serie , {"SF24","F2_FILIAL+F2_SERIE+DTOS(F2_EMISSAO)+F2_DOC+F2_CLIENTE+F2_LOJA	"})
aAdd( aSIX_Serie , {"SF25","F2_FILIAL+F2_CARGA+F2_SEQCAR+F2_SERIE+F2_DOC+F2_CLIENTE+F2_LOJA	"})
aAdd( aSIX_Serie , {"SF26","F2_FILIAL+F2_SERIORI+F2_NFORI	"})
aAdd( aSIX_Serie , {"SF31","F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM,5,2)	"})
aAdd( aSIX_Serie , {"SF34","F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE	"})
aAdd( aSIX_Serie , {"SF35","F3_FILIAL+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+F3_IDENTFT	"})
aAdd( aSIX_Serie , {"SF36","F3_FILIAL+F3_NFISCAL+F3_SERIE	"})
aAdd( aSIX_Serie , {"SF81","F8_FILIAL+F8_NFDIFRE+F8_SEDIFRE+F8_FORNECE+F8_LOJA	"})
aAdd( aSIX_Serie , {"SF82","F8_FILIAL+F8_NFORIG+F8_SERORIG+F8_FORNECE+F8_LOJA	"})
aAdd( aSIX_Serie , {"SF83","F8_FILIAL+F8_NFDIFRE+F8_SEDIFRE+F8_TRANSP+F8_LOJTRAN	"})
aAdd( aSIX_Serie , {"SF92","F9_FILIAL+DTOS(F9_DTENTNE)+F9_DOCNFE+F9_SERNFE+F9_FORNECE+F9_LOJAFOR+F9_CFOENT+STR(F9_PICM,5,2)	"})
aAdd( aSIX_Serie , {"SFE4","FE_FILIAL+FE_FORNECE+FE_LOJA+FE_NFISCAL+FE_SERIE+FE_TIPO+FE_CONCEPT	"})
aAdd( aSIX_Serie , {"SFE8","FE_FILIAL+FE_CLIENTE+FE_LOJCLI+FE_NFISCAL+FE_SERIE	"})
aAdd( aSIX_Serie , {"SFP1","FP_FILIAL+FP_FILUSO+FP_SERIE+FP_CAI+FP_ESPECIE	"})
aAdd( aSIX_Serie , {"SFP2","FP_FILIAL+FP_FILUSO+FP_CAI+FP_SERIE+FP_ESPECIE	"})
aAdd( aSIX_Serie , {"SFP3","FP_FILIAL+FP_FILUSO+FP_SERIE+FP_CAI+FP_NUMINI+FP_NUMFIM+FP_ESPECIE+FP_PV	"})
aAdd( aSIX_Serie , {"SFP4","FP_FILIAL+FP_FILUSO+FP_CAI+FP_SERIE+FP_NUMINI+FP_NUMFIM+FP_ESPECIE	"})
aAdd( aSIX_Serie , {"SFP5","FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE+FP_PV	"})
aAdd( aSIX_Serie , {"SFP6","FP_FILIAL+FP_FILUSO+FP_ESPECIE+FP_SERIE+FP_NUMINI	"})
aAdd( aSIX_Serie , {"SFT1","FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO	"})
aAdd( aSIX_Serie , {"SFT2","FT_FILIAL+FT_TIPOMOV+DTOS(FT_ENTRADA)+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO	"})
aAdd( aSIX_Serie , {"SFT3","FT_FILIAL+FT_TIPOMOV+FT_CLIEFOR+FT_LOJA+FT_SERIE+FT_NFISCAL+FT_IDENTF3	"})
aAdd( aSIX_Serie , {"SFT4","FT_FILIAL+FT_TIPOMOV+FT_CLIEFOR+FT_LOJA+FT_SERIE+FT_NFISCAL+FT_CFOP	"})
aAdd( aSIX_Serie , {"SFT6","FT_FILIAL+FT_TIPOMOV+FT_NFISCAL+FT_SERIE	"})
aAdd( aSIX_Serie , {"SFU1","FU_FILIAL+FU_TIPOMOV+FU_SERIE+FU_DOC+FU_CLIFOR+FU_LOJA+FU_ITEM+FU_COD	"})
aAdd( aSIX_Serie , {"SFU2","FU_FILIAL+FU_TIPOMOV+FU_ESPECIE+FU_SERIE+FU_DOC+FU_CLIFOR+FU_LOJA+FU_ITEM+FU_COD	"})
aAdd( aSIX_Serie , {"SFX1","FX_FILIAL+FX_TIPOMOV+FX_SERIE+FX_DOC+FX_CLIFOR+FX_LOJA+FX_ITEM+FX_COD	"})
aAdd( aSIX_Serie , {"SFX2","FX_FILIAL+FX_TIPOMOV+FX_ESPECIE+FX_SERIE+FX_DOC+FX_CLIFOR+FX_LOJA+FX_ITEM+FX_COD	"})
aAdd( aSIX_Serie , {"SL12","L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV	"})
aAdd( aSIX_Serie , {"SL1B","L1_FILIAL+L1_SERPED+L1_DOCPED	"})
aAdd( aSIX_Serie , {"SL23","L2_FILIAL+L2_SERIE+L2_DOC+L2_PRODUTO	"})
aAdd( aSIX_Serie , {"SL61","L6_FILIAL+L6_SERIE+L6_ESTACAO	"})
aAdd( aSIX_Serie , {"SLX1","LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE+LX_ITEM+LX_HORA	"})
aAdd( aSIX_Serie , {"SN18","N1_FILIAL+N1_FORNEC+N1_LOJA+N1_NFESPEC+N1_NFISCAL+N1_NSERIE+N1_NFITEM	"})
aAdd( aSIX_Serie , {"SUA2","UA_FILIAL+UA_SERIE+UA_DOC	"})
aAdd( aSIX_Serie , {"SWN1","WN_FILIAL+WN_DOC+WN_SERIE+WN_TEC+WN_EX_NCM+WN_EX_NBM	"})
aAdd( aSIX_Serie , {"SWN2","WN_FILIAL+WN_DOC+WN_SERIE+WN_FORNECE+WN_LOJA	"})
aAdd( aSIX_Serie , {"SWW1","WW_FILIAL+WW_NF_COMP+WW_SE_NFC+WW_FORNECE+WW_LOJA+WW_PO_NUM+WW_NR_CONT	"})
aAdd( aSIX_Serie , {"TE02","TE0_FILIAL+TE0_DOC+TE0_SERIE+TE0_ITEM	"})
aAdd( aSIX_Serie , {"TE12","TE1_FILIAL+TE1_DOC+TE1_SERIE+TE1_ITEM	"})
aAdd( aSIX_Serie , {"TE22","TE2_FILIAL+TE2_DOC+TE2_SERIE+TE2_ITEM	"})
aAdd( aSIX_Serie , {"TEW5","TEW_FILIAL+TEW_NFSAI+TEW_SERSAI+TEW_ITSAI	"})
aAdd( aSIX_Serie , {"TEW6","TEW_FILIAL+TEW_NFENT+TEW_SERENT+TEW_ITENT	"})
aAdd( aSIX_Serie , {"VD25","VD2_FILIAL+VD2_NUMNFI+VD2_SERNFI+DTOS(VD2_DATPAG)	"})
aAdd( aSIX_Serie , {"VDD6","VDD_FILIAL+VDD_NUMNFI+VDD_SERNFI+VDD_CODFOR+VDD_LOJA	"})
aAdd( aSIX_Serie , {"VDV2","VDV_FILIAL+VDV_CHAINT+VDV_SFILNF+VDV_SNUMNF+VDV_SSERNF	"})
aAdd( aSIX_Serie , {"VDV3","VDV_FILIAL+VDV_CHAINT+VDV_EFILNF+VDV_ENUMNF+VDV_ESERNF+VDV_ECDFOR+VDV_ELJFOR	"})
aAdd( aSIX_Serie , {"VDV4","VDV_FILIAL+VDV_SFILNF+VDV_SNUMNF+VDV_SSERNF+VDV_CHAINT	"})
aAdd( aSIX_Serie , {"VDV5","VDV_FILIAL+VDV_EFILNF+VDV_ENUMNF+VDV_ESERNF+VDV_ECDFOR+VDV_ELJFOR+VDV_CHAINT	"})
aAdd( aSIX_Serie , {"VE12","VE1_FILIAL+VE1_DESMAR	"})
aAdd( aSIX_Serie , {"VEC4","VEC_FILIAL+VEC_NUMNFI+VEC_SERNFI+VEC_GRUITE+VEC_CODITE	"})
aAdd( aSIX_Serie , {"VF32","VF3_FILIAL+DTOS(VF3_DATPOS)+VF3_CHAINT+VF3_NUMNFI+VF3_SERNFI	"})
aAdd( aSIX_Serie , {"VF33","VF3_FILIAL+VF3_CHAINT+DTOS(VF3_DATPOS)+VF3_NUMNFI+VF3_SERNFI	"})
aAdd( aSIX_Serie , {"VG52","VG5_FILIAL+VG5_CODMAR+VG5_NUMNFI+VG5_SERIEN+VG5_PECINT+VG5_SERINT	"})
aAdd( aSIX_Serie , {"VG54","VG5_FILIAL+VG5_CODMAR+VG5_NUMNFI+VG5_SERIEN+VG5_ORDITE+VG5_PECINT+VG5_SERINT	"})
aAdd( aSIX_Serie , {"VG67","VG6_FILIAL+VG6_CODMAR+VG6_RENNF1+VG6_SERNFI+VG6_ITEMNF	"})
aAdd( aSIX_Serie , {"VGA2","VGA_FILIAL+VGA_CODMAR+VGA_NUMNFI+VGA_SERIEN	"})
aAdd( aSIX_Serie , {"VI01","VI0_FILIAL+VI0_CODMAR+VI0_SERNFI+VI0_NUMNFI	"})
aAdd( aSIX_Serie , {"VI02","VI0_FILIAL+VI0_CODMAR+VI0_NUMNFI+VI0_SERNFI+VI0_CODFOR+VI0_LOJFOR	"})
aAdd( aSIX_Serie , {"VIA1","VIA_FILIAL+VIA_CODMAR+VIA_SERNFI+VIA_NUMNFI+VIA_CODITE+VIA_PEDCON	"})
aAdd( aSIX_Serie , {"VIA3","VIA_FILIAL+VIA_CODMAR+VIA_NUMNFI+VIA_SERNFI+VIA_CODFOR+VIA_LOJFOR	"})
aAdd( aSIX_Serie , {"VIK1","VIK_FILIAL+VIK_TIPO+VIK_NUMNFI+VIK_SERNFI	"})
aAdd( aSIX_Serie , {"VIP1","VIP_FILIAL+VIP_NUMNFI+VIP_SERNFI	"})
aAdd( aSIX_Serie , {"VIQ1","VIQ_FILIAL+VIQ_NUMNFI+VIQ_SERNFI	"})
aAdd( aSIX_Serie , {"VIV1","VIV_FILIAL+VIV_CODMAR+VIV_NUMNFI+VIV_SERNFI	"})
aAdd( aSIX_Serie , {"VJC1","VJC_FILIAL+VJC_CLIFAT+VJC_LOJA+VJC_SERNFI+VJC_NUMNFI	"})
aAdd( aSIX_Serie , {"VJC3","VJC_FILIAL+VJC_SERNFI+VJC_NUMNFI+VJC_TIPO	"})
aAdd( aSIX_Serie , {"VJI1","VJI_FILIAL+VJI_GRUITE+VJI_CODITE+VJI_SERNFI+VJI_NUMNFI	"})
aAdd( aSIX_Serie , {"VJI3","VJI_FILIAL+VJI_SERNFI+VJI_NUMNFI+VJI_TIPO	"})
aAdd( aSIX_Serie , {"VO35","VO3_FILIAL+VO3_NUMNFI+VO3_SERNFI	"})
aAdd( aSIX_Serie , {"VO47","VO4_FILIAL+VO4_NUMNFI+VO4_SERNFI	"})
aAdd( aSIX_Serie , {"VOO4","VOO_FILIAL+VOO_NUMNFI+VOO_SERNFI	"})
aAdd( aSIX_Serie , {"VS13","VS1_FILIAL+VS1_NUMNFI+VS1_SERNFI	"})
aAdd( aSIX_Serie , {"VSC6","VSC_FILIAL+VSC_NUMNFI+VSC_SERNFI	"})
aAdd( aSIX_Serie , {"VSK2","VSK_FILIAL+VSK_CODGRU	"})
aAdd( aSIX_Serie , {"VSL3","VSL_FILIAL+VSL_CODGRU+VSL_CODINC	"})
aAdd( aSIX_Serie , {"VV04","VV0_FILIAL+VV0_NUMNFI+VV0_SERNFI	"})
aAdd( aSIX_Serie , {"VVD4","VVD_FILIAL+VVD_CODFOR+VVD_LOJA+VVD_SERNFI+VVD_NUMNFI	"})
aAdd( aSIX_Serie , {"VVF4","VVF_FILIAL+VVF_CODFOR+VVF_LOJA+VVF_NUMNFI+VVF_SERNFI	"})
aAdd( aSIX_Serie , {"VVF6","VVF_FILIAL+VVF_NUMNFI+VVF_SERNFI+VVF_CODFOR+VVF_LOJA	"})


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O Array aSIX_SDoc contem todos os indices que contem o campo     ³
//³_SDOC referente a serie do documento fiscal e que apos o recurso ³
//³do projeto chave unica for ligado (campos do Grupo SXG 094 com   ³
//³tamanho = 14) o SHOWPESQ destes indices devera ser = "S".        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aSIX_SDoc , {"AD02","AD0_FILIAL+AD0_CNPJ+AD0_SDOC+AD0_DOC	"})
aAdd( aSIX_SDoc , {"AFN7","AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_DOC+AFN_SDOC+AFN_FORNEC+AFN_LOJA+AFN_ITEM	"})
aAdd( aSIX_SDoc , {"AFN8","AFN_FILIAL+AFN_DOC+AFN_SDOC+AFN_FORNEC+AFN_LOJA+AFN_ITEM+AFN_PROJET+AFN_REVISA+AFN_TAREFA	"})
aAdd( aSIX_SDoc , {"AFN9","AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_DOC+AFN_SDOC+AFN_FORNEC+AFN_LOJA+AFN_ITEM	"})
aAdd( aSIX_SDoc , {"AGH3","AGH_FILIAL+AGH_NUM+AGH_SDOC+AGH_FORNEC+AGH_LOJA+AGH_ITEMPD+AGH_ITEM	"})
aAdd( aSIX_SDoc , {"AGH4","AGH_FILIAL+AGH_NUM+AGH_SDOC+AGH_ITEMPD+AGH_ITEM	"})
aAdd( aSIX_SDoc , {"B193","B19_FILIAL+B19_DOC+B19_SDOC+B19_FORNEC+B19_LOJA	"})
aAdd( aSIX_SDoc , {"CB0A","CB0_FILIAL+CB0_NFENT+CB0_SDOCE+CB0_FORNEC+CB0_LOJAFO+CB0_CODPRO	"})
aAdd( aSIX_SDoc , {"CB0B","CB0_FILIAL+CB0_FORNEC+CB0_LOJAFO+CB0_CODPRO+CB0_NFENT+CB0_SDOCE+CB0_ITNFE	"})
aAdd( aSIX_SDoc , {"CB78","CB7_FILIAL+CB7_NOTA+CB7_SDOC+CB7_LOCAL+CB7_STATUS	"})
aAdd( aSIX_SDoc , {"CB88","CB8_FILIAL+CB8_NOTA+CB8_SDOC+CB8_ITEM+CB8_SEQUEN+CB8_PROD	"})
aAdd( aSIX_SDoc , {"CBE3","CBE_FILIAL+CBE_CODETI+CBE_NOTA+CBE_SDOC+CBE_FORNEC+CBE_LOJA+CBE_CODPRO+CBE_LOTECT+DTOS(CBE_DTVLD)	"})
aAdd( aSIX_SDoc , {"CBE4","CBE_FILIAL+CBE_NOTA+CBE_SDOC+CBE_FORNEC+CBE_LOJA+CBE_CODPRO+CBE_CODETI	"})
aAdd( aSIX_SDoc , {"CBG7","CBG_FILIAL+CBG_NOTAE+CBG_SDOCE+CBG_FORN+CBG_LOJFOR+DTOS(CBG_DATA)+CBG_HORA	"})
aAdd( aSIX_SDoc , {"CBG8","CBG_FILIAL+CBG_NOTAS+CBG_SDOCS+DTOS(CBG_DATA)+CBG_HORA	"})
aAdd( aSIX_SDoc , {"CBK2","CBK_FILIAL+CBK_DOC+CBK_SDOC+CBK_CLIENT+CBK_LOJA	"})
aAdd( aSIX_SDoc , {"CBL3","CBL_FILIAL+CBL_DOC+CBL_SDOC+CBL_CODETI+CBL_PROD	"})
aAdd( aSIX_SDoc , {"CBL4","CBL_FILIAL+CBL_DOC+CBL_SDOC+CBL_CLIENT+CBL_LOJA	"})
aAdd( aSIX_SDoc , {"CCX5","CCX_FILIAL+CCX_DOC+CCX_SDOC+CCX_CLIENT+CCX_LOJA+CCX_ITEM	"})
aAdd( aSIX_SDoc , {"CCX6","CCX_FILIAL+CCX_DOC+CCX_SDOC+CCX_CLIENT+CCX_LOJA+CCX_PROCA	"})
aAdd( aSIX_SDoc , {"CCX7","CCX_FILIAL+CCX_DOC+CCX_SDOC+CCX_CLIENT+CCX_LOJA+DTOS(CCX_DTAPUR)	"})
aAdd( aSIX_SDoc , {"CCX8","CCX_FILIAL+CCX_DOC+CCX_SDOC+CCX_ITEM+CCX_CLIENT+CCX_LOJA+DTOS(CCX_DTAPUR)	"})
aAdd( aSIX_SDoc , {"CD02","CD0_FILIAL+CD0_TPMOV+CD0_SDOC+CD0_DOC+CD0_CLIFOR+CD0_LOJA+CD0_ITEM+CD0_COD	"})
aAdd( aSIX_SDoc , {"CD23","CD2_FILIAL+CD2_TPMOV+CD2_SDOC+CD2_DOC+CD2_CODCLI+CD2_LOJCLI+CD2_ITEM+CD2_CODPRO+CD2_IMP	"})
aAdd( aSIX_SDoc , {"CD24","CD2_FILIAL+CD2_TPMOV+CD2_SDOC+CD2_DOC+CD2_CODFOR+CD2_LOJFOR+CD2_ITEM+CD2_CODPRO+CD2_IMP	"})
aAdd( aSIX_SDoc , {"CD34","CD3_FILIAL+CD3_TPMOV+CD3_SDOC+CD3_DOC+CD3_CLIFOR+CD3_LOJA+CD3_ITEM+CD3_COD	"})
aAdd( aSIX_SDoc , {"CD35","CD3_FILIAL+CD3_ESPEC+CD3_TPMOV+CD3_SDOC+CD3_DOC+CD3_CLIFOR+CD3_LOJA+CD3_ITEM+CD3_COD	"})
aAdd( aSIX_SDoc , {"CD44","CD4_FILIAL+CD4_TPMOV+CD4_SDOC+CD4_DOC+CD4_CLIFOR+CD4_LOJA+CD4_ITEM+CD4_COD	"})
aAdd( aSIX_SDoc , {"CD45","CD4_FILIAL+CD4_TPMOV+CD4_ESPEC+CD4_SDOC+CD4_DOC+CD4_CLIFOR+CD4_LOJA+CD4_ITEM+CD4_COD	"})
aAdd( aSIX_SDoc , {"CD55","CD5_FILIAL+CD5_DOC+CD5_SDOC+CD5_FORNEC+CD5_LOJA+CD5_DOCIMP+CD5_NADIC	"})
aAdd( aSIX_SDoc , {"CD56","CD5_FILIAL+CD5_DOC+CD5_SDOC+CD5_FORNEC+CD5_LOJA+CD5_DOCIMP+STR(CD5_ALPIS,5,2)+STR(CD5_ALCOF,5,2)+CD5_NADIC+CD5_SQADIC	"})
aAdd( aSIX_SDoc , {"CD57","CD5_FILIAL+CD5_DOC+CD5_SDOC+CD5_FORNEC+CD5_LOJA+CD5_ITEM	"})
aAdd( aSIX_SDoc , {"CD62","CD6_FILIAL+CD6_TPMOV+CD6_SDOC+CD6_DOC+CD6_CLIFOR+CD6_LOJA+CD6_ITEM+CD6_COD+CD6_PLACA+CD6_TANQUE	"})
aAdd( aSIX_SDoc , {"CD72","CD7_FILIAL+CD7_TPMOV+CD7_SDOC+CD7_DOC+CD7_CLIFOR+CD7_LOJA+CD7_ITEM+CD7_COD	"})
aAdd( aSIX_SDoc , {"CD82","CD8_FILIAL+CD8_TPMOV+CD8_SDOC+CD8_DOC+CD8_CLIFOR+CD8_LOJA+CD8_ITEM+CD8_COD	"})
aAdd( aSIX_SDoc , {"CD92","CD9_FILIAL+CD9_TPMOV+CD9_SDOC+CD9_DOC+CD9_CLIFOR+CD9_LOJA+CD9_ITEM+CD9_COD	"})
aAdd( aSIX_SDoc , {"CDA2","CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SDOC+CDA_CLIFOR+CDA_LOJA+CDA_NUMITE+CDA_SEQ+CDA_CODLAN+CDA_CALPRO	"})
aAdd( aSIX_SDoc , {"CDB2","CDB_FILIAL+CDB_TPMOV+CDB_DOC+CDB_SDOC+CDB_CLIFOR+CDB_LOJA+CDB_ITEM+CDB_COD+CDB_COMPL	"})
aAdd( aSIX_SDoc , {"CDC3","CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SDOC+CDC_CLIFOR+CDC_LOJA+CDC_GUIA+CDC_UF	"})
aAdd( aSIX_SDoc , {"CDD2","CDD_FILIAL+CDD_TPMOV+CDD_DOC+CDD_SDOC+CDD_CLIFOR+CDD_LOJA+CDD_DOCREF+CDD_SDOCRF+CDD_PARREF+CDD_LOJREF	"})
aAdd( aSIX_SDoc , {"CDE2","CDE_FILIAL+CDE_TPMOV+CDE_DOC+CDE_SDOC+CDE_CLIFOR+CDE_LOJA+CDE_CPREF+CDE_SDOCRF+CDE_PARREF+CDE_LOJREF	"})
aAdd( aSIX_SDoc , {"CDF2","CDF_FILIAL+CDF_TPMOV+CDF_DOC+CDF_SDOC+CDF_CLIFOR+CDF_LOJA+CDF_ENTREG+CDF_LOJENT	"})
aAdd( aSIX_SDoc , {"CDG2","CDG_FILIAL+CDG_TPMOV+CDG_DOC+CDG_SDOC+CDG_CLIFOR+CDG_LOJA+CDG_PROCES+CDG_TPPROC	"})
aAdd( aSIX_SDoc , {"CDL3","CDL_FILIAL+CDL_DOC+CDL_SDOC+CDL_CLIENT+CDL_LOJA+CDL_NUMDE+CDL_DOCORI+CDL_SDOCOR+CDL_FORNEC+CDL_LOJFOR+CDL_NRREG+CDL_ITEMNF+CDL_NRMEMO	"})
aAdd( aSIX_SDoc , {"CDL4","CDL_FILIAL+CDL_DOC+CDL_SDOC+CDL_CLIENT+CDL_LOJA+CDL_ITEMNF+CDL_NUMDE+CDL_DOCORI+CDL_SDOCOR+CDL_FORNEC+CDL_LOJFOR+CDL_NRREG	"})
aAdd( aSIX_SDoc , {"CDM5","CDM_FILIAL+CDM_DOCENT+CDM_SDOCE+CDM_FORNEC+CDM_LJFOR+CDM_ITENT+CDM_PRODUT+CDM_NSEQE+CDM_TIPO	"})
aAdd( aSIX_SDoc , {"CDM6","CDM_FILIAL+CDM_DOCSAI+CDM_SDOCS+CDM_CLIENT+CDM_LJCLI+CDM_ITSAI+CDM_PRODUT+CDM_NSEQS+CDM_TIPO	"})
aAdd( aSIX_SDoc , {"CDM7","CDM_FILIAL+CDM_DOCENT+CDM_SDOCE+CDM_PRODUT+DTOS(CDM_DTENT)+CDM_TIPO	"})
aAdd( aSIX_SDoc , {"CDM8","CDM_FILIAL+DTOS(CDM_DTSAI)+CDM_DOCSAI+CDM_SDOCS+CDM_NSEQS	"})
aAdd( aSIX_SDoc , {"CDQ4","CDQ_FILIAL+CDQ_DOC+CDQ_SDOC+CDQ_CLIENT+CDQ_LOJA+CDQ_SEQ	"})
aAdd( aSIX_SDoc , {"CDQ5","CDQ_FILIAL+CDQ_CLIENT+CDQ_LOJA+CDQ_DOC+CDQ_SDOC+CDQ_SEQ	"})
aAdd( aSIX_SDoc , {"CDQ6","CDQ_FILIAL+CDQ_DOC+CDQ_SDOC+CDQ_CLIENT+CDQ_LOJA+CDQ_CODMSG	"})
aAdd( aSIX_SDoc , {"CDR2","CDR_FILIAL+CDR_TPMOV+CDR_DOC+CDR_SDOC+CDR_CLIFOR+CDR_LOJA	"})
aAdd( aSIX_SDoc , {"CDS2","CDS_FILIAL+CDS_TPMOV+CDS_SDOC+CDS_DOC+CDS_CLIFOR+CDS_LOJA+CDS_ITEM+CDS_PRODUT	"})
aAdd( aSIX_SDoc , {"CDT2","CDT_FILIAL+CDT_TPMOV+CDT_DOC+CDT_SDOC+CDT_CLIFOR+CDT_LOJA+CDT_IFCOMP	"})
aAdd( aSIX_SDoc , {"CE22","CE2_FILIAL+CE2_NUMPV+CE2_DOCNF+CE2_SDOC+CE2_ITEMNF+CE2_CODNF+CE2_FORNNF+CE2_LOJANF+CE2_NUMSEQ	"})
aAdd( aSIX_SDoc , {"CF43","CF4_FILIAL+CF4_TIPMOV+CF4_SDOC+CF4_NOTA+CF4_CLIFOR+CF4_LOJA+CF4_ITEM	"})
aAdd( aSIX_SDoc , {"CF63","CF6_FILIAL+CF6_CLIFOR+CF6_LOJA+CF6_SDOC+CF6_NUMDOC+CF6_TIPONF+CF6_ITEM+CF6_CFOP+CF6_NATBCC	"})
aAdd( aSIX_SDoc , Iif(lExistCFF, {"CFF2","CFF_FILIAL+CFF_NUMDOC+CFF_SERIE+CFF_CLIFOR+CFF_LOJA+CFF_TPMOV+CFF_TIPO+CFF_ITEMNF+CFF_CODLEG+CFF_CODIGO+CFF_ANEXO+CFF_ART+CFF_INC+CFF_PRG "}, {"CFF2","CFF_FILIAL+CFF_NUMDOC+CFF_SDOC+CFF_CLIFOR+CFF_LOJA+CFF_CODLEG+CFF_CODIGO+CFF_ANEXO+CFF_ART+CFF_INC+CFF_ALIN+CFF_PRG+CFF_ITM+CFF_LTR	"}))
aAdd( aSIX_SDoc , {"CG82","CG8_FILIAL+CG8_NUMDOC+CG8_SDOC+CG8_FORNEC+CG8_LOJA	"})
aAdd( aSIX_SDoc , {"CKQ6","CKQ_FILIAL+CKQ_MODELO+CKQ_TP_MOV+CKQ_SDOC+CKQ_NUMERO	"})
aAdd( aSIX_SDoc , {"CNG3","CNG_FILIAL+CNG_DOC+CNG_SDOC+CNG_FORNEC+CNG_LOJA	"})
aAdd( aSIX_SDoc , {"COG3","COG_FILIAL+COG_DOC+COG_SDOC+COG_FORNEC+COG_LOJA+COG_CODIGO	"})
aAdd( aSIX_SDoc , {"D073","D07_FILIAL+D07_CODDIS+D07_DOC+D07_SDOC+D07_FORNEC+D07_LOJA+D07_PRODUT+D07_ITEM	"})
aAdd( aSIX_SDoc , {"D074","D07_FILIAL+D07_DOC+D07_SDOC+D07_FORNEC+D07_LOJA+D07_PRODUT+D07_ITEM	"})
aAdd( aSIX_SDoc , {"D125","D12_FILIAL+D12_STATUS+D12_PRIORI+D12_CARGA+D12_DOC+D12_SDOC+D12_CLIFOR+D12_LOJA+D12_SERVIC+D12_ORDTAR+D12_ORDATI	"})
aAdd( aSIX_SDoc , {"D134","D13_FILIAL+D13_DOC+D13_SDOC+D13_CLIFOR+D13_LOJA+D13_LOCAL+D13_ENDER	"})
aAdd( aSIX_SDoc , {"DAI6","DAI_FILIAL+DAI_NFISCA+DAI_SDOC+DAI_CLIENT+DAI_LOJA	"})
aAdd( aSIX_SDoc , {"DB23","DB2_FILIAL+DB2_DOC+DB2_SDOC+DB2_CLIFOR+DB2_LOJA	"})
aAdd( aSIX_SDoc , {"DBB3","DBB_FILIAL+DBB_DOC+DBB_SDOC+DBB_FORNEC+DBB_LOJA	"})
aAdd( aSIX_SDoc , {"DCF9","DCF_FILIAL+DCF_SERVIC+DCF_DOCTO+DCF_SDOC+DCF_CLIFOR+DCF_LOJA+DCF_CODPRO	"})
aAdd( aSIX_SDoc , {"DCFA","DCF_FILIAL+DCF_SERVIC+DCF_CODPRO+DCF_DOCTO+DCF_SDOC+DCF_CLIFOR+DCF_LOJA	"})
aAdd( aSIX_SDoc , {"DCFB","DCF_FILIAL+DCF_DOCORI+DCF_SDOCOR	"})
aAdd( aSIX_SDoc , {"DCFC","DCF_FILIAL+DTOS(DCF_DATA)+DCF_SERVIC+DCF_DOCTO+DCF_SDOC	"})
aAdd( aSIX_SDoc , {"DCN3","DCN_FILIAL+DCN_PROD+DCN_LOCAL+DCN_NUMSEQ+DCN_DOC+DCN_SDOC+DCN_CLIFOR+DCN_LOJA+DCN_ITEM	"})
aAdd( aSIX_SDoc , {"DCX3","DCX_FILIAL+DCX_EMBARQ+DCX_DOC+DCX_SDOC+DCX_FORNEC+DCX_LOJA	"})
aAdd( aSIX_SDoc , {"DCX4","DCX_FILIAL+DCX_DOC+DCX_SDOC+DCX_FORNEC+DCX_LOJA	"})
aAdd( aSIX_SDoc , {"DEB3","DEB_FILIAL+DEB_CGCREM+DEB_DOC+DEB_SDOC	"})
aAdd( aSIX_SDoc , {"DEF2","DEF_FILIAL+DEF_CLITXT+DEF_LOJTXT+DEF_FILDOC+DEF_DOC+DEF_SDOC	"})
aAdd( aSIX_SDoc , {"DF16","DF1_FILIAL+DF1_FILDOC+DF1_DOC+DF1_SDOC	"})
aAdd( aSIX_SDoc , {"DF63","DF6_FILIAL+DF6_FILDOC+DF6_DOC+DF6_SDOC+DF6_FILORI+DF6_VIAGEM	"})
aAdd( aSIX_SDoc , {"DFN3","DFN_FILIAL+DFN_IDCTMS+DFN_FILDOC+DFN_DOC+DFN_SDOC+DFN_SERTMS+DFN_TIPTRA+DFN_CODDES+DFN_FILCUS	"})
aAdd( aSIX_SDoc , {"DFN4","DFN_FILIAL+DFN_FILDOC+DFN_DOC+DFN_SDOC+DFN_SERTMS+DFN_TIPTRA	"})
aAdd( aSIX_SDoc , {"DFP3","DFP_FILIAL+DFP_DOCDCT+DFP_SDOCT+DFP_FORNEC+DFP_LOJFOR+DFP_ITEM	"})
aAdd( aSIX_SDoc , {"DFP4","DFP_FILIAL+DFP_DOCDCT+DFP_SDOCT+DFP_FORNEC+DFP_LOJFOR+DFP_FILDCS+DFP_DOCDCS+DFP_SDOCS	"})
aAdd( aSIX_SDoc , {"DFR3","DFR_FILIAL+DFR_FILDCT+DFR_DOCDCT+DFR_SDOCT+DFR_NUMFAT	"})
aAdd( aSIX_SDoc , {"DFS2","DFS_FILIAL+DFS_DOCDCT+DFS_SDOCT+DFS_FORNEC+DFS_LOJFOR	"})
aAdd( aSIX_SDoc , {"DFV3","DFV_FILIAL+DFV_FILDOC+DFV_DOC+DFV_SDOC+DFV_STATUS	"})
aAdd( aSIX_SDoc , {"DI93","DI9_FILIAL+DI9_FILDOC+DI9_DOC+DI9_SDOC+DI9_ITEM	"})
aAdd( aSIX_SDoc , {"DIA3","DIA_FILIAL+DIA_FILDOC+DIA_DOC+DIA_SDOC+DIA_CODPAS	"})
aAdd( aSIX_SDoc , {"DIB3","DIB_FILIAL+DIB_FILDOC+DIB_DOC+DIB_SDOC+DIB_SEQUEN+DIB_CPODOC	"})
aAdd( aSIX_SDoc , {"DIB4","DIB_FILIAL+DIB_FILDOC+DIB_DOC+DIB_SDOC+DIB_CPODOC+DIB_SEQUEN	"})
aAdd( aSIX_SDoc , {"DIC2","DIC_FILIAL+DIC_FILDOC+DIC_DOC+DIC_SDOC+DIC_SEQUEN	"})
aAdd( aSIX_SDoc , {"DIH3","DIH_FILIAL+DIH_FILDOC+DIH_DOC+DIH_SDOC	"})
aAdd( aSIX_SDoc , {"DII3","DII_FILIAL+DII_FILDOC+DII_DOC+DII_SDOC+DII_FILMIC+DII_NUMMIC	"})
aAdd( aSIX_SDoc , {"DIK5","DIK_FILIAL+DIK_FILDOC+DIK_DOC+DIK_SDOC	"})
aAdd( aSIX_SDoc , {"DIM1","DIM_FILIAL+DIM_FILDOC+DIM_DOC+DIM_SDOC+DIM_SEQUEN	"})
aAdd( aSIX_SDoc , {"DIN2","DIN_FILIAL+DIN_FILORI+DIN_LOTNFC+DIN_NUMNFC+DIN_SDOCC+DIN_CODPRO	"})
aAdd( aSIX_SDoc , {"DT6E","DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SDOC	"})
aAdd( aSIX_SDoc , {"DT6F","DT6_FILIAL+DT6_FILORI+DT6_LOTNFC+DT6_FILDOC+DT6_DOC+DT6_SDOC	"})
aAdd( aSIX_SDoc , {"DT6G","DT6_FILIAL+DT6_CLIREM+DT6_LOJREM+DT6_LOTCET+DT6_FILDOC+DT6_DOC+DT6_SDOC	"})
aAdd( aSIX_SDoc , {"DT6H","DT6_FILIAL+DT6_FILDCO+DT6_DOCDCO+DT6_SDOCOR	"})
aAdd( aSIX_SDoc , {"DT86","DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SDOC+DT8_CODPRO+DT8_CODPAS	"})
aAdd( aSIX_SDoc , {"DT87","DT8_FILIAL+DT8_TABFRE+DT8_TIPTAB+DT8_CDRORI+DT8_CDRDES+DT8_SEQTAB+DT8_FILDOC+DT8_DOC+DT8_SDOC	"})
aAdd( aSIX_SDoc , {"DTA6","DTA_FILIAL+DTA_FILDOC+DTA_DOC+DTA_SDOC+DTA_FILORI+DTA_VIAGEM	"})
aAdd( aSIX_SDoc , {"DTA7","DTA_FILIAL+DTA_FILORI+DTA_VIAGEM+DTA_FILDOC+DTA_DOC+DTA_SDOC	"})
aAdd( aSIX_SDoc , {"DTA8","DTA_FILIAL+DTA_LOCAL+DTA_LOCALI+DTA_UNITIZ+DTA_CODANA+DTA_FILDOC+DTA_DOC+DTA_SDOC+DTA_FILORI+DTA_VIAGEM	"})
aAdd( aSIX_SDoc , {"DTA9","DTA_FILIAL+DTA_SERTMS+DTA_TIPTRA+DTA_FILORI+DTA_VIAGEM+DTA_FILDOC+DTA_DOC+DTA_SDOC	"})
aAdd( aSIX_SDoc , {"DTCA","DTC_FILIAL+DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+DTC_SERVIC+DTC_CODPRO+DTC_NUMNFC+DTC_SDOCC	"})
aAdd( aSIX_SDoc , {"DTCB","DTC_FILIAL+DTC_NUMNFC+DTC_SDOCC+DTC_CLIREM+DTC_LOJREM+DTC_CODPRO+DTC_FILORI+DTC_LOTNFC	"})
aAdd( aSIX_SDoc , {"DTCC","DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SDOC+DTC_SERVIC+DTC_CODPRO	"})
aAdd( aSIX_SDoc , {"DTCD","DTC_FILIAL+DTC_FILDOC+DTC_DOCPER+DTC_SDOC+DTC_SERVIC+DTC_CODPRO	"})
aAdd( aSIX_SDoc , {"DTCE","DTC_FILIAL+DTC_CLIREM+DTC_LOJREM+DTC_NUMNFC+DTC_SDOCC	"})
aAdd( aSIX_SDoc , {"DTCF","DTC_FILIAL+DTC_CLIDES+DTC_LOJDES+DTC_NUMNFC+DTC_SDOCC	"})
aAdd( aSIX_SDoc , {"DTCG","DTC_FILIAL+DTC_DOC+DTC_SERIE+DTC_FILDOC+DTC_NUMNFC+DTC_SDOCC	"})
aAdd( aSIX_SDoc , {"DTE4","DTE_FILIAL+DTE_FILORI+DTE_NUMNFC+DTE_SDOCC+DTE_CLIREM+DTE_LOJREM+DTE_CODPRO	"})
aAdd( aSIX_SDoc , {"DTX8","DTX_FILIAL+DTX_MANIFE+DTX_SDOCMN	"})
aAdd( aSIX_SDoc , {"DTX9","DTX_FILIAL+DTX_FILMAN+DTX_MANIFE+DTX_SDOCMN	"})
aAdd( aSIX_SDoc , {"DTXA","DTX_FILIAL+DTX_FILORI+DTX_VIAGEM+DTX_FILMAN+DTX_MANIFE+DTX_SDOCMN	"})
aAdd( aSIX_SDoc , {"DTXB","DTX_FILIAL+DTX_TIPMAN+DTX_STATUS+DTX_FILMAN+DTX_MANIFE+DTX_SDOCMN	"})
aAdd( aSIX_SDoc , {"DU15","DU1_FILIAL+DU1_FILDOC+DU1_DOC+DU1_SDOC	"})
aAdd( aSIX_SDoc , {"DU16","DU1_FILIAL+DU1_NUMNFC+DU1_SDOCC+DU1_CODCLI+DU1_LOJCLI	"})
aAdd( aSIX_SDoc , {"DU17","DU1_FILIAL+DU1_CODCLI+DU1_LOJCLI+DU1_NUMNFC+DU1_SDOCC	"})
aAdd( aSIX_SDoc , {"DU72","DU7_FILIAL+DU7_FILDOC+DU7_DOC+DU7_SDOC	"})
aAdd( aSIX_SDoc , {"DUAC","DUA_FILIAL+DUA_CODOCO+DUA_FILDOC+DUA_DOC+DUA_SDOC	"})
aAdd( aSIX_SDoc , {"DUAD","DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SDOC+DUA_FILORI+DUA_VIAGEM	"})
aAdd( aSIX_SDoc , {"DUAE","DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SDOC+DUA_SEQOCO	"})
aAdd( aSIX_SDoc , {"DUAF","DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SDOC+DUA_TIPUSO+DUA_IDENT	"})
aAdd( aSIX_SDoc , {"DUB9","DUB_FILIAL+DUB_FILDOC+DUB_DOC+DUB_SDOC+DUB_STATUS	"})
aAdd( aSIX_SDoc , {"DUDA","DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SDOC+DUD_FILORI+DUD_VIAGEM	"})
aAdd( aSIX_SDoc , {"DUDB","DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_SEQUEN+DUD_FILDOC+DUD_DOC+DUD_SDOC	"})
aAdd( aSIX_SDoc , {"DUDC","DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_FILMAN+DUD_MANIFE+DUD_SDOCMN	"})
aAdd( aSIX_SDoc , {"DUDD","DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SDOC+DUD_NUMROM	"})
aAdd( aSIX_SDoc , {"DUU8","DUU_FILIAL+DUU_FILDOC+DUU_DOC+DUU_SDOC+DUU_STATUS	"})
aAdd( aSIX_SDoc , {"DUU9","DUU_FILIAL+DUU_FILRID+DUU_NUMRID+DUU_FILDOC+DUU_DOC+DUU_SDOC	"})
aAdd( aSIX_SDoc , {"DV44","DV4_FILIAL+DV4_FILOCO+DV4_NUMOCO+DV4_FILDOC+DV4_DOC+DV4_SDOC+DV4_NUMNFC+DV4_SDOCC	"})
aAdd( aSIX_SDoc , {"DV45","DV4_FILIAL+DV4_FILDOC+DV4_DOC+DV4_SDOC+DV4_NUMNFC+DV4_SDOCC	"})
aAdd( aSIX_SDoc , {"DVS2","DVS_FILIAL+DVS_FILDOC+DVS_DOC+DVS_SDOC+DVS_CODPAS	"})
aAdd( aSIX_SDoc , {"DVV3","DVV_FILIAL+DVV_FILDOC+DVV_DOC+DVV_SDOC+DVV_PREFIX+DVV_NUM+DVV_TIPO	"})
aAdd( aSIX_SDoc , {"DVX5","DVX_FILIAL+DVX_FILDOC+DVX_DOC+DVX_SDOC+DVX_FILORI	"})
aAdd( aSIX_SDoc , {"DXM4","DXM_PRDTOR+DXM_LJPRO+DXM_FAZ	"})
aAdd( aSIX_SDoc , {"DXM5","DXM_FILIAL+DXM_NOTA+DXM_SDOC+DXM_ITEMNF	"})
aAdd( aSIX_SDoc , {"DY42","DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SDOC+DY4_NUMNFC+DY4_SDOCC+DY4_CODPRO	"})
aAdd( aSIX_SDoc , {"DYC2","DYC_FILIAL+DYC_NUMROM+DYC_FILDOC+DYC_DOC+DYC_SDOC	"})
aAdd( aSIX_SDoc , {"DYJ3","DYJ_FILIAL+DYJ_FILDOC+DYJ_DOC+DYJ_SDOC+DYJ_NUMAGD+DYJ_ITEAGD	"})
aAdd( aSIX_SDoc , {"DYN4","DYN_FILIAL+DYN_FILMAN+DYN_MANIFE+DYN_SDOCMN+DYN_STCMDF	"})
aAdd( aSIX_SDoc , {"ED89","ED8_FILIAL+ED8_NF+ED8_SDOC	"})
aAdd( aSIX_SDoc , {"EES5","EES_FILIAL+EES_PREEMB+EES_NRNF+EES_SDOC+EES_PEDIDO+EES_SEQUEN	"})
aAdd( aSIX_SDoc , {"EEZ2","EEZ_FILIAL+EEZ_PREEMB+EEZ_CNPJ+EEZ_SDOC+EEZ_NF	"})
aAdd( aSIX_SDoc , {"EI13","EI1_FILIAL+EI1_HAWB+EI1_DOC+EI1_SDOC	"})
aAdd( aSIX_SDoc , {"EI23","EI2_FILIAL+EI2_HAWB+EI2_DOC+EI2_SDOC+EI2_PGI_NU+EI2_PO_NUM+EI2_POSICA	"})
aAdd( aSIX_SDoc , {"EI24","EI2_FILIAL+EI2_DOC+EI2_SDOC+EI2_HAWB+EI2_PGI_NU+EI2_PO_NUM+EI2_POSICA	"})
aAdd( aSIX_SDoc , {"EW13","EW1_FILIAL+EW1_NUMNF+EW1_SDOC	"})
aAdd( aSIX_SDoc , {"EW23","EW2_FILIAL+EW2_NUMNF+EW2_SDOC	"})
aAdd( aSIX_SDoc , {"FN66","FN6_FILIAL+FN6_NUMNF+FN6_SDOC	"})
aAdd( aSIX_SDoc , {"FR35","FR3_FILIAL+FR3_CART+FR3_DOC+FR3_SDOC+FR3_PEDIDO	"})
aAdd( aSIX_SDoc , {"FR36","FR3_FILIAL+FR3_CART+FR3_CLIENT+FR3_LOJA+FR3_PREFIX+FR3_NUM+FR3_PARCEL+FR3_TIPO+FR3_DOC+FR3_SDOC+FR3_PEDIDO	"})
aAdd( aSIX_SDoc , {"FR37","FR3_FILIAL+FR3_CART+FR3_FORNEC+FR3_LOJA+FR3_PREFIX+FR3_NUM+FR3_PARCEL+FR3_TIPO+FR3_DOC+FR3_SDOC+FR3_PEDIDO	"})
aAdd( aSIX_SDoc , {"GW1F","GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SDOC+GW1_NRDC	"})
aAdd( aSIX_SDoc , {"GW1G","GW1_FILIAL+GW1_NRROM+GW1_CDTPDC+GW1_EMISDC+GW1_SDOC+GW1_NRDC	"})
aAdd( aSIX_SDoc , {"GW1H","GW1_CDTPDC+GW1_EMISDC+GW1_SDOC+GW1_NRDC	"})
aAdd( aSIX_SDoc , {"GW1I","GW1_FILIAL+GW1_SDOC+GW1_NRDC	"})
aAdd( aSIX_SDoc , {"GW1J","GW1_EMISDC+GW1_SDOC+GW1_NRDC	"})
aAdd( aSIX_SDoc , {"GW43","GW4_FILIAL+GW4_EMISDF+GW4_CDESP+GW4_SERDF+GW4_NRDF+DTOS(GW4_DTEMIS)+GW4_EMISDC+GW4_SDOCDC+GW4_NRDC+GW4_TPDC	"})
aAdd( aSIX_SDoc , {"GW44","GW4_FILIAL+GW4_EMISDC+GW4_SDOCDC+GW4_NRDC+GW4_TPDC	"})
aAdd( aSIX_SDoc , {"GW83","GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SDOCDC+GW8_NRDC+GW8_ITEM+GW8_UNINEG+GW8_INFO1	"})
aAdd( aSIX_SDoc , {"GW84","GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SDOCDC+GW8_NRDC+GW8_SEQ	"})
aAdd( aSIX_SDoc , {"GWB3","GWB_FILIAL+GWB_CDTPDC+GWB_EMISDC+GWB_SDOCDC+GWB_NRDC+GWB_CDUNIT	"})
aAdd( aSIX_SDoc , {"GWE3","GWE_FILIAL+GWE_CDTPDC+GWE_EMISDC+GWE_SDOCDC+GWE_NRDC+GWE_FILDT+GWE_NRDT+GWE_SERDT	"})
aAdd( aSIX_SDoc , {"GWE4","GWE_FILIAL+GWE_FILDT+GWE_NRDT+GWE_SDOCDT	"})
aAdd( aSIX_SDoc , {"GWH3","GWH_FILIAL+GWH_NRCALC+GWH_CDTPDC+GWH_EMISDC+GWH_SDOCDC+GWH_NRDC	"})
aAdd( aSIX_SDoc , {"GWH4","GWH_FILIAL+GWH_CDTPDC+GWH_EMISDC+GWH_SDOCDC+GWH_NRDC+GWH_NRCALC	"})
aAdd( aSIX_SDoc , {"GWL3","GWL_FILIAL+GWL_NROCO+GWL_FILDC+GWL_EMITDC+GWL_SDOCDC+GWL_NRDC+GWL_TPDC	"})
aAdd( aSIX_SDoc , {"GWL4","GWL_FILIAL+GWL_NRDC+GWL_FILDC+GWL_EMITDC+GWL_SDOCDC+GWL_TPDC+GWL_NROCO	"})
aAdd( aSIX_SDoc , {"GWM4","GWM_FILIAL+GWM_TPDOC+GWM_CDESP+GWM_CDTRP+GWM_SERDOC+GWM_NRDOC+DTOS(GWM_DTEMIS)+GWM_CDTPDC+GWM_EMISDC+GWM_SDOCDC+GWM_NRDC+GWM_SEQGW8	"})
aAdd( aSIX_SDoc , {"GWM5","GWM_FILIAL+GWM_CDTPDC+GWM_EMISDC+GWM_SDOCDC+GWM_NRDC	"})
aAdd( aSIX_SDoc , {"GWU7","GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SDOC+GWU_NRDC+GWU_SEQ	"})
aAdd( aSIX_SDoc , {"GWU8","GWU_CDTRP+GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SDOC+GWU_NRDC+GWU_SEQ	"})
aAdd( aSIX_SDoc , {"GWW3","GWW_FILIAL+GWW_NRAGEN+GWW_CDTPDC+GWW_EMISDC+GWW_SDOC+GWW_NRDC	"})
aAdd( aSIX_SDoc , {"GWW4","GWW_FILIAL+GWW_CDTPDC+GWW_EMISDC+GWW_SDOC+GWW_NRDC	"})
aAdd( aSIX_SDoc , {"GXA4","GXA_FILIAL+GXA_NRMOV+GXA_CDPTCT+GXA_SEQ+GXA_CDTPDC+GXA_EMISDC+GXA_SDOC+GXA_NRDC	"})
aAdd( aSIX_SDoc , {"GXA5","GXA_FILIAL+GXA_CDTPDC+GXA_EMISDC+GXA_SDOC+GXA_NRDC	"})
aAdd( aSIX_SDoc , {"HB63","HB6_FILIAL+HB6_ID+HB6_COD+HB6_DOC+HB6_SDOC	"})
aAdd( aSIX_SDoc , {"HB64","HB6_FILIAL+HB6_ID+HB6_DOC+HB6_SDOC+DTOS(HB6_DATA)	"})
aAdd( aSIX_SDoc , {"HD22","HD2_FILIAL+HD2_ID+HD2_DOC+HD2_SDOC+HD2_ITEM	"})
aAdd( aSIX_SDoc , {"HF13","HF1_FILIAL+HF1_ID+HF1_DOC+HF1_SDOC	"})
aAdd( aSIX_SDoc , {"HF23","HF2_FILIAL+HF2_ID+HF2_DOC+HF2_SDOC	"})
aAdd( aSIX_SDoc , {"MAX4","MAX_FILIAL+MAX_NUM+MAX_SDOC	"})
aAdd( aSIX_SDoc , {"MB13","MB1_FILIAL+MB1_SDOC+MB1_NF+MB1_CODIGO	"})
aAdd( aSIX_SDoc , {"MBJ6","MBJ_FILIAL+MBJ_DOC+MBJ_SDOC+MBJ_PROD+MBJ_ITEM	"})
aAdd( aSIX_SDoc , {"MBN4","MBN_FILIAL+MBN_NUMCAR+MBN_DOC+MBN_SDOC+MBN_ITSALD	"})
aAdd( aSIX_SDoc , {"MBZ3","MBZ_FILIAL+MBZ_CUPOM+MBZ_SDOC+MBZ_FORMA+MBZ_PARCEL	"})
aAdd( aSIX_SDoc , {"MBZ4","MBZ_FILIAL+MBZ_SITUA+MBZ_CUPOM+MBZ_SDOC	"})
aAdd( aSIX_SDoc , {"MDD3","MDD_FILIAL+MDD_SDOCRC+MDD_DOCR+MDD_PDVR	"})
aAdd( aSIX_SDoc , {"MDJ4","MDJ_FILIAL+MDJ_DOC+MDJ_SDOC+MDJ_CLIENT+MDJ_LOJA	"})
aAdd( aSIX_SDoc , {"MDK3","MDK_FILIAL+MDK_DOC+MDK_SDOC+MDK_CLIENT+MDK_LOJA	"})
aAdd( aSIX_SDoc , {"MDL3","MDL_FILIAL+MDL_NFCUP+MDL_SDOC+MDL_CUPOM+MDL_SERCUP	"})
aAdd( aSIX_SDoc , {"MDU4","MDU_FILIAL+MDU_DOC+MDU_SDOC+MDU_PRODUT	"})
aAdd( aSIX_SDoc , {"MFI6","MFI_FILIAL+MFI_FILORI+MFI_DOC+MFI_SDOC+MFI_ITEM	"})
aAdd( aSIX_SDoc , {"NOA4","NOA_FILIAL+NOA_TIPDOC+NOA_SDOC+NOA_NUMDOC+NOA_CLIFOR+NOA_LOJACF	"})
aAdd( aSIX_SDoc , {"QEKF","QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_NTFISC+QEK_SDOC+QEK_ITEMNF+QEK_TIPONF+QEK_NUMSEQ	"})
aAdd( aSIX_SDoc , {"QEKG","QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_NTFISC+QEK_SDOC+QEK_ITEMNF+QEK_TIPONF+QEK_LOTE+QEK_NUMSEQ	"})
aAdd( aSIX_SDoc , {"QEY5","QEY_FILIAL+QEY_FORNEC+QEY_LOJFOR+QEY_PRODUT+QEY_NTFISC+QEY_SDOC+QEY_ITEMNF+QEY_TIPONF+DTOS(QEY_DTENTR)+QEY_LOTE+QEY_ENSAIO	"})
aAdd( aSIX_SDoc , {"QEZ4","QEZ_FILIAL+QEZ_FORNEC+QEZ_LOJFOR+QEZ_GRUPO+QEZ_NTFISC+QEZ_SDOC+QEZ_ITEMNF+QEZ_TIPONF+DTOS(QEZ_DTENTR)+QEZ_LOTE+QEZ_ENSAIO	"})
aAdd( aSIX_SDoc , {"SC6D","C6_FILIAL+C6_NOTA+C6_SDOC	"})
aAdd( aSIX_SDoc , {"SC6E","C6_FILIAL+C6_CLI+C6_LOJA+C6_PRODUTO+C6_NFORI+C6_SDOCORI+C6_ITEMORI	"})
aAdd( aSIX_SDoc , {"SC9A","C9_FILIAL+C9_SDOCNF+C9_NFISCAL+C9_CARGA+C9_SEQCAR	"})
aAdd( aSIX_SDoc , {"SCU5","CU_FILIAL+CU_FORNECE+CU_LOJA+CU_NFISCAL+CU_SDOCNF	"})
aAdd( aSIX_SDoc , {"SCU6","CU_FILIAL+CU_FORNECE+CU_LOJA+CU_NCRED+CU_SDOCNCP	"})
aAdd( aSIX_SDoc , {"SD1D","D1_FILIAL+D1_DOC+D1_SDOC+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM	"})
aAdd( aSIX_SDoc , {"SD1E","D1_FILIAL+D1_COD+D1_DOC+D1_SDOC+D1_FORNECE+D1_LOJA	"})
aAdd( aSIX_SDoc , {"SD1F","D1_FILIAL+DTOS(D1_EMISSAO)+D1_DOC+D1_SDOC+D1_FORNECE+D1_LOJA	"})
aAdd( aSIX_SDoc , {"SD1G","D1_FILIAL+D1_FORNECE+D1_LOJA+D1_SDOCREM+D1_REMITO+D1_ITEMREM	"})
aAdd( aSIX_SDoc , {"SD1H","D1_FILIAL+D1_DOC+D1_SDOC+D1_FORNECE+D1_LOJA+D1_COD+D1_LOTECTL+D1_NUMLOTE+DTOS(D1_DTVALID)	"})
aAdd( aSIX_SDoc , {"SD2D","D2_FILIAL+D2_DOC+D2_SDOC+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM	"})
aAdd( aSIX_SDoc , {"SD2E","D2_FILIAL+D2_PDV+D2_SDOC+D2_DOC+D2_CLIENTE+D2_LOJA	"})
aAdd( aSIX_SDoc , {"SD2F","D2_FILIAL+D2_CLIENTE+D2_LOJA+D2_SDOCREM+D2_REMITO+D2_ITEMREM	"})
aAdd( aSIX_SDoc , {"SD2G","D2_FILIAL+D2_NFORI+D2_SDOCORI	"})
aAdd( aSIX_SDoc , {"SD86","D8_FILIAL+D8_DOC+D8_SDOC+D8_ITEM	"})
aAdd( aSIX_SDoc , {"SD96","D9_FILIAL+D9_SDOC+DTOS(D9_DTUSO)+D9_DOC	"})
aAdd( aSIX_SDoc , {"SD97","D9_FILIAL+D9_SDOC+D9_DOC+DTOS(D9_DTUSO)	"})
aAdd( aSIX_SDoc , {"SD98","D9_FILIAL+D9_NSU+D9_SDOC+D9_DOC	"})
aAdd( aSIX_SDoc , {"SD99","D9_CNPJ+D9_SDOC+DTOS(D9_DTUSO)+D9_DOC	"})
aAdd( aSIX_SDoc , {"SD9A","D9_CNPJ+D9_SDOC+D9_DOC+DTOS(D9_DTUSO)	"})
aAdd( aSIX_SDoc , {"SDA3","DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SDOC+DA_CLIFOR+DA_LOJA	"})
aAdd( aSIX_SDoc , {"SDBH","DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SDOC+DB_CLIFOR+DB_LOJA+DB_ITEM	"})
aAdd( aSIX_SDoc , {"SDBI","DB_FILIAL+DB_DOC+DB_SDOC+DB_CLIFOR+DB_LOJA+DB_SERVIC+DB_TAREFA	"})
aAdd( aSIX_SDoc , {"SDBJ","DB_FILIAL+DB_PRODUTO+DB_DOC+DB_SDOC+DB_CLIFOR+DB_LOJA+DB_SERVIC+DB_TAREFA+DB_ATIVID	"})
aAdd( aSIX_SDoc , {"SDBK","DB_FILIAL+DB_STATUS+DB_SERVIC+DB_ORDTARE+DB_TAREFA+DB_ORDATIV+DB_ATIVID+DB_DOC+DB_SDOC+DB_CLIFOR+DB_LOJA+DB_ITEM	"})
aAdd( aSIX_SDoc , {"SDBL","DB_FILIAL+DB_STATUS+DB_SERVIC+DB_DOC+DB_SDOC+DB_CLIFOR+DB_LOJA+DB_ITEM+DB_ORDTARE+DB_ORDATIV	"})
aAdd( aSIX_SDoc , {"SDBM","DB_FILIAL+DB_DOC+DB_SDOC+DB_CLIFOR+DB_LOJA+DB_IDOPERA	"})
aAdd( aSIX_SDoc , {"SDBN","DB_FILIAL+DB_DOC+DB_SDOC+DB_SERVIC+DB_TAREFA+DB_ATIVID+DB_ESTORNO	"})
aAdd( aSIX_SDoc , {"SDBO","DB_FILIAL+DB_STATUS+DB_PRIORI+DB_CARGA+DB_DOC+DB_SDOC+DB_CLIFOR+DB_LOJA+DB_ITEM+DB_SERVIC+DB_ORDTARE+DB_ORDATIV	"})
aAdd( aSIX_SDoc , {"SDE2","DE_FILIAL+DE_DOC+DE_SDOC+DE_FORNECE+DE_LOJA+DE_ITEMNF+DE_ITEM	"})
aAdd( aSIX_SDoc , {"SDH3","DH_FILIAL+DH_TPMOV+DH_SDOC+DH_DOC+DH_ITEM+DH_CLIENTE+DH_LOJACLI+DH_FORNECE+DH_LOJAFOR+DH_OPER+DH_IDENTNF+DH_ITEMCOB	"})
aAdd( aSIX_SDoc , {"SDS3","DS_FILIAL+DS_DOC+DS_SDOC+DS_FORNEC+DS_LOJA	"})
aAdd( aSIX_SDoc , {"SDT5","DT_FILIAL+DT_CNPJ+DT_FORNEC+DT_LOJA+DT_DOC+DT_SDOC	"})
aAdd( aSIX_SDoc , {"SDT6","DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SDOC+DT_PRODFOR	"})
aAdd( aSIX_SDoc , {"SDT7","DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SDOC+DT_COD	"})
aAdd( aSIX_SDoc , {"SE5M","E5_FILIAL+E5_ORDREC+E5_SDOCREC	"})
aAdd( aSIX_SDoc , {"SELA","EL_FILIAL+DTOS(EL_DTDIGIT)+EL_RECIBO+EL_TIPODOC+EL_SDOC	"})
aAdd( aSIX_SDoc , {"SELB","EL_FILIAL+EL_COBRAD+EL_RECIBO+EL_SDOC	"})
aAdd( aSIX_SDoc , {"SELC","EL_FILIAL+EL_CLIORIG+EL_LOJORIG+EL_RECIBO+EL_SDOC	"})
aAdd( aSIX_SDoc , {"SELD","EL_FILIAL+EL_SDOC+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO	"})
aAdd( aSIX_SDoc , {"SEX5","EX_FILIAL+EX_NUM+DTOS(EX_EMISSAO)+EX_SDOCREC	"})
aAdd( aSIX_SDoc , {"SEX6","EX_FILIAL+EX_COBRAD+EX_NUM+EX_TIPODOC+EX_TITULO+EX_SDOCREC	"})
aAdd( aSIX_SDoc , {"SEX7","EX_FILIAL+EX_COBRAD+EX_NUM+DTOS(EX_EMISSAO)+EX_SDOCREC	"})
aAdd( aSIX_SDoc , {"SEY5","EY_FILIAL+EY_SDOC+EY_RECINI+EY_COBRAD	"})
aAdd( aSIX_SDoc , {"SF1A","F1_FILIAL+F1_DOC+F1_SDOC+F1_FORNECE+F1_LOJA+F1_TIPO	"})
aAdd( aSIX_SDoc , {"SF1B","F1_FILIAL+F1_HAWB+F1_TIPO_NF+F1_DOC+F1_SDOC	"})
aAdd( aSIX_SDoc , {"SF2B","F2_FILIAL+F2_DOC+F2_SDOC+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO	"})
aAdd( aSIX_SDoc , {"SF2C","F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SDOC	"})
aAdd( aSIX_SDoc , {"SF2D","F2_FILIAL+F2_ECF+DTOS(F2_EMISSAO)+F2_PDV+F2_SDOC+F2_MAPA+F2_DOC	"})
aAdd( aSIX_SDoc , {"SF2E","F2_FILIAL+F2_SDOC+DTOS(F2_EMISSAO)+F2_DOC+F2_CLIENTE+F2_LOJA	"})
aAdd( aSIX_SDoc , {"SF2F","F2_FILIAL+F2_CARGA+F2_SEQCAR+F2_SDOC+F2_DOC+F2_CLIENTE+F2_LOJA	"})
aAdd( aSIX_SDoc , {"SF2G","F2_FILIAL+F2_SDOCORI+F2_NFORI	"})
aAdd( aSIX_SDoc , {"SF39","F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SDOC+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM,5,2)	"})
aAdd( aSIX_SDoc , {"SF3A","F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SDOC	"})
aAdd( aSIX_SDoc , {"SF3B","F3_FILIAL+F3_SDOC+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+F3_IDENTFT	"})
aAdd( aSIX_SDoc , {"SF3C","F3_FILIAL+F3_NFISCAL+F3_SDOC	"})
aAdd( aSIX_SDoc , {"SF64","F6_FILIAL+F6_OPERNF+F6_TIPODOC+F6_DOC+F6_SDOC+F6_CLIFOR+F6_LOJA	"})
aAdd( aSIX_SDoc , {"SF84","F8_FILIAL+F8_NFDIFRE+F8_SDOCFRE+F8_FORNECE+F8_LOJA	"})
aAdd( aSIX_SDoc , {"SF85","F8_FILIAL+F8_NFORIG+F8_SDOCORI+F8_FORNECE+F8_LOJA	"})
aAdd( aSIX_SDoc , {"SF86","F8_FILIAL+F8_NFDIFRE+F8_SDOCFRE+F8_TRANSP+F8_LOJTRAN	"})
aAdd( aSIX_SDoc , {"SF93","F9_FILIAL+DTOS(F9_DTENTNE)+F9_DOCNFE+F9_SDOCNFE+F9_FORNECE+F9_LOJAFOR+F9_CFOENT+STR(F9_PICM,5,2)	"})
aAdd( aSIX_SDoc , {"SFEC","FE_FILIAL+FE_FORNECE+FE_LOJA+FE_NFISCAL+FE_SDOC+FE_TIPO+FE_CONCEPT	"})
aAdd( aSIX_SDoc , {"SFED","FE_FILIAL+FE_CLIENTE+FE_LOJCLI+FE_NFISCAL+FE_SDOC	"})
aAdd( aSIX_SDoc , {"SFT8","FT_FILIAL+FT_TIPOMOV+FT_SDOC+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO	"})
aAdd( aSIX_SDoc , {"SFT9","FT_FILIAL+FT_TIPOMOV+DTOS(FT_ENTRADA)+FT_SDOC+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO	"})
aAdd( aSIX_SDoc , {"SFTA","FT_FILIAL+FT_TIPOMOV+FT_CLIEFOR+FT_LOJA+FT_SDOC+FT_NFISCAL+FT_IDENTF3	"})
aAdd( aSIX_SDoc , {"SFTB","FT_FILIAL+FT_TIPOMOV+FT_CLIEFOR+FT_LOJA+FT_SDOC+FT_NFISCAL+FT_CFOP	"})
aAdd( aSIX_SDoc , {"SFTC","FT_FILIAL+FT_TIPOMOV+FT_NFISCAL+FT_SDOC	"})
aAdd( aSIX_SDoc , {"SFU5","FU_FILIAL+FU_TIPOMOV+FU_SDOC+FU_DOC+FU_CLIFOR+FU_LOJA+FU_ITEM+FU_COD	"})
aAdd( aSIX_SDoc , {"SFU6","FU_FILIAL+FU_TIPOMOV+FU_ESPECIE+FU_SDOC+FU_DOC+FU_CLIFOR+FU_LOJA+FU_ITEM+FU_COD	"})
aAdd( aSIX_SDoc , {"SFX4","FX_FILIAL+FX_TIPOMOV+FX_SDOC+FX_DOC+FX_CLIFOR+FX_LOJA+FX_ITEM+FX_COD	"})
aAdd( aSIX_SDoc , {"SFX5","FX_FILIAL+FX_TIPOMOV+FX_ESPECIE+FX_SDOC+FX_DOC+FX_CLIFOR+FX_LOJA+FX_ITEM+FX_COD	"})
aAdd( aSIX_SDoc , {"SL1J","L1_FILIAL+L1_SDOC+L1_DOC+L1_PDV	"})
aAdd( aSIX_SDoc , {"SL1K","L1_FILIAL+L1_SDOCPED+L1_DOCPED	"})
aAdd( aSIX_SDoc , {"SL27","L2_FILIAL+L2_SDOC+L2_DOC+L2_PRODUTO	"})
aAdd( aSIX_SDoc , {"SL66","L6_FILIAL+L6_SDOC+L6_ESTACAO	"})
aAdd( aSIX_SDoc , {"SLX4","LX_FILIAL+LX_PDV+LX_CUPOM+LX_SDOC+LX_ITEM+LX_HORA	"})
aAdd( aSIX_SDoc , {"SN1A","N1_FILIAL+N1_FORNEC+N1_LOJA+N1_NFESPEC+N1_SDOC+N1_NSERIE+N1_NFITEM	"})
aAdd( aSIX_SDoc , {"SUAC","UA_FILIAL+UA_SDOC+UA_DOC	"})
aAdd( aSIX_SDoc , {"SWN4","WN_FILIAL+WN_DOC+WN_SDOC+WN_TEC+WN_EX_NCM+WN_EX_NBM	"})
aAdd( aSIX_SDoc , {"SWN5","WN_FILIAL+WN_DOC+WN_SDOC+WN_FORNECE+WN_LOJA	"})
aAdd( aSIX_SDoc , {"SWW3","WW_FILIAL+WW_NF_COMP+WW_SDOC+WW_FORNECE+WW_LOJA+WW_PO_NUM+WW_NR_CONT	"})
aAdd( aSIX_SDoc , {"TE03","TE0_FILIAL+TE0_DOC+TE0_SDOC+TE0_ITEM	"})
aAdd( aSIX_SDoc , {"TE13","TE1_FILIAL+TE1_DOC+TE1_SDOC+TE1_ITEM	"})
aAdd( aSIX_SDoc , {"TE23","TE2_FILIAL+TE2_DOC+TE2_SDOC+TE2_ITEM	"})
aAdd( aSIX_SDoc , {"TEWE","TEW_FILIAL+TEW_NFSAI+TEW_SDOCS+TEW_ITSAI	"})
aAdd( aSIX_SDoc , {"TEWF","TEW_FILIAL+TEW_NFENT+TEW_SDOCE+TEW_ITENT	"})
aAdd( aSIX_SDoc , {"VD26","VD2_FILIAL+VD2_NUMNFI+VD2_SDOC+DTOS(VD2_DATPAG)	"})
aAdd( aSIX_SDoc , {"VDD7","VDD_FILIAL+VDD_NUMNFI+VDD_SDOC+VDD_CODFOR+VDD_LOJA	"})
aAdd( aSIX_SDoc , {"VDV6","VDV_FILIAL+VDV_CHAINT+VDV_SFILNF+VDV_SNUMNF+VDV_SDOCS	"})
aAdd( aSIX_SDoc , {"VDV7","VDV_FILIAL+VDV_CHAINT+VDV_EFILNF+VDV_ENUMNF+VDV_SDOCE+VDV_ECDFOR+VDV_ELJFOR	"})
aAdd( aSIX_SDoc , {"VDV8","VDV_FILIAL+VDV_SFILNF+VDV_SNUMNF+VDV_SDOCS+VDV_CHAINT	"})
aAdd( aSIX_SDoc , {"VDV9","VDV_FILIAL+VDV_EFILNF+VDV_ENUMNF+VDV_SDOCE+VDV_ECDFOR+VDV_ELJFOR+VDV_CHAINT	"})
aAdd( aSIX_SDoc , {"VEC7","VEC_FILIAL+VEC_NUMNFI+VEC_SDOC+VEC_GRUITE+VEC_CODITE	"})
aAdd( aSIX_SDoc , {"VEC8","VEC_FILIAL+VEC_NFIORI+VEC_SDOCOR+VEC_GRUITE+VEC_CODITE	"})
aAdd( aSIX_SDoc , {"VF34","VF3_FILIAL+DTOS(VF3_DATPOS)+VF3_CHAINT+VF3_NUMNFI+VF3_SDOC	"})
aAdd( aSIX_SDoc , {"VF35","VF3_FILIAL+VF3_CHAINT+DTOS(VF3_DATPOS)+VF3_NUMNFI+VF3_SDOC	"})
aAdd( aSIX_SDoc , {"VG55","VG5_FILIAL+VG5_CODMAR+VG5_NUMNFI+VG5_SDOCS+VG5_PECINT+VG5_SERINT	"})
aAdd( aSIX_SDoc , {"VG56","VG5_FILIAL+VG5_CODMAR+VG5_NUMNFI+VG5_SDOCS+VG5_ORDITE+VG5_PECINT+VG5_SERINT	"})
aAdd( aSIX_SDoc , {"VG68","VG6_FILIAL+VG6_CODMAR+VG6_RENNF1+VG6_SDOCS+VG6_ITEMNF	"})
aAdd( aSIX_SDoc , {"VGA3","VGA_FILIAL+VGA_CODMAR+VGA_NUMNFI+VGA_SDOCE	"})
aAdd( aSIX_SDoc , {"VI03","VI0_FILIAL+VI0_CODMAR+VI0_SDOC+VI0_NUMNFI	"})
aAdd( aSIX_SDoc , {"VI04","VI0_FILIAL+VI0_CODMAR+VI0_NUMNFI+VI0_SDOC+VI0_CODFOR+VI0_LOJFOR	"})
aAdd( aSIX_SDoc , {"VIA4","VIA_FILIAL+VIA_CODMAR+VIA_SDOC+VIA_NUMNFI+VIA_CODITE+VIA_PEDCON	"})
aAdd( aSIX_SDoc , {"VIA5","VIA_FILIAL+VIA_CODMAR+VIA_NUMNFI+VIA_SDOC+VIA_CODFOR+VIA_LOJFOR	"})
aAdd( aSIX_SDoc , {"VIK2","VIK_FILIAL+VIK_TIPO+VIK_NUMNFI+VIK_SDOC	"})
aAdd( aSIX_SDoc , {"VIP2","VIP_FILIAL+VIP_NUMNFI+VIP_SDOCNF	"})
aAdd( aSIX_SDoc , {"VIQ2","VIQ_FILIAL+VIQ_NUMNFI+VIQ_SDOC	"})
aAdd( aSIX_SDoc , {"VIV2","VIV_FILIAL+VIV_CODMAR+VIV_NUMNFI+VIV_SDOC	"})
aAdd( aSIX_SDoc , {"VIW3","VIW_FILIAL+VIW_NUMOSV+VIW_NUMNFI+VIW_SDOC	"})
aAdd( aSIX_SDoc , {"VJC4","VJC_FILIAL+VJC_CLIFAT+VJC_LOJA+VJC_SDOC+VJC_NUMNFI	"})
aAdd( aSIX_SDoc , {"VJC5","VJC_FILIAL+VJC_SDOC+VJC_NUMNFI+VJC_TIPO	"})
aAdd( aSIX_SDoc , {"VJI4","VJI_FILIAL+VJI_GRUITE+VJI_CODITE+VJI_SDOC+VJI_NUMNFI	"})
aAdd( aSIX_SDoc , {"VJI5","VJI_FILIAL+VJI_SDOC+VJI_NUMNFI+VJI_TIPO	"})
aAdd( aSIX_SDoc , {"VO39","VO3_FILIAL+VO3_NUMNFI+VO3_SDOC	"})
aAdd( aSIX_SDoc , {"VO4B","VO4_FILIAL+VO4_NUMNFI+VO4_SDOC	"})
aAdd( aSIX_SDoc , {"VOO5","VOO_FILIAL+VOO_NUMNFI+VOO_SDOC	"})
aAdd( aSIX_SDoc , {"VS19","VS1_FILIAL+VS1_NUMNFI+VS1_SDOC	"})
aAdd( aSIX_SDoc , {"VSC7","VSC_FILIAL+VSC_NUMNFI+VSC_SDOC	"})
aAdd( aSIX_SDoc , {"VV06","VV0_FILIAL+VV0_NUMNFI+VV0_SDOC	"})
aAdd( aSIX_SDoc , {"VVD5","VVD_FILIAL+VVD_CODFOR+VVD_LOJA+VVD_SDOC+VVD_NUMNFI	"})
aAdd( aSIX_SDoc , {"VVF7","VVF_FILIAL+VVF_CODFOR+VVF_LOJA+VVF_NUMNFI+VVF_SDOC	"})
aAdd( aSIX_SDoc , {"VVF8","VVF_FILIAL+VVF_NUMNFI+VVF_SDOC+VVF_CODFOR+VVF_LOJA	"})

Return {aSIX_Serie,aSIX_SDoc}

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSerieSDoc()
Retorna Retorna a posição do Array aCamposSer de acordo com campos informado
@Param
cCampo   -> Campo a ser pesquisado

@Return ( nPos )

@author Alexandre Lemes
@since  21/10/2015
@version 1.0  

/*/
//------------------------------------------------------------------- 
Function GetSerieSDoc(cCampo as Character)
Local nPos as Numeric 
//- Executa a chamada para garantir a carga do Array contendo 
//- todos os campos e Alias do Projeto
SerieToSDoc() 

//- Busca a posição do Campo, não existindo zera o mesmo
If (nPos := oCposSerie[AllTrim(cCampo)]) == nil 
	nPos := 0
EndIf 


Return nPos
