#INCLUDE "FISR003.CH"
#INCLUDE "Protheus.ch"
#include "FiveWin.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FISR003   ºAutor  ³Mary C. Hergert     º Data ³ 17/07/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio Auxiliar para preenchimento da DMD - BA          º±±
±±º          ³ Bahia - Declaracao da Movimentacao de Produtos com ICMS    º±±
±±º          ³ Diferido.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FISR003

Local Titulo    := OemToAnsi(STR0001)  // "DMD -Declaração da Movimentação de ICMS Diferido - Bahia"
Local cDesc1    := OemToAnsi(STR0002)  // "Este relatório emite as informações necessárias "
Local cDesc2    := OemToAnsi(STR0003)  // "para auxiliar o preenchimento do DMD-BA."
Local cDesc3    := ""
Local cDMDB5	:= GetNewPar("MV_DMDB5","")

Local cString	:= "SF3"
Local wnrel     := "FISR003"  			// Nome do Arquivo utilizado no Spool
Local nPagina	:= 1

Local aArea		:= GetArea()
Local lRet		:= .T.
Local lDic      := .F. 					// Habilita/Desabilita Dicionario
Local lComp     := .F. 					// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro   := .F. 					// Habilita/Desabilita o Filtro
Local cMensagem	:= ""
Local cErro		:= ""
Local cSolucao	:= ""
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

//
Private Tamanho := "G"					// P/M/G
Private Limite  := 220 					// 80/132/220
Private cPerg   := "FSR001"				// Pergunta do Relatorio
Private aReturn := {STR0004,1,STR0005,1,2,1,"",1}	//"Zebrado"###"Administracao"
Private lEnd    := .F.					// Controle de cancelamento do relatorio
Private m_pag   := 1  					// Contador de Paginas
Private nLastKey:= 0  					// Controla o cancelamento da SetPrint e SetDefault

If lVerpesssen
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apenas processa o relatorio se o campo na tabela SB5 existir³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cDMDB5)
		
		Pergunte("FISR003",.F.)
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Envia para a SetPrinter                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			wnrel:=SetPrint(cString,wnrel,"FISR003",@Titulo,cDesc1,cDesc2,cDesc3,lDic,"",lComp,Tamanho,lFiltro,.T.)  
			If ( nLastKey==27 )
				dbSelectArea(cString)
				dbSetOrder(1)
				dbClearFilter()
				Return
			Endif
			SetDefault(aReturn,cString)
			If ( nLastKey==27 )
				dbSelectArea(cString)
				dbSetOrder(1)
				dbClearFilter()
				Return
			Endif
			
			RptStatus({|lEnd| ImpDMD(@lEnd,wnrel,cString,Tamanho,nPagina)},Titulo)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Restaura Ambiente                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cString)
			dbClearFilter()
			Set Device To Screen
			Set Printer To
			
			If ( aReturn[5] = 1 )
				dbCommitAll()
				OurSpool(wnrel)
			Endif
			MS_FLUSH()
			
		EndIf

	Else 

		cMensagem 	:= STR0008// "Parâmetro inconsistente"
		cErro 		:= STR0009// "O parâmetro MV_DMDB5 não está definido no dicionário de dados ou "
		cErro 		+= STR0010// "o seu conteúdo é inválido. Este parâmetro deve conter o número "
		cErro 		+= STR0011// "da habilitação do produto diferido, que será a base da emissão "
		cErro 		+= STR0012// "do relatório.Para tanto, será necessário observar "
		cErro 		+= STR0013// "a solução proposta abaixo: "
		cSolucao 	:= STR0014// "Estrutura do parâmetro MV_DMDB5: "
		cSolucao 	+= STR0015// "Parâmetro do tipo caracter, que deve conter o campo da tabela SB5 "
		cSolucao 	+= STR0016// "que contém o número da habilitação para o produto diferido na Sefaz. "
		cSolucao 	+= STR0017// "Exemplo: B5_HABDIF. Para maiores referências, consultar a documentação que acompanha a rotina."
		
		xMagHelpFis(cMensagem,cErro,cSolucao)
		
	Endif
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ImpDMD    ³ Autor ³Mary C. Hergert        ³ Data ³ 17/07/2009     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³ Impressao do Relatorio Auxiliar para preenchimento da DMD - BA   º±±
±±º          ³ Bahia - Declaracao da Movimentacao de Produtos com ICMS          º±±
±±º          ³ Diferido.                                                        º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ FISR003                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                                
Static Function ImpDMD(lEnd,wnRel,cString,Tamanho,nPagina,lAgrupa)

