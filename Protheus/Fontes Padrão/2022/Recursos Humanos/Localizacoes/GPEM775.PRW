#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "GPEM775.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±                       
±±³Fun‡…o    ³ GPEM775  ³ Autor ³ Rogerio Vaz Melonio   ³ Data ³ 22/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao de arquivo texto do Quadro de Pessoal              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcos Kato ³22/10/08³      ³Insercao do Cod. Assoc. Pratonal 1,2 e 3 e³±±
±±³            ³        ³      ³o Ano de Constituicao da Empresa no Arq.  ³±±
±±³Marcos Kato ³19/11/08³      ³Substituicao RGP_HRSEMAN para RA_HRSEMAN  ³±±
±±³            ³        ³      ³porque nao foi encontrado o campo no atusx³±±
±±³Marcos Kato ³28/11/08³      ³Tratamento para o campo M0_NIRE.		  ³±±
±±³Tiago Malta ³07/01/10³00280/³ Alterado o conteudo da variavel cFilDe e ³±±
±±|            |        |  2010| cFilAte para space(FWGETTAMFILIAL).	  ³±±
±±³ Alex       ³22/12/10³29463/³ Atender Nova Interface Totvs 11.5 utili- ³±±
±±³            ³        ³  2010³ zando a funcao MsAdvSize.                ³±±
±±º------------³--------³------³ versao 11.5------------------------------º±±
±±ºEmerson     ³30/06/11³013705³Atender a Nova Interface Totvs 11.5 utili-º±±
±±ºCampos      ³        ³ /2011³zando a funcao MsAdvSize( p/ flexibilidadeº±±
±±º            ³        ³      ³da tela de acordo com a resolucao).       º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function GPEM775()
Local nOpca 	:= 0
Local bBtnCalcule							//bloco do botão OK
Local bPergunte								//bloco para o pergunte
Local cSays			:= OemToAnsi(STR0002)	//"Este programa gera o arquivo texto do Quadro de Pessoal"
Local oDlg
Local oBtnCalcule
Local oBtnEnd
Local oBtnPergunte
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aButtons		:= {}
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }

Private cFilDe := cFilAte := Space(FWGETTAMFILIAL)
Private cTxtParam := ""
Private oAnoMes, oTxtParam, aParamQP
Private cAnoMes := Space(6)
Private cTipo:="",cMorada:="",cLocalidade:="",cCodPostal:="",cDescPostal:="",cCodEstab:="",cCodIRCT:=""
Private cPerg := Padr("GPEM775",10)
Pergunte(cPerg,.F.)
DEFINE FONT oFont1  NAME "Arial" SIZE 0,-13 BOLD
cTxtParam := OemToAnsi(Gpem775QbrPar(cPerg))
cBlkGet :=  "{ | u | If( PCount() == 0, cTxtParam,cTxtParam:= u ) }"
cBlKVld :=  "{|| .T. }"
cBlKWhen := "{|| .F. }"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize( , .T., 370)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0001 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL // "Geração do Quadro de Pessoal"
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Descricao da Janela                                                      ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
	@ aObjSize[1,1] , aObjSize[1,2] TO aObjSize[1,3],aObjSize[1,4] OF oDlg PIXEL  //@ 11,12 TO 100,245 OF oDlg PIXEL
	@ aObjSize[1,1]+15 , aObjSize[1,2]+5 SAY cSays Of oDlg Pixel  FONT oFont1 // "Este programa gera o arquivo texto do Quadro de Pessoal"
	@ aObjSize[1,1]+25 , aObjSize[1,2]+5 SAY STR0003 Of oDlg Pixel FONT oFont1 // "Parametros:"
	oTxtParam := TMultiGet():New(aObjSize[1,1]+40,aObjSize[1,2]+5,&cBlKGet,oDlg,(aObjSize[1,4]-aObjSize[1,2])-10,(aObjSize[1,3]-aObjSize[1,1])-50,,.F.,,,,.T.,,.F.,&(cBlkWhen),.F.,.F.,.F.,&(cBlkVld),,.F.,.F.,.T.)

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Funcoes em GpFiltro  - Blocos de Execucao dos filtros                    ³
	³ GpFiltro - Chama a janela principal do cadastro de filtros               ³
	³ GpFltAlsGet - Retorna a expressao para elaborar o filtro                 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	AADD(aButtons, {"LogOcorr" ,{ || GPM775Log() },STR0005,STR0005} )
	AADD(aButtons, {"Parametros" ,{ || Pergunte("GPEM775",.T.), cTxtParam := OemToAnsi(Gpem775QbrPar(cPerg)), oTxtParam:Refresh() },STR0003,STR0003} )
	
	bSet15		:= { || nOpca := 1, IF( GPM775Ok()( ),oDlg:End(), nOpca:=0 ) }
	bSet24		:= { || oDlg:End() }

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Filial de                                         ³
//³ mv_par02 - Filial Ate                                        ³
//³ mv_par03 - Ano/Mes Referencia                                ³
//³ mv_par04 - Nome do Arquivo                                   ³
//³ mv_par05 - Local do Arquivo                                  ³
//³ mv_par06 - Capital Social                                    ³
//³ mv_par07 - % Privado Nacional                                ³
//³ mv_par08 - % Estrangeiro                                     ³
//³ mv_par09 - % Publico                                         ³
//³ mv_par10 - Volume de Negocios                                ³
//³ mv_par11 - Nome de Contato                                   ³
//³ mv_par12 - Fone 1                                            ³
//³ mv_par13 - Fone 2                                            ³
//³ mv_par14 - Fax                                               ³
//³ mv_par15 - Email                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF nOpca == 1
	ProcGpe({|lEnd| f775GravaQP()})  // Chamada do Processamento
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GPM775GetFile ºAutor  ³Rogerio Melonio   º Data ³  07/08/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualizacao do Relatorio de Log de Processamento.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPM775GetFile()
Local cArq
mvRet := Alltrim(ReadVar())
cArq := Space(80)
cTipo := STR0015+".txt"+")   | *."+"txt"+"  " // "Arquivos de Quadro de Pessoal (*.txt)   | *.txt  "
cGetFile := cGetFile("",OemToAnsi(STR0016),0,,.F.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY) //"Selecione o Diretorio"
If Empty(cGetFile)
	Return(.F.)
