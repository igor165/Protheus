#Include 'Protheus.ch'

Static lAutoSt := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} RUP_PLS
Fun��o de compatibiliza��o do release incremental. Esta fun��o � relativa ao m�dulo plano de sa�de. 
 
@param  cVersion		- Vers�o do Protheus
@param  cMode			- Modo de execu��o. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart		- Release de partida  Ex.: 002  
@param  cRelFinish	- Release de chegada Ex: 005 
@param  cLocaliz		- Localiza��o (pa�s). Ex: BRA 
 
@Author Karine Riquena Limp 
@since 03/06/2015
@version P12
/*/
//-------------------------------------------------------------------
function RUP_PLS(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

local aCampos := {}
local aPos    := {}
Local lPls	:= GetNewPar("MV_PLSATIV",.F.)

If !lPls .OR. lAutoSt
	Return()
Endif

plsLoadTab( "B90" )	

//Sinalizador Respons�vel por enviar o e-mail de cria��o de senha para primeiro acesso.
plsSinaliz("ENVIO DE SENHA", "Prezado Cliente, Seu cadastro foi realizado e foi gerado automaticamente um Usu�rio e Senha.", "PLSA260", "1")

//Sinalizadores respons�veis pelo envio de e-mail na altera��o dos status. 
plsSinaliz("INFORMATIVO SOLICITA��O PENDENTE INFORM.", "Caro Benefici�rio, � necess�rio complementar as informa��es para a sua solicita��o.", "PLSA001A", "1.B", plsRetCmp("1"), plsRetPos("1"))
plsSinaliz("INFORMATIVO SOLICITA��O REPROVADA/INDEF.", "Caro Benefici�rio, a sua solicita��o foi Reprovada/Indeferida.", "PLSA001A", "1.4", plsRetCmp("2"))
plsSinaliz("INFORMATIVO SOLICITA��O APROVADA", 		   "Caro Benefici�rio, a sua solicita��o foi Aprovada.", "PLSA001A", "1.3", plsRetCmp("3"))
plsSinaliz("INFORMATIVO SOLICITA��O PARC. APROVADA",    "Caro Benefici�rio, a sua solicita��o foi Parcialmente Aprovada.", "PLSA001A", "1.C", plsRetCmp("4"))

//Importante: Para cada novo sinalizador � necess�rio incrementar o indicador para carregar os campos na fun��o plsRetCmp 
plsSinaliz("VISITA INSTITUCIONAL - SOLICITA��O",;//BOJ_ASSUNT
                                             "",;//BOJ_TEXTO
                                      "PLSA817",;//BOJ_ROTINA
                                            "0",;//BOJ_VERSAO
                                 plsRetCmp("5"),,;//Campos da B1U
                       "\workflow\WF000004.htm",;//BOJ_DIRECT
                                            "3")//BOJ_OPERAC

plsSinaliz("VISITA INSTITUCIONAL - APROVA��O",;//BOJ_ASSUNT
                                             "",;//BOJ_TEXTO
                                      "PLSA817",;//BOJ_ROTINA
                                            "01",;//BOJ_VERSAO
                                 plsRetCmp("6"),,;//Campos da B1U
                       "\workflow\WF000005.htm",;//BOJ_DIRECT
                                            "4")//BOJ_OPERAC

plsSinaliz("VISITA INSTITUCIONAL - REPROVA��O",;//BOJ_ASSUNT
                                             "",;//BOJ_TEXTO
                                      "PLSA817",;//BOJ_ROTINA
                                            "03",;//BOJ_VERSAO
                                 plsRetCmp("7"),,;//Campos da B1U
                       "\workflow\WF000006.htm",;//BOJ_DIRECT
                                            "4")//BOJ_OPERAC
                                            
plsSinaliz("SOLICITA��O DE INCLUS�O DE BENEFICI�RIOS",;//BOJ_ASSUNT
                                             "",;//BOJ_TEXTO
                                      "PLSA977AB",;//BOJ_ROTINA
                                            "01",;//BOJ_VERSAO
                                 plsRetCmp("8"),;//Campos da B1U
                       			  plsRetPos("8"),;//Campos da B1P
               			  						"",;//BOJ_DIRECT
                                            "4")//BOJ_OPERAC

plsSinaliz("AGRADECIMENTO A INDICA��O DE PRESTADOR",;//BOJ_ASSUNT
                                             "",;//BOJ_TEXTO
                                      "PLSA809",;//BOJ_ROTINA
                                            "0",;//BOJ_VERSAO
                                 plsRetCmp("9"),; //Campos da B1U
                                 plsRetPos("2"),;//Campos da B1P
                       "\workflow\WF000007.htm",;//BOJ_DIRECT
                                            "3")//BOJ_OPERAC                                            
//Sinalizador Respons�vel por enviar o e-mail com altera��o de senha.
plsSinaliz("ALTERA��O DE SENHA - CALLCENTER",; 
           "",;
           "PLSXTMK",;
           "001",;
           plsRetCmp("10"))                                            
//Sinalizador Respons�vel por enviar o e-mail com o relat�rio RDA.
plsSinaliz("RELATORIO RDA - CALLCENTER",; 
           "Prezado, foi enviado no anexo o relat�rio de RDA conforme solicitado.",;
           "PLSIMPRDA",;
           "001") 
           
//Sinalizador Respons�vel por enviar o e-mail com o relat�rio de RDA's suspensas.
plsSinaliz("RELATORIO RDA SUSPENSAS",; 
           "Em anexo, um arquivo .csv com as RDA suspensas",;
           "PLSR957",;
           "001") 

plsSinaliz("GERA��O DE NOVA GUIA PELO AUDITOR.",;//BOJ_ASSUNT
													"",;//BOJ_TEXTO
											"PLSA790V",;//BOJ_ROTINA
                                            "01",;//BOJ_VERSAO
                               	  plsRetCmp("11"),;//Campos da B1U
                       		   	   plsRetPos("7"),;			   
                       						   	"",;//BOJ_DIRECT
                                            	"3")//BOJ_OPERAC    
                                           	
plsMessage("STR0001", "Ol� %NOMUSR%. Esse � o seu primeiro acesso, seja Bem-Vindo! <BR >� necess�rio que altere a senha para prosseguir.  <BR> A senha deve ter 8 digitos e pelo menos um caracter especial ou n�mero.", "3", "Primeiro Acesso", "")
plsMessage("STR0002", "Login criado com sucesso! Verifique seu e-mail as informa��es para acesso!", "0", "Login criado com sucesso", "PLSABPRAC")
plsMessage("STR0003", "N�o foi poss�vel criar o usu�rio!", "0", "Nao foi possivel criar o user", "PLSABPRAC")
plsMessage("STR0004", "Benefici�rio j� existe, caso tenha esquecido a senha, solicite uma nova no link 'Esqueceu sua senha'!", "0", "Esqueceu sua senha", "PLSABPRAC")
plsMessage("STR0005", "N�o existe e-mail cadastrado ou est� incorreto no cadastro de Vidas!", "0", "Nao existe e-mail cadastrado", "PLSABPRAC")
plsMessage("STR0006", "N�o foi encontrado o CPF no cadastro de Vidas!", "0", "Nao foi encontrado o CPF", "PLSABPRAC")
plsMessage("STR0007", "Texto livre para documenta��o necess�ria", "0", "Texto livre documenta��o", "PLSR9561")
plsMessage("STR0008", "Texto livre para documenta��o necess�ria", "0", "Texto livre documenta��o", "PLSR9561")
plsMessage("STR0009", "Texto livre", "0", "Texto livre 1", "PLSR9562")
plsMessage("STR0010", "Texto livre", "0", "Texto livre 2", "PLSR9562")
plsMessage("STR0011", "Texto livre", "0", "Texto livre 3", "PLSR9562")
plsMessage("STR0012", "Texto livre", "0", "Texto livre 4", "PLSR9562")
plsMessage("STR0013", "Texto livre", "0", "Texto livre 5", "PLSR9562")
plsMessage("STR0014", "Baixe o plugin para visualiza��o do relat�rio em:", "3", "Plugin de visualiza��o relat�rios", "PPLRELGEN")
plsMessage("STR0015", "Nesta se��o coloque as informa��es b�sicas do comprovante fiscal", "3", "Tour reembolso passo 1", "PPLREEMB")
plsMessage("STR0016", "Nesta se��o, dever�o ser informados as despesas descritas no cupom fiscal", "3", "Tour reembolso passo 2", "PPLREEMB")
plsMessage("STR0017", "Aqui dever�o ser anexados os comprovantes fiscais e receitas de medicamentos se houver", "3", "Tour reembolso passo 3", "PPLREEMB")
plsMessage("STR0018", "Clique nesse bot�o para finalizar a digita��o do comprovante", "3", "Tour reembolso passo 4", "PPLREEMB")
plsMessage("STR0019", "<strong>Endere�o:</strong> Av. Bela Cintra, n� 986 - 9� andar - Edif�cio Rachid Saliba - Bairro Jardim Paulista -S�o Paulo-S�o Paulo-CEP: 01415-000 <br><strong>Disque ANS: </strong>0800 701 9656<br><strong>Site: </strong>www.ans.gov.br", "3", "Informa��es ANS", "PPLDADPES")
plsMessage("STR0020", "<strong>Endere�o:</strong> Av. , n�  - Bairro  - S�o Paulo-SP -CEP: 00000-000 <br><strong>Disque: </strong>0800 000 0000<br><strong>Site: </strong>www.operadora.org.br", "3", "Informa��es Operadora", "PPLDADPES")
plsMessage("STR0021", "relatorioprecoprestador", "2", "NOMEREL", "PLSATBPR")
plsMessage("STR0022", "Legenda das Unidades de Sa�de", "2", "TITULOLEGENDAUNI", "PLSATBPR")
plsMessage("STR0023", "RDA x Tabela de Pre�os (Itens)", "2", "BC6", "PLSATBPR")
plsMessage("STR0024", "Procedimentos Rede Atendimento", "2", "BC0", "PLSATBPR")
plsMessage("STR0025", "Procedimentos por Produtos", "2", "BE9", "PLSATBPR")
plsMessage("STR0026", "Empresa x Prest x Proc x Pagto", "2", "BMI", "PLSATBPR")
plsMessage("STR0027", "Pacotes Cabe�alho - RDA x Pacote", "2", "BLY", "PLSATBPR")
plsMessage("STR0028", "Procedimentos tabelas Gen�ricas", "2", "B23", "PLSATBPR")
plsMessage("STR0029", "Relat�rio de Tabela de Pre�os do Prestador", "2", "TITULOREL", "PLSATBPR")
plsMessage("STR0030", "Tabela Padr�o de Procedimentos e Itens", "2", "BR8", "PLSATBPR")


return

//-------------------------------------------------------------------
/*/{Protheus.doc} plsRetPos
Fun��o para Retornar os posicionamentos para grava��o dos sinalizadores
@author Roberto Vanderlei de Arruda
@since 23/09/2015
@version P12
/*/
//-------------------------------------------------------------------

static function plsRetPos(cTpSinalizador)

	local aPos := {}
	local cCodTit := getNewPar("MV_PLCDTIT", "T")
	if cTpSinalizador == "1"
		aadd(aPos, {'001', 'BBP', '1', 'XFILIAL("BBP")+BOW->BOW_MOTPAD'}) 	
	Elseif cTpSinalizador == "2"
		aadd(aPos, {'001', 'BA1', '2', 'XFILIAL("BA1")+B9Y->B9Y_CARTEI'}) 		
	elseif cTpSinalizador == "8"	
		aadd(aPos, {'001', 'BA1', '1', 'XFILIAL("BA1")+CCODFAM+"' + cCodTit + '"'})
	elseif cTpSinalizador == "7"	
		aadd(aPos, {'001', 'BAU', '1', 'XFILIAL("BAU")+B53->B53_CODRDA' })		
		aadd(aPos, {'002', 'BA1', '2', 'XFILIAL("BA1")+B53->B53_MATUSU' })
	elseif cTpSinalizador == "3"	
		aadd(aPos, {'001', 'BAU', '1', 'XFILIAL("BAU") + BAU->BAU_CODIGO'})		
	endif
	
	
return aPos
//-------------------------------------------------------------------
/*/{Protheus.doc} plsRetCmp
Fun��o para Retornar os campos para grava��o dos sinalizadores
@author Roberto Vanderlei de Arruda
@since 23/09/2015
@version P12
/*/
//-------------------------------------------------------------------

static function plsRetCmp(cTpSinalizador)

	local aCmpos := {}
	
	if cTpSinalizador $ "1,2,3,4" // Sinalizadores para envio de e-mail referente a altera��o de status da solicita��o.
	
		aadd(aCmpos, {"%TIPO_SOLICITACAO%", "CTIPOSOLICITACAO"})
		aadd(aCmpos, {"%PROTOC%", "CPROTOC"})
		aadd(aCmpos, {"%NOMBEN%", "CNOMBEN"})
		aadd(aCmpos, {"%ITENS%", "CITENS"})
			
		if cTpSinalizador = "1" //Sinalizador de Altera��o Status Protocolo (Pendente Informa��o Benefici�rio).
			aadd(aCmpos, {"%DATPAR%", "CDATPAR"})
			aadd(aCmpos, {"%MOTIV%", "CMOTIV"})
			aadd(aCmpos, {"%MOTPAD%", "CAPITAL(BBP->BBP_DESMOT)"})
			aadd(aCmpos, {"%OBS%", "BOW->BOW_MOTIND"})
		else
			if cTpSinalizador = "2" //Sinalizador de Indeferimento de solicita��o.
				aadd(aCmpos, {"%DATPAR%", "CDATPAR"})
				aadd(aCmpos, {"%MOTIV%", "CMOTIV"})
			else
				if cTpSinalizador $ "3,4" //Sinalizador de Deferimento da solicita��o e Sinalizador Deferimento Parcial da Solicita��o.
					aadd(aCmpos, {"%DTPROVPAGTO%", "CDTPROVPAGTO"})
					aadd(aCmpos, {"%VALTOT%", "CVALTOT"})
				endif					
			endif		
		endif
	Else
		Do Case
			Case cTpSinalizador == "5"
				//Adicionar os campos da B1U
				aadd(aCmpos, {"%B7K_CODVIS%", "B7K->B7K_CODVIS"})
				aadd(aCmpos, {"%B7K_DATSUG%", "B7K->B7K_DATSUG"})
				aadd(aCmpos, {"%B7K_HORSUG%", "B7K->B7K_HORSUG"})
				aadd(aCmpos, {"%B7K_CODRDA%", 'Posicione("BAU",1,xFilial("BAU")+B7K->B7K_CODRDA,"BAU_NOME")'})
			Case cTpSinalizador == "6"
				//Adicionar os campos da B1U
				aadd(aCmpos, {"%B7K_CODVIS%", "B7K->B7K_CODVIS"})
				aadd(aCmpos, {"%B7K_DATAGE%", "M->B7K_DATAGE"})
				aadd(aCmpos, {"%B7K_HORAGE%", "M->B7K_HORAGE"})
				aadd(aCmpos, {"%B7K_CODRDA%", 'POSICIONE("BAU",1,XFILIAL("BAU")+B7K->B7K_CODRDA,"BAU_NOME")'})					
			Case cTpSinalizador == "7"
				//Adicionar os campos da B1U
				aadd(aCmpos, {"%B7K_CODVIS%", "B7K->B7K_CODVIS"})
				aadd(aCmpos, {"%B7K_DATSUG%", "B7K->B7K_DATSUG"})
				aadd(aCmpos, {"%B7K_HORSUG%", "B7K->B7K_HORSUG"})
				aadd(aCmpos, {"%B7K_CODRDA%", 'POSICIONE("BAU",1,XFILIAL("BAU")+B7K->B7K_CODRDA,"BAU_NOME")'})
			Case cTpSinalizador == "8"
				//Adicionar os campos da B1U
				aadd(aCmpos, {"%TITULAR%", "BA1->BA1_NOMUSR"})
				aadd(aCmpos, {"%BENEFS%",  "PL97ABRETB()"})
				aadd(aCmpos, {"%PROTOC%",  "BBA->BBA_CODSEQ"})
			Case cTpSinalizador == "9"
				aadd(aCmpos, {"%BENEF%"    , "BA1->BA1_NOMUSR"})
				aadd(aCmpos, {"%PRESTADOR%", "B9Y->B9Y_NOME"})
				aadd(aCmpos, {"%PROTOCOLO%", "B9Y->B9Y_NROPRO"})
			Case cTpSinalizador == "10"
				aadd(aCmpos, {"%NOMUSR%"  , "BSW->BSW_NOMUSR"})
				aadd(aCmpos, {"%DATA%"    , "DATE()"})
				aadd(aCmpos, {"%HORA%"    , "TIME()"})
				aadd(aCmpos, {"%USER%"    , "BSW->BSW_LOGUSR"})
				aadd(aCmpos, {"%PASSWORD%", "CSENHATMK"})
			Case cTpSinalizador == "11"
				aadd(aCmpos, {"%GUIA_ANT%"  , "ASITUCB53[6]"})
				aadd(aCmpos, {"%GUIA_NEW%"  , "B53->B53_NUMGUI"})
				aadd(aCmpos, {"%ENDRDA%"    , "BAU->BAU_END"})
				aadd(aCmpos, {"%BAIR%"  		, "BAU->BAU_BAIRRO"})
				aadd(aCmpos, {"%NOMRDA%"  	, "BAU->BAU_NOME"})
				aadd(aCmpos, {"%MATRIC%"  	, "B53->B53_MATUSU"})
				aadd(aCmpos, {"%NOME%"  		, "BA1->BA1_NOMUSR"})
				aadd(aCmpos, {"%CPF%"  		, "BA1->BA1_CPFUSR"})
			Case cTpSinalizador == "12"
				aadd(aCmpos, {"%NOMRDA%"  	, "BAU->BAU_NOME"})
		EndCase
   Endif


return aCmpos

//-------------------------------------------------------------------
/*/{Protheus.doc} plsSinaliz
Fun��o para carregar os sinalizadores - BOJ
@author Roberto Vanderlei de Arruda
@since 17/08/2015
@version P12
aCampos Formato:
	{Nome_Variavel_Html, Nome_Campo}
