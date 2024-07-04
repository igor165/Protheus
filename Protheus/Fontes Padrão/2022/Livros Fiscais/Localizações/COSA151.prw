#Include 'Protheus.ch'
#Include 'COS151.ch'

#Define _Entrada 	0   
#Define _Saida 		1          
//Define dos tipos de Produtos
#Define _CV 			2
#Define _A 			3
#Define _SP 			4
#Define _M			5
#Define _I			6
//Defines das Colunas dos arrays
#DEFINE _TIPO			7
#Define _CEDULA		1
#Define _NOMBRE		2
#Define _MONTO 		3
#Define _CODIGO		4
#Define _Fornece 	1
#Define _Produto 	2
#Define _Total 		3

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³COSA151   ³ Autor ³Everton Mateus Fernandes³ Data ³23.09.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exporta dados de notas de compra e venda para o Excel.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Oscar Garcia³21/05/18³DMINA-2802³ Se eliminan #IFNDEF TOP y CriaTrab()  ³±±
±±³            ³        ³          ³ por SONARQUBE.                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

Function COSA151()  
/*Tabelas utilizadas: SF1, SD1, SA1, SA2, SB1, SF2, SD2*/

LOCAL aAreaSF1   	:= SF1->(GetArea())
LOCAL aAreaSD1   	:= SD1->(GetArea())
LOCAL aAreaSF2  	:= SF2->(GetArea())
LOCAL aAreaSD2  	:= SD2->(GetArea())
LOCAL aAreaSA2  	:= SA2->(GetArea())
LOCAL cAliasSF1 	:= "SF1"
LOCAL cQuery
LOCAL cFile 		:= ""
LOCAL cTipo			:= ""
LOCAL nX, nY 
LOCAL aCampos 		:= Array(5,2)  
LOCAL aSoma 		:= {}
LOCAL aDados 		:= {}
Local nTamEsp		:= TamSX3("D2_ESPECIE")[1]

