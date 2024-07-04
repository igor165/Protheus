#INCLUDE "PRR050.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PRR050   ³ Autor ³ Tatiana L Campos      ³ Data ³ 21/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relatorio de Resultados                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao de pesquisa e resultado - GPR                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PRR050()

Local oReport
Local aArea := GetArea()

If FindFunction("TRepInUse") .OR. TRepInUse()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                          ³
	//³ Mv_Par01           // De  Pesquisa                            ³
	//³ Mv_Par02           // Ate Pesquisa      					  ³ 
	//³ Mv_Par03           // Analitico/Sintetico	A/S				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Pergunte("PRR050",.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oReport := PRR050RptDef()
	oReport:PrintDialog()

EndIf

RestArea( aArea )
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRR050RptDef ºAutor  ³Tatiana L Campos    º Data ³  10/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para informar as celulas que serao utilizadas no rela-  º±±
±±º          ³latorio                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PRR050                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ºManutencao Efetuada                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³        º      º                                               º±±
±±º          ³        º      º                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PRR050RptDef()
Local oReport						// Objeto do relatorio
Local oSection1						// Objeto da secao 1
Local oSection2						// Objeto da secao 2
Local oSection3						// Objeto da secao 3
Local cAlias1	:= GetNextAlias()	// Pega o proximo Alias Disponivel


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera a tela com os dados para a confirmacao da geracao do relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//"Emissao de Resultados. "
// "Este programa ira emitir uma relacao de Resultados." 
DEFINE REPORT oReport NAME "PRR050" TITLE STR0001 PARAMETER "PRR050" ACTION {|oReport| PRR050PrtRpt(oReport,cAlias1)} DESCRIPTION STR0002


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define a secao1 do relatorio, informando que o arquivo principal utlizado eh o SKS e o complementar o SKT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SECTION oSection1 OF oReport TITLE STR0002 TABLES "SKT","SKS","SKC","SKU","SKP"	 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define as celulas que irao aparecer na secao1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Pesquisa
DEFINE CELL NAME "KT_CODPESQ"	OF oSection1 ALIAS "SKT" 								//Codigo da pesquisa
DEFINE CELL NAME "KC_DESC"		OF oSection1 ALIAS "SKC" TITLE "Descrição da pesquisa" //Nome da pesquisa
DEFINE CELL NAME "KC_PUBLICO"	OF oSection1 ALIAS "SKC" 							   //Publico alvo    

//Questionario
DEFINE CELL NAME "KU_CODQST"	OF oSection1 ALIAS "SKU" //Codigo do questionario
DEFINE CELL NAME "KP_DESC"	 	OF oSection1 ALIAS "SKP" //Descricao do questionario (KC_CODPESQ)

//Respondente
DEFINE CELL NAME "KT_CODRESP"	OF oSection1 ALIAS "SKT" TITLE "Respondente(s)"		//Codigo do respondente           
DEFINE CELL NAME "KS_DATFIM"	OF oSection1 ALIAS "SKS" TITLE "Data da resposta"	//Data da resposta               

oSection1:SetLineBreak()		// Estilo de linha

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define a secao2 (que sera filha da secao1)  e o arquivo principal utilizado na secao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE SECTION oSection2 OF oSection1 TITLE STR0002 TABLES "SKU","SKG","SKH","SYP"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define as celulas que irao aparecer na secao2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Questao - Tipo de questao   
DEFINE CELL NAME "KU_CODQUES"	OF oSection2 ALIAS "SKU" SIZE 50 TITLE "Código da questão"  	//codigo da questao  
DEFINE CELL NAME "KG_DESC"		OF oSection2 ALIAS "SKG" SIZE 35 TITLE "Questão"   				//descricao da questao
DEFINE CELL NAME "KG_TIPOQST"	OF oSection2 ALIAS "SKG"   										//1-multipla escolha; 2-unica escolha; 3-dissertativa                

//complemento - KG_CODCOMP
DEFINE CELL NAME "YP_TEXTO"		OF oSection2 ALIAS "SYP" SIZE 100 TITLE "Complemento"	BLOCK {|| PRR050Busca(1, cAlias1, oSection2) }

//objetivo - KG_CODOBJ
DEFINE CELL NAME "YP_TEXTO"		OF oSection2 ALIAS "SYP" SIZE 100 TITLE "Objetivo"	BLOCK {|| PRR050Busca(2, cAlias1, oSection2) }