/*/
//-------------------------------------------------------------------
static function plsSinaliz(cAssunto, cTexto, cRotina, cVersao, aCampos, aPos, cDirect,cOperacao) 

	local i
	local cCodSinalizador
	Default cVersao := ""
	default aCampos := {}
	default aPos 	  := {}
	default cDirect   := ""
	default cOperacao := ""
	
	dbSelectArea( "BOJ" )
	dbSelectArea( "B1U" )
	dbSelectArea( "B1P" )
	
	
	BOJ->(dbSetOrder(3)) //B90_FILIAL+B90_CHAVE
	
	if !(BOJ->(dbSeek(xFilial("BOJ") + cRotina + (Space(TamSx3("BOJ_ROTINA")[1] - len(cRotina)))  + cVersao + (Space(TamSx3("BOJ_VERSAO")[1] - len(cVersao) )))))
		Begin Transaction
		
			cCodSinalizador := GETSX8NUM("BOJ","BOJ_CODSIN")
			
	    	BOJ->(RecLock("BOJ", .T.))
	    	BOJ->BOJ_FILIAL := xFilial("BOJ")
	    	BOJ->BOJ_CODSIN := cCodSinalizador                                                                   
	    	BOJ->BOJ_ASSUNT := cAssunto
	    	BOJ->BOJ_TEXTO  := cTexto
	    	BOJ->BOJ_ROTINA := cRotina
	    	BOJ->BOJ_VERSAO := cVersao
	    	BOJ->BOJ_DIRECT := cDirect
	    	BOJ->BOJ_OPERAC := cOperacao
	    	
	       BOJ->(MsUnlock())
	       ConfirmSX8()
	        
	       for i := 1 to len(aCampos)
	    		B1U->(RecLock("B1U", .T.))
	    		B1U->B1U_FILIAL := xFilial("B1U")
	    		B1U->B1U_CODSIN := cCodSinalizador                                                                   
	    		B1U->B1U_CAMPO  := aCampos[i][1] 
	    		B1U->B1U_DADO   := aCampos[i][2]
	       	B1U->(MsUnlock())	       	
	       next

	      	for i := 1 to len(aPos)
	    		B1P->(RecLock("B1P", .T.))
	    		B1P->B1P_FILIAL := xFilial("B1P")
	    		B1P->B1P_CODSIN := cCodSinalizador                                                                   
	    		B1P->B1P_ORDEM  := aPos[i][1]  
	    		B1P->B1P_ALIAS  := aPos[i][2]
	    		B1P->B1P_INDICE := aPos[i][3]
	    		B1P->B1P_CHAVE  := aPos[i][4]
	       	B1P->(MsUnlock())	       	
	       next
	       
	    End Transaction
	endif
return

//-------------------------------------------------------------------
/*/{Protheus.doc} plsMessage
Fun��o para carregar as mensagens do portal - BMV
@author Roberto Vanderlei de Arruda	
@since 17/08/2015
@version P12
/*/
//-------------------------------------------------------------------
static function plsMessage(cCodMsg, cTextMsg, cTpPor, cDescri, cRotina)

	dbSelectArea( "BMV" )

	BMV->(dbSetOrder(1)) //B90_FILIAL+B90_CHAVE
	
	if !(BMV->(dbSeek(xFilial("BMV")+cCodMsg/*"STR0001"*/)))
		Begin Transaction
			//Mensgaem exibida ao realizar o primeiro acesso ao portal.
	    	BMV->(RecLock("BMV", .T.))
	    	BMV->BMV_FILIAL := xFilial("BMV")
	    	BMV->BMV_CODIGO := cCodMsg//"STR0001"    	                                                                   
	    	BMV->BMV_MSGPOR := cTextMsg//"Ol� %NOMUSR%. Esse � o seu primeiro acesso, seja Bem-Vindo! <BR >� necess�rio que altere a senha para prosseguir.  <BR> A senha deve ter 8 d�gitos e pelo menos um caracter especial ou n�mero."
	    	
	    	BMV->BMV_TPPOR := cTpPor//"3"
	    	BMV->BMV_DESCRI := cDescri//"Primeiro Acesso"
	    	BMV->BMV_ROTINA := cRotina
	       BMV->(MsUnlock())
	    End Transaction
	endif
    