Endif
&mvRet := cGetFile
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GPM775Log     ºAutor  ³Rogerio Melonio   º Data ³  07/08/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualizacao do Relatorio de Log de Processamento.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPM775Log()
cPathFile := ""
cExtRel := ".##R"
cPathFile := ( __RelDir + "GPEM775" + cExtRel )
If File(cPathFile)
	OurSpool( "GPEM775" )
	Ms_Flush()
Else
	MsgStop(STR0013) // "Não existe Log de Processamento para exibir"
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³f775LogTipo    ºAutor  ³Rogerio Vaz Melonio º Data ³04/09/08º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina p/ verificar se campos dos registros  estao corretosº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cria Log de Inconsistencia de registros conforme o tipo    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function f775LogTipo(cTipo,cMorada,cLocalidade,cCodPostal,cDescPostal,cCodEstab,cCodIRCT)
If cTipo == '00'
	/*/
	Registro de Contato					
	Nome(s) do Contato							A 			100		S 		Padr(mv_par11,100)
	Correio Eletrônico							A 			60		S 		Padr(mv_par15,60)
	/*/
	cTxtOco := ""
	cTxtOco += Iif(Empty(mv_par11),STR0019,"") 	// "Nome "
	cTxtOco += Iif(Empty(mv_par12),STR0020,"") 	// "Fone 1 "
	cTxtOco += Iif(Empty(mv_par15),STR0021,"") 	// "Email "
	If !Empty(cTxtOco)
		If aTotRegs[1] == 0
			cLog := STR0035 // "Inconsistências nas informações do Contato"
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[1] := len(aLog)
		EndIf	
		Aadd(aLog[aTotRegs[1]], cTxtOco ) 
	Endif
ElseIf cTipo == '10'
	/*/
	Registro da Empresa					
	Nº de Identificação Fiscal 					N 			9		S 		SM0->M0_CGC 
	Ano de Referência da Informação 			N 			4		S 		Substr(mv_par03,1,4)
	Nome da Empresa 							A 			60		S 		SM0->M0_NOMECOM
	Morada 										A 			40		S 		SM0->M0_ENDCOB e caso esteja vazio, SM0->M0_ENDENT
	Localidade 									A 			20		S 		SM0->M0_BAIRCOB, se estiver vazio, SM0->M0_BAIRENT
	Código Postal 								N 			7		S 		SM0->M0_CEPCOB, se estiver vazio, SM0->M0_CEPENT
	Código Postal (descritivo) 					A 			20		S 		fDesc("SCG",SM0->M0_CEPCOB,"CG_DESCEP") ou fDesc("SCG", SM0-> M0_CEPENT, "CG_DESCEP")
	Telefone 									N 			9		S 		SM0->M0_TEL
	Código da Atividade Principal da Empresa 	N 			5		S 		SM0->M0_CNAE 
	Código de Natureza Jurídica 				N 			2		S 		SM0->M0_NATJUR 
	Volume de negócios, ano anterior 			N 			12		S 		StrZero(mv_par10*100,12)
	/*/
	cTxtOco := ""
	cTxtOco += Iif(Empty(SM0->M0_CGC),STR0022,"") 		// "NIF "
	cTxtOco += Iif(Empty(mv_par03),STR0023,"") 			// "Ano/Mes de referencia "
	cTxtOco += Iif(Empty(SM0->M0_NOMECOM),STR0019,"") 	// "Nome "
	cTxtOco += Iif(Empty(cMorada),STR0024,"") 			// "Endereco "
	cTxtOco += Iif(Empty(cLocalidade),STR0025,"") 		// "Bairro "
	cTxtOco += Iif(Empty(cCodPostal),STR0026,"") 		// "Codigo Postal "
	cTxtOco += Iif(Empty(cDescPostal),STR0027,"") 		// "Descricao do Codigo Postal "
	cTxtOco += Iif(Empty(SM0->M0_TEL),STR0028,"") 		// "Telefone "
	cTxtOco += Iif(Empty(SM0->M0_CNAE),STR0029,"") 		// "Cod. Atividade "
	cTxtOco += Iif(Empty(SM0->M0_NATJUR),STR0030,"") 	// "Cod. Natureza Juridica "
	cTxtOco += Iif(Empty(mv_par10),STR0031,"") 			// "Volume de Negocios do ano anterior "
	If !Empty(cTxtOco)
		If aTotRegs[2] == 0
			cLog := STR0036 // "Inconsistencias no Cadastro da Empresa"
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[2] := len(aLog)
		EndIf	
		Aadd(aLog[aTotRegs[2]], cTxtOco ) 
	Endif
ElseIf cTipo == '20'
	/*/
	Registro do estabelecimento
	Nº do Estabelecimento 						N 			4		S 		RCO_NESTAB
	Nome do Estabelecimento 					A 			60		S 		RCO_NOME
	Morada 										A 			40		S 		RCO_END
	Localidade 									A 			20		S 		RCO_LOCAL
	Código Postal 								N 			7		S 		RCO_CEP
	Código Postal (descritivo) 					A 			20		S 		fDesc("SCG",RCO->RCO_CEP,"CG_DESCEP"))
	Telefone 									N 			9		S 		RCO_FONE
	Código de Distrito / Município / Freguesia 	N 			6		S 		RCO_BAIRRO
	Cód. Atividade Principal do Estabelecimento	N 			5		S 		RCO_ATIVID
	/*/
	cTxtOco := ""
	cTxtOco += Iif(Empty(RCO->RCO_NESTAB),STR0032,"") 	// "Numero do Estabelecimento "
	cTxtOco += Iif(Empty(RCO->RCO_NOME),STR0019,"") 	// "Nome "
	cTxtOco += Iif(Empty(RCO->RCO_END),STR0024,"") 		// "Endereco "
	cTxtOco += Iif(Empty(RCO->RCO_LOCAL),STR0025,"") 	// "Bairro "
	cTxtOco += Iif(Empty(RCO->RCO_CEP),STR0026,"") 		// "Codigo Postal "
	cTxtOco += Iif(Empty(cDescPostal),STR0027,"") 		// "Descricao do Codigo Postal "
	cTxtOco += Iif(Empty(RCO->RCO_FONE),STR0028,"") 	// "Telefone "
	cTxtOco += Iif(Empty(RCO->RCO_BAIRRO),STR0033,"") 	// "Código de Estado / Município / Bairro "
	cTxtOco += Iif(Empty(RCO->RCO_ATIVID),STR0029,"") 	// "Cod. Atividade "
	If !Empty(cTxtOco)
		If aTotRegs[3] == 0
			cLog := STR0037 // "Inconsistencias no Cadastro do Estabelecimento"
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[3] := len(aLog)
		EndIf	
		Aadd(aLog[aTotRegs[3]], Alltrim(RCO->RCO_NESTAB)+"-"+AllTrim(RCO->RCO_NOME)+":"+cTxtOco ) 
	Endif