//------------------------------
//---Monta o array dos campos---
//------------------------------
aCampos[1] := {"CEDULA",10}
aCampos[2] := {"NOMBRE",60}
aCampos[3] := {"MONTO",13}
aCampos[4] := {"CODIGO",2}  
aCampos[5] := {"TIPO",1}  
cQuery        := "" 

                         
//----------------------------------                                              
//Exibe as perguntas do grupo COS151
//----------------------------------
IF Pergunte("COS151",.T.)
	
	//----------------------------------------------------------------
	//Realiza a consulta das notas e agrupa por Fornecedor e Conceito 
	//----------------------------------------------------------------
	cAliasSF1 := "SF1TMP"          
	//NOTAS DE ENTRADA
	cQuery	  := "  SELECT A2_CGC CEDULA, A2_NOME NOMBRE, SUM(D1_TOTAL) MONTO, B1_CONCEPT CODIGO, 0 TIPO, A2_COD FORNECEDOR FROM"
	cQuery	  += "  " + RetSqlName('SB1') + " inner join " + RetSqlName('SD1') + " on D1_COD=B1_COD inner join " + RetSqlName('SA2') + " on D1_FORNECE=A2_COD"
	cQuery	  += "   WHERE D1_FILIAL   = '" + xFilial('SF1')+ "'"
	cQuery	  += "  	AND D1_DTDIGIT between '" + Dtos(mv_par01) + "' and  '" + Dtos(mv_par02) + "'"
	cQuery	  += "  	AND D1_TIPO = 'N' "
	cQuery	  += "		AND " + RetSqlName('SB1') +  ".D_E_L_E_T_  = ' '"
	cQuery	  += "		AND " + RetSqlName('SA2') +  ".D_E_L_E_T_  = ' '"
	cQuery	  += "   GROUP BY A2_CGC, A2_COD, A2_NOME, B1_CONCEPT" 
	dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSF1, .F., .T.)
	
	//-------------------------
	//Realiza o filtro	
	//-------------------------
	While (cAliasSF1)->(!Eof())
		If ((cAliasSF1)->CODIGO = "CV" .and. (cAliasSF1)->MONTO > 2500) .or. ((cAliasSF1)->CODIGO != "CV" .and. (cAliasSF1)->MONTO > 50000)  
			aadd(aDados,{(cAliasSF1)->CEDULA,(cAliasSF1)->NOMBRE,(cAliasSF1)->MONTO,(cAliasSF1)->CODIGO,(cAliasSF1)->TIPO, (cAliasSF1)->FORNECEDOR})
		Endif
		(cAliasSF1)->(DbSkip())
	EndDo	
	(cAliasSF1)->(dbCloseArea())     

	C151Vendas(@aDados)
	
	//mensagem
	If Empty(aDados)
		MsgAlert(OemToAnsi(STR0003)/*"Não existem dados a serem exportados!"*/,OemToAnsi(STR0004)/*"Atenção!"*/)
	else
		//Abre a tela para o usuário informar o local e nome do arquivo
		cFile := cGetFile('Arquivo TXT|*.TXT','Salvar...',1,'C:\',.F.,GETF_LOCALFLOPPY+GETF_LOCALHARD,.F.)
		//Chama a função para gerar o .TXT
		if AllTrim(cFile)<>""
			msAguarde(C151GerArq(cFile, aCampos, aDados),OemToAnsi(STR0001)/*"Aguarde o termino da geração do arquivo."*/,OemToAnsi(STR0002)/*"Gerando arquivo..."*/)
		endif
	Endif
EndIf//Fim do Pergunte()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³C151GerArq ³ Autor³Everton Mateus Fernandes³ Data ³28.09.2011³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exporta para TXT                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 : Array com dados                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/               

Static Function C151GerArq(cFile, aCampos, aDados)
Local aArea		:= GetArea()                 	// retorna ambiente anterior
Local nY		:= 0                            // auxiliar do for
Local nX        := 0                            // auxiliar do for
Local cBuffer   := ""                           // recebe as variaveis de valores
Local nHandle   := 0
Local xValor    := Nil                          // Variável que receberá o que será incluído em cada linha 
Local Ext		:=".TXT"						// Extenção do arquivo


//-------------------------------------------------------
//inclui a extensão, caso o usuario nao tenha colocado
//-------------------------------------------------------
if SubStr(Upper(cFile),len(cFile)-3,4)<>Upper(Ext)
	cFile+=lower(Ext)
endif
//----------------------
//Tenta criar o arquivo
//----------------------
If (nHandle := FCreate(cFile)) > 0		
	//------------------------------------
 	//Insere os dados no arquivo
    //aDados{[CEDULA][NOMBRE][MONTO][CODIGO][0/1]} 0=entrada; 1=saida
    //------------------------------------
	For nX := 1 To Len(aDados)
		For nY := 1 to Len(aCampos) - 2
			xValor := aDados[nX][nY]
			//Incluis " " a direita quando necessário.
			xValor := Substr(PadR(xValor,aCampos[nY][2]," "),1,aCampos[nY][2])
		    //Remove as aspas da string
		    cBuffer += xValor
		Next nY                 
		//Inclui o tipo do produto
		if aDados[nX][nY]=="CV" 
			if aDados[nX][nY+1]==_Entrada
				xValor := "C"
			elseif aDados[nX][nY+1]==_Saida
				xValor := "V"
			endif
		else
			xValor := aDados[nX][nY]
		endif
	  	//Concatena a string
	  	cBuffer += xValor
		//Indicador de nova linha
		cBuffer += CRLF
	Next nX	        
        
	//inclui os dados no arquivo
	FWrite(nHandle, cBuffer)
	FClose(nHandle)

	MsgAlert(OemToAnsi(STR0005)/*"Arquivo Gerado com sucesso!"*/)
Else
	MsgStop(OemToAnsi(STR0006)/*"Erro na criacao do arquivo na estacao local. Contate o administrador do sistema"*/) 
EndIf	

RestArea(aArea)
Return


/*
ExpA1 - Array com informações de Vendas
[n,1] - Cédula do Cliente                                 
[n,2] - Razão Social                                       
[n,3] - Valor Total Para o Cliente
[n,4] - "V" (Fixo "V") Conceito Venda                      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³C151Vendas³ Autor ³Vendas & CRM           ³ Data ³17.11.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera informacoes para o conceito "V" - Vendas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array que deverá ser alimentada com informacoes    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/               
Static Function C151Vendas(aDados)

Local aArea		:= GetArea()	
Local aEspD2		:= {'NF','NDC','NCE'}		// Especies de Documentos de SD2
Local aEspD1		:= {'NDE','NCC'}			// Especies de Documentos de SD1 
Local aTamEsp		:= TamSX3("D2_ESPECIE")
Local aTamVlr		:= TamSX3("D2_TOTAL")
Local nTamVlr1	:= aTamVlr[1]
Local nTamVlr2	:= aTamVlr[2]
Local cCliente	:= ""	
Local cLoja		:= ""
Local cDocSerie	:= ""
Local cFilter		
Local nX
Local cAlias
Local aStru
Local cArqTrab
Local cNomeInd

For nX := 1 To Len(aEspD2)		
	aEspD2[nX] := PadR(aEspD2[nX],aTamEsp[1])
Next nX	

For nX := 1 To Len(aEspD1)		
	aEspD1[nX] := PadR(aEspD1[nX],aTamEsp[1])
Next nX	


cAlias	:= GetNextAlias()
  
BeginSQL alias cAlias

	COLUMN MONTO AS NUMERIC(nTamVlr1,nTamVlr2)

	SELECT
		A1_COD CLIENTE,
		A1_LOJA LOJA,
		A1_CGC CEDULA,
		A1_NOME NOMBRE,
		SUM(D2_TOTAL * F2_TXMOEDA) MONTO,
		D2_ESPECIE ESPECIE,
		B1_CONCEPT CODIGO			
	FROM
		%table:SD2% SD2
	JOIN
		%table:SA1% SA1 ON (SA1.A1_COD=SD2.D2_CLIENTE AND SA1.A1_LOJA=SD2.D2_LOJA)
	JOIN
		%table:SB1% SB1 ON (SB1.B1_COD=SD2.D2_COD)
	JOIN
		%table:SF2% SF2 ON (
								SF2.F2_DOC=SD2.D2_DOC 
								AND
								SF2.F2_SERIE=SD2.D2_SERIE
								AND
								SF2.F2_CLIENTE=SD2.D2_CLIENTE
								AND
								SF2.F2_LOJA=SD2.D2_LOJA
								AND
								SD2.D2_ESPECIE=SF2.F2_ESPECIE									
								)				
	WHERE
		SD2.D2_EMISSAO BETWEEN %exp:Dtos(mv_par01)% AND %exp:Dtos(mv_par02)%
		AND
		(
			SD2.D2_ESPECIE=%exp:aEspD2[1]%
			OR
			SD2.D2_ESPECIE=%exp:aEspD2[2]%
			OR
			SD2.D2_ESPECIE=%exp:aEspD2[3]%
		)
		AND
		SD2.D2_FILIAL = %xfilial:SD2% 		
		AND
		SD2.%notDel%
		AND
		SA1.%notDel%
		AND
		SB1.%notDel%
	GROUP BY A1_COD,A1_LOJA,A1_CGC,A1_NOME,D2_ESPECIE,B1_CONCEPT
	
	UNION ALL
	
	SELECT
		A1_COD CLIENTE,
		A1_LOJA LOJA,
		A1_CGC CEDULA,
		A1_NOME NOMBRE,
		SUM(D1_TOTAL * F1_TXMOEDA) MONTO,
		D1_ESPECIE ESPECIE,
		B1_CONCEPT CODIGO
	FROM
		%table:SD1% SD1
	JOIN
		%table:SA1% SA1 ON (SA1.A1_COD=SD1.D1_FORNECE AND SA1.A1_LOJA=SD1.D1_FORNECE)
	JOIN
		%table:SB1% SB1 ON (SB1.B1_COD=SD1.D1_COD)
	JOIN
		%table:SF1% SF1 ON (
								SF1.F1_DOC=SD1.D1_DOC 
								AND
								SF1.F1_SERIE=SD1.D1_SERIE
								AND
								SF1.F1_FORNECE=SD1.D1_FORNECE
								AND
								SF1.F1_LOJA=SD1.D1_LOJA
								AND
								SD1.D1_ESPECIE=SF1.F1_ESPECIE									
								)				
	WHERE
		SD1.D1_EMISSAO BETWEEN %exp:Dtos(mv_par01)% AND %exp:Dtos(mv_par02)%
		AND
		(
			SD1.D1_ESPECIE=%exp:aEspD1[1]%
			OR
			SD1.D1_ESPECIE=%exp:aEspD1[2]%
		)
		AND
		SD1.D1_FILIAL = %xfilial:SD1% 		
		AND
		SD1.%notDel%
		AND
		SA1.%notDel%
		AND
		SB1.%notDel%
	GROUP BY A1_COD,A1_LOJA,A1_CGC,A1_NOME,D1_ESPECIE,B1_CONCEPT		
	
	ORDER BY CLIENTE,LOJA,ESPECIE 		

EndSQL	

DbSelectArea(cAlias)	

c151ProVen(@aDados,cAlias)

DbCloseArea()

RestArea(aArea)
	
Return


/*
ExpA1 - Array com informações de Vendas
[n,1] - Cédula do Cliente                                 
[n,2] - Razão Social                                       
[n,3] - Valor Total Para o Cliente
[n,4] - "V" (Fixo "V") Conceito Venda  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³C151ProVen³ Autor ³Vendas & CRM           ³ Data ³21.11.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa Alias informado para gerar informacoes de Vendas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array com informações para popular com vendas      ³±±
±±³          ³ ExpC2 - Alias da Tabela Temporaria                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    
Static Function c151ProVen(aDados,cAlias)

Local cCliente
Local cLoja
Local aDadosCli	:= {}
Local nDebVenta	:= 0
Local nCredVenta	:= 0
Local nSaiVenta	:= 0
Local nTotVenta	:= 0
Local nDebOtros	:= 0
Local nCredOtros	:= 0
Local nSaiOtros	:= 0
Local nTotOtros	:= 0
Local nTotal		:= 0	
Local nX

While !(cAlias)->(EOF())
		
	cCliente	:=	(cAlias)->CLIENTE
	cLoja		:=	(cAlias)->LOJA
		
	aAdd(aDadosCli,{	cCliente,;
						cLoja,;
						(cAlias)->CEDULA,;
						(cAlias)->NOMBRE,;
						(cAlias)->MONTO,;
						(cAlias)->ESPECIE,;
						(cAlias)->CODIGO,})						
	
	DbSkip()		
	
	//Qdo Muda o Cliente Verifica se deve Listar Conforme Regra de Negócio
	If (cAlias)->(EOF()) .OR. (cCliente+cLoja <> ( (cAlias)->CLIENTE + (cAlias)->LOJA ) )
		
		//Inicializa Totalizadores									
		nDebVenta	:= 0
		nCredVenta	:= 0
		nSaiVenta	:= 0
		nTotVenta	:= 0
		nDebOtros	:= 0
		nCredOtros	:= 0
		nSaiOtros	:= 0
		nTotOtros	:= 0			
		
		//Totaliza Saidas, Debitos e Creditos
		//Separando em conceito "CV" e os Outros
		For nX := 1 To Len(aDadosCli)						
			If Trim(aDadosCli[nX][6]) == "NF"
				If Trim(aDadosCli[nX][7]) == "CV"
					nSaiVenta	+= aDadosCli[nX][5]
				Else
					nSaiOtros	+= aDadosCli[nX][5]
				EndIf
			ElseIf Trim(aDadosCli[nX][6]) $ "NCC|NDE"
				If Trim(aDadosCli[nX][7]) == "CV"
					nCredVenta	+= aDadosCli[nX][5]
				Else
					nCredOtros	+= aDadosCli[nX][5]
				EndIf
			ElseIf Trim(aDadosCli[nX][6]) $ "NCE|NDC"
				If Trim(aDadosCli[nX][7]) == "CV"
					nDebVenta	+= aDadosCli[nX][5]
				Else
					nDebOtros	+= aDadosCli[nX][5]
				EndIf					
			EndIf
		Next
		
		//Após totalizacoes de Saídas, Debitos e Creditos
		//Gera Totais pelos Conceitos
		nTotVenta	:=	nSaiVenta - nCredVenta + nDebVenta
		nTotOtros	:=	nSaiOtros - nCredOtros + nDebOtros
		
		//Arredondamento conforme regra de negócio do país
		nX 			:= nTotVenta - Int(nTotVenta)
		nTotVenta	:= Int(nTotVenta)
		If nX >= 0.5
			nTotVenta += 1
		EndIf
		
		nX			:= nTotOtros - Int(nTotOtros)
		nTotOtros	:= Int(nTotOtros)
		If nX >= 0.5
			nTotOtros += 1
		EndIf
		
		//Se total conceito CV > 2.500.000 ou Outros > 50.000 Inclui no Arquivo			
		If nTotVenta > 2500000 .OR. nTotOtros > 50000
			nTotal := nTotVenta + nTotOtros
			aAdd(aDados,{		aDadosCli[1][3],;	//CEDULA
								aDadosCli[1][4],;	//NOMBRE
								nTotal,;			//MONTO								 
								"V",;			    //Conceito "V"
								_Saida,;			//Saida
								})
		EndIf									
					
		//Limpa Dados do Cliente
		aDadosCli	:= {}
		
	EndIf					
End	

Return aDados