return


//-------------------------------------------------------------------
/*/{Protheus.doc} plsLoadTab
Fun��o para fazer o load das tabelas do pls
@author Karine Riquena Limp
@since 03/06/2015
@version P12
/*/
//-------------------------------------------------------------------
static function plsLoadTab(cAlias)

do case
	case cAlias == "B90"
		plLoadGen()
endCase	

return
//-------------------------------------------------------------------
/*/{Protheus.doc} plLoadGen
Fun��o para fazer o load das tabelas B90 B91 e B7C que compoem o layout web generico
@author Karine Riquena Limp
@since 03/06/2015
@version P12
/*/
//-------------------------------------------------------------------
static function plLoadGen()
local lB90 := ChkFile("B90")
local lB91 := ChkFile("B91")
local lB7C := ChkFile("B7C")
local lB2C := ChkFile("B2C")

if lB90 .and. lB91 .and. lB7C .and. lB2C
 	
 	B90->(dbSelectArea("B90"))
	B90->(dbSetOrder(2)) //B90_FILIAL+B90_CHAVE
	
	if !(B90->(dbSeek(xFilial("B90")+"PLSALTRDAF")))
		PlsMnuPor("000008", "Principal", "Dados Cadastrais", "PLSXFUN", "javascript:callAltCad();", 12)
	endIf

	if !(B90->(dbSeek(xFilial("B90")+"PLSALTRDAJ")))
		PlsMnuPor("000008", "Principal", "Dados Cadastrais", "PLSXFUN", "javascript:callAltCad();", 12)
	endIf
	
	if !(B90->(dbSeek(xFilial("B90")+"PLSINDPRE")))
		PlsMnuPor("000010", "Principal", "Indique um prestador", "PLSXFUN", "W_PPLCADGEN.APW?cChave=PLSINDPRE", 3)
	endIf
	