//	Respostas - KG_TIPOQST -> 1- multipla escolha       
DEFINE CELL NAME "KH_DESC"		OF oSection2 ALIAS "SKH" SIZE 50 							//Descricao da Alternativa 
DEFINE CELL NAME "KH_PONTO"		OF oSection2 ALIAS "SKH"  									//Pontuacao da alternativa	     	
DEFINE CELL NAME "KU_CODALT"	OF oSection2 ALIAS "SKU" SIZE 35 TITLE "Cod. Alternativa"	//Codigo da alternativa escolhida (KH_CODALT)		

//	Respostas - KG_TIPQST -> 2- unica escolha
DEFINE CELL NAME "KI_DESC"		OF oSection2 ALIAS "SKI" SIZE 50	//Descricao da coluna/linha - KI_CODCOL
DEFINE CELL NAME "KU_CODCOL" 	OF oSection2 ALIAS "SKU" SIZE 35	//Codigo da alternativa escolhida   	

//	Respostas - KG_TIPOQST -> 3 - dissertativa               
DEFINE CELL NAME "YP_TEXTO"		OF oSection2 ALIAS "SYP" SIZE 100 TITLE "Resposta"	BLOCK {|| PRR050Busca(3, cAlias1, oSection2) }	

oSection2:SetLineStyle()			// Estilo de linha

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define a secao3³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE SECTION oSection3 OF oSection2 TITLE STR0003 TABLES "SKU","SKT","SKC","SKG","SKP"	// "Emissao de Resultados"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define as celulas que irao aparecer na secao3³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE CELL NAME "KT_CODPESQ"	OF oSection3 ALIAS "SKT" TITLE "Código da pesquisa"			//Codigo da pesquisa     
DEFINE CELL NAME "KC_DESC"		OF oSection3 ALIAS "SKC" TITLE "Nome da pesquisa"			//Nome da pesquisa
DEFINE CELL NAME "KU_CODQST"	OF oSection3 ALIAS "SKU" TITLE "Código do questionário"		//Codigo do questionario
DEFINE CELL NAME "KP_DESC"	 	OF oSection3 ALIAS "SKP" TITLE "Nome do questionário"		//Descricao do questionario (KC_CODPESQ)
DEFINE CELL NAME "KU_CODQUES"	OF oSection3 ALIAS "SKU" TITLE "Código da questão"  		//codigo da questao  
DEFINE CELL NAME "KG_DESC"		OF oSection3 ALIAS "SKG" TITLE "Enunciado da questão"		//descricao da questao
DEFINE COLLECTION OF oSection3 FUNCTION COUNT FORMULA oSection2:Cell("KH_DESC") CONTENT oSection2:Cell("KU_CODALT") TITLE "Total de alternativas"

oSection3:SetLineStyle()		// Estilo de linha

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRR050PrtRptºAutor  ³Tatiana L Campos    º Data ³  10/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para impressao do relatorio personalizavel             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PRR050                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PRR050PrtRpt( oReport,cAlias1)
Local oSection1 := oReport:Section(1)							// Define a secao 1 do relatorio
Local oSection2 := oReport:Section(1):Section(1)				// Define que a secao 2 serah filha da secao 1
Local oSection3 := oReport:Section(1):Section(1):Section(1)	// Define que a secao 3 serah filha da secao 1
Local cFiltro	:= ""											// Variavel utilizada para o filtro

//Controla as sessoes impressas para analitico/sintetico
IF ( mv_par03 == 2)  
	oSection1:Hide()	
	oSection2:Hide()	
	oSection3:Enable()
	Else	
	oSection1:Show()
	oSection2:Show()
	oSection3:Disable()
Endif

