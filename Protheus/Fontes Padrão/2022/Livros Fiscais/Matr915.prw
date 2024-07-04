#INCLUDE "MATR915.CH"
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥  MATR915 ≥ Autor ≥ Eduardo Ju            ≥ Data ≥ 04.08.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Listagem de Conferencia da GiaRJ                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥Nenhum                                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥Nenhum                                                      ≥±±
±±≥          ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥   DATA   ≥ Programador   ≥Manutencao efetuada                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥          ≥               ≥                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

Function Matr915()
	Local 	Titulo  := OemToAnsi(STR0001) //"Listagem de Conferencia da GIA-RJ"             
	Local 	cDesc1  := OemToAnsi(STR0002) //"Este programa permite listar quais sao informacoes  "  
	Local 	cDesc2  := OemToAnsi(STR0003) //"geradas em Arquivo Magnetico e que serao validadas  "  
	Local 	cDesc3  := OemToAnsi(STR0004) //"pela Secretaria da Fazenda do Rio de Janeiro."                              
	Local 	cAlias  := "SF3"  // Alias utilizado na Filtragem
	Local 	lDic    := .F. // Habilita/Desabilita Dicionario
	Local 	lComp   := .T. // Habilita/Desabilita o Formato Comprimido/Expandido
	Local 	lFiltro := .F. // Habilita/Desabilita o Filtro
	Local 	wnrel   := "MATR915"  
	Local 	nomeprog:= "MATR915"
	Local 	nAno  	:= 0
	Local 	nMes  	:= 0
	Local 	aDatas	:= {}
	Local 	lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
	Private Tamanho := "M" // P/M/G
	Private Limite  := 132 // 80/132/220
	Private aOrdem  := {}  // Ordem do Relatorio
	Private cPerg   := "GIARJ "  // Pergunta do Relatorio
	Private aReturn := { STR0005, 1,STR0006, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
	Private lEnd    := .F.// Controle de cancelamento do relatorio
	Private nPagina := 1  // Contador de Paginas
	Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault 
	If lVerpesssen
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Verifica as Perguntas Seleciondas                                       ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		Pergunte(cPerg,.F.)
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Envia para a SetPrinter                                                 ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		wnrel:=SetPrint(cAlias,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)
		//
		If ( nLastKey==27 )
			dbSelectArea(cAlias)
			dbSetOrder(1)
			Set Filter to
			Return
		Endif
		//
		SetDefault(aReturn,cAlias)
		//
		If ( nLastKey==27 )
			dbSelectArea(cAlias)
			dbSetOrder(1)
			Set Filter to
			Return
		Endif     
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Chamada da Funcao que retorna Data Inicial e Data Final                 ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		nAno  := mv_par01
		nMes  := mv_par02
		aDatas:=DetDatas(nMes,nAno,3,1)
		dDtIni:=aDatas[1]
		dDtFim:=aDatas[2] 
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Chamada da Funcao ResumeF3 (Apuracao do ICMS) Fisxapur.prx              ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		ResumeF3("IC",dDtIni,dDtFim,"*",.F.,.T.,1,.F.,2,Nil,Nil,{},{},"",.T.,"ICM",,,.F.)
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Chamada da Funcao  FisApur (Apuracao do ICMS) Fisxapur.prx              ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		FisApur("IC",val(Substr(DTOS(dDtFim),1,4)),val(Substr(DTOS(dDtFim),5,2)),2,0,"*",.F.,{},1,.T.,"PUR","")
		//
		RptStatus({|lEnd| ImpDet(@lEnd,wnRel,cAlias,nomeprog,Titulo)},Titulo)
	EndIf
Return(.T.)
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Program   ≥ ImpDet   ≥ Autor ≥ Eduardo Ju            ≥ Data ≥04.08.2003≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Controle de Fluxo do Relatorio.                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥Nenhum                                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥   DATA   ≥ Programador   ≥Manutencao efetuada                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥          ≥               ≥                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function ImpDet(lEnd,wnrel,cAlias,nomeprog,Titulo)
	Local li      := 100 // Contador de Linhas
	Local lImp    := .F. // Indica se algo foi impresso
    //
	DbSelectArea(cAlias)
	SetRegua((cAlias)->(LastRec()))
	DbSetOrder(1)
	DbSeek(xFilial(cAlias))
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Execucao do relatorio                                        ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	RptStatus({|lEnd| R915Imp(@lEnd,wnRel,cAlias,Tamanho)},titulo)
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Restaura Ambiente                                            ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	dbSelectArea(cAlias)
	dbClearFilter()
	//		
	Set Device To Screen
	Set Printer To
	If ( aReturn[5] = 1 )
		dbCommitAll()
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
Return(.T.)
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ R915Imp  ≥ Autor ≥ Eduardo Ju            ≥ Data ≥ 05.08.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Chama Funcao Matr915 - Utilizado para Gerar Relatorio      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function R915Imp(lEnd,WnRel,cAlias,Tamanho)
	Local	nLinPag	:=	55
	Private nTotReg := 2    //Contador de Registros, inicializado c/2 pelo fato de nao considerar Reg Tipo 0000
	Private nSomaVal:= 0    //Somatoria de todos os Valores Mencionados
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Imprime Registro Identificador da Declaracao         ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Reg0110(nLinPag)  
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Imprime Registro de Movimentacao de Entradas         ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Reg0120(nLinPag)  
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Imprime Registro de Movimentacao de Saidas           ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Reg0130(nLinPag)   
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Imprime Registros: 0140 / 0150 / 0160 / 0170 / 0180  ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	RegApur(nLinPag)      
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Imprime Registro de Movimentacao de Operacoes com Prazo Especial ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Reg0190(nLinPag) 
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Imprime Registro de Movimentacao de Outros ICMS devido  ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Reg0200(nLinPag)   
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Imprime Registro de Movimentacao de Entradas Interestaduais  ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	DbSelectArea("ICM")
		dbCloseArea()
	ResumeF3("IC",dDtIni,dDtFim,"*",.F.,.T.,1,.F.,2,Nil,Nil,{},{},"",.T.,"ICM",,,.T.)
	Reg0210(nLinPag)  
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Imprime Registro de Movimentacao de Saidas Interestaduais    ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Reg0220(nLinPag)
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Imprime Registro de Movimentacao de Saidas para ZFM/ALC      ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Reg0230(nLinPag)
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Imprime Registro de Movimentacao de SCE Compensado entre Estabelecimentos ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Reg0240(nLinPag)  
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Imprime Registro de Movimentacao de SCE Compensado do Proprio≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Reg0250(nLinPag)       
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Imprime Registro de Movimentacao de SCE Recebido             ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Reg0260(nLinPag)  
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Imprime Registro de Movimentacao de SCE Transferido          ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Reg0270(nLinPag)
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Imprime Registro Trailler do Arquivo (Somatoria dos Valores) ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	//Reg9999(nLinPag)
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Fecha Arquivos Utilizados                                    ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	DbSelectArea("ICM")
	dbCloseArea()
	//	
	DbSelectArea("PUR")
	dbCloseArea()
	//
	DbSelectArea("SX5")
	dbCloseArea() 
	//
	DbSelectArea("SA1")
	dbCloseArea()
	//
	DbSelectArea("SA2")
	dbCloseArea()
	//
	DbSelectArea("SF3")
	dbCloseArea()
Return
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ Reg0110  ≥ Autor ≥ Eduardo Ju            ≥ Data ≥ 14.08.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Registro Identificador da Declaracao                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function Reg0110(nLinPag)
	Local 	cTipo       := "" 
	Local 	nLin 		   := 0 
	Local 	cInsc_Estad := SM0->M0_INSC
	Local 	nAA_Referen := StrZero (mv_par01, 4)
	Local 	nMM_Referen := StrZero (mv_par02, 2)
	Local 	cInd_Retif  := IIf(mv_par03==1,"S","N")
	Local 	cNomeReprLeg:= mv_par04
	Local 	cDDD_ReprLeg:= mv_par05
	Local 	cTel_ReprLeg:= mv_par06
	Local 	cNom_Ctabil := mv_par07
	Local 	cEmail      := mv_par08
	Local 	cDDD_Ctabil := mv_par09
	Local 	cTel_Ctabil := mv_par10
	Local 	nValSaldoAnt:= mv_par11
	Local 	nValSalAntST:= mv_par12
	Local 	cObs        := mv_par13
	Local 	cObs_ST     := mv_par14
	Local 	nValAntSCE  := mv_par15
	Local 	nValCrdSCE  := mv_par16
	Local 	nValEstSCE  := mv_par17
	Local 	nValProvSCE := mv_par18
	Local 	cInd_Mop    := IIF(mv_par19==1,"S","N")
	Local 	cInd_Mtribut:= IIF(mv_par20==1,"S","N")
	Local 	cInd_MICMS  := IIF(mv_par21==1,"S","N")
	Local 	cInd_MALCZFM:= IIF(mv_par22==1,"S","N")
	Local	aL 			:= R915LayOut()
	//	  
	cTipo:= "0110"  
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Rotina de Impressao do Registro 0110                         ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If nLin == 0
		R915Cabec(aL,@nLin,@nPagina,cTipo)
	Endif                  
	// 			 
	FmtLin ({Transform(cInsc_Estad,"@R 999.999.999.999")},al[07],,,@nLin)
	FmtLin ({nAA_Referen},al[08],,,@nLin)
	FmtLin ({nMM_Referen},al[09],,,@nLin)
	FmtLin ({cInd_Retif},al[10],,,@nLin)
	FmtLin ({cNomeReprLeg},al[11],,,@nLin)
	FmtLin ({cDDD_ReprLeg},al[12],,,@nLin)
	FmtLin ({cTel_ReprLeg},al[13],,,@nLin)
	FmtLin ({cNom_Ctabil},al[14],,,@nLin)
	FmtLin ({cEmail},al[15],,,@nLin)
	FmtLin ({cDDD_Ctabil},al[16],,,@nLin)
	FmtLin ({cTel_Ctabil},al[17],,,@nLin)
	FmtLin ({nValSaldoAnt},al[18],,,@nLin)
	FmtLin ({nValSalAntST},al[19],,,@nLin)
	FmtLin ({cObs},al[20],,,@nLin)
	FmtLin ({cObs_ST},al[21],,,@nLin)
	FmtLin ({nValAntSCE},al[22],,,@nLin)
	FmtLin ({nValCrdSCE},al[23],,,@nLin)
	FmtLin ({nValEstSCE},al[24],,,@nLin)
	FmtLin ({nValProvSCE},al[25],,,@nLin)
	FmtLin ({cInd_Mop},al[26],,,@nLin)
	FmtLin ({cInd_Mtribut},al[27],,,@nLin)
	FmtLin ({cInd_MICMS},al[28],,,@nLin)
	FmtLin ({cInd_MALCZFM},al[29],,,@nLin)
	FmtLin ({},al[30],,,@nLin) 
	//	
	nTotReg += 1
	nSomaVal+= nValSaldoAnt+nValSalAntST+nValAntSCE+nValCrdSCE+nValEstSCE+nValProvSCE   
Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ Reg0120  ≥ Autor ≥ Eduardo Ju            ≥ Data ≥ 14.08.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Registro de Movimentacao de Entradas                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function Reg0120(nLinPag)
	Local cTipo       	:= ""
	Local nLin        	:= 0
	Local cCod_FisOp  	:= ""	
	Local nVal_ctabil 	:= 0
	Local nVal_BasCalc	:= 0
	Local nVal_Imposto	:= 0
	Local nVal_OpIsent	:= 0
	Local nVal_OutraOP	:= 0
	Local nVal_CalcST 	:= 0
	Local nVal_Retido 	:= 0
	Local lImprime    	:= .F. 
	Local	nTotVlrCont	:=	0
	Local	nTotVlrBC	:=	0
	Local	nTotVlrImp	:=	0
	Local	nTotVlrIsen	:=	0
	Local	nTotVlrOut	:=	0
	Local	aL 			:= R915LayOut()
	Local	lTotaliza	:=	.F.
	//
	cTipo := ""
	//
	DbSelectArea("ICM")
	SetRegua(LastRec())
	DbGoTop() 
	While !Eof() 
		If Interrupcao(@lEnd)
			Loop
		Endif 
		If Substr(CFOP,1,1) < "5" 
			lImprime    := .T.
			cTipo       := "0120"
			cCod_FisOp  := ICM->CFOP	
			nVal_ctabil := ICM->VALCONT
			nVal_BasCalc:= ICM->BASEICM
			nVal_Imposto:= ICM->VALICM
			nVal_OpIsent:= ICM->ISENICM
			nVal_OutraOP:= ICM->OUTRICM
			nVal_CalcST := ICM->BASERET
			nVal_Retido := ICM->ICMSRET 
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Rotina de Impressao do Registro 0120                         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			IncRegua()
			//
			If (nLin == 0 .And. lImprime) .Or. (nLin>=nLinPag)
				If nLin>=nLinPag
					FmtLin({},al[39],,,@nLin)
					nLin := 2
				EndIf
				R915Cabec(aL,@nLin,@nPagina,cTipo)
			Endif                  
			//
			FmtLin({cCod_FisOp,nVal_ctabil,nVal_BasCalc,nVal_Imposto,nVal_OpIsent,nVal_OutraOP},al[38],,,@nLin) 
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Totalizando registros≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			nTotVlrCont	+=	nVal_ctabil
			nTotVlrBC	+=	nVal_BasCalc
			nTotVlrImp	+=	nVal_Imposto
			nTotVlrIsen	+=	nVal_OpIsent
			nTotVlrOut	+=	nVal_OutraOP		
			lTotaliza	:=	.T.
			//
			nTotReg += 1
			nSomaVal+= ICM->VALCONT+ICM->BASEICM+ICM->VALICM+ICM->ISENICM+ICM->OUTRICM
		EndIf   	
		DbSkip()
	EndDo  
	//
	If (lTotaliza)
		FmtLin({},al[37],,,@nLin)
		FmtLin({"", nTotVlrCont, nTotVlrBC, nTotVlrImp, nTotVlrIsen, nTotVlrOut},al[38],,,@nLin)
		FmtLin({},al[39],,,@nLin)
	EndIf
Return
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ Reg0130  ≥ Autor ≥ Eduardo Ju            ≥ Data ≥ 15.08.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Registro de Movimentacao de Saidas                         ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function Reg0130(nLinPag)
	Local cTipo       := ""
	Local nLin        := 0
	Local cCod_FisOp  := ""	
	Local nVal_ctabil := 0
	Local nVal_BasCalc:= 0
	Local nVal_Imposto:= 0
	Local nVal_OpIsent:= 0
	Local nVal_OutraOP:= 0
	Local nVal_CalcST := 0
	Local nVal_Retido := 0 
	Local lImprime    := .F.
	Local	nTotVlrCont	:=	0
	Local	nTotVlrBC	:=	0
	Local	nTotVlrImp	:=	0
	Local	nTotVlrIsen	:=	0
	Local	nTotVlrOut	:=	0 
	Local 	nTotVlrCST	:= 	0
	Local	nTotVlrRet	:=	0
	Local	aL := R915LayOut()
	Local	lTotaliza	:=	.F.
	//
	cTipo := ""
	//
	DbSelectArea("ICM")
	SetRegua(LastRec())
	DbGoTop() 
	While !Eof() 
		If Interrupcao(@lEnd)
			Loop
		Endif 
		If Substr(CFOP,1,1) >= "5" 
			lImprime    := .T.
			cTipo       := "0130"
			cCod_FisOp  := ICM->CFOP
			nVal_ctabil := ICM->VALCONT
			nVal_BasCalc:= ICM->BASEICM
			nVal_Imposto:= ICM->VALICM
			nVal_OpIsent:= ICM->ISENICM
			nVal_OutraOP:= ICM->OUTRICM
			If mv_par20==1 // Apresenta valores de ST
				nVal_CalcST := ICM->BASERET
				nVal_Retido := ICM->ICMSRET
			Endif
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Rotina de Impressao do Registro 0130                         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			IncRegua()
			//
			If (nLin == 0 .And. lImprime) .Or. (nLin>=nLinPag)
				If nLin>=nLinPag				
					FmtLin({},al[49],,,@nLin)
					nLin := 2
				EndIf
				R915Cabec(aL,@nLin,@nPagina,cTipo)
			Endif                  
			//

			FmtLin({cCod_FisOp,nVal_ctabil,nVal_BasCalc,nVal_Imposto,nVal_OpIsent,nVal_OutraOP,nVal_CalcST,nVal_Retido},al[48],,,@nLin)

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Totalizando variaveis.≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			nTotVlrCont	+=	nVal_ctabil
			nTotVlrBC	+=	nVal_BasCalc
			nTotVlrImp	+=	nVal_Imposto
			nTotVlrIsen	+=	nVal_OpIsent
			nTotVlrOut	+=	nVal_OutraOP
			nTotVlrCST	+=	nVal_CalcST
			nTotVlrRet	+=	nVal_Retido             
			
			lTotaliza	:=	.T.
		    //
			nTotReg += 1
			nSomaVal+= ICM->VALCONT+ICM->BASEICM+ICM->VALICM+ICM->ISENICM+ICM->OUTRICM
		EndIf		
		dbskip()
	EndDo
	//
	If (lTotaliza)
		FmtLin({},al[47],,,@nLin)
		FmtLin({"", nTotVlrCont, nTotVlrBC, nTotVlrImp, nTotVlrIsen, nTotVlrOut, nTotVlrCST, nTotVlrRet},al[48],,,@nLin)
		FmtLin({},al[49],,,@nLin)
	EndIf
Return
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ RegApur  ≥ Autor ≥ Eduardo Ju            ≥ Data ≥ 15.08.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Registro de Movimentacao de Outros Debitos                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function RegApur(nLinPag)
	Local cTipo       := ""
	Local nLin        := 0
	Local cSeq_Ocorr  := ""
	Local nVal_OutDeb := 0
	Local nVal_EstCrd := 0
	Local nVal_OutCrd := 0
	Local nVal_EstDeb := 0
	Local nVal_Deducao:= 0
	Local cDesc_Compl := ""
	Local lImprime    := .F.
	Local	aL := R915LayOut()
	Local	nTotVlr	:=	0
	Local	lCabec	:=	.T.
	// 
	cTipo := ""
	//
	DbSelectArea("PUR")
	SetRegua(LastRec())
	DbGoTop() 
	//
	While !Eof()
		If Interrupcao(@lEnd)
			Loop
		Endif 
		If PUR->CODIGO == "002" .And. Alltrim(PUR->SUBCOD) == "002.00" .And. PUR->VALOR > 0			
			lImprime    := .T.
			cTipo:= "0140"
			cSeq_Ocorr  := Alltrim(StrTran(PUR->SUBCOD,".",""))
			nVal_OutDeb := PUR->VALOR
			cDesc_Compl := PUR->DESCR
			//
			If (lCabec)
				R915Cabec(aL,@nLin,@nPagina,cTipo)
				lCabec	:=	.F.
			EndIf
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Rotina de Impressao do Registro 0140                         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			IncRegua()
			//
			If nLin>=nLinPag .And. lImprime
		   		If (nLin>=nLinPag)
					FmtLin({},al[59],,,@nLin)	
					nLin := 2
		   		EndIf
				R915Cabec(aL,@nLin,@nPagina,cTipo)
			Endif                  
			//			
			FmtLin({cSeq_Ocorr,nVal_OutDeb,cDesc_Compl},al[58],,,@nLin)
			//	
			nTotReg += 1
			nSomaVal+= PUR->VALOR
			nTotVlr+= PUR->VALOR
		EndIf		
		dbskip()
	EndDo
	//
	If (lImprime)
		FmtLin({},al[57],,,@nLin)
		FmtLin({"", nTotVlr, ""},al[58],,,@nLin)
		FmtLin({},al[59],,,@nLin)	
	EndIf
	//
	nTotVlr		:=	0
	lImprime	:=	.F.
	cTipo   	:= ""
	lCabec		:=	.T.
	//
	DbSelectArea("PUR")
	SetRegua(LastRec())
	DbGoTop() 
	While !Eof()
		If Interrupcao(@lEnd)
			Loop
		Endif 
		If PUR->CODIGO == "003" .And. Alltrim(PUR->SUBCOD) == "003.00" .And. PUR->VALOR > 0
			lImprime	:=	.T.
			cTipo      := "0150"
			cSeq_Ocorr := Alltrim(StrTran(PUR->SUBCOD,".",""))
			nVal_EstCrd:= PUR->VALOR
			cDesc_Compl:= PUR->DESCR
			//
			If (lCabec)
				FmtLin({},aL[61],,,@nLin)
				FmtLin({},aL[62],,,@nLin)
				FmtLIn({},al[63],,,@nLin)
				FmtLIn({},al[64],,,@nLin)
				FmtLIn({},al[65],,,@nLin)
				FmtLIn({},al[66],,,@nLin)
				FmtLIn({},al[67],,,@nLin)
				lCabec	:=	.F.
			EndIf
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Rotina de Impressao do Registro 0150                         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			IncRegua()
			//
			If nLin>=nLinPag .And. lImprime
		   		If (nLin>=nLinPag)
					FmtLin({},al[69],,,@nLin)	
					nLin := 2
		   		EndIf
				FmtLin({},aL[61],,,@nLin)
				FmtLin({},aL[62],,,@nLin)
				FmtLIn({},al[63],,,@nLin)
				FmtLIn({},al[64],,,@nLin)
				FmtLIn({},al[65],,,@nLin)
				FmtLIn({},al[66],,,@nLin)
				FmtLIn({},al[67],,,@nLin)                  
			EndIf
			//
			FmtLin({cSeq_Ocorr,nVal_EstCrd,cDesc_Compl},al[68],,,@nLin) 
			//
			nTotReg += 1
			nSomaVal+= PUR->VALOR		
			nTotVlr	+=	PUR->VALOR
		EndIf		
		dbskip()
	EndDo
	//
	If (lImprime)
		FmtLin({},al[67],,,@nLin)
		FmtLin({"", nTotVlr, ""},al[68],,,@nLin)
		FmtLin({},al[69],,,@nLin)	
	EndIf
	//
	nTotVlr		:=	0
	lImprime	:=	.F.
	cTipo 		:= ""
	lCabec		:=	.T.
	//
	DbSelectArea("PUR")
	SetRegua(LastRec())
	DbGoTop() 
	While !Eof()
		If Interrupcao(@lEnd)
			Loop
		Endif 
		If PUR->CODIGO == "006" .And. Alltrim(PUR->SUBCOD) <> "006.00" .And. PUR->VALOR > 0
			lImprime	:=	.T.
			cTipo      := "0160"
			cSeq_Ocorr := Alltrim(StrTran(PUR->SUBCOD,".",""))
			nVal_OutCrd:= PUR->VALOR
			cDesc_Compl:= PUR->DESCR
			//
			If (lCabec)
				FmtLin({},aL[71],,,@nLin)
				FmtLin({},aL[72],,,@nLin)
				FmtLIn({},al[73],,,@nLin)
				FmtLIn({},al[74],,,@nLin)
				FmtLIn({},al[75],,,@nLin)
				FmtLIn({},al[76],,,@nLin)
				FmtLIn({},al[77],,,@nLin)
				lCabec	:=	.F.
			EndIf
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Rotina de Impressao do Registro 0160                         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			IncRegua()
			//
			If nLin>=nLinPag .And. lImprime	
		   		If (nLin>=nLinPag)
					FmtLin({},al[79],,,@nLin)	
					nLin := 2
		   		EndIf
				FmtLin({},aL[71],,,@nLin)
				FmtLin({},aL[72],,,@nLin)
				FmtLIn({},al[73],,,@nLin)
				FmtLIn({},al[74],,,@nLin)
				FmtLIn({},al[75],,,@nLin)
				FmtLIn({},al[76],,,@nLin)
				FmtLIn({},al[77],,,@nLin)
			EndIf
			//
			FmtLin({cSeq_Ocorr,nVal_OutCrd,cDesc_Compl},al[78],,,@nLin)
			//
			nTotReg += 1
			nSomaVal+= PUR->VALOR 
			nTotVlr	+= PUR->VALOR 
		EndIf		
		dbskip()
	EndDo
	//
	If (lImprime)
		FmtLin({},al[77],,,@nLin)
		FmtLin({"", nTotVlr, ""},al[78],,,@nLin)
		FmtLin({},al[79],,,@nLin)	
	EndIf
	//
	nTotVlr		:=	0
	lImprime	:=	.F.
	cTipo 		:= ""
	lCabec		:=	.T.
	//
	DbSelectArea("PUR")
	SetRegua(LastRec())
	DbGoTop() 
	While !Eof()
		If Interrupcao(@lEnd)
			Loop
		Endif 
		If PUR->CODIGO == "007" .And. Alltrim(PUR->SUBCOD) == "007.00" .And. PUR->VALOR > 0
			cTipo      	:= "0170"
			cSeq_Ocorr 	:= Alltrim(StrTran(PUR->SUBCOD,".",""))
			nVal_EstDeb	:= PUR->VALOR
			cDesc_Compl	:= PUR->DESCR
			lImprime	:=	.T.
			//
			If (lCabec)
				FmtLin({},aL[81],,,@nLin)
				FmtLin({},aL[82],,,@nLin)
				FmtLIn({},al[83],,,@nLin)
				FmtLIn({},al[84],,,@nLin)
				FmtLIn({},al[85],,,@nLin)
				FmtLIn({},al[86],,,@nLin)
				FmtLIn({},al[87],,,@nLin)
				lCabec	:=	.F.
			EndIf
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Rotina de Impressao do Registro 0170                         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			IncRegua()
			//
			If nLin>=nLinPag .And. lImprime	
		   		If (nLin>=nLinPag)
					FmtLin({},al[89],,,@nLin)	
					nLin := 2
		   		EndIf
				FmtLin({},aL[81],,,@nLin)
				FmtLin({},aL[82],,,@nLin)
				FmtLIn({},al[83],,,@nLin)
				FmtLIn({},al[84],,,@nLin)
				FmtLIn({},al[85],,,@nLin)
				FmtLIn({},al[86],,,@nLin)
				FmtLIn({},al[87],,,@nLin)        
			EndIf
			//
			FmtLin({cSeq_Ocorr,nVal_EstDeb,cDesc_Compl},al[88],,,@nLin) 
			//
			nTotReg += 1
			nSomaVal+= PUR->VALOR
			nTotVlr	+= PUR->VALOR
		EndIf		
		dbskip()
	EndDo 
	//
	If (lImprime)
		FmtLin({},al[87],,,@nLin)
		FmtLin({"", nTotVlr, ""},al[88],,,@nLin)
		FmtLin({},al[89],,,@nLin)	
	EndIf
	//
	nTotVlr		:=	0
	lImprime	:=	.F.
	cTipo 		:= ""
	lCabec		:=	.T.
	//
	DbSelectArea("PUR")
	SetRegua(LastRec())
	DbGoTop() 
	While !Eof()
	
		If Interrupcao(@lEnd)
			Loop
		Endif
		
		// Mesma regra de codigos do GIARJ.INI para geracao do tipo de ocorrencia "0180" no arquivo magnetico.
		// Gerar os lancamentos detalhados, conforme a apuraÁ„o de ICMS, e nao apenas o valor total de deducoes.
		 
		If PUR->CODIGO == "012" .And. Alltrim(PUR->SUBCOD) <> "012.00" .And. Alltrim(PUR->SUBCOD) <> "012.30" .And. PUR->VALOR > 0
			cTipo       := "0180"
			cSeq_Ocorr  := Alltrim(StrTran(PUR->SUBCOD,".",""))
			nVal_Deducao:= PUR->VALOR
			cDesc_Compl := PUR->DESCR
			lImprime	:=	.T.
			//
			If (lCabec)
				FmtLin({},aL[91],,,@nLin)
				FmtLin({},aL[92],,,@nLin)
				FmtLIn({},al[93],,,@nLin)
				FmtLIn({},al[94],,,@nLin)
				FmtLIn({},al[95],,,@nLin)
				FmtLIn({},al[96],,,@nLin)
				FmtLIn({},al[97],,,@nLin)
				lCabec	:=	.F.
			EndIf
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Rotina de Impressao do Registro 0180                         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			IncRegua()
			//
			If nLin>=nLinPag .And. lImprime	
		   		If (nLin>=nLinPag)
					FmtLin({},al[99],,,@nLin)	
					nLin := 2
		   		EndIf
				FmtLin({},aL[91],,,@nLin)
				FmtLin({},aL[92],,,@nLin)
				FmtLIn({},al[93],,,@nLin)
				FmtLIn({},al[94],,,@nLin)
				FmtLIn({},al[95],,,@nLin)
				FmtLIn({},al[96],,,@nLin)
				FmtLIn({},al[97],,,@nLin)
			EndIf
			//
			FmtLin({cSeq_Ocorr,nVal_Deducao,cDesc_Compl},al[98],,,@nLin) 
			//
			nTotReg += 1
			nSomaVal+= PUR->VALOR
			nTotVlr	+= PUR->VALOR
		EndIf	
			
		dbskip()
		
	EndDo
	
	If (lImprime)
		FmtLin({},al[97],,,@nLin)
		FmtLin({"", nTotVlr, ""},al[98],,,@nLin)
		FmtLin({},al[99],,,@nLin)	
	EndIf
Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ Reg0190  ≥ Autor ≥ Eduardo Ju            ≥ Data ≥ 15.08.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Registro de Movimentacao de Operacoes com Prazo Especial   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function Reg0190(nLinPag)
	Local cTipo       := ""
	Local nLin        := 0
	Local cSeq_Ocorr  := ""
	Local nVal_PrzEsp := 0
	Local cDesc_Compl := ""	
	Local lImprime    := .F.
	Local	nTotVlr	:=	0
	//
	cTipo := ""
	//
	DbSelectArea("PUR")
	SetRegua(LastRec())
	DbGoTop() 
	//
	While !Eof()
		If Interrupcao(@lEnd)
			Loop
		Endif 
		If PUR->CODIGO == "0000"
			lImprime   := .T.
			cTipo      := "0190"
			cSeq_Ocorr := Alltrim(StrTran(PUR->SUBCOD,".",""))
			nVal_PrzEsp:= PUR->VALOR
			cDesc_Compl:= PUR->DESCR
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Rotina de Impressao do Registro 0190                         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			IncRegua()
			//	
			If (nLin==0 .And. lImprime) .Or. (nLin>=nLinPag)
		   		If (nLin>=nLinPag)
					FmtLin({},al[109],,,@nLin)	
					nLin := 2
		   		EndIf
				R915Cabec(aL,@nLin,@nPagina,cTipo)
			Endif                  
			//
			FmtLin({cSeq_Ocorr,nVal_PrzEsp,cDesc_Compl},al[108],,,@nLin) 
			 //
			nTotReg += 1
			nSomaVal+= PUR->VALOR
			nTotVlr	+= PUR->VALOR
		EndIf		
		dbskip()
	EndDo
	//
	If (lImprime)
		FmtLin({},al[107],,,@nLin)
		FmtLin({"", nTotVlr, ""},al[108],,,@nLin)
		FmtLin({},al[109],,,@nLin)	
	EndIf
Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ Reg0200  ≥ Autor ≥ Eduardo Ju            ≥ Data ≥ 15.08.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Registro de Movimentacao de Outros ICMS devido             ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function Reg0200(nLinPag)
	Local cTipo       := ""
	Local nLin        := 0
	Local cSeq_Ocorr  := ""
	Local nVal_Lanc   := 0
	Local cDesc_Compl := ""	
	Local lImprime    := .F.
	Local	aL := R915LayOut()
	Local	nTotVlr	:=	0
	//
	cTipo := ""
	//
	DbSelectArea("PUR")
	SetRegua(LastRec())
	DbGoTop() 
	While !Eof()
		If Interrupcao(@lEnd)
			Loop
		Endif 
		//If (AllTrim (PUR->CODIGO)$"/019/020/" .OR.;
		If	((ALLTRIM(PUR->CODIGO)=="012" .And. Alltrim(StrTran(PUR->SUBCOD,".",""))=="01201") .OR.;
			(Alltrim(PUR->CODIGO)=="900" .And. Alltrim(StrTran(PUR->SUBCOD,".","")) $ "00169#00170#00207#00208#00209#00210#00274") .Or.;
			 ("DIFAL"$UPPER(ALLTRIM(PUR->DESCR)))) .And. PUR->VALOR > 0
			 
			lImprime   := .T.
			cTipo      := "0200"
			cSeq_Ocorr := Alltrim(StrTran(PUR->SUBCOD,".",""))
			nVal_Lanc  := PUR->VALOR
			cDesc_Compl:= AllTrim(PUR->DESCR)
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Rotina de Impressao do Registro 0200                         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			IncRegua()
			//
			If (nLin==0 .And. lImprime) .Or. (nLin>=nLinPag)
		   		If (nLin>=nLinPag)
					FmtLin({},al[119],,,@nLin)	
					nLin := 2
		   		EndIf
				R915Cabec(aL,@nLin,@nPagina,cTipo)
			Endif                  
			//
			FmtLin({cSeq_Ocorr,nVal_Lanc,cDesc_Compl},al[118],,,@nLin) 
		    //
			nTotReg += 1
			nSomaVal+= PUR->VALOR
			nTotVlr	+=	PUR->VALOR
		EndIf		
		dbskip()
	EndDo
	//
	If (lImprime)
		FmtLin({},al[117],,,@nLin)
		FmtLin({"", nTotVlr, ""},al[118],,,@nLin)
		FmtLin({},al[119],,,@nLin)	
	EndIf
Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ Reg0210  ≥ Autor ≥ Eduardo Ju            ≥ Data ≥ 15.08.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Registro de Movimentacao de Entradas Interestaduais        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function Reg0210(nLinPag)
	Local cTipo       := ""
	Local nLin        := 0
	Local cCod_UF     := ""
	Local nVal_ctabil := 0
	Local nVal_BasCalc:= 0
	Local nVal_OutraOP:= 0
	Local nVal_OutProd:= 0
	Local lImprime    := .F.
	Local	aL := R915LayOut()
	Local	nTotCont	:=	0
	Local	nTotBC		:=	0
	Local	nTotOut		:=	0
	Local	nTotOutP	:=	0
	Local	nTotVlr	:=	0
	Local   aDados		:=	{}
	Local	nDados		:=	0
	Local	nI			:=	0
	//
	cTipo := ""
	//
	DbSelectArea("ICM")
	SetRegua(LastRec())
	DbGoTop()
	While !Eof() 
		If Interrupcao(@lEnd)
			Loop
		Endif 
		If Subs(ICM->CFOP,1,1) == "2"
			lImprime    := .T.
			cTipo       := "0210"
			cCod_UF     := ICM->UF
			nVal_ctabil := ICM->VALCONT
			nVal_BasCalc:= ICM->BASEICM
			nVal_OutraOP:= ICM->OUTRICM + ICM->ISENICM 
			nVal_OutProd:= ICM->ICMSRET
			//
			nTotCont	+=	ICM->VALCONT
			nTotBC		+=	ICM->BASEICM
			nTotOut		+=	ICM->OUTRICM + ICM->ISENICM 
			nTotOutP	+=	ICM->ICMSRET
			
						
			nDados	:= ascan(aDados,{|x| x[1]=cCod_UF})
			If nDados == 0
				aAdd(aDados,{cCod_UF,nVal_ctabil,nVal_BasCalc,nVal_OutraOP,nVal_OutProd})
			Else	
			   aDados[nDados][2]+=nVal_ctabil
			   aDados[nDados][3]+=nVal_BasCalc
			   aDados[nDados][4]+=nVal_OutraOP
			   aDados[nDados][5]+=nVal_OutProd
			EndIf

			nTotReg += 1
			nSomaVal+= ICM->VALCONT+ICM->BASEICM+ICM->OUTRICM+ICM->ICMSRET+ICM->ISENICM
			nTotVlr	+=	ICM->VALCONT+ICM->BASEICM+ICM->OUTRICM+ICM->ICMSRET+ICM->ISENICM
		EndIf
		DbSkip()
	EndDo
			
	For nI:=1 to len(aDados)
		If Interrupcao(@lEnd)
			Loop
		Endif 
		
		IncRegua()
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Rotina de Impressao do Registro 0210                         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			//
			If (nLin == 0 .And. lImprime) .Or. (nLin>=nLinPag)
		   		If (nLin>=nLinPag)
					FmtLin({},al[129],,,@nLin)	
					nLin := 2
	   			EndIf
				R915Cabec(aL,@nLin,@nPagina,cTipo)
			Endif                  
		//
		FmtLin(adados[nI],al[128],,,@nLin)
	Next nI
	
	//
	If (lImprime)
		FmtLin({},al[127],,,@nLin)
		FmtLin({"", nTotCont, nTotBC, nTotOut, nTotOutP},al[128],,,@nLin)
		FmtLin({},al[129],,,@nLin)	
	EndIf
Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ Reg0220  ≥ Autor ≥ Eduardo Ju            ≥ Data ≥ 15.08.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Registro de Movimentacao de Saidas Interestaduais          ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function Reg0220(nLinPag)
	Local 	cTipo        := ""
	Local 	nLin         := 0
	Local 	cCod_UF      := ""
	Local 	nValCtaNcont := 0
	Local 	nValCtaContr := 0
	Local 	nValBasNcont := 0
	Local 	nValBasContr := 0
	Local 	nVal_OutraOP := 0
	Local 	nVal_ImpST   := 0 
	Local 	_aTotal      := {}
	Local 	lImprime     := .F.
	Local	aL := R915LayOut()
	Local	nTotCtaN	:=	0
	Local	nTotCta		:=	0
	Local	nTotBNC		:=	0
	Local	nTotBC		:=	0
	Local	nTotOut		:=	0
	Local	nTotSt		:=	0
	Local	aDados		:=	{}
	Local	nDados		:=	0
	Local	nI			:=	0
	Local   lContrib    := .T.
	//
	cTipo := ""
	//
	DbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	DbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	DbSelectArea("SF3")
	SF3->(dbSetOrder(1))
	//
	_aTotal := {"SF3",""}
	FsQuery(_aTotal,1,"F3_FILIAL='"+xFilial("SF3")+"' And F3_EMISSAO>='"+Dtos(dDtIni)+"' And F3_EMISSAO<='"+Dtos(dDtFim)+"' And F3_DTCANC='' And F3_CODISS='' And F3_TIPO<>'S' And F3_OBSERV NOT IN ('CANCELAD')","F3_FILIAL=='"+ xFilial("SF3") +"' .and. DTOS(F3_EMISSAO)>='"+ DTOS(dDtIni) +"' .and. DTOS(F3_EMISSAO)<='"+ DTOS(dDtFim) +"' .And. Empty(F3_DTCANC) .And. Empty(F3_CODISS) .And. F3_TIPO<>'S' .And. !'CANCELAD'$F3_OBSERV",SF3->(IndexKey()))
	//
	SetRegua(LastRec())             
	SF3->(DbGoTop())
	//
	While !Eof()
		If Interrupcao(@lEnd)
			Loop
	   	Endif  
		If Subs(SF3->F3_CFO,1,1)=="6"
			If SF3->F3_TIPO$"DB"
				SA2->(MsSeek(xFilial("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA)) 
			Else
				SA1->(MsSeek(xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
			EndIf	
			//
	        lImprime :=(SF3->F3_TIPO$"DB",Empty(SA2->A2_CODMUN),Empty(SA1->A1_SUFRAMA))
	        //
	        If lImprime
				cTipo        := "0220"
				cCod_UF      := SF3->F3_ESTADO

				If SF3->F3_TIPO$"DB" //Caso seja DevoluÁ„o ou Beneficiamento, dever„o ser observados o cadastro de Fornecedor
					If SA2->A2_CONTRIB == "1"
						lContrib := .T.
					ElseIf SA2->A2_CONTRIB == "2"
						lContrib := .F.
					ElseIf LEFT(AllTrim(SA2->A2_INSCR),1) $ "1234567890"  //Caso o campo A2_CONTRIB esteja em branco, ser· observado se a IE est· preenchida.
						lContrib := .T.
					Else
						lContrib := .F.
					EndIf
				Else
					If SA1->A1_CONTRIB == "1"
						lContrib := .T.
					ElseIf SA1->A1_CONTRIB == "2"
						lContrib := .F.
					ElseIf LEFT(AllTrim(SA1->A1_INSCR),1) $ "1234567890"  //Caso o campo A1_CONTRIB esteja em branco, ser· observado se a IE est· preenchida.
						lContrib := .T.
					Else
						lContrib := .F.
					EndIf
				EndIf

				nValCtaNcont := IIF(lContrib,0				,SF3->F3_VALCONT)
				nValCtaContr := IIF(lContrib,SF3->F3_VALCONT,0)
				nValBasNcont := IIF(lContrib,0				,SF3->F3_BASEICM)
				nValBasContr := IIF(lContrib,SF3->F3_BASEICM,0)
				nVal_OutraOP := ( SF3->F3_OUTRICM  + SF3->F3_ISENICM )
				nVal_ImpST   := SF3->F3_ICMSRET
				//
				nTotCtaN	+=	nValCtaNcont
				nTotCta		+=	nValCtaContr
				nTotBNC		+=	nValBasNcont
				nTotBC		+=	nValBasContr
				nTotOut		+=	nVal_OutraOP
				nTotSt		+=	nVal_ImpST
			   	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			   	//≥ Rotina de Impressao do Registro 0220                         ≥
			   	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			    IncRegua()
				//		
			   	If (nLin == 0 .And. lImprime) .Or. (nLin>=nLinPag)
			   		If (nLin>=nLinPag)
						FmtLin({},al[139],,,@nLin)	
						nLin := 2
			   		EndIf
					R915Cabec(aL,@nLin,@nPagina,cTipo)
			   	Endif                  
				nDados	:= ascan(aDados,{|x| x[1]=cCod_UF})
				If nDados == 0
					aAdd(aDados,{cCod_UF,nValCtaNcont,nValCtaContr,nValBasNcont,nValBasContr,nVal_OutraOP,nVal_ImpST})
				Else	
				   aDados[nDados][2]+=nValCtaNcont
				   aDados[nDados][3]+=nValCtaContr
				   aDados[nDados][4]+=nValBasNcont
				   aDados[nDados][5]+=nValBasContr
				   aDados[nDados][6]+=nVal_OutraOP
				   aDados[nDados][7]+=nVal_ImpST
				EndIf            	
			   	nTotReg += 1
			   	nSomaVal+= SF3->F3_VALCONT+SF3->F3_BASEICM+SF3->F3_OUTRICM+SF3->F3_ICMSRET             
			Endif	   	
		EndIf   	
		DbSkip() 
	EndDo
	
	For nI:=1 to len(aDados)
	    IncRegua()
		//		
	   	If (nLin == 0 .And. lImprime) .Or. (nLin>=nLinPag)
	   		If (nLin>=nLinPag)
				FmtLin({},al[139],,,@nLin)	
				nLin := 2
	   		EndIf
				R915Cabec(aL,@nLin,@nPagina,cTipo)
	   	Endif  
		//
	  	FmtLin(aDados[nI],al[138],,,@nLin)
	Next nI 
		//
	
	//
	If (lImprime)
		FmtLin({},al[137],,,@nLin)
		FmtLin({"", nTotCtaN, nTotCta, nTotBNC, nTotBC, nTotOut, nTotSt}, al[138],,,@nLin) 
		FmtLin({},al[139],,,@nLin)	
	EndIf   
	//
	FsQuery(_aTotal,2)
Return
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ Reg0230  ≥ Autor ≥ Eduardo Ju            ≥ Data ≥ 15.08.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Registro de Movimentacao de Saidas para ZFM/ALC            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function Reg0230(nLinPag)
	Local cTipo       := ""
	Local nLin        := 0
	Local cCod_Local  := ""
	Local cNum_SerNF  := ""
	Local cNum_SubNF  := ""
	Local cNum_NF     := ""
	Local cDt_Emiss   := ""
	Local nVal_NF     := 0
	Local nVal_Isenta := 0
	Local cCNPJ       := ""
	Local cInsc_SUFRAM:= ""
	Local _aTotal     := {}
	Local lImprime    := .F.
	Local	aL := R915LayOut()
	Local	nTotValCont	:=	0
	Local	nTotIsenta	:=	0
	//
	cTipo := ""
	//
	DbSelectArea("SX5")
	SX5->(dbSetOrder(1)) 
	DbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	DbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	DbSelectArea("SF3")
	SF3->(dbSetOrder(1))
	//
	_aTotal := {"SF3",""}
	FsQuery(_aTotal,1,"F3_FILIAL='"+xFilial("SF3")+"' And F3_EMISSAO>='"+Dtos(dDtIni)+"' And F3_EMISSAO<='"+Dtos(dDtFim)+"'","F3_FILIAL=='"+ xFilial("SF3") +"' .and. DTOS(F3_EMISSAO)>='"+ DTOS(dDtIni) +"' .and. DTOS(F3_EMISSAO)<='"+ DTOS(dDtFim) +"'",SF3->(IndexKey()))
	//
	SetRegua(LastRec())
	SF3->(DbGoTop())
	While !Eof() 
		If Interrupcao(@lEnd)
			Loop
	   	Endif 
		If Subs(SF3->F3_CFO,1,1)=="6"
			If SF3->F3_TIPO$"DB"
				SA2->(MsSeek(xFilial("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA)) 
			Else
				SA1->(MsSeek(xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
			EndIf        
			//
			lImprime := (SF3->F3_TIPO$"DB",!Empty(SA2->A2_CODLOC),!Empty(SA1->A1_CODLOC)) .And. (SF3->F3_TIPO$"DB",!Empty(SA2->A2_CODMUN),!Empty(SA1->A1_SUFRAMA))
			//
			If lImprime
				SX5->(MsSeek(xFilial("SX5")+"AB"+IIf(SF3->F3_TIPO$"DB",Subs(SA2->A2_CODLOC,5,4),Subs(SA1->A1_CODLOC,5,4))))
				cTipo       := "0230"
				cCod_Local  := SUBS(SX5->X5_DESCRI,1,8)
				cNum_SerNF  := SerieNfId("SF3",2,"F3_SERIE")
				cNum_SubNF  := Space(002)
				cNum_NF     := SF3->F3_NFISCAL
				cDt_Emiss   := Dtos(SF3->F3_EMISSAO)+StrTran(Time(),":","")
				nVal_NF     := SF3->F3_VALCONT
				nVal_Isenta := SF3->F3_ISENICM
				cCNPJ       := Iif(SF3->F3_TIPO$"DB",SA2->A2_CGC,SA1->A1_CGC)
				cInsc_SUFRAM:= Iif(SF3->F3_TIPO$"DB",SPACE(09),SA1->A1_SUFRAMA)
				//
				nTotValCont+=	SF3->F3_VALCONT
				nTotIsenta +=	SF3->F3_ISENICM
			   	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			   	//≥ Rotina de Impressao do Registro 0230                         ≥
			   	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			   	IncRegua()
				//
			   	If (nLin == 0 .And. lImprime) .Or. (nLin>=nLinPag)
			   		If (nLin>=nLinPag)
						FmtLin({},al[149],,,@nLin)	
						nLin := 2
			   		EndIf
				   R915Cabec(aL,@nLin,@nPagina,cTipo)
			   	Endif                  
				//
			   	FmtLin({cCod_Local,cNum_SerNF,cNum_SubNF,cNum_NF,cDt_Emiss,nVal_NF,nVal_Isenta,cInsc_SUFRAM,cCNPJ},al[148],,,@nLin) 
				//
			    nTotReg += 1
			    nSomaVal+= SF3->F3_VALCONT+SF3->F3_ISENICM
			Endif   
		EndIf   	
		DbSkip()
	EndDo
	//
	If (lImprime)
		FmtLin({},al[147],,,@nLin)
		FmtLin({"", "", "", "", "", nTotValCont, nTotIsenta, "", ""},al[148],,,@nLin) 
		FmtLin({},al[149],,,@nLin)	
	EndIf   
	//	
	FsQuery(_aTotal,2)
	SF3->(DbGoTop())
Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ Reg0240  ≥ Autor ≥ Eduardo Ju            ≥ Data ≥ 15.08.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Registro de Movimentacao de SCE Compensado entre           ≥±±
±±≥          ≥ Estabelecimentos                                           ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function Reg0240(nLinPag)
	Local cTipo       := ""
	Local nLin        := 0
	Local cSeq_Ocorr  := ""
	Local cObs_SCE    := ""
	Local cNum_Inscr  := ""      
	Local cNum_SerNF  := ""
	Local cNum_SubNF  := ""
	Local cNum_NF     := ""
	Local nVal_Compen := 0
	Local lImprime    := .F.
	Local	aL := R915LayOut()
	Local	nTotValCont	:=	0
	//		
	cTipo := ""
	DbSelectArea("ICM")
	SetRegua(LastRec())
	DbGoTop()
	//
	While !Eof() 
		If Interrupcao(@lEnd)
			Loop
		Endif 
		If Subs(SF3->F3_CFO,1,1)== ""
			lImprime    := .T.
			cTipo       := "0240"
			cSeq_Ocorr  := Alltrim(StrTran(PUR->SUBCOD,".",""))
			cObs_SCE    := Space(10) //Space(100)
			cNum_Inscr  := SA1->A1_INSCR      
			cNum_SerNF  := SerieNfId("SF3",2,"F3_SERIE")
			cNum_SubNF  := Space(002)
			cNum_NF     := SF3->F3_NFISCAL
			nVal_Compen := SF3->F3_VALCONT
			//
			nTotValCont	+=	SF3->F3_VALCONT
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Rotina de Impressao do Registro 0240                         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			IncRegua()
			//
			If (nLin == 0 .And. lImprime) .Or. (nLin>=nLinPag)
		   		If (nLin>=nLinPag)
					FmtLin({},al[159],,,@nLin)	
					nLin := 2
		   		EndIf
				R915Cabec(aL,@nLin,@nPagina,cTipo)
			Endif                  
			//
			FmtLin({cSeq_Ocorr,cObs_SCE,cNum_Inscr,cNum_SerNF,cNum_SubNF,cNum_NF,nVal_Compen},al[158],,,@nLin) 
			//
			nTotReg += 1
			nSomaVal+= SF3->F3_VALCONT
		EndIf   	
		DbSkip()
	EndDo
	//
	If (lImprime)
		FmtLin({},al[157],,,@nLin)
		FmtLin({"", "", "", "", "", "", nTotValCont},al[158],,,@nLin) 
		FmtLin({},al[159],,,@nLin)	
	EndIf   
Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ Reg0250  ≥ Autor ≥ Eduardo Ju            ≥ Data ≥ 15.08.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Registro de Movimentacao de SCE Compensado do Proprio      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function Reg0250(nLinPag)
	Local cTipo       := ""
	Local nLin        := 0
	Local cSeq_Ocorr  := ""
	Local cObs        := ""
	Local nVal_Compen := 0
	Local lImprime    := .F.
	Local	aL := R915LayOut()
	Local	nTotValCont	:=	0
	//
	cTipo := ""
	DbSelectArea("ICM")
	SetRegua(LastRec())
	DbGoTop()
	While !Eof() 
		If Interrupcao(@lEnd)
			Loop
		Endif 
		If Subs(SF3->F3_CFO,1,1)== ""
	 		lImprime    := .T.
			cTipo       := "0250"
			cSeq_Ocorr  := Alltrim(StrTran(PUR->SUBCOD,".",""))
			cObs        := Space(10)
			nVal_Compen := ICM->VALCONT	
			//
			nTotValCont	+=	ICM->VALCONT	
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Rotina de Impressao do Registro 0250                         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			IncRegua()
			//			
			If (nLin == 0 .And. lImprime) .Or. (nLin>=nLinPag)
		   		If (nLin>=nLinPag)
					FmtLin({},al[169],,,@nLin)	
					nLin := 2
		   		EndIf
				R915Cabec(aL,@nLin,@nPagina,cTipo)
			Endif                  
			//
			FmtLin({cSeq_Ocorr,cObs,nVal_Compen},al[168],,,@nLin) 
			//
			nTotReg += 1
			nSomaVal+= ICM->VALCONT
		EndIf   	
		DbSkip()
	EndDo
	//
	If (lImprime)
		FmtLin({},al[167],,,@nLin)
		FmtLin({"", "", nTotValCont},al[168],,,@nLin) 
		FmtLin({},al[169],,,@nLin)	
	EndIf  
Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ Reg0260  ≥ Autor ≥ Eduardo Ju            ≥ Data ≥ 15.08.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Registro de Movimentacao de SCE Compensado do Proprio      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function Reg0260(nLinPag)
	Local cTipo       := ""
	Local nLin        := 0
	Local cSeq_Ocorr  := ""
	Local cObs        := ""
	Local nNum_Inscr  := 0      
	Local cNum_SerNF  := ""
	Local cNum_SubNF  := ""
	Local cNum_NF     := ""
	Local cPref_Proc  := ""
	Local nNum_Proc   := 0
	Local nAno_Proc   := 0
	Local nVal_SaldRec:= 0 
	Local lImprime    := .F.
	Local 	aL := R915LayOut()
	Local	nTotValCont	:=	0
	//
	cTipo := ""
	//
	DbSelectArea("ICM")
	SetRegua(LastRec())
	DbGoTop()
	While !Eof() 
		If Interrupcao(@lEnd)
			Loop
		Endif 
		If Subs(SF3->F3_CFO,1,1)== ""
			lImprime    := .T.
			cTipo       :="0260"
			cSeq_Ocorr  := Alltrim(StrTran(PUR->SUBCOD,".",""))
			cObs        := Space(10)//Space(100)
			nNum_Inscr  := 0      
			cNum_SerNF  := ICM->&(SerieNfId("SF3",3,"F3_SERIE")) 
			cNum_SubNF  := Space(002)
			cNum_NF     := ICM->F3_NFISCAL
			cPref_Proc  := "E-04"
			nNum_Proc   := 0
			nAno_Proc   := 0
			nVal_SaldRec:= ICM->VALCONT 
			//
			nTotValCont	+=	ICM->VALCONT 
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Rotina de Impressao do Registro 0260                         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			IncRegua()
			//
			If (nLin == 0 .And. lImprime) .Or. (nLin>=nLinPag)
		   		If (nLin>=nLinPag)
					FmtLin({},al[179],,,@nLin)	
					nLin := 2
		   		EndIf
				R915Cabec(aL,@nLin,@nPagina,cTipo)
			Endif                  
			//
			FmtLin({cSeq_Ocorr,cObs,nNum_Inscr,cNum_SerNF,cNum_SubNF,cNum_NF,cPref_Proc,nNum_Proc,nAno_Proc,nVal_SaldRec},al[178],,,@nLin) 
			//
			nTotReg += 1
			nSomaVal+= ICM->VALCONT
		EndIf   	
		DbSkip()
	EndDo
	//
	If (lImprime)
		FmtLin({},al[177],,,@nLin)
		FmtLin({"", "", "", "", "", "", "", "", "", nTotValCont},al[178],,,@nLin) 
		FmtLin({},al[179],,,@nLin)	
	EndIf 
Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ Reg0270  ≥ Autor ≥ Eduardo Ju            ≥ Data ≥ 15.08.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Registro de Movimentacao de SCE Transferido                ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function Reg0270(nLinPag)
	Local cTipo       := ""
	Local nLin        := 0
	Local cSeq_Ocorr  := ""
	Local cSeq_OcorDes:= 0
	Local cObs        := ""
	Local cNum_SerNF  := ""
	Local cNum_SubNF  := ""
	Local cNum_NF     := ""
	Local cPref_Proc  := ""
	Local nNum_Proc   := 0
	Local nAno_Proc   := 0
	Local nVal_Transf := 0
	Local lImprime    := .F.
	Local	aL := R915LayOut()
	Local	nTotValCont	:=	0
	//
	cTipo := ""
	//
	DbSelectArea("ICM")
	SetRegua(LastRec())
	DbGoTop()
	While !Eof() 
		If Interrupcao(@lEnd)
			Loop
		Endif
		If Subs(SF3->F3_CFO,1,1)== ""
			lImprime    := .T.
			cTipo :="0270"
			cSeq_Ocorr  := Alltrim(StrTran(PUR->SUBCOD,".",""))
			cSeq_OcorDes:= "0"
			cObs        := Space(10) //Space(100) 
			cNum_SerNF  := ICM->&(SerieNfId("SF3",3,"F3_SERIE"))
			cNum_SubNF  := Space(002)
			cNum_NF     := ICM->F3_NFISCAL
			cPref_Proc  := "E-04"
			nNum_Proc   := 0
			nAno_Proc   := 0
			nVal_Transf := ICM->VALCONT
	        //
	        nTotValCont	+=	ICM->VALCONT
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Rotina de Impressao do Registro 0270                         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			IncRegua()
			//
			If (nLin == 0 .And. lImprime) .Or. (nLin>=nLinPag)
		   		If (nLin>=nLinPag)
					FmtLin({},al[189],,,@nLin)	
					nLin := 2
		   		EndIf
				R915Cabec(aL,@nLin,@nPagina,cTipo)
			Endif                  
			//
			FmtLin({cSeq_Ocorr,cSeq_OcorDes,cObs,cNum_SerNF,cNum_SubNF,cNum_NF,cPref_Proc,nNum_Proc,nAno_Proc,nVal_Transf},al[188],,,@nLin) 
			//
			nTotReg += 1
			nSomaVal+= ICM->VALCONT
		EndIf   	
		DbSkip()
	EndDo 
	//
	If (lImprime)
		FmtLin({},al[187],,,@nLin)
		FmtLin({"", "", "", "", "", "", "", "", "", nTotValCont},al[188],,,@nLin) 
		FmtLin({},al[189],,,@nLin)	
	EndIf 
Return
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ R915LayOut   ≥Autor ≥ Eduardo Ju           ≥Data≥ 05.08.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Armazena LayOut da Listagem de Conferencia da GiaRJ        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ MATR915                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function R915LayOut()
	Local	aL	:=	Array (198)
						//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
						// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	al[01] := STR0008 	//"                      						 Listagem de Conferencia da Gia - RJ       								   Pag.: #### "
	al[02] := STR0009 	//"                                                                               													  "
	al[03] := STR0010 	//"+---------------------------------------------------------------------------------------------------------------------------------+"
	al[04] := STR0011 	//"≥Registro: 0110 ≥Registro Identificador da Declaracao                        													 ≥"
	al[05] := STR0012 	//"+---------------------------------------------------------------------------------------------------------------------------------+"
	al[06] := STR0013 	//"+---------------------------------------------------------------------------------------------------------------------------------+"
	al[07] := STR0014 	//"≥Inscricao Estadual:                 ########                                                                                     ≥"
	al[08] := STR0015 	//"≥Ano de Referencia:                  ####																						 ≥"
	al[09] := STR0016 	//"≥Mes de Referencia:                  ##																							 ≥"
	al[10] := STR0017 	//"≥Indicador de Retificadora:          #                                                                                            ≥"
	al[11] := STR0018 	//"≥Nome do Representante Legal:        ################################################################							 ≥"
	al[12] := STR0019  	//"≥DDD do Representante Legal:         ####																						 ≥"
	al[13] := STR0020  	//"≥Telefone do Representante Legal:    ########																					 ≥"
	al[14] := STR0021  	//"≥Nome do Contabilista:				################################################################							 ≥"
	al[15] := STR0022	//"≥Correio Eletronico:					########################################													 ≥"
	al[16] := STR0023  	//"≥DDD do Contabilista:                ####                                           												 ≥"
	al[17] := STR0024  	//"≥Telefone do Contabilista:			########                                                                                     ≥"
	al[18] := STR0025 	//"≥Valor do Saldo Anterior:			###############                                      										 ≥"
	al[19] := STR0026	//"≥Valor do Saldo Anterior ST:			###############																				 ≥"
	al[20] := STR0027	//"≥Observacao:							##########################################################################################	 ≥"
	al[21] := STR0028  	//"≥Observacao ST:						##########################################################################################	 ≥"
	al[22] := STR0029 	//"≥Valor do Saldo Anterior SCE:		###############																				 ≥"
	al[23] := STR0030	//"|Valor do Credito de Energia SCE:    ###############                                                                              |"      
	al[24] := STR0031	//"≥Valor do Estorno de Provisao SCE:	###############																				 ≥"
	al[25] := STR0032	//"≥Valor de Provisao SCE:				###############                                                                              ≥"
	al[26] := STR0033  	//"≥Ind. Mov. Operacoes Proprias:       #                                                                                            ≥"
	al[27] := STR0034	//"≥Ind. Mov. Substituicao Tributaria:  #                                                                                            ≥"
	al[28] := STR0035	//"≥Ind. Mov. Outros ICMS:              #                                                                                          	 ≥"
	al[29] := STR0036	//"≥Ind. Mov. ALC/ZFM:	                #                                                                                          	 ≥"
	al[30] := STR0037	//"+---------------------------------------------------------------------------------------------------------------------------------+"
	al[31] := STR0038	//"+---------------------------------------------------------------------------------------------------------------------------------+"
	al[32] := STR0039 	//"≥Registro: 0120 ≥Registro de Movimentacao de Entradas                        												     ≥"
	al[33] := STR0040 	//"+---------------------------------------------------------------------------------------------------------------------------------+"
	al[34] := STR0041 	//"+------------------------------------------------------------------------------------------+"
  	al[35] := STR0042  	//"|CFOP |     Valor      ≥ Valor da Base  ≥   Valor  do    ≥  Valor de Op.  ≥ Valor de Outras≥"
  	al[36] := STR0043  	//"≥     ≥    Contabil    ≥  de  Calculo   ≥    Imposto	    ≥    Isentas	 ≥	  Operacoes	  ≥"
  	al[37] := STR0044 	//"+-----+----------------+----------------+----------------+----------------+----------------+"
  	al[38] := STR0045  	//"≥#### ≥############### ≥############### ≥############### ≥############### ≥############### ≥" 
   	al[39] := STR0046 	//"+------------------------------------------------------------------------------------------+"    
   	al[40] := STR0047 	//"                                                                               													  "
   	al[41] := STR0048	//"+---------------------------------------------------------------------------------------------------------------------------------+"
	al[42] := STR0049 	//"≥Registro: 0130 ≥Registro de Movimentacao de Saidas                        													 	 ≥"
	al[43] := STR0050 	//"+---------------------------------------------------------------------------------------------------------------------------------+"
	al[44] := STR0051 	//"+---------------------------------------------------------------------------------------------------------------------------------+"
  	al[45] := STR0052  	//"≥CFOP ≥     Valor      ≥ Valor da Base  ≥   Valor  do    ≥  Valor de Op.  ≥ Valor de Outras≥ Valor da Base  ≥ Valor do Imposto    ≥"
  	al[46] := STR0053  	//"≥     ≥    Contabil    ≥  de  Calculo   ≥    Imposto	    ≥    Isentas	 ≥	  Operacoes	  ≥ de Calculo ST  ≥    Retido ST		 ≥"
  	al[47] := STR0054 	//"+-----+----------------+----------------+----------------+----------------+----------------+----------------+---------------------+"
  	al[48] := STR0055  	//"≥#### ≥############### ≥############### ≥############### ≥############### ≥############### ≥############### ≥###############      ≥ 
   	al[49] := STR0056 	//"+---------------------------------------------------------------------------------------------------------------------------------+"
   	al[50] := STR0057 	//"                                                                               													  "
	al[51] := STR0058	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[52] := STR0059 	//"≥Registro: 0140 ≥Registro de Movimentacao de Outros Debitos              													 	 													  	≥"
	al[53] := STR0060 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[54] := STR0061 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[55] := STR0062  	//"≥Sequencial da ≥    Valor de    ≥ Descricao    																					                                                        ≥"
  	al[56] := STR0063  	//"≥ Ocorrencia   ≥  Outro Debito  ≥ Complementar 																					                                                        ≥"   
  	al[57] := STR0064 	//"+--------------+----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------+"
  	al[58] := STR0065  	//"≥	#####     ≥############### ≥######################################################################################################################################################  ≥"
   	al[59] := STR0066 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
   	al[60] := STR0067 	//"                                                                               													                                                         "
	al[61] := STR0068	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[62] := STR0069 	//"≥Registro: 0150 ≥Registro de Movimentacao de Estornos Credito              													 	 													  	≥"
	al[63] := STR0070 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[64] := STR0071 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[65] := STR0072  	//"≥Sequencial da ≥    Valor de    ≥ Descricao    																					                                                        ≥"
  	al[66] := STR0073  	//"≥ Ocorrencia   ≥Estorno Credito ≥ Complementar 																					                                                        ≥"   
  	al[67] := STR0074 	//"+--------------+----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------+"
  	al[68] := STR0075  	//"≥	#####     ≥############### ≥######################################################################################################################################################  ≥"
   	al[69] := STR0076 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[70] := STR0077 	//"                                                                               													                                                         "
   	al[71] := STR0078  	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[72] := STR0079 	//"≥Registro: 0160 ≥Registro de Movimentacao de Outros Creditos              													 	 													  	≥"
	al[73] := STR0080 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[74] := STR0081 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[75] := STR0082  	//"≥Sequencial da ≥   Valor de     ≥ Descricao    																					                                                        ≥"
  	al[76] := STR0083  	//"≥ Ocorrencia   ≥ Outro Credito  ≥ Complementar 																					                                                        ≥"   
  	al[77] := STR0084 	//"+--------------+----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------+"
  	al[78] := STR0085  	//"≥	#####     ≥############### ≥######################################################################################################################################################  ≥"
   	al[79] := STR0086 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[80] := STR0087 	//"                                                                               													                                                         "
	al[81] := STR0088 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[82] := STR0089 	//"≥Registro: 0170 ≥Registro de Movimentacao de Estornos Debito              													 	 													  	≥"
	al[83] := STR0090 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[84] := STR0091 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[85] := STR0092  	//"≥Sequencial da ≥   Valor de     ≥ Descricao    																					                                                        ≥"
  	al[86] := STR0093  	//"≥ Ocorrencia   ≥Estorno Debito  ≥ Complementar 																					                                                        ≥"   
  	al[87] := STR0094 	//"+--------------+----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------+"
  	al[88] := STR0095  	//"≥	#####     ≥############### ≥######################################################################################################################################################  ≥"
   	al[89] := STR0096 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[90] := STR0097 	//"                                                                               													                                                         "
	al[91] := STR0098 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[92] := STR0099 	//"≥Registro: 0180 ≥Registro de Movimentacao de Deducoes              													 	 													  	        ≥"
	al[93] := STR0100 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[94] := STR0101 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[95] := STR0102  	//"≥Sequencial da ≥   Valor de     ≥ Descricao    																					                                                        ≥"
  	al[96] := STR0103  	//"≥ Ocorrencia   ≥    Deducao     ≥ Complementar 																					                                                        ≥"   
  	al[97] := STR0104 	//"+--------------+----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------+"
  	al[98] := STR0105  	//"≥	#####     ≥############### ≥######################################################################################################################################################  ≥"
   	al[99] := STR0106 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[100]:= STR0107 	//"                                                                               													                                                         "
   	al[101]:= STR0108 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[102]:= STR0109 	//"≥Registro: 0190 ≥Registro de Movimentacao de Operacoes com Prazo Especial              													 	 										    ≥"
	al[103]:= STR0110 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[104]:= STR0111 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[105]:= STR0112  	//"≥Sequencial da ≥    Valor de    ≥ Descricao    																					                                                        ≥"
  	al[106]:= STR0113  	//"≥ Ocorrencia   ≥ Prazo Especial ≥ Complementar 																					                                                        ≥"   
  	al[107]:= STR0114 	//"+--------------+----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------+"
  	al[108]:= STR0115  	//"≥	#####     ≥############### ≥######################################################################################################################################################  ≥"
   	al[109]:= STR0116 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[110]:= STR0117 	//"                                                                               													                                                         "
 	al[111]:= STR0118	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[112]:= STR0119 	//"≥Registro: 0200 ≥Registro de Movimentacao de Outros ICMS devido              													 	 										            ≥"
	al[113]:= STR0120 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[114]:= STR0121 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[115]:= STR0122  	//"≥Sequencial da ≥    Valor de    ≥ Descricao    																					                                                        ≥"
  	al[116]:= STR0123  	//"≥ Ocorrencia   ≥   Lancamento   ≥ Complementar 																					                                                        ≥"   
  	al[117]:= STR0124 	//"+--------------+----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------+"
  	al[118]:= STR0125  	//"|   #####      |################|########################################################################################################################################################|"
   	al[119]:= STR0126 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[120]:= STR0127 	//"                                                                               													                                                         "
	al[121]:= STR0128 	//"+-------------------------------------------------------------------------+"
	al[122]:= STR0129 	//"≥Registro: 0210 ≥Registro de Movimentacao de Entradas Interestaduais      ≥"
	al[123]:= STR0130 	//"+-------------------------------------------------------------------------+"
	al[124]:= STR0131 	//"+-------------------------------------------------------------------------+"
  	al[125]:= STR0132  	//"≥ UF  ≥     Valor      ≥ Valor da Base  ≥Valor de Outras ≥Valor de Outros ≥"
  	al[126]:= STR0133  	//"≥     ≥    Contabil    ≥  de  Calculo   ≥   Operacoes    ≥   Produtos     ≥"
  	al[127]:= STR0134 	//"+-----+----------------+----------------+----------------+----------------+"
  	al[128]:= STR0135  	//"≥ ### |############### ≥############### ≥############### ≥############### ≥ 
   	al[129]:= STR0136 	//"+-------------------------------------------------------------------------+"          
   	al[130]:= STR0137  	//"																			  "	
	al[131]:= STR0138	//"+-----------------------------------------------------------------------------------------------------------+"
	al[132]:= STR0139 	//"≥Registro: 0220 ≥Registro de Movimentacao de Saidas Interestaduais                        				   ≥"
	al[133]:= STR0140 	//"+-----------------------------------------------------------------------------------------------------------+"
	al[134]:= STR0141 	//"+-----------------------------------------------------------------------------------------------------------+"
  	al[135]:= STR0142 	//"≥ UF  ≥ Valor Contabil ≥ Valor Contabil ≥Valor Base Calc.≥Valor Base Calc.≥ Valor de Outras≥Valor do Imposto≥"
  	al[136]:= STR0143 	//"≥     ≥Nao Contribuinte≥  Contribuinte  ≥Nao Contribuinte≥ Contribuinte	 ≥	  Operacoes	  ≥   Cobrado ST   ≥"
  	al[137]:= STR0144 	//"+-----+----------------+----------------+----------------+----------------+----------------+----------------+"
  	al[138]:= STR0145 	//"≥ ### ≥############### ≥############### ≥############### ≥############### ≥############### ≥############### ≥ 
   	al[139]:= STR0146 	//"+-----------------------------------------------------------------------------------------------------------+"
   	al[140]:= STR0147 	//"                                                                               							    "	 
	al[141]:= STR0148	//"+---------------------------------------------------------------------------------------------------------------------------------+"
	al[142]:= STR0149 	//"≥Registro: 0230 ≥Registro de Movimentacao de Saidas para ZFM/ALC                        											 ≥"
	al[143]:= STR0150 	//"+---------------------------------------------------------------------------------------------------------------------------------+"
	al[144]:= STR0151 	//"+---------------------------------------------------------------------------------------------------------------------------------+"
  	al[145]:= STR0152  	//"≥Codigo da ≥Serie ≥ Subserie ≥ Numero ≥   Data de     ≥ Valor da Nota  ≥   Valor de     ≥  Numero do    ≥    Numero de Inscr. 	 ≥"
  	al[146]:= STR0153  	//"≥Localidade≥da NF ≥  da NF   ≥ da NF  ≥   Emissao	 ≥	  Fiscal	  ≥   Isentas      ≥    CNPJ       ≥       Suframa           ≥"		
	al[147]:= STR0154	//"+----------+------+----------+--------+---------------+----------------+----------------+---------------+-------------------------+"
  	al[148]:= STR0155  	//"≥ ######## ≥ ###  ≥   ##     ≥ ###### ≥############## ≥############### ≥############### ≥############## ≥     ############        ≥"
   	al[149]:= STR0156 	//"+---------------------------------------------------------------------------------------------------------------------------------+"
   	al[150]:= STR0157 	//"                                                                               													  "
	al[151]:= STR0158	//"+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[152]:= STR0159 	//"≥Registro: 0240 ≥Registro de Movimentacao de SCE Compensado entre Estabelecimentos                        						                                          ≥"
	al[153]:= STR0160 	//"+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[154]:= STR0161 	//"+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[155]:= STR0162  	//"≥Sequencial da ≥Observacao                                                                                           ≥Numero de ≥Serie ≥ Subserie≥ Numero ≥     Valor   	  ≥"                                                                                                                
  	al[156]:= STR0163  	//"≥ Ocorrencia   ≥                                                                                               		≥Inscricao ≥da NF ≥  da NF  ≥ da NF  ≥   Compensado   ≥"   
  	al[157]:= STR0164 	//"+--------------+-----------------------------------------------------------------------------------------------------+----------+------+---------+--------+----------------+"
  	al[158]:= STR0165  	//"≥	#####     ≥#################################################################################################### ≥ ######## ≥ ###  ≥   ##    ≥ ###### ≥ ###############≥"
   	al[159]:= STR0166 	//"+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
   	al[160]:= STR0167 	//"                                                                               													                                           "
   	al[161]:= STR0168	//"+------------------------------------------------------------------------------------------------------------------------------------+"
	al[162]:= STR0169 	//"≥Registro: 0250 ≥Registro de Movimentacao de SCE Compensado do Proprio             													≥"
	al[163]:= STR0170 	//"+------------------------------------------------------------------------------------------------------------------------------------+"
	al[164]:= STR0171 	//"+------------------------------------------------------------------------------------------------------------------------------------+"
	al[165]:= STR0172  	//"≥Sequencial da ≥Observacao 																		                   ≥     Valor      ≥"
  	al[166]:= STR0173  	//"≥ Ocorrencia   ≥                                                                                                    ≥   Compensado   ≥"   
  	al[167]:= STR0174 	//"+--------------+----------------------------------------------------------------------------------------------------+----------------+"
  	al[168]:= STR0175  	//"≥	#####     ≥####################################################################################################≥############### ≥"
   	al[169]:= STR0176 	//"+------------------------------------------------------------------------------------------------------------------------------------+"
	al[170]:= STR0177 	//"                                                                               													     "
 	al[171]:= STR0178 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[172]:= STR0179 	//"≥Registro: 0260 ≥Registro de Movimentacao de SCE Recebido                        						                                                                                                              ≥"
	al[173]:= STR0180 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[174]:= STR0181 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[175]:= STR0182  	//"≥Sequencial da ≥Observacao                                                                                           ≥Numero de ≥Serie ≥ Subserie≥ Numero ≥Cod. Prefixo≥    Numero do       ≥Ano do   ≥  Valor         ≥"                                                                                                                
  	al[176]:= STR0183  	//"≥ Ocorrencia   ≥                                                                                               		≥Inscricao ≥da NF ≥  da NF  ≥ da NF  ≥do Processo ≥    Processo        ≥Processo ≥  Compensado    ≥"   
  	al[177]:= STR0184 	//"+--------------+-----------------------------------------------------------------------------------------------------+----------+------+---------+--------+------------+--------------------+---------+----------------+"
  	al[178]:= STR0185  	//"≥	#####     ≥#################################################################################################### ≥ ######## ≥ ###  ≥   ##    ≥ ###### ≥ ########## ≥####################≥ ####    ≥############### ≥"
   	al[179]:= STR0186 	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
   	al[180]:= STR0187 	//"                                                                               													                                                                                       "  
	al[181]:= STR0188	//"+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[182]:= STR0189 	//"≥Registro: 0270 ≥Registro de Movimentacao de SCE Transferido                        						                                                                                                                 ≥"
	al[183]:= STR0190 	//"+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[184]:= STR0191 	//"+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	al[185]:= STR0192  	//"≥ Seq. da  ≥Seq.Ocor.≥Observacao                                                                                          ≥Numero de ≥Serie ≥Subserie ≥ Numero ≥Cod. Prefixo≥    Numero do       ≥Ano do  ≥ Valor do Saldo≥"                                                                                                                
  	al[186]:= STR0193  	//"≥Ocorrencia≥Destino  ≥                                                                                               	 ≥Inscricao ≥da NF ≥ da NF   ≥ da NF  ≥do Processo ≥    Processo        ≥Processo≥  Transferido  ≥"   
  	al[187]:= STR0194 	//"+----------+---------+----------------------------------------------------------------------------------------------------+----------+------+---------+--------+------------+--------------------+--------+---------------+"
  	al[188]:= STR0195  	//"≥   #####  ≥ #####   ≥####################################################################################################≥ ######## ≥ ###  ≥  ##     ≥ ###### ≥ ########## ≥####################≥ ####   ≥###############≥"
   	al[189]:= STR0196 	//"+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
   	al[190]:= STR0197 	//"                                                                               													                                                                                          "    
	al[191]:= STR0198	//"+---------------------------------------------------------------------------------------------------------------------------------+"
	al[192]:= STR0199 	//"≥Registro: 9999 ≥Registro Trailler do Arquivo                      										 						 ≥"
	al[193]:= STR0200 	//"+---------------------------------------------------------------------------------------------------------------------------------+"
	al[194]:= STR0201 	//"+---------------------------------------------------------------------------------------------------------------------------------+"
	al[195]:= STR0202  	//"≥Somatorio dos Valores Informados:	#########################                                                                    ≥"
	al[196]:= STR0203  	//"≥Total de Declaracoes:				#####                                                                                        ≥"
	al[197]:= STR0204  	//"≥Total de Registros:   				#####                                                                                        ≥"
	al[198]:= STR0205  	//"+---------------------------------------------------------------------------------------------------------------------------------+"
Return (aL)

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ R915Cabec    ≥Autor ≥ Eduardo Ju           ≥Data≥ 05.08.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Imprime cabecalho do relatorio                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ MATR915                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function R915Cabec(aL,nLin,nPagina,cTipo)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Imprime caracter de controle de largura de impressao         ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
nLin:=0
@ nLin++,0 Psay AvalImp(220)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Imprime cabecalho do relatorio                               ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
    //Titulo do relatorio
	FmtLin({Transform(nPagina++,"@R 9999")},aL[01],,,@nLin)  
	FmtLin({},aL[02],,,@nLin)
	
	If cTipo == "0110"	//Registro 0110
		FmtLin({},aL[03],,,@nLin)
		FmtLin({},aL[04],,,@nLin)
		FmtLin({},al[05],,,@nLin)
		FmtLin({},al[06],,,@nLin)
	EndIf
	
	If cTipo == "0120"	//Registro 0120
		FmtLin({},aL[31],,,@nLin)
		FmtLin({},aL[32],,,@nLin)
		FmtLin({},al[33],,,@nLin)
		FmtLin({},al[34],,,@nLin)
		FmtLin({},al[35],,,@nLin)
		FmtLin({},al[36],,,@nLin)
		FmtLin({},al[37],,,@nLin)
	EndIf
		
	If cTipo == "0130"	//Registro 0130
		FmtLin({},aL[41],,,@nLin)
		FmtLin({},aL[42],,,@nLin)
		FmtLIn({},al[43],,,@nLin)
		FmtLIn({},al[44],,,@nLin)
		FmtLIn({},al[45],,,@nLin)
		FmtLIn({},al[46],,,@nLin)
		FmtLIn({},al[47],,,@nLin)
	EndIf
		
	If cTipo == "0140"	//Registro RegApur
		FmtLin({},aL[51],,,@nLin)
		FmtLin({},aL[52],,,@nLin)
		FmtLIn({},al[53],,,@nLin)
		FmtLIn({},al[54],,,@nLin)
		FmtLIn({},al[55],,,@nLin)
		FmtLIn({},al[56],,,@nLin)
		FmtLIn({},al[57],,,@nLin)
	EndIf
		
	If cTipo == "0190"	//Registro 0190
		FmtLin({},aL[101],,,@nLin)
		FmtLin({},aL[102],,,@nLin)
		FmtLIn({},al[103],,,@nLin)
		FmtLIn({},al[104],,,@nLin)
		FmtLIn({},al[105],,,@nLin)
		FmtLIn({},al[106],,,@nLin)
		FmtLIn({},al[107],,,@nLin)
	EndIf
	
	If cTipo == "0200"	//Registro 0200
		FmtLin({},aL[111],,,@nLin)
		FmtLin({},aL[112],,,@nLin)
		FmtLIn({},al[113],,,@nLin)
		FmtLIn({},al[114],,,@nLin)
		FmtLIn({},al[115],,,@nLin)
		FmtLIn({},al[116],,,@nLin)
		FmtLIn({},al[117],,,@nLin)
	EndIf	
	
	If cTipo == "0210"	//Registro 0210
		FmtLin({},aL[121],,,@nLin)
		FmtLin({},aL[122],,,@nLin)
		FmtLIn({},al[123],,,@nLin)
		FmtLIn({},al[124],,,@nLin)
		FmtLIn({},al[125],,,@nLin)
		FmtLIn({},al[126],,,@nLin)
		FmtLIn({},al[127],,,@nLin)
	EndIf
		
	If cTipo == "0220"	//Registro 0220
		FmtLin({},aL[131],,,@nLin)
		FmtLin({},aL[132],,,@nLin)
		FmtLin({},al[133],,,@nLin)
		FmtLin({},al[134],,,@nLin)
		FmtLin({},al[135],,,@nLin)
		FmtLin({},al[136],,,@nLin)
		FmtLin({},al[137],,,@nLin)
	EndIf	
	
	If cTipo == "0230"	//Registro 0230
		FmtLin({},aL[141],,,@nLin)
		FmtLin({},aL[142],,,@nLin)
		FmtLin({},al[143],,,@nLin)
		FmtLin({},al[144],,,@nLin)
		FmtLin({},al[145],,,@nLin)
		FmtLin({},al[146],,,@nLin)
		FmtLin({},al[147],,,@nLin)
	EndIf	 
	
	If cTipo == "0240"	//Registro 0240
		FmtLin({},aL[151],,,@nLin)
		FmtLin({},aL[152],,,@nLin)
		FmtLIn({},al[153],,,@nLin)
		FmtLIn({},al[154],,,@nLin)
		FmtLIn({},al[155],,,@nLin)
		FmtLIn({},al[156],,,@nLin)
		FmtLIn({},al[157],,,@nLin)
	EndIf	
	
	If cTipo == "0250"	//Registro 0250
		FmtLin({},aL[161],,,@nLin)
		FmtLin({},aL[162],,,@nLin)
		FmtLIn({},al[163],,,@nLin)
		FmtLIn({},al[164],,,@nLin)
		FmtLIn({},al[165],,,@nLin)
		FmtLIn({},al[166],,,@nLin)
		FmtLIn({},al[167],,,@nLin)		
	EndIf	
	
	If cTipo == "0260"	//Registro 0260
		FmtLin({},aL[171],,,@nLin)
		FmtLin({},aL[172],,,@nLin)
		FmtLIn({},al[173],,,@nLin)
		FmtLIn({},al[174],,,@nLin)
		FmtLIn({},al[175],,,@nLin)
		FmtLIn({},al[176],,,@nLin)
		FmtLIn({},al[177],,,@nLin)	
	Endif	  
	
	If cTipo == "0270"	//Registro 0270
		FmtLin({},aL[181],,,@nLin)
		FmtLin({},aL[182],,,@nLin)
		FmtLIn({},al[183],,,@nLin)
		FmtLIn({},al[184],,,@nLin)                
		
		FmtLIn({},al[185],,,@nLin)
		FmtLIn({},al[186],,,@nLin)
		FmtLIn({},al[187],,,@nLin)	
	EndIf
		
	If cTipo == "9999"	//Registro 9999
		FmtLin({},aL[191],,,@nLin)
		FmtLin({},aL[192],,,@nLin)
		FmtLIn({},al[193],,,@nLin)
		FmtLIn({},al[194],,,@nLin) 
	EndIf
	
Return (nil)