ElseIf cTipo == '30'
	/*/
	Registro do estabelecimento/IRCT
	Nº do Estabelecimento 						N 			4		S 		RCO->RCO_NESTAB
	Código do IRCT 								N 			5		S 		SRA->RA_CODIRCT
	/*/
	cTxtOco := ""
	cTxtOco += Iif(Empty(cCodEstab),STR0032,"") 	// "Numero do Estabelecimento "
	cTxtOco += Iif(Empty(cCodIRCT),STR0034,"") 		// "Código do IRCT "
	If !Empty(cTxtOco) 
		If aTotRegs[4] == 0
			cLog := STR0038 // "Inconsistencias no Cadastro do Estabelecimento/IRCT"
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[4] := len(aLog)
		Endif
		Aadd(aLog[aTotRegs[4]], cCodEstab+"-"+cCodIRCT+":"+cTxtOco ) 
	EndIf	
ElseIf cTipo == '40'
	/*/
	cTipo == '40'
	Registro do Funcionario
	Descrição dos Campos			Conteúdo Obrigatório
	1. Tipo de Registro 			S 
	2 - Nº. do Estabelecimento 		S 
	3. Código do IRCT 				S 
	5. Nome do Trabalhador 			S 
	6.1 Data de Nascimento 			S 
	6.2 Data de Admissão 			S 
	7.1 Salario Base 				S 
	7.3 Valor de Horas extras		
	9.1 Horas Normais 				Obrigatório se 7.1 > 0
	9.2 Horas Extras				Obrigatório se 7.3 > 0
	10. Período Normal de Trabalho 	S 
	12. Cod. Categoria Profissional S 
	13. Cod. de Profissão 			S 
	14. Cod. de Habilitação 		S 
	15. Cod. de Nacionalidade 		S 
	17. Situação na Profissão 		S 
	18. Tipo de Contrato 			S 
	19. Regime de Duração do Trabalho 	S 
	20. Sexo 						S 
	/*/
	cTxtOco := ""
	cTxtOco += Iif(Empty(RGP->RGP_CODEST),STR0032,"") 	// "Numero do Estabelecimento "
	cTxtOco += Iif(Empty(RGP->RGP_IRCT),STR0033,"") 	// "Código do IRCT "
	cTxtOco += Iif(Empty(SRA->RA_NOME),STR0019,"") 		// "Nome "
	cTxtOco += Iif(Empty(SRA->RA_NASC),STR0043,"") 		// "Data de Nascimento "
	cTxtOco += Iif(Empty(SRA->RA_ADMISSA),STR0044,"") 	// "Data de Admissão "
	cTxtOco += Iif(RGP->RGP_REMUBA > 0 .And. RGP->RGP_HRNORM = 0,STR0045,"") 	// "Horas Normais "
	cTxtOco += Iif(RGP->RGP_TRBSUP > 0 .And. RGP->RGP_HRSUPL = 0,STR0046,"") 	// "Horas Extras " 
	
	//If RGP->RGP_HRSEMAN - Int(RGP->RGP_HRSEMAN) == 0 // se eh hora completa, multiplica por 10 
        //nPerNormal 	:= RGP->RGP_HRSEMAN 
        //ElseIf RGP->RGP_HRSEMAN - Int(RGP->RGP_HRSEMAN) <= 0.50
        //   nPerNormal := (Int(RGP->RGP_HRSEMAN) + 0.50) * 10
        //Else
    	//   nPerNormal := (Int(RGP->RGP_HRSEMAN)+1) * 10
        //EndIf			
	If SRA->RA_HRSEMAN - Int(SRA->RA_HRSEMAN) == 0 // se eh hora completa, multiplica por 10 
        nPerNormal 	:= SRA->RA_HRSEMAN 
    ElseIf SRA->RA_HRSEMAN - Int(SRA->RA_HRSEMAN) <= 0.50
        nPerNormal := (Int(SRA->RA_HRSEMAN) + 0.50) * 10
    Else
        nPerNormal := (Int(SRA->RA_HRSEMAN)+1) * 10
    EndIf			
	cTxtOco += Iif(nPerNormal=0,STR0047,"")     	// "Período Normal de Trabalho Semanal (PNT) "
	cTxtOco += Iif(Empty(RGP->RGP_CATEGO),STR0048,"") 	// "Código de Categoria Profissional "
	cTxtOco += Iif(Empty(RGP->RGP_CODHAB),STR0049,"") 	// "Código de Grau de Instruçao "
	cTxtOco += Iif(Empty(RGP->RGP_CODPRO),STR0050,"") 	// "Código de Profissão "
	cTxtOco += Iif(Empty(RGP->RGP_CODNAC),STR0051,"") 	// "Código de Nacionalidade "
	cTxtOco += Iif(Empty(RGP->RGP_SITPRO),STR0052,"") 	// "Situação na Profissão "
	cTxtOco += Iif(Empty(RGP->RGP_TIPOCO),STR0053,"") 	// "Tipo de Contrato "
	cTxtOco += Iif(Empty(RGP->RGP_REGIME),STR0054,"") 	// "Regime de Duração do Trabalho "
	cTxtOco += Iif(Empty(SRA->RA_SEXO ),STR0055,"") 	// "Sexo "

	If !Empty(cTxtOco) 
		If aTotRegs[5] == 0
			cLog := STR0039 // "Inconsistencias no Cadastro de Funcionarios"
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[5] := len(aLog)
		Endif
		Aadd(aLog[aTotRegs[5]], SRA->RA_MAT+"-"+AllTrim(SRA->RA_NOME)+":"+cTxtOco ) 
	Else
		// se nao ha inconsistencias no cadastro do funcionario
		If aTotRegs[13] == 0
			cLog := STR0014 // "Funcionários sem inconsistencias."
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[13] := len(aLog)
		EndIf	
		Aadd(aLog[aTotRegs[13]], SRA->RA_FILIAL+"-"+SRA->RA_MAT+ space(02)+SRA->RA_NOME ) 
	EndIf	
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GPM775Ok  ºAutor  ³Microsiga           º Data ³  22/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPM775Ok()
Return (MsgYesNo(OemToAnsi(STR0012),OemToAnsi(STR0007))) //"Confirma configura‡„o dos parƒmetros?"###"Aten‡„o"

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Gpem775QbrPar³Autor³ Rogerio Vaz Melonio    ³Data³22/08/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna o texto dos parametros separado em linhas      		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function Gpem775QbrPar(cPerg)
nLinha := 1
nStrPar := 1
cTxtPar := ""
cTxtSX1 := ""
dbSelectArea("SX1")
dbSetOrder(1)
dbSeek(cPerg)
aParamQP := {}
While !Eof() .And. SX1->X1_GRUPO == cPerg
	cTxtSX1 += AllTrim(SX1->X1_PERGUNT)+":'"
	cVarX1 := AllTrim(SX1->X1_VAR01)
	If SX1->X1_TIPO == "C"
		cContX1 := AllTrim(&cVarX1)
	ElseiF SX1->X1_TIPO == "N"
		cContX1 := AllTrim(Transform(&cVarX1,SX1->X1_PICTURE))
	ElseiF SX1->X1_TIPO == "D"
		cContX1 := Dtoc(&cVarX1)
	Endif
	Aadd(aParamQP,{SX1->X1_PERGUNT+" : ",cContX1})
	cTxtSX1 +=  cContX1+"' ; " 
	dbSkip()