else
	Conout("N�o foi poss�vel fazer a cria��o das tabelas B90, B7C e B91")
endIf

//Portal Prestador
PlsMnuPor("000008", "Principal", "Corpo Cl�nico", "PLSXFUN", "W_PPLCORPOCLI.APW", 15)
PlsMnuPor("000008", "Principal", "Visita Institucional", "PLSXFUN","W_PPLCADGEN.APW?cChave=PLSA817", 16)
PlsMnuPor("000008", "Principal", "Digita��o de Guias", "PLSXFUN", "W_PPLDIGGUIP.APW", 18)
PlsMnuPor("000008", "Principal", "Acredita��es", "PLSXFUN", "W_PPLSACR.APW", 19)
PlsMnuPor("000008", "Principal", "Guia de Prorroga��o", "PLSXFUN", "W_PPLPRORINT.APW", 22)
plsAltMnu("000008", "W_PPLCHADTIN.APW", "Data da Interna��o/Data da Alta")
PlsMnuPor("000008", "Principal", "Recurso de Glosa", "PLSXFUN", "W_PPLRECGLO.APW", 23)

//Portal Benefici�rio
PlsMnuPor("000010", "Principal", "Estat�stica Partos", "PLSXFUN", "W_PPLCHAMNC.APW", 3)
PlsMnuPor("000010", "Principal", "Consulta Status Autoriza��o", "PLSXFUN", "W_PPLCAUTZ.APW", 4)
PlsMnuPor("000010", "Principal", "Consultar Visitas aos Prestadores", "PLSXFUN", "W_PLSMAPCAPT.APW", 5)
PlsMnuPor("000010", "Principal", "Imprimir Carteirinha", "PLSXFUN", "W_PPLCHAMCB.APW", 6)
PlsMnuPor("000010", "Principal", "Consultar Uso Constante", "PLSXFUN", "W_PPLCONUSOC.APW", 7)
PlsMnuPor("000010", "Principal", "Dados Pessoais", "PLSXFUN", "W_PPLDADPES.APW", 8)