Local lAglutina := Iif(mv_par06 == 1, .T., .F.) //verifica se aglutina pelo grupo da Tabela de Codigos de Produto Diferido
Local aArea		:= GetArea()
Local aLay		:= RDmdLayOut(lAglutina)
Local aProdProc	:= {}  
Local aProcessa	:= {}   
Local aTotal	:= Array(9)

Local cAliasSFT :=	"SFT"
Local cAliasSB1 :=	"SB1"
Local cAliasSB5 :=	"SB5"
Local cIndSF3   :=	""
Local cDMDB5	:= GetNewPar("MV_DMDB5","")
Local cDMDA1	:= GetNewPar("MV_DMDA1","A1_COD_MUN")
Local cDMDA2	:= GetNewPar("MV_DMDA2","A2_COD_MUN")
Local cDMDCod   := "B5_CDDMDBA"
Local cCodMun	:= ""
Local cTes		:= ""

Local lSA1		:= .F.
Local lInscrito := .F.  
Local lProcessa	:= .T.

Local nPos		:= 0
Local nImprime	:= 0
Local nX		:= 0  
Local nLin 		:= 70 

#IFDEF TOP
	Local cCampos	:= ""
	Local cCondicao	:= ""
#ELSE
	Local cArqInd	:= ""
	Local cChave	:= ""
	Local cCondicao	:= ""
	Local lFoundB5	:= .F.
#ENDIF 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para montagem da query com o campo de icms diferido informado no sb5³ 
//³Numero da habilitacao para comercializacao com diferimento          ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP     
	cCondicao 	:= " SB5." + Alltrim(cDMDB5) + " <> '' "       
	cCampos 	:= " ,SB5." + Alltrim(cDMDB5) + " "
	If Alltrim(cDMDCod)<>""
	   cCampos 	:= cCampos + ",SB5." + Alltrim(cDMDCod) + " "
    Endif	
	cCampos 	:= "% " + cCampos + " %"
	cCondicao 	:= "% " + cCondicao + " %" 
	cDtCanc 	:= Space(TamSx3("F3_DTCANC")[01])
#ENDIF

dbSelectArea("SA1")
dbSelectArea("SA2")
dbSelectArea("SB1")
dbSelectArea("SB5")
dbSelectArea("SFT")
dbSelectArea("SD1")
dbSelectArea("SD2")
dbSelectArea("SF4")

SA1->(dbSetOrder(1))
SA2->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SB5->(dbSetOrder(1))
SFT->(dbSetOrder(1))
SD1->(dbSetOrder(1))
SD2->(dbSetOrder(3))
SF4->(dbSetOrder(1))

dbSelectArea("SFT")
SFT->(dbsetorder(1))
	
#IFDEF TOP

    If TcSrvType()<>"AS/400"

		lQuery 		:= .T.
		cAliasSFT	:= GetNextAlias()   
		cAliasSB1	:= cAliasSFT
		cAliasSB5	:= cAliasSFT 
		
		BeginSql Alias cAliasSFT     
		
			COLUMN FT_ENTRADA AS DATE
			COLUMN FT_DTCANC AS DATE
			
			SELECT SFT.FT_FILIAL,SFT.FT_NFISCAL,SFT.FT_SERIE,SFT.FT_ITEM,SFT.FT_ENTRADA,
				SFT.FT_PRODUTO,SFT.FT_TOTAL,SFT.FT_CLIEFOR,SFT.FT_LOJA,
				SFT.FT_CFOP,SFT.FT_QUANT,SFT.FT_TIPO,SB1.B1_UM,SB1.B1_DESC,SB5.B5_COD
				%Exp:cCampos%
			
			FROM %table:SFT% SFT, %table:SB1% SB1, %table:SB5% SB5 
				
			WHERE SFT.FT_FILIAL = %xFilial:SFT% AND 
				SFT.FT_ENTRADA >= %Exp:mv_par01% AND 
				SFT.FT_ENTRADA <= %Exp:mv_par02% AND 
				SFT.FT_PRODUTO >= %Exp:mv_par03% AND
				SFT.FT_PRODUTO <= %Exp:mv_par04% AND
				SFT.FT_DTCANC = %Exp:cDtCanc% AND
				SFT.FT_TIPO NOT IN ('I','P','C') AND
				SUBSTRING(SFT.FT_CFOP,1,1) IN ('1','3','5') AND 
				SFT.%NotDel% AND
				SB1.B1_FILIAL = %xFilial:SB1% AND
				SB1.B1_COD = SFT.FT_PRODUTO AND
				SB1.%NotDel% AND                 
				SB5.B5_FILIAL = %xFilial:SB5% AND
				SB5.B5_COD = SB1.B1_COD AND 
				%Exp:cCondicao%	AND 
				SB5.%NotDel%
					
			ORDER BY SFT.FT_FILIAL,SFT.FT_PRODUTO
		EndSql
	
		dbSelectArea(cAliasSFT)

	Else
	                  
