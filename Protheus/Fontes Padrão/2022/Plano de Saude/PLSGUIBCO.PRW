#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMGER2.CH"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "plsguibco.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
#include 'fileio.ch'

#DEFINE lSrvUnix IsSrvUnix()
#DEFINE __RELIMP PLSMUDSIS(getWebDir() + getSkinPls() + "\relatorios\")
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSGUIBCO ³ Autor ³ Thiago Guilherme		³ Data ³ 25.11.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta o pergunte com as opções de guia			          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSGUIBCO(lAuto)

LOCAl cTipGui := NIL 
LOCAL nQtdGui := NIL 
LOCAL lRetPerg := .F.

if valtype(lAuto) <> 'L'
	lAuto := .f.
endif

While !lRetPerg
	If lAuto .or. Pergunte("PLSGUIBRA", .T.)
	
		cTipGui := ALLTRIM(MV_PAR01) 
		nQtdGui := MV_PAR02
	
		If EMPTY(cTipGui) .OR. EMPTY(nQtdGui)
			Alert(STR0013) //"Preencha todos os parâmetros."
			lRetPerg := .T.
			loop 
		
		EndIf
		
		SX5->(dbSetOrder(1))
		If !SX5->(dbSeek(xFilial('SX5')+'PU'+cTipGui)) .and. !lAuto
			Alert(STR0014) //"Selecione um tipo de guia existente."
			loop
		EndIf
		
		lRetPerg := .T.
		
		If cTipGui == "1" //Consulta	
			MsgRun(STR0001,STR0012,{|| PLIMPGUIB(cTipGui,nQtdGui,lAuto)})
			
		ElseIf cTipGui == "2" //SADT
			MsgRun(STR0002,STR0012,{|| PLIMPGUIB(cTipGui,nQtdGui,lAuto)})
		
		ElseIf cTipGui == "3" //Internação 
			MsgRun(STR0003,STR0012,{|| PLIMPGUIB(cTipGui,nQtdGui,lAuto)})
		
		ElseIf cTipGui == "4" // Prorrog. de internação
			MsgRun(STR0004,STR0012,{|| PLIMPGUIB(cTipGui,nQtdGui,lAuto)})
		
		ElseIf cTipGui == "5" // Resumo de internação
			MsgRun(STR0005,STR0012,{|| PLIMPGUIB(cTipGui,nQtdGui,lAuto)})
		
		ElseIf cTipGui == "6" // Odontológica
			MsgRun(STR0006,STR0012,{|| PLIMPGUIB(cTipGui,nQtdGui,lAuto)})
	
		ElseIf cTipGui == "7" // Odontológica (Solicitação)
			MsgRun(STR0007,STR0012,{|| PLIMPGUIB(cTipGui,nQtdGui,lAuto)})
		
		ElseIf cTipGui == "8" // Sol. Honorário médico
			MsgRun(STR0008,STR0012,{|| PLIMPGUIB(cTipGui,nQtdGui,lAuto)})
		
		ElseIf cTipGui == "9" // Sol. radioterapia
			MsgRun(STR0009,STR0012,{|| PLIMPGUIB(cTipGui,nQtdGui,lAuto)})
		
		ElseIf cTipGui == "10" //Sol. Quimioterapia
			MsgRun(STR0010,STR0012,{|| PLIMPGUIB(cTipGui,nQtdGui,lAuto)})
		
		ElseIf cTipGui == "11" //Sol. OPME
			MsgRun(STR0011,STR0012,{|| PLIMPGUIB(cTipGui,nQtdGui,lAuto)})
		
		ElseIf cTipGui == "12" //Outras despesas
			MsgRun("Outras despesas",STR0012,{|| PLIMPGUIB(cTipGui,nQtdGui,lAuto)})
			
		ElseIf cTipGui == "13" //Comprovante Presencial
			MsgRun("Comprovante Presencial",STR0012,{|| PLIMPGUIB(cTipGui,nQtdGui,lAuto)})
			
		ElseIf cTipGui == "14" //Tratamento odontologico
			MsgRun("Tratamento odontológico",STR0012,{|| PLIMPGUIB(cTipGui,nQtdGui,lAuto)})
		EndIf
	Else
		
		lRetPerg := .T.
	EndIf
EndDo
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLIMPGUIB ³ Autor ³ Thiago Guilherme		³ Data ³ 25.11.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprimei a guia de acordo com a opção selecionada          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function PLIMPGUIB(cTipo, nQtd, lWeb)
	
LOCAL aDados :={}	
LOCAL cRegANS := ""
LOCAL cVerTISS  := PLSTISSVER()
LOCAL cNomArq   := NIL
LOCAL AretRel   := NIL
LOCAL nI
LOCAL nCt		:= 0
LOCAL nCount	:= 0
LOCAL cSQL		:= NIL

DEFAULT nQtd := 1
DEFAULT lWeb := .F.

//Pega o registro na ANS de acordo com a operadora
BA0->(dbSetOrder(1))
BA0->(dbSeek(xFilial("BA0")+PlsIntPad()))
cRegANS := BA0->BA0_SUSEP
	
	//Esta parte da rotina só será executada para estes tipos de guias
	//ja que as outras não geram dinamicamente o array de acordo com a
	//versão da TISS
	If cTipo $ "1,2,3,4,5,6"
	
		If cTipo $ "1,2,6" 
			cSQL := "select MAX(R_E_C_N_O_) AS RECNO from " +  RetSqlName('BEA')
			cSQL += " where D_E_L_E_T_ = '' "
			
			If cTipo $ "1,2"
				cSQL += " AND BEA_TIPO = '" + cTipo + "'"
			
			ElseIf cTipo == "4"
				cSQL += " AND BEA_TIPO = '" + cTipo + "'"
			EndIf
			
			PlsQuery(cSQL,'TrbBEA')
		
			BEA->(dbGoto(TrbBEA->RECNO))
			
			TrbBEA->(DbCloseArea())
			
			For nI := 1 To nQtd
				
				//Gera o array dinamico de acordo com a versão da TISS
				AADD(aDados, MtaDados(cTipo))
				
				//altera o registro na ANS e insere o sequencial da guia impressa
				aDados[nI][1] := cRegANS
				aDados[nI][2] := GETSXENUM('BEA', 'BEA_NUMIMP',9)
				ConfirmSX8()
			Next 
			
		ElseIf cTipo $ "3,4,5"
		
			cSQL := "select MAX(R_E_C_N_O_) AS RECNO from " +  RetSqlName('BE4')
			cSQL += " where D_E_L_E_T_ = '' "
		
			PlsQuery(cSQL,'TrbBE4')
		
			BE4->(dbGoto(TrbBE4->RECNO))
			
			TrbBE4->(DbCloseArea())
			
			For nI := 1 To nQtd
				
				//Gera o array dinamico de acordo com a versão da TISS
				AADD(aDados, MtaDados(cTipo))
				
				//altera o registro na ANS e insere o sequencial da guia impressa
				If LEN(aDados[1]) != 0
					aDados[nI][1] := cRegANS
					aDados[nI][2] := GETSXENUM('BE4', 'BE4_NUMIMP',6)
					ConfirmSX8()
				EndIf
			Next 		
		EndIf
		
		//o array dinámico vem preenchido de acordo com o posicionamento da tabela
		//o for se faz necessário para limpar todas as posições do array.
		For nI := 1 To nQtd
		
			For nCt := 3 To Len(aDados[nI]) 
				
				If ValType(aDados[nI][nCt]) == "C"
					aDados[nI][nCt] := Replicate(" ",Len(aDados[nI][nCt]))
				
				ElseIf ValType(aDados[nI][nCt]) == "N"
					aDados[nI][nCt] := VAL("")
					
				ElseIf ValType(aDados[nI][nCt]) == "D"
					aDados[nI][nCt] := CtoD("   /   /   ")
				
				
				
				ElseIf ValType(aDados[nI][nCt]) == "A"
					
					For nCount := 1 To Len(aDados[nI][nCt])
						
						If ValType(aDados[nI][nCt][nCount]) == "C"
							aDados[nI][nCt][nCount] := Replicate(" ",Len(aDados[nI][nCt][nCount]))
						
						ElseIf ValType(aDados[nI][nCt][nCount]) == "N"
							aDados[nI][nCt][nCount] := VAL("")
						
						ElseIf ValType(aDados[nI][nCt][nCount]) == "D"
							
							aDados[nI][nCt][nCount] := CtoD("   /   /   ")
						EndIf
					Next
				EndIf
			Next
		Next
	EndIf
	
	If cTipo == "1" // Consulta
		
		If cVerTISS >= "3" 
			cNomArq := PLSCONSU(aDados,,,,lWeb,__RELIMP)
			
		Else
			cNomArq := PlsTISS1(aDados,,,,lWeb,__RELIMP)
		EndIf
		
	ElseIf cTipo == "2" //SADT

		If cVerTISS >= "3"
			
			cNomArq := PLSSADT(aDados, .F.,,, lWeb, __RELIMP)
		Else  
			cNomArq := PLSTISS2(aDados, .F.,,, lWeb, __RELIMP)
		EndIf
		
	ElseIf cTipo == "3" //Solicitação de Internação
		
		If  cVerTISS >= "3" 
			
			AretRel := PLSSOLIT(aDados,,,,,lWeb,__RELIMP)
			cNomArq  := AretRel[3]
		Else
			
			cNomArq := PLSTISS3(aDados,,,,,lWeb,__RELIMP)
		EndIf
	
	ElseIf cTipo == "4" //Prorrog. de Internação
	
		If PLSTISSVER() >= "3"
			AretRel := PLSPRGIT(aDados,,,,,lWeb,__RELIMP)
			cNomArq  := AretRel[3]
		Else
			MsgAlert(STR0015) //"Impressão indisponível para versão TISS configurada."
		EndIf
	
	ElseIf cTipo == "5" //resumo de Internação
		
		If  cVerTISS >= "3" 
		
			cNomArq := PLSRESIT(aDados,,,,lWeb,__RELIMP) 
		Else
			MsgAlert(STR0015) //"Impressão indisponível para versão TISS configurada." 
		EndIf
	
	ElseIf cTipo == "6" //Odontologico (cobrança)
		
		If PLSTISSVER() >= "3" 
			cNomArq := PLSODTCB(aDados,,,,lWeb,__RELIMP)
		Else
			MsgAlert(STR0015) //"Impressão indisponível para versão TISS configurada."
		EndIf 
		
	ElseIf cTipo == "7" //Odontológica (Solicitação)
		If  cVerTISS >= "3" 
			
			For nI := 1 To nQtd
			
				AADD(aDados, { ;
							cRegANS,; 				 
							GETSXENUM('BEA', 'BEA_NUMIMP',9),;   
							"",; 
							"",; 					 
							Replicate(" ",70),;      
							Replicate(" ",20),;		
							"",;			         
							"",;					 
							"",;   		 			 
							"",;				 	 
							Replicate(" ",500),;  	
							CtoD("    /     /    "),;   	 
							"",;			     	 
							CtoD("    /    /     "),; 		 
							"",;					 
							CtoD("    /    /    ")}  )	 
							
				ConfirmSX8()
			Next
			
			AretRel := PLSODTSC(aDados,,,,lWeb,__RELIMP)
			cNomArq  := AretRel[3]
		Else
			MsgAlert(STR0015) //"Impressão indisponível para versão TISS configurada." 
		EndIf
		
	ElseIf cTipo == "8" //Honorário médico
		
		If PLSTISSVER() >= "3"
    		cNomArq := PLSHONMD(aDados,,,,lWeb,__RELIMP,.T.)
   		Else
    		MsgAlert(STR0015) //"Impressão indisponível para versão TISS configurada."
    	EndIf
	
	//As guias de anexos não possuem geração dinámica do aDados
	//por isto deverão ser alterada de acordo com as alterações da TISS.	
	ElseIf cTipo == "9" //Solic. Radioterapia
			
		For nI := 1 To nQtd			
			
			AADD(aDados, {;
				cRegANS,;
				{GETSXENUM('B4A', 'B4A_NUMIMP',6)},; //2 - N Guia no Prestador
				{""},; //3 - Numero da Guia Referenciada
				{""},; //4 - Senha
				{CtoD("   /   /   ")},; //5 - Data da Autorizacao
				{""},; //6 - Numero da Guia Atribuido pela Operadora
				{""},; //7 - Número da Carteira
				{Replicate(" ", 70)},; //8 - Nome
				{VAL("")},; //9 - Idade
				{""},; //10 - Sexo
				{Replicate("", 70)},; //11 - Nome do Profissional Solicitante
				{""},; //12 - Telefone
				{Replicate(" ", 60)},; //13 - E-mail
				{CtoD("   /   /   ")},; //14 - Data do diagnóstico
				{""},; //15 - CID 10 Principal
				{""},; //16 - CID 10 (2)
				{""},; //17 - CID 10 (3)
				{""},; //18 - CID 10 (4)
				{""},; //19 - Diagnóstico por Imagem
				{""},; //20 - Estadiamento
				{""},; //21 - ECOG
				{""},; //22 - Finalidade
				{Replicate(" ", 1000)},; //23 - Diagnóstico Cito/Histopatológico
				{Replicate(" ", 1000)},; //24 - Informações relevantes
				{Replicate(" ", 40)},; //25 - Cirurgia
				{CtoD("   /   /   ")},; //26 - Data da Realização
				{Replicate(" ", 40)},; //27 - Quimioterapia
				{CtoD("   /   /   ")},; //28 - Data da Aplicação
				{VAL("")},; //29 - Número de Campos
				{VAL("")},; //30 - Dose por dia (em Gy)
				{VAL("")},; //31 - Dose Total ( em Gy)
				{VAL("")},; //32 - Número de Dias
				{CtoD("   /   /   ")},; //33 - Data Prevista para Início da Administração
				{Replicate(" ", 500)},; //34-Observação/Justificativa
				{CtoD("   /   /   ")},; //35 - Data da Solicitação
				{{}},; //36-Assinatura do Profissional Solicitante
				{{}} })  //37-Assinatura do Autorizador da Operadora
				
			ConfirmSX8()
		Next			
		
		cNomArq := PLTRADIO(aDados,,,lWeb,__RELIMP,.T.)
	
	ElseIf cTipo == "10" //Solic. Quimioterapia
		
		For nI := 1 To nQtd					
			
			AADD(aDados, {;
				cRegANS,;
				{GETSXENUM('B4A', 'B4A_NUMIMP',6)},; //2 - N Guia no Prestador
				{""},; //3 - Numero da Guia Referenciada
				{""},; //4 - Senha
				{CtoD("   /   /   ")},; //5 - Data da Autorizacao
				{""},; //6 - Numero da Guia Atribuido pela Operadora
				{""},; //7 - Número da Carteira
				{Replicate(" ", 70)},; //8 - Nome
				{VAL("")},; //9 - Peso (Kg)
				{VAL("")},; //10 - Altura (Cm)
				{VAL("")},; //11 - Superfície Corporal (m²)
				{VAL("")},; //12 - Idade
				{""},; //13 - Sexo
				{Replicate(" ", 70)},; //14 - Nome do Profissional Solicitante
				{""},; //15 - Telefone
				{Replicate(" ", 60)},; //16 - E-mail
				{CtoD("   /   /     ")},; //17 - Data do diagnóstico
				{""},; //18 - CID 10 Principal
				{""},; //19 - CID 10 (2)
				{""},; //20 - CID 10 (3)
				{""},; //21 - CID 10 (4)
				{""},; //22 - Estadiamento
				{""},; //23 - Tipo de Quimioterapia
				{""},; //24 - Finalidade
				{""},; //25 - ECOG
				{""},; //26 - Tumor
				{""},; //27 - Nódulo
				{""},; //28 - Metastase
				{Replicate(" ", 1000)},; //29 - PlanoTerapêutico
				{Replicate(" ", 1000)},; //30 - Diagnóstico Cito/Histopatológico
				{Replicate(" ", 1000)},; //31 - Informações relevantes
				{{CtoD("   /   /     "),CtoD("   /   /     "),CtoD("   /   /     "),CtoD("   /   /     "),CtoD("   /   /     "),CtoD("   /   /     "),CtoD("   /   /     "),CtoD("   /   /     ")}},; //32-Data Prevista para Administração
				{{"","","","","","","",""}},; //33-Tabela
				{{"","","","","","","",""}},; //34-Código do Medicamento
				{{Replicate(" ", 150),Replicate(" ", 150),Replicate(" ", 150),Replicate(" ", 150),Replicate(" ", 150),Replicate(" ", 150),Replicate(" ", 150),Replicate(" ", 150)}},; //35-Descrição
				{{VAL(""), VAL(""), VAL(""), VAL(""), VAL(""), VAL(""), VAL(""), VAL("")}},; //36-Doses
				{{"", "", "", "", "", "", "", ""}},; //37 - Unidade de Medida
				{{"", "", "", "", "", "", "", ""}},; //38-Via Adm
				{{VAL(""), VAL(""), VAL(""), VAL(""), VAL(""), VAL(""), VAL(""), VAL("")}},; //39-Frequência
				{Replicate(" ", 40)},; //40- Cirurgia
				{CtoD("   /   /    ")},; //41 - Data da Realização
				{Replicate(" ", 40)},; //42 - Área Irradiada
				{CtoD("   /   /    ")},; //43 - Data da Aplicação
				{Replicate(" ", 500)},; //44 - Observação
				{VAL("")},; //45 - Número de Ciclos Previstos
				{VAL("")},; //46 - Ciclo Atual
				{},; //47 - Dias Ciclo Atual
				{VAL("")},; //48-Intervalo entre Ciclos ( em dias)
				{CtoD("   /   /    ")},; //49 - Data da Solicitação
				{""},; //50-Assinatura do Profissional Solicitante
				{""} })  //51-Assinatura do Responsável pela Autorização
				
			ConfirmSX8()
		Next			
		
		cNomArq := PLTQUIMIO(aDados,,,lWeb,__RELIMP,.T.)

	ElseIf cTipo == "11" //Solic. OPME
		
		For nI := 1 To nQtd			
		
			AADD(aDados, {;
				cRegANS,;
				{GETSXENUM('B4A', 'B4A_NUMIMP',6)},; //2 - N Guia no Prestador
				{""},; //3 - Numero da Guia Referenciada
				{""},; //4 - Senha
				{CtoD("   /   /   ")},; //5 - Data da Autorizacao
				{""},; //6 - Numero da Guia Atribuido pela Operadora
				{""},; //7 - Numero da Carteira
				{Replicate(" ", 70)},; //8 - Nome
				{Replicate(" ", 70)},; //9- Nome do Profissional Solicitante
				{""},; //10 - Telefone
				{Replicate(" ", 60)},; //11 - E-mail
				{Replicate(" ", 1000)},; //12 - Justificativa Tecnica
				{{"", "","", "","", ""}},; //13-Tabela
				{{"", "","", "","", ""}},; //14-Codigo do Material
				{{Replicate(" ", 150), Replicate(" ", 150),Replicate(" ", 150), Replicate(" ", 150),Replicate(" ", 150), Replicate(" ", 150)}},; //15-Descricao
				{{"", "","", "","", ""}},; //16-Opcao
				{{VAL(""), VAL(""), VAL(""), VAL(""), VAL(""), VAL("")}},; //17-Qtde. Solicitada
				{{VAL(""), VAL(""),VAL(""), VAL(""),VAL(""), VAL("")}},; //18-Valor Unitario Solicitado
				{{VAL(""), VAL(""), VAL(""), VAL(""), VAL(""), VAL("")}},; //19-Qtde. Autorizada
				{{VAL(""), VAL(""), VAL(""), VAL(""), VAL(""), VAL("")}},; //20-Valor Unitario Autorizado
				{{"","","","","",""}},; //21-Registro ANVISA do Material
				{{Replicate(" ", 30), Replicate(" ", 30), Replicate(" ", 30), Replicate(" ", 30), Replicate(" ", 30), Replicate(" ", 30)}},; //22-Referencia do material no fabricante
				{{Replicate(" ", 30), Replicate(" ", 30), Replicate(" ", 30), Replicate(" ", 30), Replicate(" ", 30), Replicate(" ", 30)}},; //23-N Autorizacao de Funcionamento
				{Replicate(" ", 500)},; //24 - Especificacao do Material
				{Replicate(" ", 500)},; //25- Observacao / Justificativa
				{CtoD("   /   /   ")},; //26 - Data da Solicitacao
				{""},; //27- Assinatura do Profissional Solicitante
				{""} })
				
			ConfirmSX8()
		Next			
		
		cNomArq := PLTOPME(aDados,,,lWeb,__RELIMP,.T.)
		
	ElseIf cTipo == "12" //Outras despesas
		
		For nI := 1 To nQtd
			AADD(aDados, { ;
				cRegANS,; 				//1 - Registro ANS
				"",; 					//2 – Número da Guia Referenciada
				"",; 					//3 - Código na Operadora
				Replicate( " ",70 ),;	//4 - Nome do Contratado
				"",; 					//5 – Código CNES
				{ "" },; 				//6-CD
				{ CtoD( "  /  /  " ) },;	//7-Data
				{ "" },; 				//8-Hora Inicial
				{ "" },; 				//9-Hora Final
				{ "" },; 				//10-Tabela
				{ "" },; 				//11-Código do Item
				{ VAL( "" ) },;			//12-Qtde.
				{ "" },; 				//13-Unidade de Medida
				{ VAL( "" ) },; 		//14- Fator Red. / Acresc
				{ VAL( "" ) },; 		//15-Valor Unitário - R$
				{ VAL( "" ) },; 		//16-Valor Total – R$
				{ "" },; 				//17-Registro ANVISA do Material
				{ "" },; 				//18-Referência do material no fabricante
				{ "" },; 				//19-Nº Autorização de Funcionamento
				{ Replicate(" ", 150) },; //20-Descrição
				VAL( "" ),; 			//21 - Total de Gases Medicinais (R$)
				VAL( "" ),; 			//22 - Total de Medicamentos (R$)
				VAL( "" ),; 			//23 - Total de Materiais (R$)
				VAL( "" ),; 			//24 - Total de OPME (R$)
				VAL( "" ),; 			//25 - Total de Taxas e Aluguéis (R$)
				VAL( "" ),; 			//26 - Total de Diárias (R$)
				VAL( "" ) } ) 			//27 - Total Geral (R$)
				
			//ConfirmSX8()
		Next
		
		cNomArq := PLSTISSH( aDados,,,lWeb,__RELIMP,.T. )
	ElseIf cTipo == "13" //Guia de Comprovante Presencial
		For nI := 1 To nQtd
			AADD( aDados, { ;
					cRegANS,; 							//01 - Registro ANS
					"",;								//02 – Número da Guia no Prestador
					"",; 								//03 - Código na Operadora
					Replicate( " ",70 ),;				//04 - Nome do Contratado
					"",; 								//05 – Código CNES
					Replicate( " ",70 ),;				//06 - Nome do profissional executante
					"",;								//07 - Conseho Profissional
					"",;	 							//08 - Numero no conselho
					"",; 								//09 - UF
					"",; 								//10 - Codigo CBO
					{ CToD( "   /   /   " ) },;			//11 - Data do atendimento
					{ "" },;							//12 - Numero da carteira
					{ Replicate( " ",70 ) },;			//13 - Nome do beneficiario
					{ "" },;							//14 - Numero da guia principal
					{ "" },;							//15 - Assinatura
					{ CToD( "   /   /   " ) },;			//16 - Data
					{ "" } } )							//17 - Assinatura do contratado
		Next
		
		cNomArq := PLSTISCOMP( aDados,,,lWeb,__RELIMP,.T. )
	Endif
Return cNomArq

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MtaDados ³ Autor ³ Thiago Ribas     ³ Data ³ 22/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
																		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSGUIBCO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MtaDados(cTipo)
LOCAL aDados := {}

If cTipo $ "1,2"
	aDados := PLSGSADT(cTipo) 	// Funcao que monta o array com os dados da guia de CONSULTA ou SP/SADT
ElseIf cTipo $ "3"
	aDados := PLSGINT(1) 		// Funcao que monta o array com os dados da guia de Sol. Internaçao 
ElseIf cTipo $ "4"
	aDados := PLSGINT(3) 		// Funcao que monta o array com os dados da guia de prorrog. Internaçao
ElseIf cTipo $ "5"
	aDados := PLSGINT(2) 		// Funcao que monta o array com os dados da guia de resumo de Internaçao
ElseIf cTipo == "6"
	aDados := PLSGODCO() 		// Funcao que monta o array com os dados da guia Cobranca Odonto
ElseIf cTipo == "8"				
	aDados := PLSGHONI(1)	//Funcao que monta o array com os dados da guia de honorário médico
EndIf

return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ?PLSCONSU  ?Autor ?Bruno Iserhardt       ?Data ?20.06.13 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ?Estrutura Relatório TISS 3.00.01 (Guia de Consulta )        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?SigaPLS                                                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros?aDados - Array com as informações do relat´rio              ³±?
±±?         ?lGerTXT - Define se imprime direto sem passar pela tela     ³±?
±±?         ?          de configuracao/preview do relatorio              ³±?
±±?         ?nLayout - Define o formato de papél para impressao:         ³±?
±±?         ?          1 - Formato Ofício II (216x330mm)                 ³±?
±±?         ?          2 - Formato A4 (210x297mm)                        ³±?
±±?         ? 		     3 - Formato Carta (216x279mm)                     ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLSCONSU(aDados, lGerTXT, nLayout, cLogoGH, lWeb, cPathRelW)

Local nLinMax
Local nColMax
Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
Local nColA4    :=  0      // Para implementar layout A4
Local nLinA4    :=  0      // Para implementar layout A4
Local cFileLogo
Local nI, nX
Local cObs
Local oFont01
Local oFont02n
Local oFont03n
Local oFont04
LOCAL cFileName	:= ""
LOCAL cRel      := "guicons"
LOCAL cPathSrvJ := GETMV("MV_RELT")
LOCAL nAL		:= 0.25
LOCAL nAC		:= 0.24
LOCAL nLinObs	:= 0

DEFAULT lGerTXT 	:= .F.
DEFAULT nLayout 	:= 2
DEFAULT cLogoGH 	:= ""
DEFAULT lWeb		:= .F.
DEFAULT cPathRelW 	:= ""
DEFAULT aDados := { {;
	"123456",; //1 - Registro ANS
	"12345678901234567890",; //2- N?Guia no Prestador
	"12345678901234567890",; //3 - Número da Guia Atribuído pela Operadora
	"12345678901234567892",; //4 - Número da Carteira
	CtoD("12/12/07"),; //5 - Validade da Carteira
	"N",; //6 ?Atendimento a RN (Sim ou Não)
	Replicate("M",70),; //7 ?Nome
	"123456789012345",; //8 - Cartão Nacional de Saúde
	"12345678901234",; //9- Código na Operadora
	Replicate("M",70),; //10 - Nome do Contratado
	"1234567",; //11 - Código CNES
	Replicate("M",70),; //12 - Nome do Profissional Executante
	"AA",; //13 - Conselho Profissional
	"123456789012345",; //14 - Número no Conselho
	"RS",; //15 - UF
	"123456",; //16 - Código CBO
	"A",; //17 - Indicação de Acidente(acidente ou doença relacionada)
	CtoD("12/12/07"),; //18 - Data do Atendimento
	"A",; //19 - Tipo de Consulta
	"00",; //20 - Tabela
	"1234567890",; //21 - Código do Procedimento
	11111.78,; //22 - Valor do Procedimento
	Replicate("M",100)+Replicate("A",100)+Replicate("B",100)+Replicate("D",100)+Replicate("C",100)} } //23 - Observação / Justificativa

oFont01		:= TFont():New("Arial",  5,  5, , .F., , , , .T., .F.) // Normal

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Nao permite acionar a impressao quando for na web.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lWeb
	cPathSrvJ := cPathRelW
	cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
Else
	cFileName := cRel+CriaTrab(NIL,.F.)
EndIf

	//						New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF] )
oPrint := FWMSPrinter():New ( cFileName			,			,	.F.				,cPathSrvJ	 	,	.T.				,			 ,				,			  ,			  ,	.F.			, 		, 				)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Tratamento para impressao via job
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
oPrint:lServer := lWeb

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Caminho do arquivo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
oPrint:cPathPDF := cPathSrvJ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Modo retrato
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
oPrint:SetPortrait()

If nLayout ==2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Papél A4
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:SetPaperSize(9)
ElseIf nLayout ==3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Papél Carta
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:SetPaperSize(1)
Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Papel Oficio2 216 x 330mm / 8 1/2 x 13in
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:SetPaperSize(14)
Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Device
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lWeb
	oPrint:setDevice(IMP_PDF)
	oPrint:lPDFAsPNG := .T.
EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Verifica se existe alguma impressora configurada para Impressao Grafica
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If  !lWeb
	oPrint:Setup()
	If !(oPrint:nModalResult == 1)
		Return
	Endif
EndIf

If oPrint:nPaperSize  == 9 // Papél A4
	nLinMax	:= 1134
	nColMax	:= 2335
	nLayout 	:= 2
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
Elseif oPrint:nPaperSize == 1 // Papel Carta
	nLinMax	:= 0925
	nColMax	:= 2400
	nLayout 	:= 3
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
Else // Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	nLinMax	:= 1184
	nColMax	:= 2400
	nLayout 	:= 1
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
	oFont04	:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
Endif

For nX := 1 To Len(aDados)

	If Len(aDados[nX]) == 0
		Loop
	EndIf

	If oPrint:Cprinter == "PDF" .OR. lWeb
		nLinIni	:= 000
	Else
		nLinIni := 100
	Endif
	nColIni := 065
	nLinA4  := 000
	nColA4  := 000

	oPrint:StartPage()		// Inicia uma nova pagina
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Box((nLinIni + 0000)*nAL, (nColIni + 0010)*nAC, (nLinIni + nLinMax)*nAL, (nColIni + nColMax)*nAC)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega e Imprime Logotipo da Empresa                         ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fLogoEmp(@cFileLogo,, cLogoGH)

	If File(cFilelogo)
		oPrint:SayBitmap((nLinIni + 0050)*nAL, (nColIni + 0020)*nAC, cFileLogo, (400)*nAL, (090)*nAC) // Tem que estar abaixo do RootPath
	EndIf

	if nLayout == 2 // Papél A4
		nColA4:= -0065
		nLinA4:= 0
	Elseif nLayout ==3 //Carta
		nLinA4:= -0010
	Endif

	oPrint:Say((nLinIni + 0110)*nAL + nLinA4, (nColIni + (nColMax*0.4))*nAC, "GUIA DE CONSULTA", oFont02n,,,, 2) //"GUIA DE CONSULTA"
	oPrint:Say((nLinIni + 0090)*nAL + nLinA4, (nColIni + (nColMax*0.67))*nAC, "2- N?Guia no Prestador", oFont01) //"2- N?Guia no Prestador"
	oPrint:Say((nLinIni + 0090)*nAL + nLinA4, (nColIni + (nColMax*0.78))*nAC, aDados[nX, 02], oFont03n)

	oPrint:Box((nLinIni + 0165)*nAL + nLinA4, (nColIni + 0020)*nAC, (nLinIni + 0225)*nAL + nLinA4, (nColIni + (nColMax*0.16) - 0010)*nAC)
	oPrint:Say((nLinIni + 0185)*nAL + nLinA4, (nColIni + 0030)*nAC, "1 - Registro ANS", oFont01) //1 - Registro ANS
	oPrint:Say((nLinIni + 0217)*nAL + nLinA4, (nColIni + 0040)*nAC, IIf(Empty(aDados[nX, 01]),'|___|___|___|___|___|___|',aDados[nX, 01]), oFont04)
	oPrint:Box((nLinIni + 0165)*nAL + nLinA4, (nColIni + (nColMax*0.16))*nAC, (nLinIni + 0225)*nAL + nLinA4, (nColIni + (nColMax*0.64) - 0010)*nAC)
	oPrint:Say((nLinIni + 0185)*nAL + nLinA4, (nColIni + (nColMax*0.16) + 0010)*nAC, "3 - Número da Guia Atribuído pela Operadora", oFont01) //3 - Número da Guia Atribuído pela Operadora
	oPrint:Say((nLinIni + 0217)*nAL + nLinA4, (nColIni + (nColMax*0.16) + 0020)*nAC, IIf(Empty(aDados[nX, 03]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 03]), oFont04)

	oPrint:Say((nLinIni + 0245)*nAL + nLinA4, (nColIni + 0020)*nAC, "Dados do Beneficiário", oFont01) //Dados do Beneficiário
	oPrint:Box((nLinIni + 0255)*nAL + nLinA4, (nColIni + 0020)*nAC, (nLinIni + 0315)*nAL + nLinA4, (nColIni + (nColMax*0.48) - 0010)*nAC)
	oPrint:Say((nLinIni + 0275)*nAL + nLinA4, (nColIni + 0030)*nAC, "4 - Número da Carteira", oFont01) //4 - Número da Carteira
	oPrint:Say((nLinIni + 0307)*nAL + nLinA4, (nColIni + 0040)*nAC, IIf(Empty(aDados[nX, 04]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 04]), oFont04)
	oPrint:Box((nLinIni + 0255)*nAL + nLinA4, (nColIni + (nColMax*0.48))*nAC, (nLinIni + 0315)*nAL + nLinA4, (nColIni + (nColMax*0.70) - 0010)*nAC)
	oPrint:Say((nLinIni + 0275)*nAL + nLinA4, (nColIni + (nColMax*0.48) + 0010)*nAC, "5 - Validade da Carteira", oFont01) //5 - Validade da Carteira
	oPrint:Say((nLinIni + 0307)*nAL + nLinA4, (nColIni + (nColMax*0.48) + 0020)*nAC, IIf(Empty(aDados[nX, 05]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 05])), oFont04)
	oPrint:Box((nLinIni + 0255)*nAL + nLinA4, (nColIni + (nColMax*0.70))*nAC, (nLinIni + 0315)*nAL + nLinA4, (nColIni + (nColMax*0.92) - 0090)*nAC)
	oPrint:Say((nLinIni + 0275)*nAL + nLinA4, (nColIni + (nColMax*0.70) + 0010)*nAC, "6 - Atendimento a RN (Sim ou Não)", oFont01) //6 - Atendimento a RN (Sim ou Não)
	oPrint:Say((nLinIni + 0307)*nAL + nLinA4, (nColIni + (nColMax*0.70) + 0020)*nAC, IIf(Empty(aDados[nX, 06]),'|___|',aDados[nX, 06]), oFont04)

	oPrint:Box((nLinIni + 0325)*nAL + nLinA4, (nColIni + 0020)*nAC, (nLinIni + 0385)*nAL + nLinA4, (nColIni + (nColMax*0.70) - 0100)*nAC)
	oPrint:Say((nLinIni + 0345)*nAL + nLinA4, (nColIni + 0030)*nAC, "7 - Nome", oFont01) //7 - Nome
	oPrint:Say((nLinIni + 0377)*nAL + nLinA4, (nColIni + 0040)*nAC, aDados[nX, 07] , oFont04)
	
	oPrint:Box((nLinIni + 0325)*nAL + nLinA4, (nColIni + (nColMax*0.70) - 0090)*nAC, (nLinIni + 0385)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
	oPrint:Say((nLinIni + 0345)*nAL + nLinA4, (nColIni + (nColMax*0.70) - 0080)*nAC, "8 - Cartão Nacional de Saúde", oFont01) //8 - Cartão Nacional de Saúde
	oPrint:Say((nLinIni + 0377)*nAL + nLinA4, (nColIni + (nColMax*0.70) - 0080)*nAC, IIf(Empty(aDados[nX, 08]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 08]), oFont04)

	oPrint:Say((nLinIni + 0405)*nAL + nLinA4, (nColIni + 0020)*nAC, "Dados do Contratado", oFont01) //Dados do Contratado
	
	oPrint:Box((nLinIni + 0415)*nAL + nLinA4, (nColIni + 0020)*nAC, (nLinIni + 0475)*nAL + nLinA4, (nColIni + (nColMax*0.20) + 0290)*nAC)
	oPrint:Say((nLinIni + 0435)*nAL + nLinA4, (nColIni + 0030)*nAC, "9 - Código na Operadora", oFont01) //9 - Código na Operadora
	oPrint:Say((nLinIni + 0467)*nAL + nLinA4, (nColIni + IIf(Empty(aDados[nX, 09]),0022,0040))*nAC, IIf(Empty(aDados[nX, 09]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 09]), oFont04)
	
	oPrint:Box((nLinIni + 0415)*nAL + nLinA4, (nColIni + (nColMax*0.20) + 0300)*nAC, (nLinIni + 0475)*nAL + nLinA4, (nColIni + (nColMax*0.85) - 0060)*nAC)
	oPrint:Say((nLinIni + 0435)*nAL + nLinA4, (nColIni + (nColMax*0.20) + 0310)*nAC, "10 - Nome do Contratado", oFont01) //10 - Nome do Contratado
	oPrint:Say((nLinIni + 0467)*nAL + nLinA4, (nColIni + (nColMax*0.20) + 0320)*nAC, aDados[nX, 10], oFont04)
	
	oPrint:Box((nLinIni + 0415)*nAL + nLinA4, (nColIni + (nColMax*0.85) - 0050)*nAC, (nLinIni + 0475)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
	oPrint:Say((nLinIni + 0435)*nAL + nLinA4, (nColIni + (nColMax*0.85) - 0040)*nAC, "11 - Código CNES", oFont01) //11 - Código CNES
	oPrint:Say((nLinIni + 0467)*nAL + nLinA4, (nColIni + (nColMax*0.85) - 0030)*nAC, IIf(Empty(aDados[nX, 11]),'|___|___|___|___|___|___|___|',aDados[nX, 11]), oFont04)

	oPrint:Box((nLinIni + 0485)*nAL + nLinA4, (nColIni + 0020)*nAC, (nLinIni + 0545)*nAL + nLinA4, (nColIni + (nColMax*0.51) - 0310)*nAC)
	oPrint:Say((nLinIni + 0505)*nAL + nLinA4, (nColIni + 0030)*nAC, "12 - Nome do Profissional Executante", oFont01) //12 - Nome do Profissional Executante
	oPrint:Say((nLinIni + 0537)*nAL + nLinA4, (nColIni + 0040)*nAC, aDados[nX, 12], oFont04)
	
	oPrint:Box((nLinIni + 0485)*nAL + nLinA4, (nColIni + (nColMax*0.51) - 0300)*nAC, (nLinIni + 0545)*nAL + nLinA4, (nColIni + (nColMax*0.60) - 0260)*nAC)
	oPrint:Say((nLinIni + 0500)*nAL + nLinA4, (nColIni + (nColMax*0.51) - 0300)*nAC, "13 - Conselho", oFont01) //13 - Conselho
	oPrint:Say((nLinIni + 0517)*nAL + nLinA4, (nColIni + (nColMax*0.51) - 0300)*nAC, "Profissional", oFont01) //Profissional
	oPrint:Say((nLinIni + 0540)*nAL + nLinA4, (nColIni + (nColMax*0.51) - 0290)*nAC, IIf(Empty(aDados[nX, 13]),'|___|___|',aDados[nX, 13]), oFont04)
	
	oPrint:Box((nLinIni + 0485)*nAL + nLinA4, (nColIni + (nColMax*0.60) - 0350)*nAC, (nLinIni + 0545)*nAL + nLinA4, (nColIni + (nColMax*0.81) - 0010)*nAC)
	oPrint:Say((nLinIni + 0505)*nAL + nLinA4, (nColIni + (nColMax*0.60) - 0340)*nAC, "14 - Número no Conselho", oFont01) //14 - Número no Conselho
	oPrint:Say((nLinIni + 0537)*nAL + nLinA4, (nColIni + (nColMax*0.60) - IIf(Empty(aDados[nX, 14]),0327,0330))*nAC, IIf(Empty(aDados[nX, 14]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 14]), oFont04)
	
	oPrint:Box((nLinIni + 0485)*nAL + nLinA4, (nColIni + (nColMax*0.81) - 0040)*nAC, (nLinIni + 0545)*nAL + nLinA4, (nColIni + (nColMax*0.87) - 050)*nAC)
	oPrint:Say((nLinIni + 0505)*nAL + nLinA4, (nColIni + (nColMax*0.81) - 0040)*nAC, "15 - UF", oFont01) //15 - UF
	oPrint:Say((nLinIni + 0537)*nAL + nLinA4, (nColIni + (nColMax*0.81) - 0030)*nAC, IIf(Empty(aDados[nX, 15]),'|___|___|',aDados[nX, 15]), oFont04)
	
	oPrint:Box((nLinIni + 0485)*nAL + nLinA4, (nColIni + (nColMax*0.87) - 0040)*nAC, (nLinIni + 0545)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
	oPrint:Say((nLinIni + 0505)*nAL + nLinA4, (nColIni + (nColMax*0.87) - 0030)*nAC, "16 - Código CBO", oFont01) //16 - Código CBO
	
	If !EMPTY(aDados[nX, 04])
	   
	   cQuery := "SELECT BTU_CDTERM "
	   cQuery += "FROM " + RetSqlName("BTU") + " "
	   cQuery += "WHERE BTU_VLRSIS LIKE '%" + ALLTRIM(aDados[nX, 16]) + "%' AND D_E_L_E_T_ <> '*' "

	   // Compatibiliza a sintaxe da query para o banco de dados em uso.
	   cQuery := ChangeQuery(cQuery)

	   // Executa a query e retorna o conjunto de registros numa WorkArea denominada MOVIM,
	   // contendo os registros filtrados pela clausula WHERE.
	   dbUseArea(.T., "TOPCONN", TCGenQry( , , cQuery), "MOVIM", .F., .T.)

		aDados[nX, 16] := MOVIM->BTU_CDTERM
	
		dbSelectArea("MOVIM")
   		MOVIM->( DbCloseArea() )
	EndIf

	oPrint:Say((nLinIni + 0537)*nAL + nLinA4, (nColIni + (nColMax*0.87) - 0020)*nAC, IIf(Empty(aDados[nX, 16]),'|___|___|___|___|___|___|',aDados[nX, 16]), oFont04)

	oPrint:Say((nLinIni + 0565)*nAL + nLinA4, (nColIni + 0020)*nAC, "Hipóteses Diagnósticas", oFont01) //Hipóteses Diagnósticas
	oPrint:Box((nLinIni + 0575)*nAL + nLinA4, (nColIni + 0020)*nAC, (nLinIni + 0635)*nAL + nLinA4, (nColIni + (nColMax*0.23) - 0010)*nAC)
	oPrint:Say((nLinIni + 0590)*nAL + nLinA4, (nColIni + 0030)*nAC, "17 - Indicação de Acidente", oFont01) //17 - Indicação de Acidente
	oPrint:Say((nLinIni + 0605)*nAL + nLinA4, (nColIni + 0040)*nAC, "(acidente ou doença relacionada)", oFont01) //(acidente ou doença relacionada)
	oPrint:Say((nLinIni + 0630)*nAL + nLinA4, (nColIni + (nColMax*0.11))*nAC, IIf(Empty(aDados[nX, 17]),'|___|',aDados[nX, 17]), oFont04)

	oPrint:Say((nLinIni + 0655)*nAL + nLinA4, (nColIni + 0020)*nAC, "Dados do Atendimento / Procedimento Realizado", oFont01) //Dados do Atendimento / Procedimento Realizado
	oPrint:Box((nLinIni + 0665)*nAL + nLinA4, (nColIni + 0020)*nAC, (nLinIni + 0725)*nAL + nLinA4, (nColIni + (nColMax*0.23) - 0010)*nAC)
	oPrint:Say((nLinIni + 0685)*nAL + nLinA4, (nColIni + 0030)*nAC, "18 - Data do Atendimento", oFont01) //18 - Data do Atendimento
	oPrint:Say((nLinIni + 0717)*nAL + nLinA4, (nColIni + 0040)*nAC, IIf(Empty(aDados[nX, 18]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 18])), oFont04)
	oPrint:Box((nLinIni + 0665)*nAL + nLinA4, (nColIni + (nColMax*0.23))*nAC, (nLinIni + 0725)*nAL + nLinA4, (nColIni + (nColMax*0.35) - 0010)*nAC)
	oPrint:Say((nLinIni + 0685)*nAL + nLinA4, (nColIni + (nColMax*0.23) + 0010)*nAC, "19 - Tipo de Consulta", oFont01) //19 - Tipo de Consulta
	oPrint:Say((nLinIni + 0717)*nAL + nLinA4, (nColIni + (nColMax*0.23) + 0020)*nAC, IIf(Empty(aDados[nX, 19]),'|___|',aDados[nX, 19]), oFont04)
	oPrint:Box((nLinIni + 0665)*nAL + nLinA4, (nColIni + (nColMax*0.46))*nAC, (nLinIni + 0725)*nAL + nLinA4, (nColIni + (nColMax*0.53) - 0010)*nAC)
	oPrint:Say((nLinIni + 0685)*nAL + nLinA4, (nColIni + (nColMax*0.46) + 0010)*nAC, "20 - Tabela", oFont01) //20 - Tabela
	oPrint:Say((nLinIni + 0717)*nAL + nLinA4, (nColIni + (nColMax*0.46) + 0020)*nAC, IIf(Empty(aDados[nX, 20]),'|___|___|',aDados[nX, 20]), oFont04)
	oPrint:Box((nLinIni + 0665)*nAL + nLinA4, (nColIni + (nColMax*0.53))*nAC, (nLinIni + 0725)*nAL + nLinA4, (nColIni + (nColMax*0.78) - 0010)*nAC)
	oPrint:Say((nLinIni + 0685)*nAL + nLinA4, (nColIni + (nColMax*0.53) + 0010)*nAC, "21 - Código do Procedimento", oFont01) //21 - Código do Procedimento
	oPrint:Say((nLinIni + 0717)*nAL + nLinA4, (nColIni + (nColMax*0.53) + 0020)*nAC, IIf(Empty(aDados[nX, 21]),'|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 21]), oFont04)
	oPrint:Box((nLinIni + 0665)*nAL + nLinA4, (nColIni + (nColMax*0.78))*nAC, (nLinIni + 0725)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
	oPrint:Say((nLinIni + 0685)*nAL + nLinA4, (nColIni + (nColMax*0.78) + 0010)*nAC, "22 - Valor do Procedimento", oFont01) //22 - Valor do Procedimento
	oPrint:Say((nLinIni + 0717)*nAL + nLinA4, (nColIni + (nColMax*0.78) + 0020)*nAC, IIf(Empty(aDados[nX, 22]), '|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 22], "@E 99,999,999.99")), oFont04)

	oPrint:Box((nLinIni + 0735)*nAL + nLinA4, (nColIni + 0020)*nAC, (nLinIni + 1000)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
	oPrint:Say((nLinIni + 0755)*nAL + nLinA4, (nColIni + 0030)*nAC, "23 - Observação / Justificativa", oFont01) //23 - Observação / Justificativa
	
	If !Empty(aDados[nX, 23])
		For nI := 1 To MlCount(aDados[nX, 23], 100)
			cObs := MemoLine(aDados[nX, 23], 100, nI)
			oPrint:Say((nLinIni + 0800 + nLinObs)*nAL + nLinA4, (nColIni + 0040)*nAC, cObs, oFont04)
			nLinObs+=40
		Next nI
	Else
		oPrint:Say((nLinIni + 0800 + 0)*nAL + nLinA4, (nColIni + 0040)*nAC, REPLICATE('_',156), oFont04)
		oPrint:Say((nLinIni + 0800 + 40)*nAL + nLinA4, (nColIni + 0040)*nAC, REPLICATE('_',156), oFont04)
		oPrint:Say((nLinIni + 0800 + 80)*nAL + nLinA4, (nColIni + 0040)*nAC, REPLICATE('_',156), oFont04)
		oPrint:Say((nLinIni + 0800 + 120)*nAL + nLinA4, (nColIni + 0040)*nAC, REPLICATE('_',156), oFont04)
	EndIf
	
	oPrint:Box((nLinIni + 1010)*nAL + nLinA4, (nColIni + 0020)*nAC, (nLinIni + 1120)*nAL + nLinA4, (nColIni + (nColMax/2) - 0005)*nAC)
	oPrint:Say((nLinIni + 1030)*nAL + nLinA4, (nColIni + 0030)*nAC, "24 - Assinatura do Profissional Executante", oFont01) //24 - Assinatura do Profissional Executante
	oPrint:Box((nLinIni + 1010)*nAL + nLinA4, (nColIni + (nColMax/2) + 0005)*nAC, (nLinIni + 1120)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
	oPrint:Say((nLinIni + 1030)*nAL + nLinA4, (nColIni + (nColMax/2) + 0015)*nAC, "25 - Assinatura do Beneficiário ou Responsável", oFont01) //25 - Assinatura do Beneficiário ou Responsável

	oPrint:EndPage()	// Finaliza a pagina

Next nX


If lGerTXT .And. !lWeb
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Imprime Relatorio
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:Print()
Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Visualiza impressao grafica antes de imprimir
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:Preview()
EndIf

Return (cFileName)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ?PLSSADT  ?Autor ?Bruno Iserhardt       ?Data ?18.06.13 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ?Estrutura Relatório TISS 3.00.01 (Guia de Serv/SADT)        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?SigaPLS                                                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros?aDados - Array com as informações do relat´rio              ³±?
±±?         ?lGerTXT - Define se imprime direto sem passar pela tela	   ³±?
±±?         ?		 de configuracao/preview do relatorio 		       ³±?
±±?         ?nLayout - Define o formato de papél para impressao:         ³±?
±±?         ?          1 - Formato Ofício II (216x330mm)                 ³±?
±±?         ?          2 - Formato A4 (210x297mm)                        ³±?
±±?         ? 		 3 - Formato Carta (216x279mm)     			       ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PLSSADT(aDados, lGerTXT, nLayout, cLogoGH, lWeb, cPathRelW)

Local nLinMax
Local nColMax
Local nLinIni	:= 0 // Linha Lateral (inicial) Esquerda
Local nColIni	:= 0 // Coluna Lateral (inicial) Esquerda
Local nLimFim	:= 0
Local nColA4    := 0
Local nColSoma  := 0
Local nColSoma2 := 0
Local nLinA4	:= 0
Local cFileLogo
Local nLin
Local nOldLinIni
Local nI, nJ, nX//, nN
Local nV, nV1, nV2	//, nV3, nV4
Local cObs
Local oFont01
Local oFont02n
Local oFont03n
Local oFont04
Local oFont05
Local lImpnovo  :=.T.
Local nVolta    := 0
Local nP        := 0
Local nP1       := 0
Local nP2       := 0
Local nT        := 0
Local nT1       := 0
Local nT2       := 0
Local nT3       := 0
Local nT4       := 0
Local nProx     := 0
LOCAL cFileName	:= ""
LOCAL cRel      := "guisadt"
LOCAL cPathSrvJ := GETMV("MV_RELT")
LOCAL nAL		:= 0.25
LOCAL nAC		:= 0.24
Local lImpPrc   := .T.
Local cCodTab 	:= ""
Local cCodPro 	:= ""
Local cDescri	:= ""
Local lImpNAut	:= IIf(GetNewPar("MV_PLNAUT",0) == 0, .F., .T.) // 0 = Nao imprime procedimento nao autorizado 1 = Sim imprime
Local nLinSeq		:= 0
Local nSeq			:= 0
Local lPLSGTISS := ExistBlock("PLSGTISS")
PRIVATE aTabDup := PlsBusTerDup(SuperGetMv("MV_TISSCAB", .F. ,"87"))

DEFAULT lGerTXT 	:= .F.
DEFAULT nLayout 	:= 2
DEFAULT cLogoGH 	:= ""
DEFAULT lWeb		:= .F.
DEFAULT cPathRelW 	:= ""
DEFAULT aDados 	:= { {;
	"123456",; //1 - Registro ANS
	"12345678901234567890",; //2- N?Guia no Prestador
	"12345678901234567890",; //3- Número da guia principal
	CtoD("01/01/07"),; //4 - Data da Autorização
	"12345678901234567890",; //5-Senha
	CtoD("01/01/07"),; //6 - Data de Validade da Senha
	"12345678901234567890",; //7 - Número da Guia Atribuído pela Operadora
	"12345678901234567890",; //8 - Número da Carteira
	CtoD("12/12/07"),; //9 - Validade da Carteira
	Replicate("N",70),; //10 - Nome
	"123456789012345",; //11 - Cartão Nacional de Saúde
	"N",; //12 -Atendimento a RN
	"12345678901234",; //13 - Código na Operadora
	Replicate("N",70),; //14 - Nome do Contratado
	Replicate("N",70),; //15 - Nome do Profissional Solicitante
	"00",; //16 - Conselho Profissional
	"123456789012345",; //17 - Número no Conselho
	"UF",; //18 - UF
	"123456",; //19 - Código CBO
	"",; //20 - Assinatura do Profissional Solicitante
	"A",; //21 - Caráter do Atendimento
	CtoD("12/12/07"),; //22 - Data da Solicitação
	Replicate("A",500),; //23 - Indicação Clínica
	{ "10", "20", "30", "40", "50", "60" } ,; //24-Tabela
	{ "1234567890", "2345678901", "3456789012", "4567890123", "5678901234", "1111111111" },; //25- Código do Procedimento
	{ Replicate("M",60),Replicate("B",60),Replicate("C",60),Replicate("D",60),Replicate("E",60),Replicate("E",60) },; //26 - Descrição
	{ 111,111,11,1,1,2 },; //27-Qtde. Solic.
	{ 999,999,99,9,9,1 },; //28-Qtde. Aut.
	"123456789012345",; //29-Código na operadora
	Replicate("M",70),; //30-Nome do contratado
	"9999999",; //31-Código CNES
	"TA",; //32-Tipo de Atendimento
	"A",; //33 - Indicação de Acidente
	"C",; //34 - Tipo de consulta
	"AA",; //35 - Motivo de Encerramento do Atendimento
	{ CtoD("12/12/07"),CtoD("12/12/07"),CtoD("12/12/07"),CtoD("12/12/07"),CtoD("12/12/07") },; //36 - Data
	{ "00:00","01:00","02:00","03:00","04:00" },; //37 - Hora Inicial
	{ "02:00","04:00","06:00","99:00","00:99" },; //38 - Hora Final
	{ "TT","TT","TT","TT","TT" },; //39 - Tabela
	{ "1234567890","1234567890","1234567890","1234567890","1234567890" },;//40-Código do Procedimento
	{ Replicate("M",60),Replicate("B",60),Replicate("C",60),Replicate("D",60),Replicate("E",60) },;//41-Descrição
	{ 111, 222, 333, 444, 555},; //42 - Qtde.
	{ "0", "1", "2", "3", "4"},; //43-Via
	{ "0", "1", "2", "3", "4"},; //44-Tec.
	{ 0.99, 1.65 , 2.58 , 3.11 , 4.22},;//45- Fator Red./Acresc.
	{ 111111.99, 222222.65 , 333333.58 , 444444.11 , 555555.22},;//46-Valor Unitário (R$)
	{ 111111.99, 999999.65 , 888888.58 , 777777.11 , 666666.22},;//47-Valor Total (R$)
	{ "44", "33", "22", "11"},; //48-Seq.Ref
	{ "00", "11", "22", "33"},; //49-Grau Part.
	{ Replicate("M",14), Replicate("D",14), Replicate("C",14), Replicate("A",14)},; //50-Código na Operadora/CPF
	{ Replicate("B",70), Replicate("E",70), Replicate("X",70), Replicate("Z",70)},; //51-Nome do Profissional
	{ "12", "34", "56", "78"},; //52-Conselho Profissional
	{ Replicate("0",15), Replicate("1",15), Replicate("2",15), Replicate("3",15)},; //53-Número no Conselho
	{ "RS", "RJ", "SP", "RS"},; //54-UF
	{ "000000", "111111", "222222", "333333", "aaaaaa"},; //55-Código CBO
	{ CtoD("01/01/07"),CtoD("02/01/07"),CtoD("03/01/07"),CtoD("04/01/07"),CtoD("05/01/07"),CtoD("06/01/07"),CtoD("07/01/07"),CtoD("08/01/07"),CtoD("09/01/07"),CtoD("10/01/07")},; //56-Data de Realização de Procedimentos em Série
	"",;//57-Assinatura do Beneficiário ou Responsável
	Replicate("0",500),; //58-Observação / Justificativa
	12345678.90,; //59 - Total de Procedimentos (R$)
	12345678.90,; //60 - Total de Taxas e Aluguéis (R$)
	11111111.55,; //61 - Total de Materiais (R$)
	58745458.11,; //62- Total de OPME (R$)
	77777777.00,; //63 - Total de Medicamentos (R$)
	22222222.99,; //64 - Total de Gases Medicinais (R$)
	99999999.99 } } //65 - Total Geral (R$)

oFont01	:= TFont():New("Arial",  5,  5, , .F., , , , .T., .F.) // Normal

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Nao permite acionar a impressao quando for na web.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lWeb
	cPathSrvJ := cPathRelW
	cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
Else
	cFileName := cRel+CriaTrab(NIL,.F.)
EndIf

//						New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF] )
oPrint := FWMSPrinter():New ( cFileName			,			,	.F.				,cPathSrvJ	 	,	.T.				,			 ,				,			  ,			  ,	.F.			, 		, 				)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Tratamento para impressao via job
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//oPrint:lInJob  := lWeb
oPrint:lServer := lWeb
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Caminho do arquivo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
oPrint:cPathPDF := cPathSrvJ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Modo paisagem
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
oPrint:SetLandscape()

if nLayout ==2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Papél A4
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:SetPaperSize(9)
Elseif nLayout ==3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Papél Carta
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:SetPaperSize(1)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:SetPaperSize(14)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Device
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lWeb
	oPrint:setDevice(IMP_PDF)
	oPrint:lPDFAsPNG := .T.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Verifica se existe alguma impressora configurada para Impressao Grafica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If  !lWeb
	oPrint:Setup()
	If !(oPrint:nModalResult == 1)// Botao cancelar da janela de config. de impressoras.
		Return
	Else
		lImpnovo:=(oPrint:nModalResult == 1)
	Endif
EndIf

If oPrint:nPaperSize  == 9 // Papél A4
	nLinMax	:=	2000
	nColMax	:=	3365 //3508 //3380 //3365
	nLayout 	:= 2
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 05, 05, , .F., , , , .T., .F.) // Normal
	oFont05		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	oFont06		:= TFont():New("Arial", 06, 06, , .F., , , , .T., .F.) // Normal
Elseif oPrint:nPaperSize == 1 // Papel Carta
	nLinMax	:=	2000
	nColMax	:=	3175
	nLayout 	:= 3
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
	oFont05		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	oFont06		:= TFont():New("Arial", 06, 06, , .F., , , , .T., .F.) // Normal
Else // Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	nLinMax	:=	2435
	nColMax	:=	3765
	nLayout 	:= 1
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	oFont05		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	oFont06		:= TFont():New("Arial", 06, 06, , .F., , , , .T., .F.) // Normal
Endif

While lImpnovo

	lImpnovo:=.F.
	nVolta  += 1
	nT      += 5
	nT1     += 5
	nT2     += 5
	nT3     += 9
	nT4     += 9
	nProx   += 1

	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		For nI := 24 To 28
			If aDados[nX, nI] <> NIL .and. Len(aDados[nX, nI]) < nT
				For nJ := Len(aDados[nX, nI]) + 1 To nT
					If AllTrim(Str(nI)) $ "27,28"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 36 To 47
			If  aDados[nX, nI] <> NIL .and. Len(aDados[nX, nI]) < nT1
				For nJ := Len(aDados[nX, nI]) + 1 To nT1
					If AllTrim(Str(nI)) $ "36"
						aAdd(aDados[nX, nI], StoD(""))
					ElseIf AllTrim(Str(nI)) $ "42,45,46,47"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 48 To 55
			If aDados[nX][nI] != NIL 
				If Len(aDados[nX, nI]) < nT2 //17-09
					For nJ := Len(aDados[nX, nI]) + 1 To nT2
						aAdd(aDados[nX, nI], "")
					Next nJ
				EndIf
			EndIf
		Next nI

		If oPrint:Cprinter == "PDF" .OR. lWeb
			nLinIni	:= 150
			nLimFim	:= 400
		Else
			nLinIni	:= 050
			nLimFim	:= 300
		Endif


		nColIni	:= 080
		nColA4		:= 000
		nLinA4		:= 000
		nColSoma	:= 000
		nColSoma2	:= 000

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Inicia uma nova pagina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		oPrint:StartPage()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box((nLinIni + 0000)*nAL, (nColIni + 0000)*nAC, (nLimFim + nLinMax)*nAL, (nColIni + nColMax)*nAC)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega e Imprime Logotipo da Empresa                         ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fLogoEmp(@cFileLogo,, cLogoGH)

		If File(cFilelogo)
			oPrint:SayBitmap((nLinIni + 0050)*nAL, (nColIni + 0020)*nAC, cFileLogo, (400)*nAL, (090)*nAC) 	// Tem que estar abaixo do RootPath
		EndIf

		If nLayout == 2 // Papél A4
			nColA4    := -0395
			nLinA4    := -0010
			nColSoma  := -0300
			nColSoma2 := -0190
		Elseif nLayout == 3// Carta
			nColA4    := -0590
			nLinA4    := -0010
			nColSoma  := -0300
			nColSoma2 := -0190
		Endif

		oPrint:Say((nLinIni + 0050)*nAL, (nColIni + (nColMax*0.30))*nAC, "GUIA DE SERVIÇO PROFISSIONAL / SERVIÇO AUXILIAR DE", oFont02n,,,, 2) //GUIA DE SERVIÇO PROFISSIONAL / SERVIÇO AUXILIAR DE
		oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.36))*nAC, "DIAGNÓSTICO E TERAPIA - SP/SADT", oFont02n,,,, 2) //DIAGNÓSTICO E TERAPIA - SP/SADT
		oPrint:Say((nLinIni + 0050)*nAL, (nColIni + (nColMax*0.70))*nAC, "2- N?Guia no Prestador", oFont01) //"N?
		oPrint:Say((nLinIni + 0050)*nAL, (nColIni + (nColMax*0.79))*nAC, aDados[nX, 02], oFont03n)

		oPrint:Box((nLinIni + 0175)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0250)*nAL + nLinA4, (nColIni + (nColMax*0.1) - 0010)*nAC)
		oPrint:Say((nLinIni + 0170 + nLinA4)*nAL, (nColIni + 0015)*nAC, "1 - "+"Registro ANS", oFont01) //"Registro ANS"
		oPrint:Say((nLinIni + 0210 + nLinA4)*nAL, (nColIni + 0030)*nAC, Iif(Empty(aDados[nX, 01]),'|___|___|___|___|___|___|',aDados[nX, 01]), oFont04)
		
		oPrint:Box((nLinIni + 0175)*nAL + nLinA4, (nColIni + (nColMax*0.1))*nAC, (nLinIni + 0250)*nAL + nLinA4, (nColIni + (nColMax*0.37) + 0200)*nAC)
		oPrint:Say((nLinIni + 0170 + nLinA4)*nAL, (nColIni + (nColMax*0.1) + 0010)*nAC, "3 - "+"N?Guia Principal", oFont01) //"N?Guia Principal"
		oPrint:Say((nLinIni + 0210 + nLinA4)*nAL, (nColIni + (nColMax*0.1) + 0020)*nAC, Iif(Empty(aDados[nX, 03]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 03]), oFont04)

		oPrint:Box((nLinIni + 0260)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0335)*nAL + nLinA4, (nColIni + (nColMax*0.14) + 0036)*nAC)
		oPrint:Say((nLinIni + 0255 + nLinA4)*nAL, (nColIni + 0020)*nAC, "4 - Data da Autorização", oFont01) //"Data da Autorização"
		oPrint:Say((nLinIni + 0295 + nLinA4)*nAL, (nColIni + 0030)*nAC, Iif(Empty(aDados[nX, 04]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 04])), oFont04)
		
		oPrint:Box((nLinIni + 0260)*nAL + nLinA4, (nColIni + (nColMax*0.14) + 0050)*nAC, (nLinIni + 0335)*nAL + nLinA4, (nColIni + (nColMax*0.42) + 0220)*nAC)
		oPrint:Say((nLinIni + 0255 + nLinA4)*nAL, (nColIni + (nColMax*0.14) + 0060)*nAC, "5 - Senha", oFont01) //"Senha"
		oPrint:Say((nLinIni + 0295 + nLinA4)*nAL, (nColIni + (nColMax*0.14) + 0070)*nAC, Iif(Empty(aDados[nX, 05]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 05]), oFont04)
		
		oPrint:Box((nLinIni + 0260)*nAL + nLinA4, (nColIni + (nColMax*0.42) + 0250)*nAC, (nLinIni + 0335)*nAL + nLinA4, (nColIni + (nColMax*0.54) + 0350)*nAC)
		oPrint:Say((nLinIni + 0255 + nLinA4)*nAL, (nColIni + (nColMax*0.42) + 0260)*nAC, "6 - Data de Validade da Senha", oFont01) //"6 - Data de Validade da Senha"
		oPrint:Say((nLinIni + 0295 + nLinA4)*nAL, (nColIni + (nColMax*0.42) + 0270)*nAC, Iif(Empty(aDados[nX, 06]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 06])), oFont04)
		
		oPrint:Box((nLinIni + 0260)*nAL + nLinA4, (nColIni + (nColMax*0.54) + 0390)*nAC, (nLinIni + 0335)*nAL + nLinA4, (nColIni + (nColMax*0.82) + 0562)*nAC)
		oPrint:Say((nLinIni + 0255 + nLinA4)*nAL, (nColIni + (nColMax*0.54) + 0400)*nAC, "7 - Número da Guia Atribuído pela Operadora", oFont01) //"7 - Número da Guia Atribuído pela Operadora"
		oPrint:Say((nLinIni + 0295 + nLinA4)*nAL, (nColIni + (nColMax*0.54) + 0410)*nAC, Iif(Empty(aDados[nX, 07]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 07]), oFont04)

		AddTBrush(oPrint, (nLinIni + 0310 + nLinA4)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0365)*nAL + nLinA4, (nColIni + nColMax)*nAC)
		oPrint:Say((nLinIni + 0330 + nLinA4)*nAL, (nColIni + 0010)*nAC, "Dados do Beneficiário", oFont01) //"Dados do Beneficiário"
		
		oPrint:Box((nLinIni + 0370)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0447)*nAL + nLinA4, (nColIni + (nColMax*0.34) - 0010)*nAC)
		oPrint:Say((nLinIni + 0365 + nLinA4)*nAL, (nColIni + 0020)*nAC, "8 - Número da Carteira", oFont01) //"8 - Número da Carteira"
		oPrint:Say((nLinIni + 0405 + nLinA4)*nAL, (nColIni + 0030)*nAC, Iif(Empty(aDados[nX, 08]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 08]), oFont04)
		
		oPrint:Box((nLinIni + 0370)*nAL + nLinA4, (nColIni + (nColMax*0.34))*nAC, (nLinIni + 0447)*nAL + nLinA4, (nColIni + (nColMax*0.49) - 0010)*nAC)
		oPrint:Say((nLinIni + 0365 + nLinA4)*nAL, (nColIni + (nColMax*0.34) + 0010)*nAC, "9 - Validade da Carteira", oFont01) //"9 - Validade da Carteira"
		oPrint:Say((nLinIni + 0405 + nLinA4)*nAL, (nColIni + (nColMax*0.34) + 0020)*nAC, Iif(Empty(aDados[nX, 09]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 09])), oFont04)
		
		oPrint:Box((nLinIni + 0370)*nAL + nLinA4, (nColIni + (nColMax*0.49))*nAC, (nLinIni + 0447)*nAL + nLinA4, (nColIni + (nColMax*0.73) - 0010)*nAC)
		oPrint:Say((nLinIni + 0365 + nLinA4)*nAL, (nColIni + (nColMax*0.49) + 0010)*nAC, "10 - Nome", oFont01) //"10 - Nome"
		oPrint:Say((nLinIni + 0405 + nLinA4)*nAL, (nColIni + (nColMax*0.49) + 0020)*nAC, aDados[nX, 10], oFont04)
		
		oPrint:Box((nLinIni + 0370)*nAL + nLinA4, (nColIni + (nColMax*0.73))*nAC, (nLinIni + 0447)*nAL + nLinA4, (nColIni + (nColMax*0.95) - 0010)*nAC)
		oPrint:Say((nLinIni + 0365 + nLinA4)*nAL, (nColIni + (nColMax*0.73) + 0010)*nAC, "11 - Cartão Nacional de Saúde", oFont01) //"11 - Cartão Nacional de Saúde"
		oPrint:Say((nLinIni + 0405 + nLinA4)*nAL, (nColIni + (nColMax*0.73) + 0020)*nAC, Iif(Empty(aDados[nX, 11]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 11]), oFont06)
		
		oPrint:Box((nLinIni + 0370)*nAL + nLinA4, (nColIni + (nColMax*0.95))*nAC, (nLinIni + 0447)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
		oPrint:Say((nLinIni + 0365 + nLinA4)*nAL, (nColIni + (nColMax*0.95) + 0010)*nAC, "12 -Atendimento", oFont01) //"12 -Atendimento a RN"
		oPrint:Say((nLinIni + 0385 + nLinA4)*nAL, (nColIni + (nColMax*0.95) + 0010)*nAC, "a RN", oFont01) //"8 - Número da Carteira"
		oPrint:Say((nLinIni + 0405 + nLinA4)*nAL, (nColIni + (nColMax*0.95) + 0050)*nAC, Iif(Empty(aDados[nX, 12]),'|___|',aDados[nX, 12]), oFont04)

		AddTBrush(oPrint, (nLinIni + 0420 + nLinA4)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0475)*nAL + nLinA4, (nColIni + nColMax)*nAC)
		oPrint:Say((nLinIni + 0440 + nLinA4)*nAL, (nColIni + 0010)*nAC, "Dados do Solicitante", oFont01) //"Dados do Solicitante"
		
		oPrint:Box((nLinIni + 0480)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0557)*nAL + nLinA4, (nColIni + (nColMax*0.30) - 0010)*nAC)
		oPrint:Say((nLinIni + 0475 + nLinA4)*nAL, (nColIni + 0020)*nAC, "13 - Código na Operadora", oFont01) //"13 - Código na Operadora"
		oPrint:Say((nLinIni + 0515 + nLinA4)*nAL, (nColIni + 0030)*nAC, Iif(Empty(aDados[nX, 13]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 13]), oFont04)
		
		oPrint:Box((nLinIni + 0480)*nAL + nLinA4, (nColIni + (nColMax*0.30))*nAC, (nLinIni + 0557)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
		oPrint:Say((nLinIni + 0475 + nLinA4)*nAL, (nColIni + (nColMax*0.30) + 0010)*nAC, "14 - Nome do Contratado", oFont01) //"14 - Nome do Contratado"
		oPrint:Say((nLinIni + 0515 + nLinA4)*nAL, (nColIni + (nColMax*0.30) + 0020)*nAC, aDados[nX, 14], oFont04)

		oPrint:Box((nLinIni + 0565)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0642)*nAL + nLinA4, (nColIni + (nColMax*0.30) - 0010)*nAC)
		oPrint:Say((nLinIni + 0560 + nLinA4)*nAL, (nColIni + 0020)*nAC, "15 - Nome do Profissional Solicitante", oFont01) //"15 - Nome do Profissional Solicitante"
		oPrint:Say((nLinIni + 0600 + nLinA4)*nAL, (nColIni + 0030)*nAC, aDados[nX, 15], oFont04)
		
		oPrint:Box((nLinIni + 0565)*nAL + nLinA4, (nColIni + (nColMax*0.30))*nAC, (nLinIni + 0642)*nAL + nLinA4, (nColIni + (nColMax*0.36) - 0010)*nAC)
		oPrint:Say((nLinIni + 0550 + nLinA4)*nAL, (nColIni + (nColMax*0.30) + 0010)*nAC, "16 - Conselho", oFont01) //"16 - Conselho Profissional"
		oPrint:Say((nLinIni + 0570 + nLinA4)*nAL, (nColIni + (nColMax*0.30) + 0010)*nAC, "Profissional", oFont01) //"16 - Conselho Profissional"
		oPrint:Say((nLinIni + 0600 + nLinA4)*nAL, (nColIni + (nColMax*0.30) + 0020)*nAC, Iif(Empty(aDados[nX, 16]),'|___|___|',aDados[nX, 16]), oFont04)
		
		oPrint:Box((nLinIni + 0565)*nAL + nLinA4, (nColIni + (nColMax*0.36))*nAC, (nLinIni + 0642)*nAL + nLinA4, (nColIni + (nColMax*0.63) - 0010)*nAC)
		oPrint:Say((nLinIni + 0560 + nLinA4)*nAL, (nColIni + (nColMax*0.36) + 0010)*nAC, "17 - Número no Conselho", oFont01) //"17 - Número no Conselho"
		oPrint:Say((nLinIni + 0600 + nLinA4)*nAL, (nColIni + (nColMax*0.36) + 0020)*nAC, Iif(Empty(aDados[nX, 17]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 17]), oFont04)
		
		oPrint:Box((nLinIni + 0565)*nAL + nLinA4, (nColIni + (nColMax*0.63))*nAC, (nLinIni + 0642)*nAL + nLinA4, (nColIni + (nColMax*0.68) - 0010)*nAC)
		oPrint:Say((nLinIni + 0560 + nLinA4)*nAL, (nColIni + (nColMax*0.63) + 0010)*nAC, "18 - UF", oFont01) //"18 - UF"
		oPrint:Say((nLinIni + 0600 + nLinA4)*nAL, (nColIni + (nColMax*0.63) + 0020)*nAC, Iif(Empty(aDados[nX, 18]),'|___|___|',aDados[nX, 18]), oFont04)
		
		oPrint:Box((nLinIni + 0565)*nAL + nLinA4, (nColIni + (nColMax*0.68))*nAC, (nLinIni + 0642)*nAL + nLinA4, (nColIni + (nColMax*0.80) - 0010)*nAC)
		oPrint:Say((nLinIni + 0560 + nLinA4)*nAL, (nColIni + (nColMax*0.68) + 0010)*nAC, "19 - Código CBO", oFont01) //"19 - Código CBO"
	   /*cQuery := "SELECT BTU_CDTERM "
	   cQuery += "FROM " + RetSqlName("BTU") + " "
	   cQuery += "WHERE BTU_VLRSIS LIKE '%" + ALLTRIM(aDados[nX, 19]) + "%' AND D_E_L_E_T_ <> '*' "

	   // Compatibiliza a sintaxe da query para o banco de dados em uso.
	   cQuery := ChangeQuery(cQuery)

	   // Executa a query e retorna o conjunto de registros numa WorkArea denominada MOVIM,
	   // contendo os registros filtrados pela clausula WHERE.
	   dbUseArea(.T., "TOPCONN", TCGenQry( , , cQuery), "MOVIM", .F., .T.)



		aDados[nX, 19] := MOVIM->BTU_CDTERM

		dbSelectArea("MOVIM")
   		dbCloseArea()*/

		oPrint:Say((nLinIni + 0600 + nLinA4)*nAL, (nColIni + (nColMax*0.68) + 0020)*nAC, Iif(Empty(aDados[nX, 19]),'|___|___|___|___|___|___|',aDados[nX, 19]), oFont04)
		
		oPrint:Box((nLinIni + 0565)*nAL + nLinA4, (nColIni + (nColMax*0.80))*nAC, (nLinIni + 0642)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
		oPrint:Say((nLinIni + 0560 + nLinA4)*nAL, (nColIni + (nColMax*0.80) + 0010)*nAC, "20 - Assinatura do Profissional Solicitante", oFont01) //"20 - Assinatura do Profissional Solicitante"

		AddTBrush(oPrint, (nLinIni + 0615 + nLinA4)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0670)*nAL + nLinA4, (nColIni + nColMax)*nAC)
		oPrint:Say((nLinIni + 0635 + nLinA4)*nAL, (nColIni + 0010)*nAC, "Dados da Solicitação / Procedimentos e Exames Solicitados", oFont01) //"Dados da Solicitação / Procedimentos e Exames Solicitados"
		oPrint:Box((nLinIni + 0675)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 0752)*nAL + nLinA4, (nColIni + (nColMax*0.08) - 0010)*nAC)
		oPrint:Say((nLinIni + 0665 + nLinA4)*nAL, (nColIni + 0020)*nAC, "21 - Caráter do", oFont01) //"21 - Caráter do "
		oPrint:Say((nLinIni + 0685 + nLinA4)*nAL, (nColIni + 0020)*nAC, "Atendimento", oFont01) //"8 - Número da Carteira"
		oPrint:Say((nLinIni + 0710 + nLinA4)*nAL, (nColIni + 0080)*nAC, Iif(Empty(aDados[nX, 21]),'|___|',aDados[nX, 21]), oFont04)
		
		oPrint:Box((nLinIni + 0675)*nAL + nLinA4, (nColIni + (nColMax*0.08))*nAC, (nLinIni + 0752)*nAL + nLinA4, (nColIni + (nColMax*0.25) - 0010)*nAC)
		oPrint:Say((nLinIni + 0665 + nLinA4)*nAL, (nColIni + (nColMax*0.08) + 0010)*nAC, "22 - Data da Solicitação", oFont01) //"22 - Data da Solicitação"
		oPrint:Say((nLinIni + 0710 + nLinA4)*nAL, (nColIni + (nColMax*0.08) + 0020)*nAC, Iif(Empty(aDados[nX, 22]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 22])), oFont04)
		
		oPrint:Box((nLinIni + 0675)*nAL + nLinA4, (nColIni + (nColMax*0.25))*nAC, (nLinIni + 0752)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
		oPrint:Say((nLinIni + 0665 + nLinA4)*nAL, (nColIni + (nColMax*0.25) + 0010)*nAC, "23 - Indicação Clínica", oFont01) //"23 - Indicação Clínica"
		oPrint:Say((nLinIni + 0710 + nLinA4)*nAL, (nColIni + (nColMax*0.25) + 0020)*nAC, aDados[nX, 23], oFont04)

		oPrint:Box((nLinIni + 0760)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1000)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
		oPrint:Say((nLinIni + 0760 + nLinA4)*nAL, (nColIni + (nColMax*0.02))*nAC, "24-Tabela", oFont01) //"24-Tabela"
		oPrint:Say((nLinIni + 0760 + nLinA4)*nAL, (nColIni + (nColMax*0.06))*nAC, "25- Código do Procedimento", oFont01) //"25- Código do Procedimento"
		oPrint:Say((nLinIni + 0760 + nLinA4)*nAL, (nColIni + (nColMax*0.23))*nAC, "26 - Descrição", oFont01) //"26 - Descrição"
		oPrint:Say((nLinIni + 0760 + nLinA4)*nAL, (nColIni + (nColMax*0.85))*nAC, "27-Qtde. Solic.", oFont01) //"27-Qtde. Solic."
		oPrint:Say((nLinIni + 0760 + nLinA4)*nAL, (nColIni + (nColMax*0.92))*nAC, "28-Qtde. Aut.", oFont01) //"28-Qtde. Aut."

		nOldLinIni := nLinIni

		if nVolta = 1
			nV:=1
		Endif

		cOper := substr(aDados[nX, 2],1,4)
		cAno  := substr(aDados[nX, 2],6,4)
		cMes  := substr(aDados[nX, 2],11,2)
		cAut  := substr(aDados[nX, 2],14,8)
		lLibera := .f.

// ATENÇÃO!!! Não dar manutenção nessa codificação! Devemos manter os tratamentos nas tabelas B7A e B7B (Tipos de guias) - Thiago Fonseca 21.01.15
		//Realizo a consulta na BEA
		DbSelectArea("BEA")
		BEA->(dbSetOrder(1))
		If BEA->(DbSeek(xFilial("BEA")+cOper+cAno+cMes+cAut))
			If BEA->BEA_LIBERA == '0'
				//se eh uma execucao eu tenho que refazer os procedimentos que foram solicitados
				If !Empty(BEA->BEA_NRLBOR)
					xChave := alltrim(BEA->BEA_NRLBOR)
				Else
					xChave := alltrim(cOper+cAno+cMes+cAut)
				Endif
			Else
				//se eh uma solicitacao eu tenho que refazer os procedimentos que foram solicitados e autorizados
				xChave := alltrim(cOper+cAno+cMes+cAut)
				lLibera := .t.
			Endif

			BE2->(DbSetORder(1))
			if !Empty(xChave) .and. BE2->(MsSeek(xFilial('BE2')+alltrim(xChave)))
				aDados[nX, 24] := {}
				aDados[nX, 25] := {}
				aDados[nX, 26] := {}
				aDados[nX, 27] := {}
				aDados[nX, 28] := {}
				While !BE2->(Eof()) .and. xFilial('BE2')+xChave == BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)
					If (BE2->BE2_STATUS == '0' .And. lImpNAut) .Or. BE2->BE2_STATUS == '1'

						BD6->(DbSetOrder(6))
						If BD6->(MsSeek(xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)+'1'+BE2->(BE2_CODPAD+BE2_CODPRO))) .and. !Empty(BD6->BD6_SLVPAD)
							//ALTERACOES DO DAHER +++++++++++++++ COMENTEI AQUI PARA VOCES OBSERVAREM OQ UE DEVE SER FEITO NOS DEMAIS FONTES/PONTOS DO PROGRAMA
							//cCodTab := PLSIMPVINC("BR4","87"	,	BD6->BD6_CODPAD					,.F.)
							//cCodPro := PLSIMPVINC("BR8",cCodTab	,	BD6->BD6_CODPAD+BD6->BD6_CODPRO	,.F.)
							//cDescri := PLSIMPVINC("BR8",cCodTab	,	BD6->BD6_CODPAD+BD6->BD6_CODPRO	,.T.)  
							
							cPadBkp := PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",  BD6->BD6_CODPAD,.T.)
							cCodPro	:= PLSGETVINC("BTU_CDTERM", "BR8", .F., '',  BD6->BD6_CODPRO, .F. ,aTabDup, @cPadBkp,alltrim(cPadBkp)+BD6->BD6_CODPRO)
							cCodTab := cPadBkp
							cDescri	:= PLSGETVINC("BTQ_DESTER", "BR8", .F., '',  BD6->BD6_DESPRO)
			
			
						Else
							//ALTERACOES DO DAHER +++++++++++++++ COMENTEI AQUI PARA VOCES OBSERVAREM OQ UE DEVE SER FEITO NOS DEMAIS FONTES/PONTOS DO PROGRAMAtotvs								
							//cCodTab := PLSIMPVINC("BR4","87"	,	BE2->BE2_CODPAD					,.F.)
							//cCodPro := PLSIMPVINC("BR8",cCodTab	,	BE2->BE2_CODPAD+BE2->BE2_CODPRO	,.F.)
							//cDescri := PLSIMPVINC("BR8",cCodTab	,	BE2->BE2_CODPAD+BE2->BE2_CODPRO	,.T.)
							cPadBkp := PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",  BD6->BD6_CODPAD,.T.)
							cCodPro	:= PLSGETVINC("BTU_CDTERM", "BR8", .F., '',  BD6->BD6_CODPRO, .F. ,aTabDup, @cPadBkp,alltrim(cPadBkp)+BD6->BD6_CODPRO)
							cCodTab := cPadBkp
							cDescri	:= PLSGETVINC("BTQ_DESTER", "BR8", .F., '',  BD6->BD6_DESPRO)
						Endif
					
						aAdd(aDados[nX, 24], cCodTab)
						aAdd(aDados[nX, 25], cCodPro)
						aAdd(aDados[nX, 26], cDescri)
						aAdd(aDados[nX, 27], BE2->BE2_QTDSOL)
						aAdd(aDados[nX, 28], IIf(BE2->BE2_STATUS = '1',BE2->BE2_QTDSOL,0))
						
					Endif
					BE2->(DbSkip())
				Enddo
				For nI := 24 To 28
					If Len(aDados[nX, nI]) < nT
						For nJ := Len(aDados[nX, nI]) + 1 To nT
							If AllTrim(Str(nI)) $ "27,28"
								aAdd(aDados[nX, nI], 0)
							Else
								aAdd(aDados[nX, nI], "")
							EndIf
						Next nJ
					EndIf
				Next nI
			Endif
		Endif

		For nP := nV To nT
			oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + 0025)*nAC, AllTrim(Str(nP)) + " - ", oFont01)
			oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + (nColMax*0.020))*nAC, Iif(Empty(aDados[nX, 24, nP]),'|___|___|',aDados[nX, 24, nP]), oFont04)
			oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + (nColMax*0.06))*nAC, Iif(Empty(aDados[nX, 25, nP]),'|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 25, nP]), oFont04)
			oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + (nColMax*0.23))*nAC, Iif(aDados[nX, 26] = NIL .or. Empty(aDados[nX, 26, nP]),REPLICATE('_',130),aDados[nX, 26, nP]), oFont04)
			oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + (nColMax*0.85))*nAC, IIf(Empty(aDados[nX, 27, nP]) .AND. EMPTY(aDados[nX, 25, nP]), '|___|___|___|', Transform(aDados[nX, 27, nP], "@E 9999.99")), oFont04,,,,1)
			oPrint:Say((nLinIni + 0800 + nLinA4)*nAL, (nColIni + (nColMax*0.92))*nAC, IIf(Empty(aDados[nX, 28, nP]) .AND. EMPTY(aDados[nX, 25, nP]), '|___|___|___|', Transform(aDados[nX, 28, nP], "@E 9999.99")), oFont04,,,,1)

			nLinIni += 40
		Next nP

		if nT < Len(aDados[nX, 24]).or. lImpnovo
			nV:=nP
			lImpnovo:=.T.
		Endif

		nLinIni := nOldLinIni

		AddTBrush(oPrint, (nLinIni + 0980 + nLinA4)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1035)*nAL + nLinA4, (nColIni + nColMax)*nAC)
		oPrint:Say((nLinIni + 1000 + nLinA4)*nAL, (nColIni + 0010)*nAC, "Dados do Contratado Executante", oFont01) //"Dados do Contratado Executante"
		
		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1118)*nAL + nLinA4, (nColIni + (nColMax*0.30) - 0010)*nAC)
		oPrint:Say((nLinIni + 1035 + nLinA4)*nAL, (nColIni + 0020)*nAC, "29 - Código na Operadora", oFont01) //"29 - Código na Operadora"
		If !lLibera
			oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + 0030)*nAC, Iif(Empty(aDados[nX, 29]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 29]), oFont04)
		Endif

		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + (nColMax*0.30))*nAC, (nLinIni + 1118)*nAL + nLinA4, (nColIni + (nColMax*0.87) - 0010)*nAC)
		oPrint:Say((nLinIni + 1035 + nLinA4)*nAL, (nColIni + (nColMax*0.30) + 0010)*nAC, "30 - Nome do Contratado", oFont01) //"30 - Nome do Contratado"

		If !lLibera
			oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + (nColMax*0.30) + 0020)*nAC, aDados[nX, 30], oFont04)
		Endif

		oPrint:Box((nLinIni + 1040)*nAL + nLinA4, (nColIni + (nColMax*0.87))*nAC, (nLinIni + 1118)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
		oPrint:Say((nLinIni + 1035 + nLinA4)*nAL, (nColIni + (nColMax*0.87) + 0010)*nAC, "31 - Código CNES", oFont01) //"31 - Código CNES"
		oPrint:Say((nLinIni + 1075 + nLinA4)*nAL, (nColIni + (nColMax*0.87) + 0020)*nAC, Iif(Empty(aDados[nX, 31]),'|___|___|___|___|___|___|___|',aDados[nX, 31]), oFont04)
		
		AddTBrush(oPrint, (nLinIni + 1095 + nLinA4)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1149.1)*nAL + nLinA4, (nColIni + nColMax)*nAC)
		oPrint:Say((nLinIni + 1110 + nLinA4)*nAL, (nColIni + 0010)*nAC, "Dados do Atendimento", oFont01) //"Dados do Atendimento"
		oPrint:Box((nLinIni + 1150)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1226)*nAL + nLinA4, (nColIni + (nColMax*0.08) - 0010)*nAC)
		oPrint:Say((nLinIni + 1145 + nLinA4)*nAL, (nColIni + 0020)*nAC, "32-Tipo de Atendimento", oFont01) //"32-Tipo de Atendimento"
		oPrint:Say((nLinIni + 1185 + nLinA4)*nAL, (nColIni + 0100)*nAC, Iif(Empty(aDados[nX, 32]),'|___|',aDados[nX, 32]), oFont04)
		oPrint:Box((nLinIni + 1150)*nAL + nLinA4, (nColIni + (nColMax*0.08))*nAC, (nLinIni + 1226)*nAL + nLinA4, (nColIni + (nColMax*0.29) - 0010)*nAC)
		oPrint:Say((nLinIni + 1145 + nLinA4)*nAL, (nColIni + (nColMax*0.08) + 0010)*nAC, "33 - Indicação de Acidente (acidente ou doença relacionada", oFont01) //"33 - Indicação de Acidente (acidente ou doença relacionada"
		oPrint:Say((nLinIni + 1185 + nLinA4)*nAL, (nColIni + (nColMax*0.08) + 0020)*nAC, Iif(Empty(aDados[nX, 33]),'|___|',aDados[nX, 33]), oFont04)

		oPrint:Box((nLinIni + 1150)*nAL + nLinA4, (nColIni + (nColMax*0.29))*nAC, (nLinIni + 1226)*nAL + nLinA4, (nColIni + (nColMax*0.36) - 0010)*nAC)
		oPrint:Say((nLinIni + 1145 + nLinA4)*nAL, (nColIni + (nColMax*0.29) + 0010)*nAC, "34 - Tipo de Consulta", oFont01) //"34 - Tipo de Consulta"
		oPrint:Say((nLinIni + 1185 + nLinA4)*nAL, (nColIni + (nColMax*0.29) + 0020)*nAC, Iif(Empty(aDados[nX, 34]),'|___|',aDados[nX, 34]), oFont04)

		oPrint:Box((nLinIni + 1150)*nAL + nLinA4, (nColIni + (nColMax*0.36))*nAC, (nLinIni + 1226)*nAL + nLinA4, (nColIni + (nColMax*0.53) - 0010)*nAC)
		oPrint:Say((nLinIni + 1145 + nLinA4)*nAL, (nColIni + (nColMax*0.36) + 0010)*nAC, "35 - Motivo de Encerramento do Atendimento", oFont01) //"35 - Motivo de Encerramento do Atendimento"
		oPrint:Say((nLinIni + 1185 + nLinA4)*nAL, (nColIni + (nColMax*0.36) + 0020)*nAC, Iif(Empty(aDados[nX, 35]),'|___|___|',aDados[nX, 35]), oFont04)

		AddTBrush(oPrint, (nLinIni + 1200 + nLinA4)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1260)*nAL + nLinA4, (nColIni + nColMax)*nAC)
		oPrint:Say((nLinIni + 1220 + nLinA4)*nAL, (nColIni + 0010)*nAC, "Dados da Execução / Procedimentos e Exames Realizados", oFont01) //Dados da Execução / Procedimentos e Exames Realizados
		oPrint:Box((nLinIni + 1265)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1500)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
		oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.02))*nAC, "36-Data", oFont01) //"36-Data"
		oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.140))*nAC, "37-Hora Inicial", oFont01) //"37-Hora Inicial"
		oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.190))*nAC, "38-Hora Final", oFont01) //"38-Hora Final"
		oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.24))*nAC, "39-Tabela", oFont01) //"39-Tabela"
		oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.28))*nAC, "40-Código do Procedimento", oFont01) //"40-Código do Procedimento"
		oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.39))*nAC, "41-Descrição", oFont01) //"41-Descrição"
		oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.600))*nAC, "42 - Qtde.", oFont01) //"42 - Qtde."
		oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.645))*nAC, "43-Via", oFont01) //"43-Via"
		oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.67))*nAC, "44-Tec.", oFont01) //"44-Tec."
		oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.695))*nAC, "45- Fator Red./Acresc.", oFont01) //"45- Fator Red./Acresc."
		oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.76))*nAC, "46-Valor Unitário (R$)", oFont01) //"46-Valor Unitário (R$)"
		oPrint:Say((nLinIni + 1265 + nLinA4)*nAL, (nColIni + (nColMax*0.87))*nAC, "47-Valor Total (R$)", oFont01) //"47-Valor Total (R$)"

		nOldLinIni := nLinIni

		if nVolta==1
			nV1:=1
		Endif

		If lPLSGTISS
			lImpPrc := ExecBlock("PLSGTISS",.F.,.F.,{"02",lImpPrc})
		EndIf

		If lImpPrc

			For nP1 := nV1 To nT1
				If !lLibera
					cCodPad := ''
					cCodPro := ''
					If !Empty(aDados[nX, 40, nP1])
						//aqui ocorre um outro problema.. la na b7a e b7b no plsa446 ele busca primeiro o codpad.. mas o codpad as vezes pode vir errado
						//pois pode ter mais de um de-para entao aqui tem q se fazer a busca pelo codigo pad correto
						//ou seja, vou desconsiderar o de-para feito no 466 e vou fazer o de-para denovo por aqui
						DbSelectArea("BEA")
						BEA->(dbSetOrder(1))
						If BEA->(DbSeek(xFilial("BEA")+cOper+cAno+cMes+cAut))
							cCodLdp := BEA->BEA_CODLDP
							cCodPeg := BEA->BEA_CODPEG
							cNumero := BEA->BEA_NUMGUI
							cOriMov := BEA->BEA_ORIMOV
							BD6->(DbSetORder(1))
							if BD6->(MsSeek(xFilial('BD6')+cOper+cCodLdp+cCodPeg+cNumero+cOriMov+aDados[nX, 48, nP1]))
								cPadBkp := PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",  BD6->BD6_CODPAD,.T.)
								cCodPro	:= PLSGETVINC("BTU_CDTERM", "BR8", .F., '',  BD6->BD6_CODPRO, .F. ,aTabDup, @cPadBkp,alltrim(cPadBkp)+BD6->BD6_CODPRO)
								cCodPad := cPadBkp
							Else
								cCodPad := aDados[nX, 39, nP1]
								cCodPro := aDados[nX, 40, nP1] 							
							Endif
						Endif	
					Endif
						oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + 0015)*nAC, AllTrim(Str(nP1)) + " - ", oFont01)
						oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.020))*nAC, IIf(Empty(aDados[nX, 36, nP1]), '|___|___|/|___|___|/|___|___|___|___|', DtoC(aDados[nX, 36, nP1])), oFont06)
						oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.140))*nAC, IIf(Empty(aDados[nX, 37, nP1]), '|__|__|:|__|__|', Transform(aDados[nX, 37, nP1], "@R 99:99")), oFont06)
						oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.190))*nAC, IIf(Empty(aDados[nX, 38, nP1]), '|__|__|:|__|__|', Transform(aDados[nX, 38, nP1], "@R 99:99")), oFont06)
						oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.24))*nAC, Iif(Empty(cCodPad),'|___|___|',cCodPad), oFont06)
						oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.28))*nAC, Iif(Empty(cCodPro),'|__|__|__|__|__|__|__|__|__|__|',cCodPro), oFont06)
						oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.39))*nAC, Iif(aDados[nX, 41] = NIL .or. Empty(SUBSTR(aDados[nX, 41, nP1],1,51)),REPLICATE('_',50),SUBSTR(aDados[nX, 41, nP1],1,51)), oFont06)
						oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.600))*nAC, IIf(Empty(aDados[nX, 42, nP1]), '|___|___|__|', Transform(aDados[nX, 42, nP1], "@E 9999.99")), oFont06,,,,1)
						oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.645))*nAC, Iif(Empty(aDados[nX, 43, nP1]),'|___|',aDados[nX, 43, nP1]), oFont06)
						oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.67))*nAC, Iif(Empty(aDados[nX, 44, nP1]),'|___|',aDados[nX, 44, nP1]), oFont06)
						oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.695))*nAC, IIf(Empty(aDados[nX, 45, nP1]), '|___|,|___|___|', Transform(aDados[nX, 45, nP1], "@E 9999.99")), oFont06,,,,1)
						oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.75))*nAC, IIf(Empty(aDados[nX, 46, nP1]), '|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 46, nP1], "@E 99,999,999.99")), oFont06,,,,1)
						oPrint:Say((nLinIni + 1305 + nLinA4)*nAL, (nColIni + (nColMax*0.87))*nAC, IIf(Empty(aDados[nX, 47, nP1]), '|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 47, nP1], "@E 99,999,999.99")), oFont06,,,,1)
				Endif
				nLinIni += 40
			Next nP1

		EndIf

		if nT1 < Len(aDados[nX, 36]).or. lImpnovo
			nV1:=nP1
			lImpnovo:=.T.
		Endif

		nLinIni := nOldLinIni

		AddTBrush(oPrint, (nLinIni + 1480 + nLinA4)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1535)*nAL + nLinA4, (nColIni + nColMax)*nAC)
		oPrint:Say((nLinIni + 1500 + nLinA4)*nAL, (nColIni + 0010)*nAC, "Identificação do(s) Profissional(is) Executante(s)", oFont01) //Identificação do(s) Profissional(is) Executante(s)
		oPrint:Box((nLinIni + 1540)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1775)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
		oPrint:Say((nLinIni + 1530 + nLinA4)*nAL, (nColIni + (nColMax*0.008))*nAC, "48-Seq.Ref", oFont01) //"48-Seq.Ref"
		oPrint:Say((nLinIni + 1530 + nLinA4)*nAL, (nColIni + (nColMax*0.04))*nAC, "49-Grau Part.", oFont01) //"49-Grau Part."
		oPrint:Say((nLinIni + 1530 + nLinA4)*nAL, (nColIni + (nColMax*0.09))*nAC, "50-Código na Operadora/CPF", oFont01) //"50-Código na Operadora/CPF"
		oPrint:Say((nLinIni + 1530 + nLinA4)*nAL, (nColIni + (nColMax*0.31))*nAC, "51-Nome do Profissional", oFont01) //"51-Nome do Profissional"
		oPrint:Say((nLinIni + 1530 + nLinA4)*nAL, (nColIni + (nColMax*0.59))*nAC, "52-Conselho", oFont01) //"52-Conselho"
		oPrint:Say((nLinIni + 1530 + nLinA4)*nAL, (nColIni + (nColMax*0.63))*nAC, "53-Número no Conselho", oFont01) //"53-Número no Conselho"
		oPrint:Say((nLinIni + 1530 + nLinA4)*nAL, (nColIni + (nColMax*0.84))*nAC, "54-UF", oFont01) //"54-UF"
		oPrint:Say((nLinIni + 1530 + nLinA4)*nAL, (nColIni + (nColMax*0.88))*nAC, "55-Código CBO", oFont01) //"55-Código CBO"

		if nVolta==1
			nV2:=1
		Endif

		nLinSeq := nLinIni 
		For nSeq := 1 To 5
			oPrint:Say((nLinSeq + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.016))*nAC, AllTrim(Str(nSeq)) + " - ", oFont04)
			nLinSeq += 40
		Next nSeq
		
		For nP2 := nV2 To nT2
			nSeq := 1
			If aDados[nX, 50] != NIL 
				//If !Empty(aDados[nX, 50, nP2]) //17-09
					If !lLibera
						oPrint:Say((nLinIni + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.050))*nAC, Iif(Empty(aDados[nX, 49, nP2]),'|___|___|',aDados[nX, 49, nP2]), oFont06)
						oPrint:Say((nLinIni + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.09))*nAC, Iif(Empty(aDados[nX, 50, nP2]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 50, nP2]), oFont06)
						oPrint:Say((nLinIni + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.31))*nAC, Iif(Empty(aDados[nX, 51, nP2]),REPLICATE('_',70),aDados[nX, 51, nP2]), oFont06)
						oPrint:Say((nLinIni + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.59))*nAC, Iif(Empty(aDados[nX, 52, nP2]),'|___|___|',aDados[nX, 52, nP2]), oFont06)
						oPrint:Say((nLinIni + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.63))*nAC, If (Empty(aDados[nX, 53, nP2]), '|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|', Transform(aDados[nX, 53, nP2], "999999999999999")), oFont06)
						oPrint:Say((nLinIni + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.84))*nAC, Iif(Empty(aDados[nX, 54, nP2]),'|___|___|',aDados[nX, 54, nP2]), oFont06)
						If FUNNAME() == "HSPAHM30"
							oPrint:Say((nLinIni + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.92))*nAC, "", oFont04)
						Else
							oPrint:Say((nLinIni + 1565 + nLinA4)*nAL, (nColIni + (nColMax*0.88))*nAC, Iif(Empty(aDados[nX, 55, nP2]),'|___|___|___|___|___|___|',aDados[nX, 55, nP2]), oFont06)
						EndIf
					Endif
					nLinIni += 40
				//EndIf
			EndIf
			nSeq++
		Next nP2

		if nT2 < Len(aDados[nX, 48]).or. lImpnovo
			nV2:=nP2
			lImpnovo:=.T.
		Endif

		nLinIni := nOldLinIni

		oPrint:Box((nLinIni + 1785)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 1920)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
		oPrint:Say((nLinIni + 1780 + nLinA4)*nAL, (nColIni + 0020)*nAC, "56-Data de Realização de Procedimentos em Série 57-Assinatura do Beneficiário ou Responsável", oFont01) //56-Data de Realização de Procedimentos em Série 57-Assinatura do Beneficiário ou Responsável
		if Len(aDados[nX])>68
			oPrint:Say((nLinIni + 1805 + nLinA4)*nAL, (nColIni + 0020)*nAC, "1-  "+If (Empty(aDados[nX, 69]), " |___|___|/|___|___|/|___|___|___|___| _______________", 				dToc(aDados[nX, 69])+"   ____________________________"), oFont06)
			oPrint:Say((nLinIni + 1870 + nLinA4)*nAL, (nColIni + 0020)*nAC, "2-  "+If (Empty(aDados[nX, 70]), " |___|___|/|___|___|/|___|___|___|___| _______________", 				dToc(aDados[nX, 70])+"   ____________________________"), oFont06)
			oPrint:Say((nLinIni + 1805 + nLinA4)*nAL, (nColIni + (nColMax/5))*nAC, "3-  "+If (Empty(aDados[nX, 71]), " |___|___|/|___|___|/|___|___|___|___| ________________", 		dToc(aDados[nX, 71])+"   ____________________________"), oFont06)
			oPrint:Say((nLinIni + 1870 + nLinA4)*nAL, (nColIni + (nColMax/5))*nAC, "4-  "+If (Empty(aDados[nX, 72]), " |___|___|/|___|___|/|___|___|___|___| ________________", 		dToc(aDados[nX, 72])+"   ____________________________"), oFont06)
			oPrint:Say((nLinIni + 1805 + nLinA4)*nAL, (nColIni + (nColMax/5*2))*nAC, "5-  "+If (Empty(aDados[nX, 73]), " |___|___|/|___|___|/|___|___|___|___| ________________", 	dToc(aDados[nX, 73])+"   ____________________________"), oFont06)
			oPrint:Say((nLinIni + 1870 + nLinA4)*nAL, (nColIni + (nColMax/5*2))*nAC, "6-  "+If (Empty(aDados[nX, 74]), " |___|___|/|___|___|/|___|___|___|___| ________________", 	dToc(aDados[nX, 74])+"   ____________________________"), oFont06)
			oPrint:Say((nLinIni + 1805 + nLinA4)*nAL, (nColIni + (nColMax/5*3))*nAC, "7-  "+If (Empty(aDados[nX, 75]), " |___|___|/|___|___|/|___|___|___|___| ________________", 	dToc(aDados[nX, 75])+"   ____________________________"), oFont06)
			oPrint:Say((nLinIni + 1870 + nLinA4)*nAL, (nColIni + (nColMax/5*3))*nAC, "8-  "+If (Empty(aDados[nX, 76]), " |___|___|/|___|___|/|___|___|___|___| ________________", 	dToc(aDados[nX, 76])+"   ____________________________"), oFont06)
			oPrint:Say((nLinIni + 1805 + nLinA4)*nAL, (nColIni + (nColMax/5*4))*nAC, "9-  "+If (Empty(aDados[nX, 77]), " |___|___|/|___|___|/|___|___|___|___| ______________", 		dToc(aDados[nX, 77])+"   ____________________________"), oFont06)
			oPrint:Say((nLinIni + 1870 + nLinA4)*nAL, (nColIni + (nColMax/5*4))*nAC, "10- "+If (Empty(aDados[nX, 78]), " |___|___|/|___|___|/|___|___|___|___| ______________", 	dToc(aDados[nX, 78])+"   ____________________________"), oFont06)
		Endif

		oPrint:Line((nLinIni + 1930)*nAL + nLinA4, (nColIni + 0010)*nAC,(nLinIni + 1930)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
		oPrint:Line((nLinIni + 1930)*nAL + nLinA4, (nColIni + 0010)*nAC,(nLinIni + 2110)*nAL + nLinA4, (nColIni + 0010)*nAC)
		oPrint:Line((nLinIni + 1930)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC, (nLinIni + 2110)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
		oPrint:Line((nLinIni + 2110)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 2110)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
		oPrint:Say((nLinIni + 1925 + nLinA4)*nAL, (nColIni + 0020)*nAC, "58-Observação / Justificativa", oFont01) //58-Observação / Justificativa

		nLin := 0
       //Defino as variáveis para a consultada na BEA
		cOper := substr(aDados[nX, 2],1,4)
		cAno  := substr(aDados[nX, 2],6,4)
		cMes  := substr(aDados[nX, 2],11,2)
		cAut  := substr(aDados[nX, 2],14,8)

		//Realizo a consulta na BEA
		DbSelectArea("BEA")
		BEA->(dbSetOrder(1))
		BEA->(DbSeek(xFilial("BEA")+cOper+cAno+cMes+cAut))

		//acrescento na posição da observação o resultado da busca, pois estava vindo errado
		If PGETTISVER() < '3'//No caso da Tiss 3, considero a parametrizacao da estrutura de impressao B7B para o campo 58 - Observacao / Justificativa
			aDados[nX, 58] := BEA->BEA_MSG01 + BEA->BEA_MSG02
		EndIf

		For nI := 1 To MlCount(aDados[nX, 58])
			cObs := MemoLine(aDados[nX, 58], 200, nI)
			If cObs == ""
				exit
			Endif
			oPrint:Say((nLinIni + 1965 + nLinA4 + nLin)*nAL, (nColIni + 0030)*nAC, LOWERACE(cObs), oFont05)
			nLin += 50
		Next nI

		oPrint:Box((nLinIni + 2120)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 2196)*nAL + nLinA4, (nColIni + (nColMax/7) - 0010)*nAC)
		oPrint:Say((nLinIni + 2115 + nLinA4)*nAL, (nColIni + 0020)*nAC, "59 - Total de Procedimentos (R$)", oFont01) //59 - Total de Procedimentos (R$)
		oPrint:Say((nLinIni + 2155 + nLinA4)*nAL, (nColIni + 0016)*nAC, IIf(Empty(aDados[nX, 59]), '|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 59], "@E 99,999,999.99")), oFont04)
		oPrint:Box((nLinIni + 2120)*nAL + nLinA4, (nColIni + nColMax/7)*nAC, (nLinIni + 2196)*nAL + nLinA4, (nColIni + ((nColMax/7)*2) - 0010)*nAC)
		oPrint:Say((nLinIni + 2115 + nLinA4)*nAL, (nColIni + (nColMax/7) + 0010)*nAC, "60 - Total de Taxas e Aluguéis (R$)", oFont01) //60 - Total de Taxas e Aluguéis (R$)
		oPrint:Say((nLinIni + 2155 + nLinA4)*nAL, (nColIni + (nColMax/7) + 0010)*nAC, IIf(Empty(aDados[nX, 60]), '|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 60], "@E 99,999,999.99")), oFont04)
		oPrint:Box((nLinIni + 2120)*nAL + nLinA4, (nColIni + ((nColMax/7)*2))*nAC, (nLinIni + 2196)*nAL + nLinA4, (nColIni + ((nColMax/7)*3) - 0010)*nAC)
		oPrint:Say((nLinIni + 2115 + nLinA4)*nAL, (nColIni + ((nColMax/7)*2) + 0010)*nAC, "61 - Total de Materiais (R$)", oFont01) //61 - Total de Materiais (R$)
		oPrint:Say((nLinIni + 2155 + nLinA4)*nAL, (nColIni + ((nColMax/7)*2) + 0010)*nAC, IIf(Empty(aDados[nX, 61]), '|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 61], "@E 99,999,999.99")), oFont04)
		oPrint:Box((nLinIni + 2120)*nAL + nLinA4, (nColIni + ((nColMax/7)*3))*nAC, (nLinIni + 2196)*nAL + nLinA4, (nColIni + ((nColMax/7)*4) - 0010)*nAC)
		oPrint:Say((nLinIni + 2115 + nLinA4)*nAL, (nColIni + ((nColMax/7)*3) + 0010)*nAC, "62- Total de OPME (R$)", oFont01) //62- Total de OPME (R$)
		oPrint:Say((nLinIni + 2155 + nLinA4)*nAL, (nColIni + ((nColMax/7)*3) + 0010)*nAC, IIf(Empty(aDados[nX, 62]), '|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 62], "@E 99,999,999.99")), oFont04)
		oPrint:Box((nLinIni + 2120)*nAL + nLinA4, (nColIni + ((nColMax/7)*4))*nAC, (nLinIni + 2196)*nAL + nLinA4, (nColIni + ((nColMax/7)*5) - 0010)*nAC)
		oPrint:Say((nLinIni + 2115 + nLinA4)*nAL, (nColIni + ((nColMax/7)*4) + 0010)*nAC, "63 - Total de Medicamentos (R$)", oFont01) //63 - Total de Medicamentos (R$)
		oPrint:Say((nLinIni + 2155 + nLinA4)*nAL, (nColIni + ((nColMax/7)*4) + 0010)*nAC, IIf(Empty(aDados[nX, 63]), '|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 63], "@E 99,999,999.99")), oFont04)
		oPrint:Box((nLinIni + 2120)*nAL + nLinA4, (nColIni + ((nColMax/7)*5))*nAC, (nLinIni + 2196)*nAL + nLinA4, (nColIni + ((nColMax/7)*6) - 0010)*nAC)
		oPrint:Say((nLinIni + 2115 + nLinA4)*nAL, (nColIni + ((nColMax/7)*5) + 0010)*nAC, "64 - Total de Gases Medicinais (R$)", oFont01) //64 - Total de Gases Medicinais (R$)
		oPrint:Say((nLinIni + 2155 + nLinA4)*nAL, (nColIni + ((nColMax/7)*5) + 006)*nAC, IIf(Empty(aDados[nX, 64]), '|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 64], "@E 99,999,999.99")), oFont04)
		oPrint:Box((nLinIni + 2120)*nAL + nLinA4, (nColIni + ((nColMax/7)*6))*nAC, (nLinIni + 2196)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
		oPrint:Say((nLinIni + 2115 + nLinA4)*nAL, (nColIni + ((nColMax/7)*6) + 0010)*nAC, "65 - Total Geral (R$)", oFont01) //65 - Total Geral (R$)
		oPrint:Say((nLinIni + 2155 + nLinA4)*nAL, (nColIni + ((nColMax/7)*6) + 0010)*nAC, IIf(Empty(AllTrim(aDados[nX, 65])), '|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 65], "@E 99,999,999.99")), oFont04)

		oPrint:Box((nLinIni + 2206)*nAL + nLinA4, (nColIni + 0010)*nAC, (nLinIni + 2284)*nAL + nLinA4, (nColIni + (nColMax/3) - 0010)*nAC)
		oPrint:Say((nLinIni + 2201 + nLinA4)*nAL, (nColIni + 0020)*nAC, "66 - Assinatura do Responsável pela Autorização", oFont01) //66 - Assinatura do Responsável pela Autorização
		oPrint:Box((nLinIni + 2206)*nAL + nLinA4, (nColIni + (nColMax/3))*nAC, (nLinIni + 2284)*nAL + nLinA4, (nColIni + ((nColMax/3)*2) - 0010)*nAC)
		oPrint:Say((nLinIni + 2201 + nLinA4)*nAL, (nColIni + (nColMax/3) + 0010)*nAC, "67 - Assinatura do Beneficiário ou Responsável", oFont01) //67 - Assinatura do Beneficiário ou Responsável
		oPrint:Box((nLinIni + 2206)*nAL + nLinA4, (nColIni + ((nColMax/3)*2))*nAC, (nLinIni + 2284)*nAL + nLinA4, (nColIni + nColMax - 0010)*nAC)
		oPrint:Say((nLinIni + 2201 + nLinA4)*nAL, (nColIni + ((nColMax/3)*2) + 0010)*nAC, "68 - Assinatura do Contratado", oFont01) //68 - Assinatura do Contratado

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Finaliza a pagina
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		oPrint:EndPage()

	Next nX
EndDo

If lGerTXT .And. !lWeb
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Imprime Relatorio
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:Print()
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Visualiza impressao grafica antes de imprimir
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:Preview()
EndIf

Return(cFileName)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ?PLSSOLIT  ?Autor ?Bruno Iserhardt       ?Data ?21.06.13 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ?Estrutura Relatório TISS 3.00.01 (Guia Sol. Internaçao)     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?SigaPLS                                                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros?aDados - Array com as informações do relat´rio              ³±?
±±?         ?lGerTXT - Define se imprime direto sem passar pela tela 	   ³±?
±±?         ?		 de configuracao/preview do relatorio 		       ³±?
±±?         ?nLayout - Define o formato de papél para impressao:         ³±?
±±?         ?          1 - Formato Ofício II (216x330mm)                 ³±?
±±?         ?          2 - Formato A4 (210x297mm)                        ³±?
±±?         ? 		 3 - Formato Carta (216x279mm)     			       ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PLSSOLIT(aDados, lGerTXT, nLayout, cLogoGH, lMail, lWeb, cPathRelW, lProrrog)

Local nLinMax
Local nColMax
Local nLinIni	:=	0	// Linha Lateral (inicial) Esquerda
Local nColIni	:=	0	// Coluna Lateral (inicial) Esquerda
Local nColA4    :=  0
Local nLinA4    :=  0
Local cFileLogo
Local nLin
Local nP:=0
Local nT:=0
Local nT1:=0
Local nT3:=0
Local nI,nJ,nK,nX
Local nR,nV,nV1,nV2,nN
Local cObs
Local oFont01
Local oFont02n
Local oFont03n
Local oFont04
Local lImpnovo  :=.T.
Local nVolta    :=0
Local cFile 	:= GetNewPar("MV_RELT",'\SPOOL\')
Local lRet		:= .T.
Local lOk		:= .T.
LOCAL cFileName	:= ""
LOCAL cRel      := "GUICONS"
LOCAL cPathSrvJ := GETMV("MV_RELT")
LOCAL nAL		:= 0.25
LOCAL nAC		:= 0.24
Local lImpPrc   := .T.
Local cCodTab 	:= ""
Local cCodPro 	:= ""
Local cDescri	:= ""
Local lImpNAut	:= IIf(GetNewPar("MV_PLNAUT",0) == 0, .F., .T.) // 0 = Nao imprime procedimento nao autorizado 1 = Sim imprime
LOCAL nLinObs	:= 0
LOCAL cIndic    := ""
LOCAL cErro		:= ""
LOCAL cArq			:= ""
Local bError		:= ErrorBlock( {|e| TrataErro(e,@cErro) } )
Local lPLSGTISS := ExistBlock("PLSGTISS")

DEFAULT lProrrog 	:= ".F."
DEFAULT lGerTXT 	:= .F.
DEFAULT nLayout 	:= 2
DEFAULT cLogoGH 	:= ""
DEFAULT lMail		:= .F.
DEFAULT lWeb		:= .F.
DEFAULT cPathRelW 	:= ""
DEFAULT aDados 	:= { { ;
	"123456",; //1 - Registro ANS
	"12345678901234567890",; //2- N?Guia no Prestador
	"12345678901234567890",; //3 - Número da Guia Atribuído pela Operadora
	CtoD("01/01/07"),; //4 - Data da Autorização
	"12345678901234567890",; //5 - Senha
	CtoD("01/01/07"),; //6 ?Data de Validade da Senha
	"12345678901234567890",; //7 - Número da Carteira
	CtoD("12/12/07"),; //8 - Validade da Carteira
	"S",; //9-Atendimento de RN
	Replicate("M",70),; //10 - Nome
	"123456789012345",; //11 - Cartão Nacional de Saúde
	"12345678901234",; //12 ?Código na Operadora
	Replicate("M",70),; //13 - Nome do Contratado
	Replicate("M",70),; //14 - Nome do Profissional Solicitante
	"MM",; //15 - Conselho Profissional
	"123456789012345",; //16 - Número no Conselho
	"RS",; //17 - UF
	"123456",; //18 - Código CBO
	"12345678901234",; //19- Código na Operadora / CNPJ
	Replicate("M",70),; //20 - Nome do Hospital/Local Solicitado
	CtoD("12/12/07"),; //21 - Data sugerida para internação
	"U",; //22 - Caráter do Atendimento
	"1",; //23-Tipo de Internação
	"1",; //24 - Regime de Internação
	999,; //25 - Qtde. Diárias Solicitadas
	"A",; //26 ?Previsão de uso de OPME
	"N",; //27 ?Previsão de uso de quimioterápico
	Replicate("M",480),; //28 - Indicação Clínica
	"1234",; //29-CID 10 Principal (opcional)
	"1234",; //30 - CID 10 (2) (opcional)
	"1234",; //31 - CID 10 (3) (opcional)
	"1234",; //32 - CID 10 (4) (opcional)
	"1",; //33 - Indicação de Acidente (acidente ou doença relacionada)
	{ "10","20","30","40","50","60","70","80","90","99","00","11", "11" },; //34-Tabela
	{ "1234567890","2345678901","3456789012","4567890123","5678901234","1234567890","2345678901","3456789012","4567890123","5678901234","4567890123","5678901234","5678901234" },; //35 - Código do Procedimento
	{ Replicate("M",150),Replicate("A",150),Replicate("B",150),Replicate("C",150),Replicate("D",150),Replicate("M",150),Replicate("A",150),Replicate("B",150),Replicate("C",150),Replicate("D",150),Replicate("C",150),Replicate("D",150),Replicate("D",150) },; //36 - Descrição
	{ 999,888,777,666,555,444,333,222,111,999,888,777,777 },; //37 - Qtde Solic
	{ 111,222,333,444,555,1212,111,222,333,444,555,1212,1212 },; //38 ?Qtde Aut
	CtoD("12/12/07"),; //39 - Data Provável da Admissão Hospitalar
	123,; //40 - Qtde. Diarias Autorizadas
	"AA",;//41 - Tipo da Acomodação Autorizada
	"12345678901234",; //42 - Código na Operadora / CNPJ autorizado
	Replicate("M",70),; //43 - Nome do Hospital / Local Autorizado
	"1234567",; //44 - Código CNES
	Replicate("O",1000),; //45 ?Observação / Justificativa
	CtoD("12/12/07") } } //46-Data da Solicitação

If nLayout  == 1 // Ofício 2
	nLinMax	:=	3705	// Numero maximo de Linhas (31,5 cm)
	nColMax	:=	2400	// Numero maximo de Colunas (21 cm)
Elseif nLayout == 2   // Papél A4
	nLinMax	:=	2350
	nColMax	:=	2335
Else //Carta
	nLinMax	:=	3155
	nColMax	:=	2400
Endif

oFont01		:= TFont():New("Arial",  5,  5, , .F., , , , .T., .F.) // Normal
if nLayout == 1 // Oficio 2
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
Else  // Papél A4 ou Carta
	oFont02n := TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n := TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04	 := TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Nao permite acionar a impressao quando for na web.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lWeb
	cPathSrvJ := cPathRelW
	cFileName := cRel+CriaTrab(NIL,.F.)+".pdf"
Else
	cFileName := cRel+CriaTrab(NIL,.F.)+".pdf"
EndIf

	//						New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF] )
oPrint := FWMSPrinter():New ( cFileName			,	IMP_PDF		,	.F.				,cPathSrvJ	 	,	.T.				,			 ,				,			  ,			  ,	.F.			, 		, 				)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Tratamento para impressao via job
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//oPrint:lInJob  := lWeb
oPrint:lServer := lWeb
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Caminho do arquivo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
oPrint:cPathPDF := cPathSrvJ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Modo retrato
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
oPrint:SetPortrait()	// Modo retrato

If nLayout ==2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Papél A4
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:SetPaperSize(9)
ElseIf nLayout ==3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Papél Carta
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:SetPaperSize(1)
Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Papel Oficio2 216 x 330mm / 8 1/2 x 13in
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:SetPaperSize(14)
Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Device
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lWeb
	oPrint:setDevice(IMP_PDF)
	oPrint:lPDFAsPNG := .T.
EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Verifica se existe alguma impressora configurada para Impressao Grafica
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If  !lWeb
	oPrint:Setup()
	If !(oPrint:nModalResult == 1)
		lRet := .F.
		lMail := .F.
	Else
		lImpnovo:=(oPrint:nModalResult == 1)
	Endif
EndIf

If lProrrog == '.T.'
	lProrrog := PPLVERPRR(@aDados)
Else
	lProrrog := .F.
EndIf


BEGIN SEQUENCE	
	While lImpnovo

		lImpnovo:=.F.
		nVolta  += 1
		nT      += 12
		nT1     += 2
		nT3     += 3

		For nX := 1 To Len(aDados)

			If Len(aDados[nX]) == 0
				Loop
			EndIf

			For nI := 34 To 38
				If Len(aDados[nX, nI]) < nT
					For nJ := Len(aDados[nX, nI]) + 1 To nT
						If AllTrim(Str(nI)) $ "37,38"
							aAdd(aDados[nX, nI], 0)
						Else
							aAdd(aDados[nX, nI], "")
						EndIf
					Next nJ
				EndIf
			Next nI

			If oPrint:Cprinter == "PDF" .OR. lWeb
				nLinIni	:= 150
			Else
				nLinIni := 000
			Endif

			nColIni := 060
			nColA4  := 000
			nLinA4  := 000

			oPrint:StartPage()		// Inicia uma nova pagina

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:Box((nLinIni + 0000)*nAL, (nColIni + 0010)*nAC, (nLinIni + nLinMax - 10)*nAL, (nColIni + nColMax)*nAC)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega e Imprime Logotipo da Empresa                         ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fLogoEmp(@cFileLogo,, cLogoGH)

			If File(cFilelogo)
				oPrint:SayBitmap((nLinIni + 0050)*nAL, (nColIni + 0020)*nAC, cFileLogo, (400)*nAL, (090)*nAC) 		// Tem que estar abaixo do RootPath
			EndIf

			If nLayout == 2 // Papél A4
				nColA4    := -0065
			Elseif nLayout == 3// Carta
				nLinA4    := -0085
			Endif

			If lProrrog
				oPrint:Say((nLinIni+ 0050)*nAL, (nColIni + (nColMax*0.35))*nAC, "GUIA  DE SOLICITAÇÃO", oFont02n) //"GUIA DE SOLICITAÇÃO DE PRORROGAÇÃO DE "
				oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.30))*nAC, "DE PRORROGAÇÃO DE INTERNAÇÃO", oFont02n) //"DE INTERNAÇÃO"
				oPrint:Say((nLinIni + 0150)*nAL, (nColIni + (nColMax*0.28))*nAC, "OU COMPLEMENTAÇÃO DO TRATAMENTO", oFont02n) //"DE INTERNAÇÃO"
			Else
				oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.40))*nAC, "GUIA DE SOLICITAÇÃO", oFont02n) //"GUIA DE SOLICITAÇÃO"
				oPrint:Say((nLinIni + 0150)*nAL, (nColIni + (nColMax*0.42))*nAC, "DE INTERNAÇÃO", oFont02n) //"DE INTERNAÇÃO"
			EndIf
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.70))*nAC, "2- N?Guia no Prestador", oFont01) //"2- N?Guia no Prestador"
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.79))*nAC, aDados[nX, 02], oFont03n)

			oPrint:Box((nLinIni + 0180)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0240)*nAL, (nColIni + (nColMax*0.15)- 0010)*nAC)
			oPrint:Say((nLinIni + 0200)*nAL, (nColIni + 0030)*nAC, "1 - Registro ANS", oFont01) //"1 - Registro ANS"
			oPrint:Say((nLinIni + 0232)*nAL, (nColIni + 0040)*nAC, Iif(Empty(aDados[nX, 01]),'|___|___|___|___|___|___|',aDados[nX, 01]), oFont04)
			oPrint:Box((nLinIni + 0180)*nAL, (nColIni + (nColMax*0.15))*nAC, (nLinIni + 0240)*nAL, (nColIni + (nColMax*0.62) - 0010)*nAC)
			oPrint:Say((nLinIni + 0200)*nAL, (nColIni + (nColMax*0.15) + 0010)*nAC, "3 - Número da Guia Atribuído pela Operadora", oFont01) //"3 - Número da Guia Atribuído pela Operadora"
			oPrint:Say((nLinIni + 0232)*nAL, (nColIni + (nColMax*0.15) + 0020)*nAC, Iif(Empty(aDados[nX, 03]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 03]), oFont04)

			oPrint:Box((nLinIni + 0250)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0310)*nAL, (nColIni + (nColMax*0.25) - 0010)*nAC)
			oPrint:Say((nLinIni + 0270)*nAL, (nColIni + 0030)*nAC, "4 - Data da Autorização", oFont01) //"4 - Data da Autorização"
			oPrint:Say((nLinIni + 0302)*nAL, (nColIni + 0040)*nAC, Iif(Empty(aDados[nX, 04]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 04])), oFont04)
			oPrint:Box((nLinIni + 0250)*nAL, (nColIni + (nColMax*0.25))*nAC, (nLinIni + 0310)*nAL, (nColIni + (nColMax*0.70)- 0010)*nAC)
			oPrint:Say((nLinIni + 0270)*nAL, (nColIni + (nColMax*0.25) + 0010)*nAC, "5 - Senha", oFont01) //"5 - Senha"
			oPrint:Say((nLinIni + 0302)*nAL, (nColIni + (nColMax*0.25) + 0020)*nAC, Iif(Empty(aDados[nX, 05]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 05]), oFont04)
			oPrint:Box((nLinIni + 0250)*nAL, (nColIni + (nColMax*0.70))*nAC, (nLinIni + 0310)*nAL, (nColIni + (nColMax*0.95)- 0010)*nAC)
			oPrint:Say((nLinIni + 0270)*nAL, (nColIni + (nColMax*0.70) + 0010)*nAC, "6 - Data de Validade da Senha", oFont01) //"6 - Data de Validade da Senha"
			oPrint:Say((nLinIni + 0302)*nAL, (nColIni + (nColMax*0.70) + 0020)*nAC, Iif(Empty(aDados[nX, 06]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 06])), oFont04)

			oPrint:Say((nLinIni + 0330)*nAL, (nColIni + 0020)*nAC, "Dados do Beneficiário", oFont01) //Dados do Beneficiário
			oPrint:Box((nLinIni + 0340)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0400)*nAL, (nColIni + (nColMax*0.50) - 0010)*nAC)
			oPrint:Say((nLinIni + 0360)*nAL, (nColIni + 0030)*nAC, "7 - Número da Carteira", oFont01) //"7 - Número da Carteira"
			oPrint:Say((nLinIni + 0392)*nAL, (nColIni + 0040)*nAC, Iif(Empty(aDados[nX, 07]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 07]), oFont04)
			oPrint:Box((nLinIni + 0340)*nAL, (nColIni + (nColMax*0.50))*nAC, (nLinIni + 0400)*nAL, (nColIni + (nColMax*0.73) - 0010)*nAC)
			oPrint:Say((nLinIni + 0360)*nAL, (nColIni + (nColMax*0.50) + 0010)*nAC, "8 - Validade da Carteira", oFont01) //"8 - Validade da Carteira"
			oPrint:Say((nLinIni + 0392)*nAL, (nColIni + (nColMax*0.50) + 0020)*nAC, Iif(Empty(aDados[nX, 08]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 08])), oFont04)
			oPrint:Box((nLinIni + 0340)*nAL, (nColIni + (nColMax*0.73))*nAC, (nLinIni + 0400)*nAL, (nColIni + (nColMax*0.85) - 0010)*nAC)
			oPrint:Say((nLinIni + 0360)*nAL, (nColIni + (nColMax*0.73) + 0010)*nAC, "9 - Atendimento de RN", oFont01) //"9 - Atendimento de RN"
			oPrint:Say((nLinIni + 0392)*nAL, (nColIni + (nColMax*0.78))*nAC, Iif(Empty(aDados[nX, 09]),'|___|',aDados[nX, 09]), oFont04)

			oPrint:Box((nLinIni + 0410)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0470)*nAL, (nColIni + (nColMax*0.60) - 0010)*nAC)
			oPrint:Say((nLinIni + 0430)*nAL, (nColIni + 0030)*nAC, "10 - Nome", oFont01) //"10 - Nome"
			oPrint:Say((nLinIni + 0462)*nAL, (nColIni + 0040)*nAC, aDados[nX, 10], oFont04)
			oPrint:Box((nLinIni + 0410)*nAL, (nColIni + (nColMax*0.60))*nAC, (nLinIni + 0470)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 0430)*nAL, (nColIni + (nColMax*0.60) + 0010)*nAC, "11 - Cartão Nacional de Saúde", oFont01) //"11 - Cartão Nacional de Saúde"
			oPrint:Say((nLinIni + 0462)*nAL, (nColIni + (nColMax*0.60) + 0020)*nAC, Iif(Empty(aDados[nX, 11]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 11]), oFont04)

			oPrint:Say((nLinIni + 0490)*nAL, (nColIni + 0020)*nAC, "Dados do Contratado Solicitante", oFont01) //Dados do Contratado Solicitante
			oPrint:Box((nLinIni + 0500)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0560)*nAL, (nColIni + (nColMax*0.33) - 0010)*nAC)
			oPrint:Say((nLinIni + 0520)*nAL, (nColIni + 0030)*nAC, "12 - Código na Operadora", oFont01) //"12 - Código na Operadora"
			oPrint:Say((nLinIni + 0552)*nAL, (nColIni + 0040)*nAC, Iif(Empty(aDados[nX, 12]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 12]), oFont04)
			oPrint:Box((nLinIni + 0500)*nAL, (nColIni + (nColMax*0.33))*nAC, (nLinIni + 0560)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 0520)*nAL, (nColIni + (nColMax*0.33) + 0010)*nAC, "13 - Nome do Contratado", oFont01) //"13 - Nome do Contratado"
			oPrint:Say((nLinIni + 0552)*nAL, (nColIni + (nColMax*0.33) + 0020)*nAC, aDados[nX, 13], oFont04)

			oPrint:Box((nLinIni + 0570)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0630)*nAL, (nColIni + (nColMax*0.37) - 0010)*nAC)
			oPrint:Say((nLinIni + 0590)*nAL, (nColIni + 0030)*nAC, "14 - Nome do Profissional Solicitante", oFont01) //"14 - Nome do Profissional Solicitante"
			oPrint:Say((nLinIni + 0622)*nAL, (nColIni + 0040)*nAC, aDados[nX, 14], oFont04)
			oPrint:Box((nLinIni + 0570)*nAL, (nColIni + (nColMax*0.37))*nAC, (nLinIni + 0630)*nAL, (nColIni + (nColMax*0.47) - 0010)*nAC)
			oPrint:Say((nLinIni + 0586)*nAL, (nColIni + (nColMax*0.37) + 0010)*nAC, "15 - Conselho", oFont01) //"15 - Conselho"
			oPrint:Say((nLinIni + 0603)*nAL, (nColIni + (nColMax*0.37) + 0015)*nAC, "Profissional", oFont01) //"Profissional"
			oPrint:Say((nLinIni + 0624)*nAL, (nColIni + (nColMax*0.37) + 0035)*nAC, Iif(Empty(aDados[nX, 15]),'|___|___|',aDados[nX, 15]), oFont04)
			oPrint:Box((nLinIni + 0570)*nAL, (nColIni + (nColMax*0.47))*nAC, (nLinIni + 0630)*nAL, (nColIni + (nColMax*0.80) - 0010)*nAC)
			oPrint:Say((nLinIni + 0590)*nAL, (nColIni + (nColMax*0.47) + 0010)*nAC, "16 - Número no Conselho", oFont01) //"16 - Número no Conselho"
			oPrint:Say((nLinIni + 0622)*nAL, (nColIni + (nColMax*0.47) + 0020)*nAC, Iif(Empty(aDados[nX, 16]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 16]), oFont04)
			oPrint:Box((nLinIni + 0570)*nAL, (nColIni + (nColMax*0.80))*nAC, (nLinIni + 0630)*nAL, (nColIni + (nColMax*0.84) - 0010)*nAC)
			oPrint:Say((nLinIni + 0590)*nAL, (nColIni + (nColMax*0.80) + 0010)*nAC, "17 - UF", oFont01) //"17 - UF"
			oPrint:Say((nLinIni + 0622)*nAL, (nColIni + (nColMax*0.80) + 0020)*nAC, Iif(Empty(aDados[nX, 17]),'|___|___|',aDados[nX, 17]), oFont04)
			oPrint:Box((nLinIni + 0570)*nAL, (nColIni + (nColMax*0.84))*nAC, (nLinIni + 0630)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 0590)*nAL, (nColIni + (nColMax*0.84) + 0010)*nAC, "18 - Código CBO", oFont01) //"18 - Código CBO"
			oPrint:Say((nLinIni + 0622)*nAL, (nColIni + (nColMax*0.84) + 0020)*nAC, Iif(Empty(aDados[nX, 18]),'|___|___|___|___|___|___|',aDados[nX, 18]), oFont04)

			oPrint:Say((nLinIni + 0650)*nAL, (nColIni + 0020)*nAC, "Dados do Hospital /Local Solicitado / Dados da Internação", oFont01) //Dados do Hospital /Local Solicitado / Dados da Internação
			oPrint:Box((nLinIni + 0660)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0720)*nAL, (nColIni + (nColMax*0.33) - 0010)*nAC)
			oPrint:Say((nLinIni + 0680)*nAL, (nColIni + 0030)*nAC, "19- Código na Operadora / CNPJ", oFont01) //"19- Código na Operadora / CNPJ"
			oPrint:Say((nLinIni + 0712)*nAL, (nColIni + 0040)*nAC, Iif(Empty(aDados[nX, 19]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 19]), oFont04)
			oPrint:Box((nLinIni + 0660)*nAL, (nColIni + (nColMax*0.33))*nAC, (nLinIni + 0720)*nAL, (nColIni + (nColMax*0.78) - 0010)*nAC)
			oPrint:Say((nLinIni + 0680)*nAL, (nColIni + (nColMax*0.33) + 0010)*nAC, "20 - Nome do Hospital/Local Solicitado", oFont01) //"20 - Nome do Hospital/Local Solicitado"
			oPrint:Say((nLinIni + 0712)*nAL, (nColIni + (nColMax*0.33) + 0020)*nAC, aDados[nX, 20], oFont04)
			oPrint:Box((nLinIni + 0660)*nAL, (nColIni + (nColMax*0.78))*nAC, (nLinIni + 0720)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 0680)*nAL, (nColIni + (nColMax*0.78) + 0010)*nAC, "21 - Data sugerida para internação", oFont01) //"20 - Nome do Hospital/Local Solicitado"
			oPrint:Say((nLinIni + 0712)*nAL, (nColIni + (nColMax*0.78) + 0020)*nAC, Iif(Empty(aDados[nX, 21]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 21])), oFont04)

			oPrint:Box((nLinIni + 0730)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0790)*nAL, (nColIni + (nColMax*0.17) - 0010)*nAC)
			oPrint:Say((nLinIni + 0750)*nAL, (nColIni + 0030)*nAC, "22 - Caráter do Atendimento", oFont01) //"22 - Caráter do Atendimento"
			oPrint:Say((nLinIni + 0782)*nAL, (nColIni + 0185)*nAC, Iif(Empty(aDados[nX, 22]),'|___|',aDados[nX, 22]), oFont04)
			oPrint:Box((nLinIni + 0730)*nAL, (nColIni + (nColMax*0.17))*nAC, (nLinIni + 0790)*nAL, (nColIni + (nColMax*0.29) - 0010)*nAC)
			oPrint:Say((nLinIni + 0750)*nAL, (nColIni + (nColMax*0.17) + 0010)*nAC, "23 - Tipo de Internação", oFont01) //"23-Tipo de Internação"
			oPrint:Say((nLinIni + 0782)*nAL, (nColIni + (nColMax*0.225))*nAC, Iif(Empty(aDados[nX, 23]),'|___|',aDados[nX, 23]), oFont04)
			oPrint:Box((nLinIni + 0730)*nAL, (nColIni + (nColMax*0.29))*nAC, (nLinIni + 0790)*nAL, (nColIni + (nColMax*0.44) - 0010)*nAC)
			oPrint:Say((nLinIni + 0750)*nAL, (nColIni + (nColMax*0.29) + 0010)*nAC, "24 - Regime de Internação", oFont01) //"24 - Regime de Internação"
			oPrint:Say((nLinIni + 0782)*nAL, (nColIni + (nColMax*0.36))*nAC, Iif(Empty(aDados[nX, 24]),'|___|',aDados[nX, 24]), oFont04)
			oPrint:Box((nLinIni + 0730)*nAL, (nColIni + (nColMax*0.44))*nAC, (nLinIni + 0790)*nAL, (nColIni + (nColMax*0.60) - 0010)*nAC)
			oPrint:Say((nLinIni + 0750)*nAL, (nColIni + (nColMax*0.44) + 0010)*nAC, "25 - Qtde. Diárias Solicitadas", oFont01) //"25 - Qtde. Diárias Solicitadas"
			oPrint:Say((nLinIni + 0782)*nAL, (nColIni + (nColMax*0.49))*nAC, IIf(Empty(aDados[nX, 25]), '|___|___|___|', Transform(aDados[nX, 25], "@E 999")), oFont04)
			oPrint:Box((nLinIni + 0730)*nAL, (nColIni + (nColMax*0.60))*nAC, (nLinIni + 0790)*nAL, (nColIni + (nColMax*0.78) - 0010)*nAC)
			oPrint:Say((nLinIni + 0750)*nAL, (nColIni + (nColMax*0.60) + 0010)*nAC, "26 - Previsão de uso de OPME", oFont01) //"26 ?Previsão de uso de OPME"
			oPrint:Say((nLinIni + 0782)*nAL, (nColIni + (nColMax*0.68))*nAC, Iif(Empty(aDados[nX, 26]),'|___|',aDados[nX, 26]), oFont04)
			oPrint:Box((nLinIni + 0730)*nAL, (nColIni + (nColMax*0.78))*nAC, (nLinIni + 0790)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 0750)*nAL, (nColIni + (nColMax*0.78) + 0010)*nAC, "27 - Previsão de uso de quimioterápico", oFont01) //"27 ?Previsão de uso de quimioterápico"
			oPrint:Say((nLinIni + 0782)*nAL, (nColIni + (nColMax*0.85))*nAC, Iif(Empty(aDados[nX, 27]),'|___|',aDados[nX, 27]), oFont04)

			oPrint:Box((nLinIni + 0800)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1040)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 0820)*nAL, (nColIni + 0030)*nAC, "28 - Indicação Clínica", oFont01) //"28 - Indicação Clínica"
			
			If Empty(aDados[nX, 28])
				For nI := 1 To MlCount(aDados[nX, 28], 100)
					cIndic := MemoLine(aDados[nX, 28], 100, nI)
					oPrint:Say((nLinIni + 0852 + nLinObs)*nAL, (nColIni + 0040)*nAC, cIndic, oFont04)
					nLinObs+=40
				Next nI
			EndIf

			oPrint:Say((nLinIni + 1060)*nAL, (nColIni + 0020)*nAC, "Hipóteses Diagnósticas", oFont01) //Hipóteses Diagnósticas
			oPrint:Box((nLinIni + 1070)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1130)*nAL, (nColIni + (nColMax*0.15) - 0010)*nAC)
			oPrint:Say((nLinIni + 1090)*nAL, (nColIni + 0030)*nAC, "29 - CID 10 Principal (opcional)", oFont01) //"29 - CID 10 Principal"
			oPrint:Say((nLinIni + 1122)*nAL, (nColIni + 0040)*nAC, Iif(Empty(aDados[nX, 29]),'|___|___|___|___|',aDados[nX, 29]), oFont04)
			oPrint:Box((nLinIni + 1070)*nAL, (nColIni + (nColMax*0.15))*nAC, (nLinIni + 1130)*nAL, (nColIni + (nColMax*0.30) - 0010)*nAC)
			oPrint:Say((nLinIni + 1090)*nAL, (nColIni + (nColMax*0.15) + 0010)*nAC, "30 - CID 10 (2) (opcional)", oFont01) //"30 - CID 10 (2)"
			oPrint:Say((nLinIni + 1122)*nAL, (nColIni + (nColMax*0.15) + 0020)*nAC, Iif(Empty(aDados[nX, 30]),'|___|___|___|___|',aDados[nX, 30]), oFont04)
			oPrint:Box((nLinIni + 1070)*nAL, (nColIni + (nColMax*0.30))*nAC, (nLinIni + 1130)*nAL, (nColIni + (nColMax*0.45) - 0010)*nAC)
			oPrint:Say((nLinIni + 1090)*nAL, (nColIni + (nColMax*0.30) + 0010)*nAC, "31 - CID 10 (3) (opcional)", oFont01) //"31 - CID 10 (3)"
			oPrint:Say((nLinIni + 1122)*nAL, (nColIni + (nColMax*0.30) + 0020)*nAC, Iif(Empty(aDados[nX, 31]),'|___|___|___|___|',aDados[nX, 31]), oFont04)
			oPrint:Box((nLinIni + 1070)*nAL, (nColIni + (nColMax*0.45))*nAC, (nLinIni + 1130)*nAL, (nColIni + (nColMax*0.60) - 0010)*nAC)
			oPrint:Say((nLinIni + 1090)*nAL, (nColIni + (nColMax*0.45) + 0010)*nAC, "32 - CID 10 (4) (opcional)", oFont01) //"32 - CID 10 (4)"
			oPrint:Say((nLinIni + 1122)*nAL, (nColIni + (nColMax*0.45) + 0020)*nAC, Iif(Empty(aDados[nX, 32]),'|___|___|___|___|',aDados[nX, 32]), oFont04)
			oPrint:Box((nLinIni + 1070)*nAL, (nColIni + (nColMax*0.60))*nAC, (nLinIni + 1130)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 1090)*nAL, (nColIni + (nColMax*0.60) + 0010)*nAC, "33 - Indicação de Acidente (acidente ou doença relacionada)", oFont01) //"33 - Indicação de Acidente (acidente ou doença relacionada)"
			oPrint:Say((nLinIni + 1122)*nAL, (nColIni + (nColMax*0.60) + 0020)*nAC, Iif(Empty(aDados[nX, 33]),'|___|',aDados[nX, 33]), oFont04)

			oPrint:Say((nLinIni + 1150)*nAL, (nColIni + 0020)*nAC, "Procedimentos Solicitados", oFont01) //Procedimentos Solicitados
			oPrint:Box((nLinIni + 1160)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1670)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 1180)*nAL, (nColIni + (nColMax*0.02))*nAC, "34 - Tabela", oFont01) //34-Tabela
			oPrint:Say((nLinIni + 1180)*nAL, (nColIni + (nColMax*0.08))*nAC, "35 - Código do Procedimento", oFont01) //35 - Código do Procedimento
			oPrint:Say((nLinIni + 1180)*nAL, (nColIni + (nColMax*0.32))*nAC, "36 - Descrição", oFont01) //36 - Descrição
			oPrint:Say((nLinIni + 1180)*nAL, (nColIni + (nColMax*0.80))*nAC, "37 - Qtde Solic", oFont01) //37 - Qtde Solic
			oPrint:Say((nLinIni + 1180)*nAL, (nColIni + (nColMax*0.90))*nAC, "38 - Qtde Aut", oFont01) //38 ?Qtde Aut

			nOldLinIni := nLinIni

			if nVolta=1
				nV1:=1
			Endif


			cOper := substr(aDados[nX, 2],1,4)
			cAno  := substr(aDados[nX, 2],6,4)
			cMes  := substr(aDados[nX, 2],11,2)
			cAut  := substr(aDados[nX, 2],14,8)

			DbSelectArea("BEA")
			BEA->(dbSetOrder(1))
			If BEA->(DbSeek(xFilial("BEA")+cOper+cAno+cMes+cAut))
				If BEA->BEA_LIBERA == '0'
					//se eh uma execucao eu tenho que refazer os procedimentos que foram solicitados
					If !Empty(BEA->BEA_NRLBOR)
						xChave := alltrim(BEA->BEA_NRLBOR)
					Else
						xChave := alltrim(cOper+cAno+cMes+cAut)
					Endif
				Else
					//se eh uma solicitacao eu tenho que refazer os procedimentos que foram solicitados e autorizados
					xChave := alltrim(cOper+cAno+cMes+cAut)
				Endif
	
				BE2->(DbSetORder(1))
				if !Empty(xChave) .and. BE2->(MsSeek(xFilial('BE2')+alltrim(xChave)))
					aDados[nX, 34] := {}
					aDados[nX, 35] := {}
					aDados[nX, 36] := {}
					aDados[nX, 37] := {}
					aDados[nX, 38] := {}
					While !BE2->(Eof()) .and. xFilial('BE2')+xChave == BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)
						If (BE2->BE2_STATUS == '0' .And. lImpNAut) .Or. BE2->BE2_STATUS == '1'
	
							BD6->(DbSetOrder(6))
							If BD6->(MsSeek(xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)+'1'+BE2->(BE2_CODPAD+BE2_CODPRO))) .and. !Empty(BD6->BD6_SLVPAD)
								cCodTab := PLSIMPVINC("BR4","87"	,	BD6->BD6_CODPAD					,.F.)
								cCodPro := PLSIMPVINC("BR8",cCodTab	,	BD6->BD6_CODPAD+BD6->BD6_CODPRO	,.F.)
								cDescri := PLSIMPVINC("BR8",cCodTab	,	BD6->BD6_CODPAD+BD6->BD6_CODPRO	,.T.)
							Else
								cCodTab := PLSIMPVINC("BR4","87"	,	BE2->BE2_CODPAD					,.F.)
								cCodPro := PLSIMPVINC("BR8",cCodTab	,	BE2->BE2_CODPAD+BE2->BE2_CODPRO	,.F.)
								cDescri := PLSIMPVINC("BR8",cCodTab	,	BE2->BE2_CODPAD+BE2->BE2_CODPRO	,.T.)
							Endif
							
							If Empty(cCodTab) .Or. Empty(cCodPro) .Or. Empty(cDescri)
								cCodTab := BE2->BE2_CODPAD
								cCodPro := BE2->BE2_CODPRO
								cDescri := Posicione("BR8",1, xFilial("BR8")+BE2->(BE2_CODPAD+BE2_CODPRO), "BR8_DESCRI")
							Endif
						
							aAdd(aDados[nX, 34], cCodTab)
							aAdd(aDados[nX, 35], cCodPro)
							aAdd(aDados[nX, 36], cDescri)
							aAdd(aDados[nX, 37], BE2->BE2_QTDSOL)
							aAdd(aDados[nX, 38], IIf(BE2->BE2_STATUS = '1',BE2->BE2_QTDPRO,0))
							
						Endif
						BE2->(DbSkip())
					Enddo
					For nI := 34 To 38
						If Len(aDados[nX, nI]) < nT
							For nJ := Len(aDados[nX, nI]) + 1 To nT
								If AllTrim(Str(nI)) $ "37,38"
									aAdd(aDados[nX, nI], 0)
								Else
									aAdd(aDados[nX, nI], "")
								EndIf
							Next nJ
						EndIf
					Next nI
				Endif
			Endif

			If lPLSGTISS
				lImpPrc := ExecBlock("PLSGTISS",.F.,.F.,{"03",lImpPrc})
			EndIf

			If lImpPrc

				For nP := nV1 To nT
						if nVolta <> 1
							nN:=nP-((5*nVolta)-5)
							oPrint:Say((nLinIni + 1220)*nAL, (nColIni + 0025)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
						else
							oPrint:Say((nLinIni + 1220)*nAL, (nColIni + 0025)*nAC, AllTrim(Str(nP)) + " - ", oFont01)
						endif
						oPrint:Say((nLinIni + 1220)*nAL, (nColIni + (nColMax*0.03))*nAC, Iif(Empty(aDados[nX, 34, nP]),'|___|___|',aDados[nX, 34, nP]), oFont04)
						oPrint:Say((nLinIni + 1220)*nAL, (nColIni + (nColMax*0.08))*nAC, Iif(Empty(aDados[nX, 35, nP]),'|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 35, nP]), oFont04)
						oPrint:Say((nLinIni + 1220)*nAL, (nColIni + (nColMax*0.32))*nAC, Iif(Empty(aDados[nX, 36, nP]),REPLICATE('_',100),aDados[nX, 36, nP]), oFont01)
						oPrint:Say((nLinIni + 1220)*nAL, (nColIni + (nColMax*0.82))*nAC, if (aDados[nX, 37, nP]=0,'|___|___|___|',Transform(aDados[nX, 37, nP], "@E 999")), oFont04,,,,1)
						oPrint:Say((nLinIni + 1220)*nAL, (nColIni + (nColMax*0.92))*nAC, if (aDados[nX, 38, nP]=0,'|___|___|___|',Transform(aDados[nX, 38, nP], "@E 999")), oFont04,,,,1)
						nLinIni += 40
				Next nP
			EndIF

			if nT < Len(aDados[nX, 35]).or. lImpnovo
				nV1:=nP
				lImpnovo:=.T.
			Endif

			nLinIni := nOldLinIni

			oPrint:Say((nLinIni + 1690)*nAL, (nColIni + 0020)*nAC, "Dados da Autorização", oFont01) //Dados da Autorização
			oPrint:Box((nLinIni + 1700)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1760)*nAL, (nColIni + (nColMax*0.26) - 0010)*nAC)
			oPrint:Say((nLinIni + 1720)*nAL, (nColIni + 0030)*nAC, "39 - Data Provável da Admissão Hospitalar", oFont01) //"39 - Data Provável da Admissão Hospitalar"
			oPrint:Say((nLinIni + 1752)*nAL, (nColIni + 0040)*nAC, Iif(Empty(aDados[nX, 39]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 39])), oFont04)
			oPrint:Box((nLinIni + 1700)*nAL, (nColIni + (nColMax*0.26))*nAC, (nLinIni + 1760)*nAL, (nColIni + (nColMax*0.44) - 0010)*nAC)
			oPrint:Say((nLinIni + 1720)*nAL, (nColIni + (nColMax*0.26) + 0010)*nAC, "40 - Qtde. Diarias Autorizadas", oFont01) //"40 - Qtde. Diarias Autorizadas"
			oPrint:Say((nLinIni + 1752)*nAL, (nColIni + (nColMax*0.34))*nAC, Iif(Empty(aDados[nX, 40]),'|___|___|___|',Transform(aDados[nX, 40], "@E 999")), oFont04)
			oPrint:Box((nLinIni + 1700)*nAL, (nColIni + (nColMax*0.44))*nAC, (nLinIni + 1760)*nAL, (nColIni + (nColMax*0.66) - 0010)*nAC)
			oPrint:Say((nLinIni + 1720)*nAL, (nColIni + (nColMax*0.44) + 0010)*nAC, "41 - Tipo da Acomodação Autorizada", oFont01) //"41 - Tipo da Acomodação Autorizada"
			oPrint:Say((nLinIni + 1752)*nAL, (nColIni + (nColMax*0.54))*nAC, Iif(Empty(aDados[nX, 41]),'|___|___|',aDados[nX, 41]), oFont04)

			oPrint:Box((nLinIni + 1770)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1830)*nAL, (nColIni + (nColMax*0.33) - 0010)*nAC)
			oPrint:Say((nLinIni + 1790)*nAL, (nColIni + 0030)*nAC, "42 - Código na Operadora / CNPJ autorizado", oFont01) //"42 - Código na Operadora / CNPJ autorizado"
			oPrint:Say((nLinIni + 1822)*nAL, (nColIni + 0040)*nAC, Iif(Empty(aDados[nX, 42]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 42]), oFont04)
			oPrint:Box((nLinIni + 1770)*nAL, (nColIni + (nColMax*0.33))*nAC, (nLinIni + 1830)*nAL, (nColIni + (nColMax*0.82) - 0010)*nAC)
			oPrint:Say((nLinIni + 1790)*nAL, (nColIni + (nColMax*0.33) + 0010)*nAC, "43 - Nome do Hospital / Local Autorizado", oFont01) //"43 - Nome do Hospital / Local Autorizado"
			oPrint:Say((nLinIni + 1822)*nAL, (nColIni + (nColMax*0.33) + 0020)*nAC, Iif(Empty(aDados[nX, 43]),'',aDados[nX, 43]), oFont04)
			oPrint:Box((nLinIni + 1770)*nAL, (nColIni + (nColMax*0.82))*nAC, (nLinIni + 1830)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 1790)*nAL, (nColIni + (nColMax*0.82) + 0010)*nAC, "44 - Código CNES", oFont01) //"44 - Código CNES"
			oPrint:Say((nLinIni + 1822)*nAL, (nColIni + (nColMax*0.82) + 0020)*nAC, Iif(Empty(aDados[nX, 44]),'|___|___|___|___|___|___|___|',aDados[nX, 44]), oFont04)

			oPrint:Box((nLinIni + 1840)*nAL, (nColIni + 0020)*nAC, (nLinIni + 2260)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 1860)*nAL, (nColIni + 0030)*nAC, "45 - Observação / Justificativa", oFont01) //"45 ?Observação / Justificativa"

			nLinObs := 0
			
			If !Empty(aDados[nX, 45])
				For nI := 1 To MlCount(aDados[nX, 45], 100)
					cObs := MemoLine(aDados[nX, 45], 100, nI)
					oPrint:Say((nLinIni + 1892 + nLinObs)*nAL, (nColIni + 0040)*nAC, cObs, oFont04)
					nLinObs+=38
				Next nI
			Else
				oPrint:Say((nLinIni + 1892 + nLinObs)*nAL, (nColIni + 0040)*nAC, REPLICATE('_',156), oFont04)
				oPrint:Say((nLinIni + 1930 + nLinObs)*nAL, (nColIni + 0040)*nAC, REPLICATE('_',156), oFont04)
			EndIf

			oPrint:Box((nLinIni + 2270)*nAL, (nColIni + 0020)*nAC, (nLinIni + 2330)*nAL, (nColIni + (nColMax/4) - 0010)*nAC)
			oPrint:Say((nLinIni + 2290)*nAL, (nColIni + 0030)*nAC, "46 - Data da Solicitação", oFont01) //"46 - Data da Solicitação"
			oPrint:Say((nLinIni + 2322)*nAL, (nColIni + 0040)*nAC, Iif(Empty(aDados[nX, 46]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 46])), oFont04)
			oPrint:Box((nLinIni + 2270)*nAL, (nColIni + (nColMax/4))*nAC, (nLinIni + 2330)*nAL, (nColIni + ((nColMax/4)*2) - 0010)*nAC)
			oPrint:Say((nLinIni + 2290)*nAL, (nColIni + (nColMax/4) + 0010)*nAC, "47-Assinatura do Profissional Solicitante", oFont01) //"47-Assinatura do Profissional Solicitante"
			oPrint:Box((nLinIni + 2270)*nAL, (nColIni + ((nColMax/4)*2))*nAC, (nLinIni + 2330)*nAL, (nColIni + ((nColMax/4)*3) - 0010)*nAC)
			oPrint:Say((nLinIni + 2290)*nAL, (nColIni + ((nColMax/4)*2) + 0010)*nAC, "48-Assinatura do Beneficiário ou Responsável", oFont01) //"48-Assinatura do Beneficiário ou Responsável"
			oPrint:Box((nLinIni + 2270)*nAL, (nColIni + ((nColMax/4)*3))*nAC, (nLinIni + 2330)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 2290)*nAL, (nColIni + ((nColMax/4)*3) + 0010)*nAC, "49-Assinatura do Responsável pela Autorização", oFont01) //"49-Assinatura do Responsável pela Autorização"

			oPrint:EndPage()	// Finaliza a pagina

		Next nX

	enddo
END SEQUENCE
ErrorBlock( bError )

If !Empty(cErro)
	cArq := "erro_imp_relat_" + DtoS(Date()) + StrTran(Time(),":") + ".txt"
	MsgAlert("Erro ao gerar relatório. Visualize o log em /LOGPLS/" + cArq )
	cErro := 	"Erro ao carregar dados do relatório." + CRLF + ;
		"Verifique a cfg. de impressão da guia no cadastro de " + CRLF + ;
		"Tipos de Guias." + CRLF + CRLF + ;
		cErro
	PLSLogFil(cErro,cArq)
EndIf

If lGerTXT .And. !lWeb
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Imprime Relatorio
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:Print()
Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Visualiza impressao grafica antes de imprimir
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If lRet

		oPrint:Preview()
	Endif

	If lMail .And. (lRet:=Aviso("Atenção","Confirma o envio do relatório por e-mail?",{"Sim","Não"},1)== 1)

		If File(cFile)
			lOk := (FErase(cFile)==0)
		EndIf

		If lOk
			CpyT2S(oPrint:CPATHPDF+LOWER(cFileName),cFile,.T.)
		Else
			Aviso("Atenção","Não foi possível criar o arquivo "+cFile,{"Ok"},1)
			lRet := .F.
		EndIf
	EndIf
EndIf

Return {lRet,cFile+cFileName,cFileName}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ?PLSPRGIT  ?Autor ?MAICON SANTOS        ?Data ?16.10.14  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ?Estrutura Relatório TISS 3.00.01 (Guia Prog. Internaçao)    ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?SigaPLS                                                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros?aDados - Array com as informações do relat´rio              ³±?
±±?         ?lGerTXT - Define se imprime direto sem passar pela tela	 ³±?
±±?         ?		 de configuracao/preview do relatorio 		        ³±?
±±?         ?nLayout - Define o formato de papél para impressao:         ³±?
±±?         ?          1 - Formato Ofício II (216x330mm)                 ³±?
±±?         ?          2 - Formato A4 (210x297mm)                        ³±?
±±?         ? 		 	3 - Formato Carta (216x279mm)     			        ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PLSPRGIT(aDados, lGerTXT, nLayout, cLogoGH, lMail, lWeb, cPathRelW )

Local nLinMax
Local nColMax
Local nLinIni	:=	0	// Linha Lateral (inicial) Esquerda
Local nColIni	:=	0	// Coluna Lateral (inicial) Esquerda
Local nColA4    :=  0
Local nLinA4    :=  0
Local cFileLogo
Local nLin
Local nP:=0
Local nT:=0
Local nT1:=0
Local nT3:=0
Local nI,nJ,nK,nX
Local nR,nV,nV1,nV2,nN
Local cObs
Local oFont01
Local oFont02n
Local oFont03n
Local oFont04
Local lImpnovo  :=.T.
Local nVolta    :=0
Local cFile 	:= GetNewPar("MV_RELT",'\SPOOL\')+'PLSR421N.HTM'
Local lRet		:= .T.
Local lOk		:= .T.
LOCAL cFileName	:= ""
LOCAL cRel      := "GUICONS"
LOCAL cPathSrvJ := GETMV("MV_RELT")
LOCAL nAL		:= 0.25
LOCAL nAC		:= 0.24
Local lImpPrc   := .T.
LOCAL nLinObs	:= 0
LOCAL cIndic    := ""
LOCAL I			:=0
LOCAL J			:=0
LOCAL cErro		:= ""
LOCAL cArq			:= ""
Local bError		:= ErrorBlock( {|e| TrataErro(e,@cErro) } )
Local nLinB		:= 0
Local lPLSGTISS := ExistBlock("PLSGTISS")
DEFAULT lGerTXT 	:= .F.
DEFAULT nLayout 	:= 2
DEFAULT cLogoGH 	:= ""
DEFAULT lMail		:= .F.
DEFAULT lWeb		:= .F.
DEFAULT cPathRelW 	:= ""
DEFAULT aDados 	:= { { ;
	"123456",; 				 //1 - Registro ANS
	"12345678901234567890",; //2 - N?Guia no Prestador
	"12345678901234567890",; //3 - Número da Guia de Solicitação de Internação
	CtoD("01/01/07"),; 		 //4 - Data da Autorização
	"12345678901234567890",; //5 - Senha
	"12345678901234567890",; //6 - Número da Guia Atribuído pela Operadora
	"123456789012345678901234567890",; //7 - Número da Carteira
	Replicate("M",70),; //8 - Nome
	"12345678901234",; //9 ?Código na Operadora
	Replicate("M",70),; //10 - Nome do Contratado
	Replicate("M",70),; //11 - Nome do Profissional Solicitante
	"MM",; //12 - Conselho Profissional
	"123456789012345",; //13 - Número no Conselho
	"RS",; //14 - UF
	"123456",; //15 - Código CBO
	999,; //16 - Qtde. diárias adicionais solicitadas
	"AA",; //17 - Tipo da acomodação solicitada
	Replicate("M",500),; //18 - Indicação Clínica
	{ "10","20","30","40","50","60","70","80","90","99","00","11", "11" },; //19-Tabela
	{ "1234567890","2345678901","3456789012","4567890123","5678901234","1234567890","2345678901","3456789012","4567890123","5678901234","4567890123","5678901234","5678901234" },; //20 - Código do Procedimento
	{ Replicate("M",150),Replicate("A",150),Replicate("B",150),Replicate("C",150),Replicate("D",150),Replicate("M",150),Replicate("A",150),Replicate("B",150),Replicate("C",150),Replicate("D",150),Replicate("C",150),Replicate("D",150),Replicate("D",150) },; //21 - Descrição
	{ 999,888,777,666,555,444,333,222,111,999,888,777,777 },; //22 - Qtde Solic
	{ 111,222,333,444,555,1212,111,222,333,444,555,1212,1212 },; //23 ?Qtde Aut
	123,; //24 - Qtde. diárias adicionais autorizadas
	"AA",;//25 - Tipo da Acomodação Autorizada
	Replicate("O",500),; //26 - Justificativa da Operadora
	Replicate("O",500),; //27 ?Observação / Justificativa
	CtoD("12/12/07") } } //28 - Data da Solicitação

If nLayout  == 1 // Ofício 2
	nLinMax	:=	3705	// Numero maximo de Linhas (31,5 cm)
	nColMax	:=	2400	// Numero maximo de Colunas (21 cm)
Elseif nLayout == 2   // Papél A4
	nLinMax	:=	2478
	nColMax	:=	2335
Else //Carta
	nLinMax	:=	3155
	nColMax	:=	2400
Endif

oFont01		:= TFont():New("Arial",  5,  5, , .F., , , , .T., .F.) // Normal
if nLayout == 1 // Oficio 2
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
Else  // Papél A4 ou Carta
	oFont02n := TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n := TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04	 := TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Nao permite acionar a impressao quando for na web.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lWeb
	cPathSrvJ := cPathRelW
	cFileName := cRel+CriaTrab(NIL,.F.)+".pdf"
Else
	cFileName := cRel+CriaTrab(NIL,.F.)
EndIf

	//						New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF] )
oPrint := FWMSPrinter():New ( cFileName			,			,	.F.				,cPathSrvJ	 	,	.T.				,			 ,				,			  ,			  ,	.F.			, 		, 				)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Tratamento para impressao via job
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//oPrint:lInJob  := lWeb
oPrint:lServer := lWeb
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Caminho do arquivo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
oPrint:cPathPDF := cPathSrvJ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Modo retrato
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
oPrint:SetPortrait()	// Modo retrato

If nLayout ==2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Papél A4
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:SetPaperSize(9)
ElseIf nLayout ==3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Papél Carta
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:SetPaperSize(1)
Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Papel Oficio2 216 x 330mm / 8 1/2 x 13in
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:SetPaperSize(14)
Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Device
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lWeb
	oPrint:setDevice(IMP_PDF)
	oPrint:lPDFAsPNG := .T.
EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Verifica se existe alguma impressora configurada para Impressao Grafica
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If  !lWeb
	oPrint:Setup()
	If !(oPrint:nModalResult == 1)
		lRet := .F.
		lMail := .F.
		lImpnovo:=.F.
	Else
		lImpnovo:=(oPrint:nModalResult == 1)
	Endif
EndIf

If Empty(aDados[1])
	aDados 	:= { { ;
		"",; 				 //1 - Registro ANS
		"",; //2 - N?Guia no Prestador
		"",; //3 - Número da Guia de Solicitação de Internação
		'',; 		 //4 - Data da Autorização
		"",; //5 - Senha
		"",; //6 - Número da Guia Atribuído pela Operadora
		"",; //7 - Número da Carteira
		'',; //8 - Nome
		"",; //9 ?Código na Operadora
		'',; //10 - Nome do Contratado
		'',; //11 - Nome do Profissional Solicitante
		"",; //12 - Conselho Profissional
		"",; //13 - Número no Conselho
		"",; //14 - UF
		"",; //15 - Código CBO
		'',; //16 - Qtde. diárias adicionais solicitadas
		"",; //17 - Tipo da acomodação solicitada
		'',; //18 - Indicação Clínica
		{ "","","","","","","","","" },; //19-Tabela
		{ "","","","","","","","","" },; //20 - Código do Procedimento
		{ '','','','','','','','','' },; //21 - Descrição
		{ '','','','','','','','','' },; //22 - Qtde Solic
		{ '','','','','','','','','' },; //23 ?Qtde Aut
		'',; //24 - Qtde. diárias adicionais autorizadas
		"",;//25 - Tipo da Acomodação Autorizada
		'',; //26 - Justificativa da Operadora
		'',; //27 ?Observação / Justificativa
		'' } } //28 - Data da Solicitação
EndIf



For I:=1 to Len(aDados)    // Prevenindo de erros log
	For J:=1 To Len(aDados[I])
		If ValType(aDados[I,J])=="U"
			//lImpnovo:=.F.
			aDados[I,J] := " - "
		Endif
	Next J
Next I

BEGIN SEQUENCE
	While lImpnovo

		lImpnovo:=.F.
		nVolta  += 1
		nT      += 9
		nT1     += 2
		nT3     += 3


		For nX := 1 To Len(aDados)

			If Len(aDados[nX]) == 0
				Loop
			EndIf

			For nI := 19 To 23
				If Len(aDados[nX, nI]) < nT
					For nJ := Len(aDados[nX, nI]) + 1 To nT
						If AllTrim(Str(nI)) $ "22,23"
							aAdd(aDados[nX, nI], 0)
						Else
							aAdd(aDados[nX, nI], "")
						EndIf
					Next nJ
				EndIf
			Next nI

			If oPrint:Cprinter == "PDF" .OR. lWeb
				nLinIni := 150
			Else
				nLinIni := 000
			Endif

			nColIni := 060
			nColA4  := 000
			nLinA4  := 000

			oPrint:StartPage()		// Inicia uma nova pagina

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:Box((nLinIni + 0000)*nAL, (nColIni + 0010)*nAC, (nLinIni + nLinMax - 10)*nAL, (nColIni + nColMax)*nAC)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega e Imprime Logotipo da Empresa                         ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fLogoEmp(@cFileLogo,, cLogoGH)

			If File(cFilelogo)
				oPrint:SayBitmap((nLinIni + 0050)*nAL, (nColIni + 0020)*nAC, cFileLogo, (400)*nAL, (090)*nAC) 		// Tem que estar abaixo do RootPath
			EndIf

			If nLayout == 2 // Papél A4
				nColA4    := -0065
			Elseif nLayout == 3// Carta
				nLinA4    := -0085
			Endif

			oPrint:Say((nLinIni + 0050)*nAL, (nColIni + (nColMax*0.40))*nAC, "GUIA DE SOLICITAÇÃO", oFont02n) //"GUIA DE SOLICITAÇÃO"
			oPrint:Say((nLinIni + 0050)*nAL, (nColIni + (nColMax*0.69))*nAC, "2- N?Guia no Prestador", oFont01) //"2- N?Guia no Prestador"
			oPrint:Say((nLinIni + 0050)*nAL, (nColIni + (nColMax*0.78))*nAC, aDados[nX, 02], oFont03n)
			oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.34))*nAC, "DE PRORROGAÇÃO DE INTERNAÇÃO", oFont02n) //"DE PRORROGAÇÃO DE INTERNAÇÃO"
			oPrint:Say((nLinIni + 0150)*nAL, (nColIni + (nColMax*0.32))*nAC, "OU COMPLEMENTAÇÃO DO TRATAMENTO", oFont02n) //"OU COMPLEMENTAÇÃO DO TRATAMENTO"

		//Linha 1
			oPrint:Box((nLinIni + 0180)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0240)*nAL, (nColIni + (nColMax*0.18)- 0010)*nAC)
			oPrint:Say((nLinIni + 0200)*nAL, (nColIni + 0030)*nAC, "1 - Registro ANS", oFont01) //"1 - Registro ANS"
			oPrint:Say((nLinIni + 0232)*nAL, (nColIni + 0040)*nAC, Iif(Empty(SUBSTR(aDados[nX, 01],1,6)),'|___|___|___|___|___|___|',SUBSTR(aDados[nX, 01],1,6)), oFont04)
			oPrint:Box((nLinIni + 0180)*nAL, (nColIni + (nColMax*0.18))*nAC, (nLinIni + 0240)*nAL, (nColIni + (nColMax*0.64) - 0010)*nAC)
			oPrint:Say((nLinIni + 0200)*nAL, (nColIni + (nColMax*0.18) + 0010)*nAC, "3 - Número da Guia de Solicitação de Internação", oFont01) //"3 - Número da Guia de Solicitação de Internação"
			oPrint:Say((nLinIni + 0232)*nAL, (nColIni + (nColMax*0.18) + 0020)*nAC, Iif(Empty(aDados[nX, 03]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 03]), oFont04)
			oPrint:Box((nLinIni + 0180)*nAL, (nColIni + (nColMax*0.64))*nAC, (nLinIni + 0240)*nAL, (nColIni + (nColMax*0.85) - 0010)*nAC)
			oPrint:Say((nLinIni + 0200)*nAL, (nColIni + (nColMax*0.64) + 0010)*nAC, "4 - Data da Autorização", oFont01) //"4 - Data da Autorização"
			oPrint:Say((nLinIni + 0232)*nAL, (nColIni + (nColMax*0.64) + 0020)*nAC, Iif(Empty(aDados[nX, 04]),'|___|___|/|___|___|/|___|___|___|___|',IIF( ValType(aDados[nX, 04]) == "D", DtoC(aDados[nX, 04]), aDados[nX, 04])), oFont04)

		//Linha 2
			oPrint:Box((nLinIni + 0250)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0310)*nAL, (nColIni + (nColMax*0.50) - 0010)*nAC)
			oPrint:Say((nLinIni + 0270)*nAL, (nColIni + 0030)*nAC, "5 - Senha", oFont01) //"5 - Senha"
			oPrint:Say((nLinIni + 0302)*nAL, (nColIni + 0040)*nAC, Iif(Empty(SUBSTR(aDados[nX, 05],1,20)),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',SUBSTR(aDados[nX, 05],1,20)), oFont04)
			oPrint:Box((nLinIni + 0250)*nAL, (nColIni + (nColMax*0.50))*nAC, (nLinIni + 0310)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 0270)*nAL, (nColIni + (nColMax*0.50) + 0010)*nAC, "6 - Número da Guia Atribuído pela Operadora", oFont01) //"6 - Número da Guia Atribuído pela Operadora"
			oPrint:Say((nLinIni + 0302)*nAL, (nColIni + (nColMax*0.50) + 0020)*nAC, Iif(Empty(aDados[nX, 06]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 06]), oFont04)

		//Linha 3
			oPrint:Say((nLinIni + 0330)*nAL, (nColIni + 0020)*nAC, "Dados do Beneficiário", oFont01) //Dados do Beneficiário*/

		//Linha 4
			oPrint:Box((nLinIni + 0340)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0400)*nAL, (nColIni + (nColMax*0.50) - 0010)*nAC)
			oPrint:Say((nLinIni + 0360)*nAL, (nColIni + 0030)*nAC, "7 - Número da Carteira", oFont01) //"7 - Número da Carteira"
			oPrint:Say((nLinIni + 0392)*nAL, (nColIni + 0040)*nAC, Iif(Empty(aDados[nX, 07]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 07]), oFont04)
			oPrint:Box((nLinIni + 0340)*nAL, (nColIni + (nColMax*0.50))*nAC, (nLinIni + 0400)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 0360)*nAL, (nColIni + (nColMax*0.50) + 0010)*nAC, "8 - Nome", oFont01) //"8 - Nome"
			oPrint:Say((nLinIni + 0392)*nAL, (nColIni + (nColMax*0.50) + 0020)*nAC, SUBSTR(aDados[nX, 8],1,70), oFont04)

		//Linha 5
			oPrint:Say((nLinIni + 0420)*nAL, (nColIni + 0020)*nAC, "Dados do Contratado Solicitante", oFont01) //Dados do Contratado Solicitante

		//Linha 6
			oPrint:Box((nLinIni + 0430)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0490)*nAL, (nColIni + (nColMax*0.40) - 0010)*nAC)
			oPrint:Say((nLinIni + 0450)*nAL, (nColIni + 0030)*nAC, "9 - Código na Operadora", oFont01) //"9 - Código na Operadora"
			oPrint:Say((nLinIni + 0482)*nAL, (nColIni + 0040)*nAC, Iif(Empty(SUBSTR(aDados[nX, 9],1,14)),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',SUBSTR(aDados[nX, 9],1,14)), oFont04)
			oPrint:Box((nLinIni + 0430)*nAL, (nColIni + (nColMax*0.40))*nAC, (nLinIni + 0490)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 0450)*nAL, (nColIni + (nColMax*0.40) + 0010)*nAC, "10 - Nome do Contratado", oFont01) //"10 - Nome do Contratado"
			oPrint:Say((nLinIni + 0482)*nAL, (nColIni + (nColMax*0.40) + 0020)*nAC, SUBSTR(aDados[nX, 10],1,70), oFont04)

		//Linha 7
			oPrint:Box((nLinIni + 0500)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0560)*nAL, (nColIni + (nColMax*0.40) - 0010)*nAC)
			oPrint:Say((nLinIni + 0520)*nAL, (nColIni + 0030)*nAC, "11 - Nome do Profissional Solicitante", oFont01) //"11 - Nome do Profissional Solicitante"
			oPrint:Say((nLinIni + 0552)*nAL, (nColIni + 0040)*nAC, SUBSTR(aDados[nX, 11],1,70), oFont04)
			oPrint:Box((nLinIni + 0500)*nAL, (nColIni + (nColMax*0.40))*nAC, (nLinIni + 0560)*nAL, (nColIni + (nColMax*0.46) - 0010)*nAC)
			oPrint:Say((nLinIni + 0518)*nAL, (nColIni + (nColMax*0.40) + 0010)*nAC, "12 - Conselho", oFont01) //"12 - Conselho"
			oPrint:Say((nLinIni + 0532)*nAL, (nColIni + (nColMax*0.40) + 0015)*nAC, "Profissional", oFont01) //"Profissional"
			oPrint:Say((nLinIni + 0558)*nAL, (nColIni + (nColMax*0.40) + 0020)*nAC, Iif(Empty(SUBSTR(aDados[nX, 12],1,3)),'|___|___|',SUBSTR(aDados[nX, 12],1,3)), oFont04)
			oPrint:Box((nLinIni + 0500)*nAL, (nColIni + (nColMax*0.46))*nAC, (nLinIni + 0560)*nAL, (nColIni + (nColMax*0.78) - 0010)*nAC)
			oPrint:Say((nLinIni + 0520)*nAL, (nColIni + (nColMax*0.46) + 0010)*nAC, "13 - Número no Conselho", oFont01) //"13 - Número no Conselho"
			oPrint:Say((nLinIni + 0552)*nAL, (nColIni + (nColMax*0.46) + 0020)*nAC, Iif(Empty(SUBSTR(aDados[nX, 13],1,15)),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',SUBSTR(aDados[nX, 13],1,15)), oFont04)
			oPrint:Box((nLinIni + 0500)*nAL, (nColIni + (nColMax*0.78))*nAC, (nLinIni + 0560)*nAL, (nColIni + (nColMax*0.85) - 0010)*nAC)
			oPrint:Say((nLinIni + 0520)*nAL, (nColIni + (nColMax*0.78) + 0010)*nAC, "14 - UF", oFont01) //"14 - UF"
			oPrint:Say((nLinIni + 0552)*nAL, (nColIni + (nColMax*0.78) + 0020)*nAC, Iif(Empty(SUBSTR(aDados[nX, 14],1,2)),'|___|___|',SUBSTR(aDados[nX, 14],1,2)), oFont04)
			oPrint:Box((nLinIni + 0500)*nAL, (nColIni + (nColMax*0.85))*nAC, (nLinIni + 0560)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 0520)*nAL, (nColIni + (nColMax*0.85) + 0010)*nAC, "15 - Código CBO", oFont01) //"15 - Código CBO"
			oPrint:Say((nLinIni + 0552)*nAL, (nColIni + (nColMax*0.85) + 0020)*nAC, Iif(Empty(SUBSTR(aDados[nX, 15],1,6)),'|___|___|___|___|___|___|',SUBSTR(aDados[nX, 15],1,6)), oFont04)

		//Linha 8
			oPrint:Say((nLinIni + 0580)*nAL, (nColIni + 0020)*nAC, "Dados da Internação", oFont01) //Dados da Internação

		//Linha 9
			oPrint:Box((nLinIni + 0590)*nAL, (nColIni + 0020)*nAC, (nLinIni + 0650)*nAL, (nColIni + (nColMax*0.20) - 0010)*nAC)
			oPrint:Say((nLinIni + 0610)*nAL, (nColIni + 0030)*nAC, "16 - Qtde. Diárias Adicionais Solicitadas", oFont01) //"16 - Qtde. Diárias Adicionais Solicitadas / CNPJ"
			oPrint:Say((nLinIni + 0642)*nAL, (nColIni + 0040)*nAC, IIf(Empty(aDados[nX, 16]), '|___|___|___|', Transform(aDados[nX, 16], "@E 999")), oFont04)
			oPrint:Box((nLinIni + 0590)*nAL, (nColIni + (nColMax*0.20))*nAC, (nLinIni + 0650)*nAL, (nColIni + (nColMax*0.45) - 0010)*nAC)
			oPrint:Say((nLinIni + 0610)*nAL, (nColIni + (nColMax*0.20) + 0010)*nAC, "17 - Tipo da Acomodação Solicitada", oFont01) //"17-Tipo de Internação"
			oPrint:Say((nLinIni + 0642)*nAL, (nColIni + (nColMax*0.21))*nAC, IIf(Empty(aDados[nX, 17]), '|___|___|',aDados[nX, 17]), oFont04)

		//Linha 10
			oPrint:Box((nLinIni + 0660)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1200)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 0680)*nAL, (nColIni + 0030)*nAC, "18 - Indicação Clínica", oFont01) //"18 - Indicação Clínica"
			//oPrint:Say((nLinIni + 0712 + nLinObs)*nAL, (nColIni + 0040)*nAC,  aDados[nX, 18], oFont04)

			nLinB := nLinIni
			If !Empty(aDados[nX, 18])
				For nI := 1 To MlCount(aDados[nX, 18], 180)
					cObs := MemoLine(aDados[nX, 18], 180, nI)
					oPrint:Say((nLinB + 0712)*nAl, (nColIni + 0040)*nAC, Iif(Empty(cObs),REPLICATE('_',150),cObs), oFont04)
					nLinB += 30
					If nI == 15
						exit
					Endif
				Next nI
			Else
				For nI := 1 To 12
					oPrint:Say((nLinB + 0712)*nAl, (nColIni + 0040)*nAC, REPLICATE('_',150), oFont04)
					nLinB += 30
				Next nI
			EndIf


		//Linha 11
			oPrint:Say((nLinIni + 1228)*nAL, (nColIni + 0020)*nAC, "Procedimentos Solicitados", oFont01) //Procedimentos Solicitados
		//Linha 12
			oPrint:Box((nLinIni + 1238)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1638)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 1258)*nAL, (nColIni + (nColMax*0.02))*nAC, "19 - Tabela", oFont01) //19-Tabela
			oPrint:Say((nLinIni + 1258)*nAL, (nColIni + (nColMax*0.07))*nAC, "20 - Código do Procedimento", oFont01) //20 - Código do Procedimento
			oPrint:Say((nLinIni + 1258)*nAL, (nColIni + (nColMax*0.31))*nAC, "21 - Descrição", oFont01) //21 - Descrição
			oPrint:Say((nLinIni + 1258)*nAL, (nColIni + (nColMax*0.86))*nAC, "22 - Qtde Solic", oFont01) //22 - Qtde Solic
			oPrint:Say((nLinIni + 1258)*nAL, (nColIni + (nColMax*0.93))*nAC, "23 - Qtde Aut", oFont01) //23 ?Qtde Aut

			nOldLinIni := nLinIni

			if nVolta=1
				nV1:=1
			Endif

			If lPLSGTISS
				lImpPrc := ExecBlock("PLSGTISS",.F.,.F.,{"03",lImpPrc})
			EndIf

			If lImpPrc

				For nP := nV1 To nT
					//If !Empty(Alltrim(aDados[nx,19,nP]))
						oPrint:Say((nLinIni + 1298)*nAL, (nColIni + 0025)*nAC, AllTrim(Str(nP)) + " - ", oFont01)
						oPrint:Say((nLinIni + 1298)*nAL, (nColIni + (nColMax*0.03))*nAC, Iif(Empty(aDados[nX, 19, nP]),'|___|___|',aDados[nX, 19, nP]), oFont04)
						oPrint:Say((nLinIni + 1298)*nAL, (nColIni + (nColMax*0.08))*nAC, Iif(Empty(aDados[nX, 20, nP]),'|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 20, nP]), oFont04)
						oPrint:Say((nLinIni + 1298)*nAL, (nColIni + (nColMax*0.31))*nAC, Iif(Empty(aDados[nX, 21, nP]),REPLICATE('_',105),SUBSTR(aDados[nX, 21, nP],1,300)), oFont01)
						oPrint:Say((nLinIni + 1298)*nAL, (nColIni + (nColMax*0.84))*nAC, if (Empty(aDados[nX, 22, nP]),'|___|___|___|',Transform(aDados[nX, 22, nP], "@E 999")), oFont04,,,,1)
						oPrint:Say((nLinIni + 1298)*nAL, (nColIni + (nColMax*0.91))*nAC, if (Empty(aDados[nX, 23, nP]),'|___|___|___|',Transform(aDados[nX, 23, nP], "@E 999")), oFont04,,,,1)
						nLinIni += 40
					//Endif
				Next nP

			EndIf

			if nT < Len(aDados[nX, 20]).or. lImpnovo
				nV1:=nP
				lImpnovo:=.T.
			Endif

			nLinIni := nOldLinIni

		//Linha 13
			oPrint:Say((nLinIni + 1666)*nAL, (nColIni + 0020)*nAC, "Dados da Autorização", oFont01) //Dados da Autorização

		//Linha 14
			oPrint:Box((nLinIni + 1676)*nAL, (nColIni + 0020)*nAC, (nLinIni + 1736)*nAL, (nColIni + (nColMax*0.20) - 0010)*nAC)

			oPrint:Say((nLinIni + 1696)*nAL, (nColIni + 0030)*nAC, "24 - Qtde. Diárias Adicionais Autorizadas", oFont01) //"24 - Data Provável da Admissão Hospitalar"
			oPrint:Say((nLinIni + 1728)*nAL, (nColIni + 0040)*nAC, Iif(Empty((aDados[nX, 24])),'|___|___|___|',aDados[nX, 24]), oFont04)
			oPrint:Box((nLinIni + 1676)*nAL, (nColIni + (nColMax*0.20))*nAC, (nLinIni + 1736)*nAL, (nColIni + (nColMax*0.45) - 0040)*nAC)

			oPrint:Say((nLinIni + 1696)*nAL, (nColIni + (nColMax*0.20) + 0010)*nAC, "25 - Tipo da Acomodação Autorizada", oFont01) //"25 - Tipo da Acomodação Autorizada"
			oPrint:Say((nLinIni + 1728)*nAL, (nColIni + (nColMax*0.21))*nAC, Iif(Empty(aDados[nX, 25]),'|___|___|',aDados[nX, 25]), oFont04)

		//Linha 15
			oPrint:Box((nLinIni + 1746)*nAL, (nColIni + 0020)*nAC, (nLinIni + 2058)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 1766)*nAL, (nColIni + 0030)*nAC, "26 - Justificativa da Operadora", oFont01) //"26 - Código na Operadora / CNPJ autorizado"

			nLinB := 0
			nLinB := nLinIni
			If !Empty(aDados[nX, 26]) 
				For nI := 1 To MlCount(aDados[nX, 26], 180)
					cObs := MemoLine(aDados[nX, 26], 180, nI)
					oPrint:Say((nLinB + 1798)*nAl, (nColIni + 0040)*nAC, Iif(Empty(cObs),REPLICATE('_',150),cObs), oFont04)
					nLinB += 30
					If nI == 8
						exit
					Endif
				Next nI
			Else
				For nI := 1 To 8
					oPrint:Say((nLinB + 1798)*nAl, (nColIni + 0040)*nAC, REPLICATE('_',150), oFont04)
					nLinB += 30
				Next nI
			EndIf


		//Linha 16
			oPrint:Box((nLinIni + 2068)*nAL, (nColIni + 0020)*nAC, (nLinIni + 2388)*nAL, (nColIni + nColMax - 0010)*nAC)
			oPrint:Say((nLinIni + 2088)*nAL, (nColIni + 0030)*nAC, "27 - Observação / Justificativa", oFont01) //"27 ?Observação / Justificativa"

			nLinB := 0
			nLinB := nLinIni
			If !Empty(aDados[nX, 27])
				For nI := 1 To MlCount(aDados[nX, 27], 180)
					cObs := MemoLine(aDados[nX, 27], 180, nI)
					oPrint:Say((nLinB + 2120)*nAl, (nColIni + 0040)*nAC, Iif(Empty(cObs),REPLICATE('_',150),cObs), oFont04)
					nLinB += 30
					If nI == 8
						exit
					Endif
				Next nI
			Else
				For nI := 1 To 8
					oPrint:Say((nLinB + 2120)*nAl, (nColIni + 0040)*nAC, REPLICATE('_',150), oFont04)
					nLinB += 30
				Next nI
			EndIf
			

		//Linha 17
			oPrint:Box((nLinIni + 2398)*nAL, (nColIni + 0020)*nAC, (nLinIni + 2458)*nAL, (nColIni + (nColMax/3) - 0010)*nAC)
			oPrint:Say((nLinIni + 2418)*nAL, (nColIni + 0030)*nAC, "28 - Data da Solicitação", oFont01) //"28 - Data da Solicitação"
			oPrint:Say((nLinIni + 2450)*nAL, (nColIni + 0040)*nAC, Iif(Empty(aDados[nX, 28]),'|___|___|/|___|___|/|___|___|___|___|',IIF( ValType(aDados[nX, 28]) == "D", DtoC(aDados[nX, 28]), aDados[nX, 28])), oFont04)
			oPrint:Box((nLinIni + 2398)*nAL, (nColIni + (nColMax/3))*nAC, (nLinIni + 2458)*nAL, (nColIni + ((nColMax/3)*2) - 0010)*nAC)
			oPrint:Say((nLinIni + 2418)*nAL, (nColIni + (nColMax/3) + 0010)*nAC, "29-Assinatura do Profissional Solicitante", oFont01) //"29-Assinatura do Profissional Solicitante"
			oPrint:Box((nLinIni + 2398)*nAL, (nColIni + ((nColMax/3)*2))*nAC, (nLinIni + 2458)*nAL, (nColIni + ((nColMax/3)*3) - 0010)*nAC)
			oPrint:Say((nLinIni + 2418)*nAL, (nColIni + ((nColMax/3)*2) + 0010)*nAC, "30-Assinatura do Responsável pela Autorização", oFont01) //"30-Assinatura do Beneficiário ou Responsável"

			oPrint:EndPage()	// Finaliza a pagina

		Next nX

	enddo
END SEQUENCE
ErrorBlock( bError )

If !Empty(cErro)
	cArq := "erro_imp_relat_" + DtoS(Date()) + StrTran(Time(),":") + ".txt"
	MsgAlert("Erro ao gerar relatório. Visualize o log em /LOGPLS/" + cArq )
	cErro := 	"Erro ao carregar dados do relatório." + CRLF + ;
		"Verifique a cfg. de impressão da guia no cadastro de " + CRLF + ;
		"Tipos de Guias." + CRLF + CRLF + ;
		cErro
	PLSLogFil(cErro,cArq)
EndIf

If lGerTXT .And. !lWeb
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Imprime Relatorio
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:Print()
Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Visualiza impressao grafica antes de imprimir
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If lRet

		oPrint:Preview()
	Endif

	If lMail .And. (lRet:=Aviso("Atenção","Confirma o envio do relatório por e-mail?",{"Sim","Não"},1)== 1)

		If File(cFile)
			lOk := (FErase(cFile)==0)
		EndIf

		If lOk
			oPrint:SaveAsHTML(cFile)
		Else
			Aviso("Atenção","Não foi possível criar o arquivo "+cFile,{"Ok"},1)
			lRet := .F.
		EndIf

	EndIf

EndIf

Return {lRet,cFile,cFileName}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ?PLSRESIT ?Autor ?Bruno Iserhardt       ?Data ?25.06.13 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ?Estrutura Relatório TISS 3.00.01 (Guia Res. Internaçao)     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?SigaPLS                                                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros?aDados - Array com as informações do relat´rio              ³±?
±±?         ?lGerTXT - Define se imprime direto sem passar pela tela 	   ³±?
±±?         ?		 de configuracao/preview do relatorio 		       ³±?
±±?         ?nLayout - Define o formato de papél para impressao:         ³±?
±±?         ?          1 - Formato Ofício II (216x330mm)                 ³±?
±±?         ?          2 - Formato A4 (210x297mm)                        ³±?
±±?         ? 		 3 - Formato Carta (216x279mm)     			       ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PLSRESIT(aDados, lGerTXT, nLayout, cLogoGH,lWeb, cPathRelW)

Local nLinMax
	Local nColMax
	Local nLinIni := 0		// Linha Lateral (inicial) Esquerda
	Local nColIni := 0		// Coluna Lateral (inicial) Esquerda
    Local nColA4  := 0
    Local nCol2A4 := 0
	Local cFileLogo
	Local lPrinter
	Local nLin 	:= 0
	Local nOldLinIni
	Local nI, nJ, nX, nN
	Local cObs
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local lImpnovo:=.T.
	Local nVolta  := 0
	Local nP   	  := 0
	Local nP1     := 0
	Local nP2     := 0
	Local nP3     := 0
	Local nP4     := 0
	Local nP5     := 0
	Local nT      := 0
	Local nT1     := 0
	Local nT2     := 0
	Local nT3     := 0
	Local nT4     := 0
	Local nAte    := 22
	Local nAte1   := 26
	Local nAte2   := 5
	
	LOCAL nLwebC := 0
	LOCAL nLweb  := 0
	LOCAl nTweb  := 1 
	LOCAL nWeb	  := 0
	local oPrint  := nil	//07-12
	LOCAL cPathSrvJ := GETMV("MV_RELT") //07-12
	LOCAL cFileName := "" //07-12
	LOCAL cErro		:= ""
	LOCAL cArq			:= ""
	LOCAL cRel      := "resinte"
	//Local bError		:= ErrorBlock( {|e| TrataErro(e,@cErro) } )

	Default lGerTXT := .F.
	Default nLayout := 2
	Default cLogoGH := ''
	DEFAULT lWeb		:= .F. /*07-12*/
	DEFAULT cPathRelW 	:= ""  /*07-12*/
	
	Default aDados := { { ;
						"123456",; //1 - Registro ANS
						"12345678901234567890",; //2- N?Guia no Prestador
						"12345678901234567890",; //3 - Número da Guia de Solicitação de Internação
						CtoD("01/01/07"),; //4 - Data da Autorização
						"12345678901234567890",; //5 - Senha
						CtoD("01/01/07"),; //6 - Data de Validade da Senha
						"12345678901234567890",; //7- Número da Guia Atribuído pela Operadora
						"12345678901234567890",; //8 - Número da Carteira
						CtoD("12/12/07"),; //9 - Validade da Carteira
						Replicate("M",70),; //10- Nome
						"123456789012345",; //11 - Cartão Nacional de Saúde
						"S",; //12-Atendimento a RN
						"12345678901234",; //13 - Código na Operadora
						Replicate("M",70),; //14 - Nome do Contratado
						"1234567",; //15 - Código CNES
						"U",; //16 - Caráter do Atendimento
						"T",; //17 - Tipo de Faturamento
						CtoD("12/12/07"),; //18- Data do Início do Faturamento
						"00:00",; //19- Hora do Início do Faturamento
						CtoD("12/12/07"),; //20- Data do Fim do Faturamento
						"99:99",; //21- Hora do Fim do Faturamento
						"I",; //22- Tipo de Internação
						"E",; //23- Regime de Internação
						"0000",; //24 - CID 10 Principal
						"1111",; //25 - CID 10 (2)
						"2222",; //26 - CID 10 (3)
						"3333",; //27 - CID 10 (4)
						"1",; //28 - Indicação de Acidente (acidente ou doença relacionada)
						"00",; //29 - Motivo de Encerramento da Internação
						"12345678901",; //30-Número da declaração de nascido vivo
						"4444",; //31 - CID 10 Óbito
						"12345678901",; //32 - Numero da declaração de óbito
						"N",; //33 -Indicador D.O. de RN
						{ CtoD("12/01/06"),CtoD("12/02/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06")},; //34-Data
						{ "0107","0207","0307","0407","0507"},; //35-Hora Inicial
						{ "0607","0707","0807","0907","1007"},; //36-Hora Final
						{ "10", "20", "30", "40", "50", "60" },; //37-Tabela
						{ "1234567890","2345678901","3456789012","4567890123","5678901234","5678901234"},; //38-Código do Procedimento
						{ Replicate("M",60),Replicate("B",60),Replicate("C",60),Replicate("D",60),Replicate("E",60),Replicate("E",60)},; //39-Descrição
						{ "0", "1", "2", "3", "4"},; //40-Qtde.
						{ "0", "1", "2", "3", "4"},; //41-Via
						{ "0", "1", "2", "3", "4"},; //42-Téc
						{ 111.00,222.00,333.00,444.00,999.99},; //43-Fator Red/Acresc
						{ 99999.99,22222.22,33.33,44444.44},; //44-Valor Unitário (R$)
						{ 111111.11,555555.00,666666.00,777777.00,888888.00},; //45-Valor Total (R$)
						{ "01", "02", "03", "04", "05"},; //46-Seq.Ref
						{ "02", "03", "04", "05", "06"},; //47-Grau Part.
						{ Replicate("M",14), Replicate("D",14), Replicate("C",14), Replicate("A",14)},; //48-Código na Operadora/CPF
						{ Replicate("A", 70), Replicate("B", 70), Replicate("C", 70), Replicate("D", 70), Replicate("E", 70)},; //49-Nome do Profissional
						{ "01", "01", "01", "01", "01", "01", "01", "01", "01", "01", "01"},; //50-Conselho Profissional
						{ "123456789102345", "123456789102345", "123456789102345", "123456789102345", "123456789102345"},; //51-Número no Conselho
						{ "01", "02", "03", "04", "05",},; //52-UF
						{ "123456", "123456", "123456", "123456", "123456"},; //53-Código CBO
						19999900.99,; //54 - Total de Procedimentos (R$)
						19999900.99,; //55 - Total de Diárias (R$)
						19999900.99,; //56 - Total de Taxase Aluguéis (R$)
						19999900.99,; //57 - Total de Materiais (R$)
						19999900.99,; //59- Total de OPME (R$)
						19999900.99,; //58 - Total de Medicamentos (R$)
						19999900.99,; //60 - Total de Gases Medicinais (R$)
						19999900.99,; //61 - Total Geral (R$)
						CtoD("01/01/07"),; //62- Data da assinatura do contratado
						Replicate("M",500) } } //65 ?Observações / Justificativa

If nLayout  == 1 // Ofício 2
	nLinMax := 2275
	nColMax := 3705	//3765
Elseif nLayout == 2   // Papél A4
   	nLinMax	:=	2275
	nColMax	:=	3370 //3365
Else //Carta
	nLinMax	:=	2435
	nColMax	:=	3175
Endif


oFont01		:= TFont():New("Arial",  6,  5, , .F., , , , .T., .F.) // Normal
if nLayout == 1 // Oficio 2
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	oFont05		:= TFont():New("Arial", 06, 06, , .F., , , , .T., .F.) // Normal
Else  // Papél A4 ou Carta
  	oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	oFont05		:= TFont():New("Arial", 06, 06, , .F., , , , .T., .F.) // Normal
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Nao permite acionar a impressao quando for na web.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lWeb
	cPathSrvJ := cPathRelW
	cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
Else
	cFileName := cRel+CriaTrab(NIL,.F.)
EndIf

if !lWeb
	oPrint	:= TMSPrinter():New("GUIA DE RESUMO DE INTERNACAO") //"GUIA DE RESUMO DE INTERNACAO"
else
	oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ	 ,.T.,	,@oPrint,			  ,			  ,	.F.			,.f.)
	If lSrvUnix
		AjusPath(@oPrint)
	EndIf
	nTweb		:= 3.9
	nLweb		:= 10
	nLwebC		:= -3
	nColMax		:= 3100
	nWeb		:= 25
	oPrint:lServer := lWeb
Endif

oPrint:SetLandscape()		// Modo paisagem

if nLayout ==2
	oPrint:SetPaperSize(9)// Papél A4
Elseif nLayout ==3
	oPrint:SetPaperSize(1)// Papél Carta
Else
	oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Device
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lWeb
	oPrint:setDevice(IMP_PDF)
Else
	// Verifica se existe alguma impressora configurada para Impressao Grafica
	lPrinter := oPrint:IsPrinterActive()

	If ! lPrinter
		oPrint:Setup()
	EndIf
Endif

BEGIN SEQUENCE
	While lImpnovo
	
		lImpnovo:=.F.
		nVolta  += 1
		nAte    += nP
		nAte1   += nP1
		nAte2   += nP4

		For nX := 1 To Len(aDados)
	
			If Len(aDados[nX]) == 0
				Loop
			EndIf
	
			For nI := 34 To 45
				If Len(aDados[nX, nI]) < nAte
					For nJ := Len(aDados[nX, nI]) + 1 To nAte
						If AllTrim(Str(nI)) $ "34"
							aAdd(aDados[nX, nI], StoD(""))
						ElseIf AllTrim(Str(nI)) $ "40,43,44,45"
							aAdd(aDados[nX, nI], 0)
						Else
							aAdd(aDados[nX, nI], "")
						EndIf
					Next nJ
				EndIf
			Next nI

			For nI := 46 To 53
				If Len(aDados[nX, nI]) < nAte1
					For nJ := Len(aDados[nX, nI]) + 1 To nAte1
						aAdd(aDados[nX, nI], "")
					Next nJ
				EndIf
			Next nI
	
			nLinIni := 080
			nColIni := 080
			nLin 	:= 000
			nColA4  := 000
			nCol2A4 := 000
	
			oPrint:StartPage()		// Inicia uma nova pagina
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Box Principal                                                 ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:Box((nLinIni + 0000)/nTweb, (nColIni + 0000)/nTweb, (nLinIni + nLinMax)/nTweb, (nColIni + nColMax)/nTweb)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega e Imprime Logotipo da Empresa                         ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fLogoEmp(@cFileLogo,, cLogoGH)
	
			If File(cFilelogo)
				oPrint:SayBitmap((nLinIni + 0050)/nTweb, (nColIni + 0020)/nTweb, cFileLogo, (400)/nTweb, (080)/nTweb) 	
			EndIf
	
			If nLayout == 2 // Papél A4
				nColA4    := -0335
			Elseif nLayout == 3// Carta
				nColA4    := -0530
			Endif
	
			oPrint:Say((nLinIni + 0080)/nTweb, ((nColIni + nColMax)*0.47)/nTweb, "GUIA DE RESUMO DE INTERNAÇÃO", oFont02n,,,, 2) //ANEXO DE SOLICITAÇÃO DE RADIOTERAPIA
			oPrint:Say((nLinIni + 0090)/nTweb, (nColMax - 750)/nTweb, "2- N?Guia no Prestador", oFont01) //2- N?Guia no Prestador
			oPrint:Say((nLinIni + 0090)/nTweb, (nColMax - 480)/nTweb, aDados[nX, 02], oFont03n)
			
			oPrint:Box((nLinIni + 0150 -nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 0220 - nWeb) /nTweb, (nColIni + (nColMax*0.10) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0155) /nTweb, (nColIni + 0030) /nTweb, "1 - Registro ANS", oFont01) //"1 - Registro ANS"
			oPrint:Say((nLinIni + 0185) /nTweb, (nColIni + 0040) /nTweb, Iif(Empty(aDados[nX, 01]),'|___|___|___|___|___|___|',aDados[nX, 01]), oFont05)
			oPrint:Box((nLinIni + 0150 - nWeb) /nTweb, (nColIni + (nColMax*0.10)) /nTweb, (nLinIni + 0220 - nWeb) /nTweb, (nColIni + (nColMax*0.40) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0155) /nTweb, (nColIni + (nColMax*0.10) + 0010) /nTweb, "3 - Número da Guia de Solicitação de Internação", oFont01) //"3 - Número da Guia de Solicitação de Internação"
			oPrint:Say((nLinIni + 0185) /nTweb, (nColIni + (nColMax*0.10) + 0020) /nTweb, Iif(Empty(aDados[nX, 03]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 03]), oFont05)
	
			oPrint:Box((nLinIni + 0230 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 0300 - nWeb) /nTweb, (nColIni + (nColMax*0.14) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0235) /nTweb, (nColIni + 0030) /nTweb, "4 - Data da Autorização", oFont01) //"4 - Data da Autorização"
			oPrint:Say((nLinIni + 0265) /nTweb, (nColIni + 0040) /nTweb, Iif(Empty(aDados[nX, 04]),'|___|___| / |___|___| / |___|___|___|___|',DtoC(aDados[nX, 04])), oFont05)
			oPrint:Box((nLinIni + 0230 - nWeb) /nTweb, (nColIni + (nColMax*0.14)) /nTweb, (nLinIni + 0300 - nWeb) /nTweb, (nColIni + (nColMax*0.42) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0235) /nTweb, (nColIni + (nColMax*0.14) + 0010) /nTweb, "5 - Senha", oFont01) //"5 - Senha"
			oPrint:Say((nLinIni + 0265) /nTweb, (nColIni + (nColMax*0.14) + 0020) /nTweb, Iif(Empty(aDados[nX, 05]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 05]), oFont05)
			oPrint:Box((nLinIni + 0230 - nWeb) /nTweb, (nColIni + (nColMax*0.42)) /nTweb, (nLinIni + 0300 - nWeb) /nTweb, (nColIni + (nColMax*0.56) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0235) /nTweb, (nColIni + (nColMax*0.42) + 0010) /nTweb, "6 - Data de Validade da Senha", oFont01) //"6 - Data de Validade da Senha"
			oPrint:Say((nLinIni + 0265) /nTweb, (nColIni + (nColMax*0.42) + 0020) /nTweb, Iif(Empty(aDados[nX, 06]),'|___|___| / |___|___| / |___|___|___|___|',DtoC(aDados[nX, 06])), oFont05)
			oPrint:Box((nLinIni + 0230 -nWeb) /nTweb, (nColIni + (nColMax*0.56)) /nTweb, (nLinIni + 0300 - nWeb) /nTweb, (nColIni + (nColMax*0.85) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0235) /nTweb, (nColIni + (nColMax*0.56) + 0010) /nTweb, "7- Número da Guia Atribuído pela Operadora", oFont01) //"7- Número da Guia Atribuído pela Operadora"
			oPrint:Say((nLinIni + 0265) /nTweb, (nColIni + (nColMax*0.56) + 0020) /nTweb, Iif(Empty(aDados[nX, 07]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 07]), oFont05)
	
			If !lWeb
				AddTBrush(oPrint, nLinIni + 0307, nColIni + 0010, nLinIni + 0337, nColIni + nColMax)
			EndIf
			
			oPrint:Say((nLinIni + 0310) /nTweb, (nColIni + 0020) /nTweb, "Dados do Beneficiário", oFont01) //"Dados do Beneficiário"
			
			oPrint:Box((nLinIni + 0340 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 0410 - nWeb) /nTweb, (nColIni + (nColMax*0.12) - 00100 /nTweb))
			oPrint:Say((nLinIni + 0345) /nTweb, (nColIni + 0030) /nTweb, "8 - Número da Carteira", oFont01) //"8 - Número da Carteira"
			oPrint:Say((nLinIni + 0375) /nTweb, (nColIni + 0030) /nTweb, Iif(Empty(AllTrim(aDados[nX, 08])),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 08]), oFont01)
			
			oPrint:Box((nLinIni + 0340 - nWeb) /nTweb, (nColIni + (nColMax*0.12)) /nTweb, (nLinIni + 0410 - nWeb) /nTweb, (nColIni + (nColMax*0.26) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0345) /nTweb , (nColIni + (nColMax*0.12) + 0010) /nTweb, "9 - Validade da Carteira", oFont01) //"9 - Validade da Carteira"
			oPrint:Say((nLinIni + 0375) /nTweb, (nColIni + (nColMax*0.12) + 0020) /nTweb, Iif(Empty(aDados[nX, 09]),'|___|___| / |___|___| / |___|___|___|___|',DtoC(aDados[nX, 09])), oFont05)
			
			oPrint:Box((nLinIni + 0340 - nWeb) /nTweb, (nColIni + (nColMax*0.26)) /nTweb, (nLinIni + 0410 - nWeb) /nTweb, (nColIni + (nColMax*0.64) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0345) /nTweb, (nColIni + (nColMax*0.26) + 0010) /nTweb, "10- Nome", oFont01) //"10- Nome"
			oPrint:Say((nLinIni + 0375) /nTweb, (nColIni + (nColMax*0.26) + 0020) /nTweb, aDados[nX, 10], oFont04)
			
			oPrint:Box((nLinIni + 0340 - nWeb) /nTweb, (nColIni + (nColMax*0.64)) /nTweb, (nLinIni + 0410 - nWeb) /nTweb, (nColIni + (nColMax*0.92) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0345) /nTweb, (nColIni + (nColMax*0.64) + 0010) /nTweb, "11 - Cartão Nacional de Saúde", oFont01) //"11 - Cartão Nacional de Saúde"
			oPrint:Say((nLinIni + 0375) /nTweb, (nColIni + (nColMax*0.64) + 0020) /nTweb, Iif(Empty(aDados[nX, 11]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 11]), oFont05)
			
			oPrint:Box((nLinIni + 0340 - nWeb) /nTweb, (nColIni + (nColMax*0.92)) /nTweb, (nLinIni + 0410 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
			oPrint:Say((nLinIni + 0345) /nTweb, (nColIni + (nColMax*0.92) + 0010) /nTweb, "12 - Atendimento a RN", oFont01) //"12 - Atendimento a RN"
			oPrint:Say((nLinIni + 0375) /nTweb, (nColIni + (nColMax*0.92) + 0020) /nTweb, Iif(Empty(aDados[nX, 12]),'|___|',aDados[nX, 12]), oFont05)
			
			If !lWeb
				AddTBrush(oPrint, nLinIni + 0417, nColIni + 0010, nLinIni + 0447, nColIni + nColMax)
			Endif
			
			oPrint:Say((nLinIni + 0420) /nTweb, (nColIni + 0020) /nTweb, "Dados do Contratado Executante", oFont01) //"Dados do Contratado Executante"
			
			oPrint:Box((nLinIni + 0450 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 0520 - nWeb) /nTweb, (nColIni + (nColMax*0.30) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0455) /nTweb, (nColIni + 0030) /nTweb, "13 - Código na Operadora", oFont01) //"13 - Código na Operadora"
			oPrint:Say((nLinIni + 0485) /nTweb, (nColIni + 0040) /nTweb, Iif(Empty(aDados[nX, 13]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 13]), oFont05)
			
			oPrint:Box((nLinIni + 0450 - nWeb) /nTweb, (nColIni + (nColMax*0.30)) /nTweb, (nLinIni + 0520 - nWeb) /nTweb,  (nColIni + (nColMax*0.80) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0455) /nTweb, (nColIni + (nColMax*0.30) + 0010) /nTweb, "14 - Nome do Contratado", oFont01) //"14 - Nome do Contratado"
			oPrint:Say((nLinIni + 0485) /nTweb, (nColIni + (nColMax*0.30) + 0020) /nTweb, aDados[nX, 14], oFont04)
			
			oPrint:Box((nLinIni + 0450 - nWeb) /nTweb, (nColIni + (nColMax*0.80)) /nTweb, (nLinIni + 0520 - nWeb) /nTweb,  (nColIni + nColMax - 0010) /nTweb)
			oPrint:Say((nLinIni + 0455) /nTweb, (nColIni + (nColMax*0.80) + 0010) /nTweb, "15 - Código CNES", oFont01) //"15 - Código CNES"
			oPrint:Say((nLinIni + 0485) /nTweb, (nColIni + (nColMax*0.80) + 0020) /nTweb, Iif(Empty(aDados[nX, 15]),'|___|___|___|___|___|___|___|',aDados[nX, 15]), oFont05)
	
			If !lWeb
				AddTBrush(oPrint, nLinIni + 0527, nColIni + 0010, nLinIni + 0557, nColIni + nColMax)
			EndIf
			
			oPrint:Say((nLinIni + 0530) /nTweb, (nColIni + 0020) /nTweb, "Dados da Internação", oFont01) //"Dados da Internação"
			oPrint:Box((nLinIni + 0560 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 0630 - nWeb) /nTweb, (nColIni + (nColMax*0.10) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + 0030) /nTweb, "16 - Caráter do Atendimento", oFont01) //"16 - Caráter do Atendimento"
			oPrint:Say((nLinIni + 0595) /nTweb, (nColIni + 0140) /nTweb, Iif(Empty(aDados[nX, 16]),'|___|',aDados[nX, 16]), oFont05)
			oPrint:Box((nLinIni + 0560 - nWeb) /nTweb, (nColIni + (nColMax*0.10)) /nTweb, (nLinIni + 0630 - nWeb) /nTweb, (nColIni + (nColMax*0.20) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + (nColMax*0.10) + 0010) /nTweb, "17 - Tipo de Faturamento", oFont01) //"17 - Tipo de Faturamento"
			oPrint:Say((nLinIni + 0595) /nTweb, (nColIni + (nColMax*0.10) + 0020) /nTweb, Iif(Empty(aDados[nX, 17]),'|___|',aDados[nX, 17]), oFont05)
			oPrint:Box((nLinIni + 0560 - nWeb) /nTweb, (nColIni + (nColMax*0.20)) /nTweb, (nLinIni + 0630 - nWeb) /nTweb, (nColIni + (nColMax*0.35) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + (nColMax*0.20) + 0010) /nTweb, "18- Data do Início do Faturamento", oFont01) //"18- Data do Início do Faturamento"
			oPrint:Say((nLinIni + 0595) /nTweb, (nColIni + (nColMax*0.20) + 0020) /nTweb, Iif(Empty(aDados[nX, 18]),'|___|___| / |___|___| / |___|___|___|___|',DtoC(aDados[nX, 18])), oFont05)
			oPrint:Box((nLinIni + 0560 - nWeb) /nTweb, (nColIni + (nColMax*0.35)) /nTweb, (nLinIni + 0630 - nWeb) /nTweb, (nColIni + (nColMax*0.47) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + (nColMax*0.35) + 0010) /nTweb, "19- Hora do Início do Faturamento", oFont01) //"19- Hora do Início do Faturamento"
			oPrint:Say((nLinIni + 0595) /nTweb, (nColIni + (nColMax*0.35) + 0020) /nTweb, IIf(Empty(aDados[nX, 19]), '|___|___|:|___|___|', Transform(aDados[nX, 19], "@R 99:99")), oFont05)
			oPrint:Box((nLinIni + 0560 - nWeb) /nTweb, (nColIni + (nColMax*0.47)) /nTweb, (nLinIni + 0630 - nWeb) /nTweb, (nColIni + (nColMax*0.62) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + (nColMax*0.47) + 0010) /nTweb, "20- Data do Fim do Faturamento", oFont01) //"20- Data do Fim do Faturamento"
			oPrint:Say((nLinIni + 0595) /nTweb, (nColIni + (nColMax*0.47) + 0020) /nTweb, Iif(Empty(aDados[nX, 20]),'|___|___| / |___|___| / |___|___|___|___|',DtoC(aDados[nX, 20])), oFont05)
			oPrint:Box((nLinIni + 0560 - nWeb) /nTweb, (nColIni + (nColMax*0.62)) /nTweb, (nLinIni + 0630 - nWeb) /nTweb, (nColIni + (nColMax*0.74) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + (nColMax*0.62) + 0010) /nTweb, "21- Hora do Fim do Faturamento", oFont01) //"21- Hora do Fim do Faturamento"
			oPrint:Say((nLinIni + 0595) /nTweb, (nColIni + (nColMax*0.62) + 0020) /nTweb, IIf(Empty(aDados[nX, 21]), '|___|___|:|___|___|', Transform(aDados[nX, 21], "@R 99:99")), oFont05)
			oPrint:Box((nLinIni + 0560 - nWeb) /nTweb, (nColIni + (nColMax*0.74)) /nTweb, (nLinIni + 0630 - nWeb) /nTweb, (nColIni + (nColMax*0.82) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + (nColMax*0.74) + 0010) /nTweb, "22- Tipo de Internação", oFont01) //"22- Tipo de Internação"
			oPrint:Say((nLinIni + 0595) /nTweb, (nColIni + (nColMax*0.74) + 0020) /nTweb, Iif(Empty(aDados[nX, 22]),'|___|',aDados[nX, 22]), oFont05)
			oPrint:Box((nLinIni + 0560 - nWeb) /nTweb, (nColIni + (nColMax*0.82)) /nTweb, (nLinIni + 0630 - nWeb) /nTweb, (nColIni + (nColMax*0.91) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0565) /nTweb, (nColIni + (nColMax*0.82) + 0010) /nTweb, "23- Regime de Internação", oFont01) //"23- Regime de Internação"
			oPrint:Say((nLinIni + 0595) /nTweb, (nColIni + (nColMax*0.82) + 0020) /nTweb, Iif(Empty(aDados[nX, 23]),'|___|',aDados[nX, 23]), oFont05)
	
			oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.07) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + 0022) /nTweb, "24-CID 10 Principal", oFont01) //"24 - CID 10 Principal"
			oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + 0040) /nTweb, Iif(Empty(aDados[nX, 24]),'|___|___|___|___|',aDados[nX, 24]), oFont05)
			oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.07)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.14) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + (nColMax*0.07) + 0010) /nTweb, "25 - CID 10 (2)", oFont01) //"25 - CID 10 (2)"
			oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + (nColMax*0.07) + 0020) /nTweb, Iif(Empty(aDados[nX, 25]),'|___|___|___|___|',aDados[nX, 25]), oFont05)
			
			oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.14)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.21) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + (nColMax*0.14) + 0010) /nTweb, "26 - CID 10 (3)", oFont01) //"26 - CID 10 (3)"
			oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + (nColMax*0.14) + 0020) /nTweb, Iif(Empty(aDados[nX, 26]),'|___|___|___|___|',aDados[nX, 26]), oFont05)
			
			oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.21)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.28) - 0010) /nTweb)			
			oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + (nColMax*0.21) + 0010) /nTweb, "27 - CID 10 (4)", oFont01) //"27 - CID 10 (4)"
			oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + (nColMax*0.21) + 0020) /nTweb, Iif(Empty(aDados[nX, 27]),'|___|___|___|___|',aDados[nX, 27]), oFont05)
			
			oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.28)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.39) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0642) /nTweb, (nColIni + (nColMax*0.28) + 001) /nTweb, "28 - Indicação de Acidente", oFont01) //"28 - Indicação de Acidente"
			oPrint:Say((nLinIni + 0657) /nTweb, (nColIni + (nColMax*0.28) + 0010) /nTweb, "(acidente ou doença relacionada)", oFont01) //"acidente ou doença relacionada)"
			oPrint:Say((nLinIni + 0677) /nTweb, (nColIni + (nColMax*0.28) + 0020) /nTweb, Iif(Empty(aDados[nX, 28]),'|___|',aDados[nX, 28]), oFont05)
			
			oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.39)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.52) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + (nColMax*0.39) + 0010) /nTweb, "29-Motivo de Encerramento da Internação", oFont01) //"29 - Motivo de Encerramento da Internação"
			oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + (nColMax*0.39) + 0020) /nTweb, Iif(Empty(aDados[nX, 29]),'|___|___|',aDados[nX, 29]), oFont05)
			oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.52)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.68) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + (nColMax*0.52) + 0010) /nTweb, "30-Número da declaração de nascido vivo", oFont01) //"30-Número da declaração de nascido vivo"
			oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + (nColMax*0.52) + 0020) /nTweb, Iif(Empty(aDados[nX, 30]),'|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 30]), oFont05)
			
			oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.68)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.76) - 0010) /nTweb)
			oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + (nColMax*0.68) + 0010) /nTweb, "31 - CID 10 Óbito", oFont01) //"31 - CID 10 Óbito"
			oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + (nColMax*0.68) + 0020) /nTweb, Iif(Empty(aDados[nX, 31]),'|___|___|___|___|___|',aDados[nX, 31]), oFont05)
			
			oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.76)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + (nColMax*0.92) - 0010 )/nTweb)
			oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + (nColMax*0.76) + 0010) /nTweb, "32 - Numero da declaração de óbito", oFont01) //"32 - Numero da declaração de óbito"
			oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + (nColMax*0.76) + 0020) /nTweb, Iif(Empty(aDados[nX, 32]),'|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 32]), oFont05)
			
			oPrint:Box((nLinIni + 0640 - nWeb) /nTweb, (nColIni + (nColMax*0.92)) /nTweb, (nLinIni + 0710 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
			oPrint:Say((nLinIni + 0645) /nTweb, (nColIni + (nColMax*0.92) + 0010) /nTweb, "33 -Indicador D.O. de RN", oFont01) //"33 -Indicador D.O. de RN"
			oPrint:Say((nLinIni + 0675) /nTweb, (nColIni + (nColMax*0.92) + 0020) /nTweb, Iif(Empty(aDados[nX, 33]),'|___|',aDados[nX, 33]), oFont05)
			
			If !lWeb
				AddTBrush(oPrint, nLinIni + 0717, nColIni + 0010, nLinIni + 0747, nColIni + nColMax)
			EndIf
			
			oPrint:Say((nLinIni + 0720) /nTweb, (nColIni + 0020) /nTweb, "Procedimentos e Exames Realizados", oFont01) //"Procedimentos e Exames Realizados"
			oPrint:Box((nLinIni + 0750 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 1310 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
			oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.02)) /nTweb, "34-Data", oFont01) //"34-Data"
			oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.14)) /nTweb, "35-Hora Inicial", oFont01) //"35-Hora Inicial"
			oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.19)) /nTweb, "36-Hora Final", oFont01) //"36-Hora Final"
			oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.23)) /nTweb, "37-Tabela", oFont01) //"37-Tabela"
			oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.26)) /nTweb, "38-Código do Procedimento", oFont01) //"38-Código do Procedimento"
			oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.38)) /nTweb, "39-Descrição", oFont01) //"39-Descrição"
			oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.63)) /nTweb, "40-Qtde.", oFont01) //"40-Qtde."
			oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.67)) /nTweb, "41-Via", oFont01) //"41-Via"
			oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.70)) /nTweb, "42-Téc", oFont01) //"42-Téc"
			oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.725)) /nTweb, "43-Fator Red/Acresc", oFont01) //"43-Fator Red/Acresc"
			oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.79)) /nTweb, "44-Valor Unitário (R$)", oFont01) //"44-Valor Unitário (R$)"
			oPrint:Say((nLinIni + 0760) /nTweb, (nColIni + (nColMax*0.89)) /nTweb, "45-Valor Total (R$)", oFont01) //"45-Valor Total (R$)"
	
			nOldLinIni := nLinIni
			if nVolta=1
				nP:=1
			Endif
			nT:=nP+9
			For nI := nP To nT
				if nVolta <> 1
					nN:=nI-(15*nVolta-15)
					oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + 0030) /nTweb, AllTrim(Str(nN)) + " - ", oFont01)
				else
					oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + 0030) /nTweb, AllTrim(Str(nI)) + " - ", oFont01)
				Endif
				oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.02)) /nTweb, IIf(Empty(aDados[nX, 34, nI]),'|___|___| / |___|___| / |___|___|___|___|',IIf(Valtype(aDados[nX, 34, nI])== "D", DtoC(aDados[nX, 34, nI]),aDados[nX, 34, nI])), oFont01) //"34-Data"
				oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.13)) /nTweb, IIf(Empty(aDados[nX, 35, nI]), '|___|__|:|___|___|', Transform(aDados[nX, 35, nI], "@R 99:99")), oFont01) //"35-Hora Inicial"
			   	oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.177)) /nTweb, IIf(Empty(aDados[nX, 36, nI]), '|___|__|:|___|___|', Transform(aDados[nX, 36, nI], "@R 99:99")), oFont01) //"36-Hora Final"
				oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.225)) /nTweb, Iif(Empty(aDados[nX, 37, nI]),'|___|___|',aDados[nX, 37, nI]), oFont05) //"37-Tabela"
				oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.26)) /nTweb, Iif(Empty(aDados[nX, 38, nI]),'|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 38, nI]), oFont01) //"38-Código do Procedimento"
				oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.37)) /nTweb, Iif(Empty(aDados[nX, 39, nI]),'   ' + REPLICATE('_',60),aDados[nX, 39, nI]), oFont05) //"39-Descrição"
				oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.63)) /nTweb, IIf(Empty(aDados[nX, 40, nI]), '|___|___|___|', Transform(aDados[nX, 40, nI], "@E 999")), oFont01,,,,1) //"40-Qtde."
				oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.67)) /nTweb, Iif(Empty(aDados[nX, 41, nI]),'|___|',aDados[nX, 41, nI]), oFont01) //"41-Via"
				oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.70)) /nTweb, Iif(Empty(aDados[nX, 42, nI]),'|___|',aDados[nX, 42, nI]), oFont01) //"42-Téc"
				oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.725)) /nTweb, IIf(Empty(aDados[nX, 43, nI]), '|___|___|___|,|___|___|', Transform(aDados[nX, 43, nI], "@E 999.99")), oFont01,,,,1) //"43-Fator Red/Acresc"
				oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.79)) /nTweb, IIf(Empty(aDados[nX, 44, nI]), '|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 44, nI], "@E 99,999,999.99")), oFont01,,,,1) //"44-Valor Unitário (R$)"
				oPrint:Say((nLinIni + 0800) /nTweb, (nColIni + (nColMax*0.89)) /nTweb, IIf(Empty(aDados[nX, 45, nI]), '|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 45, nI], "@E 99,999,999.99")), oFont01,,,,1) //45-Valor Total (R$)
				nLinIni += 50
			Next nI
	
			nLinIni := nOldLinIni
		    nP:=nI
	
			If !lWeb
				AddTBrush(oPrint, nLinIni + 1317, nColIni + 0010, nLinIni + 1347, nColIni + nColMax)
		    EndIf
		    
		    oPrint:Say((nLinIni + 1320) /nTweb, (nColIni + 0020) /nTweb, "Identificação da Equipe", oFont01) //"Identificação da Equipe"
			oPrint:Box((nLinIni + 1350 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 1830 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
			oPrint:Say((nLinIni + 1360) /nTweb, (nColIni + (nColMax*0.01)) /nTweb, "46-Seq.Ref", oFont01) //"46-Seq.Ref"
			oPrint:Say((nLinIni + 1360) /nTweb, (nColIni + (nColMax*0.05)) /nTweb, "47-Grau Part.", oFont01) //"47-Grau Part."
			oPrint:Say((nLinIni + 1360) /nTweb, (nColIni + (nColMax*0.09)) /nTweb, "48-Código na Operadora/CPF", oFont01) //"48-Código na Operadora/CPF"
			oPrint:Say((nLinIni + 1360) /nTweb, (nColIni + (nColMax*0.29)) /nTweb, "49-Nome do Profissional", oFont01) //"49-Nome do Profissional"
			oPrint:Say((nLinIni + 1360) /nTweb, (nColIni + (nColMax*0.55)) /nTweb, "50-Conselho Profissional", oFont01) //"50-Conselho Profissional"
			oPrint:Say((nLinIni + 1360) /nTweb, (nColIni + (nColMax*0.64)) /nTweb, "51-Número no Conselho", oFont01) //"51-Número no Conselho"
			oPrint:Say((nLinIni + 1360) /nTweb, (nColIni + (nColMax*0.86)) /nTweb, "52-UF", oFont01) //"52-UF"
			oPrint:Say((nLinIni + 1360) /nTweb, (nColIni + (nColMax*0.90)) /nTweb, "53-Código CBO", oFont01) //"53-Código CBO"
	
			nOldLinIni := nLinIni
			if nVolta=1
				nP1:=1
			Endif
			nT1:=nP1+7
			For nI := nP1 To nT1
				oPrint:Say((nLinIni + 1400) /nTweb, (nColIni + (nColMax*0.01)) /nTweb, Iif(Empty(aDados[nX, 46, nI]),'|___|___|',aDados[nX, 46, nI]), oFont01) //"46-Seq.Ref"
				oPrint:Say((nLinIni + 1400) /nTweb, (nColIni + (nColMax*0.05)) /nTweb, Iif(Empty(aDados[nX, 47, nI]),'|___|___|',aDados[nX, 47, nI]), oFont01) //"47-Grau Part."
				oPrint:Say((nLinIni + 1400) /nTweb, (nColIni + (nColMax*0.09)) /nTweb, Iif(Empty(aDados[nX, 48, nI]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 48, nI]), oFont01) //"48-Código na Operadora/CPF"
				oPrint:Say((nLinIni + 1400) /nTweb, (nColIni + (nColMax*0.29)) /nTweb, Iif(Empty(aDados[nX, 49, nI]),REPLICATE('_',75),aDados[nX, 49, nI]), oFont01) //"49-Nome do Profissional"
				oPrint:Say((nLinIni + 1400) /nTweb, (nColIni + (nColMax*0.56)) /nTweb, Iif(Empty(aDados[nX, 50, nI]),'|___|___|',aDados[nX, 50, nI]), oFont01) //"50-Conselho Profissional"
				oPrint:Say((nLinIni + 1400) /nTweb, (nColIni + (nColMax*0.64)) /nTweb, Iif(Empty(aDados[nX, 51, nI]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 51, nI]), oFont01) //"51-Número no Conselho"
				oPrint:Say((nLinIni + 1400) /nTweb, (nColIni + (nColMax*0.863)) /nTweb, Iif(Empty(aDados[nX, 52, nI]),'|___|___|',aDados[nX, 52, nI]), oFont01) //"52-UF"
				oPrint:Say((nLinIni + 1400) /nTweb, (nColIni + (nColMax*0.90)) /nTweb, Iif(Empty(aDados[nX, 53, nI]),'|___|___|___|___|___|___|',aDados[nX, 53, nI]), oFont01) //"53-Código CBO"
				nLinIni += 50
			Next nI
	
			nP1:=nI
			nLinIni := nOldLinIni
	
			oPrint:Box((nLinIni + 1840 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 1930 - nWeb) /nTweb, (nColIni + (nColMax/8) - 0010) /nTweb)
			oPrint:Say((nLinIni + 1845) /nTweb, (nColIni + 0030) /nTweb, "54 - Total de Procedimentos (R$)", oFont01) //"54 - Total de Procedimentos (R$)"
			oPrint:Say((nLinIni + 1885)/nTweb, (nColIni + 0030) /nTweb, IIf(Empty(aDados[nX, 54]), '|___|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 54], "@E 99,999,999.99")), oFont01,,,,1)
			oPrint:Box((nLinIni + 1840 - nWeb) /nTweb, (nColIni + (nColMax/8)) /nTweb , (nLinIni + 1930 - nWeb) /nTweb, (nColIni + (nColMax/8*2) - 0010) /nTweb)
			oPrint:Say((nLinIni + 1845) /nTweb, (nColIni + (nColMax/8) + 0010) /nTweb, "55 - Total de Diárias (R$)", oFont01) //"55 - Total de Diárias (R$)"
			oPrint:Say((nLinIni + 1885) /nTweb, (nColIni + (nColMax/8) + 0010) /nTweb, IIf(Empty(aDados[nX, 55]), '|___|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 55], "@E 99,999,999.99")), oFont01,,,,1)
			oPrint:Box((nLinIni + 1840 - nWeb)  /nTweb, (nColIni + (nColMax/8*2))/nTweb, (nLinIni + 1930 - nWeb)  /nTweb, (nColIni + (nColMax/8*3) - 0010) /nTweb)
			oPrint:Say((nLinIni + 1845) /nTweb, (nColIni + (nColMax/8*2) + 0010) /nTweb, "56 - Total de Taxase Aluguéis (R$)", oFont01) //"56 - Total de Taxase Aluguéis (R$)"
			oPrint:Say((nLinIni + 1885) /nTweb, (nColIni + (nColMax/8*2) + 0010) /nTweb, IIf(Empty(aDados[nX, 56]), '|___|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 56], "@E 99,999,999.99")), oFont01,,,,1)
			oPrint:Box((nLinIni + 1840 - nWeb) /nTweb, (nColIni + (nColMax/8*3)) /nTweb , (nLinIni + 1930 - nWeb) /nTweb, (nColIni + (nColMax/8*4) - 0010) /nTweb)
			oPrint:Say((nLinIni + 1845) /nTweb, (nColIni + (nColMax/8*3) + 0010) /nTweb, "57 - Total de Materiais (R$)", oFont01) //"57 - Total de Materiais (R$)"
			oPrint:Say((nLinIni + 1885) /nTweb, (nColIni + (nColMax/8*3) + 0010) /nTweb, IIf(Empty(aDados[nX, 57]), '|___|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 57], "@E 99,999,999.99")), oFont01,,,,1)
			oPrint:Box((nLinIni + 1840 - nWeb)  /nTweb, (nColIni + (nColMax/8*4))/nTweb, (nLinIni + 1930 - nWeb) /nTweb, (nColIni + (nColMax/8*5) - 0010) /nTweb)
			oPrint:Say((nLinIni + 1845) /nTweb, (nColIni + (nColMax/8*4) + 0010) /nTweb, "58 - Total de OPME (R$)", oFont01) //"58- Total de OPME (R$)"
			oPrint:Say((nLinIni + 1885) /nTweb, (nColIni + (nColMax/8*4) + 0010) /nTweb, IIf(Empty(aDados[nX, 58]), '|___|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 58], "@E 99,999,999.99")), oFont01,,,,1)
			oPrint:Box((nLinIni + 1840 - nWeb) /nTweb, (nColIni + (nColMax/8*5)) /nTweb, (nLinIni + 1930 - nWeb) /nTweb, (nColIni + (nColMax/8*6) - 0010) /nTweb)
			oPrint:Say((nLinIni + 1845) /nTweb, (nColIni + (nColMax/8*5) + 0010) /nTweb, "59 - Total de Medicamentos (R$)", oFont01) //"59 - Total de Medicamentos (R$)"
			oPrint:Say((nLinIni + 1885) /nTweb, (nColIni + (nColMax/8*5) + 0010) /nTweb, IIf(Empty(aDados[nX, 59]), '|___|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 59], "@E 99,999,999.99")), oFont01,,,,1)
			oPrint:Box((nLinIni + 1840 - nWeb)  /nTweb, (nColIni + (nColMax/8*6))/nTweb, (nLinIni + 1930 - nWeb) /nTweb, (nColIni + (nColMax/8*7) - 0010) /nTweb)
			oPrint:Say((nLinIni + 1845) /nTweb, (nColIni + (nColMax/8*6) + 0010) /nTweb, "60 - Total de Gases Medicinais (R$)", oFont01) //"60 - Total de Gases Medicinais (R$)"
			oPrint:Say((nLinIni + 1885) /nTweb, (nColIni + (nColMax/8*6) + 0010) /nTweb, IIf(Empty(aDados[nX, 60]), '|___|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 60], "@E 99,999,999.99")), oFont01,,,,1)
			oPrint:Box((nLinIni + 1840 - nWeb) /nTweb, (nColIni + (nColMax/8*7)) /nTweb, (nLinIni + 1930 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
			oPrint:Say((nLinIni + 1845) /nTweb, (nColIni + (nColMax/8*7) + 0010) /nTweb, "61 - Total Geral (R$)", oFont01) //"61 - Total Geral (R$)"
			oPrint:Say((nLinIni + 1885) /nTweb, (nColIni + (nColMax/8*7) + 0010) /nTweb, IIf(Empty(AllTrim(aDados[nX, 61])), '|___|___|___|___|___|___|___|,|___|___|', Transform(aDados[nX, 61], "@E 99,999,999.99")), oFont01,,,,1)
	
			oPrint:Box((nLinIni + 1940 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 2030 - nWeb) /nTweb, (nColIni + (nColMax*0.15) - 0010) /nTweb)
			oPrint:Say((nLinIni + 1945) /nTweb, (nColIni + 0030) /nTweb, "62- Data da assinatura do contratado", oFont01) //"62- Data da assinatura do contratado"
			oPrint:Say((nLinIni + 1975) /nTweb, (nColIni + 0040) /nTweb, Iif(Empty(aDados[nX, 62]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 62])), oFont01)
			oPrint:Box((nLinIni + 1940 - nWeb) /nTweb, (nColIni + (nColMax*0.15)) /nTweb, (nLinIni + 2030 - nWeb) /nTweb, (nColIni + (nColMax*0.525) - 0010) /nTweb)
			oPrint:Say((nLinIni + 1945) /nTweb, (nColIni + (nColMax*0.15) + 0010) /nTweb, "63- Assinatura do contratado", oFont01) //"63- Assinatura do contratado"
			oPrint:Box((nLinIni + 1940 - nWeb) /nTweb, (nColIni + (nColMax*0.525)) /nTweb, (nLinIni + 2030 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
			oPrint:Say((nLinIni + 1945) /nTweb, (nColIni + (nColMax*0.525) + 0010) /nTweb, "64-Assinatura do(s) Auditor(es) da Operadora", oFont01) //"64-Assinatura do(s) Auditor(es) da Operadora"
	
			//AddTBrush(oPrint, nLinIni + 2040, nColIni + 0020, nLinIni + 2270, nColIni + nColMax - 0010)
			oPrint:Box((nLinIni + 2040 - nWeb) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + 2270 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
			oPrint:Say((nLinIni + 2050) /nTweb, (nColIni + 0030) /nTweb, "65 ?Observações / Justificativa", oFont01) //"65 ?Observações / Justificativa"
			For nI := 1 To MlCount(aDados[nX, 63], 130)
				cObs := MemoLine(aDados[nX, 63], 130, nI)
				oPrint:Say((nLinIni + 2080 + nLin) /nTweb, (nColIni + 0040) /nTweb, cObs, oFont04)
				nLin += 50
			Next nI
	
			oPrint:EndPage()	// Finaliza a pagina
	
			//  Verso da Guia
			oPrint:StartPage()	// Inicia uma nova pagina
	
			nLinIni := 080
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Box Principal                                                 ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:Box((nLinIni + 0010) /nTweb, (nColIni + 0020) /nTweb, (nLinIni + nLinMax) /nTweb, (nColIni + nColMax) /nTweb)
	
			If !lWeb
				AddTBrush(oPrint, nLinIni + 0017, nColIni + 0030, nLinIni + 0047, nColIni + nColMax)
			EndIf
			
			nLinIni += 010 
			
			oPrint:Say((nLinIni + 0020) /nTweb, (nColIni + 0030) /nTweb, "Procedimentos e Exames Realizados (Continuação)", oFont01) //"Procedimentos e Exames Realizados"
			oPrint:Box((nLinIni + 0050 - nWeb) /nTweb, (nColIni + 0030) /nTweb, (nLinIni + (nLinMax*0.3) - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
			oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.02)) /nTweb, "34-Data", oFont01) //"34-Data"
			oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.14)) /nTweb, "35-Hora Inicial", oFont01) //"35-Hora Inicial"
			oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.19)) /nTweb, "36-Hora Final", oFont01) //"36-Hora Final"
			oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.23)) /nTweb, "37-Tabela", oFont01) //"37-Tabela"
			oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.26)) /nTweb, "38-Código do Procedimento", oFont01) //"38-Código do Procedimento"
			oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.38)) /nTweb, "39-Descrição", oFont01) //"39-Descrição"
			oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.63)) /nTweb, "40-Qtde.", oFont01) //"40-Qtde."
			oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.67)) /nTweb, "41-Via", oFont01) //"41-Via"
			oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.70)) /nTweb, "42-Téc", oFont01) //"42-Téc"
			oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.725)) /nTweb, "43-Fator Red/Acresc", oFont01) //"43-Fator Red/Acresc"
			oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.79)) /nTweb, "44-Valor Unitário (R$)", oFont01) //"44-Valor Unitário (R$)"
			oPrint:Say((nLinIni + 0060) /nTweb, (nColIni + (nColMax*0.89)) /nTweb, "45-Valor Total (R$)", oFont01) //"45-Valor Total (R$)"
	
			nOldLinIni := nLinIni
	
			if nVolta =1
				nP:=11
			Endif
			nT2:=nP+11
	
			For nI := nP To nT2
				if nVolta<>1
					nN:=nI-((15*nVolta)-15)
					oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + 0030) /nTweb, AllTrim(Str(nN)) + " - ", oFont01)
				Else
					oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + 0030) /nTweb, AllTrim(Str(nI)) + " - ", oFont01)
				Endif
				oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.02)) /nTweb, IIf(Empty(aDados[nX, 34, nI]),'|___|___|/|___|___|/|___|___|___|___|',aDados[nX, 34, nI]), oFont01) //"34-Data"
				oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.13)) /nTweb, IIf(Empty(aDados[nX, 35, nI]), "|___|___|:|___|___|", Transform(aDados[nX, 35, nI], "@R 99:99")), oFont01) //"35-Hora Inicial"
			   	oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.177)) /nTweb, IIf(Empty(aDados[nX, 36, nI]), "|___|___|:|___|___|", Transform(aDados[nX, 36, nI], "@R 99:99")), oFont01) //"36-Hora Final"
				oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.225)) /nTweb, Iif(Empty(aDados[nX, 37, nI]),'|___|___|',aDados[nX, 37, nI]), oFont01) //"37-Tabela"
				oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.26)) /nTweb, Iif(Empty(aDados[nX, 38, nI]),'|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 38, nI]), oFont01) //"38-Código do Procedimento"
				oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.38)) /nTweb, Iif(Empty(aDados[nX, 39, nI]),REPLICATE('_',60),aDados[nX, 39, nI]), oFont05) //"39-Descrição"
				oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.63)) /nTweb, IIf(Empty(aDados[nX, 40, nI]), "|___|___|___|", Transform(aDados[nX, 40, nI], "@E 999")), oFont01,,,,1) //"40-Qtde."
				oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.67)) /nTweb, Iif(Empty(aDados[nX, 41, nI]),'|___|',aDados[nX, 41, nI]), oFont01) //"41-Via"
				oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.70)) /nTweb, Iif(Empty(aDados[nX, 42, nI]),'|___|',aDados[nX, 42, nI]), oFont01) //"42-Téc"
				oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.725)) /nTweb, IIf(Empty(aDados[nX, 43, nI]), "|___|___|___|,|___|___|", Transform(aDados[nX, 43, nI], "@E 999.99")), oFont01,,,,1) //"43-Fator Red/Acresc"
				oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.79)) /nTweb, IIf(Empty(aDados[nX, 44, nI]), "|___|___|___|___|___|___|,|___|___|", Transform(aDados[nX, 44, nI], "@E 99,999,999.99")), oFont01,,,,1) //"44-Valor Unitário (R$)"
				oPrint:Say((nLinIni + 0100) /nTweb, (nColIni + (nColMax*0.89)) /nTweb, IIf(Empty(aDados[nX, 45, nI]), "|___|___|___|___|___|___|,|___|___|", Transform(aDados[nX, 45, nI], "@E 99,999,999.99")), oFont01,,,,1) //45-Valor Total (R$)
				nLinIni += 50
			Next nI
	
			nP:=nI
	
			if nVolta=1
				nP3:=len(aDados[nX,34])
			Endif
	
			if nP3 >nI-1
				lImpnovo:=.T.
			Endif
	
			nLinIni := nOldLinIni
			
			If !lWeb
				AddTBrush(oPrint, nLinIni + (nLinMax*0.3) + 0017, nColIni + 0030, nLinIni + (nLinMax*0.3) + 0047, nColIni + nColMax)
			EndIf
			
			oPrint:Say((nLinIni + (nLinMax*0.3) + 0020) /nTweb, (nColIni + 0030) /nTweb, "Identificação da Equipe (Continuação)", oFont01) //"Identificação da Equipe (Continuação)"
			oPrint:Box((nLinIni + (nLinMax*0.3) + 0050 - nWeb) /nTweb , (nColIni + 0030) /nTweb, (nLinIni + (nLinMax*0.73) + 0050 - nWeb) /nTweb, (nColIni + nColMax - 0010) /nTweb)
			oPrint:Say((nLinIni + (nLinMax*0.3) + 0060) /nTweb, (nColIni + (nColMax*0.01)) /nTweb, "46-Seq.Ref", oFont01) //"46-Seq.Ref"
			oPrint:Say((nLinIni + (nLinMax*0.3) + 0060) /nTweb, (nColIni + (nColMax*0.05)) /nTweb, "47-Grau Part.", oFont01) //"47-Grau Part."
			oPrint:Say((nLinIni + (nLinMax*0.3) + 0060) /nTweb, (nColIni + (nColMax*0.09)) /nTweb, "48-Código na Operadora/CPF", oFont01) //"48-Código na Operadora/CPF"
			oPrint:Say((nLinIni + (nLinMax*0.3) + 0060) /nTweb, (nColIni + (nColMax*0.29)) /nTweb, "49-Nome do Profissional", oFont01) //"49-Nome do Profissional"
			oPrint:Say((nLinIni + (nLinMax*0.3) + 0060) /nTweb, (nColIni + (nColMax*0.55)) /nTweb, "50-Conselho Profissional", oFont01) //"50-Conselho Profissional"
			oPrint:Say((nLinIni + (nLinMax*0.3) + 0060) /nTweb, (nColIni + (nColMax*0.64)) /nTweb, "51-Número no Conselho", oFont01) //"51-Número no Conselho"
			oPrint:Say((nLinIni + (nLinMax*0.3) + 0060) /nTweb, (nColIni + (nColMax*0.86)) /nTweb, "52-UF", oFont01) //"52-UF"
			oPrint:Say((nLinIni + (nLinMax*0.3) + 0060) /nTweb, (nColIni + (nColMax*0.90)) /nTweb, "53-Código CBO", oFont01) //"53-Código CBO"
	
			nOldLinIni := nLinIni
			if nVolta =1
				nP1:=9
			Endif
			nT3:=nP1+17
	
			For nI := nP1 To nT3
				oPrint:Say((nLinIni + (nLinMax*0.3) + 0100) /nTweb, (nColIni + (nColMax*0.01)) /nTweb, Iif(Empty(aDados[nX, 46, nI]),'|___|___|',aDados[nX, 46, nI]), oFont01) //"46-Seq.Ref"
				oPrint:Say((nLinIni + (nLinMax*0.3) + 0100) /nTweb, (nColIni + (nColMax*0.05)) /nTweb, Iif(Empty(aDados[nX, 47, nI]),'|___|___|',aDados[nX, 47, nI]), oFont01) //"47-Grau Part."
				oPrint:Say((nLinIni + (nLinMax*0.3) + 0100) /nTweb, (nColIni + (nColMax*0.09)) /nTweb, Iif(Empty(aDados[nX, 48, nI]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 48, nI]), oFont01) //"48-Código na Operadora/CPF"
				oPrint:Say((nLinIni + (nLinMax*0.3) + 0100) /nTweb, (nColIni + (nColMax*0.29)) /nTweb, Iif(Empty(aDados[nX, 49, nI]),REPLICATE('_',75),aDados[nX, 49, nI]), oFont01) //"49-Nome do Profissional"
				oPrint:Say((nLinIni + (nLinMax*0.3) + 0100) /nTweb, (nColIni + (nColMax*0.56)) /nTweb, Iif(Empty(aDados[nX, 50, nI]),'|___|___|',aDados[nX, 50, nI]), oFont01) //"50-Conselho Profissional"
				oPrint:Say((nLinIni + (nLinMax*0.3) + 0100) /nTweb, (nColIni + (nColMax*0.64)) /nTweb, Iif(Empty(aDados[nX, 51, nI]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 51, nI]), oFont01) //"51-Número no Conselho"
				oPrint:Say((nLinIni + (nLinMax*0.3) + 0100) /nTweb, (nColIni + (nColMax*0.863)) /nTweb, Iif(Empty(aDados[nX, 52, nI]),'|___|___|',aDados[nX, 52, nI]), oFont01) //"52-UF"
				oPrint:Say((nLinIni + (nLinMax*0.3) + 0100) /nTweb, (nColIni + (nColMax*0.90)) /nTweb, Iif(Empty(aDados[nX, 53, nI]),'|___|___|___|___|___|___|',aDados[nX, 53, nI]), oFont01) //"53-Código CBO"
				nLinIni += 50
			Next nI
			
			nP1:=nI
	
			if nVolta=1
				nP2:=len(aDados[nX,46])
			Endif
	
			if nP2 >nI-1
				lImpnovo:=.T.
			Endif
	
			nLinIni := nOldLinIni
	
			oPrint:EndPage()	// Finaliza a pagina

		Next nX

	Enddo
END SEQUENCE
//ErrorBlock( bError )

If !Empty(cErro)
	cArq := "erro_imp_relat_" + DtoS(Date()) + StrTran(Time(),":") + ".txt"
	MsgAlert("Erro ao gerar relatório. Visualize o log em /LOGPLS/" + cArq )
	cErro := 	"Erro ao carregar dados do relatório." + CRLF + ;
				"Verifique a cfg. de impressão da guia no cadastro de " + CRLF + ;
				"Tipos de Guias." + CRLF + CRLF + ;
				cErro
	PLSLogFil(cErro,cArq)
EndIf

If lWeb .OR. lGerTXT
	oPrint:Print()
Else
	oPrint:Preview()
Endif

Return cFileName 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ?PLSODTCB  ?Autor ?Luciano Aparecido     ?Data ?10.03.07 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ?Estrutura Relatório TISS (Guia Odontológica - Cobrança)     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?SigaPLS                                                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros?aDados - Array com as informações do relat´rio              ³±?
±±?         ?nLayout - Define o formato de papél para impressao:         ³±?
±±?         ?          1 - Formato Ofício II (216x330mm)                 ³±?
±±?         ?          2 - Formato A4 (210x297mm)                        ³±?
±±?         ? 		 3 - Formato Carta (216x279mm)     			       ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PLSODTCB(aDados, nLayout, cLogoGH, lGerTXT, lWeb, cPathRelW) //Guia Odontológica - Cobrança

	Local nLinMax
	Local nColMax
	Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
	Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
	Local nColA4    :=  0
	Local cFileLogo
  	Local nLin
	Local nN, nX
	Local nI, nJ
	Local cObs
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local oPrint    := Nil
	Local nT        := 0
	Local nP		:= 0
	Local nP1		:= 0
	Local nAte 		:= 20
	Local lImpnovo 	:= .T.
	Local nVolta	:= 0
	Local cMsg 		:= ""
	LOCAL cFileName	:= ""
	LOCAL cRel      := "GUICONS"
	LOCAL cPathSrvJ := GETMV("MV_RELT")
	LOCAL nAL		:= 0.25
	LOCAL nAC		:= 0.24
	LOCAL cTissVer:= "2.02.03"
	LOCAL cImpDatRea:= GetNewPar("MV_PLSIMDR","S") //Habilita/Desabilita a impressão do campo (Data Realização) na Guia Odontológica (S ou N).

	If FindFunction("PLSTISSVER")
		cTissVer	:= PLSTISSVER()
	EndIf
	cTissVer:= "3.00.01"

	DEFAULT lGerTXT 	:= .F.
	DEFAULT nLayout 	:= 2
	DEFAULT cLogoGH 	:= ""
	DEFAULT lWeb		:= .F.
	DEFAULT cPathRelW 	:= ""
	DEFAULT aDados  := { { ;
						"123456",;                      //1 - Registro ANS
						"12345678901234567892",;
						CtoD("05/03/07"),;
						CtoD("05/03/07"),;
						"12345678901234567892",;        //5 - Senha
						CtoD("01/12/07"),;
						"12345678901234567892",;
						"12345678901234567892",;
						Replicate("M",40),;
						Replicate("M",40),;             //10 - Empresa
						CtoD("01/12/07"),;
						"123456789012345",;
						Replicate("M",70),;
						"1199999999",;
						Replicate("M",40),;             //15 - Nome do títular do plano
						Replicate("M",70),;
						"123456789012345",;
						"SP",;
						"12345",;
						"14.141.114/00001-35",;			//20 - Código na Operadora / CNPJ / CPF
						Replicate("M",70),;
						"123456789012345",;
						"SP",;
						"1234567",;
						Replicate("M",70),;             //25 - Profissional Executante
						"123456789012345",;
						"SP",;
						"12345",;
						{"AA","BB","CC","DD","EE","FF","GG","HH","II","JJ","KK","LL","MM","NN","OO","PP"},;
					    {"1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890","1234567890"},;
						{Replicate("M",40),Replicate("M",40),Replicate("M",40),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70),Replicate("M",70)},;
						{"1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234","1234"},;
						{"ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE","ABCDE"},;
						{10,20,30,40,50,60,70,80,90,15,25,35,45,55,65,75},;
						{99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99},;
						{99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99},;
						{99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99,99999.99},;
						{"A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A"},;
						{CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07"),CtoD("01/03/07")},;
						{"","","","","","","","","","","","","","","",""},;             //Posição 40
						CtoD("01/04/07"),;
						"1",;
						"1",;
				   		999999.99,;
						999999.99,;
						999999.99,;
						Replicate("M", 240),;
					 	CtoD("30/12/07"),;
					 	Replicate("M",30),;
						CtoD("30/12/07"),;
						Replicate("M",30),;
						CtoD("30/12/07"),;
						Replicate("M",30),;
						CtoD("30/12/07"),;
						Replicate("M",30)} }



	If nLayout  == 1 // Ofício 2
		nLinMax := 2435
		nColMax := 3705
	Elseif nLayout == 2   // Papél A4
	   	nLinMax	:=	2290
		nColMax	:=	3350 //3365
	Else //Carta
		nLinMax	:=	2435
		nColMax	:=	3175
	Endif

	oFont01		:= TFont():New("Arial",  4,  4, , .F., , , , .T., .F.) // Normal
	if nLayout == 1 // Oficio 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
		oFont05		:= TFont():New("Arial", 06, 06, , .F., , , , .T., .F.) // Normal
		oFont06		:= TFont():New("Arial", 05, 05, , .F., , , , .T., .F.) // Normal
	Else  // Papél A4 ou Carta
	  	oFont02n := TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n := TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04	 := TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
		oFont05		:= TFont():New("Arial", 06, 06, , .F., , , , .T., .F.) // Normal
		oFont06		:= TFont():New("Arial", 05, 05, , .F., , , , .T., .F.) // Normal
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Nao permite acionar a impressao quando for na web.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If lWeb
		cPathSrvJ := cPathRelW
		cFileName := cRel+CriaTrab(NIL,.F.)+".pdf"
	Else
		cFileName := cRel+CriaTrab(NIL,.F.)
	EndIf

	//						New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF] )
	If !lWeb
	oPrint := FWMSPrinter():New ( cFileName			,			,	.F.				,cPathSrvJ	 	,	.T.				,			 ,				,			  ,			  ,	.F.			, 		, 				)
	Else
		oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ	 ,.T.,	,@oPrint,			  ,			  ,	.F.			,.f.)
		If lSrvUnix
			AjusPath(@oPrint)
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Tratamento para impressao via job
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//oPrint:lInJob  := lWeb
	oPrint:lServer := lWeb
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Caminho do arquivo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:cPathPDF := cPathSrvJ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Modo paisagem
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:SetLandscape()

	If nLayout ==2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Papél A4
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		oPrint:SetPaperSize(9)
	ElseIf nLayout ==3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Papél Carta
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		oPrint:SetPaperSize(1)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Papel Oficio2 216 x 330mm / 8 1/2 x 13in
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		oPrint:SetPaperSize(14)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Device
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If lWeb
		oPrint:setDevice(IMP_PDF)
		oPrint:lPDFAsPNG := .T.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Verifica se existe alguma impressora configurada para Impressao Grafica
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If  !lWeb
		oPrint:Setup()
		If (oPrint:nModalResult == 2) // Clicou no botao cancelar
			lRet := .F.
			lMail := .F.
			Return
		Else
			lImpnovo:=(oPrint:nModalResult == 1)
		Endif
	EndIf

	 While lImpnovo
	 	lImpnovo:=.F.
	 	nVolta 	+= 1
	 	nAte	+= nP
		For nX := 1 To Len(aDados)

			If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
				Loop
			EndIf

	   		If oPrint:Cprinter == "PDF" .OR. lWeb
				nLinIni := 130
				nColMax -= 15
			Else
				nLinIni := 080
			Endif
			nColIni := 080
			nColA4  := 000

			oPrint:StartPage()		// Inicia uma nova pagina
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Box Principal                                                 ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:Box((nLinIni + 0000)*nAL, (nColIni + 0000)*nAC, (nLinIni + nLinMax)*nAL, (nColIni + nColMax)*nAC)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega e Imprime Logotipo da Empresa                         ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fLogoEmp(@cFileLogo,, cLogoGH)

			If File(cFilelogo)
				oPrint:SayBitmap((nLinIni + 0050)*nAL, (nColIni + 0020)*nAC, cFileLogo, (400)*nAL, (090)*nAC) 		// Tem que estar abaixo do RootPath
			EndIf

			If nLayout == 2 // Papél A4
			  	nColA4    := -0335
			Elseif nLayout == 3// Carta
				nColA4    := -0530
			Endif

			For nI := 30 To 42
				If Len(aDados[nX, nI]) < nAte
					For nJ := Len(aDados[nX, nI]) + 1 To nAte
						If AllTrim(Str(nI)) $ "35,36,37,38"
							aAdd(aDados[nX, nI], 0)
						ElseiF AllTrim(Str(nI)) $ "41"
							aAdd(aDados[nX, nI], StoD(""))
						Else
							aAdd(aDados[nX, nI],"")
						EndIf
					Next nJ
				EndIf
			Next nI

			oPrint:Say((nLinIni + 0090)*nAL, (nColIni + 1482 + IIF(nLayout ==2 .Or. nLayout ==3,nColA4+160,0))*nAC, "GUIA TRATAMENTO ODONTOLÓGICO", oFont02n,,,, 2) //"GUIA TRATAMENTO ODONTOLÓGICO"
			oPrint:Say((nLinIni + 0090)*nAL, (nColIni + 2900 + nColA4)*nAC, "2-"+"Nºda guia no prestador", oFont01) //"N?da guia no prestador"
			oPrint:Say((nLinIni + 0090)*nAL, (nColIni + 3096 + nColA4)*nAC, aDados[nX, 02], oFont03n)

			nLinIni+= 20
			oPrint:Box((nLinIni + 0155)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0249)*nAL, (nColIni + 0215)*nAC)
			oPrint:Say((nLinIni + 0180)*nAL, (nColIni + 0020)*nAC, "1 - "+"Registro ANS", oFont01) //"Registro ANS"
			oPrint:Say((nLinIni + 0220)*nAL, (nColIni + 0030)*nAC, Iif(Empty(aDados[nX, 01]),'|___|___|___|___|___|___|',aDados[nX, 01]), Iif(Empty(aDados[nX, 01]),oFont06,oFont05))

			oPrint:Box((nLinIni + 0155)*nAL, (nColIni + 0220)*nAC, (nLinIni + 0249)*nAL, (nColIni + 1000)*nAC)
			oPrint:Say((nLinIni + 0180)*nAL, (nColIni + 0230)*nAC, "3 - "+"Número da Guia Principal", oFont01) //"Número da Guia Principal"
			oPrint:Say((nLinIni + 0220)*nAL, (nColIni + 0240)*nAC, Iif(Empty(aDados[nX, 03]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 03]), Iif(Empty(aDados[nX, 03]),oFont06,oFont05))

			oPrint:Box((nLinIni + 0155)*nAL, (nColIni + 1005)*nAC, (nLinIni + 0249)*nAL, (nColIni + 1355)*nAC)
			oPrint:Say((nLinIni + 0180)*nAL, (nColIni + 1015)*nAC, "4 - "+"Data da Autorização", oFont01) //"Data da Autorização"
			oPrint:Say((nLinIni + 0220)*nAL, (nColIni + 1025)*nAC, Iif(Empty(aDados[nX, 04]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 04])), Iif(Empty(aDados[nX, 04]),oFont06,oFont05))

			oPrint:Box((nLinIni + 0155)*nAL, (nColIni + 1360)*nAC, (nLinIni + 0249)*nAL, (nColIni + 2115)*nAC)
			oPrint:Say((nLinIni + 0180)*nAL, (nColIni + 1365)*nAC, "5 - "+"Senha", oFont01) //"Senha"
			oPrint:Say((nLinIni + 0220)*nAL, (nColIni + 1370)*nAC, Iif(Empty(aDados[nX, 05]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 05]), Iif(Empty(aDados[nX, 05]),oFont06,oFont05))

			oPrint:Box((nLinIni + 0155)*nAL, (nColIni + 2120)*nAC, (nLinIni + 0249)*nAL, (nColIni + 2470)*nAC)
			oPrint:Say((nLinIni + 0180)*nAL, (nColIni + 2130)*nAC, "6 - "+"Data Validade da Senha", oFont01) //"Data Validade da Senha"
			oPrint:Say((nLinIni + 0220)*nAL, (nColIni + 2140)*nAC, Iif(Empty(aDados[nX, 06]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 06])), Iif(Empty(aDados[nX, 06]),oFont06,oFont05))

			oPrint:Box((nLinIni + 0155)*nAL, (nColIni + 2475)*nAC, (nLinIni + 0249)*nAL, (nColIni + 3290)*nAC)
			oPrint:Say((nLinIni + 0180)*nAL, (nColIni + 2480)*nAC, "7 - "+"Número da Guia Atribuído pela Operadora", oFont01) //"Número da Guia Atribuído pela Operadora"
			oPrint:Say((nLinIni + 0220)*nAL, (nColIni + 2485)*nAC, Iif(Empty(aDados[nX, 07]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 07]), Iif(Empty(aDados[nX, 07]),oFont06,oFont05))

		    nLinIni += 10
			oPrint:Say((nLinIni + 0274)*nAL, (nColIni + 0010)*nAC, "Dados do Beneficiário", oFont01) //"Dados do Beneficiário"
			oPrint:Box((nLinIni + 0284)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0378)*nAL, (nColIni + 0860)*nAC)
			oPrint:Say((nLinIni + 0309)*nAL, (nColIni + 0020)*nAC, "8 - "+"Número da Carteira", oFont01) //"Número da Carteira"
			oPrint:Say((nLinIni + 0349)*nAL, (nColIni + 0030)*nAC, Iif(Empty(aDados[nX, 08]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 08]), Iif(Empty(aDados[nX, 08]),oFont06,oFont05))

			oPrint:Box((nLinIni + 0284)*nAL, (nColIni + 0865)*nAC, (nLinIni + 0378)*nAL, (nColIni + 1895 + nColA4)*nAC)
			oPrint:Say((nLinIni + 0309)*nAL, (nColIni + 0870)*nAC, "9 - "+"Plano", oFont01) //"Plano"
			oPrint:Say((nLinIni + 0349)*nAL, (nColIni + 0875)*nAC, aDados[nX, 09], Iif(Empty(aDados[nX, 09]),oFont06,oFont05))

			oPrint:Box((nLinIni + 0284)*nAL, (nColIni + 1900 + nColA4)*nAC, (nLinIni + 0378)*nAL, (nColIni + 2600 + nColA4)*nAC)
			oPrint:Say((nLinIni + 0309)*nAL, (nColIni + 1905 + nColA4)*nAC, "10 - "+"Empresa", oFont01) //"Empresa"
			oPrint:Say((nLinIni + 0349)*nAL, (nColIni + 1910 + nColA4)*nAC, aDados[nX, 10], Iif(Empty(aDados[nX, 10]),oFont06,oFont05))

			oPrint:Box((nLinIni + 0284)*nAL, (nColIni + 2605 + nColA4)*nAC, (nLinIni + 0378)*nAL, (nColIni + 2955 + nColA4)*nAC)
			oPrint:Say((nLinIni + 0309)*nAL, (nColIni + 2610 + nColA4)*nAC, "11 - "+"Data Validade da Carteira", oFont01) //"Data Validade da Carteira"
			oPrint:Say((nLinIni + 0349)*nAL, (nColIni + 2615 + nColA4)*nAC, Iif(Empty(aDados[nX, 11]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 11])), Iif(Empty(aDados[nX, 11]),oFont06,oFont05))

			oPrint:Box((nLinIni + 0284)*nAL, (nColIni + 2960 + nColA4)*nAC, (nLinIni + 0378)*nAL, (nColIni + 3613 + nColA4)*nAC)
			oPrint:Say((nLinIni + 0309)*nAL, (nColIni + 2965 + nColA4)*nAC, "12 - "+"Número do Cartão Nacional de Saúde", oFont01) //"Número do Cartão Nacional de Saúde"
			oPrint:Say((nLinIni + 0349)*nAL, (nColIni + 2970 + nColA4)*nAC, Iif(Empty(aDados[nX, 12]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 12]), Iif(Empty(aDados[nX, 12]),oFont06,oFont05))

			oPrint:Box((nLinIni + 0383)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0477)*nAL, (nColIni + 1600 + nColA4)*nAC)
			oPrint:Say((nLinIni + 0407)*nAL, (nColIni + 0020)*nAC, "13 - "+"Nome", oFont01) //"Nome"
			oPrint:Say((nLinIni + 0447)*nAL, (nColIni + 0030)*nAC, aDados[nX, 13], oFont04)

			oPrint:Box((nLinIni + 0383)*nAL, (nColIni + 1605 + nColA4)*nAC, (nLinIni + 0477)*nAL, (nColIni + 2235 + nColA4)*nAC)
			oPrint:Say((nLinIni + 0407)*nAL, (nColIni + 1615 + nColA4)*nAC, "14 - "+"Telefone", oFont01) //"Telefone"
			oPrint:Say((nLinIni + 0447)*nAL, (nColIni + 1625 + nColA4)*nAC, Iif(Empty(aDados[nX, 14]),'(|___|___|)|___|___|___|___|___|-|___|___|___|___|',aDados[nX, 14]), oFont04)

			oPrint:Box((nLinIni + 0383)*nAL, (nColIni + 2240 + nColA4)*nAC, (nLinIni + 0477)*nAL, (nColIni + 3185 + nColA4)*nAC)
			oPrint:Say((nLinIni + 0407)*nAL, (nColIni + 2250 + nColA4)*nAC, "15 - "+"Nome do Titular do Plano", oFont01) //"Nome do Titular do Plano"
			oPrint:Say((nLinIni + 0447)*nAL, (nColIni + 2260 + nColA4)*nAC, aDados[nX, 15], oFont04)

			oPrint:Box((nLinIni + 0383)*nAL, (nColIni + 3195 + nColA4)*nAC, (nLinIni + 0477)*nAL, (nColIni + 3610 + nColA4)*nAC)
			oPrint:Say((nLinIni + 0407)*nAL, (nColIni + 3205 + nColA4)*nAC, "16 - "+"Atendimento a RN", oFont01) //"Atendimento a RN"
			oPrint:Say((nLinIni + 0447)*nAL, (nColIni + 3215 + nColA4)*nAC, Iif(Empty(aDados[nX, 16]),'|___|',aDados[nX, 16]), oFont04)

			nLinIni += 10
			oPrint:Say((nLinIni + 0502)*nAL, (nColIni + 0010)*nAC, "Dados do Contratado Responsável pelo Tratamento", oFont01) 		 //"Dados do Contratado Responsável pelo Tratamento"
			oPrint:Box((nLinIni + 0512)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0607)*nAL, (nColIni + 1940)*nAC)
			oPrint:Say((nLinIni + 0537)*nAL, (nColIni + 0020)*nAC, "17 - " + "Nome do Profissional Solicitante", oFont01) //"Nome do Profissional Solicitante"
			oPrint:Say((nLinIni + 0577)*nAL, (nColIni + 0030)*nAC, aDados[nX, 17], oFont04)

			oPrint:Box((nLinIni + 0512)*nAL, (nColIni + 1945)*nAC, (nLinIni + 0607)*nAL, (nColIni + 2745)*nAC)
			oPrint:Say((nLinIni + 0537)*nAL, (nColIni + 1950)*nAC, "18 - " + "Número no CRO", oFont01) //"Número no CRO"
			oPrint:Say((nLinIni + 0577)*nAL, (nColIni + 1955)*nAC, Iif(Empty(aDados[nX, 18]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 18]), oFont04)

			oPrint:Box((nLinIni + 0512)*nAL, (nColIni + 2750)*nAC, (nLinIni + 0607)*nAL, (nColIni + 2900)*nAC)
			oPrint:Say((nLinIni + 0537)*nAL, (nColIni + 2760)*nAC, "19 - " + "UF", oFont01) //"UF"
			oPrint:Say((nLinIni + 0577)*nAL, (nColIni + 2770)*nAC, Iif(Empty(aDados[nX, 19]),'|___|___|',aDados[nX, 19]), oFont04)

			oPrint:Box((nLinIni + 0512)*nAL, (nColIni + 2905)*nAC, (nLinIni + 0607)*nAL, (nColIni + 3255)*nAC)
			oPrint:Say((nLinIni + 0537)*nAL, (nColIni + 2910)*nAC, "20 - " + "Código CBOS", oFont01) //"Código CBO S"
			oPrint:Say((nLinIni + 0577)*nAL, (nColIni + 2915)*nAC, Iif(Empty(aDados[nX, 20]),'|___|___|___|___|___|___|',aDados[nX, 20]), oFont04)

			oPrint:Box((nLinIni + 0611)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0706)*nAL, (nColIni + 0760)*nAC)
			oPrint:Say((nLinIni + 0636)*nAL, (nColIni + 0020)*nAC, "21 - "+"Código na Operadora / CNPJ / CPF", oFont01) //"Código na Operadora / CNPJ / CPF"
			oPrint:Say((nLinIni + 0676)*nAL, (nColIni + 0030)*nAC, Iif(Empty(aDados[nX, 21]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 21]), oFont04)

			oPrint:Box((nLinIni + 0611)*nAL, (nColIni + 0765)*nAC, (nLinIni + 0706)*nAL, (nColIni + 1940)*nAC)
			oPrint:Say((nLinIni + 0636)*nAL, (nColIni + 0770)*nAC, "22 - "+"Nome do Contratado Executante", oFont01) //"Nome do Contratado Executante"
			oPrint:Say((nLinIni + 0676)*nAL, (nColIni + 0775)*nAC, SubStr(aDados[nX, 22], 1, 65), oFont04)

			oPrint:Box((nLinIni + 0611)*nAL, (nColIni + 1945)*nAC, (nLinIni + 0706)*nAL, (nColIni + 2745)*nAC)
			oPrint:Say((nLinIni + 0636)*nAL, (nColIni + 1950)*nAC, "23 - "+"Número no CRO", oFont01) //"Número no CRO"
			oPrint:Say((nLinIni + 0676)*nAL, (nColIni + 1955)*nAC, Iif(Empty(aDados[nX, 23]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 23]), oFont04)

			oPrint:Box((nLinIni + 0611)*nAL, (nColIni + 2750)*nAC, (nLinIni + 0706)*nAL, (nColIni + 2900)*nAC)
			oPrint:Say((nLinIni + 0636)*nAL, (nColIni + 2760)*nAC, "24 - "+"UF", oFont01) //"UF"
			oPrint:Say((nLinIni + 0676)*nAL, (nColIni + 2770)*nAC, Iif(Empty(aDados[nX, 24]),'|___|___|',aDados[nX, 24]), oFont04)

			oPrint:Box((nLinIni + 0611)*nAL, (nColIni + 2905)*nAC, (nLinIni + 0706)*nAL, (nColIni + 3255)*nAC)
			oPrint:Say((nLinIni + 0636)*nAL, (nColIni + 2910)*nAC, "25 - "+"Código CNES", oFont01) //"Código CNES"
			oPrint:Say((nLinIni + 0676)*nAL, (nColIni + 2915)*nAC, Iif(Empty(aDados[nX, 25]),'|___|___|___|___|___|___|',aDados[nX, 25]), oFont04)

			oPrint:Box((nLinIni + 0710)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0805)*nAL, (nColIni + 1940)*nAC)
			oPrint:Say((nLinIni + 0735)*nAL, (nColIni + 0020)*nAC, "26 - "+"Nome do Profissional Executante", oFont01) //"Nome do Profissional Executante"
			oPrint:Say((nLinIni + 0775)*nAL, (nColIni + 0030)*nAC, aDados[nX, 26], oFont04)

			oPrint:Box((nLinIni + 0710)*nAL, (nColIni + 1945)*nAC, (nLinIni + 0805)*nAL, (nColIni + 2745)*nAC)
			oPrint:Say((nLinIni + 0735)*nAL, (nColIni + 1950)*nAC, "27 - "+"Número no CRO", oFont01) //"Número no CRO"
			oPrint:Say((nLinIni + 0775)*nAL, (nColIni + 1955)*nAC, Iif(Empty(aDados[nX, 27]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 27]), oFont04)

			oPrint:Box((nLinIni + 0710)*nAL, (nColIni + 2750)*nAC, (nLinIni + 0805)*nAL, (nColIni + 2900)*nAC)
			oPrint:Say((nLinIni + 0735)*nAL, (nColIni + 2760)*nAC, "28 - "+"UF", oFont01) //"UF"
			oPrint:Say((nLinIni + 0775)*nAL, (nColIni + 2770)*nAC, Iif(Empty(aDados[nX, 28]),'|___|___|',aDados[nX, 28]), oFont04)

			oPrint:Box((nLinIni + 0710)*nAL, (nColIni + 2905)*nAC, (nLinIni + 0805)*nAL, (nColIni + 3255)*nAC)
			oPrint:Say((nLinIni + 0735)*nAL, (nColIni + 2910)*nAC, "29 - "+"Código CBOS", oFont01) //"Código CBO S"
			oPrint:Say((nLinIni + 0775)*nAL, (nColIni + 2915)*nAC, Iif(Empty(aDados[nX, 29]),'|___|___|___|___|___|___|',aDados[nX, 29]), oFont04)

			nLinIni += 110
			oPrint:Say((nLinIni + 0730)*nAL, (nColIni + 0010)*nAC, "Procedimentos Executados", oFont01) //"Procedimentos Executados"
			oPrint:Box((nLinIni + 0740)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1580)*nAL, (nColIni + 3665 + nColA4)*nAC)
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 0030)*nAC, "30 - " + "Tabela", oFont01) //"Tabela"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 0145)*nAC, "31 - " + "Código do Procedimento", oFont01) //"Código do Procedimento"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 0520)*nAC, "32 - " + "Descrição", oFont01) //"Descrição"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 1400 + nColA4)*nAC, "33 - " + "Dente/Região", oFont01) //"Dente/Região"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 1580 + nColA4)*nAC, "34 - " + "Face", oFont01) //"Face"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 1790 + nColA4)*nAC, "35 - " + "Qtd", oFont01) //"Qtd"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 1870 + nColA4)*nAC, "36 - " + "Quantidade US", oFont01,,,,1) //"Quantidade US"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 2150 + nColA4)*nAC, "37 - " + "Valor", oFont01) //"Valor"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 2470 + nColA4)*nAC, "38 - " + "Franquia/Co-participação R$", oFont01) //"Franquia/Co-participação R$"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 2790 + nColA4)*nAC, "39 - " + "Aut", oFont01,,,,1)  //"Aut"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 2850 + nColA4)*nAC, "40 - " + "Cód. Negativa", oFont01,,,,1) //"Cód. Negativa"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 3020 + nColA4)*nAC, "41 - " + "Data Realização", oFont01,,,,1) //"Data Realização"
			oPrint:Say((nLinIni + 0770)*nAL, (nColIni + 3350 + nColA4)*nAC, "42 - " + "Assinatura", oFont01,,,,1) //"Assinatura"

			nOldLinIni := nLinIni

			If nVolta == 1
			  nP := 1
			Endif
			nT := nP+19

			For nI := nP To nT
				If nVolta <> 1
					nN := nI-(20*nVolta-20)
					oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nN)) + " - ", oFont01)
				Else
					oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 0020)*nAC, AllTrim(Str(nI)) + " - ", oFont01)
				Endif

				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 0060)*nAC, Iif(Empty(aDados[nX, 30, nI]),'|___|___|',aDados[nX, 30, nI]), Iif(Empty(aDados[nX, 30, nI]),oFont06,oFont04))
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 0145)*nAC, Iif(Empty(aDados[nX, 31, nI]),'|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 31, nI]), Iif(Empty(aDados[nX, 31, nI]),oFont06,oFont04))
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 0520)*nAC, Iif(Empty(aDados[nX, 32, nI]),REPLICATE('_',50),aDados[nX, 32, nI]), Iif(Empty(aDados[nX, 32, nI]),oFont06,oFont01))
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 1400 + nColA4)*nAC, Iif(Empty(aDados[nX, 33, nI]),'|___|___|___|___|',aDados[nX, 33, nI]), Iif(Empty(aDados[nX, 33, nI]),oFont06,oFont04))
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 1580 + nColA4)*nAC, Iif(Empty(aDados[nX, 34, nI]),'|___|___|___|___|___|',aDados[nX, 34, nI]), Iif(Empty(aDados[nX, 34, nI]),oFont06,oFont04))
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 1790 + nColA4)*nAC, IIF(Empty(aDados[nX, 35, nI]), "|___|___|", Transform(aDados[nX, 35, nI], "@E 9999.99")), Iif(Empty(aDados[nX, 35, nI]),oFont06,oFont04),,,,1)

				If GetNewPar("MV_PLSMUS","2") == "2"
					oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 1870 + nColA4)*nAC, IIf(Empty(aDados[nX, 36, nI]), "|___|___|___|___|___|,|___|___|", ""), Iif(Empty(aDados[nX, 36, nI]),oFont06,oFont04),,,,1)
				Else
					oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 1870 + nColA4)*nAC, IIf(Empty(aDados[nX, 36, nI]), "|___|___|___|___|___|,|___|___|", Transform(aDados[nX, 36, nI], "@E 99,999,999.99")), Iif(Empty(aDados[nX, 36, nI]),oFont06,oFont04),,,,1)//dennis
				Endif
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 2150 + nColA4)*nAC, IIf(Empty(aDados[nX, 37, nI]), "|___|___|___|___|___|___|,|___|___|", Transform(aDados[nX, 37, nI], "@E 99,999,999.99")), Iif(Empty(aDados[nX, 37, nI]),oFont06,oFont04),,,,1)
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 2470 + nColA4)*nAC, IIf(Empty(aDados[nX, 38, nI]), "|___|___|___|___|___|___|,|___|___|", Transform(aDados[nX, 38, nI], "@E 99,999,999.99")), Iif(Empty(aDados[nX, 38, nI]),oFont06,oFont04),,,,1)
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 2790 + nColA4)*nAC, Iif(Empty(aDados[nX, 39, nI]),'|___|',aDados[nX, 39, nI]), Iif(Empty(aDados[nX, 39, nI]),oFont06,oFont04))
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 2850 + nColA4)*nAC, Iif(Empty(aDados[nX, 40, nI]),'|___|___|___|___|',aDados[nX, 40, nI]), Iif(Empty(aDados[nX, 40, nI]),oFont06,oFont04))
			   	If cImpDatRea == "S"
			   	oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 3020 + nColA4)*nAC, IIf(Empty(aDados[nX, 41, nI]), "|___|___|/|___|___|/|___|___|___|___|", DtoC(aDados[nX, 41, nI])), Iif(Empty(aDados[nX, 41, nI]),oFont06,oFont04))
			   	Else
				oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 3020 + nColA4)*nAC, IIf(Empty(aDados[nX, 41, nI]), "|___|___|/|___|___|/|___|___|___|___|", ""                       ), Iif(Empty(aDados[nX, 41, nI]),oFont06,oFont04))
			   	EndIf
			   	oPrint:Say((nLinIni + 0810)*nAL, (nColIni + 3350 + nColA4)*nAC, Iif(Empty(aDados[nX, 42, nI]),REPLICATE('_',25),aDados[nX, 42, nI]), Iif(Empty(aDados[nX, 42, nI]),oFont06,oFont04))

				nLinIni += 40
			Next nI

			nP:=nI

			nP1:=Len(aDados[nX, 29])

		 	if nP1 >nI-1
				lImpnovo:=.T.
			Endif

		 	nLinIni := nOldLinIni - 30

			oPrint:Box((nLinIni + 1625)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1719)*nAL, (nColIni + 0500)*nAC)
			oPrint:Say((nLinIni + 1655)*nAL, (nColIni + 0020)*nAC, "43 - "+"Data Previsão Término do Tratamento", oFont01) //"Data Previsão Término do Tratamento"
			oPrint:Say((nLinIni + 1695)*nAL, (nColIni + 0030)*nAC, Iif(Empty(aDados[nX, 43]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 43])), oFont04)
			
			oPrint:Box((nLinIni + 1625)*nAL, (nColIni + 0505)*nAC, (nLinIni + 1719)*nAL, (nColIni + 1410)*nAC)
			oPrint:Say((nLinIni + 1655)*nAL, (nColIni + 0515)*nAC, "44 - "+"Tipo de Atendimento", oFont01) //"Tipo de Atendimento"
			oPrint:Line((nLinIni+ 1660)*nAL, (nColIni + 0515)*nAC, (nLinIni + 1700)*nAL, (nColIni + 0515)*nAC)
			oPrint:Line((nLinIni+ 1700)*nAL, (nColIni + 0515)*nAC, (nLinIni + 1700)*nAL, (nColIni + 0550)*nAC)
			oPrint:Line((nLinIni+ 1660)*nAL, (nColIni + 0550)*nAC, (nLinIni + 1700)*nAL, (nColIni + 0550)*nAC)
			oPrint:Say((nLinIni + 1695)*nAL, (nColIni + 0527)*nAC, Iif(Empty(aDados[nX, 44]),'',aDados[nX, 44]), oFont04)
			oPrint:Say((nLinIni + 1685)*nAL, (nColIni + 0570)*nAC, "1 - "+'Tratamento Odontológico'+"     "+"2 - "+'Exame Radiológico'+"     "+"3 - "+'Ortodontia'+"     "+"4 - "+'Urgência/Emergência ', oFont01) //"Tratamento Odontológico   Exame Radiológico   Ortodontia   Urgência/Emergência "
			
			oPrint:Box((nLinIni + 1625)*nAL, (nColIni + 1415)*nAC, (nLinIni + 1719)*nAL, (nColIni + 2010)*nAC)
			oPrint:Say((nLinIni + 1655)*nAL, (nColIni + 1425)*nAC, "45 - "+"Tipo de Faturamento", oFont01) //"Tipo de Faturamento"
			oPrint:Line((nLinIni+ 1660)*nAL, (nColIni + 1425)*nAC, (nLinIni + 1700)*nAL, (nColIni + 1425)*nAC)
			oPrint:Line((nLinIni+ 1700)*nAL, (nColIni + 1425)*nAC, (nLinIni + 1700)*nAL, (nColIni + 1460)*nAC)
			oPrint:Line((nLinIni+ 1660)*nAL, (nColIni + 1460)*nAC, (nLinIni + 1700)*nAL, (nColIni + 1460)*nAC)
			oPrint:Say((nLinIni + 1695)*nAL, (nColIni + 1437)*nAC, Iif(Empty(aDados[nX, 45]),'',aDados[nX, 45]), oFont04)
			oPrint:Say((nLinIni + 1685)*nAL, (nColIni + 1480)*nAC, "1 - "+"Total"+"     "+"2 - "+"Parcial ", oFont01) //"Total"###"Parcial "
			
			oPrint:Box((nLinIni + 1625)*nAL, (nColIni + 1715)*nAC, (nLinIni + 1719)*nAL, (nColIni + 2215)*nAC)
			oPrint:Say((nLinIni + 1655)*nAL, (nColIni + 1725)*nAC, "46 - "+"Total Quantidade US", oFont01) //"Total Quantidade US"
			oPrint:Say((nLinIni + 1695)*nAL, (nColIni + 1730)*nAC, Iif(Empty(aDados[nX, 46]),'|___|___|___|___|___|___|___|,|___|___|',Transform(aDados[nX, 46], "@E 999,999,999.99")), oFont04,,,,1)
			
			oPrint:Box((nLinIni + 1625)*nAL, (nColIni + 2220)*nAC, (nLinIni + 1719)*nAL, (nColIni + 2720)*nAC)
			oPrint:Say((nLinIni + 1655)*nAL, (nColIni + 2230)*nAC, "47 - "+"Valor Total R$", oFont01) //"Valor Total R$"
			oPrint:Say((nLinIni + 1695)*nAL, (nColIni + 2235)*nAC, Iif(Empty(aDados[nX, 47]),'|___|___|___|___|___|___|___|,|___|___|',Transform(aDados[nX, 47], "@E 999,999,999.99")), oFont04,,,,1)
			
			oPrint:Box((nLinIni + 1625)*nAL, (nColIni + 2725)*nAC, (nLinIni + 1719)*nAL, (nColIni + 3315)*nAC)
			oPrint:Say((nLinIni + 1655)*nAL, (nColIni + 2735)*nAC, "48 - "+"Total Franquia / Co-Participação R$", oFont01) //"Total Franquia / Co-Participação R$"
			oPrint:Say((nLinIni + 1695)*nAL, (nColIni + 2750)*nAC, Iif(Empty(aDados[nX, 48]),'|___|___|___|___|___|___|___|___|,|___|___|',Transform(aDados[nX, 48], "@E 999,999,999.99")), oFont04,,,,1)

		 	nLinIni+=05
		 	cMsg := "Declaro, que após ter sido devidamente esclarecido sobre os propósitos, riscos, custos e alternativas de tratamento, conforme acima apresentados, aceito e autorizo a execução do tratamento, comprometendo-me a cumprir as orientações do profissional assistente"// 
		 	oPrint:Say((nLinIni + 1735)*nAL, (nColIni + 0010)*nAC, cMsg, oFont04)

		 	cMsg := "e arcar com os custos previstos em contrato. Declaro, ainda, que o(s) procedimento(s) descrito(s) acima, e por mim assinado(s), foi/foram realizado(s) com meu consentimento e de forma satisfatória. Autorizo a Operadora a pagar em meu nome e por minha conta, "// 
		 	oPrint:Say((nLinIni + 1770)*nAL, (nColIni + 0010)*nAC, cMsg, oFont04)

		 	cMsg := "ao profissional contratado que assina esse documento, os valores referentes ao tratamento realizado, "//
		 	oPrint:Say((nLinIni + 1800)*nAL, (nColIni + 0010)*nAC, cMsg, oFont04)

		    nLinIni += 50
		    oPrint:Box((nLinIni + 1755)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1895)*nAL, (nColIni + 3665 + nColA4)*nAC)
			oPrint:Say((nLinIni + 1865)*nAC, (nColIni + 0020)*nAC, "49 - "+"Observação/Justificativa", oFont01) //"Observação/Justificativa"

			nLin := 1825

			For nI := 1 To MlCount(aDados[nX, 49], 220)
				cObs := MemoLine(aDados[nX, 49], 220, nI)
				oPrint:Say((nLinIni + nLin)*nAL, (nColIni + 0020)*nAC, cObs, oFont04)
				nLin += 35
			Next nI

			nLinIni+=65

			oPrint:Box((nLinIni + 1840)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1935)*nAL, (nColIni + 0825)*nAC)
			oPrint:Say((nLinIni + 1865)*nAL, (nColIni + 0025)*nAC, "50 - "+"Data, local e Assinatura do Cirurgião Dentista Solicitante", oFont01) //"Data, local e Assinatura do Cirurgião Dentista Solicitante"
			oPrint:Say((nLinIni + 1905)*nAL, (nColIni + 0035)*nAC, Iif(Empty(aDados[nX, 50]),'|___|___| / |___|___| / |___|___|___|___|',DtoC(aDados[nX, 50])), oFont04)

		 	oPrint:Box((nLinIni + 1840)*nAL, (nColIni + 0830)*nAC, (nLinIni + 1935)*nAL, (nColIni + 1600)*nAC)
			oPrint:Say((nLinIni + 1865)*nAL, (nColIni + 0845)*nAC, "51 - "+"Assinatura do Cirurgião Dentista", oFont01) //"Assinatura do Cirurgião Dentista"
			oPrint:Say((nLinIni + 1905)*nAL, (nColIni + 0855)*nAC, (aDados[nX, 51]), oFont04)

			oPrint:Box((nLinIni + 1840)*nAL, (nColIni + 1605)*nAC, (nLinIni + 1935)*nAL, (nColIni + 2375)*nAC)
			oPrint:Say((nLinIni + 1865)*nAL, (nColIni + 1620)*nAC, "52 - "+"Data Assinatura do Associado / Responsável", oFont01) //"Data Assinatura do Associado / Responsável"
			oPrint:Say((nLinIni + 1905)*nAL, (nColIni + 1630)*nAC, Iif(Empty(aDados[nX, 52]),'|___|___| / |___|___| / |___|___|___|___|',DtoC(aDados[nX, 52])), oFont04)

			oPrint:Box((nLinIni + 1840)*nAL, (nColIni + 2380)*nAC, (nLinIni + 1935)*nAL, (nColIni + 3165)*nAC)
			oPrint:Say((nLinIni + 1865)*nAL, (nColIni + 2385)*nAC, "53 - "+"Assinatura do Associado / Responsável", oFont01) //"Assinatura do Associado / Responsável"
			oPrint:Say((nLinIni + 1905)*nAL, (nColIni + 2395)*nAC, aDados[nX, 53], oFont04)

			nLinIni+=10
			oPrint:Box((nLinIni + 1940)*nAL, (nColIni + 0010)*nAC, (nLinIni + 2035)*nAL, (nColIni + 0825)*nAC)
			oPrint:Say((nLinIni + 1965)*nAL, (nColIni + 0025)*nAC, "54 - "+"Data, local e Assinatura do Cirurgião Dentista Solicitante", oFont01) //"Data, local e Assinatura do Cirurgião Dentista Solicitante"
			oPrint:Say((nLinIni + 2005)*nAL, (nColIni + 0035)*nAC, Iif(Empty(aDados[nX, 54]),'|___|___| / |___|___| / |___|___|___|___|',DtoC(aDados[nX, 54])), oFont04)

		 	oPrint:Box((nLinIni + 1940)*nAL, (nColIni + 0830)*nAC, (nLinIni + 2035)*nAL, (nColIni + 1600)*nAC)
			oPrint:Say((nLinIni + 1965)*nAL, (nColIni + 0845)*nAC, "55 - "+"Data, Local e Assinatura do Cirurgião Dentista", oFont01) //"Data, Local e Assinatura do Cirurgião Dentista"
			oPrint:Say((nLinIni + 2005)*nAL, (nColIni + 0855)*nAC, (aDados[nX, 55]), oFont04)

			oPrint:Box((nLinIni + 1940)*nAL, (nColIni + 1605)*nAC, (nLinIni + 2035)*nAL, (nColIni + 2375)*nAC)
			oPrint:Say((nLinIni + 1965)*nAL, (nColIni + 1620)*nAC, "56 - "+"Data, Local e Assinatura do Associado / Responsável", oFont01) //"Data, Local e Assinatura do Associado / Responsável"
			oPrint:Say((nLinIni + 2005)*nAL, (nColIni + 1630)*nAC, Iif(Empty(aDados[nX, 56]),'|___|___| / |___|___| / |___|___|___|___|',DtoC(aDados[nX, 56])), oFont04)

			oPrint:EndPage()	// Finaliza a pagina
		Next nX
	Enddo

If lGerTXT .And. !lWeb
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Imprime Relatorio
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:Print()
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Visualiza impressao grafica antes de imprimir
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:Print()
EndIf

Return(cFileName)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ?PLSODTSC  ?Autor ?Thiago Ribas     ?Data ?17.12.15 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ?Estrutura Relatório TISS 3 Guia Odontológica - Solicitação)  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?SigaPLS                                                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros?aDados - Array com as informações do relat´rio              ³±?
±±?         ?lGerTXT - Imprime sem seleção de impressora
			 ?nLayout - Define o formato de papél para impressao:         ³±?
±±?         ?          1 - Formato Ofício II (216x330mm)                 ³±?
±±?         ?          2 - Formato A4 (210x297mm)                        ³±?
±±?         ? 		 3 - Formato Carta (216x279mm)     			       ³±?
±±?         ?cPathRelW - caminho onde ser?gravado o relatório	       ³±			
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PLSODTSC(aDados, lGerTXT, nLayout, cLogoGH, lWeb, cPathRelW) //Guia Odontológica - Solicitação

	Local nLinMax
	Local nColMax
	Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
	Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
	Local cFileLogo
	Local nLin
	Local nX , nI
	Local cObs
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local nCol  	:=	0
	Local nColf 	:=	0
	Local aNum1,aNum2,aNum3,aNum4 :={}
	LOCAL cRel      := "TRTODONT"
	LOCAL cPathSrvJ := GETMV("MV_RELT")
	Local lRet 		:= .T.
	Local oPrint := NIL
	Local nAL		:= 0.25
	Local nAC		:= 0.24
	Local nEspGrid  := 0
	Local nLinVert  := 0
	Local nVert     := 0
	Local cFileName := NIL
	Local cFile     := GetNewPar("MV_RELT",'\SPOOL\')+'PLSR421N.HTM'

	Default lGerTXT := .F.
	Default nLayout := 2
	Default cLogoGH := ''
	Default lWeb	:= .F.
	Default cPathRelW 	:= ""
	Default aDados  := { { ;
						"123456",; 				 //1 - Registro ANS
						"12345678901234567892",; //2 - N?Guia no Prestador  
						"12345678901234567892",; //3 - Número da Guia Principal de Tratamento Odontológico
						"12345678901234567892",; //4 - Número da Guia Atribuído pela Operadora					 
						Replicate("M",70),;      //5 - Nome
						Replicate("M",20),;		 //6 - Número da Carteira
						"",;			         //7 - Dente
						"",;					 //8 - Situação Dentária Inicial
						"",;   		 			 //9 - Sinais Clínicos de Doença Periodontal
						"",;				 	 //10 - Alteração dos Tecidos Moles
						Replicate("M",500),;  	 //11 - Observação/Justificativa
						CtoD("30/12/07"),;   	 //12 - Local e Data
						"",;			     	 //13 - Assinatura do Cirurgião-Dentista
						CtoD("30/12/07"),; 		 //14 - Local e Data
						"",;					 //15 - Assinatura do Beneficiário/Responsável
						CtoD("30/12/07")} } 	 //16 - Local, Data e Carimbo da Empresa

	If nLayout  == 1 // Ofício 2
		nLinMax := 2435
		nColMax := 3705
	Elseif nLayout == 2   // Papél A4
	   	nLinMax	:=	2150
		nColMax	:=	3350 //3365
	Else //Carta
		nLinMax	:=	2435
		nColMax	:=	3175
	Endif

	oFont01		:= TFont():New("Arial",  6,  6, , .F., , , , .T., .F.) // Normal
	if nLayout == 1 // Oficio 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	Else  // Papél A4 ou Carta
	  	oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Nao permite acionar a impressao quando for na web.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If lWeb
		cPathSrvJ := cPathRelW
		cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
	Else
		cFileName := cRel+CriaTrab(NIL,.F.)
	EndIf

	oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ, .T.,, @oPrint,,, .F.,.F.)

	//³Tratamento para impressao via job
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:lServer := lWeb
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Caminho do arquivo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	oPrint:cPathPDF := cPathSrvJ
	
	oPrint:SetLandscape()		// Modo paisagem
	
	if nLayout ==2
		oPrint:SetPaperSize(9)// Papél A4
	Elseif nLayout ==3
		oPrint:SetPaperSize(1)// Papél Carta
	Else
		oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	Endif/
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Device
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If lWeb
		oPrint:setDevice(IMP_PDF)
		oPrint:lPDFAsPNG := .T.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Verifica se existe alguma impressora configurada para Impressao Grafica
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If  !lWeb
		oPrint:Setup()
		lImpnovo:=(oPrint:nModalResult == 1)
	EndIf
	
	If oPrint:Cprinter == "PDF" .OR. lWeb
		nLinIni := 150
		nColMax -= 15
	Else
		nLinIni := 080
	Endif
	
	nColIni := 080
	
	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		oPrint:StartPage()		// Inicia uma nova pagina
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box((nLinIni + 0000)*nAL, (nColIni + 0000)*nAC, (nLinIni + nLinMax)*nAL, (nColIni + nColMax)*nAC)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega e Imprime Logotipo da Empresa                         ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fLogoEmp(@cFileLogo,, cLogoGH)

		If File(cFilelogo)
			oPrint:SayBitmap((nLinIni + 0050)*nAL, (nColIni + 0020)*nAC, cFileLogo, (400)*nAL, (090)*nAC) 		// Tem que estar abaixo do RootPath
		EndIf

		oPrint:Say((nLinIni + 0080)*nAL, (nColIni + (nColMax*0.3))*nAC,"GUIA TRATAMENTO ODONTOLÓGICO - SITUAÇÃO INICIAL", oFont02n,,,, 2)  //"GUIA TRATAMENTO ODONTOLÓGICO - SITUAÇÃO INICIAL"
		oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.76))*nAC, "2 - "+"Nº", oFont01) //"N?
		oPrint:Say((nLinIni + 0100)*nAL, (nColIni + (nColMax*0.79))*nAC, aDados[nX, 02], oFont03n)
		
		oPrint:Box((nLinIni + 0175)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0269)*nAL, (nColIni + (nColMax*0.1) - 0010)*nAC)
		oPrint:Say((nLinIni + 0210)*nAL, (nColIni + 0020)*nAC, "1 - " + "Registro ANS", oFont01) //"Registro ANS"
		oPrint:Say((nLinIni + 0243)*nAL, (nColIni + 0030)*nAC, Iif(Empty(aDados[nX, 01]),'|___|___|___|___|___|___|',aDados[nX, 01]), oFont04)
		
		oPrint:Box((nLinIni + 0175)*nAL, (nColIni + (nColMax*0.1))*nAC, (nLinIni + 0269)*nAL , (nColIni + (nColMax*0.50) - 0010)*nAC)
		oPrint:Say((nLinIni + 0210)*nAL, (nColIni + (nColMax*0.1) + 0010)*nAC, "3 - " + "Número da Guia Principal de Tratamento Odontológico", oFont01) //"Número da Guia Principal de Tratamento Odontológico"
		oPrint:Say((nLinIni + 0243)*nAL, (nColIni + (nColMax*0.1) + 0020)*nAC, Iif(Empty(aDados[nX, 03]),' |___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 03]), oFont04)
		
	    oPrint:Box((nLinIni + 0175)*nAL, (nColIni + (nColMax*0.50))*nAC, (nLinIni + 0269)*nAL , (nColIni + (nColMax*0.92) - 0010)*nAC)
		oPrint:Say((nLinIni + 0210)*nAL, (nColIni + (nColMax*0.50) + 0020)*nAC, "4 - " + "Número da Guia Atribuído pela Operadora", oFont01) //"Número da Guia Atribuído pela Operadora"
		oPrint:Say((nLinIni + 0243)*nAL, (nColIni + (nColMax*0.50) + 0030)*nAC, Iif(Empty(aDados[nX, 04]),' |___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 04]), oFont04)
		
		oPrint:Say((nLinIni + 0305)*nAL, (nColIni + 0010)*nAC, "Dados do Beneficiário", oFont01) //"Dados do Beneficiário"
		
		oPrint:Box((nLinIni + 0320)*nAL, (nColIni + 0010)*nAC, (nLinIni + 0398)*nAL, (nColIni + 1700 - 0010)*nAC)
		oPrint:Say((nLinIni + 0355)*nAL, (nColIni + 0020)*nAC, "5 - "+"Nome", oFont01) //"Nome"
		oPrint:Say((nLinIni + 0385)*nAL, (nColIni + 0030)*nAC, SUBSTR(aDados[nX, 05],1,50), oFont04)
		
		oPrint:Box((nLinIni + 0320)*nAL, (nColIni + 3200)*nAC, (nLinIni + 0398)*nAL, (nColIni + 1700)*nAC)
		oPrint:Say((nLinIni + 0355)*nAL, (nColIni + 1710)*nAC, "6 - " + "Número da Carteira", oFont01) //"Número da Carteira"
		oPrint:Say((nLinIni + 0385)*nAL, (nColIni + 1710)*nAC, Iif(Empty(aDados[nX, 06]),' |___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 06]), oFont04)
		
		oPrint:Say((nLinIni + 0437)*nAL, (nColIni + 0010)*nAC, "Situação Inicial", oFont01) //"Situação Inicial"
		
		//Monta GRID e informações da situação inicial
		//Início
		nEspGrid := 515
		
		oPrint:Box((nLinIni + 0455)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1147)*nAL, (nColIni + 0240)*nAC)
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, "Situação Inicial", oFont04) //"Situação Inicial"
			oPrint:Box((nLinIni + nEspGrid + 0055)*nAL, (nColIni + 0010)*nAC, (nLinIni + nEspGrid + 0055)*nAL , (nColIni + 0280)*nAC)
			
			nEspGrid += 115
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, "Permanentes", oFont04) //"Permanentes"
			oPrint:Box((nLinIni + nEspGrid + 0055)*nAL, (nColIni + 0010)*nAC, (nLinIni + nEspGrid + 0055)*nAL , (nColIni + 0280)*nAC)
			
			nEspGrid += 115
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, "Decíduos", oFont04) //"Decíduos"
			oPrint:Box((nLinIni + nEspGrid + 0055)*nAL, (nColIni + 0010)*nAC, (nLinIni + nEspGrid + 0055)*nAL , (nColIni + 0280)*nAC)
			
			nEspGrid += 115
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, "Decíduos", oFont04) //"Decíduos"
			oPrint:Box((nLinIni + nEspGrid + 0055)*nAL, (nColIni + 0010)*nAC, (nLinIni + nEspGrid + 0055)*nAL , (nColIni + 0280)*nAC)
			
			nEspGrid += 115
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, "Permanentes", oFont04) //"Permanentes"
			oPrint:Box((nLinIni + nEspGrid + 0055)*nAL, (nColIni + 0010)*nAC, (nLinIni + nEspGrid + 0055)*nAL , (nColIni + 0280)*nAC)
			
			nEspGrid += 115
			oPrint:Say((nLinIni + nEspGrid)*nAL, (nColIni + 0020)*nAC, "Situação Inicial", oFont04) //"Situação Inicial"*/
		
			nCol  :=245
			nColf :=350
			nLinVert := 455
			
			For nI:=1 to 16
				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)
				nLinVert += 115
				
				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)
				nLinVert += 115
				
				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)
				nLinVert += 115
				
				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)
				nLinVert += 115
				
				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)
				nLinVert += 115
				
				oPrint:Box((nLinIni + nLinVert)*nAL, (nColIni + nCol)*nAC , (nLinIni + nLinVert + 115)*nAL, (nColIni + 	nColf)*nAC)

			    nCol     += 0100
			    nColf 	 += 0100
			    nLinVert := 0455
			Next nI
			
			nCol  := 0268
			nVert := 0640
			aNum1:={"18","17","16","15","14","13","12","11","21","22","23","24","25","26","27","28"}
			
			For nI:=1 to Len(aNum1)
			oPrint:Say((nLinIni + 0640)*nAL, (nColIni + nCol)*nAC, aNum1[nI], oFont03n)
			 nCol  +=0100
			Next nI
			
			nVert += 0120
			nCol  := 0570
			aNum2:={"55","54","53","52","51","61","62","63","64","65"}
			
			For nI:=1 to Len(aNum2)
			oPrint:Say((nLinIni + nVert)*nAL, (nColIni + nCol)*nAC, aNum2[nI], oFont03n)
			 nCol  +=0100
			Next nI
			
			nVert += 0110
			nCol  := 0570
			aNum3:={"85","84","83","82","81","71","72","73","74","75"}
			
			For nI:=1 to Len(aNum3)
			oPrint:Say((nLinIni + nVert)*nAL, (nColIni + nCol)*nAC, aNum3[nI], oFont03n)
			 nCol  +=0100
			Next nI
			
			nVert += 0115
			nCol  := 0268
			aNum4:={"48","47","46","45","44","43","42","41","31","32","33","34","35","36","37","38"}
			
			For nI:=1 to Len(aNum4)
			oPrint:Say((nLinIni + nVert)*nAL, (nColIni + nCol)*nAC, aNum4[nI], oFont03n)
			 nCol  +=0100
			Next nI
		//FIM
		
		//Monta os quadros referente a parte pertencente 
		//a LEGENDA E OBSERVAÇÕES SOBRE A SITUAÇÃO INICIAL
		
		oPrint:Say((nLinIni + 0465)*nAL, (nColIni + 1910)*nAC, "LEGENDA E OBSERVAÇÕES SOBRE A SITUAÇÃO INICIAL", oFont01)	 //"LEGENDA E OBSERVAÇÕES SOBRE A SITUAÇÃO INICIAL"
		
		//Montagem do quadro Sinais Clínicos de doença periodontal ?
		//INÍCIO	
		oPrint:Box((nLinIni + 0485)*nAL, (nColIni + 2250)*nAC, (nLinIni + 0650)*nAL, (nColIni + 2770)*nAC)
	
			oPrint:Say((nLinIni + 0520)*nAL, (nColIni + 2290)*nAC, "9 - " + "Sinais Clínicos de doença periodontal ?", oFont01) //"Sinais Clínicos de doença periodontal ?"
	
				oPrint:Line((nLinIni + 0560)*nAL,(nColIni + 2320)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2320)*nAC)
				oPrint:Line((nLinIni + 0600)*nAL,(nColIni + 2320)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2380)*nAC)
				oPrint:Line((nLinIni + 0560)*nAL,(nColIni + 2380)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2380)*nAC)
				oPrint:Say((nLinIni + 0590)*nAL, (nColIni + 2400)*nAC, "Sim", oFont04)  //"Sim"
				oPrint:Say((nLinIni + 0560)*nAL, (nColIni + 2335)*nAC, IIf(((aDados[nX, 9]) =="1"),"X",""), oFont04)
		
			   	oPrint:Line((nLinIni + 0560)*nAL, (nColIni + 2550)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2550)*nAC)
				oPrint:Line((nLinIni + 0600)*nAL, (nColIni + 2550)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2610)*nAC)
				oPrint:Line((nLinIni + 0560)*nAL, (nColIni + 2610)*nAC, (nLinIni + 0600)*nAL,(nColIni + 2610)*nAC)
				oPrint:Say((nLinIni + 0590)*nAL,  (nColIni + 2630)*nAC, "Não", oFont04) //"Não"
				oPrint:Say((nLinIni + 0560)*nAL,  (nColIni + 2560)*nAC, IIf (((aDados[nX, 9]) == "0"),"X",""), oFont04)
		//FIM
		
		//Montagem do quadro alteração dos Tecidos Moles
		//INÍCIO
		oPrint:Box((nLinIni + 0965)*nAL, (nColIni + 2250)*nAC, (nLinIni + 0800)*nAL, (nColIni + 2770)*nAC)
			
			oPrint:Say((nLinIni + 0838)*nAL, (nColIni + 2290)*nAC, "10 - "+"Alteração dos Tecidos Moles ?", oFont01) //"Alteração dos Tecidos Moles ?"
			
				oPrint:Line((nLinIni + 0880)*nAL, (nColIni + 2320)*nAC, (nLinIni + 0920)*nAL, (nColIni + 2320)*nAC)
				oPrint:Line((nLinIni + 0920)*nAL, (nColIni + 2320)*nAC, (nLinIni + 0920)*nAL, (nColIni + 2380)*nAC)
				oPrint:Line((nLinIni + 0880)*nAL, (nColIni + 2380)*nAC, (nLinIni + 0920)*nAL, (nColIni + 2380)*nAC)
				oPrint:Say((nLinIni + 0910)*nAL, (nColIni + 2400)*nAC, "Sim", oFont04)  //"Sim"
				oPrint:Say((nLinIni + 0880)*nAL, (nColIni + 2335)*nAC, IIf(((aDados[nX, 10]) =="1"),"X",""), oFont04)
		
				oPrint:Line((nLinIni + 0880)*nAL, (nColIni + 2550)*nAC,( nLinIni + 0920)*nAL, (nColIni + 2550)*nAC)
				oPrint:Line((nLinIni + 0920)*nAL, (nColIni + 2550)*nAC, (nLinIni + 0920)*nAL, (nColIni + 2610)*nAC)
				oPrint:Line((nLinIni + 0880)*nAL, (nColIni + 2610)*nAC, (nLinIni + 0920)*nAL, (nColIni + 2610)*nAC)
				oPrint:Say((nLinIni + 0910)*nAL, (nColIni + 2630)*nAC, "Não", oFont04) //"Não"
				oPrint:Say((nLinIni + 0880)*nAL, (nColIni + 2560)*nAC, IIf (((aDados[nX, 10]) =="0"),"X",""), oFont04)
		//FIM
		
		//Montagem do quadro SITUAÇÃO INICIAL
		//INÍCIO
		oPrint:Box((nLinIni + 0560)*nAL, (nColIni + 1910)*nAC, (nLinIni + 0900)*nAL, (nColIni + 2220)*nAC)
			oPrint:Say((nLinIni + 0608)*nAL, (nColIni + 1960)*nAC, "8 - " + "SITUAÇÃO INICIAL", oFont01) //"SITUAÇÃO INICIAL"
			oPrint:Say((nLinIni + 0658)*nAL, (nColIni + 1960)*nAC, "A - Ausente", oFont01) //"A - Ausente"
			oPrint:Say((nLinIni + 0708)*nAL, (nColIni + 1960)*nAC, "E - Extração Indicada", oFont01) //"E - Extração Indicada"
			oPrint:Say((nLinIni + 0758)*nAL, (nColIni + 1960)*nAC, "H - Hígido", oFont01) //"H - Hígido"
			oPrint:Say((nLinIni + 0808)*nAL, (nColIni + 1960)*nAC, "C - Cariado", oFont01) //"C - Cariado"
			oPrint:Say((nLinIni + 0858)*nAL, (nColIni + 1960)*nAC, "R - Restaurado", oFont01) //"R - Restaurado"
		//FIM
		
		oPrint:Box((nLinIni + 1180)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1810)*nAL, (nColIni + 3320)*nAC)
		oPrint:Say((nLinIni + 1210)*nAL, (nColIni + 0020)*nAC, "11 - " + "Observação / Justificativa", oFont01) //"Observação / Justificativa"

		nLin := 1270
		
		For nI := 1 To MlCount(aDados[nX, 11], 130)
			cObs := MemoLine(aDados[nX, 11], 130, nI)
			oPrint:Say((nLinIni + nLin)*nAL, (nColIni + 0030)*nAC, cObs, oFont04)
			nLin += 50
		Next nI
		
		//Início da montagem  dos campos inferiores.
		oPrint:Box((nLinIni + 1830)*nAL, (nColIni + 0010)*nAC, (nLinIni + 1980)*nAL, (nColIni + 0850)*nAC)
		oPrint:Say((nLinIni + 1860)*nAL, (nColIni + 0020)*nAC, "12 - " + "Local e Data", oFont01) //"Local e Data"
		oPrint:Say((nLinIni + 1960)*nAL, (nColIni + 00350)*nAC, Iif(Empty(aDados[nX, 12]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 12])), oFont04)
		
		oPrint:Box((nLinIni + 1830)*nAL, (nColIni + 0870)*nAC, (nLinIni + 1980)*nAL, (nColIni + 1710)*nAC)
		oPrint:Say((nLinIni + 1860)*nAL, (nColIni + 0880)*nAC, "13 - " + "Assinatura do Cirurgião-Dentista", oFont01) //"Assinatura do Cirurgião-Dentista"
		
		oPrint:Box((nLinIni + 1990)*nAL, (nColIni + 0010)*nAC, (nLinIni + 2140)*nAL, (nColIni + 0850)*nAC)
		oPrint:Say((nLinIni + 2020)*nAL, (nColIni + 0020)*nAC, "14 - "+"Local e Data", oFont01) //"Local e Data"
		oPrint:Say((nLinIni + 2120)*nAL, (nColIni + 00350)*nAC, Iif(Empty(aDados[nX, 14]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 14])), oFont04)
	
		oPrint:Box((nLinIni + 1990)*nAL, (nColIni + 0870)*nAC, (nLinIni + 2140)*nAL, (nColIni + 1710)*nAC)
		oPrint:Say((nLinIni + 2020)*nAL, (nColIni + 0880)*nAC, "15 - " + "Assinatura do Beneficiário / Responsável", oFont01) //"Assinatura do Beneficiário / Responsável"
		
		oPrint:Box((nLinIni + 1830)*nAL, (nColIni + 1730)*nAC, (nLinIni + 2140)*nAL, (nColIni + 3320)*nAC)
		oPrint:Say((nLinIni + 1860)*nAL, (nColIni + 1740)*nAC, "16 - " + "Local, Data e Carimbo da Empresa", oFont01) //"Local, Data e Carimbo da Empresa"
		oPrint:Say((nLinIni + 2120)*nAL, (nColIni + 2200)*nAC, Iif(Empty(aDados[nX, 16]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 16])), oFont04)
		//FIM
		
		oPrint:EndPage()	// Finaliza a pagina

	Next nX
	
	If lGerTXT .And. !lWeb
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Imprime Relatorio
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		oPrint:Print()
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Visualiza impressao grafica antes de imprimir
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		If lRet
			oPrint:Preview()
		Endif
	EndIf
Return {lRet,cFile,cFileName}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ?PLSHONMD  ?Autor ?Bruno Iserhardt       ?Data ?26.06.13 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ?Estrutura Relatório TISS 3.00.01 (Guia Hon Individual)      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?SigaPLS                                                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros?aDados - Array com as informações do relat´rio              ³±?
±±?         ?lGerTXT - Define se imprime direto sem passar pela tela 	  ³±?
±±?         ?		 de configuracao/preview do relatorio 		         ³±?
±±?         ?nLayout - Define o formato de papél para impressao:         ³±?
±±?         ?          1 - Formato Ofício II (216x330mm)                 ³±?
±±?         ?          2 - Formato A4 (210x297mm)                        ³±?
±±?         ? 		 3 - Formato Carta (216x279mm)     			         ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PLSHONMD(aDados, lGerTXT, nLayout, cLogoGH, lWeb, cPathRelW, lUnicaImp)

Local nLinMax
Local nColMax
Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
Local nColA4    :=  0
Local nCol2A4   :=  0
Local nWeb		:= 0
Local cFileLogo
Local lPrinter := .F.
Local nOldLinIni
Local nI, nJ, nX
Local cObs
Local oFont01
Local oFont02n
Local oFont03n
Local oFont04
Local oFont06
Local nAte		:= 10
Local nAte2	:= 0
Local lImpNovo	:= .T.
Local nIni		:= 1
Local nIni2	:= 1
Local cRel      := "guihon"
Local oPrint	:= nil
Local cPathSrvJ := GETMV("MV_RELT")
Local nTweb		:= 1
Local nLweb		:= 0
Local nLwebC	:= 0
LOCAL cErro		:= ""
LOCAL cArq			:= ""
Local nTamBox	:= 0

Default lGerTXT := .F.
Default nLayout := 2
Default cLogoGH := ''
Default lWeb    := .F.
Default cPathRelW := ''
Default lUnicaImp := .F. 
Default aDados := { { ;
	"123456",; //1 - Registro ANS
	"12345678901234567890",; //2- N?Guia no Prestador
	"12345678901234567890",; //3- N?Guia de Solicitação de Internação
	"12345678901234567890",; //4 - Senha
	"12345678901234567890",; //5 - Número da Guia Atribuído pela Operadora
	"12345678901234567890",; //6 - Número da Carteira
	Replicate("M",70),; //7 - Nome
	"S",; //8 - Atendimento a RN
	"12345678901234",; //9 - Código na Operadora
	Replicate("H",70),; //10 - Nome do Hospital/Local
	"1234567",; //11-Código CNES
	"12345678901234",; //12 - Código na Operadora
	Replicate("M",70),; //13 - Nome do Contratado
	"1234567",; //14 - Código CNES
	CtoD("12/03/06"),; //15 - Data do Início do Faturamento
	CtoD("12/03/06"),; //16 - Data do Fim do Faturamento
	{ CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06")},; //17-Data
	{ "0107","0207","0307","0407","0507","0507","0507","0507","0507","0507","0507","0507" },; //18-Hora Inicial
	{ "0607","0707","0807","0907","1007","0507","0507","0507","0507","0507","0507","0507" },; //19-Hora Final
	{ "MM","AA","BB","CC","DD","DD","DD","DD","DD","DD","DD","DD" },; //20-Tabela
	{ "5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234"},; //21-Código do Procedimento
	{ Replicate("M",10),Replicate("E",150),Replicate("E",150),Replicate("E",150),Replicate("E",150),Replicate("E",150),Replicate("E",150),Replicate("E",150),Replicate("E",150),Replicate("E",150),Replicate("E",150),Replicate("E",150)},; //22-Código do Procedimento
	{ 120,1,22,322,4,444,4,444,4,4,411,111 },; //23-Qtde.
	{ "D","D","D","D","D","D","D","D","D","D","D","D"},; //24-Via
	{ "M","E","F","G","H","D","D","D","D","D","D","D" },; //25-Tec
	{ 1.99,1.99,1.99,1.99,1.99,1.99,1.99,1.99,1.99,1.99,1.99,1.99 },; //26- Fator Red / Acresc
	{ 999999.99,22222.22,33.33,44444.44,11111.11,111111.11,11111.11,11111.11,211111.11,11111.11,311111.11,999999.99 },; //27-Valor Unitário - R$
	{ 999999.99,22222.22,33.33,44444.44,11111.11,111111.11,11111.11,11111.11,211111.11,11111.11,311111.11,999999.99 },; //28-Valor Total ?R$
	{ "01", "99", "01", "99", "01" },; //29-Seq.Ref
	{ "02", "88", "02", "88", "02" },; //30-Grau Part.
	{ "01234567890123", "01234567890123", "01234567890123", "01234567890123", "01234567890123" },; //31-Código na Operadora/CPF
	{ Replicate("M", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70), Replicate("M", 70) },; //32-Nome do Profissional
	{ "00", "02", "00", "02", "00" },; //33-Conselho Profissional
	{ "012345678901234", "012345678901234", "012345678901234", "012345678901234", "012345678901234" },; //34-Número no Conselho
	{ "AA", "AA", "AA", "AA", "AA" },; //35-UF
	{ "123456", "123456", "123456", "123456", "123456" },; //36-Código CBO
	Replicate("M", 500),; //37- Observação / Justificativa
	987564.32,; //38- Valor total dos honorários
	CtoD("01/01/07") } } //39 - Data de emissão

If nLayout  == 1 // Ofício 2
	nLinMax := 2435
	nColMax := 3705
Elseif nLayout == 2   // Papél A4
	nLinMax	:=	2275
	nColMax	:=	3270 //3365
Else //Carta
	nLinMax	:=	2435
	nColMax	:=	3175
Endif

oFont01		:= TFont():New("Arial",  6,  6, , .F., , , , .T., .F.) // Normal
if nLayout == 1 // Oficio 2
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
Else  // Papél A4 ou Carta
	oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
Endif
oFont06		:= TFont():New("Arial", 06, 06, , .F., , , , .T., .F.) // Normal

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Nao permite acionar a impressao quando for na web.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lWeb
	cPathSrvJ := cPathRelW
	cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
Else
	cFileName := cRel+CriaTrab(NIL,.F.)
EndIf

if !lWeb
	oPrint	:= TMSPrinter():New("GUIA DE HONORARIOS") //"GUIA DE HONORARIOS"
else


	oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ	 ,.T.,	,@oPrint,			  ,			  ,	.F.			,.f.)
	If lSrvUnix
		AjusPath(@oPrint)
	EndIf
	oPrint:cPathPDF := cPathSrvJ

	nTweb	 := 3.9 //2 //3.9
	nLweb	 := 10 //5 //10
	nLwebC	 := -3
	nTamBox := 25

	oPrint:lServer := lWeb
Endif

oPrint:SetLandscape()		// Modo paisagem

if nLayout == 2
	oPrint:SetPaperSize(9)// Papél A4
Elseif nLayout == 3
	oPrint:SetPaperSize(1)// Papél Carta
Else
	oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
Endif


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Device
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lWeb
	oPrint:setDevice(IMP_PDF)
Else
		// Verifica se existe alguma impressora configurada para Impressao Grafica
	lPrinter := oPrint:IsPrinterActive()
	IF lPrinter
		lPrinter := IIF(GETNEWPAR("MV_IMPATIV", .F.), .F., .T.)	//	Define se ir?alterar a Impressora Ativa
	ENDIF
	If ! lPrinter
		oPrint:Setup()
	EndIf
Endif

For nX := 1 To Len(aDados)

	nAte 	:= 10
	nAte2 	:= 5
	nI		:= 0
	nIni	:= 1
	nIni2	:= 1
	
	//Esta parte do código faz com que
	//imprima mais de uma guia.
	//INICIO
	If lUnicaImp
		If nX <= Len(aDados) 
			lImpNovo := .T.
		EndIf
	EndIf
	//FIM 
	
	While lImpNovo

		lImpNovo 	:= .F.

		If  ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		For nI := 17 To 28
			If Len(aDados[nX, nI]) < nAte
				For nJ := Len(aDados[nX, nI]) + 1 To nAte
					If AllTrim(Str(nI)) $ "17"
						aAdd(aDados[nX, nI], StoD(""))
					ElseIf AllTrim(Str(nI)) $ "23,26,27,28"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		For nI := 29 To 36
			If Len(aDados[nX, nI]) < nAte2
				For nJ := Len(aDados[nX, nI]) + 1 To nAte2
					aAdd(aDados[nX, nI], "")
				Next nJ
			EndIf
		Next nI

		nLinIni := 060
		nColIni := 040
		nColA4  := 000
		nCol2A4 := 000

		If lWeb
			nColMax := 3200
		Endif

		oPrint:StartPage()		// Inicia uma nova pagina
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Box Principal                                                 ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box((nLinIni + 0000)/nTweb, (nColIni + 0000)/nTweb, (nLinIni + nLinMax)/nTweb, (nColIni + nColMax)/nTweb)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega e Imprime Logotipo da Empresa                         ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fLogoEmp(@cFileLogo,, cLogoGH)

		If File(cFilelogo)
			oPrint:SayBitmap((nLinIni + 0050)/nTweb, (nColIni + 0020)/nTweb, cFileLogo, (400)/nTweb, (090)/nTweb) 		// Tem que estar abaixo do RootPath
		EndIf

		If nLayout == 2 // Papél A4
			nColA4    := -0335
		Elseif nLayout == 3// Carta
			nColA4    := -0530
			nCol2A4   := -0400
		Endif
			
			nLinIni += 70
		
			oPrint:Say((nLinIni + 0060)/nTWeb, ((nColIni + nColMax)*0.44)/nTWeb, "GUIA DE HONORÁRIOS", oFont03n,,,, 2) //GUIA DE HONORÁRIOS
			oPrint:Say((nLinIni + 0095)/nTWeb, ((nColIni + nColMax)*0.42)/nTWeb, "(Somente para pacientes internados)", oFont02n,,,, 2) //"(Somente para pacientes internados"
			oPrint:Say((nLinIni + 0080)/nTWeb, (nColMax - 750)/nTWeb, "2- N° Guia no Prestador", oFont01) //2- N?Guia no Prestador
			oPrint:Say((nLinIni + 0075)/nTWeb, (nColMax - 480)/nTWeb, aDados[nX, 02], oFont03n)
			
			oPrint:Box((nLinIni + 0170-nTamBox)/nTWeb, (nColIni + 0020)/nTWeb, (nLinIni + 0250-nTamBox)/nTWeb, ((nColIni + nColMax)*0.15 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0175)/nTWeb, (nColIni + 0030)/nTWeb, "1 - Registro ANS", oFont01) //"1 - Registro ANS"
			oPrint:Say((nLinIni + 0205)/nTWeb, (nColIni + 0040)/nTWeb, Iif(Empty(aDados[nX, 01]),'|___|___|___|___|___|___|',aDados[nX, 01]), oFont04)
			oPrint:Box((nLinIni + 0170-nTamBox)/nTWeb, ((nColIni + nColMax)*0.15)/nTWeb, (nLinIni + 0250-nTamBox)/nTWeb, ((nColIni + nColMax)*0.44- 0010)/nTWeb)
			oPrint:Say((nLinIni + 0175)/nTWeb, ((nColIni + nColMax)*0.15 + 0010)/nTWeb, "3- N?Guia de Solicitação de Internação", oFont01) //"3- N?Guia de Solicitação de Internação"
			oPrint:Say((nLinIni + 0205)/nTWeb, ((nColIni + nColMax)*0.15 + 0020)/nTWeb, Iif(Empty(aDados[nX, 03]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 03]), oFont06)
			oPrint:Box((nLinIni + 0170-nTamBox)/nTWeb, ((nColIni + nColMax)*0.44)/nTWeb, (nLinIni + 0250-nTamBox)/nTWeb, ((nColIni + nColMax)*0.72- 0010)/nTWeb)
			oPrint:Say((nLinIni + 0175)/nTWeb, ((nColIni + nColMax)*0.44 + 0010)/nTWeb, "4 - Senha", oFont01) //"4 - Senha"
			oPrint:Say((nLinIni + 0205)/nTWeb, ((nColIni + nColMax)*0.44 + 0020)/nTWeb, Iif(Empty(aDados[nX, 04]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 04]), oFont06)
			oPrint:Box((nLinIni + 0170-nTamBox)/nTWeb, ((nColIni + nColMax)*0.72)/nTWeb, (nLinIni + 0250-nTamBox)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0175)/nTWeb, ((nColIni + nColMax)*0.72 + 0010)/nTWeb, "5 - Número da Guia Atribuído pela Operadora", oFont01) //"5 - Número da Guia Atribuído pela Operadora"
			oPrint:Say((nLinIni + 0205)/nTWeb, ((nColIni + nColMax)*0.72 + 0020)/nTWeb, Iif(Empty(aDados[nX, 05]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 05]), oFont06)

			AddTBrush(oPrint, (nLinIni + 0257)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 0285)/nTWeb, (nColIni + nColMax)/nTWeb)
			oPrint:Say((nLinIni + 0260)/nTWeb, (nColIni + 0020)/nTWeb, "Dados do Beneficiário", oFont01) //"Dados do Beneficiário"
			oPrint:Box((nLinIni + 0290-nTamBox)/nTWeb, (nColIni + 0020)/nTWeb, (nLinIni + 0370-nTamBox)/nTWeb, ((nColIni + nColMax)*0.35 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0295)/nTWeb, (nColIni + 0030)/nTWeb, "6 - Número da Carteira", oFont01) //"6 - Número da Carteira"
			oPrint:Say((nLinIni + 0325)/nTWeb, (nColIni + 0040)/nTWeb, Iif(Empty(aDados[nX, 06]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 06]), oFont06)
			oPrint:Box((nLinIni + 0290-nTamBox)/nTWeb, ((nColIni + nColMax)*0.35)/nTWeb, (nLinIni + 0370-nTamBox)/nTWeb, ((nColIni + nColMax)*0.9 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0295)/nTWeb, ((nColIni + nColMax)*0.35 + 0010)/nTWeb, "7 - Nome", oFont01) //"7 - Nome"
			oPrint:Say((nLinIni + 0325)/nTWeb, ((nColIni + nColMax)*0.35 + 0020)/nTWeb, aDados[nX, 07], oFont04)
			oPrint:Box((nLinIni + 0290-nTamBox)/nTWeb, ((nColIni + nColMax)*0.9)/nTWeb, (nLinIni + 0370-nTamBox)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0295)/nTWeb, ((nColIni + nColMax)*0.9 + 0010)/nTWeb, "8 - Atendimento a RN", oFont01) //"7 - Nome"
			oPrint:Say((nLinIni + 0325)/nTWeb, ((nColIni + nColMax)*0.9 + 0020)/nTWeb, Iif(Empty(aDados[nX, 08]),'|___|',aDados[nX, 08]), oFont04)

			AddTBrush(oPrint, (nLinIni + 0377)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 0405)/nTWeb, (nColIni + nColMax)/nTWeb)
			oPrint:Say((nLinIni + 0380)/nTWeb, (nColIni + 0020)/nTWeb, "Dados do Contratado (onde foi executado o procedimento)", oFont01) //"Dados do Contratado (onde foi executado o procedimento)"
			oPrint:Box((nLinIni + 0410-nTamBox)/nTWeb, (nColIni + 0020)/nTWeb, (nLinIni + 0490-nTamBox)/nTWeb, ((nColIni + nColMax)*0.25 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0415)/nTWeb, (nColIni + 0030)/nTWeb, "9 - Código na Operadora", oFont01) //"9 - Código na Operadora"
			oPrint:Say((nLinIni + 0445)/nTWeb, (nColIni + 0040)/nTWeb, Iif(Empty(aDados[nX, 09]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 09]), oFont06)
			oPrint:Box((nLinIni + 0410-nTamBox)/nTWeb, ((nColIni + nColMax)*0.25)/nTWeb, (nLinIni + 0490-nTamBox)/nTWeb, ((nColIni + nColMax)*0.85 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0415)/nTWeb, ((nColIni + nColMax)*0.25 + 0010)/nTWeb, "10 - Nome do Hospital/Local", oFont01) //"10 - Nome do Hospital/Local"
			oPrint:Say((nLinIni + 0445)/nTWeb, ((nColIni + nColMax)*0.25 + 0020)/nTWeb, aDados[nX, 10], oFont04)
			oPrint:Box((nLinIni + 0410-nTamBox)/nTWeb, ((nColIni + nColMax)*0.85)/nTWeb, (nLinIni + 0490-nTamBox)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0415)/nTWeb, ((nColIni + nColMax)*0.85 + 0010)/nTWeb, "11 - Código CNES", oFont01) //"11 - Código CNES"
			oPrint:Say((nLinIni + 0445)/nTWeb, ((nColIni + nColMax)*0.85 + 0020)/nTWeb, Iif(Empty(aDados[nX, 11]),'|___|___|___|___|___|___|___|',aDados[nX, 11]), oFont04)

			AddTBrush(oPrint, (nLinIni + 0497)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 0525)/nTWeb, (nColIni + nColMax)/nTWeb)
			oPrint:Say((nLinIni + 0500)/nTWeb, (nColIni + 0020)/nTWeb, "Dados do Contratado Executante", oFont01) //"Dados do Contratado Executante"
			oPrint:Box((nLinIni + 0530-nTamBox)/nTWeb, (nColIni + 0020)/nTWeb, (nLinIni + 0610-nTamBox)/nTWeb, ((nColIni + nColMax)*0.25 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0535)/nTWeb, (nColIni + 0030)/nTWeb, "12 - Código na Operadora", oFont01) //"12 - Código na Operadora"
			oPrint:Say((nLinIni + 0565)/nTWeb, (nColIni + 0040)/nTWeb, Iif(Empty(aDados[nX, 12]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 12]), oFont06)
			oPrint:Box((nLinIni + 0530-nTamBox)/nTWeb, ((nColIni + nColMax)*0.25)/nTWeb, (nLinIni + 0610-nTamBox)/nTWeb, ((nColIni + nColMax)*0.85 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0535)/nTWeb, ((nColIni + nColMax)*0.25 + 0010)/nTWeb, "13 - Nome do Contratado", oFont01) //"13 - Nome do Contratado"
			oPrint:Say((nLinIni + 0565)/nTWeb, ((nColIni + nColMax)*0.25 + 0020)/nTWeb, aDados[nX, 13], oFont04)
			oPrint:Box((nLinIni + 0530-nTamBox)/nTWeb, ((nColIni + nColMax)*0.85)/nTWeb, (nLinIni + 0610-nTamBox)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0535)/nTWeb, ((nColIni + nColMax)*0.85 + 0010)/nTWeb, "14 - Código CNES", oFont01) //"14 - Código CNES"
			oPrint:Say((nLinIni + 0565)/nTWeb, ((nColIni + nColMax)*0.85 + 0020)/nTWeb, Iif(Empty(aDados[nX, 14]),'|___|___|___|___|___|___|___|',aDados[nX, 14]), oFont04)

			nLinIni -= 90

			AddTBrush(oPrint, (nLinIni + 0707)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 0735)/nTWeb, (nColIni + nColMax)/nTWeb)
			oPrint:Say((nLinIni + 0710)/nTWeb, (nColIni + 0020)/nTWeb, "Dados da internação", oFont01) //"Dados da internação"
			oPrint:Box((nLinIni + 0740-nTamBox)/nTWeb, (nColIni + 0020)/nTWeb, (nLinIni + 0820-nTamBox)/nTWeb, ((nColIni + nColMax)*0.18 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0745)/nTWeb, (nColIni + 0030)/nTWeb, "15 - Data do Início do Faturamento", oFont01) //"20 ?Data do Início do Faturamento"
			oPrint:Say((nLinIni + 0775)/nTWeb, (nColIni + 0040)/nTWeb, Iif(Empty(aDados[nX, 15]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 15])), oFont04)
			oPrint:Box((nLinIni + 0740-nTamBox)/nTWeb, ((nColIni + nColMax)*0.18)/nTWeb, (nLinIni + 0820-nTamBox)/nTWeb, ((nColIni + nColMax)*0.36 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0745)/nTWeb, ((nColIni + nColMax)*0.18 + 0010)/nTWeb, "16 - Data do Fim do Faturamento", oFont01) //"21 ?Data do Fim do Faturamento"
			oPrint:Say((nLinIni + 0775)/nTWeb, ((nColIni + nColMax)*0.18 + 0020)/nTWeb, Iif(Empty(aDados[nX, 16]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 16])), oFont04)

			AddTBrush(oPrint, (nLinIni + 0827)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 0855)/nTWeb, (nColIni + nColMax)/nTWeb)
			oPrint:Say((nLinIni + 0830)/nTWeb, (nColIni + 0030)/nTWeb, "Procedimentos Realizados", oFont01) //"Dados da internação"
			oPrint:Box((nLinIni + 0860-nTamBox)/nTWeb, (nColIni + 0020)/nTWeb, (nLinIni + 1400-nTamBox)/nTWeb,(nColIni + nColMax - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0868)/nTWeb, ((nColIni + nColMax)*0.025+ 0030)/nTWeb, "17 - Data", oFont01) //"23 - Data"
			oPrint:Say((nLinIni + 0868)/nTWeb, ((nColIni + nColMax)*0.145+ 0030)/nTWeb, "18 - Hora Inicial", oFont01) //"24 - Hora Inicial"
			oPrint:Say((nLinIni + 0868)/nTWeb, ((nColIni + nColMax)*0.205+ 0030)/nTWeb, "19 - Hora Final", oFont01) //"25 - Hora Final"
			oPrint:Say((nLinIni + 0868)/nTWeb, ((nColIni + nColMax)*0.265+ 0030)/nTWeb, "20 - Tabela", oFont01) //"26 - Tabela"
			oPrint:Say((nLinIni + 0868)/nTWeb, ((nColIni + nColMax)*0.305+ 0030)/nTWeb, "21 - Código do Procedimento", oFont01) //"27 - Código do Procedimento"
			oPrint:Say((nLinIni + 0868)/nTWeb, ((nColIni + nColMax)*0.445+ 0030)/nTWeb, "22 - Descrição", oFont01) //"28 - Descrição"
			oPrint:Say((nLinIni + 0868)/nTWeb, ((nColIni + nColMax)*0.62+ 0030)/nTWeb, "23 - Qtde", oFont01) //"29 - Qtde"
			oPrint:Say((nLinIni + 0868)/nTWeb, ((nColIni + nColMax)*0.665+0030)/nTWeb, "24 - Via", oFont01) //"30 - Via"
			oPrint:Say((nLinIni + 0868)/nTWeb, ((nColIni + nColMax)*0.69+ 0030)/nTWeb, "25 - Tec", oFont01) //"31 - Tec"
			oPrint:Say((nLinIni + 0868)/nTWeb, ((nColIni + nColMax)*0.72+ 0030)/nTWeb, "26 - Fator Red", oFont01) //"32 - Fator Red"
			oPrint:Say((nLinIni + 0886)/nTWeb, ((nColIni + nColMax)*0.727+0030)/nTWeb, "/ Acresc", oFont01) //"/ Acresc"
			oPrint:Say((nLinIni + 0868)/nTWeb, ((nColIni + nColMax)*0.769+0030)/nTWeb, "27 - Valor Unitário - R$", oFont01) //"33 - Valor Unitário - R$"
			oPrint:Say((nLinIni + 0868)/nTWeb, ((nColIni + nColMax)*0.88+ 0030)/nTWeb, "28 - Valor Total - R$", oFont01) //"34-Valor Total ?R$"

			nOldLinIni := nLinIni

			For nI := nIni To nAte
				oPrint:Say((nLinIni + 0912)/nTWeb, ((nColIni + nColMax)*0.01+ 0030)/nTWeb, AllTrim(Str(nI)) + " - ", oFont01)

				oPrint:Say((nLinIni + 0910)/nTWeb, ((nColIni + nColMax)*0.025+ 0030)/nTWeb, Iif(Empty(aDados[nX, 17, nI]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 17, nI])), oFont06)
				oPrint:Say((nLinIni + 0910)/nTWeb, ((nColIni + nColMax)*0.145+ 0030)/nTWeb, IIf(Empty(aDados[nX, 18, nI]), "|___|___|:|___|___|", Transform(aDados[nX, 18, nI], "@R 99:99")), oFont06)
				oPrint:Say((nLinIni + 0910)/nTWeb, ((nColIni + nColMax)*0.205+ 0030)/nTWeb, IIf(Empty(aDados[nX, 19, nI]), "|___|___|:|___|___|", Transform(aDados[nX, 19, nI], "@R 99:99")), oFont06)
				oPrint:Say((nLinIni + 0910)/nTWeb, ((nColIni + nColMax)*0.265+ 0030)/nTWeb, Iif(Empty(aDados[nX, 20, nI]),'|___|___|',aDados[nX, 20, nI]), oFont06)
				oPrint:Say((nLinIni + 0910)/nTWeb, ((nColIni + nColMax)*0.305+ 0030)/nTWeb, Iif(Empty(aDados[nX, 21, nI]),'|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 21, nI]), oFont06)
				oPrint:Say((nLinIni + 0910)/nTWeb, ((nColIni + nColMax)*0.445+ 0030)/nTWeb, Iif(Empty(aDados[nX, 22, nI]),REPLICATE('_',45),aDados[nX, 22, nI]), oFont06)
				oPrint:Say((nLinIni + 0910)/nTWeb, ((nColIni + nColMax)*0.62+ 0030)/nTWeb, IIf(Empty(aDados[nX, 23, nI]), "|___|___|___|", Transform(aDados[nX, 23, nI], "@E 999")), oFont06,,,,1)
				oPrint:Say((nLinIni + 0910)/nTWeb, ((nColIni + nColMax)*0.665+0030)/nTWeb, Iif(Empty(aDados[nX, 24, nI]),'|___|',aDados[nX, 24, nI]), oFont06)
				oPrint:Say((nLinIni + 0910)/nTWeb, ((nColIni + nColMax)*0.69+ 0030)/nTWeb, Iif(Empty(aDados[nX, 25, nI]),'|___|',aDados[nX, 25, nI]), oFont06,,,,1)
				oPrint:Say((nLinIni + 0910)/nTWeb, ((nColIni + nColMax)*0.72+ 0030)/nTWeb, IIf(Empty(aDados[nX, 26, nI]), "|___|,|___|___|", Transform(aDados[nX, 26, nI], "@E 9.99")), oFont06,,,,1)
				oPrint:Say((nLinIni + 0910)/nTWeb, ((nColIni + nColMax)*0.769+0030)/nTWeb, IIf(Empty(aDados[nX, 27, nI]), "|___|___|___|___|___|___|,|___|___|", Transform(aDados[nX, 27, nI], "@E 99,999,999.99")), oFont06,,,,1)
				oPrint:Say((nLinIni + 0910)/nTWeb, ((nColIni + nColMax)*0.88+ 0030)/nTWeb, IIf(Empty(aDados[nX, 28, nI]), "|___|___|___|___|___|___|,|___|___|", Transform(aDados[nX, 28, nI], "@E 99,999,999.99")), oFont06,,,,1)
				nLinIni += 50
			Next nI

			nLinIni := nOldLinIni

			nIni		:= nAte + 1
			If nAte < Len(aDados[nX][17])
				lImpNovo 	:= .T.
				nAte		+= 10
			EndIf

			nLinIni -= 100

			AddTBrush(oPrint, (nLinIni + 1507)/nTWeb,( nColIni + 0010)/nTWeb, (nLinIni + 1535)/nTWeb, (nColIni + nColMax)/nTWeb)
			oPrint:Say((nLinIni + 1510)/nTWeb, (nColIni + 0020)/nTWeb, "Identificação do(s) Profissional(is) Executante(s)", oFont01) //"Identificação do(s) Profissional(is) Executante(s)"
			oPrint:Box((nLinIni + 1540-nTamBox)/nTWeb, (nColIni + 0020)/nTWeb, (nLinIni + 1900-nTamBox)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
			oPrint:Say((nLinIni + 1555)/nTWeb, (nColIni + 0030)/nTWeb, "29-Seq. Ref", oFont01) //"29-Seq. Ref"
			oPrint:Say((nLinIni + 1555)/nTWeb, ((nColIni + nCOlMax)*0.05+ 0030)/nTWeb, "30-Grau Part.", oFont01) //"30-Grau Part."
			oPrint:Say((nLinIni + 1555)/nTWeb, ((nColIni + nCOlMax)*0.10+ 0030)/nTWeb, "31-Còdigo na Operadora/CPF", oFont01) //"31-Còdigo na Operadora/CPF"
			oPrint:Say((nLinIni + 1555)/nTWeb, ((nColIni + nCOlMax)*0.29+ 0030)/nTWeb, "32-Nome do Profissional", oFont01) //"32-Nome do Profissional"
			oPrint:Say((nLinIni + 1555)/nTWeb, ((nColIni + nCOlMax)*0.6+ 0030)/nTWeb, "33-Conselho", oFont01) //"33-Conselho"
			oPrint:Say((nLinIni + 1575)/nTWeb, ((nColIni + nCOlMax)*0.6+ 0030)/nTWeb, "Profissional", oFont01) //"Profissional"
			oPrint:Say((nLinIni + 1555)/nTWeb, ((nColIni + nCOlMax)*0.65+ 0030)/nTWeb, "34-Número do Conselho", oFont01) //"34-Número do Conselho"
			oPrint:Say((nLinIni + 1555)/nTWeb, ((nColIni + nCOlMax)*0.85+ 0030)/nTWeb, "35-UF", oFont01) //"35-UF"
			oPrint:Say((nLinIni + 1555)/nTWeb, ((nColIni + nCOlMax)*0.89+ 0030)/nTWeb, "36-Código CBO", oFont01) //"36-Código CBO"

			nOldLinIni := nLinIni

			For nI := nIni2 To nAte2
			
				oPrint:Say((nLinIni + 1600)/nTWeb, (nColIni + 0030)/nTWeb, Iif(Empty(aDados[nX, 29, nI]),'|___|___|',AllTrim(aDados[nX, 29, nI])), oFont06)
				oPrint:Say((nLinIni + 1600)/nTWeb, ((nColIni + nColMax)*0.05+ 0030)/nTWeb, Iif(Empty(aDados[nX, 30, nI]),'|___|___|',aDados[nX, 30, nI]), oFont06)
				oPrint:Say((nLinIni + 1600)/nTWeb, ((nColIni + nColMax)*0.10+ 0030)/nTWeb, Iif(Empty(aDados[nX, 31, nI]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 31, nI]), oFont06)
				oPrint:Say((nLinIni + 1600)/nTWeb, ((nColIni + nColMax)*0.29+ 0030)/nTWeb, Iif(Empty(aDados[nX, 32, nI]),REPLICATE('_',80),aDados[nX, 32, nI]), oFont06)
				oPrint:Say((nLinIni + 1600)/nTWeb, ((nColIni + nColMax)*0.60+ 0030)/nTWeb, Iif(Empty(aDados[nX, 33, nI]),'|___|___|',aDados[nX, 33, nI]), oFont06)
				oPrint:Say((nLinIni + 1600)/nTWeb, ((nColIni + nColMax)*0.65+ 0030)/nTWeb, Iif(Empty(aDados[nX, 34, nI]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 34, nI]), oFont06)
				oPrint:Say((nLinIni + 1600)/nTWeb, ((nColIni + nColMax)*0.85+ 0030)/nTWeb, Iif(Empty(aDados[nX, 35, nI]),'|___|___|',aDados[nX, 35, nI]), oFont06)
				oPrint:Say((nLinIni + 1600)/nTWeb, ((nColIni + nColMax)*0.89+ 0030)/nTWeb, Iif(Empty(aDados[nX, 36, nI]),'|___|___|___|___|___|___|',aDados[nX, 36, nI]), oFont06)
				

				nLinIni += 50
			Next nI

			nLinIni := nOldLinIni

			nIni2		:= nAte2 + 1
			If nAte2 < Len(aDados[nX][29])
				lImpNovo 	:= .T.
				nAte2		+= 5
			EndIf

			nLinIni += 410

			AddTBrush(oPrint, (nLinIni + 1510)/nTWeb, (nColIni + 0020)/nTWeb, (nLinIni + 1800)/nTWeb, ((nColIni + nColMax)*0.85 - 0010)/nTWeb)
			oPrint:Box((nLinIni + 1510-nTamBox)/nTWeb, (nColIni + 0020)/nTWeb, (nLinIni + 1800-nTamBox)/nTWeb, ((nColIni + nColMax)*0.85 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 1515)/nTWeb, (nColIni + 0030)/nTWeb, "37- Observação / Justificativa", oFont01) //"35- Observação / Justificativa"

			nOldLinIni := nLinIni
			If !Empty(aDados[nX, 37])
				For nI := 1 To MlCount(aDados[nX, 37], 100)
					cObs := MemoLine(aDados[nX, 37], 100, nI)
					oPrint:Say((nLinIni + 1545)/nTWeb, (nColIni + 0040)/nTWeb, strtran(cObs,char(10)," "), oFont04)
					nLinIni += 50
				Next nI
			Else
				oPrint:Say((nLinIni + 1545)/nTWeb, (nColIni + 0040)/nTWeb, REPLICATE('_',220), oFont06)
				oPrint:Say((nLinIni + 1595)/nTWeb, (nColIni + 0040)/nTWeb, REPLICATE('_',220), oFont06)
				oPrint:Say((nLinIni + 1645)/nTWeb, (nColIni + 0040)/nTWeb, REPLICATE('_',220), oFont06)
			EndIf			
				
			nLinIni := nOldLinIni

			oPrint:Box((nLinIni + 1510-nTamBox)/nTWeb, ((nColIni + nColMax)*0.85)/nTWeb, (nLinIni + 1590-nTamBox)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
			oPrint:Say((nLinIni + 1515)/nTWeb, ((nColIni + nColMax)*0.85 + 0010)/nTWeb, "38 - Valor total dos honorários", oFont01) //"36 - Valor total dos honorários"
			oPrint:Say((nLinIni + 1545)/nTWeb, ((nColIni + nColMax)*0.85 + 0020)/nTWeb, IIf(Empty(aDados[nX, 38]), "|___|___|___|___|___|___|___|___|,|___|___|", Transform(aDados[nX, 38], "@E 99,999,999.99")), oFont06)

			oPrint:Box((nLinIni + 1810-nTamBox)/nTWeb, (nColIni + 0020)/nTWeb, (nLinIni + 1900-nTamBox)/nTWeb, ((nColIni + nColMax)*0.2 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 1815)/nTWeb, (nColIni + 0030)/nTWeb, "39 - Data de emissão", oFont01) //"37 - Data de emissão"
			oPrint:Say((nLinIni + 1845)/nTWeb, (nColIni + 0040)/nTWeb, Iif(Empty(aDados[nX, 39]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 39])), oFont04)
			oPrint:Box((nLinIni + 1810-nTamBox)/nTWeb, ((nColIni + nColMax)*0.2)/nTWeb, (nLinIni + 1900-nTamBox)/nTWeb, ((nColIni + nColMax)*0.85 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 1815)/nTWeb, ((nColIni + nColMax)*0.2 + 0010)/nTWeb, "40 - Assinatura do Profissional Executante", oFont01) //"38 - Assinatura do Profissional Executante"

			oPrint:EndPage()	// Finaliza a pagina
		
	End

Next nX

	//END SEQUENCE
	//ErrorBlock( bError )

If !Empty(cErro)
	cArq := "erro_imp_relat_" + DtoS(Date()) + StrTran(Time(),":") + ".txt"
	MsgAlert("Erro ao gerar relatório. Visualize o log em /LOGPLS/" + cArq )
	cErro := 	"Erro ao carregar dados do relatório." + CRLF + ;
		"Verifique a cfg. de impressão da guia no cadastro de " + CRLF + ;
		"Tipos de Guias." + CRLF + CRLF + ;
		cErro
	PLSLogFil(cErro,cArq)
EndIf

If lGerTXT .OR. lWeb
	oPrint:Print()		// Imprime Relatorio
Else
	oPrint:Preview()	// Visualiza impressao grafica antes de imprimir
EndIf

Return cFileName

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ?PLTRADIO?Autor ?Bruno Iserhardt       ?Data ?06.02.14 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ?Estrutura Relatório TISS 3 (Anexo de Solicitacao de         ³±?
±±?         ?Radioterapia)                                               ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?SigaPLS                                                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros?aDados - Array com as informações do relat´rio              ³±?
±±?         ?nLayout - Define o formato de papél para impressao:         ³±?
±±?         ?          1 - Formato Ofício II (216x330mm)                 ³±?
±±?         ?          2 - Formato A4 (210x297mm)                        ³±?
±±?         ? 		 3 - Formato Carta (216x279mm)     			       ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLTRADIO(aDados, nLayout, cLogoGH,lWeb, cPathRelW, lUnicaImp)

Local nLinMax
Local nColMax
Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
Local nOldLin	:=	0
Local nColA4    := 	0
Local nWeb		:=  0
Local cFileLogo
Local lPrinter := .F.
Local lImpNovo := .T.
Local nI, nJ, nN, nV
Local nX, nX1, nCount
Local oFont01
Local oFont02n
Local oFont03n
Local oFont04
Local oFont06
Local cObs
Local cRel      := "guiaradi"
Local cPathSrvJ := GETMV("MV_RELT")
Local nTweb		:= 1
Local nLweb		:= 0
Local nLwebC	:= 0
Local oPrint	:= NIL

Default lUnicaImp := .F.
Default lWeb    := .F.
Default cPathRelW := ''
Default nLayout := 2
Default cLogoGH := ''
Default	aDados  := { {;
	"123456",; //1 - Registro ANS
	{"01234567890123456789"},; //2 - N Guia no Prestador
	{"01234567890123456789"},; //3 - Numero da Guia Referenciada
	{"01234567890123456789"},; //4 - Senha
	{CtoD("06/02/14")},; //5 - Data da Autorizacao
	{"01234567890123456789"},; //6 - Numero da Guia Atribuido pela Operadora
	{"01234567890123456789"},; //7 - Número da Carteira
	{Replicate("M", 70)},; //8 - Nome
	{999},; //9 - Idade
	{"M"},; //10 - Sexo
	{Replicate("M", 70)},; //11 - Nome do Profissional Solicitante
	{"01234567890"},; //12 - Telefone
	{Replicate("M", 60)},; //13 - E-mail
	{CtoD("06/02/2014")},; //14 - Data do diagnóstico
	{"1111"},; //15 - CID 10 Principal
	{"2222"},; //16 - CID 10 (2)
	{"3333"},; //17 - CID 10 (3)
	{"4444"},; //18 - CID 10 (4)
	{"1"},; //19 - Diagnóstico por Imagem
	{"2"},; //20 - Estadiamento
	{"3"},; //21 - ECOG
	{"4"},; //22 - Finalidade
	{Replicate("M", 1000)},; //23 - Diagnóstico Cito/Histopatológico
	{Replicate("M", 1000)},; //24 - Informações relevantes
	{Replicate("M", 40)},; //25 - Cirurgia
	{CtoD("06/02/2014")},; //26 - Data da Realização
	{Replicate("M", 40)},; //27 - Quimioterapia
	{CtoD("06/02/2014")},; //28 - Data da Aplicação
	{111},; //29 - Número de Campos
	{2222},; //30 - Dose por dia (em Gy)
	{3333},; //31 - Dose Total ( em Gy)
	{444},; //32 - Número de Dias
	{CtoD("06/02/2014")},; //33 - Data Prevista para Início da Administração
	{Replicate("M", 500)},; //34-Observação/Justificativa
	{CtoD("06/02/2014")},; //35 - Data da Solicitação
	{},; //36-Assinatura do Profissional Solicitante
	{} } } //37-Assinatura do Autorizador da Operadora

	If nLayout  == 1 // Ofício 2
		nLinMax := 2435
		nColMax := 3705
	Elseif nLayout == 2   // Papél A4
		nLinMax	:=	2275
		nColMax	:=	3270
	Else //Carta
		nLinMax	:=	2435
		nColMax	:=	3175
	Endif

	oFont01		:= TFont():New("Arial",  5,  5, , .F., , , , .T., .F.) // Normal
	if nLayout == 1 // Oficio 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
		oFont05		:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
	Else  // Papél A4 ou Carta
		oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
		oFont05		:= TFont():New("Arial", 07, 07, , .F., , , , .T., .F.) // Normal
	Endif
	oFont06		:= TFont():New("Arial", 06, 06, , .F., , , , .T., .F.) // Normal

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Nao permite acionar a impressao quando for na web.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If lWeb
		cPathSrvJ := cPathRelW
		cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
	Else
		cFileName := cRel+CriaTrab(NIL,.F.)
	EndIf
	
	if !lWeb
		oPrint	:= TMSPrinter():New("ANEXO DE SOLICITAÇÃO DE RADIOTERAPIA") //ANEXO DE SOLICITAÇÃO DE RADIOTERAPIA
	else
		oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ	 ,.T.,	,@oPrint,			  ,			  ,	.F.			,.f.)
		If lSrvUnix
			AjusPath(@oPrint)
		EndIf
		oPrint:cPathPDF := cPathSrvJ
		nTweb		:= 3.9
		nLweb		:= 10
		nLwebC		:= -3
		nWeb		:= 25
		nColMax		:= 3100
		oPrint:lServer := lWeb
	Endif

	oPrint:SetLandscape()		// Modo paisagem
	
	if nLayout ==2
		oPrint:SetPaperSize(9)// Papél A4
	Elseif nLayout ==3
		oPrint:SetPaperSize(1)// Papél Carta
	Else
		oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Device
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If lWeb
		oPrint:setDevice(IMP_PDF)
	Else
		// Verifica se existe alguma impressora configurada para Impressao Grafica
		lPrinter := oPrint:IsPrinterActive()
		IF lPrinter
			lPrinter := IIF(GETNEWPAR("MV_IMPATIV", .F.), .F., .T.)	//	Define se ir?alterar a Impressora Ativa
		ENDIF
		If ! lPrinter
			oPrint:Setup()
		EndIf
	Endif

For nX := 1 To Len(aDados)

	If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
		Loop
	EndIf

	For nX1 := 1 To Len(aDados[nX, 02])

		nAte := 12
		nV := 1

		//Esta parte do código faz com que
		//imprima mais de uma guia.
		//INICIO
		If lUnicaImp
			If nX1 <= Len(aDados) 
				lImpNovo := .T.
			EndIf
		EndIf
		//FIM

		While lImpNovo

			lImpNovo := .F.

			nLinIni  := 080
			nColIni  := 080
			nColA4   := 000

			oPrint:StartPage()		// Inicia uma nova pagina
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Box Principal                                                 ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:Box((nLinIni + 0000)/nTweb, (nColIni + 0000)/nTweb, (nLinIni + nLinMax)/nTweb, (nColIni + nColMax)/nTweb)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrega e Imprime Logotipo da Empresa                         ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fLogoEmp(@cFileLogo,, cLogoGH)

			If File(cFilelogo)
				oPrint:SayBitmap((nLinIni + 0050)/nTweb, (nColIni + 0020)/nTweb, cFileLogo, (400)/nTweb, (090)/nTweb) 		// Tem que estar abaixo do RootPath
			EndIf

			If nLayout == 2 // Papél A4
				nColA4    := -0335
			Elseif nLayout == 3// Carta
				nColA4    := -0530
			Endif

			oPrint:Say((nLinIni + 0080)/nTweb, ((nColIni + nColMax)*0.47)/nTweb, "ANEXO DE SOLICITAÇÃO DE RADIOTERAPIA", oFont02n,,,, 2) //ANEXO DE SOLICITAÇÃO DE RADIOTERAPIA
			oPrint:Say((nLinIni + 0090)/nTweb, (nColMax - 750)/nTweb, "2- N?Guia no Prestador", oFont01) //2- N?Guia no Prestador
			oPrint:Say((nLinIni + 0070)/nTweb, (nColMax - 480)/nTweb, aDados[nX, 02, nX1], oFont03n)

				//fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 40, 80)
			oPrint:Box((nLinIni + 0175 -nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 0269-nWeb)/nTweb, ((nColIni + nColMax)*0.065 - 0010)/nTweb)
			oPrint:Say((nLinIni + 0180)/nTweb, (nColIni + 0015)/nTweb, "1 - Registro ANS", oFont01) //1 - Registro ANS
			oPrint:Say((nLinIni + 0220)/nTweb, (nColIni + 0030)/nTweb, Iif(Empty(aDados[nX, 01]),'|___|___|___|___|___|___|',aDados[nX, 01]), oFont06)
			
			oPrint:Box((nLinIni + 0175-nWeb)/nTweb, ((nColIni + nColMax)*0.065)/nTweb, (nLinIni + 0269-nWeb)/nTweb, ((nColIni + nColMax)*0.325 - 0010)/nTweb)
			oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.065 + 0006)/nTweb, "3 - Número da Guia Referenciada", oFont01) //3 - Número da Guia Referenciada
			oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.065 + 0006)/nTweb, Iif(Empty(aDados[nX, 03, nX1]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 03, nX1]), oFont06)
			
			oPrint:Box((nLinIni + 0175-nWeb)/nTweb, ((nColIni + nColMax)*0.325)/nTweb, (nLinIni + 0269-nWeb)/nTweb, ((nColIni + nColMax)*0.595 - 0010)/nTweb)
			oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.325 + 0020)/nTweb, "4 - Senha", oFont01) //4 - Senha
			oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.325 + 0020)/nTweb, Iif(Empty(aDados[nX, 04, nX1]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 04, nX1]), oFont06)
			
			oPrint:Box((nLinIni + 0175-nWeb)/nTweb, ((nColIni + nColMax)*0.595)/nTweb, (nLinIni + 0269-nWeb)/nTweb, ((nColIni + nColMax)*0.73 - 0010)/nTweb)
			oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.595 + 0030)/nTweb, "5 - Data da Autorização", oFont01) //5 - Data da Autorização
			oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.595 + 0030)/nTweb, Iif(Empty(aDados[nX, 05, nX1]),'|___|___|/|___|___|/|___|___|___|___|',DToC(aDados[nX, 05, nX1])), oFont06)
			
			oPrint:Box((nLinIni + 0175-nWeb)/nTweb, ((nColIni + nColMax)*0.73)/nTweb, (nLinIni + 0269-nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.73 + 0020)/nTweb, "6 - Número da Guia Atribuído pela Operadora", oFont01) //6 - Número da Guia Atribuído pela Operadora
			oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.73 + 0020)/nTweb, Iif(Empty(aDados[nX, 06, nX1]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 06, nX1]), oFont06)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 80)
			AddTBrush(oPrint, (nLinIni + 175)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 206)/nTweb, (nColIni + nColMax)/nTweb)
			oPrint:Say((nLinIni + 178)/nTweb, (nColIni + 0020)/nTweb, "Dados do Beneficiário", oFont01) //Dados do Prestador
			oPrint:Box((nLinIni + 208-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.35 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, (nColIni + 0020)/nTweb, "7 - Número da Carteira", oFont01) //7 - Número da Carteira
			oPrint:Say((nLinIni + 252)/nTweb, (nColIni + 0030)/nTweb, Iif(Empty(aDados[nX, 07, nX1]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 07, nX1]), oFont06)
			oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.35)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.85 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.35 + 0020)/nTweb, "8 - Nome", oFont01) //8 - Nome
			oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.35 + 0030)/nTweb, aDados[nX, 08, nX1], oFont04)
			oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.85 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.92 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.85 + 0020)/nTweb, "9 - Idade", oFont01) //12 - Idade
			oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.85 + 0030)/nTweb, Iif(Empty(aDados[nX, 9, nX1]),'|___|___|___|',Transform(aDados[nX, 9, nX1], "@E 999")), oFont06)
			oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.92 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.92 + 0020)/nTweb, "10 - Sexo", oFont01) //13 - Sexo
			oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.92 + 0030)/nTweb, Iif(Empty(aDados[nX, 10, nX1]),'|___|',aDados[nX, 10, nX1]), oFont06)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 130, 80)
			AddTBrush(oPrint,  (nLinIni + 174)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 205)/nTweb, (nColIni + nColMax)/nTweb)
			oPrint:Say((nLinIni + 178)/nTweb, (nColIni + 0020)/nTweb, "Dados do Profissional Solicitante", oFont01) //Dados do Profissional Solicitante
			
			oPrint:Box((nLinIni + 208-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.45 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, (nColIni + 0020)/nTweb, "11 - Nome do Profissional Solicitante", oFont01) //14 - Nome do Profissional Solicitante
			oPrint:Say((nLinIni + 252)/nTweb, (nColIni + 0030)/nTweb, aDados[nX, 11, nX1], oFont04)
			
			oPrint:Box((nLinIni + 209-nWeb)/nTweb, ((nColIni + nColMax)*0.45)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.65 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.45 + 0020)/nTweb, "12 - Telefone", oFont01) //15 - Telefone
			oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.45 + 0030)/nTweb, Iif(Empty(aDados[nX, 12, nX1]),'(|___|___|)|___|___|___|___|___|-|___|___|___|___|',aDados[nX, 12, nX1]), oFont06)
			
			oPrint:Box((nLinIni + 210-nWeb)/nTweb, ((nColIni + nColMax)*0.65)/nTweb, (nLinIni + 300-nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.65 + 0020)/nTweb, "13 - E-mail", oFont01) //16 - E-mail
			oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.65 + 0030)/nTweb, aDados[nX, 13, nX1], oFont04)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 130, 80)
			AddTBrush(oPrint, (nLinIni + 174)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 205)/nTweb, (nColIni + nColMax)/nTweb)
			oPrint:Say((nLinIni + 178)/nTweb, (nColIni + 0020)/nTweb, "Diagnóstico Oncológico", oFont01) //Diagnóstico Oncológico
			oPrint:Box((nLinIni + 208-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.15 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, (nColIni + 0020)/nTweb, "14 - Data do diagnóstico", oFont01) //14 - Data do diagnóstico
			oPrint:Say((nLinIni + 252)/nTweb, (nColIni + 0030)/nTweb, Iif(Empty(aDados[nX, 14, nX1]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 14, nX1])), oFont06)
			AddTBrush(oPrint, (nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.15)/nTweb, (nLinIni + 300)/nTweb, ((nColIni + nColMax)*0.23 - 0010)/nTweb)
			oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.15)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.24 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.15 + 0020)/nTweb, "15 - CID 10 Principal (opcional)", oFont01) //15 - CID 10 Principal
			oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.15 + 0030)/nTweb, Iif(Empty(aDados[nX, 15, nX1]),'|___|___|___|___|',aDados[nX, 15, nX1]), oFont06)
			AddTBrush(oPrint, (nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.24)/nTweb, (nLinIni + 300)/nTweb, ((nColIni + nColMax)*0.31 - 0010)/nTweb)
			oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.24)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.31 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.24 + 0015)/nTweb, "16 - CID 10 (2)(opcional)", oFont01) //16 - CID 10 (2)
			oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.24 + 0025)/nTweb, Iif(Empty(aDados[nX, 16, nX1]),'|___|___|___|___|',aDados[nX, 16, nX1]), oFont06)
			AddTBrush(oPrint, (nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.31)/nTweb, (nLinIni + 300)/nTweb, ((nColIni + nColMax)*0.39 - 0010)/nTweb)
			oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.31)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.39 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.31 + 0020)/nTweb, "17 - CID 10 (3)(opcional)", oFont01) //17 - CID 10 (3)
			oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.31 + 0030)/nTweb, Iif(Empty(aDados[nX, 17, nX1]),'|___|___|___|___|',aDados[nX, 17, nX1]), oFont06)
			AddTBrush(oPrint, (nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.39)/nTweb, (nLinIni + 300)/nTweb, ((nColIni + nColMax)*0.47 - 0010)/nTweb)
			oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.39)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.47 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.39 + 0020)/nTweb, "18 - CID 10 (4)(opcional)", oFont01) //18 - CID 10 (4)
			oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.39 + 0030)/nTweb, Iif(Empty(aDados[nX, 18, nX1]),'|___|___|___|___|',aDados[nX, 18, nX1]), oFont06)
			oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.47)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.59 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.47 + 0020)/nTweb, "19 - Diagnóstico por Imagem", oFont01) //19 - Diagnóstico por Imagem
			oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.47 + 0030)/nTweb, Iif(Empty(aDados[nX, 19, nX1]),'|___|',aDados[nX, 19, nX1]), oFont06)
			oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.59)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.69 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.59 + 0020)/nTweb, "20 - Estadiamento", oFont01) //20 - Estadiamento
			oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.59 + 0030)/nTweb, Iif(Empty(aDados[nX, 20, nX1]),'|___|',aDados[nX, 20, nX1]), oFont06)
			oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.69)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.79 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.69 + 0020)/nTweb, "21 - ECOG", oFont01) //21 - ECOG
			oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.69 + 0030)/nTweb, Iif(Empty(aDados[nX, 21, nX1]),'|___|',aDados[nX, 21, nX1]), oFont06)
			oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.79)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.89 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.79 + 0020)/nTweb, "22 - Finalidade", oFont01) //22 - Finalidade
			oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.79 + 0030)/nTweb, Iif(Empty(aDados[nX, 22, nX1]),'|___|',aDados[nX, 22, nX1]), oFont06)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 80)

			nOldLin := nLinIni

			oPrint:Box((nLinIni + 208-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 900-nWeb)/nTweb, ((nColIni + nColMax)*0.4 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, (nColIni + 0020)/nTweb, "23 - Diagnóstico Cito/Histopatológico", oFont01) //23 - Diagnóstico Cito/Histopatológico
			For nI := 1 To MlCount(aDados[nX, 23, nX1], 110)
				cObs := MemoLine(aDados[nX, 23, nX1], 110, nI)
				oPrint:Say((nLinIni + 254)/nTweb, (nColIni + 0020)/nTweb, cObs, oFont01)
				nLinIni += 30
			Next nI

			nLinIni := nOldLin

			oPrint:Box((nLinIni + 208-nWeb)/nTweb, ((nColIni + nColMax)*0.4 + 0010)/nTweb, (nLinIni + 900-nWeb)/nTweb, ((nColIni + nColMax)*0.8 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.4 + 0020)/nTweb, "24 - Informações relevantes", oFont01) //24 - Informações relevantes
			For nI := 1 To MlCount(aDados[nX, 24, nX1], 120)
				cObs := MemoLine(aDados[nX, 24, nX1], 120, nI)
				oPrint:Say((nLinIni + 254)/nTweb, ((nColIni + nColMax)*0.4 + 0020)/nTweb, cObs, oFont01)
				nLinIni += 30
			Next nI

			nLinIni := nOldLin

			AddTBrush(oPrint,  (nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.8)/nTweb, (nLinIni + 240)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say((nLinIni + 208)/nTweb, ((nColIni + nColMax)*0.8 + 0010)/nTweb, "Tratamentos Anteriores", oFont01) //Tratamentos Anteriores

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 40, 80)
			oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.8)/nTweb, (nLinIni + 380-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
			oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.8 + 0020)/nTweb, "25 - Cirurgia", oFont01) //36- Cirurgia

			For nI := 1 To MlCount(aDados[nX, 25, nX1], 30)
				cObs := MemoLine(aDados[nX, 25, nX1], 30, nI)
				oPrint:Say((nLinIni + 240)/nTweb, ((nColIni + nColMax)*0.8 + 0030)/nTweb, cObs, oFont04)
				nLinIni += 30
				If nI == 5
					exit
				Endif
			Next nI

			nLinIni := 670

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 80)
			oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.8)/nTweb, (nLinIni + 280-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
			oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.8 + 0020)/nTweb, "26 - Data da Realização", oFont01) //26 - Data da Realização
			oPrint:Say((nLinIni + 235)/nTweb, ((nColIni + nColMax)*0.8 + 0030)/nTweb, Iif(Empty(aDados[nX, 26, nX1]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 26, nX1])), oFont06)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 90, 80)
			oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.8)/nTweb, (nLinIni + 380-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
			oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.8 + 0020)/nTweb, "27 - Quimioterapia", oFont01) //27 - Quimioterapia

			For nI := 1 To MlCount(aDados[nX, 27, nX1], 30)
				cObs := MemoLine(aDados[nX, 27, nX1], 30, nI)
				oPrint:Say((nLinIni + 240)/nTweb, ((nColIni + nColMax)*0.8 + 0030)/nTweb, cObs, oFont04)
				nLinIni += 30
				If nI == 5
					exit
				Endif
			Next nI

			nLinIni := 960

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 80)
			oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.8)/nTweb, (nLinIni + 290-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
			oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.8 + 0020)/nTweb, "28 - Data da Aplicação", oFont01) //28 - Data da Aplicação
			oPrint:Say((nLinIni + 235)/nTweb, ((nColIni + nColMax)*0.8 + 0030)/nTweb, Iif(Empty(aDados[nX, 28, nX1]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 28, nX1])), oFont06)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 200, 80)


			If nAte < Len(aDados[nX, 29])
				lImpNovo := .T.
				nAte += 12
				nV := nN
			EndIf

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 40, 80)

			oPrint:Box((nLinIni + 204-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.12 - 0010)/nTweb)
			oPrint:Say((nLinIni + 214)/nTweb, (nColIni + 0020)/nTweb, "29 - Número de Campos", oFont01) //29 - Número de Campos
			oPrint:Say((nLinIni + 254)/nTweb, (nColIni + 0030)/nTweb, IIf(Empty(aDados[nX, 29, nX1]), "|___|___|___|", Transform(aDados[nX, 29, nX1], "@E 999")), oFont06)
			oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.12 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.22 - 0010)/nTweb)
			oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.12 + 0020)/nTweb, "30 - Dose por dia (em Gy)", oFont01) //30 - Dose por dia (em Gy)
			oPrint:Say((nLinIni + 254)/nTweb, ((nColIni + nColMax)*0.12 + 0030)/nTweb, IIf(Empty(aDados[nX, 30, nX1]), "|___|___|___|___|", Transform(aDados[nX, 30, nX1], "@E 9999")), oFont06)
			oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.22 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.32 - 0010)/nTweb)
			oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.22 + 0020)/nTweb, "31 - Dose Total ( em Gy)", oFont01) //31 - Dose Total ( em Gy)
			oPrint:Say((nLinIni + 254)/nTweb, ((nColIni + nColMax)*0.22 + 0030)/nTweb, IIf(Empty(aDados[nX, 31, nX1]), "|___|___|___|___|", Transform(aDados[nX, 31, nX1], "@E 9999")), oFont06)
			oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.32 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.40 - 0010)/nTweb)
			oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.32 + 0020)/nTweb, "32 - Número de Dias", oFont01) //32 - Número de Dias
			oPrint:Say((nLinIni + 254)/nTweb, ((nColIni + nColMax)*0.32 + 0030)/nTweb, IIf(Empty(aDados[nX, 32, nX1]), "|___|___|___|", Transform(aDados[nX, 32, nX1], "@E 999")), oFont06)
			oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.40 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.58 - 0010)/nTweb)
			oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.40 + 0020)/nTweb, "33 - Data Prevista para Início da Administração", oFont01) //33 - Data Prevista para Início da Administração
			oPrint:Say((nLinIni + 254)/nTweb, ((nColIni + nColMax)*0.40 + 0030)/nTweb, Iif(Empty(aDados[nX, 33, nX1]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 33, nX1])), oFont06)
			nLinIni := 1350 
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 80)
			AddTBrush(oPrint,  (nLinIni + 204)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 400)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
			oPrint:Box((nLinIni + 204-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 400-nWeb)/nTweb, ((nColIni + nColMax) - 0010)/nTweb)
			oPrint:Say((nLinIni + 204)/nTweb, (nColIni + 0020)/nTweb, "34 - Observação / Justificativa", oFont01) //34 - Observação / Justificativa

			nOldLin := nLinIni
			
			For nI := 1 To MlCount(aDados[nX, 34, nX1], 235)
				cObs := MemoLine(aDados[nX, 34, nX1], 235, nI)
				oPrint:Say((nLinIni + 235)/nTweb, (nColIni + 0030)/nTweb, cObs, oFont04)
				nLinIni += 30
				If nI == 5
					exit
				Endif
			Next nI

			nLinIni := nOldLin

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 230, 80)
			oPrint:Box((nLinIni + 204-nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.17 - 0010)/nTweb)
			oPrint:Say((nLinIni + 214)/nTweb, (nColIni + 0020)/nTweb, "35 - Data da Solicitação", oFont01) //35 - Data da Solicitação
			oPrint:Say((nLinIni + 254)/nTweb, (nColIni + 0030)/nTweb, Iif(Empty(aDados[nX, 35, nX1]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 35, nX1])), oFont06)
			oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.17 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, ((nColIni + nColMax)*0.55 - 0010)/nTweb)
			oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.17 + 0020)/nTweb, "36-Assinatura do Profissional Solicitante", oFont01) //36-Assinatura do Profissional Solicitante
			oPrint:Box((nLinIni + 204-nWeb)/nTweb, ((nColIni + nColMax)*0.55 + 0010)/nTweb, (nLinIni + 300-nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say((nLinIni + 214)/nTweb, ((nColIni + nColMax)*0.55 + 0020)/nTweb, "37-Assinatura do Autorizador da Operadora", oFont01) //37-Assinatura do Autorizador da Operadora

			oPrint:EndPage()	// Finaliza a pagina

		EndDo
	Next

	oPrint:EndPage()	// Finaliza a pagina

Next

If lWeb
	oPrint:Print()
Else
	oPrint:Preview()
Endif

Return cFileName

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ?PLTQUIMIO?Autor ?Bruno Iserhardt       ?Data ?05.02.14 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ?Estrutura Relatório TISS 3 (Anexo de Solicitacao de         ³±?
±±?         ?Quimioterapia)                                               ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?SigaPLS                                                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros?aDados - Array com as informações do relat´rio              ³±?
±±?         ?nLayout - Define o formato de papél para impressao:         ³±?
±±?         ?          1 - Formato Ofício II (216x330mm)                 ³±?
±±?         ?          2 - Formato A4 (210x297mm)                        ³±?
±±?         ? 		 3 - Formato Carta (216x279mm)     			       ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLTQUIMIO(aDados, nLayout, cLogoGH,lWeb, cPathRelW,lUnicaImp)

Local nLinMax
Local nColMax
Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
Local nOldLin	:=	0
Local nColA4    := 	0
Local nWeb		:= 0
Local cFileLogo
Local lImpNovo := .T.
Local lPrinter := .F.
Local nI, nJ, nN, nV
Local nX, nX1
Local oFont01
Local oFont02n
Local oFont03n
Local oFont04
Local cObs
Local cRel      := "guiaquim"
Local cPathSrvJ := GETMV("MV_RELT")
Local nTweb		:= 1
Local nLweb		:= 0
Local nLwebC	:= 0
Local oPrint	:= NIL

Default lUnicaImp := .F.
Default lWeb    := .F.
Default cPathRelW := ''
Default nLayout := 2
Default cLogoGH := ''
Default	aDados  := { {;
	"123456",; //1 - Registro ANS
	{"01234567890123456789"},; //2 - N Guia no Prestador
	{"01234567890123456789"},; //3 - Numero da Guia Referenciada
	{"01234567890123456789"},; //4 - Senha
	{CtoD("03/02/14")},; //5 - Data da Autorizacao
	{"01234567890123456789"},; //6 - Numero da Guia Atribuido pela Operadora
	{"01234567890123456789"},; //7 - Número da Carteira
	{Replicate("M", 70)},; //8 - Nome
	{999.99},; //9 - Peso (Kg)
	{999.99},; //10 - Altura (Cm)
	{99.99},; //11 - Superfície Corporal (m?
	{999},; //12 - Idade
	{"M"},; //13 - Sexo
	{Replicate("M", 70)},; //14 - Nome do Profissional Solicitante
	{"01234567890"},; //15 - Telefone
	{Replicate("M", 60)},; //16 - E-mail
	{CtoD("05/02/2014")},; //17 - Data do diagnóstico
	{"9999"},; //18 - CID 10 Principal
	{"9999"},; //19 - CID 10 (2)
	{"9999"},; //20 - CID 10 (3)
	{"9999"},; //21 - CID 10 (4)
	{"1"},; //22 - Estadiamento
	{"1"},; //23 - Tipo de Quimioterapia
	{"1"},; //24 - Finalidade
	{"1"},; //25 - ECOG
	{"1"},; //26 - TUMOR
	{"1"},; //27 - NODULO
	{"1"},; //28 - METASTASE
	{Replicate("M", 1000)},; //29 - PlanoTerapêutico
	{Replicate("M", 1000)},; //30 - Diagnóstico Cito/Histopatológico
	{Replicate("M", 1000)},; //31 - Informações relevantes
	{{CtoD("05/02/2014"),CtoD("05/02/2014"),CtoD("05/02/2014"),CtoD("05/02/2014"),CtoD("05/02/2014"),CtoD("05/02/2014"),CtoD("05/02/2014"),CtoD("05/02/2014")}},; //32-Data Prevista para Administração
	{{"99","99","99","99","99","99","99","99"}},; //33-Tabela
	{{"0123456789","0123456789","0123456789","0123456789","0123456789","0123456789","0123456789","0123456789"}},; //34-Código do Medicamento
	{{Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150),Replicate("M", 150)}},; //35-Descrição
	{{999.99, 999.99, 999.99, 999.99, 999.99, 999.99, 111.11, 222.22}},; //36-Doses
	{{"999", "999", "999", "999", "999", "999", "999", "999"}},; //37-Unidade de medida
	{{"99", "99", "99", "99", "99", "99", "99", "99"}},; //38-Via Adm
	{{99, 99, 99, 99, 99, 99, 11, 22}},; //39-Frequência
	{Replicate("M", 40)},; //40- Cirurgia
	{CtoD("05/02/2014")},; //41 - Data da Realização
	{Replicate("M", 40)},; //42 - Área Irradiada
	{CtoD("05/02/2014")},; //43 - Data da Aplicação
	{Replicate("M", 500)},; //44 - Observação
	{99},; //45 - Número de Ciclos Previstos
	{99},; //46 - Ciclo Atual
	{99},; //47 - Dias Ciclo Atual
	{999},; //48-Intervalo entre Ciclos ( em dias)
	{CtoD("05/02/2014")},; //49 - Data da Solicitação
	{""},; //50-Assinatura do Profissional Solicitante
	{""} } } //51-Assinatura do Responsável pela Autorização

If nLayout  == 1 // Ofício 2
	nLinMax := 2435
	nColMax := 3705
Elseif nLayout == 2   // Papél A4
	nLinMax	:=	2275
	nColMax	:=	3270
Else //Carta
	nLinMax	:=	2435
	nColMax	:=	3175
Endif

if lWeb
	oFont01		:= TFont():New("Arial",  4,  4, , .F., , , , .T., .F.) // Normal
else
	oFont01		:= TFont():New("Arial",  5,  5, , .F., , , , .T., .F.) // Normal
End if	
if nLayout == 1 // Oficio 2
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	oFont05		:= TFont():New("Arial", 06, 06, , .F., , , , .T., .F.) // Normal
Else  // Papél A4 ou Carta
	oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	oFont05		:= TFont():New("Arial", 06, 06, , .F., , , , .T., .F.) // Normal
Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Nao permite acionar a impressao quando for na web.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lWeb
	cPathSrvJ := cPathRelW
	cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
Else
	cFileName := cRel+CriaTrab(NIL,.F.)
EndIf

if !lWeb
	oPrint	:= TMSPrinter():New("ANEXO DE SOLICITAÇÃO DE QUIMIOTERAPIA") //ANEXO DE SOLICITAÇÃO DE QUIMIOTERAPIA
	nWeb	:= 0
else
	oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ	 ,.T.,	,@oPrint,			  ,			  ,	.F.			,.f.)
	If lSrvUnix
		AjusPath(@oPrint)
	EndIf
	oPrint:cPathPDF := cPathSrvJ
	nTweb		:= 3.9
	nLweb		:= 10
	nLwebC		:= -3
	nColMax		:= 3100
	nWeb		:= 25
	oPrint:lServer := lWeb
Endif


oPrint:SetLandscape()		// Modo paisagem

if nLayout ==2
	oPrint:SetPaperSize(9)// Papél A4
Elseif nLayout ==3
	oPrint:SetPaperSize(1)// Papél Carta
Else
	oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Device
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lWeb
	oPrint:setDevice(IMP_PDF)
Else
		// Verifica se existe alguma impressora configurada para Impressao Grafica
	lPrinter := oPrint:IsPrinterActive()
	IF lPrinter
		lPrinter := IIF(GETNEWPAR("MV_IMPATIV", .F.), .F., .T.)	//	Define se ir?alterar a Impressora Ativa
	ENDIF
	If ! lPrinter
		oPrint:Setup()
	EndIf
Endif

For nX := 1 To Len(aDados)

	If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
		Loop
	EndIf

	For nX1 := 1 To Len(aDados[nX, 02])

		nAte := 8
		nV := 1

		//Esta parte do código faz com que
		//imprima mais de uma guia.
		//INICIO
		If lUnicaImp
			If nX1 <= Len(aDados) 
				lImpNovo := .T.
			EndIf
		EndIf
		//FIM

		While lImpNovo

			lImpNovo := .F.

			For nI:= 32 To 39
				If Len(aDados[nX, nI, nX1]) < nAte
					For nJ := Len(aDados[nX, nI, nX1]) + 1 To nAte
						If AllTrim(Str(nI)) $ "36,39"
							aAdd(aDados[nX, nI, nX1], 0)
						ElseIf AllTrim(Str(nI)) $ "32"
							aAdd(aDados[nX, nI, nX1], CtoD(""))
						Else
							aAdd(aDados[nX, nI, nX1],"")
						EndIf
					Next nJ
				EndIf
			Next nI

			nLinIni  := 080
			nColIni  := 080
			nColA4   := 000

			oPrint:StartPage()		// Inicia uma nova pagina
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Box Principal                                                 ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:Box((nLinIni + 0000)/nTWeb, (nColIni + 0000)/nTWeb, (nLinIni + nLinMax)/nTWeb, (nColIni + nColMax)/nTWeb)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrega e Imprime Logotipo da Empresa                         ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fLogoEmp(@cFileLogo,, cLogoGH)

			If File(cFilelogo)
				oPrint:SayBitmap((nLinIni + 0050)/nTWeb, (nColIni + 0020)/nTWeb, cFileLogo, (400)/nTWeb, (090)/nTWeb) 		// Tem que estar abaixo do RootPath
			EndIf

			If nLayout == 2 // Papél A4
				nColA4    := -0335
			Elseif nLayout == 3// Carta
				nColA4    := -0530
			Endif

			nLinIni += 70

			oPrint:Say((nLinIni + 0010)/nTWeb, ((nColIni + nColMax)*0.47)/nTWeb, "ANEXO DE SOLICITAÇÃO DE QUIMIOTERAPIA", oFont02n,,,, 2) //ANEXO DE SOLICITAÇÃO DE QUIMIOTERAPIA
			oPrint:Say((nLinIni + 0030)/nTWeb, (nColMax - 750)/nTWeb, "2- N?Guia no Prestador", oFont01) //2- N?Guia no Prestador
			oPrint:Say((nLinIni + 0020)/nTWeb, (nColMax - 480)/nTWeb, aDados[nX, 02, nX1], oFont03n)

				//fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 80, 80)
			nLinIni -= 80
			oPrint:Box((nLinIni + 0175 -nWeb)/nTWeb,( nColIni + 0010)/nTWeb, (nLinIni + 0269-nWeb)/nTWeb, ((nColIni + nColMax)*0.065 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0180)/nTWeb,( nColIni + 0015)/nTWeb, "1 - Registro ANS", oFont01) //1 - Registro ANS
			oPrint:Say((nLinIni + 0220)/nTWeb,( nColIni + 0030)/nTWeb, Iif(Empty(aDados[nX, 01]),'|___|___|___|___|___|___|',aDados[nX, 01]), oFont05)
			oPrint:Box((nLinIni + 0175-nWeb)/nTWeb,( (nColIni + nColMax)*0.065)/nTWeb, (nLinIni + 0269-nWeb)/nTWeb, ((nColIni + nColMax)*0.325 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0180)/nTWeb,( (nColIni + nColMax)*0.065 + 0006)/nTWeb, "3 - Número da Guia Referenciada", oFont01) //3 - Número da Guia Referenciada
			oPrint:Say((nLinIni + 0220)/nTWeb,( (nColIni + nColMax)*0.065 + 0006)/nTWeb, Iif(Empty(aDados[nX, 03, nX1]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 03, nX1]), oFont05)
			oPrint:Box((nLinIni + 0175-nWeb)/nTWeb,( (nColIni + nColMax)*0.325)/nTWeb, (nLinIni + 0269-nWeb)/nTWeb, ((nColIni + nColMax)*0.595 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0180)/nTWeb,( (nColIni + nColMax)*0.325 + 0020)/nTWeb, "4 - Senha", oFont01) //4 - Senha
			oPrint:Say((nLinIni + 0220)/nTWeb,( (nColIni + nColMax)*0.325 + 0030)/nTWeb, Iif(Empty(aDados[nX, 04, nX1]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 04, nX1]), oFont05)
			oPrint:Box((nLinIni + 0175-nWeb)/nTWeb,( (nColIni + nColMax)*0.595)/nTWeb, (nLinIni + 0269-nWeb)/nTWeb, ((nColIni + nColMax)*0.73 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0180)/nTWeb,( (nColIni + nColMax)*0.595 + 0030)/nTWeb, "5 - Data da Autorização", oFont01) //5 - Data da Autorização
			oPrint:Say((nLinIni + 0220)/nTWeb,( (nColIni + nColMax)*0.595 + 0030)/nTWeb, Iif(Empty(aDados[nX, 05, nX1]),'|___|___|/|___|___|/|___|___|___|___|',DToC(aDados[nX, 05, nX1])), oFont05)
			oPrint:Box((nLinIni + 0175-nWeb)/nTWeb,( (nColIni + nColMax)*0.73)/nTWeb, (nLinIni + 0269-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
			oPrint:Say((nLinIni + 0180)/nTWeb,( (nColIni + nColMax)*0.73 + 0020)/nTWeb, "6 - Número da Guia Atribuído pela Operadora", oFont01) //6 - Número da Guia Atribuído pela Operadora
			oPrint:Say((nLinIni + 0220)/nTWeb,( (nColIni + nColMax)*0.73 + 0030)/nTWeb, Iif(Empty(aDados[nX, 06, nX1]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 06, nX1]), oFont05)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 80)
			AddTBrush(oPrint, (nLinIni + 175)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 206)/nTWeb, (nColIni + nColMax)/nTWeb)
			oPrint:Say((nLinIni + 178)/nTWeb, (nColIni + 0020)/nTWeb, "Dados do Beneficiário", oFont01) //Dados do Prestador
			
			oPrint:Box((nLinIni + 208-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.35 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 212)/nTWeb, (nColIni + 0020)/nTWeb, "7 - Número da Carteira", oFont01) //7 - Número da Carteira
			oPrint:Say((nLinIni + 252)/nTWeb, (nColIni + 0030)/nTWeb, Iif(Empty(aDados[nX, 07, nX1]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 07, nX1]), oFont05)
			
			oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.35)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
			oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.35 + 0020)/nTWeb, "8 - Nome", oFont01) //8 - Nome
			oPrint:Say((nLinIni + 252)/nTWeb, ((nColIni + nColMax)*0.35 + 0030)/nTWeb, aDados[nX, 08, nX1], oFont04)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 130, 80)
			
			oPrint:Box((nLinIni + 178-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.15 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 183)/nTWeb, (nColIni + 0020)/nTWeb, "9 - Peso (Kg)", oFont01) //9 - Peso (Kg)
			oPrint:Say((nLinIni + 223)/nTWeb, (nColIni + 0030)/nTWeb, IIf(aDados[nX, 09, nX1]>0,Transform(aDados[nX, 09, nX1], "@E 999.99"),"|___|___|___|,|___|___|"), oFont05)
			
			oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.15)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.25 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.15 + 0020)/nTWeb, "10 - Altura (Cm)", oFont01) //10 - Altura (Cm)
			oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.15 + 0030)/nTWeb, IIf(aDados[nX, 10, nX1]>0,Transform(aDados[nX, 10, nX1], "@E 999.99"),"|___|___|___|,|___|___|"), oFont05)
			
			oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.25 + 0010)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.38 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.25 + 0020)/nTWeb, "11 - Superfície Corporal (m?", oFont01) //11 - Superfície Corporal (m?
			oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.25 + 0030)/nTWeb, IIf(aDados[nX, 11, nX1]>0,Transform(aDados[nX, 11, nX1], "@E 99.99"),"|___|___|,|___|___|"), oFont05)
			
			oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.38 + 0010)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.45 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.38 + 0020)/nTWeb, "12 - Idade", oFont01) //12 - Idade
			oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.38 + 0030)/nTWeb, IIf(aDados[nX, 12, nX1]>0,Transform(aDados[nX, 12, nX1], "@E 999"),"|___|___|___|"), oFont05)
			
			oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.45 + 0010)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.5 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.45 + 0020)/nTWeb, "13 - Sexo", oFont01) //13 - Sexo
			oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.45 + 0030)/nTWeb, Iif(Empty(aDados[nX, 13, nX1]),'|___|',aDados[nX, 13, nX1]), oFont05)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 110, 80)
			AddTBrush(oPrint,  (nLinIni + 174)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 205)/nTWeb, (nColIni + nColMax)/nTWeb)
			oPrint:Say((nLinIni + 178)/nTWeb, (nColIni + 0020)/nTWeb, "Dados do Profissional Solicitante", oFont01) //Dados do Profissional Solicitante
			
			oPrint:Box((nLinIni + 208-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.45 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 212)/nTWeb, (nColIni + 0020)/nTWeb, "14 - Nome do Profissional Solicitante", oFont01) //14 - Nome do Profissional Solicitante
			oPrint:Say((nLinIni + 252)/nTWeb, (nColIni + 0030)/nTWeb, aDados[nX, 14, nX1], oFont04)
			
			oPrint:Box((nLinIni + 209-nWeb)/nTWeb, ((nColIni + nColMax)*0.45)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.66 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.45 + 0020)/nTWeb, "15 - Telefone", oFont01) //15 - Telefone
			oPrint:Say((nLinIni + 252)/nTWeb, ((nColIni + nColMax)*0.45 + 0030)/nTWeb, Iif(Empty(aDados[nX, 15, nX1]),'(|___|___|)|___|___|___|___|___|-|___|___|___|___|',aDados[nX, 15, nX1]), oFont05)
			
			oPrint:Box((nLinIni + 210-nWeb)/nTWeb, ((nColIni + nColMax)*0.66)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
			oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.66 + 0020)/nTWeb, "16 - E-mail", oFont01) //16 - E-mail
			oPrint:Say((nLinIni + 252)/nTWeb, ((nColIni + nColMax)*0.66 + 0030)/nTWeb, aDados[nX, 16, nX1], oFont04)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 140, 80)
			AddTBrush(oPrint, (nLinIni + 174)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 205)/nTWeb, (nColIni + nColMax)/nTWeb)
			oPrint:Say((nLinIni + 178)/nTWeb, (nColIni + 0020)/nTWeb, "Diagnóstico Oncológico", oFont01) //Diagnóstico Oncológico
			oPrint:Box((nLinIni + 208-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.16 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 212)/nTWeb, (nColIni + 0020)/nTWeb, "17 - Data do diagnóstico", oFont01) //17 - Data do diagnóstico
			oPrint:Say((nLinIni + 258)/nTWeb, (nColIni + 0030)/nTWeb, Iif(Empty(aDados[nX, 17, nX1]),'|___|___|/|___|___|/|___|___|___|___|',DToC(aDados[nX, 17, nX1])), oFont05)
			AddTBrush(oPrint, (nLinIni + 208)/nTWeb, ((nColIni + nColMax)*0.16)/nTWeb, (nLinIni + 300)/nTWeb, ((nColIni + nColMax)*0.24 - 0010)/nTWeb)
			oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.16)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.24 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.16 + 0010)/nTWeb, "18 - CID 10 Principal (opcional)", oFont01) //18 - CID 10 Principal
			oPrint:Say((nLinIni + 252)/nTWeb, ((nColIni + nColMax)*0.16 + 0010)/nTWeb, Iif(Empty(aDados[nX, 18, nX1]),'|___|___|___|___|',aDados[nX, 18, nX1]), oFont05)
			
			AddTBrush(oPrint, (nLinIni + 208)/nTWeb, ((nColIni + nColMax)*0.24)/nTWeb, (nLinIni + 300)/nTWeb, ((nColIni + nColMax)*0.30 - 0010)/nTWeb)
			oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.24)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.30 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.24 + 0010)/nTWeb, "19 - CID 10 (2)(opcional)", oFont01) //19 - CID 10 (2)
			oPrint:Say((nLinIni + 252)/nTWeb, ((nColIni + nColMax)*0.24 + 0010)/nTWeb, Iif(Empty(aDados[nX, 19, nX1]),'|___|___|___|___|',aDados[nX, 19, nX1]), oFont05)
			
			AddTBrush(oPrint, (nLinIni + 208)/nTWeb, ((nColIni + nColMax)*0.30)/nTWeb, (nLinIni + 300)/nTWeb, ((nColIni + nColMax)*0.36 - 0010)/nTWeb)
			oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.30)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.36 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.30 + 0010)/nTWeb, "20 - CID 10 (3)(opcional)", oFont01) //20 - CID 10 (3)
			oPrint:Say((nLinIni + 252)/nTWeb, ((nColIni + nColMax)*0.30 + 0010)/nTWeb, Iif(Empty(aDados[nX, 20, nX1]),'|___|___|___|___|',aDados[nX, 20, nX1]), oFont05)
			
			AddTBrush(oPrint, (nLinIni + 208)/nTWeb, ((nColIni + nColMax)*0.36)/nTWeb, (nLinIni + 300)/nTWeb, ((nColIni + nColMax)*0.42 - 0010)/nTWeb)
			oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.36)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.42 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.36 + 0010)/nTWeb, "21 - CID 10 (4)(opcional)", oFont01) //21 - CID 10 (4)
			oPrint:Say((nLinIni + 252)/nTWeb, ((nColIni + nColMax)*0.36 + 0010)/nTWeb, Iif(Empty(aDados[nX, 21, nX1]),'|___|___|___|___|',aDados[nX, 21, nX1]), oFont05)
			oPrint:Box((nLinIni + 208-nWeb)/nTWeb, ((nColIni + nColMax)*0.42)/nTWeb, (nLinIni + 400-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
			oPrint:Say((nLinIni + 212)/nTWeb, ((nColIni + nColMax)*0.42 + 0020)/nTWeb, "29 - Plano Terapêutico", oFont01) //29 - PlanoTerapêutico

			nOldLin := nLinIni

			For nI := 1 To MlCount(aDados[nX, 26, nX1], If(!lWeb,180,120))
				cObs := MemoLine(aDados[nX, 26, nX1], If(!lWeb,180,120), nI)
				oPrint:Say((nLinIni + 252)/nTWeb, ((nColIni + nColMax)*0.38 + 0020)/nTWeb, cObs, oFont01)
				nLinIni += 30
				If nI == 5
					exit //trunco para nao desconfigurar o relatorio
				Endif
			Next nI

			nLinIni := nOldLin

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 130, 80)
			oPrint:Box((nLinIni + 178-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.08 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 183)/nTWeb, (nColIni + 0020)/nTWeb, "22 - Estadiamento", oFont01) //22 - Estadiamento
			oPrint:Say((nLinIni + 223)/nTWeb, (nColIni + 0030)/nTWeb, Iif(Empty(aDados[nX, 22, nX1]),'|___|',aDados[nX, 22, nX1]), oFont05)
			
			oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.082)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.15 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.082 + 0020)/nTWeb, "23 - Tipo de Quimioterapia", oFont01) //23 - Tipo de Quimioterapia
			oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.082 + 0030)/nTWeb, Iif(Empty(aDados[nX, 23, nX1]),'|___|',aDados[nX, 23, nX1]), oFont05)
			
			oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.15 + 2 )/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.20 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.15 + 0022)/nTWeb, "24 - Finalidade", oFont01) //24 - Finalidade
			oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.15 + 0032)/nTWeb, Iif(Empty(aDados[nX, 24, nX1]),'|___|',aDados[nX, 24, nX1]), oFont05)
			
			oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.2)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.24 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.2 + 0020)/nTWeb, "25 - ECOG", oFont01) //25 - ECOG
			oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.2 + 0030)/nTWeb, Iif(Empty(aDados[nX, 25, nX1]),'|___|',aDados[nX, 25, nX1]), oFont05)
			
			oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.24)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.30 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.25 + 0020)/nTWeb, "26 - TUMOR", oFont01) //26 - TUMOR
			oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.25 + 0030)/nTWeb, Iif(Empty(aDados[nX, 26, nX1]),'|___|',aDados[nX, 26, nX1]), oFont05)
			
			oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.30)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.36 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.31 + 0020)/nTWeb, "27 - NÓDULO", oFont01) //27 - NÓDULO
			oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.31 + 0030)/nTWeb, Iif(Empty(aDados[nX, 27, nX1]),'|___|',aDados[nX, 27, nX1]), oFont05)
			
			oPrint:Box((nLinIni + 178-nWeb)/nTWeb, ((nColIni + nColMax)*0.36)/nTWeb, (nLinIni + 272-nWeb)/nTWeb, ((nColIni + nColMax)*0.42 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 183)/nTWeb, ((nColIni + nColMax)*0.37 + 0020)/nTWeb, "28 - Metástase", oFont01) //28 - Metástase
			oPrint:Say((nLinIni + 223)/nTWeb, ((nColIni + nColMax)*0.37 + 0030)/nTWeb, Iif(Empty(aDados[nX, 28, nX1]),'|___|',aDados[nX, 28, nX1]), oFont05)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 300, 80)
			oPrint:Box((nLinIni + 28-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 500-nWeb)/nTWeb, ((nColIni + nColMax)*0.5 - 0010)/nTWeb)
			oPrint:Say((nLinIni +33)/nTWeb, (nColIni + 0020)/nTWeb, "30 - Diagnóstico Cito/Histopatológico", oFont01) //30 - Diagnóstico Cito/Histopatológico
			oPrint:Box((nLinIni + 28-nWeb)/nTWeb, ((nColIni + nColMax)*0.5)/nTWeb, (nLinIni + 500-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
			oPrint:Say((nLinIni + 33)/nTWeb, ((nColIni + nColMax)*0.5 + 0020)/nTWeb, "31 - Informações relevantes", oFont01) //31 - Informações relevantes

			nOldLin := nLinIni

			For nI := 1 To MlCount(aDados[nX, 30, nX1], If(!lWeb,120,90))
				cObs := MemoLine(aDados[nX, 30, nX1], If(!lWeb,120,90), nI)
				oPrint:Say((nLinIni + 80)/nTWeb, (nColIni + 0020)/nTWeb, cObs, oFont01)
				nLinIni += 30
			Next nI

			nLinIni := nOldLin

			For nI := 1 To MlCount(aDados[nX, 31, nX1], If(!lWeb,120,90))
				cObs := MemoLine(aDados[nX, 31, nX1], If(!lWeb,120,90), nI)
				oPrint:Say((nLinIni + 80)/nTWeb, ((nColIni + nColMax)*0.5 + 0030)/nTWeb, cObs, oFont01)
				nLinIni += 30
			Next nI

			nLinIni := nOldLin
			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 500, 80)
			nOldLin := nLinIni

			AddTBrush(oPrint,  (nLinIni + 97)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 230)/nTWeb, ((nColIni + nColMax)*0.8 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 50)/nTWeb, (nColIni + 0020)/nTWeb, "Medicamentos e Drogas solicitadas", oFont01) //Medicamentos e Drogas solicitadas

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 80)
			oPrint:Box((nLinIni + 54-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 570-nWeb)/nTWeb, ((nColIni + nColMax)*0.8 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 60)/nTWeb, (nColIni + 0040)/nTWeb, "32-Data Prevista para Administração", oFont01) //32-Data Prevista para Administração
			oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.15)/nTWeb, "33-Tabela", oFont01) //33-Tabela
			oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.18)/nTWeb, "34-Código do Medicamento", oFont01) //34-Código do Medicamento
			oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.32)/nTWeb, "35-Descrição", oFont01) //35-Descrição
			oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.55)/nTWeb, "36-Dosagem total no ciclo", oFont01,,,,1) //36-Dosagem total no ciclo
			oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.65 + 0020)/nTWeb, "37-Unidade de medida", oFont01,,,,1) //37-Unidade de medida
			oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.71 + 0020)/nTWeb, "38-Via Adm", oFont01) //38-Via Adm
			oPrint:Say((nLinIni + 60)/nTWeb, ((nColIni + nColMax)*0.76 - 0020)/nTWeb + IIF(lWeb,0,100), "39-Frequência", oFont01,,,,1) //39-Frequência

			For nN := nV To nAte

				oPrint:Say((nLinIni + 100)/nTWeb, (nColIni + 0012)/nTWeb, AllTrim(Str(nN)) + " - ", oFont01)
				
				oPrint:Say((nLinIni + 100)/nTWeb, (nColIni + 0040)/nTWeb, Iif(Empty(aDados[nX, 32, nX1, nN]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 32, nX1, nN])), oFont05)
				oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.15)/nTWeb, Iif(Empty(aDados[nX, 33, nX1, nN]),'|___|___|',aDados[nX, 33, nX1, nN]), oFont05)
				oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.18)/nTWeb, Iif(Empty(aDados[nX, 34, nX1, nN]),'|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 34, nX1, nN]), oFont05)
				oPrint:Say((nLinIni + 110)/nTWeb, ((nColIni + nColMax)*0.32)/nTWeb, Iif(Empty(aDados[nX, 35, nX1, nN]),REPLICATE('_',80),aDados[nX, 35, nX1, nN]), oFont01)
				oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.55)/nTWeb, IIf(Empty(aDados[nX, 36, nX1, nN]), "|___|___|___|___|___|,|___|___|", Transform(aDados[nX, 36, nX1, nN], "@E 999.99")), oFont05,,,,1)
				oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.65 + 0020)/nTWeb, Iif(Empty(aDados[nX, 37, nX1, nN]),'|___|___|___|',aDados[nX, 37, nX1, nN]), oFont05)
				oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.71 + 0020)/nTWeb, Iif(Empty(aDados[nX, 38, nX1, nN]),'|___|___|',aDados[nX, 38, nX1, nN]), oFont05)
				oPrint:Say((nLinIni + 100)/nTWeb, ((nColIni + nColMax)*0.76 - 0020)/nTWeb + IIF(lWeb,0,100), IIf(Empty(aDados[nX, 39, nX1, nN]), "|___|___|", Transform(aDados[nX, 39, nX1, nN], "@E 99")), oFont05,,,,1)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 40, 80)
			Next

			If nAte < Len(aDados[nX, 32, nX1])
				lImpNovo := .T.
				nAte += 8
				nV := nN
			EndIf

			nLinIni := nOldLin

			AddTBrush(oPrint,  (nLinIni + 97)/nTWeb, ((nColIni + nColMax)*0.8)/nTWeb, (nLinIni + 230)/nTWeb, (nColIni + nColMax)/nTWeb)
			oPrint:Say((nLinIni + 50)/nTWeb, ((nColIni + nColMax)*0.8 + 0010)/nTWeb, "Tratamentos Anteriores", oFont01) //Tratamentos Anteriores

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 80)
			oPrint:Box((nLinIni + 54-nWeb)/nTWeb, ((nColIni + nColMax)*0.8)/nTWeb, (nLinIni + 230-nWeb)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
			oPrint:Say((nLinIni + 54)/nTWeb, ((nColIni + nColMax)*0.8 + 0020)/nTWeb, "40 - Cirurgia", oFont01) //40- Cirurgia

			nLinZZ := nLinIni

			For nI := 1 To MlCount(aDados[nX, 40, nX1], 30)
				cObs := MemoLine(aDados[nX, 40, nX1], 30, nI)
				oPrint:Say((nLinIni + 74)/nTWeb, ((nColIni + nColMax)*0.8 + 0030)/nTWeb, cObs, oFont04)
				nLinIni += 30
				If nI == 5
					exit // trunco para nao desconfigurar o relatorio
				Endif
			Next nI

			nLinIni := nLinZZ + 150

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 80)
			oPrint:Box((nLinIni + 54-nWeb)/nTWeb, ((nColIni + nColMax)*0.8)/nTWeb, (nLinIni + 130-nWeb)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
			oPrint:Say((nLinIni + 54)/nTWeb, ((nColIni + nColMax)*0.8 + 0020)/nTWeb, "41 - Data da Realização", oFont01) //41 - Data da Realização
			oPrint:Say((nLinIni + 74)/nTWeb, ((nColIni + nColMax)*0.8 + 0030)/nTWeb, Iif(Empty(aDados[nX, 41, nX1]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 41, nX1])), oFont05)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 80, 80)
			oPrint:Box((nLinIni + 54-nWeb)/nTWeb, ((nColIni + nColMax)*0.8)/nTWeb, (nLinIni + 230-nWeb)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
			oPrint:Say((nLinIni + 54)/nTWeb, ((nColIni + nColMax)*0.8 + 0020)/nTWeb, "42 - Área Irradiada", oFont01) //42 - Área Irradiada

			nLinZZ := nLinIni

			For nI := 1 To MlCount(aDados[nX, 42, nX1], 30)
				cObs := MemoLine(aDados[nX, 42, nX1], 30, nI)
				oPrint:Say((nLinIni + 74)/nTWeb, ((nColIni + nColMax)*0.8 + 0030)/nTWeb, cObs, oFont04)
				nLinIni += 30
				If nI == 5
					exit // trunco para nao desconfigurar o relatorio
				Endif
			Next nI

			nLinIni := nLinZZ + 150

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 30, 80)
			oPrint:Box((nLinIni + 54-nWeb)/nTWeb, ((nColIni + nColMax)*0.8)/nTWeb, (nLinIni + 130-nWeb)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
			oPrint:Say((nLinIni + 54)/nTWeb, ((nColIni + nColMax)*0.8 + 0020)/nTWeb, "43 - Data da Aplicação", oFont01) //43 - Data da Aplicação
			oPrint:Say((nLinIni + 74)/nTWeb, ((nColIni + nColMax)*0.8 + 0030)/nTWeb, Iif(Empty(aDados[nX, 43, nX1]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 43, nX1])), oFont05)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 80, 80)
			AddTBrush(oPrint, (nLinIni + 54)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 400)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
			oPrint:Box((nLinIni + 50 -nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 200-nWeb)/nTWeb, ((nColIni + nColMax) - 0010)/nTWeb)
			oPrint:Say((nLinIni + 50)/nTWeb, (nColIni + 0020)/nTWeb, "44 - Observação / Justificativa", oFont01) //38 - Área Irradiada

			nLinZZ := nLinIni
			
			For nI := 1 To MlCount(aDados[nX, 44, nX1], If(!lWeb,155,120))
				cObs := MemoLine(aDados[nX, 44, nX1], If(!lWeb,155,120), nI)
				oPrint:Say((nLinIni + 70)/nTWeb, (nColIni + 0030)/nTWeb, cObs, oFont04)
				nLinIni += 30
				If nI == 4
					exit
				Endif
			Next nI

			nLinIni := 1980

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
			oPrint:Box((nLinIni + 204-nWeb)/nTWeb, (nColIni + 0010)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.12 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 209)/nTWeb, (nColIni + 0020)/nTWeb, "45- Número de Ciclos", oFont01) //45- Número de Ciclos
			oPrint:Say((nLinIni + 229)/nTWeb, (nColIni + 0020)/nTWeb, "Previstos", oFont01) //Previstos
			oPrint:Say((nLinIni + 254)/nTWeb, (nColIni + 0030)/nTWeb, IIf(Empty(aDados[nX, 45, nX1]), "|___|___|", Transform(aDados[nX, 45, nX1], "@E 99")), oFont05)
			oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.12)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.18 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.12 + 0020)/nTWeb, "46 - Ciclo Atual", oFont01) //46 - Ciclo Atual
			oPrint:Say((nLinIni + 254)/nTWeb, ((nColIni + nColMax)*0.12 + 0030)/nTWeb, IIf(Empty(aDados[nX, 46, nX1]), "|___|___|", Transform(aDados[nX, 46, nX1], "@E 99")), oFont05)
			
			oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.18)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.23 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.18 + 0020)/nTWeb, "47-N?de dias do", oFont01) //45- Número de Ciclos
			oPrint:Say((nLinIni + 229)/nTWeb, ((nColIni + nColMax)*0.18 + 0020)/nTWeb, "Ciclo Atual", oFont01) //Previstos
			oPrint:Say((nLinIni + 254)/nTWeb, ((nColIni + nColMax)*0.18 + 0010)/nTWeb,IIf(Len(aDados[nX, 47])>0,IIf(Empty(aDados[nX, 47, nX1]), "|___|___|___|", Transform(aDados[nX, 47, nX1], "@E 99")),"|___|___|___|" ), oFont05)			
			
			oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.23)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.28 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.23 + 0020)/nTWeb, "48-Intervalo entre", oFont01) //48-Intervalo entre
			oPrint:Say((nLinIni + 229)/nTWeb, ((nColIni + nColMax)*0.23 + 0020)/nTWeb, "Ciclos ( em dias)", oFont01) //Ciclos ( em dias)
			oPrint:Say((nLinIni + 254)/nTWeb, ((nColIni + nColMax)*0.23 + 0010)/nTWeb, IIf(Empty(aDados[nX, 48, nX1]), "|___|___|___|", Transform(aDados[nX, 48, nX1], "@E 999")), oFont05)
			
			oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.28)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.42 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.28 + 0020)/nTWeb, "49 - Data da Solicitação", oFont01) //49 - Data da Solicitação
			oPrint:Say((nLinIni + 260)/nTWeb, ((nColIni + nColMax)*0.28 + 0010)/nTWeb, Iif(Empty(aDados[nX, 49, nX1]),'|___|___|/|___|___|/|___|___|___|___|',DtoC(aDados[nX, 49, nX1])), oFont05)
			
			oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.42)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, ((nColIni + nColMax)*0.71 - 0010)/nTWeb)
			oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.42 + 0020)/nTWeb, "50-Assinatura do Profissional Solicitante", oFont01) //50-Assinatura do Profissional Solicitante
			
			oPrint:Box((nLinIni + 204-nWeb)/nTWeb, ((nColIni + nColMax)*0.71)/nTWeb, (nLinIni + 300-nWeb)/nTWeb, (nColIni + nColMax - 0010)/nTWeb)
			oPrint:Say((nLinIni + 209)/nTWeb, ((nColIni + nColMax)*0.71 + 0020)/nTWeb, "51-Assinatura do Responsável pela Autorização", oFont01) //51-Assinatura do Responsável pela Autorização
			

			oPrint:EndPage()	// Finaliza a pagina

		EndDo

	Next

	oPrint:EndPage()	// Finaliza a pagina

Next

If lWeb
	oPrint:Print()
Else
	oPrint:Preview()
Endif

Return cFileName


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ?PLTOPME?Autor ?Bruno Iserhardt       ?Data ?03.02.14 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ?Estrutura Relatório TISS 3 (Anexo de Solicitacao de Ortese, ³±?
±±?         ?Proteses e Materiais Especiais)                             ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?SigaPLS                                                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros?aDados - Array com as informações do relat´rio              ³±?
±±?         ?nLayout - Define o formato de papél para impressao:         ³±?
±±?         ?          1 - Formato Ofício II (216x330mm)                 ³±?
±±?         ?          2 - Formato A4 (210x297mm)                        ³±?
±±?         ? 		 3 - Formato Carta (216x279mm)     			       ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLTOPME(aDados, nLayout, cLogoGH,lWeb, cPathRelW,lUnicaImp)

Local nLinMax
Local nColMax
Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
Local nColA4    := 	0
Local nLinOld	:=	0
Local nWeb		:=  0
Local lImpNovo := .T.
Local cFileLogo
Local lPrinter := .F.
Local nAte := 0
Local nI, nJ, nN, nV
Local nX, nX1
Local oFont01
Local oFont02n
Local oFont03n
Local oFont04
Local cObs
Local cRel      := "guiopme"
Local cPathSrvJ := GETMV("MV_RELT")
Local nTweb		:= 1
Local nLweb		:= 0
Local nLwebC	:= 0
Local oPrint	:= NIL

Default lUnicaImp := .F.
Default lWeb    := .F.
Default cPathRelW := ''
Default nLayout := 2
Default cLogoGH := ''
Default	aDados  := { {;
	"123456",; //1 - Registro ANS
	{"01234567890123456789"},; //2 - N Guia no Prestador
	{"01234567890123456789"},; //3 - Numero da Guia Referenciada
	{"01234567890123456789"},; //4 - Senha
	{CtoD("03/02/14")},; //5 - Data da Autorizacao
	{"01234567890123456789"},; //6 - Numero da Guia Atribuido pela Operadora
	{"01234567890123456789"},; //7 - Numero da Carteira
	{Replicate("M", 70)},; //8 - Nome
	{Replicate("M", 70)},; //9- Nome do Profissional Solicitante
	{"01234567890"},; //10 - Telefone
	{Replicate("M", 60)},; //11 - E-mail
	{Replicate("M", 1000)},; //12 - Justificativa Tecnica
	{{"99", "01","99", "01","99", "01"}},; //13-Tabela
	{{"0123456789", "0123456789","0123456789", "0123456789","0123456789", "0123456789"}},; //14-Codigo do Material
	{{Replicate("M", 150), Replicate("M", 150),Replicate("M", 150), Replicate("M", 150),Replicate("M", 150), Replicate("M", 150)}},; //15-Descricao
	{{"0", "9","0", "9","0", "9"}},; //16-Opcao
	{{123, 999, 123, 999, 123, 999}},; //17-Qtde. Solicitada
	{{123456.78, 999999.99,123456.78, 999999.99,123456.78, 999999.99}},; //18-Valor Unitario Solicitado
	{{123, 999, 123, 999, 123, 999}},; //19-Qtde. Autorizada
	{{123456.78, 999999.99, 123456.78, 999999.99, 123456.78, 999999.99}},; //20-Valor Unitario Autorizado
	{{"012345678901234","012345678901234","012345678901234","012345678901234","012345678901234","012345678901234"}},; //21-Registro ANVISA do Material
	{{Replicate("M", 30), Replicate("9", 30), Replicate("M", 30), Replicate("9", 30), Replicate("M", 30), Replicate("9", 30)}},; //22-Referencia do material no fabricante
	{{Replicate("M", 30), Replicate("9", 30), Replicate("M", 30), Replicate("9", 30), Replicate("9", 30), Replicate("9", 30)}},; //23-N Autorizacao de Funcionamento
	{Replicate("M", 500)},; //24 - Especificacao do Material
	{Replicate("M", 500)},; //25- Observacao / Justificativa
	{CtoD("03/02/14")},; //26 - Data da Solicitacao
	{""},; //27- Assinatura do Profissional Solicitante
	{""} } } //28- Assinatura do Responsavel pela Autorizacao

If nLayout  == 1 // Ofício 2
	nLinMax := 2435
	nColMax := 3705
Elseif nLayout == 2   // Papél A4
	nLinMax	:=	2275
	nColMax	:=	3270
Else //Carta
	nLinMax	:=	2435
	nColMax	:=	3175
Endif

oFont01		:= TFont():New("Arial",  6,  6, , .F., , , , .T., .F.) // Normal
if nLayout == 1 // Oficio 2
	oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
Else  // Papél A4 ou Carta
	oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
	oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
	oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Nao permite acionar a impressao quando for na web.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lWeb
	cPathSrvJ := cPathRelW
	cFileName := cRel+lower(CriaTrab(NIL,.F.))+".pdf"
Else
	cFileName := cRel+CriaTrab(NIL,.F.)
EndIf

if !lWeb
	oPrint	:= TMSPrinter():New("ANEXO DE SOLICITAÇÃO DE ÓRTESES, PRÓTESES E MATERIAIS ESPECIAIS - OPME") //ANEXO DE SOLICITAÇÃO DE ÓRTESES, PRÓTESES E MATERIAIS ESPECIAIS - OPME
else
	oPrint := FWMSPrinter():New ( cFileName	,,.F.,cPathSrvJ	 ,.T.,	,@oPrint,			  ,			  ,	.F.			,.f.)
	If lSrvUnix
		AjusPath(@oPrint)
	EndIf
	oPrint:cPathPDF := cPathSrvJ
	nTweb		:= 3.9
	nLweb		:= 10
	nLwebC		:= -3
	nColMax		:= 3100
	nWeb		:= 25
	oPrint:lServer := lWeb
Endif


oPrint:SetLandscape()		// Modo paisagem

if nLayout ==2
	oPrint:SetPaperSize(9)// Papél A4
Elseif nLayout ==3
	oPrint:SetPaperSize(1)// Papél Carta
Else
	oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Device
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If lWeb
	oPrint:setDevice(IMP_PDF)
Else
		// Verifica se existe alguma impressora configurada para Impressao Grafica
	lPrinter := oPrint:IsPrinterActive()
	IF lPrinter
		lPrinter := IIF(GETNEWPAR("MV_IMPATIV", .F.), .F., .T.)	//	Define se ir?alterar a Impressora Ativa
	ENDIF
	If ! lPrinter
		oPrint:Setup()
	EndIf
Endif

For nX := 1 To Len(aDados)

	If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
		Loop
	EndIf



	For nX1 := 1 To Len(aDados[nX, 02])

		nAte := 6
		nV := 1
		
		//Esta parte do código faz com que
		//imprima mais de uma guia.
		//INICIO
		If lUnicaImp
			If nX1 <= Len(aDados) 
				lImpNovo := .T.
			EndIf
		EndIf
		//FIM 
		
		While lImpNovo

			lImpNovo := .F.

			For nI:= 13 To 23
				If Len(aDados[nX, nI, nX1]) < nAte
					For nJ := Len(aDados[nX, nI, nX1]) + 1 To nAte
						If AllTrim(Str(nI)) $ "17,18,19,20"
							aAdd(aDados[nX, nI, nX1], 0)
						Else
							aAdd(aDados[nX, nI, nX1],"")
						EndIf
					Next nJ
				EndIf
			Next nI

			nLinIni  := 080
			nColIni  := 080
			nColA4   := 000

			oPrint:StartPage()		// Inicia uma nova pagina
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Box Principal                                                 ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:Box((nLinIni + 0000)/nTweb, (nColIni + 0000)/nTweb, (nLinIni + nLinMax)/nTweb, (nColIni + nColMax)/nTweb)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega e Imprime Logotipo da Empresa                         ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fLogoEmp(@cFileLogo,, cLogoGH)

			If File(cFilelogo)
				oPrint:SayBitmap((nLinIni + 0050)/nTweb, (nColIni + 0020)/nTweb, cFileLogo, 400/nTweb, 090/nTweb) 		// Tem que estar abaixo do RootPath
			EndIf

			If nLayout == 2 // Papél A4
				nColA4    := -0335
			Elseif nLayout == 3// Carta
				nColA4    := -0530
			Endif

			oPrint:Say((nLinIni + 0080)/nTweb, ((nColIni + nColMax)*0.46)/nTweb, "ANEXO DE SOLICITAÇÃO DE ÓRTESES, PRÓTESES E", oFont02n,,,, 2) //ANEXO DE SOLICITAÇÃO DE ÓRTESES, PRÓTESES E MATERIAIS ESPECIAIS - OPME
			oPrint:Say((nLinIni + 0120)/nTweb, ((nColIni + nColMax)*0.47)/nTweb, "MATERIAIS ESPECIAIS - OPME", oFont02n,,,, 2)
			oPrint:Say((nLinIni + 0090)/nTweb, (nColMax - 750)/nTweb, "2- N?Guia no Prestador", oFont01) //2- N?Guia no Prestador
			oPrint:Say((nLinIni + 0070)/nTweb, (nColMax - 480)/nTweb, aDados[nX, 02, nX1], oFont03n)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 80, 80)
			oPrint:Box((nLinIni + 0175 - nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 0269 -nWeb)/nTweb, ((nColIni + nColMax)*0.080 - 0010)/nTweb)
			oPrint:Say((nLinIni + 0180)/nTweb, (nColIni + 0015)/nTweb, "1 - Registro ANS", oFont01) //1 - Registro ANS
			oPrint:Say((nLinIni + 0220)/nTweb, (nColIni + 0030)/nTweb, Iif(Empty(aDados[nX, 01]),'|___|___|___|___|___|___|',aDados[nX, 01]), oFont01)
			oPrint:Box((nLinIni + 0175 - nWeb)/nTweb, ((nColIni + nColMax)*0.080)/nTweb, (nLinIni + 0269 - nWeb)/nTweb, ((nColIni + nColMax)*0.340 - 0010)/nTweb)
			oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.080 + 0006)/nTweb, "3 - Número da Guia Referenciada", oFont01) //3 - Número da Guia Referenciada
			oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.080 + 0006)/nTweb, Iif(Empty(aDados[nX, 03, nX1]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 03, nX1]), oFont01)
			oPrint:Box((nLinIni + 0175 - nWeb)/nTweb, ((nColIni + nColMax)*0.340)/nTweb, (nLinIni + 0269 - nWeb)/nTweb, ((nColIni + nColMax)*0.610 - 0010)/nTweb)
			oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.340 + 0015)/nTweb, "4 - Senha", oFont01) //4 - Senha
			oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.340 + 0015)/nTweb, Iif(Empty(aDados[nX, 04, nX1]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 04, nX1]), oFont01)
			oPrint:Box((nLinIni + 0175 - nWeb)/nTweb, ((nColIni + nColMax)*0.610)/nTweb, (nLinIni + 0269 - nWeb)/nTweb, ((nColIni + nColMax)*0.73 - 0010)/nTweb)
			oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.610 + 0010)/nTweb, "5 - Data da Autorização", oFont01) //5 - Data da Autorização
			oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.610 + 0010)/nTweb, Iif(Empty(aDados[nX, 05, nX1]),'|___|___|/|___|___|/|___|___|___|___|',DToC(aDados[nX, 05, nX1])), oFont01)
			oPrint:Box((nLinIni + 0175 -nWeb)/nTweb, ((nColIni + nColMax)*0.73)/nTweb, (nLinIni + 0269 -nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say((nLinIni + 0180)/nTweb, ((nColIni + nColMax)*0.73 + 0015)/nTweb, "6 - Número da Guia Atribuído pela Operadora", oFont01) //6 - Número da Guia Atribuído pela Operadora
			oPrint:Say((nLinIni + 0220)/nTweb, ((nColIni + nColMax)*0.73 + 0020)/nTweb, Iif(Empty(aDados[nX, 06, nX1]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 06, nX1]), oFont01)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 0)
			AddTBrush(oPrint, (nLinIni + 175)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 206)/nTweb, (nColIni + nColMax)/nTweb)
			oPrint:Say((nLinIni + 178)/nTweb, (nColIni + 0020)/nTweb, "Dados do Beneficiário", oFont01) //Dados do Prestador
			oPrint:Box((nLinIni + 207 - nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300- nWeb)/nTweb, ((nColIni + nColMax)*0.35 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, (nColIni + 0020)/nTweb, "7 - Número da Carteira", oFont01) //7 - Número da Carteira
			oPrint:Say((nLinIni + 252)/nTweb, (nColIni + 0030)/nTweb, Iif(Empty(aDados[nX, 07, nX1]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 07, nX1]), oFont01)
			oPrint:Box((nLinIni + 207 - nWeb)/nTweb, ((nColIni + nColMax)*0.35)/nTweb, (nLinIni + 300- nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.35 + 0020)/nTweb, "8 - Nome", oFont01) //8 - Nome
			oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.35 + 0030)/nTweb, aDados[nX, 08, nX1], oFont04)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 130, 80)
			AddTBrush(oPrint,  (nLinIni + 174)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 205)/nTweb, (nColIni + nColMax)/nTweb)
			oPrint:Say((nLinIni + 178)/nTweb, (nColIni + 0020)/nTweb, "Dados do Profissional Solicitante", oFont01) //Dados do Profissional Solicitante
			oPrint:Box((nLinIni + 207- nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 300- nWeb)/nTweb, ((nColIni + nColMax)*0.45 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, (nColIni + 0020)/nTweb, "9- Nome do Profissional Solicitante", oFont01) //9- Nome do Profissional Solicitante
			oPrint:Say((nLinIni + 252)/nTweb, (nColIni + 0030)/nTweb, aDados[nX, 09, nX1], oFont04)
			oPrint:Box((nLinIni + 207- nWeb)/nTweb, ((nColIni + nColMax)*0.45)/nTweb, (nLinIni + 300- nWeb)/nTweb, ((nColIni + nColMax)*0.65 - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.45 + 0020)/nTweb, "10 - Telefone", oFont01) //10 - Telefone
			oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.45 + 0030)/nTweb, Iif(Empty(aDados[nX, 10, nX1]),'(|___|___|)|___|___|___|___|___|-|___|___|___|___|',aDados[nX, 10, nX1]), oFont01)
			oPrint:Box((nLinIni + 207- nWeb)/nTweb, ((nColIni + nColMax)*0.65)/nTweb, (nLinIni + 300- nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say((nLinIni + 212)/nTweb, ((nColIni + nColMax)*0.65 + 0020)/nTweb, "11 - E-mail", oFont01) //11 - E-mail
			oPrint:Say((nLinIni + 252)/nTweb, ((nColIni + nColMax)*0.65 + 0030)/nTweb, aDados[nX, 11, nX1], oFont04)

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 130, 80)
			AddTBrush(oPrint, (nLinIni + 175)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 206)/nTweb, (nColIni + nColMax)/nTweb)
			oPrint:Say((nLinIni + 178)/nTweb, (nColIni + 0020)/nTweb, "Dados da Cirurgia", oFont01) //Dados da Cirurgia
			oPrint:Box((nLinIni + 209- nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 660- nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say((nLinIni + 214)/nTweb, (nColIni + 0020)/nTweb, "12 - Justificativa Técnica", oFont01) //12 - Justificativa Técnica

			nLinOld := nLinIni

			For nI := 1 To MlCount(aDados[nX, 12, nX1], 130)
				cObs := MemoLine(aDados[nX, 12, nX1], 130, nI)
				oPrint:Say((nLinIni + 252)/nTweb, (nColIni + 0020)/nTweb, cObs, oFont04)
				nLinIni += 40
				If nI == 10
					exit //trunco para nao desconfigurar o relatorio
				Endif
			Next nI

			nLinIni := nLinOld + 400

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 100, 80)
			AddTBrush(oPrint, (nLinIni + 165)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 200)/nTweb, (nColIni + nColMax)/nTweb)
			oPrint:Say((nLinIni + 168)/nTweb, (nColIni + 0020)/nTweb, "OPME Solicitadas", oFont01) //OPME Solicitadas

			oPrint:Box((nLinIni + 204- nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 790- nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say((nLinIni + 210)/nTweb, (nColIni + 0040)/nTweb, "13-Tabela", oFont01) //13-Tabela
			oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.07)/nTweb, "14-Código do Material", oFont01) //14-Código do Material
			oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.22)/nTweb, "15-Descrição", oFont01) //15-Descrição
			oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.51)/nTweb, "16-Opção", oFont01) //16-Opção
			oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.59)/nTweb, "17- Qtde. Sol.", oFont01,,,,1) //17- Qtde. Solicitada
			oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.64)/nTweb, "18- Valor Unitário Solicitado", oFont01,,,,1) //18- Valor Unitário Solicitado
			oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.78)/nTweb, "19- Qtde. Aut.", oFont01,,,,1) //19- Qtde. Autorizada
			oPrint:Say((nLinIni + 210)/nTweb, ((nColIni + nColMax)*0.88)/nTweb, "20- Valor Unitário Autorizado", oFont01,,,,1) //20- Valor Unitário Autorizado

			oPrint:Say((nLinIni + 235)/nTweb, (nColIni + 0040)/nTweb, "21-Registro ANVISA do Material", oFont01) //21-Registro ANVISA do Material
			oPrint:Say((nLinIni + 235)/nTweb, ((nColIni + nColMax)*0.28)/nTweb, "22-Referência do material no fabricante", oFont01) //22-Referência do material no fabricante
			oPrint:Say((nLinIni + 235)/nTweb, ((nColIni + nColMax)*0.6)/nTweb, "23-N?Autorização de Funcionamento", oFont01) //23-N?Autorização de Funcionamento

			For nN := nV To nAte

				oPrint:Say((nLinIni + 270)/nTweb, (nColIni + 0012)/nTweb, AllTrim(Str(nN)) + " - ", oFont01)
				oPrint:Say((nLinIni + 270)/nTweb, (nColIni + 0040)/nTweb, Iif(Empty(aDados[nX, 13, nX1, nN]),'|___|___|',aDados[nX, 13, nX1, nN]), oFont01)
				oPrint:Say((nLinIni + 270)/nTweb, ((nColIni + nColMax)*0.07)/nTweb, Iif(Empty(aDados[nX, 14, nX1, nN]),'|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 14, nX1, nN]), oFont01)
				oPrint:Say((nLinIni + 270)/nTweb, ((nColIni + nColMax)*0.22)/nTweb, Iif(Empty(aDados[nX, 15, nX1, nN]),REPLICATE('_',75),aDados[nX, 15, nX1, nN]), oFont01)
				oPrint:Say((nLinIni + 270)/nTweb, ((nColIni + nColMax)*0.51)/nTweb, Iif(Empty(aDados[nX, 16, nX1, nN]),'|___|',aDados[nX, 16, nX1, nN]), oFont01)
				oPrint:Say((nLinIni + 270)/nTweb, ((nColIni + nColMax)*0.59)/nTweb, IIf(Empty(aDados[nX, 17, nX1, nN]), "|___|___|___|", Transform(aDados[nX, 17, nX1, nN], "@E 9999.99")), oFont01,,,,1)
				oPrint:Say((nLinIni + 270)/nTweb, ((nColIni + nColMax)*0.64)/nTweb, IIf(Empty(aDados[nX, 18, nX1, nN]), "|___|___|___|___|___|___|,|___|___|", Transform(aDados[nX, 18, nX1, nN], "@E 999,999,999.99")), oFont01,,,,1)
				oPrint:Say((nLinIni + 270)/nTweb, ((nColIni + nColMax)*0.78)/nTweb, IIf(Empty(aDados[nX, 19, nX1, nN]), "|___|___|___|", Transform(aDados[nX, 19, nX1, nN], "@E 9999.99")), oFont01,,,,1)
				oPrint:Say((nLinIni + 270)/nTweb, ((nColIni + nColMax)*0.88)/nTweb, IIf(Empty(aDados[nX, 20, nX1, nN]), "|___|___|___|___|___|___|,|___|___|", Transform(aDados[nX, 20, nX1, nN], "@E 999,999,999.99")), oFont01,,,,1)

				oPrint:Say((nLinIni + 310)/nTweb, (nColIni + 0040)/nTweb, Iif(Empty(aDados[nX, 21, nX1, nN]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 21, nX1, nN]), oFont01)
				oPrint:Say((nLinIni + 310)/nTweb, ((nColIni + nColMax)*0.28)/nTweb, Iif(Empty(aDados[nX, 22, nX1, nN]),REPLICATE('_',60),aDados[nX, 22, nX1, nN]), oFont04)
				oPrint:Say((nLinIni + 310)/nTweb, ((nColIni + nColMax)*0.6)/nTweb, Iif(Empty(aDados[nX, 23, nX1, nN]),'|___|___|___|___|___|___|___|___|___|___|___|___|___|___|___|',aDados[nX, 23, nX1, nN]), oFont01)

				fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 85, 60)
			Next

			If nAte < Len(aDados[nX, 13, nX1])
				lImpNovo := .T.
				nAte += 6
				nV := nN
			EndIf

			nLinIni := 1530

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 120, 80)
			oPrint:Box((nLinIni + 178- nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 370- nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say((nLinIni + 183)/nTweb, (nColIni + 0020)/nTweb, "24 - Especificação do Material", oFont01) //24 - Especificação do Material

			nLinOld := nLinIni

			For nI := 1 To MlCount(aDados[nX, 24, nX1], 130)
				cObs := MemoLine(aDados[nX, 24, nX1], 130, nI)
				oPrint:Say((nLinIni + 210)/nTweb, (nColIni + 0020)/nTweb, cObs, oFont04)
				nLinIni += 40
				If nI == 4
					exit //trunco para nao desconfigurar o relatorio
				Endif
			Next nI

			nLinIni := nLinOld + 160

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
			AddTBrush(oPrint, (nLinIni + 178)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 370)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Box((nLinIni + 178- nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 370- nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say((nLinIni + 183)/nTweb, (nColIni + 0020)/nTweb, "25- Observação / Justificativa", oFont01) //25- Observação / Justificativa

			nLinOld := nLinIni

			For nI := 1 To MlCount(aDados[nX, 25, nX1], 130)
				cObs := MemoLine(aDados[nX, 25, nX1], 130, nI)
				oPrint:Say((nLinIni + 210)/nTweb, (nColIni + 0020)/nTweb, cObs, oFont04)
				nLinIni += 40
				If nI == 4
					exit //trunco para nao desconfigurar o relatorio
				Endif
			Next nI

			nLinIni := nLinOld + 160

			fSomaLin(nLinMax, nColMax, @nLinIni, nColIni, 50, 80)
			oPrint:Box((nLinIni + 178- nWeb)/nTweb, (nColIni + 0010)/nTweb, (nLinIni + 272- nWeb)/nTweb, ((nColIni + nColMax)*0.17 - 0010)/nTweb)
			oPrint:Say((nLinIni + 183)/nTweb, (nColIni + 0020)/nTweb, "26 - Data da Solicitação", oFont01) //26 - Data da Solicitação
			oPrint:Say((nLinIni + 223)/nTweb, (nColIni + 0030 + 0030)/nTweb, Iif(Empty(aDados[nX, 26, nX1]),'|___|___|/|___|___|/|___|___|___|___|',DToC(aDados[nX, 26, nX1])), oFont01)
			oPrint:Box((nLinIni + 178- nWeb)/nTweb, ((nColIni + nColMax)*0.17)/nTweb, (nLinIni + 272- nWeb)/nTweb, ((nColIni + nColMax)*0.55 - 0010)/nTweb)
			oPrint:Say((nLinIni + 183)/nTweb, ((nColIni + nColMax)*0.17 + 0020)/nTweb, "27- Assinatura do Profissional Solicitante", oFont01) //27- Assinatura do Profissional Solicitante
			oPrint:Box((nLinIni + 178- nWeb)/nTweb, ((nColIni + nColMax)*0.55)/nTweb, (nLinIni + 272- nWeb)/nTweb, (nColIni + nColMax - 0010)/nTweb)
			oPrint:Say((nLinIni + 183)/nTweb, ((nColIni + nColMax)*0.55 + 0020)/nTweb, "28- Assinatura do Responsável pela Autorização", oFont01) //28- Assinatura do Responsável pela Autorização

			oPrint:EndPage()	// Finaliza a pagina

		EndDo

	Next nX1


Next nX

If lWeb
	oPrint:Print()
Else
	oPrint:Preview()
Endif

Return cFileName

Static Function TrataErro(e, cErro,nPos)

//Local cArq		:= ""
Local lRet	:= e:gencode > 0

If lRet
	cErro 	+= "Posição: " + STR(nPos,3) + "; Descrição: " + e:Description + CRLF
EndIf


Return lRet

Static Function fLogoEmp(cLogo, cTipo, cLogoGH)

Local cStartPath	:= GetSrvProfString("STARTPATH","")

Default cTipo	:= "1"
Default cLogoGH := ""

If ValType(cLogoGH) <> "U" .And. !Empty(cLogoGH) .And. File(cLogoGH) //logo a partir do campo do Gestao Hospitalar
	cLogo := cLogoGH
Else // Logotipo da Empresa
	If cTipo == "1"
		cLogo := cStartPath + "\LGRL" + FWCompany() + FWCodFil() + ".BMP"	// Empresa+Filial
	Else
		cLogo := cStartPath + "\LGRL" + FWCompany() + ".BMP"				// Empresa
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AjusPath

Ajuste provisorio do path do objeto 

@Observ  Solucao de contorno ate sair o path do frame
@version P12
@since   25/09/2020
/*/
//-------------------------------------------------------------------
Static Function AjusPath(oPrint)

	oPrint:cFilePrint := StrTran(oPrint:cFilePrint,"\","/",1)
	oPrint:cPathPrint := StrTran(oPrint:cPathPrint,"\","/",1)
	oPrint:cFilePrint := StrTran(oPrint:cFilePrint,"//","/",1)
	oPrint:cPathPrint := StrTran(oPrint:cPathPrint,"//","/",1)

Return