EndDo
While nStrPar <= Len(cTxtSX1)
	If nLinha > 6
		Exit
	Endif
	cTxtPar += Substr(cTxtSX1,nStrPar,80)+Chr(13)
	nStrPar+=80  
	nLinha++
EndDo
While nLinha <= 6
	cTxtPar += Chr(13)
	nLinha++
EndDo
Return(cTxtPar)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³f775GravaQP    ºAutor  ³Rogerio Vaz Melonio º Data ³02/09/08º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de gravacao do arquivo texto do quadro de pessoal   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION f775GravaQP()
Local nY
Private cNomArq, nHdl
Private contafun, nTotal
Private cEOL    := CHR(13)+CHR(10)
Private aEstab := {}
Private aIRCT  := {}
Private cFilProc
Private aInfo 	:= {}
Private aLog := aLogTot := {}
Private aTitle	:= {}
Private aTotRegs
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Filial de                                         ³
//³ mv_par02 - Filial Ate                                        ³
//³ mv_par03 - Ano/Mes Referencia                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Monta array com as filiais que serao processadas pela rotina                   
aFilProc := {}
dbSelectArea("SM0")
cEmpFilOld := CNUMEMP
cEmpFilAtu := CEMPANT + mv_par01
dbSeek(cEmpFilAtu,.T.)
While !Eof() .And. SM0->M0_CODIGO+SM0->M0_CODFIL <= CEMPANT+mv_par02
	aAdd(aFilProc,{SM0->M0_CODFIL,SM0->M0_FILIAL+"/"+SM0->M0_NOME+"/"+M0_NOMECOM,SM0->M0_CGC})
	dbSkip()