//MENUS INCLUSAO/MANUT DE BENEFICIARIOS
PlsMnuPor("000010", "Principal", "Solic./ Manuten�ao Benef", "PLSXFUN", "W_PPLSOLMBEN.APW", 9)
PlsMnuPor("000010", "Principal", "Consulta Solicita�ao Benefici�rios", "PLSXFUN", "W_PPLCONBEN.APW", 10)
PlsMnuPor("000010", "Principal", "Solicitacao de Opcional", "PLSXFUN", "W_PPLSOLOP.APW", 11)
PlsMnuPor("000010", "Principal", "Solicita��o de Cancelamento de Plano", "PLSXFUN", "W_PPLCANPLA.APW", 12)

PlsMnuPor("000010", "Principal", "Solicitar Autoriza��o", "PLSXFUN", "W_PPLUPLOADG.APW", 16)
PlsMnuPor("000010", "Principal", "Consulta Protocolo Autorizac�o", "PLSXFUN", "W_PPLPROTPAG.APW", 17)


PlsMnuPor("000010", "Relatorios", "Extrato de Reajuste", "MTSUPPLIERQUOTE", "W_PPLREAJ.APW", 5)
PlsMnuPor("000010", "Relatorios", "Declara��o Anual de Quita��o de D�bitos", "PLSRELT", "W_PPLRDEB.APW", 6)
PlsMnuPor("000010", "Relatorios", "Cancelamento de Plano", "PLSRELT", "W_PPLRELCPL.APW", 7)