#IFDEF TOP
	DbSelectArea("SKT")
	DbSetOrder(1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros do tipo Range em expressao SQL para ser utilizada na query ³
	//³Exemplo Word, nao intervalos pre definidos (mais utilizado pelo RH - Ferias)     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	MakeSqlExpr("PRR050")
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa a secao 1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN REPORT QUERY oSection1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query da secao 1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BeginSql alias cAlias1
	
		SELECT	KS_CODPESQ,	KS_CODRESP,
				KT_CODPESQ, KT_CODRESP,	KT_CODQUES,	KT_CODQST,
				KU_CODPESQ,	KU_CODRESP,	KU_CODQUES,	KU_CODQST,	KU_CODALT,	KU_CODCOL, KU_CODDISS,	
				KC_DESC,	KC_CODPQ,	KC_PUBLICO,	KC_DTDE,	KC_DTATE,				 				
				KP_DESC,	KP_CODQUE,	
				KG_CODQST,	KG_DESC,	KG_TIPOQST,	KG_CODCOMP,	KG_CODOBJ
				
		FROM %table:SKS% SKS,%table:SKT% SKT,%table:SKU% SKU,%table:SKC% SKC,%table:SKP% SKP,
			%table:SKG% SKG
			 
		WHERE	KT_FILIAL	=	%xfilial:SKT%	AND	                                
				KT_CODPESQ	>=	%exp:mv_par01%	AND
				KT_CODPESQ	<=	%exp:mv_par02%	AND				
				KT_CODPESQ	=	KS_CODPESQ		AND				
				KS_FILIAL	=	%xfilial:SKS%	AND	
				KS_CODRESP	=	KT_CODRESP		AND
				KU_FILIAL	=	%xfilial:SKU%	AND	
				KU_CODRESP	=	KT_CODRESP		AND	
				KU_CODPESQ	=	KT_CODPESQ		AND	
				KC_FILIAL	=	%xfilial:SKC%	AND 
				KC_CODPQ	=	KU_CODPESQ		AND	
				KP_FILIAL	=	%xfilial:SKP%	AND
				KP_CODQUE	=	KU_CODQST		AND	
				KP_CODQUE	=	KT_CODQST		AND				
				KG_FILIAL	=	%xfilial:SKG%	AND	
				KG_CODQST	=	KU_CODQUES	    AND				
				SKS.%notDel%	AND 
				SKT.%notDel%	AND
				SKU.%notDel%	AND
				SKC.%notDel%	AND
				SKP.%notDel%	AND	  
				SKG.%notDel%		     
            ORDER BY %Order:SKT%
	EndSql
                                                                           
	END	REPORT QUERY oSection1
                                                             

	oSection2:SetParentQuery()
	oSection2:SetParentFilter({|cParam| (cAlias1)->KU_CODPESQ+(cAlias1)->KU_CODQST == cParam},{|| (cAlias1)->KT_CODPESQ+(cAlias1)->KT_CODQST })

	oSection3:SetParentQuery()
	oSection3:SetParentFilter({|cParam| (cAlias1)->KU_CODPESQ+(cAlias1)->KU_CODQST+(cAlias1)->KU_CODQUES == cParam},{|| (cAlias1)->KU_CODPESQ+(cAlias1)->KU_CODQST+(cAlias1)->KU_CODQUES })

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona nas tabelas secundarias usadas na section2 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         

	TRPosition():New(oSection2,"SKH",1,{|| xFilial("SKH")+(cAlias1)->KU_CODQST+(cAlias1)->KU_CODALT })	
    TRPosition():New(oSection2,"SKI",1,{|| xFilial("SKI")+(cAlias1)->KU_CODQST+(cAlias1)->KU_CODCOL })
        	
#ENDIF	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a impressao dos dados, de acordo com o filtro ou query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:Print()

Return                                                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PRR050Busca ºAutor  ³Tatiana L Campos    º Data ³  31/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para impressao dos campos memo                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PRR050                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PRR050Busca(nCampo, cAlias1, oSection2)
Local cRet := ""
    
dbSelectArea("SYP")
dbSetOrder(1)

If nCampo == 1
	MsSeek(xFilial("SYP")+(cAlias1)->KG_CODCOMP)
	If (cAlias1)->KG_CODCOMP == SYP->YP_CHAVE
		cRet := SYP->YP_TEXTO
	Else
		cRet := " "
	EndIf

ElseIf nCampo == 2
	MsSeek(xFilial("SYP")+(cAlias1)->KG_CODOBJ)
	If (cAlias1)->KG_CODOBJ == SYP->YP_CHAVE
		cRet := SYP->YP_TEXTO
	Else
		cRet := " "
	EndIf
   
ElseIf nCampo == 3                             
	MsSeek(xFilial("SYP")+(cAlias1)->KU_CODDISS)
	If (cAlias1)->KU_CODDISS == SYP->YP_CHAVE 
		cRet := SYP->YP_TEXTO
	Else
		oSection2:Cell("YP_TEXTO"):Disable()
 	EndIf

EndIf

Return cRet