EndDo
dbSelectArea("RGP")
dbSetOrder(1) // RGP_FILIAL + RGP_ANOMES + RGP_CODEST + RGP_IRCT + RGP_MATRIC
aTotRegs := array(13)
aFill(aTotRegs,0)
aLog := {}
For nY := 1 To Len(aFilProc)
	lTemArq := .F.
	dbSelectArea("RGP")
	dbSetOrder(1) // RGP_FILIAL + RGP_ANOMES + RGP_CODEST + RGP_IRCT + RGP_MATRIC
	cFilAtu := aFilProc[nY][1] // Filial + empresa a processar
	If aTotRegs[11] == 0
		cLog := STR0010  // "Filial processada: "
		Aadd(aTitle,cLog)  
		Aadd(aLog,{})
		aTotRegs[11] := len(aLog)
		Aadd(aLog[aTotRegs[11]], cFilAtu+"-"+aFilProc[nY][2]) 
	EndIf	
	If dbSeek(cFilAtu+mv_par03) // Filial + Ano + Mes
		cFilProc := RGP->RGP_FILIAL
		nTotal := 0
		f775ContaFunc(cFilAtu) // chama rotina para totalizar funcionarios por estabelecimento / IRCT da filial que esta sendo processada
		cLin1 := f775GrvCab('00',cFilAtu) // Chama rotina de geracao do cabecalho - informacoes de contato
		cLin2 := f775GrvCab('10',cFilAtu) // Chama rotina de geracao do cabecalho - informacoes da empresa
		cLin3 := f775GrvCab('20',cFilAtu) // Chama rotina de geracao do cabecalho - informacoes do estabelecimento
		cLin4 := f775GrvCab('30',cFilAtu) // Chama rotina de geracao do cabecalho - informacoes do estabelecimento/IRCT
		cExt := Iif(!".TXT"$Upper(mv_par04),".txt","")
		// nome do arquivo no formato NIF_AAAA.TXT
		// se foi escolhida mais de uma filial, o nome sera criado automaticamente
		// nome formado por caminho + nome + extensao
		cNomArq := AllTrim(mv_par05)+Iif(mv_par01==mv_par02,+AllTrim(mv_par04),AllTrim(aFilProc[nY][3])+"_"+Substr(mv_par03,1,4))+cExt
		nHdl    := fCreate(cNomArq)
		If nHdl == -1
			MsgStop(STR0017+cNomArq+STR0018,STR0007) // ###"O arquivo de nome "###" nao pode ser gravado! Verifique os parametros."###"Atencao!"
			Return
		Endif
		fWrite(nHdl,cLin1,Len(cLin1))
		fWrite(nHdl,cLin2,Len(cLin2))
		fWrite(nHdl,cLin3,Len(cLin3))
		fWrite(nHdl,cLin4,Len(cLin4))
		lTemArq := .T.
		dbSelectArea("RGP")
		ProcRegua( nTotal )
		contafun := StrZero(0,10)
		cEstabIrct := RGP->RGP_CODEST+RGP->RGP_IRCT
		While !Eof() .And. RGP->RGP_FILIAL+RGP->RGP_ANOMES <= cFilAtu+mv_par03
			IncProc(RGP->RGP_MATRIC + "-" + RGP->RGP_NOME)
			If RGP->RGP_CODEST+RGP->RGP_IRCT <> cEstabIrct
				contafun := StrZero(0,10)
				cEstabIrct := RGP->RGP_CODEST+RGP->RGP_IRCT
			Endif
			cLin := f775GrvDet() // monta a linha com dados do funcionario
			If !Empty(cLin)
				fWrite(nHdl,cLin,Len(cLin))
				lTemArq := .T.
			Endif
			dbSelectArea("RGP")
			dbSkip()
		EndDo
		// Fecha o arquivo gerado somente se houver registros validos
		If lTemArq
			fClose(nHdl)
		Endif
	Else
		// Log informando que nao foram encontrados registros para processar
		If aTotRegs[12] == 0
			cLog := STR0056 // "Não foram encontrados registros para processar nesta filial"
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[12] := len(aLog)
			Aadd(aLog[aTotRegs[12]], aFilProc[nY][2] ) 
		EndIf	
	Endif
	If aTotRegs[1] == 0 .and. aTotRegs[2] == 0 .and. aTotRegs[3] == 0 .and. aTotRegs[4]==0 .and. ;
	   aTotRegs[5] == 0
		If aTotRegs[6] == 0
			cLog := STR0008 // "Arquivo texto do Quadro de Pessoal Gerado com sucesso!"
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[6] := len(aLog)
		EndIf	
		Aadd(aLog[aTotRegs[6]], STR0009 ) // "Nao foi encontrada nenhuma inconsistencia durante a geracao."
	EndIf   
Next

If aTotRegs[7] == 0
	cLog := STR0057+Chr(13) // "Informações para gerar o arquivo texto do Quadro de Pessoal."
	Aadd(aTitle,cLog)  
	Aadd(aLog,{})
	aTotRegs[7] := len(aLog)
	Aadd(aLog[aTotRegs[7]], STR0003) //"Parâmetros"
	For nY := 1 To Len(aParamQP)
		Aadd(aLog[aTotRegs[7]], aParamQP[nY][1]+aParamQP[nY][2] )
	Next
EndIf	

fMakeLog(aLog,aTitle,,,"GPEM775",STR0011,"G","L",,.F.) // "Log de ocorrências da geração do arquivo texto do Quadro de Pessoal"
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f775GrvCab³ Autor ³ Rogerio Vaz Melonio   ³ Data ³03/09/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cabecalho dos arquivos a serem gerados                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function f775GrvCab(cTipo,cFilAtu)
Local nX
// Monta os cabecalhos dos arquivos conforme o tipo de registro
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Filial de                                         ³
//³ mv_par02 - Filial Ate                                        ³
//³ mv_par03 - Ano/Mes Referencia                                ³
//³ mv_par04 - Nome do Arquivo                                   ³
//³ mv_par05 - Local do Arquivo                                  ³
//³ mv_par06 - Capital Social                                    ³
//³ mv_par07 - % Privado Nacional                                ³
//³ mv_par08 - % Estrangeiro                                     ³
//³ mv_par09 - % Publico                                         ³
//³ mv_par10 - Volume de Negocios                                ³
//³ mv_par11 - Nome de Contato                                   ³
//³ mv_par12 - Fone 1                                            ³
//³ mv_par13 - Fone 2                                            ³
//³ mv_par14 - Fax                                               ³
//³ mv_par15 - Email                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == '00'
	/*/
	cTipo == '00'
	Estrutura do Registro de Contato					
	Descricao						Conteudo	Tipo	Tamanho		Obg 	Varíavel / Campo
	Tipo de Registro 				00			A 			2		S 		"00"
	Nome(s) do Contato							A 			100		S 		Padr(mv_par11,100)
	Contato					
	Telefone 1 									N 			9		S 		mv_par12
	Telefone 2 									N 			9				mv_par13
	Fax 										N 			9				mv_par14
	Correio Eletrônico							A 			60		S 		Padr(mv_par15,60)
	Aplicativo de Geração da Informação 					
	Nome da Empresa Produtora 					A 			60				space(60)
	Nome do Aplicativo							A 			40				space(40)
	Versão do Aplicativo						A 			20				space(20)
	Tamanho do registro										309		
	/*/
	cCab := cTipo 				// Tipo de Registro
	cCab += Padr(mv_par11,100) 	// Nome(s) do Contato
	cCab += mv_par12 			// Fone 1
	cCab += mv_par13 			// Fone 2
	cCab += mv_par14 			// Fax
	cCab += Padr(mv_par15,60) 	// Email
	cCab += Space(60)           // Brancos
	cCab += Space(40)			// Brancos
	cCab += Space(20)			// Brancos
	cCab += cEOL 				// caracter de fim de linha 
	f775LogTipo(cTipo,Nil,Nil,Nil,Nil,Nil,Nil)