PlsMnuPor("000010",,"Reembolso",,, 1, .T.) //cadastro de menu pai //Filhos do submenu reembolso colocar sempre abaixo do cadastro de menu pai
PlsMnuPor("000010", "Reembolso", "Cadastro Medicamento Uso Constante", "PLSXFUN", "W_PPLPROREC.APW", 5)
PlsMnuPor("000010", "Reembolso", "Solicita��o de reembolso", "PLSXFUN", "W_PPLREEMB.APW", 6)
PlsMnuPor("000010", "Reembolso", "Consulta Reembolso", "PLSXFUN", "W_PPLCONREE.APW", 7)


//Relat�rio de utiliza��o com co-participa��o e reembolso Anal�tico
PlsMnuPor("000010",,"Relatorios",,, 1, .T.)
PlsMnuPor("000010", "Relatorios", "Utiliza��o/ Co-Participa��o", "PLSRELT", "W_PPLCRREUTX.APW", 7)
PlsMnuPor("000010", "Relatorios", "Reembolso Anal�tico", "PLSRELT", "W_PPLCRRBAN.APW", 8)
PlsMnuPor("000010", "Relatorios", "Extrato Financeiro", "PLSRELT", "W_PPLEXFINA.APW", 13)


return


//-------------------------------------------------------------------
/*/{Protheus.doc} plsAltMnu
Altera��o menu do portal PLS 
@author Roberto Vanderlei de Arruda
@since 01/09/2015
@version P12
/*/
static function plsAltMnu(cCodMnu, cRotina, cTitulo)
	AI8->(dbSetOrder(4))
	If AI8->(dbSeek(xFilial("AI8")+cCodMnu+ cRotina + (Space(TamSx3("AI8_ROTINA")[1] - len(cRotina)))))
		AI8->(RecLock("AI8",.F.))
			AI8->AI8_TEXTO  :=  cTitulo
			AI8->AI8_TEXTOE :=  cTitulo
			AI8->AI8_TEXTOS :=  cTitulo
		AI8->(msUnLock())
	endif