#ENDIF
		cArqInd		:=	CriaTrab(Nil,.F.)
		cChave		:=	'FT_FILIAL+FT_PRODUTO'
		cCondicao 	:= 'FT_FILIAL == "' + xFilial("SFT") + '" .And. ' 
		cCondicao 	+= 'Dtos(FT_ENTRADA) >= "' + Dtos(mv_par01) + '" .And. Dtos(FT_ENTRADA) <= "' + Dtos(mv_par02) + '" .And. '
		cCondicao 	+= 'FT_PRODUTO >= "' + mv_par03 + '" .And. FT_PRODUTO <= "' + mv_par04 + '" .And. '
		cCondicao 	+= '!(FT_TIPO $ "P/I/C") .And. (SubStr(FT_CFOP,1,1) == "1" .Or. SubStr(FT_CFOP,1,1) == "5")'
		IndRegua(cAliasSFT,cArqInd,cChave,,cCondicao,STR0006) // Selecionando registros  
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF                
		(cAliasSFT)->(dbGotop())
		SetRegua(LastRec())				

#IFDEF TOP
	Endif    
#ENDIF

Do While !((cAliasSFT)->(Eof()))

	IncProc(STR0007) //"Processando Relatório"
	
	If Interrupcao(@lEnd)
	    Exit
 	Endif

	If !lQuery
	
		If !(SB1->(MsSeek(xFilial("SB1")+(cAliasSFT)->FT_PRODUTO)))
			(cAliasSFT)->(DbSkip())
			Loop                                          
		Endif

		If !(SB1->B1_COD >= mv_par03 .And. SB1->B1_COD <= mv_par04)
			(cAliasSFT)->(DbSkip())
			Loop
		EndIf         
		
		If !(SB5->(MsSeek(xFilial("SB5")+(cAliasSFT)->FT_PRODUTO)))
			(cAliasSFT)->(DbSkip())
			Loop
		Endif

		If Empty(SB5->&cDMDB5)
			(cAliasSFT)->(DbSkip())
			Loop
		Endif
	
	Endif     
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Identifica se a TES do movimento e para ICMS diferido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Left((cAliasSFT)->FT_CFOP,1) $"1/3"
		If !SD1->(DbSeek(xFilial("SD1")+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_PRODUTO+(cAliasSFT)->FT_ITEM))
			(cAliasSFT)->(DbSkip())
			Loop
		Else
			cTES := SD1->D1_TES
	   	Endif
	Else
	   If !SD2->(DbSeek(xFilial("SD2")+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_PRODUTO+(cAliasSFT)->FT_ITEM))
			(cAliasSFT)->(DbSkip())
			Loop
	   Else                    
	   		cTES := SD2->D2_TES
	   Endif
	Endif    
	If !SF4->(dbSeek(xFilial("SF4")+cTes)) .Or. !(SF4->(F4_ICMSDIF) $ "1/3/4")
		(cAliasSFT)->(DbSkip())
		Loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificando se o cliente/fornecedor sao inscritos ou nao e o³
	//³municipio de origem/destino das mercadorias                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Left((cAliasSFT)->FT_CFOP,1) $ "1/3"
		If (cAliasSFT)->FT_TIPO $ "D/B"
			If !SA1->(dbSeek(xFilial("SA1")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
				(cAliasSFT)->(dbSkip())
				Loop
			Endif
			lSA1 := .T.
		Else
			If !SA2->(dbSeek(xFilial("SA2")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
				(cAliasSFT)->(dbSkip())
				Loop
			Endif
			lSA1 := .F.
		Endif
	Else
		If (cAliasSFT)->FT_TIPO $ "D/B"
			If !SA2->(dbSeek(xFilial("SA2")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
				(cAliasSFT)->(dbSkip())
				Loop
			Endif     
			lSA1 := .F.
		Else
			If !SA1->(dbSeek(xFilial("SA1")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
				(cAliasSFT)->(dbSkip())
				Loop
			Endif     
			lSA1 := .T.
		Endif
	Endif		
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o cliente/fornecedor e inscrito na SEFAZ da Bahia.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSA1
		lInscrito := .T.
		If Empty(SA1->A1_INSCR) .Or. "ISENT"$SA1->A1_INSCR .Or. "RG"$SA1->A1_INSCR .Or. ;
		  	SA1->A1_CONTRIB == "2" .Or.; 			
			(SA1->A1_TIPO == "L")
			lInscrito := .F. 
		Endif
		If !Empty(cDMDA1) 
			cCodMun := (SA1->&cDMDA1)
		Else
			cCodMun := SA1->A1_COD_MUN
		Endif
	Else                
		lInscrito := .T.		
		If Empty(SA2->A2_INSCR) .Or. "ISENT"$SA2->A2_INSCR .Or. "RG"$SA2->A2_INSCR .Or. ;
			SA2->A2_CONTRIB == "2" .Or. ;
			(!Empty(SA2->A2_TIPORUR))
			lInscrito := .F.
		Endif
		If !Empty(cDMDA2)
			cCodMun := (SA2->&cDMDA2)
		Else
			cCodMun := SA2->A2_COD_MUN
		Endif
	Endif 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicoes do array aProcessa:          ³
	//³[01] - Codigo do Produto              ³
	//³[02] - Municipio                      ³
	//³[03] - Qtde Compras Inscrito          ³
	//³[04] - Valor Compras Inscrito         ³
	//³[05] - Quantidade Compras Nao Inscrito³
	//³[06] - Valor Compras Nao Inscrito     ³
	//³[07] - Qtde Vendas Inscrito           ³
	//³[08] - Valor Vendas Inscrito          ³
	//³[09] - Quantidade Vendas Nao Inscrito ³
	//³[10] - Valor Vendas Nao Inscrito      ³
	//³[11] - Codigo Tab.Prod.Diferido       ³  
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     
    If lAglutina 
     	nPos := aScan(aProcessa,{|x| Alltrim(x[11]) == Alltrim((cAliasSB5)->B5_CDDMDBA) .And. Alltrim(x[2]) == Alltrim(cCodMun)}) 
    Else
     	nPos := aScan(aProcessa,{|x| Alltrim(x[1]) == Alltrim((cAliasSFT)->FT_PRODUTO) .And. Alltrim(x[2]) == Alltrim(cCodMun)}) 
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acumula as operacoes de entradas de inscritos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Left((cAliasSFT)->FT_CFOP,1) $ '1/3' .And. lInscrito
		If nPos > 0
			aProcessa[nPos][03] += (cAliasSFT)->FT_QUANT
			aProcessa[nPos][04] += (cAliasSFT)->FT_TOTAL
		Else 
			aAdd(aProcessa,{(cAliasSFT)->FT_PRODUTO,cCodMun,(cAliasSFT)->FT_QUANT,(cAliasSFT)->FT_TOTAL,0,0,0,0,0,0,(cAliasSB5)->B5_CDDMDBA})
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acumula as operacoes de entradas de nao inscritos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Left((cAliasSFT)->FT_CFOP,1) $ '1/3' .And. !lInscrito
		If nPos > 0     
			aProcessa[nPos][05] += (cAliasSFT)->FT_QUANT
			aProcessa[nPos][06] += (cAliasSFT)->FT_TOTAL
		Else 
			aAdd(aProcessa,{(cAliasSFT)->FT_PRODUTO,cCodMun,0,0,(cAliasSFT)->FT_QUANT,(cAliasSFT)->FT_TOTAL,0,0,0,0,(cAliasSB5)->B5_CDDMDBA})
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acumula as operacoes de saidas de inscritos  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Left((cAliasSFT)->FT_CFOP,1) == '5' .And. lInscrito
		If nPos > 0
			aProcessa[nPos][07] += (cAliasSFT)->FT_QUANT
			aProcessa[nPos][08] += (cAliasSFT)->FT_TOTAL
		Else 
			aAdd(aProcessa,{(cAliasSFT)->FT_PRODUTO,cCodMun,0,0,0,0,(cAliasSFT)->FT_QUANT,(cAliasSFT)->FT_TOTAL,0,0,(cAliasSB5)->B5_CDDMDBA})
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acumula as operacoes de saidas de nao inscritos  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Left((cAliasSFT)->FT_CFOP,1) == '5' .And. !lInscrito
		If nPos > 0
			aProcessa[nPos][09] += (cAliasSFT)->FT_QUANT
			aProcessa[nPos][10] += (cAliasSFT)->FT_TOTAL
		Else 
			aAdd(aProcessa,{(cAliasSFT)->FT_PRODUTO,cCodMun,0,0,0,0,0,0,(cAliasSFT)->FT_QUANT,(cAliasSFT)->FT_TOTAL,Iif((cAliasSB5)->(FieldPos("B5_HABDIF"))>0,(cAliasSB5)->B5_HABDIF,"")})
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Armazena os produtos processados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lAglutina
	    If aScan(aProdProc,{|x| Alltrim(x[01]) == Alltrim((cAliasSB5)->B5_CDDMDBA)}) == 0
		   aAdd(aProdProc,{(cAliasSB5)->B5_CDDMDBA,"","",""})
	    Endif
    Else
	    If aScan(aProdProc,{|x| Alltrim(x[1]) == Alltrim((cAliasSFT)->FT_PRODUTO)}) == 0
		   aAdd(aProdProc,{(cAliasSFT)->FT_PRODUTO,(cAliasSB1)->B1_DESC,(cAliasSB1)->B1_UM,(cAliasSB5)->&cDMDB5})
	    Endif
	EndIf
	(cAliasSFT)->(dbSkip())
Enddo    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se deseja processar os produtos sem movimento no periodo.         ³
//³Se sim, seleciona todos os produtos com numero de autorizacao para operacao³
//³com diferimento cadastrados na tabela SB5.                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par05 == 1

	cAliasSB5 := "SB5"
	cAliasSB1 := "SB1"
		
	#IFDEF TOP
	
	    If TcSrvType()<>"AS/400"
	
			lQuery 		:= .T.
			cAliasSB5	:= GetNextAlias()   
			cAliasSB1	:= cAliasSB5
			
			BeginSql Alias cAliasSB1
				SELECT SB5.B5_COD,SB1.B1_UM,SB1.B1_DESC
					%Exp:cCampos%
				
				FROM %table:SB5% SB5, %table:SB1% SB1
					
				WHERE SB5.B5_FILIAL = %xFilial:SB5% AND
					SB5.B5_COD >= %Exp:mv_par03% AND  
					SB5.B5_COD <= %Exp:mv_par04% AND
					%Exp:cCondicao% AND 
					SB5.%NotDel% AND                 
					SB1.B1_FILIAL = %xFilial:SB1% AND
					SB1.B1_COD = SB5.B5_COD AND
					SB1.%NotDel%
						
				ORDER BY SB5.B5_FILIAL,SB5.B5_COD
			EndSql
		
			dbSelectArea(cAliasSB5)
	
		Else
		                  
	#ENDIF
			cArqInd		:=	CriaTrab(Nil,.F.)
			cChave		:=	"B5_FILIAL+B5_COD"
			cCondicao 	:= 'B5_FILIAL == "' + xFilial("SB5") + '" .And. ' 
			cCondicao 	+= 'B5_COD >= "' + mv_par03 + '" .And. B5_COD <= "' + mv_par04 + '" .And. '
			cCondicao 	+= 'B5_COD >= "' + mv_par03 + '" .And. B5_COD <= "' + mv_par04 + '" .And. '
			cCondicao 	+= '!Empty(' + cDMDB5 + ') ' 
			IndRegua(cAliasSB5,cArqInd,cChave,,cCondicao,STR0006) // Selecionando registros  
			#IFNDEF TOP
				DbSetIndex(cArqInd+OrdBagExt())
			#ENDIF                
			(cAliasSB5)->(dbGotop())
			SetRegua(LastRec())				
	
	#IFDEF TOP
		Endif    
	#ENDIF           

	Do While !((cAliasSB5)->(Eof()))
	
		IncProc(STR0007) //"Processando Relatório"
		
		If Interrupcao(@lEnd)
		    Exit
	 	Endif
	
		If !lQuery
		
			If !(SB1->(MsSeek(xFilial("SB1")+(cAliasSB5)->B5_COD)))
				(cAliasSB5)->(DbSkip())
				Loop
			Endif
		Endif     
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Armazena os produtos processados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If lAglutina
		    If aScan(aProdProc,{|x| Alltrim(x[01]) == Alltrim((cAliasSB5)->B5_CDDMDBA)}) == 0
			   aAdd(aProdProc,{(cAliasSB5)->B5_CDDMDBA,"","",""})
		    Endif
        Else
		    If aScan(aProdProc,{|x| Alltrim(x[1]) == Alltrim((cAliasSB5)->B5_COD)}) == 0
			   aAdd(aProdProc,{(cAliasSB5)->B5_COD,(cAliasSB1)->B1_DESC,(cAliasSB1)->B1_UM,(cAliasSB5)->&cDMDB5})
		    Endif
		EndIf
		(cAliasSB5)->(dbSkip())
		
	Enddo
	
Endif	
	
If lAglutina
    aProdProc 	:=	Asort(aProdProc,1,2,{|x,y|Alltrim(x[1])<Alltrim(y[1]) .And. Alltrim(x[2])<Alltrim(y[2])})			
    //aProcessa 	:=	Asort(aProcessa,11,2,{|x,y|Alltrim(x[11])<Alltrim(y[11]) .And. Alltrim(x[2])<Alltrim(y[2])})			
    aProcessa 	:=	Asort(aProcessa,1,2,{|x,y|Alltrim(x[1])<Alltrim(y[1]) .And. Alltrim(x[2])<Alltrim(y[2])})			
Else
    aProdProc 	:=	Asort(aProdProc,1,2,{|x,y|Alltrim(x[1])<Alltrim(y[1]) .And. Alltrim(x[2])<Alltrim(y[2])})			
    aProcessa 	:=	Asort(aProcessa,1,2,{|x,y|Alltrim(x[1])<Alltrim(y[1]) .And. Alltrim(x[2])<Alltrim(y[2])})			
EndIf

SetRegua(Len(aProdProc))	      
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua a impresao das informacoes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nPos := 1 to Len(aProdProc) 
	
	IncRegua(STR0026) //"Imprimindo as informacoes"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime o totalizador quando muda de produto         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPos <> 1 .And. nImprime <> 0

		If nLin > 60   
			If nLin < 70	
				FmtLin(,aLay[19],,,@nLin)
			Endif
			If lAglutina
			    nLin := DMDCabec(aProdProc[nPos][01],"","","",lAglutina)
			Else
			    nLin := DMDCabec(aProdProc[nPos][01],aProdProc[nPos][02],aProdProc[nPos][03],aProdProc[nPos][04],lAglutina)
		    EndIf
		Endif
    
	    FmtLin(,aLay[12],,,@nLin)
	    
	    FmtLin({aTotal[01],;
	    aTotal[02],;
	    aTotal[03],;
	    aTotal[04],;
	    aTotal[05],;
	    aTotal[06],;
	    aTotal[07],;
	    aTotal[08],;
	    aTotal[09]},aLay[18],,,@nLin)
	    
	    FmtLin(,aLay[19],,,@nLin)
	    
	    nLin := 70
	
	Endif 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Encontra o produto a ser impresso no array dos movimentos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lAglutina
	    nImprime 	:= aScan(aProcessa,{|x| Alltrim(x[11]) == Alltrim(aProdProc[nPos][01])}) 
    Else
	    nImprime 	:= aScan(aProcessa,{|x| Alltrim(x[1]) == Alltrim(aProdProc[nPos][01])}) 
	Endif
	lProcessa 	:= .T.

    aTotal[01] := STR0027 //"TOTAL"
    aTotal[02] := 0
    aTotal[03] := 0
    aTotal[04] := 0
    aTotal[05] := 0
    aTotal[06] := 0
    aTotal[07] := 0
    aTotal[08] := 0
    aTotal[09] := 0   
    
	If nLin > 60                  
		If nLin < 70	
			FmtLin(,aLay[19],,,@nLin)
		Endif
		If lAglutina
		    nLin := DMDCabec(aProdProc[nPos][01],"","","",lAglutina)
		Else
		    nLin := DMDCabec(aProdProc[nPos][01],aProdProc[nPos][02],aProdProc[nPos][03],aProdProc[nPos][04],lAglutina)
	    EndIf
	Endif
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime os produtos sem movimento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nImprime == 0
		FmtLin(,aLay[20],,,@nLin)
		FmtLin(,aLay[19],,,@nLin)
		nLin := 70 
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Varre o array de movimentos e imprime todas as ocorrencias a partir da primeira encontrada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    Do While .T.
	        
			If nLin > 60          
				If nLin < 70	
					FmtLin(,aLay[19],,,@nLin)
				Endif
				If lAglutina
				    nLin := DMDCabec(aProdProc[nPos][01],"","","",lAglutina)
				Else
				    nLin := DMDCabec(aProdProc[nPos][01],aProdProc[nPos][02],aProdProc[nPos][03],aProdProc[nPos][04],lAglutina)
			    EndIf
			Endif

	    	If !lProcessa
	    		// Se nao for a primeira vez, procura a proxima ocorrencia no array de movimentos
		        If lAglutina
		    	    nX := aScan(aProcessa,{|x| Alltrim(x[11]) == Alltrim(aProdProc[nPos][01])},nX+1) 
		        Else
		    	    nX := aScan(aProcessa,{|x| Alltrim(x[1]) == Alltrim(aProdProc[nPos][01])},nX+1) 
	    	    EndIf
	    	Else 
	    		nX := nImprime                                                                                
	    		lProcessa := .F.
	    	Endif             

	    	If nX == 0
		    	Exit
		    Endif
				    
		    FmtLin({aProcessa[nX][02],;
		    aProcessa[nX][03],;
		    aProcessa[nX][04],;
		    aProcessa[nX][05],;
		    aProcessa[nX][06],;
		    aProcessa[nX][07],;
		    aProcessa[nX][08],;
		    aProcessa[nX][09],;
		    aProcessa[nX][10]},aLay[18],,,@nLin)
	
		    aTotal[02] += aProcessa[nX][03]
		    aTotal[03] += aProcessa[nX][04]
		    aTotal[04] += aProcessa[nX][05]
		    aTotal[05] += aProcessa[nX][06]
		    aTotal[06] += aProcessa[nX][07]
		    aTotal[07] += aProcessa[nX][08]
		    aTotal[08] += aProcessa[nX][09]
		    aTotal[09] += aProcessa[nX][10]

	    Enddo   
	    
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime o totalizador do ultimo produto com movimento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPos == Len(aProdProc) .And. nImprime <> 0

		If nLin > 60
			If nLin < 70	
				FmtLin(,aLay[19],,,@nLin)
			Endif
			If lAglutina
			    nLin := DMDCabec(aProdProc[nPos][01],"","","",lAglutina)
			Else
			    nLin := DMDCabec(aProdProc[nPos][01],aProdProc[nPos][02],aProdProc[nPos][03],aProdProc[nPos][04],lAglutina)
		    EndIf
		Endif
    
	    FmtLin(,aLay[12],,,@nLin)
	    
	    FmtLin({aTotal[01],;
	    aTotal[02],;
	    aTotal[03],;
	    aTotal[04],;
	    aTotal[05],;
	    aTotal[06],;
	    aTotal[07],;
	    aTotal[08],;
	    aTotal[09]},aLay[18],,,@nLin)
	    
	    FmtLin(,aLay[19],,,@nLin)
	    
	    nLin := 70
	
	Endif
    
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³DMDCabec    ºAutor  ³ Mary C. Hergert    º Data ³ 17/07/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Imprime o cabecalho                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³FISR003                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DMDCabec(cProduto,cDescr,cUM,cHabil,lAgrupa)

Local nLin		:= 3
Local aLay		:= RDMDLayOut(lAgrupa)
		
@ 0,0 PSAY AvalImp(220)  
FmtLin(,aLay[01],,,@nLin)
FmtLin(,aLay[02],,,@nLin)
FmtLin(,aLay[03],,,@nLin)
FmtLin({SM0->M0_NOMECOM},aLay[04],,,@nLin)
FmtLin(,aLay[05],,,@nLin)
FmtLin({Transform(SM0->M0_INSC,"@R 999.999.999.999"),Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")},aLay[06],,,@nLin)
FmtLin(,aLay[07],,,@nLin)
FmtLin({StrZero(Month(mv_par01),2) + "/" + StrZero(Year(mv_par01),4)},aLay[08],,,@nLin)
FmtLin(,aLay[09],,,@nLin)
FmtLin(,aLay[10],,,@nLin)

FmtLin({cProduto,cDescr,cUM,cHabil},aLay[11],,,@nLin)
FmtLin(,aLay[12],,,@nLin)
FmtLin(,aLay[13],,,@nLin)
FmtLin(,aLay[14],,,@nLin)
FmtLin(,aLay[15],,,@nLin)
FmtLin(,aLay[16],,,@nLin)
FmtLin(,aLay[17],,,@nLin)
	
Return(nLin)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³RDmdLayOut³ Autor ³Mary C. Hergert        ³ Data ³   22/07/2009   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Layout                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³FISR003                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                                
Static Function RDmdLayOut(lAgrupa)

Local aLay := Array(20)

//aLay[01]:=	    "0         10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180                          
//aLay[01]:=	    "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012                          
aLay[01]:=		    "+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLay[02]:=STR0018 //"|                                                    DMD - DECLARACAO DE MOVIMENTACAO DE PRODUTOS COM ICMS DIFERIDO - BA                                                              |"
aLay[03]:=          "|                                                                                                                                                                                     |"
aLay[04]:=STR0019 //"| RAZÃO SOCIAL: #############################                                                                                                                                         |"
aLay[05]:=          "|                                                                                                                                                                                     |" 
aLay[06]:=STR0020 //"| INSCRIÇÃO ESTADUAL: ###########              C.N.P.J.: ##############                                                                                                               |" 
aLay[07]:=          "|                                                                                                                                                                                     |" 
aLay[08]:=STR0021 //"| PERIODO DE REFERÊNCIA: #######                                                                                                                                                      |"
aLay[09]:=          "|                                                                                                                                                                                     |" 
aLay[10]:=          "|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
If lAgrupa
    aLay[11]:=STR0033 //"| GRUPO  : ##############################    DESCRICAO: ########################################    UM: ##########    NUMERO HABILITACAO: ##############################              |"
Else
    aLay[11]:=STR0022 //"| PRODUTO: ##############################    DESCRICAO: ########################################    UM: ##########    NUMERO HABILITACAO: ##############################              |"
EndIf
aLay[12]:=          "|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
aLay[13]:=STR0023 //"|      MUNICIPIO     |                        ENTRADAS COM PRODUTOS DIFERIDOS                        |                        SAIDAS COM PRODUTOS DIFERIDOS                           |"
aLay[14]:=          "|                    |-------------------+-------------------+-------------------+-------------------+-------------------+-------------------+-------------------+--------------------|"
aLay[15]:=STR0024 //"|        ORIGEM      |     QUANTIDADE    |       VALOR       |     QUANTIDADE    |       VALOR       |     QUANTIDADE    |       VALOR       |     QUANTIDADE    |        VALOR       |"
aLay[16]:=STR0025 //"|                    |      INSCRITO     |      INSCRITO     |    NAO INSCRITO   |   NAO INSCRITO    |      INSCRITO     |      INSCRITO     |    NAO INSCRITO   |    NAO INSCRITO    |"
aLay[17]:=          "|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
aLay[18]:=          "| ################## | ################# | ################# | ################# | ################# | ################# | ################# | ################# | #################  |"
aLay[19]:=          "+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLay[20]:=STR0028 //"| SEM MOVIMENTACAO NO PERIODO                                                                                                                                                         |"

Return aLay