ElseIf cTipo == '10'
	/*/
	cTipo == '10'
	Estrutura do Registro da Empresa					
	Descricao						Conteudo	Tipo	Tamanho		Obg 	Varíavel / Campo
	Tipo de Registro 				10			N 			2		S 		"10"
	Nº de Identificação Fiscal 					N 			9		S 		SM0->M0_CGC 
	Ano de Referência da Informação 			N 			4		S 		Substr(mv_par03,1,4)
	Nome da Empresa 							A 			60		S 		SM0->M0_NOMECOM
	Localização e Contatos da Sede da Empresa 					
	Morada 										A 			40		S 		SM0->M0_ENDCOB e caso esteja vazio, SM0->M0_ENDENT
	Localidade 									A 			20		S 		SM0->M0_BAIRCOB, se estiver vazio, SM0->M0_BAIRENT
	Código Postal 								N 			7		S 		SM0->M0_CEPCOB, se estiver vazio, SM0->M0_CEPENT
	Código Postal (descritivo) 					A 			20		S 		fDesc("SCG",SM0->M0_CEPCOB,"CG_DESCEP") ou fDesc("SCG", SM0-> M0_CEPENT, "CG_DESCEP")
	Telefone 									N 			9		S 		SM0->M0_TEL
	Fax 										N 			9				SM0->M0_FAX
	Correio Eletrônico 							A 			60				Padr(mv_par15,60)
	Código de Distrito / Município / Freguesia 	N 			6		S 	
	Associações Patronais 			 		
	Código de Associação Patronal 				N 			3		
	Código de Associação Patronal 				N			3		
	Código de Associação Patronal 				N			3		
	Código da Atividade Principal da Empresa 	N 			5		S 		SM0->M0_CNAE 
	Código de Natureza Jurídica 				N 			2		S 		SM0->M0_NATJUR 
	Ano de Constituição da Empresa 				N 			4		S 	
	Número de Pessoas ao Serviço da Empresa 	N 			5		S 		RecCount("RGP")
	Capital Social 				 	
	Montante 									N 			12				StrZero(mv_par06*100,12)	
	% Privado Nacional 				   			N 			4				StrZero(mv_par07*100,4)
	% Estrangeiro 					   			N 			4				StrZero(mv_par08*100,4)
	% Público 									N 			4				StrZero(mv_par09*100,4)
	Volume de negócios, ano anterior 			N 			12		S 		StrZero(mv_par10*100,12)
	/*/
	dbSelectArea("SM0")
	dbSeek(CEMPANT+cFilAtu) // posiciona SIGAMAT na Empresa/Filial que esta sendo processada
	cMorada := Iif(!Empty(SM0->M0_ENDCOB),SM0->M0_ENDCOB,SM0->M0_ENDENT)
	cLocalidade := Iif(!Empty(SM0->M0_BAIRCOB),SM0->M0_BAIRCOB,SM0->M0_BAIRENT)
	cCodPostal := Iif(!Empty(SM0->M0_CEPCOB),SM0->M0_CEPCOB,SM0->M0_CEPENT)
	cDescPostal := fDesc("SCG",cCodPostal,"CG_DESCEP")
	cCab := cTipo 							// Tipo de Registro
	cCab += Padr(SM0->M0_CGC,9)			 	// NIF
	cCab += Substr(mv_par03,1,4)			// Ano/Mes de referencia
	cCab += Padr(SM0->M0_NOMECOM,60) 		// Nome da Empresa
	cCab += Padr(cMorada,40) 				// Morada
	cCab += Padr(cLocalidade,20) 			// Localidade
	cCab += Padr(cCodPostal,7)				// Codigo Postal
	cCab += Padr(cDescPostal,20) 			// Descricao Codigo Postal
	cCab += Padr(SM0->M0_TEL,9) 			// Telefone
	cCab += Padr(SM0->M0_FAX,9) 			// Fax
	cCab += Padr(mv_par15,60) 				// Email
	cCab += Padr(SM0->M0_CODMUN,6)			// Código de Distrito / Município / Freguesia
	cCab += Padr(SM0->M0_ASSPAT1,3) 		// Associacao Patronal 1
	cCab += Padr(SM0->M0_ASSPAT2,3)			// Associacao Patronal 2
	cCab += Padr(SM0->M0_ASSPAT3,3)	 		// Associacao Patronal 3
	cCab += Padr(SM0->M0_CNAE,5) 	        // Cod. Atividade da Empresa
	cCab += Padr(SM0->M0_NATJUR,2) 			// Cod. Natureza Juridica
	cCab += IIF(EMPTY(SM0->M0_NIRE),"0000",STRZERO(SM0->M0_NIRE,4)) // Ano de Constituicao da empresa
	cCab += StrZero(nTotal,5) 				// Numero de empregados da empresa 
	cCab += StrZero(mv_par06*100,12)	 	// Capital Social
	cCab += StrZero(mv_par07*10,4)		 	// % privado nacional
	cCab += StrZero(mv_par08*10,4) 		// % estrangeiro
	cCab += StrZero(mv_par09*10,4) 		// % publico
	cCab += StrZero(mv_par10*100,12) 		// Volume de Negocios do ano anterior
	cCab += cEOL 				// caracter de fim de linha
	f775LogTipo(cTipo,cMorada,cLocalidade,cCodPostal,cDescPostal,Nil,Nil)