return

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsMnuPor
Atualizacao do menu do portal PLS 
@author Karine Riquena Limp
@since 03/06/2015
@version P12
/*/
static function plsMnuPor(cCodPor, cTextoPai, cTitulo, cWebServ, cRotina, nOrdem, lMenuPai)
local cCodPai  := ""
local lCriaMnu := .T.

default cTextoPai := ""
default cTitulo := ""
default cWebServ := ""
default cRotina := ""
default nOrdem := 1 
default lMenuPai := .F.
dbSelectArea("AI8")
	AI8->(dbSetOrder(1))

	If AI8->(dbSeek(xFilial("AI8")+cCodPor))
		While !AI8->(Eof()) 
		
			If !lMenuPai .AND. Empty(cCodPai) .And. UPPER(AllTrim(AI8->AI8_TEXTO)) == UPPER(cTextoPai)
				cCodPai := AI8->AI8_CODMNU
			EndIf	

			If UPPER(AllTrim(AI8->AI8_TEXTO)) == UPPER(AllTrim(cTitulo))
				lCriaMnu := .F.
				Exit
			EndIf

			AI8->(dbSkip())
		EndDo
	EndIf

	If lCriaMnu
		if !lMenuPai                                  
			AI8->(dbGoBottom())
			cCodMnu := GETSXENUM("AI8","AI8_CODMNU")
			AI8->(RecLock("AI8",.T.))
			AI8->AI8_FILIAL := xFilial("AI8")
			AI8->AI8_TEXTO  := cTitulo
			AI8->AI8_TEXTOE := cTitulo
			AI8->AI8_TEXTOS := cTitulo
			AI8->AI8_WEBSRV := cWebServ
			AI8->AI8_ROTINA := cRotina
			AI8->AI8_ORDEM  := nOrdem
			AI8->AI8_INIAPV := 0
			AI8->AI8_APRVLV := 0
			AI8->AI8_CODMNU := cCodMnu
			AI8->AI8_PORTAL := cCodPor
			AI8->AI8_CODPAI := cCodPai
			AI8->(msUnLock())
			AI8->(ConfirmSx8())
		else
		
			AI8->(dbGoBottom())
			cCodMnu := GETSXENUM("AI8","AI8_CODMNU")
			AI8->(RecLock("AI8",.T.))
			AI8->AI8_FILIAL := xFilial("AI8")
			AI8->AI8_PORTAL := cCodPor
			AI8->AI8_CODMNU := cCodMnu
			AI8->AI8_TEXTO  := cTitulo
			AI8->AI8_TEXTOE := cTitulo
			AI8->AI8_TEXTOS := cTitulo
			AI8->AI8_ORDEM  := nOrdem
			AI8->AI8_INIAPV := 0
			AI8->AI8_APRVLV := 0	
			AI8->(msUnLock())
			AI8->(ConfirmSx8())
		endIf

	endif

return

//usada pra mudar o valor da vari�vel static para automa��o
function PLRrupSt(lValor)
lAutoSt := lValor
return
