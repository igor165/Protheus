#Include 'Protheus.ch'
#include "TopConn.ch"
#Include 'MATRPER1.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MATRPER1  ³ Autor ³Vendas & CRM           ³ Data ³16.02.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Geracao Arquivo Magnetico DAOT 2010 - PDT 3500             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function MATRPER1()
  
Local cFile
Local aDados := {}
Local nDeclara
Local cExercicio
Local dDataDe
Local dDataAte

#IFDEF TOP	
	If Pergunte("DAOTPER",.T.)
	
		//Regras e Filtros
		nDeclara	:= MV_PAR01
		cExercicio	:= cValToChar(MV_PAR02)
		dDataDe		:= MV_PAR03
		dDataAte	:= MV_PAR04
		
		If dDataDe > dDataAte
			MsgAlert(STR0001)//"A Data Final deve ser maior ou igual à Data Inicial."
		ElseIf Substr(cExercicio,1,1) <> "2" .OR. Len(cExercicio) <> 4
			MsgAlert(STR0002)//"Exercicio Inválido" 
		Else	
			Per1Vendas(@aDados,nDeclara,cExercicio,dDataDe,dDataAte)				
			If Empty(aDados)
				MsgAlert(STR0003,STR0004)//"Não há dados para exportação.","Atenção" 
			Else		
				cFile := cGetFile('Arquivo TXT|*.TXT',STR0005,1,'C:\',.F.,GETF_LOCALFLOPPY+GETF_LOCALHARD,.F.) // 'Salvar...'		
				If AllTrim(cFile)<>""
					MsAguarde(Per1GerTxt(cFile, aDados),STR0006,STR0007)//"Aguarde a geração do arquivo","Gerando Arquivo..."
				EndIf
			EndIf
		EndIf
		
	EndIf
#ELSE
	MsgAlert(STR0008)//"Esta funcionalidade esta disponível apenas para ambiente TopConnect."
#ENDIF

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Per1Vendas³ Autor ³Vendas & CRM           ³ Data ³16.02.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Totaliza Informacoes de Vendas DAOT 2010 - PDT 3500        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com as linhas do arquivo (Referencia)        ³±±
±±³          ³ ExpN2 = Declaracao utilizada conforme pergunte             ³±±
±±³          ³ ExpC2 = Exercicio utilizado para compor linha do arquivo   ³±±
±±³          ³ ExpD3 = Data de inicio do filtro (query)                   ³±±
±±³          ³ ExpD4 = Data final do filtro (query)                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function Per1Vendas(aDados,nDeclara,cExercicio,dDataDe,dDataAte)

Local cQuery							// Query para filtrar vendas conforme declaracao
Local cBuffer	:= ""					// String da linha montada 
Local nReg		:= 1 					// Registro Contador do layout			
Local aAuxNom 	:= {}					// Auxiliar para quebrar o nome
Local cEmpRUC							// RUC Recuperado de SM0
Local aAreaSM0 	:= SM0->(GetArea())
Local nVlrInclui := GetMV("MV_DAOTPER",.F.,0)	

SM0->(dbSeek(cEmpAnt+cFilAnt))
cEmpRUC := Trim(SM0->M0_CGC)
RestArea(aAreaSM0)

DbSelectArea("SA1")
DbSetOrder(1)
 

cQuery := "SELECT A1_COD , A1_LOJA , SUM(F3_VALCONT) as TOTAL FROM ( "
cQuery += "SELECT  DISTINCT t.* FROM ( "

//QRY1 - Vendas Brutas e QRY2 - Descontos
cQuery += Per1Ven100(dDataDe,dDataAte)

//Declarar por PDT 621 ou Formulario 118
If nDeclara == 1 .OR. nDeclara == 3
	//QRY 7	
	cQuery += " UNION ALL "+Per1Ven105(dDataDe,dDataAte)
EndIf

If nDeclara == 1 //Somente PDT 621	 
	// 109 e 112 nao totaliza	 		 		 		 	
	//160 - Vendas lei 27037
	//QRY5 Vendas Brutas e QRY6 - Devolucoes e Descontos
	cQuery += " UNION ALL "+Per1Ven160(dDataDe,dDataAte) 		 	
EndIf

cQuery += ") t ) t2 GROUP BY A1_COD , A1_LOJA ORDER BY A1_COD,A1_LOJA"

TCQUERY cQuery NEW ALIAS "QRY"

While !QRY->(EOF())	

	//Inclui no arquivo apenas quando o total for maior que o valor do parametro
	If QRY->TOTAL <= nVlrInclui
		QRY->(DbSkip())
		Loop		
	EndIf
	
	If !(SA1->(MsSeek(XFilial("SA1")+QRY->A1_COD+QRY->A1_LOJA)))
		Final(STR0009+QRY->A1_COD+STR0010+QRY->A1_LOJA+STR0011)//"Erro! Cliente:"#" Loja:"#" não encontrado."
	EndIf

	//Posicao 01 - Registro do Arquivo
	cBuffer := cValToChar(nReg) + "|"	
	
	//Posicao 02 - Tipo de Documento do Declarante - Tabla 1
	//Posicao 03 - Numero do Documento do Declarante
	//Virah de SM0 o RUC
	cBuffer += "6|"+cEmpRUC+"|"
	
	//Posicao 04 - Exercicio	
	cBuffer += cExercicio + "|"
	
	//Posicao 05 - Tipo de Pessoa do Declarado - Tabla 2	
	cBuffer += Iif(SA1->A1_TIPO=="1",'02','01')+"|"
	
	//Posicao 06 - Tipo de Documento do Declarado - Tabla 1
	//Posicao 07 - Numero do Documento do Declarado
	
	//Se tiver RUC usa preferencialmente - Tipo 6	
	If Trim(SA1->A1_CGC) <> ""
		cBuffer += "6|"+Trim(SA1->A1_CGC)+"|"
	ElseIf Trim(SA1->A1_TIPDOC) == "01" .AND. Trim(SA1->A1_PFISICA) <> ""// DNI - Tipo 1
		cBuffer += "1|"+Trim(SA1->A1_PFISICA)+"|"
	//Tipos 02/03/04/07 - Procura documento no campo DNI		
	ElseIf Trim(SA1->A1_TIPDOC) $ '02|03|04|07' .AND. Trim(SA1->A1_PFISICA) <> ""
		cBuffer += Val(SA1->A1_TIPDOC)+"|"+Trim(SA1->A1_PFISICA)+"|"	
	Else 
		/*
		Para os Tipos: 
			00 - Outros, 
			05 - Libreta Cedula Tributaria, 
			08 - Documento Provisional de Identidade
					
		Considera como sem documento por nao conter na tabela.
						
		Tambem ira considerar como sem documento quando Não encontrar RUC ou DNI para os outros tipos correspondentes.
		*/
		cBuffer += "||"	
	EndIf 
 
	//Posicao 08 - Total Arredondado
	cBuffer += cValToChar(Round(QRY->TOTAL, 0))+"|"
	
	//Posicao 09 - Apellido Paterno del declarado
	//Posicao 10 - Apellido Materno del declarado
	//Posicao 11 - Primer Nombre del declarado
	//Posicao 12 - Segundo Nombre del declarado	
	//Posicao 13 - Razao Social    
	If SA1->A1_TIPO == "1" // Se Empresa soh tem Razao Social
		cBuffer += "||||"+TRIM(SA1->A1_NOME)+"|"  
	Else // Se Pessoa Fisica Quebra o Nome
		aAuxNom := StrTokArr(Trim(SA1->A1_NOME)," ")
		If Len(aAuxNom) >= 4 		//Se Tamanho >= 4 Considera
			cBuffer += aAuxNom[4]+"|"+aAuxNom[3]+"|"+aAuxNom[1]+"|"+aAuxNom[2]+"||"
		ElseIf Len(aAuxNom) == 3	//Se Tamanho = 3 Nao tem segundo Nome
			cBuffer += aAuxNom[3]+"|"+aAuxNom[2]+"|"+aAuxNom[1]+"|||"
		Elseif Len(aAuxNom) == 2 	//Se Tamanho = 2 Soh tem nome do pai
			cBuffer += aAuxNom[2]+"||"+aAuxNom[1]+"|||"
		Elseif Len(aAuxNom) == 1 	//Se Tamanho = 1 Soh tem nome Primeiro Nome
			cBuffer += "||"+aAuxNom[1]+"|||"		
		EndIf		
	EndIf	
		
	AAdd(aDados,cBuffer)
	nReg++
	cBuffer	:= ""	
	QRY->(DbSkip())
	
EndDo

QRY->(dbCloseArea())

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Per1Ven100³ Autor ³Vendas & CRM           ³ Data ³16.02.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Totaliza Casilha 100 de Vendas DAOT 2010 - PDT 3500        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data de inicio do filtro (query)                   ³±±
±±³          ³ ExpD2 = Data final do filtro (query)                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function Per1Ven100(dDataDe,dDataAte)
//Todas as declaracoes utilizam 100
// 100 - Vendas brutas - descontos

//Vendas Brutas
clQry1	:="SELECT F3_ENTRADA" 
clQry1	+=" , F3_NFISCAL"
clQry1	+=" , F3_SERIE"
clQry1  +=" , A1_COD"
clQry1  +=" , A1_LOJA" 
clQry1	+=" , F3_VALCONT"
clQry1	+=" FROM " + RetSqlName('SF3') + " SF3"

clQry1	+=" JOIN " + RetSqlName('SF2') + " SF2"
clQry1	+=" ON F3_NFISCAL = F2_DOC"
clQry1	+=" AND F3_SERIE = F2_SERIE"
clQry1	+=" AND F3_CLIEFOR = F2_CLIENTE"
clQry1	+=" AND F3_LOJA = F2_LOJA"
clQry1	+=" AND '"+xFilial('SF2')+"' = F2_FILIAL AND SF2.D_E_L_E_T_ = ' '"

clQry1	+=" JOIN " + RetSqlName('SA1') + " SA1"
clQry1	+=" ON F3_CLIEFOR = A1_COD"
clQry1	+=" AND F3_LOJA = A1_LOJA"
clQry1	+=" AND '"+xFilial('SA1')+"' = A1_FILIAL AND SA1.D_E_L_E_T_ = ' '"
 
clQry1	+=" WHERE F3_ENTRADA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"'"
clQry1	+=" AND SF3.D_E_L_E_T_ = ' ' AND '"+xFilial('SF3')+"' = F3_FILIAL AND F3_TIPOMOV = 'V' AND F3_VALIMP1 > 0 AND F3_ESPECIE <> 'NCC'"		
//clQry1	+=" ORDER BY F3_ENTRADA,F3_NFISCAL "		

//Desc. Concedidos e/ou Devolucoes de Venda
clQry2	:="SELECT F3_ENTRADA" 
clQry2	+=" , F3_NFISCAL"
clQry2	+=" , F3_SERIE"			
clQry2  +=" , A1_COD"
clQry2  +=" , A1_LOJA" 		
clQry2	+=" , (F3_VALCONT * -1) F3_VALCONT"
clQry2	+=" FROM " + RetSqlName('SF3') + " SF3"

clQry2	+=" JOIN " + RetSqlName('SD1') + " SD1"
clQry2	+=" ON F3_NFISCAL = D1_DOC"
clQry2	+=" AND F3_SERIE = D1_SERIE"
clQry2	+=" AND F3_CLIEFOR = D1_FORNECE"
clQry2	+=" AND F3_LOJA = D1_LOJA"				
clQry2	+=" AND '"+xFilial('SD1')+"' = D1_FILIAL"
clQry2	+=" AND SD1.D_E_L_E_T_ = ' '"

clQry2	+=" JOIN " + RetSqlName('SF2') + " SF2"
clQry2	+=" ON D1_NFORI = F2_DOC"
clQry2	+=" AND D1_SERIORI = F2_SERIE"
clQry2	+=" AND D1_FORNECE = F2_CLIENTE
clQry2	+=" AND D1_LOJA = F2_LOJA" 
clQry2	+=" AND '"+xFilial('SF2')+"' = F2_FILIAL"
clQry2	+=" AND SF2.D_E_L_E_T_ = ' '"
		
clQry2	+=" JOIN " + RetSqlName('SA1') + " SA1"
clQry2	+=" ON F3_CLIEFOR = A1_COD"
clQry2	+=" AND F3_LOJA = A1_LOJA"
clQry2	+=" AND '"+xFilial('SA1')+"' = A1_FILIAL"
clQry2	+=" AND SA1.D_E_L_E_T_ = ' '"
 
clQry2	+=" WHERE F3_ENTRADA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"'"
clQry2	+=" AND SF3.D_E_L_E_T_ = ' '"
clQry2	+=" AND '"+xFilial('SF3')+"' = F3_FILIAL"
clQry2	+=" AND F3_TIPOMOV = 'V'"
clQry2	+=" AND F3_VALIMP1 > 0"
clQry2	+=" AND F3_ESPECIE = 'NCC'"					

Return (clQry1+" UNION ALL "+clQry2)

Static Function Per1Ven105(dDataDe,dDataAte)
	
//Vendas nao gravadas(sem considerar exportacoes)
clQry7	:="SELECT F3_ENTRADA" 
clQry7	+=" , F3_NFISCAL"
clQry7	+=" , F3_SERIE"
clQry7  +=" , A1_COD"
clQry7  +=" , A1_LOJA" 
clQry7	+=" , F3_VALCONT"
clQry7	+=" FROM " + RetSqlName('SF3') + " SF3"

clQry7 += " LEFT JOIN " + RetSqlName("SF2") + " SF2 "
clQry7 += " ON F2_DOC = F3_NFISCAL "
clQry7 += " AND F2_SERIE = F3_SERIE "
clQry7 += " AND F2_ESPECIE = F3_ESPECIE "
clQry7 += " AND F2_CLIENTE = F3_CLIEFOR "
clQry7 += " AND F2_LOJA = F3_LOJA "			
clQry7 += " AND F2_FILIAL = '" + XFILIAL("SF2") + "'	" 
clQry7 += " AND SF2.D_E_L_E_T_ <> '*'"	

clQry7	+=" JOIN " + RetSqlName('SA1') + " SA1"
clQry7	+=" ON F3_CLIEFOR = A1_COD"
clQry7	+=" AND F3_LOJA = A1_LOJA"
clQry7	+=" AND '"+xFilial('SA1')+"' = A1_FILIAL"
clQry7	+=" AND SA1.D_E_L_E_T_ = ' '"		

clQry7	+=" WHERE F3_ENTRADA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"'"
clQry7	+=" AND SF3.D_E_L_E_T_ = ' '"
clQry7	+=" AND '"+xFilial('SF3')+"' = F3_FILIAL"
clQry7	+=" AND F3_TIPOMOV = 'V'"
clQry7	+=" AND F3_ESPECIE NOT IN ('NCC','NDI')"
clQry7	+=" AND F3_EXENTAS <> 0"							

Return clQry7

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Per1Ven160³ Autor ³Vendas & CRM           ³ Data ³16.02.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Totaliza Casilha 160 de Vendas DAOT 2010 - PDT 3500        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data de inicio do filtro (query)                   ³±±
±±³          ³ ExpD2 = Data final do filtro (query)                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function Per1Ven160(dDataDe,dDataAte)

//Vendas Lei 27037
clQry5	:="SELECT F3_ENTRADA" 
clQry5	+=" , F3_NFISCAL"
clQry5	+=" , F3_SERIE"
clQry5  +=" , A1_COD"
clQry5  +=" , A1_LOJA" 
clQry5	+=" , F3_VALCONT"
clQry5	+=" FROM " + RetSqlName('SF3') + " SF3"

clQry5 += " LEFT JOIN " + RetSqlName("SF2") + " SF2 "
clQry5 += " ON F2_DOC = F3_NFISCAL "
clQry5 += " AND F2_SERIE = F3_SERIE "
clQry5 += " AND F2_ESPECIE = F3_ESPECIE "
clQry5 += " AND F2_CLIENTE = F3_CLIEFOR "
clQry5 += " AND F2_LOJA = F3_LOJA "			
clQry5 += " AND F2_FILIAL = '" + XFILIAL("SF2") + "'	" 
clQry5 += " AND SF2.D_E_L_E_T_ <> '*'"	

clQry5	+=" JOIN " + RetSqlName('SA1') + " SA1"
clQry5	+=" ON F3_CLIEFOR = A1_COD"
clQry5	+=" AND F3_LOJA = A1_LOJA"		
clQry5	+=" AND '"+xFilial('SA1')+"' = A1_FILIAL"
clQry5	+=" AND SA1.D_E_L_E_T_ = ' '"

clQry5	+=" JOIN " + RetSqlName('SF4') + " SF4"
clQry5	+=" ON F3_TES = F4_CODIGO"
clQry5	+=" AND '"+xFilial('SF4')+"' = F4_FILIAL"
clQry5	+=" AND SF4.D_E_L_E_T_ = ' '"
clQry5	+=" AND F4_IGVOUT = '2'"
 
clQry5	+=" WHERE F3_ENTRADA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"'"
clQry5	+=" AND SF3.D_E_L_E_T_ = ' '"
clQry5	+=" AND '"+xFilial('SF3')+"' = F3_FILIAL"
clQry5	+=" AND F3_TIPOMOV = 'V'"
clQry5	+=" AND F3_VALIMP1 > 0"
clQry5	+=" AND F3_ESPECIE NOT IN ('NCC','NDI') "  		

//Desc Concedidos e/ou Devolucoes de Venda Lei 27037
clQry6	:="SELECT F3_ENTRADA" 
clQry6	+=" , F3_NFISCAL"
clQry6	+=" , F3_SERIE"
clQry6  +=" , A1_COD"
clQry6  +=" , A1_LOJA" 
clQry6	+=" , (F3_VALCONT * -1) F3_VALCONT"
clQry6	+=" FROM " + RetSqlName('SF3') + " SF3"

clQry6	+=" JOIN " + RetSqlName('SD1') + " SD1"
clQry6	+=" ON F3_NFISCAL = D1_DOC"
clQry6	+=" AND F3_SERIE = D1_SERIE"
clQry6	+=" AND F3_CLIEFOR = D1_FORNECE"
clQry6	+=" AND F3_LOJA = D1_LOJA"		
clQry6	+=" AND '"+xFilial('SD1')+"' = D1_FILIAL"
clQry6	+=" AND SD1.D_E_L_E_T_ = ' '"
		
clQry6	+=" JOIN " + RetSqlName('SF2') + " SF2"
clQry6	+=" ON D1_NFORI = F2_DOC"
clQry6	+=" AND D1_SERIORI = F2_SERIE"
clQry6	+=" AND D1_FORNECE = F2_CLIENTE
clQry6	+=" AND D1_LOJA = F2_LOJA" 		
clQry6	+=" AND '"+xFilial('SF2')+"' = F2_FILIAL"
clQry6	+=" AND SF2.D_E_L_E_T_ = ' '"

clQry6	+=" JOIN " + RetSqlName('SA1') + " SA1"
clQry6	+=" ON F3_CLIEFOR = A1_COD"
clQry6	+=" AND F3_LOJA = A1_LOJA"		
clQry6	+=" AND '"+xFilial('SA1')+"' = A1_FILIAL"
clQry6	+=" AND SA1.D_E_L_E_T_ = ' '"

clQry6	+=" JOIN " + RetSqlName('SF4') + " SF4"
clQry6	+=" ON F3_TES = F4_CODIGO"
clQry6	+=" AND '"+xFilial('SF4')+"' = F4_FILIAL"
clQry6	+=" AND SF4.D_E_L_E_T_ = ' '"
clQry6	+=" AND F4_IGVOUT = '2'"
 
clQry6	+=" WHERE F3_ENTRADA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"'"
clQry6	+=" AND SF3.D_E_L_E_T_ = ' '"
clQry6	+=" AND '"+xFilial('SF3')+"' = F3_FILIAL"
clQry6	+=" AND F3_TIPOMOV = 'V'"
clQry6	+=" AND F3_VALIMP1 > 0"
clQry6	+=" AND F3_ESPECIE = 'NCC'"			


Return (clQry5+" UNION ALL "+clQry6)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Per1GerTxt³ Autor ³Vendas & CRM           ³ Data ³17.02.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exporta para TXT                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 : Array com dados                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/               
/*
Layout abaixo

Tabla Estructura del archivo de datos a transferir TXT
=======================================================

 DESCRIPCION
=======================================================
	Número Correlativo asignado a cada registro                
	Tipo Documento Declarante(tabla 1)
	Número de Documento del declarante              
	Periodo, ejercicio a declarar Formato AAAA
	Tipo de Persona del declarado(tabla2)  
	Tipo Documento del Declarado (tabla 1)
	Número de Documento del Declarado 
	Monto o Importe Total             
	Apellido Paterno del declarado
	Apellido Materno del declarado
	Primer Nombre del declarado      
	Segundo Nombre del declarado
	Razón Social                      
                                  
=======================================================

TABLA 1 - Tipo de Documento
============================================
COD.  	DESCRIPCION
============================================
1 	Libreta Electoral/ DNI
2 	Carnet de Fuerzas policiales
3 	Carnet de Fuerzas armadas
4 	Carnet de Extranjería
6 	Registro Unico de contribuyentes
7 	Pasaporte
- 	Sin documento 
____________________________________________



TABLA 2 - Tipo de Pessoa
============================================
COD.  	DESCRIPCION
============================================
01 	Persona Natural.
02 	Persona jurica o Entidades.
03 	Sujeto no domiciliado.
04	Adquirente - ticket
____________________________________________
*/
Static Function Per1GerTxt(cFile, aDados)
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
If SubStr(Upper(cFile),len(cFile)-3,4)<>Upper(Ext)
	cFile+=lower(Ext)
endIf
//----------------------
//Tenta criar o arquivo
//----------------------
If (nHandle := FCreate(cFile)) > 0		
	For nX := 1 To Len(aDados)
	  	//Concatena a string
	  	cBuffer += aDados[nX]
		//Indicador de nova linha
		cBuffer += CRLF
	Next nX	        
        
	//inclui os dados no arquivo
	FWrite(nHandle, cBuffer)
	FClose(nHandle)

	MsgAlert(STR0012)/*"Arquivo Gerado com sucesso!"*/
Else
	MsgStop(STR0013)/*"Erro na criacao do arquivo na estacao local. Contate o administrador do sistema"*/
EndIf	

RestArea(aArea)
Return