ElseIf cTipo == '20'
	/*/
	Estrutura do Registro do estabelecimento
	Descricao						Conteudo	Tipo	Tamanho		Obg 	Varíavel / Campo
	Tipo de Registro 					20		N 			2		S 		"20"
	Nº do Estabelecimento 						N 			4		S 		RCO_NESTAB
	Nome do Estabelecimento 					A 			60		S 		RCO_NOME
	Localização e Contatos do Estabelecimento 					
	Morada 										A 			40		S 		RCO_END
	Localidade 									A 			20		S 		RCO_LOCAL
	Código Postal 								N 			7		S 		RCO_CEP
	Código Postal (descritivo) 					A 			20		S 		fDesc("SCG",RCO->RCO_CEP,"CG_DESCEP"))
	Telefone 									N 			9		S 		RCO_FONE
	Fax 										N 			9				RCO_FAX
	Correio Eletrônico 							A 			60				RCO_EMAIL
	Código de Distrito / Município / Freguesia 	N 			6		S 		RCO_BAIRRO
	Número de Contribuinte da Segurança Social 	N 			11				RCO_NISS
	Cód. Atividade Principal do Estabelecimento	N 			5		S 		RCO_ATIVID
	Nº de pessoas ao serviço no Estabelecimento N			5		S 		calcular
	/*/
	dbSelectArea("RCO")
	dbSetOrder(1) // RCO_FILIAL+RCO_CODIGO
	cCab := ""
	For nX := 1 To Len(aEstab)
		If dbSeek(xFilial("RCO")+aEstab[nX][1])
			cCab += cTipo 								// Tipo de Registro
			cCab +=  StrZero(Val(RCO->RCO_NESTAB),4) 	// 2. Nro do Estabelecimento 
			cCab +=  Padr(RCO->RCO_NOME,60) 	// 3. Nome do Estabelecimento 
			cCab +=  Padr(RCO->RCO_END,40) 		// 4.1. Morada 
			cCab +=  Padr(RCO->RCO_LOCAL,20) 	// 4.2. Localidade 
			cCab +=  RCO->RCO_CEP 				// 4.3. Código Postal 
			cDescPostal := fDesc("SCG",RCO->RCO_CEP,"CG_DESCEP")
			cCab +=  Padr(cDescPostal,20) 		// 4.4. Código Postal (descritivo) 
			cCab +=  Padr(RCO->RCO_FONE,9) 		// 4.5. Telefone 
			cCab +=  Padr(RCO->RCO_FAX,9) 		// 4.6. Fax 
			cCab +=  Padr(RCO->RCO_EMAIL,60) 	// 4.7. Correio Eletrônico 
			cCab +=  RCO->RCO_BAIRRO 			// 4.8. Código de Distrito / Município / Freguesia 
			cCab +=  StrZero(Val(RCO->RCO_NISS),11) // 5. Número de Contribuinte da Segurança Social 
			cCab +=  StrZero(Val(RCO->RCO_ATIVID),5) // 6. Código da Atividade Principal do Estabelecimento
			cCab +=  StrZero(aEstab[nX][2],5) 		// 7. Nº de pessoas ao serviço no Estabelecimento 
			cCab += cEOL 			// caracter de fim de linha
			f775LogTipo(cTipo,Nil,Nil,Nil,cDescPostal,Nil,Nil)
		Else
			If aTotRegs[8] == 0
				cLog := STR0040 // "Estabelecimento no Quadro de Pessoal não encontrado no Cadastro de Estabelecimentos"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[8] := len(aLog)
			EndIf	
			Aadd(aLog[aTotRegs[8]], aEstab[nX][1]) 
		Endif
	Next
ElseIf cTipo == '30'
	/*/
	Estrutura do Registro do estabelecimento/IRCT
	Descricao						Conteudo	Tipo	Tamanho		Obg 	Varíavel / Campo
	Tipo de Registro 					30		N			2		S 		"30"
	Nº do Estabelecimento 						N 			4		S 		RCO->RCO_NESTAB
	Instrumento de Regulamentação Coletiva de Trabalho (IRCT) 					
	Código do IRCT 								N 			5		S 		SRA->RA_CODIRCT
	Nº de Boletim Trabalho e Emprego (BTE)		N 			2				RGD->RGD_NUMBOL
	Data de publicação no BTE (AAAAMMDD)					8				dtos(RGD->RGD_DTPUBL)
	Data início eficácia tab salarial (AAAAMM) 	N 			6				Substr(dtos(RGD->RGD_DTEFIC),1,6)
	Controle de Nº de Trabalhadores abrangidos 	N 			5		S 		calcular
	/*/
	dbSelectArea("RGD")
	dbSetOrder(1) // RGD_FILIAL+RGD_CODIGO
	dbSelectArea("RCO")
	dbSetOrder(1) // RCO_FILIAL+RCO_CODIGO
	cCab := ""
	For nX := 1 To Len(aIRCT)
		dbSelectArea("RCO")
		If dbSeek(xFilial("RCO")+aIRCT[nX][1]) // busco no RCO o estabelecimento 
			cCodEstab := aIRCT[nX][1]
			cCodIRCT  := aIRCT[nX][2]
			dbSelectArea("RGD")
			If dbSeek(cFilAtu+aIRCT[nX][2]) // busco no RGD o IRCT
				cCab += cTipo 							// Tipo de Registro
				cCab += StrZero(Val(RCO->RCO_NESTAB),4)	// 2. Nº do Estabelecimento 
				cCab += aIRCT[nX][2] 					// 3.1. - Código do IRCT 
				cCab += StrZero(Val(RGD->RGD_NUMBOL),2)	// 3.2. - Nº de Boletim Trabalho e Emprego (BTE)
				cCab += dtos(RGD->RGD_DTPUBL) 			// 3.3 - Data de publicação no BTE (AAAAMMDD)
				cCab += Substr(dtos(RGD->RGD_DTEFIC),1,6) // 3.4. - Data de início de eficácia da última tabela salarial (AAAAMM) 
				cCab += StrZero(aIRCT[nX][3],5)	// 4. Controle de Nº de Trabalhadores abrangidos 
				cCab += cEOL 					// caracter de fim de linha
			Else
				If aTotRegs[9] == 0
					cLog := STR0041 // "IRCT no Quadro de Pessoal não encontrado no Cadastro de IRCT"
					Aadd(aTitle,cLog)  
					Aadd(aLog,{})
					aTotRegs[9] := len(aLog)
				EndIf	
				Aadd(aLog[aTotRegs[9]], aIRCT[nX][2]) 
			Endif
		Else
			If aTotRegs[8] == 0
				cLog := STR0040 // "Estabelecimento no Quadro de Pessoal não encontrado no Cadastro de Estabelecimentos"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[8] := len(aLog)
			EndIf	
			Aadd(aLog[aTotRegs[8]], aIRCT[nX][1]) 
		Endif
		f775LogTipo(cTipo,Nil,Nil,Nil,Nil,cCodEstab,cCodIRCT)
	Next
Endif
Return(cCab)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f775GrvDet³ Autor ³ Rogerio Vaz Melonio   ³ Data ³03/09/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Detalhe dos funcionarios para gravar no arquivo TXT        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function f775GrvDet() // monta a linha com dados do funcionario
dbSelectArea("SRA")
cDet := ""
If dbSeek(RGP->RGP_FILIAL+RGP->RGP_MATRIC)
	contafun := soma1(contafun)
	cSexo := Iif(SRA->RA_SEXO=="M","1","2")
	cUltPromo := Iif(!Empty(RGP->RGP_ULTPRO),Substr(dtos(RGP->RGP_ULTPRO),1,6),Repl("0",6))
	cDet := "40"				// Tipo de Registro
	cDet +=  RGP->RGP_CODEST	// 2 - Nº. do Estabelecimento 
	cDet +=  RGP->RGP_IRCT 		// 3. Código do IRCT 
	cDet +=  Substr(contafun,Len(contafun)-1,2)	// 4 Nº. de Linha 
	cDet +=  Padr(SRA->RA_NOME,40) 				// 5. Nome do Trabalhador 
	cDet +=  Substr(dtos(SRA->RA_NASC),1,6) 	// Nascimento 
	cDet +=  Substr(dtos(SRA->RA_ADMISSA),1,6) 	// Admissão na empresa 
	cDet +=  cUltPromo 							// Ultima Promoção
	cDet +=  StrZero(RGP->RGP_REMUBA*100,8) 	// Base 
	cDet +=  StrZero(RGP->RGP_PREMIO*100,8) 	// Prêmios e Subsídios Regulares 
	cDet +=  StrZero(RGP->RGP_TRBSUP*100,8) 	// Trabalho Suplementar (efetuado em Outubro) 
	cDet +=  StrZero(RGP->RGP_IRREGU*100,8) 	// Prestações Irregulares (pagas em Outubro) 
	cDet +=  StrZero(RGP->RGP_HRNORM,3) 	// Horas Normais 
	cDet +=  StrZero(RGP->RGP_HRSUPL,3) 	// Horas Suplementares (efetuadas em Outubro)
	cDet +=  StrZero(RGP->RGP_PERNOR,3) 	// Período Normal de Trabalho Semanal (PNT) 
	cDet +=  RGP->RGP_CONTRO 	// Controle de Remuneração Base 
	cDet +=  RGP->RGP_CATEGO 	// Código de Categoria Profissional 
	cDet +=  RGP->RGP_CODPRO 	// Código de Profissão 
	cDet +=  RGP->RGP_CODHAB 	// Código de Habilitação 
	cDet +=  RGP->RGP_CODNAC 	// Código de Nacionalidade 
	cDet +=  "0" 			 	// Situação face à Lei nº 20/98 
	cDet +=  RGP->RGP_SITPRO 	// Situação na Profissão 
	cDet +=  RGP->RGP_TIPOCO 	// Tipo de Contrato 
	cDet +=  RGP->RGP_REGIME 	// Regime de Duração do Trabalho 
	cDet +=  cSexo 			 	// Sexo 
	cDet +=  SRA->RA_NISSPS  	// Nº de Beneficiário da Segurança Social 
	cDet += cEOL 				// caracter de fim de linha
	f775LogTipo('40',Nil,Nil,Nil,Nil,Nil,Nil)
Else
	cDet := ""
	If aTotRegs[10] == 0
		cLog := STR0042 // "Funcionario no quadro de pessoal nao encontrado no Cadastro de Funcionarios"
		Aadd(aTitle,cLog)  
		Aadd(aLog,{})
		aTotRegs[10] := len(aLog)
	EndIf	
	Aadd(aLog[aTotRegs[10]], RGP->RGP_MATRIC+"-"+AllTrim(RGP->RGP_MATRIC)) 
Endif
dbSelectArea("RGP")
Return(cDet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f775ContaFunc³ Autor ³ Rogerio Vaz Melonio   ³ Data ³03/09/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para totalizar funcionarios por estabeleciento / IRCT  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function f775ContaFunc(cFilAtu)
Local nX
// Select para totalizar funcionario por estabelecimento/IRCT da filia que esta sendo processada
cQry1 := "SELECT COUNT(RGP_MATRIC) FUNC_IRCT,RGP_CODEST,RGP_IRCT  FROM " + RetSQLName("RGP")+" RGP "
cQry1 += " WHERE RGP.RGP_FILIAL='"+cFilAtu+"'"
cQry1 += " AND RGP.RGP_ANOMES = '"+mv_par03+"' AND RGP.D_E_L_E_T_ <> '*' "
cQry1 += " GROUP BY RGP_FILIAL,RGP_CODEST,RGP_IRCT "
cQry1 += " ORDER BY RGP_CODEST,RGP_IRCT "
cQry1 := ChangeQuery(cQry1)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry1),"TMP1", .F., .T.)
dbSelectArea("TMP1")
dbGoTop()
While !Eof()
	aAdd(aIRCT,{TMP1->RGP_CODEST,TMP1->RGP_IRCT,TMP1->FUNC_IRCT})
	dbSkip()
Enddo
dbCloseArea()
aSort(aIRCT,,,{|x,y| x[1]+x[2] < y[1]+y[2] }) // coloca em ordem por Estabelecimento + IRCT
For nX := 1 To Len(aIRCT)
	nPosEst	 := aScan(aEstab,{|x| x[1] == aIRCT[nX][1]})
	If nPosEst == 0
		aAdd(aEstab,{aIRCT[nX][1],0})
		nPosEst := Len(aEstab)
	Endif
	aEstab[nPosEst][2] += aIRCT[nX][3] // acumula a quantidade de funcionarios do IRCT ao Estabelecimento
	nTotal += aIRCT[nX][3] // acumula a quantidade de funcionarios do Estabelecimento para a empresa
Next
Return