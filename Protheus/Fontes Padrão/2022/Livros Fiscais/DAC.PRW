#Include "Protheus.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DAC       ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³DAC - Declaracao de Atividades do Contribuinte - Governo do ³±±
±±³          ³      de Alagoas                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function DAC()

Private aCfp := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivos temporarios            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GeraTemp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina Cfp                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Cfp()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recupera dados do arquivo Cfp                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xMagLeWiz("DAC",@aCfp,.T.)
	
	Processa({||ProcDAC()})
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcDAC    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro da DAC                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcDAC()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao do Mes de Abril                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lAbril := (Month(dDmafin)==4)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Periodo para processamento Anual somente quando gerado o Mes de Abril   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private dProcIni := CtoD(Substr(aCfp[1][15],7,2)+"/"+SubStr(aCfp[1][15],5,2)+"/"+SubStr(aCfp[1][15],3,2))
Private dProcFim := CtoD("31/12/"+StrZero(Year(dDmaFin)-1,4))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 00 - Cabecalho do Arquivo                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcReg00()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Regitros                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If _aTotal[99]
	ProcReg01()			 					//Registro Tipo 01 - Enderecos de Correio Eletronico
	ProcReg10() 							//Registro Tipo 10 - Identificador da declaracao
	If Alltrim(aCfp[1][02])=="Mensal"	 	//Informacoes Mensais
		ProcRegEnt() 						//Processa Registros de Entrada
		ProcRegSai() 						//Processa Registros de Saida
		ProcReg313()						//Registro Tipo 31 e 33 - Apuracao do ICMS e Detalhamento de Outros Debitos e Outros Creditos do ICMS
		ProcReg41()							//Registro Tipo 41 - Obrigacoes Fiscais Apuradas
		ProcReg42()							//Registro Tipo 42 - Obrigacoes Fiscais Apuradas e Obrigacoes Fiscais Pagas
	Endif
	If Alltrim(aCfp[1][02])=="Anual" .Or. lAbril
		ProcReg61()							//Registro Tipo 61
		ProcReg63()							//Registro Tipo 63 - Operacoes realizadas por UF - Entradas
		ProcReg64()							//Registro Tipo 64 - Operacoes realizadas por UF - Saidas
		ProcReg65()							//Registro Tipo 65 - Estoque e Balanco
	Endif
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg00  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo 00 - Cabecalho do Arquivo             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg00()

dbSelectArea("R00")
RecLock("R00",.T.)
R00->IE			:= aFisFill(SM0->M0_INSC,9)
R00->TP_DECLARA	:= IIf(Alltrim(aCfp[1][1])=="Original","O","R")
R00->PERIODO	:= IIf(Alltrim(aCfp[1][2])=="Mensal","M",IIf(Alltrim(aCfp[1][2])=="Quadrimestral","Q","A"))
R00->COMPETENC	:= RetAM(Alltrim(aCfp[1][2]))		//Competencia da Declaracao - AAAAMM 
R00->SIMPLES	:= Alltrim(aCfp[1][16])    	//Contribuinte simples nacional
MsUnlock()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg01  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Enderecos de Correio Eletronico                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg01()

dbSelectArea("R01")
RecLock("R01",.T.)
R01->ECONTRIB	:= Alltrim(aCfp[1][05])	//E-mail do Contribuinte
R01->ECONT		:= Alltrim(aCfp[1][11])	//E-mail do Contador
R01->ERESP		:= Alltrim(aCfp[1][07])	//E-mail do Responsavel
R01->TELCONT	:= Alltrim(aCfp[1][14])	//Telefone do Contador
R01->TELRESP	:= Alltrim(aCfp[1][09])	//Telefone do Responsavel
MsUnlock()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg10  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Identificador da Declaracao                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg10()

Local aPeriodo	:= {"",""}
           
RetAM(Alltrim(aCfp[1][2]),@aPeriodo)

dbSelectArea("R10")
RecLock("R10",.T.)
R10->CACEAL		:= aFisFill(SM0->M0_INSC,9)
R10->CNPJCPF	:= aFisFill(aRetDig(SM0->M0_CGC,.F.),14)
R10->RAZSOC		:= SM0->M0_NOMECOM
R10->PERINI		:= aPeriodo[1]						
R10->PERFIM		:= aPeriodo[2]						
R10->DTINI		:= Dtos(dDmaInc)
R10->DTFIM		:= Dtos(dDmaFin)
R10->INDMOV		:= Left(Alltrim(aCfp[1][03]),1)	//Declaracao com Movimento
R10->CAMPO10	:= "00"								//Faixa de Recolhimento (Recalculado pelo Sistema)
R10->CAMPO11	:= "00"								//Obrigatorio EPP e ME
R10->CRC		:= Alltrim(aCfp[1][13]) 			//CRC do Contador
R10->CPFCONT	:= Alltrim(aCfp[1][12])			//CPF do Contador
R10->NOMECONT	:= Alltrim(aCfp[1][10])			//Nome do Contador
R10->CPFRESP	:= Alltrim(aCfp[1][08])			//CPF do Responsavel
R10->NOMERESP	:= Alltrim(aCfp[1][11])			//Responsavel 
R10->INDENC		:= Left(Alltrim(aCfp[1][04]),1)	//Indicador de Encerramento
R10->SIMPLES	:= Alltrim(aCfp[1][16])    		//Contribuinte simples nacional
MsUnlock()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegEnt ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registros de Entrada                                ³±±
±±³          ³Regitro 21: Entradas de Mercadorias, Bens e/ou Aquisicao de  ³±±
±±³          ³            Servicos de Transporte e Comunicacao             ³±±
±±³          ³Regitro 25: Totais de Entradas de Mercadorias, Bens e/ou     ³±±
±±³          ³            Servicos de Transporte e Comunicacao adquiridas  ³±±
±±³          ³            exclusivamente dos estados do Sul e Sudeste,     ³±±
±±³          ³            exceto Espirito Santo                            ³±±
±±³          ³Regitro 43: Entrada Interestaduais de Produtos com ST -      ³±±
±±³          ³            Fornecedor inscrito no CACEAL                    ³±±
±±³          ³Regitro 44: Entrada Interestaduais de Produtos com ST -      ³±±
±±³          ³            Fornecedor nao inscrito no CACEAL                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegEnt()

Local cDbf			:= "F3_FILIAL=='"+xFilial("SF3")+"' .AND. DTOS(F3_ENTRADA)>='"+Dtos(dDmaInc)+"' .AND. DTOS(F3_ENTRADA)<='"+Dtos(dDmaFin)+"' .AND. LEFT(F3_CFO,1)<'5' .AND. F3_TIPO<>'S' .AND. EMPTY(F3_DTCANC)"
Local cTop			:= "F3_FILIAL='"+xFilial("SF3")+"' AND F3_ENTRADA>='"+Dtos(dDmaInc)+"' AND F3_ENTRADA<='"+Dtos(dDmaFin)+"' AND (F3_CFO LIKE '1%' OR F3_CFO LIKE '2%' OR F3_CFO LIKE '3%') AND F3_TIPO NOT IN('S') AND F3_DTCANC=''"
Local aArq			:= {"SF3",""}
Local cMesRef		:= ""
Local cCfop			:= ""
Local aPeriodo		:= {"",""}
Local cSulSudeste	:= "RS/SC/PR/SP/RJ/MG"			//Estados do Sul e Sudeste exceto ES-Espirito Santo	
Local lReg25		:= .T.							//Registro Novo
Local lReg43		:= .T.							//Registro Novo
Local lReg44		:= .T.					  		//Registro Novo
Local cIE			:= ""
Local cCNPJ			:= ""
           
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna o Periodo Inicial/Final                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetAM(Alltrim(aCfp[1][2]),@aPeriodo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Entrada                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF3")
FsQuery(aArq,1,cTop,cDbf,SF3->(IndexKey()))
dbGoTop()
While !Eof()

	cMesRef := Left(Dtos(SF3->F3_ENTRADA),6)
	cCfop	:= aFisFill(SF3->F3_CFO,4)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava Registro 21                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SF3->F3_VALCONT > 0
		dbSelectArea("R21")
		dbSetOrder(1)
		If !dbSeek(cCfop+cMesRef)
			RecLock("R21",.T.)	
			R21->MESREF		:= cMesRef
			R21->PERINI		:= aPeriodo[1]
			R21->PERFIM		:= aPeriodo[2]
			R21->CFOP		:= cCfop
		Else
			RecLock("R21",.F.)
	    Endif
		R21->VALCONT	+= SF3->F3_VALCONT
		R21->BASEICM	+= SF3->F3_BASEICM
		R21->VALICM		+= SF3->F3_VALICM
		R21->ISENICM	+= SF3->F3_ISENICM
		R21->OUTRICM	+= SF3->F3_OUTRICM
		R21->VLRCONT	+= 0					//Valor Contabil de Mercadorias c/ICMS Antecipado
		MsUnlock()
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava Registro 25                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Left(Alltrim(SF3->F3_CFO),1)=="2" .And. SF3->F3_VALCONT > 0 .And. RetDados("UF","E")$cSulSudeste
		dbSelectArea("R25")
		If lReg25
			RecLock("R25",.T.)	
			R25->PERINI		:= aPeriodo[1]
			R25->PERFIM		:= aPeriodo[2]
			R25->TPOPER		:= "4"				//Valor Constante
			lReg25			:= .F.
		Else
			RecLock("R25",.F.)
			dbGoto(1)
	    Endif
		R25->VALCONT	+= SF3->F3_VALCONT
		R25->BASEICM	+= SF3->F3_BASEICM
		R25->VALICM		+= SF3->F3_VALICM
		R25->ISENICM	+= SF3->F3_ISENICM
		R25->OUTRICM	+= SF3->F3_OUTRICM
		R25->VLRCONT	+= 0
		MsUnlock()
	Endif
	
	If Left(Alltrim(SF3->F3_CFO),1)=="2" .And. SF3->F3_BASERET > 0 .And. !(SF3->F3_TIPO$"DB")
		cIE		:= RetDados("IE","E")		//IE
		cCNPJ	:= RetDados("CNPJ","E")		//CNPJ
		If Left(cIE,3)=="245"	//Contribuinte ST
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava Registro 43                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("R43")
			If lReg43
				RecLock("R43",.T.)	
				R43->CACEAL	:= aFisFill(cIE,11)		//Inscricao Estadual
				lReg43		:= .F.
			Else
				RecLock("R43",.F.)
				dbGoto(1)
		    Endif
			R43->BASERET	+= SF3->F3_BASERET
			R43->ICMSRET	+= SF3->F3_ICMSRET
			MsUnlock()
        Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava Registro 44                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("R44")
			If lReg44
				RecLock("R44",.T.)	
				R44->CNPJ	:= StrZero(Val(aRetDig(cCNPJ,.F.)),14)		//CNPJ
				R44->TPGUIA	:= "G"										//G-GNRE ou D-DAR
				lReg44		:= .F.
			Else
				RecLock("R44",.F.)
				dbGoto(1)
		    Endif
			R44->BASERET	+= SF3->F3_BASERET
			R44->ICMSRET	+= SF3->F3_ICMSRET
			MsUnlock()
		Endif
	Endif
	
	dbSelectArea("SF3")
	dbSkip()
Enddo
FsQuery(aArq,2)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegSai ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registros de Saida                                  ³±±
±±³          ³Registro 22: Saidas de Mercadorias, Bens e/ou Aquisicao de   ³±±
±±³          ³             Servicos de Transporte e Comunicacao            ³±±
±±³          ³Registro 45: Relatorio de Notas Fiscais                      ³±±
±±³          ³Registro 46: Notas Fiscais Canceladas                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegSai()

Local cDbf		:= "F3_FILIAL=='"+xFilial("SF3")+"' .AND. DTOS(F3_ENTRADA)>='"+Dtos(dDmaInc)+"' .AND. DTOS(F3_ENTRADA)<='"+Dtos(dDmaFin)+"' .AND. LEFT(F3_CFO,1)>='5' .AND. F3_TIPO<>'S'"
Local cTop		:= "F3_FILIAL='"+xFilial("SF3")+"' AND F3_ENTRADA>='"+Dtos(dDmaInc)+"' AND F3_ENTRADA<='"+Dtos(dDmaFin)+"' AND (F3_CFO LIKE '5%' OR F3_CFO LIKE '6%' OR F3_CFO LIKE '7%') AND F3_TIPO NOT IN('S')"
Local aArq		:= {"SF3",""}
Local cMesRef	:= ""
Local cCfop		:= ""
Local aPeriodo	:= {"",""}
Local cIE		:= ""
Local aAIDF		:= {}
           
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna o Periodo Inicial/Final                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetAM(Alltrim(aCfp[1][2]),@aPeriodo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Entrada                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF3")
FsQuery(aArq,1,cTop,cDbf,SF3->(IndexKey()))
dbGoTop()
While !Eof()

	cMesRef := Left(Dtos(SF3->F3_ENTRADA),6)
	cCfop	:= aFisFill(SF3->F3_CFO,4)
	cIE 	:= RetDados("IE","S")	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava Registro 22                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SF3->F3_VALCONT > 0 .And. Empty(SF3->F3_DTCANC)
		dbSelectArea("R22")
		dbSetOrder(1)
		If !dbSeek(cCfop+cMesRef)
			RecLock("R22",.T.)	
			R22->MESREF		:= cMesRef
			R22->PERINI		:= aPeriodo[1]
			R22->PERFIM		:= aPeriodo[2]
			R22->CFOP		:= cCfop
		Else
			RecLock("R22",.F.)
	    Endif
		R22->VALCONT	+= SF3->F3_VALCONT
		R22->BASEICM	+= SF3->F3_BASEICM
		R22->VALICM		+= SF3->F3_VALICM
		R22->ISENICM	+= SF3->F3_ISENICM
		R22->OUTRICM	+= SF3->F3_OUTRICM
		R22->VLRCONT	+= 0					//Valor Contabil de Mercadorias c/ICMS Antecipado
		MsUnlock()
	Endif

	If Left(Alltrim(SF3->F3_CFO),1)=="6" .And. SF3->F3_TIPO=="D" .And. SF3->F3_BASERET > 0 .And. Empty(SF3->F3_DTCANC)
		If Left(cIE,3)=="245"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava Registro 43 - Devolucoes de Compra ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If R43->(LastRec()) > 0 
				dbSelectArea("R43")
				dbGoTop()
				RecLock("R43",.F.)	
				R43->DEVOL		+= SF3->F3_BASERET		//Devolucoes
				R43->ICMSDEV	+= SF3->F3_ICMSRET		//ICMS Devolucoes
				MsUnlock()
			Endif
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava Registro 44 - Devolucoes de Compra ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If R44->(LastRec()) > 0
				dbSelectArea("R44")
				dbGoTop()
				RecLock("R44",.F.)
				R44->DEVOL		+= SF3->F3_BASERET		//Devolucoes
				R44->ICMSDEV	+= SF3->F3_ICMSRET		//ICMS Devolucoes
				MsUnlock()
			Endif
		Endif
    Endif
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava Registro 45                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAIDF := RetAIDF(SF3->F3_SERIE,SF3->F3_NFISCAL)
	If aAIDF[1]
		dbSelectArea("R45")
		dbSetOrder(1)
		If !dbSeek(aAIDF[2])
			RecLock("R45",.T.)
			R45->AIDF		:= aAIDF[2]
			R45->MODELO		:= Alltrim(Str(Val(aModNot(SF3->F3_ESPECIE))))
			R45->ESPECIE	:= RetEspecie(aModNot(SF3->F3_ESPECIE))
			R45->SERIE		:= IIf(Left(SerieNfId("SF3",2,"F3_SERIE"),1)=="U","U ",Left(SerieNfId("SF3",2,"F3_SERIE"),2))
			R45->SUBSERIE	:= ""
			R45->NFINI		:= SF3->F3_NFISCAL
			R45->NFFIM		:= SF3->F3_NFISCAL
			R45->(MsUnlock())
		Else
			RecLock("R45",.F.)
			If Val(SF3->F3_NFISCAL) < Val(R45->NFINI)
				R45->NFINI := SF3->F3_NFISCAL
			Else
				If Val(SF3->F3_NFISCAL) > Val(R45->NFFIM)
					R45->NFFIM := SF3->F3_NFISCAL
				Endif
			Endif
			R45->(MsUnlock())			
		Endif
		If !Empty(SF3->F3_DTCANC)	//NF Canceladas
			dbSelectArea("R46")
			dbSetOrder(1)
			If !dbSeek(aAIDF[2]+SF3->F3_NFISCAL)
				RecLock("R45",.F.)
				R45->NFCANC += 1
				R45->(MsUnlock())

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava Registro 46                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("R46",.T.)
				R46->AIDF		:= aAIDF[2]
				R46->MODELO		:= Alltrim(Str(Val(aModNot(SF3->F3_ESPECIE))))
				R46->ESPECIE	:= RetEspecie(aModNot(SF3->F3_ESPECIE))
				R46->SERIE		:= IIf(Left(SerieNfId("SF3",2,"F3_SERIE"),1)=="U","U ",Left(SerieNfId("SF3",2,"F3_SERIE"),2))
				R46->SUBSERIE	:= ""
				R46->NFINI		:= SF3->F3_NFISCAL
				R46->NFFIM		:= SF3->F3_NFISCAL
				R46->NFISCAL	:= SF3->F3_NFISCAL
				R46->(MsUnlock())
			Endif	
    	Endif
    Endif
	dbSelectArea("SF3")
	dbSkip()
Enddo
FsQuery(aArq,2)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg313 ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Registro Tipo 31 - Apuracao do ICMS                          ³±±
±±³Descricao ³Registro Tipo 32 - Apuracao do ICMS - Produtor Rural		  ³±±
±±³          ³              33 - Detalhamento de Outros Debitos e Outros   ³±±
±±³          ³                   Creditos do ICMS                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg313()

Local lProdRur	:= !Empty(SM0->M0_PRODRUR)
Local aRegAP		:= {}
Local aReg33		:= {}
Local aPeriodo	:= {"",""}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna o Periodo Inicial/Final                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetAM(Alltrim(aCfp[1][2]),@aPeriodo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera Tabela da Apuracao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FisApur("IC", Year(dDmaFin), Month(dDmaFin), 3, 1, "*", .F., {}, 1, .T., "APU")

aRegAP	:= {0,0,"",0,"",0,"",0,0,0,0,0,0}
aReg33	:= {0,"",0,"",0,0,0}
	
dbSelectArea("APU")
dbGoTop()
While !Eof() 
	Do Case
		Case Alltrim(APU->CODIGO)=="002" .And. AllTrim(APU->SUBCOD)=="002.00"
			aReg33[1]		:= APU->VALOR		//Outros Debitos
		Case Alltrim(APU->CODIGO)=="002" .And. AllTrim(APU->SUBCOD)<>"002.00"
			aReg33[2]		+= APU->DESCR		//Historico de Outros Debitos
		Case Alltrim(APU->CODIGO)=="006" .And. AllTrim(APU->SUBCOD)=="006.00"
			aReg33[3]		:= APU->VALOR		//Outros Creditos
		Case Alltrim(APU->CODIGO)=="006" .And. AllTrim(APU->SUBCOD)<>"006.00"
			aReg33[4]		+= APU->DESCR		//Historico de Outros Creditos
		Case Alltrim(APU->CODIGO)=="021"
			aReg33[5]		:= APU->VALOR		//Credito Recebido por Transferencia
		Case Alltrim(APU->CODIGO)=="009"
			aRegAP[1]		:= APU->VALOR		//Saldo Credor do Periodo Anterior
		Case Alltrim(APU->CODIGO)=="012" .And. AllTrim(APU->SUBCOD)=="012.00"
			aRegAP[2]		:= APU->VALOR		//Deducoes
		Case Alltrim(APU->CODIGO)=="012" .And. AllTrim(APU->SUBCOD)<>"012.00"
			aRegAP[3]		+= APU->DESCR		//Historico de Deducoes
		Case Alltrim(APU->CODIGO)=="003" .And. AllTrim(APU->SUBCOD)=="003.00"
			aRegAP[4]		:= APU->VALOR		//Estorno de Credito
		Case Alltrim(APU->CODIGO)=="003" .And. AllTrim(APU->SUBCOD)<>"003.00"
			aRegAP[5]		+= APU->DESCR		//Historico Estorno de Credito
		Case Alltrim(APU->CODIGO)=="007" .And. AllTrim(APU->SUBCOD)=="007.00"
			aRegAP[6]		:= APU->VALOR		//Estorno de Debito
		Case Alltrim(APU->CODIGO)=="007" .And. AllTrim(APU->SUBCOD)<>"007.00"
			aRegAP[7]		+= APU->DESCR		//Historico Estorno de Debito
		Case Alltrim(APU->CODIGO)=="004"
			aRegAP[8]		-= APU->VALOR		//Saldo do ICMS para o periodo seguinte
			aRegAP[10]	:= APU->VALOR		//Total do debito do ICMS
		Case Alltrim(APU->CODIGO)=="010"
			aRegAP[8]		+= APU->VALOR		//Saldo do ICMS para o periodo seguinte
		Case Alltrim(APU->CODIGO)=="001"
			aRegAP[9]		+= APU->VALOR		//Valor das saidas com debito do imposto
		Case Alltrim(APU->CODIGO)=="005"
			aRegAP[11]	+= APU->VALOR		//Valor das entradas com credito do imposto
		Case Alltrim(APU->CODIGO)=="008"
			aRegAP[12]	+= APU->VALOR		//Total do credito do ICMS
		Case Alltrim(APU->CODIGO)=="015"
			aRegAP[13]	+= APU->VALOR		//ICMS Retido por ST
		Case Alltrim(APU->CODIGO)=="019"
			aReg33[6]		:= APU->VALOR		//Credito Ativo Imobilizado
		Case Alltrim(APU->CODIGO)=="025"
			aReg33[7]		:= APU->VALOR		//Credito Presumido
	EndCase
	dbSelectArea("APU")
	dbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fecha Tabela da Apuracao           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("APU")
dbCloseArea()

If !lProdRur
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava Registro 31                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("R31")
	RecLock("R31",.T.)
	R31->PERINI 		:= aPeriodo[1]
	R31->PERFIM 		:= aPeriodo[2]
	R31->SLDCREDANT	:= aRegAP[1]	//Saldo Credor do Periodo Anterior
	R31->DEDUCAO		:= aRegAP[2]	//Deducoes
	R31->HDEDUCAO		:= aRegAP[3]	//Historico de Deducoes
	R31->SLDPERISEG	:= aRegAP[8]	//Saldo do ICMS para o periodo seguinte	
	R31->ICMSDEBIT	:= aRegAP[9]	//Valor das saidas com debito do imposto	
	R31->TOTOUTDEB	:= aReg33[1]	//Outros Debitos	
	R31->ESTCRED		:= aRegAP[4]	//Estorno de Credito
	R31->HESTCRED		:= aRegAP[5]	//Historico Estorno de Credito
	R31->TOTDEB		:= aRegAP[10]	//Total do debito do ICMS
	R31->ICMSCREDI	:= aRegAP[11]	//Valor das entradas com credito do imposto
	R31->TOTOUTCRE	:= aReg33[3]	//Outros Creditos	
	R31->ESTDEB		:= aRegAP[6]	//Estorno de Debito
	R31->HESTDEB		:= aRegAP[7]	//Historico Estorno de Debito
	R31->TOTCRED		:= aRegAP[12]	//Total do credito do ICMS
	MsUnlock()
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava Registro 32                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("R32")
	RecLock("R32",.T.)
	R32->PERINI 		:= aPeriodo[1]
	R32->PERFIM 		:= aPeriodo[2]
	R32->SLDCREDANT	:= aRegAP[1]	//Saldo Credor do Periodo Anterior
	R32->DEDUCAO		:= aRegAP[2]	//Deducoes
	R32->HDEDUCAO		:= aRegAP[3]	//Historico de Deducoes
	R32->SLDPERISEG	:= aRegAP[8]	//Saldo do ICMS para o periodo seguinte	
	R32->ICMSDEBIT	:= aRegAP[9]	//Valor das saidas com debito do imposto	
	R32->TOTOUTDEB	:= aReg33[1]	//Outros Debitos	
	R32->ESTCRED		:= aRegAP[4]	//Estorno de Credito
	R32->HESTCRED		:= aRegAP[5]	//Historico Estorno de Credito
	R32->TOTDEB		:= aRegAP[10]	//Total do debito do ICMS
	R32->ICMSCREDI	:= aRegAP[11]	//Valor das entradas com credito do imposto
	R32->TOTOUTCRE	:= aReg33[3]	//Outros Creditos	
	R32->ESTDEB		:= aRegAP[6]	//Estorno de Debito
	R32->HESTDEB		:= aRegAP[7]	//Historico Estorno de Debito
	R32->TOTCRED		:= aRegAP[12]	//Total do credito do ICMS
	R32->ICMSRETST	:= aRegAP[13]	//ICMS Retido por ST
	MsUnlock()
Endif	
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava Registro 33                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (R31->(LastRec()) > 0 .Or. R32->(LastRec()) > 0) .And. aReg33[1]+aReg33[3] > 0
	dbSelectArea("R33")
	RecLock("R33",.T.)
	R33->PERINI 		:= aPeriodo[1]
	R33->PERFIM 		:= aPeriodo[2]
	R33->TRANSAC		:= 0			//Transferencia de Creditos Acumulados
	R33->OUTDEB		:= StrTran(Alltrim(Transform(aReg33[1],"@E 9999999999.99")),",","")	//Outros Debitos
	R33->HOUTDEB		:= aReg33[2]	//Historico de Outros Debitos
	R33->ICMANTEC		:= 0			//ICMS Antecipado
	R33->CREDPRES		:= StrTran(Alltrim(Transform(aReg33[7],"@E 9999999999.99")),",","")	//Credito Presumido
	R33->CRDPRE21		:= 0			//Credito Presumido Art. 21
	R33->CRDATIVO		:= StrTran(Alltrim(Transform(aReg33[6],"@E 9999999999.99")),",","")	//Credito Ativo Imobilizado
	R33->CREDTRANS	:= StrTran(Alltrim(Transform(aReg33[5],"@E 9999999999.99")),",","")	//Credito Recebido por Transferencia
	R33->ICMIMPOR		:= 0			//ICMS Importacao
	R33->ICMRESTI		:= 0			//ICMS Restituicao
	R33->OUTCRED		:= StrTran(Alltrim(Transform(aReg33[3],"@E 9999999999.99")),",","")	//Outros Creditos
	R33->HOUTCRED		:= aReg33[4]	//Historico de Outros Creditos
	MsUnlock()	
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg41  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Registro Tipo 41 - Obrigacoes Fiscais Apuradas               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg41()

Local cDbf		:= "F6_FILIAL=='"+xFilial("SF6")+"' .AND. (F6_MESREF >='"+AllTrim(Str(Month(dDmaInc)))+"' .AND. F6_MESREF <='"+AllTrim(Str(Month(dDmaFin)))+"') .AND.(F6_ANOREF >='"+AllTrim(Str(Year(dDmaInc)))+"' .AND. F6_ANOREF <='"+AllTrim(Str(Year(dDmaFin)))+"') .AND. DTOS(F6_DTARREC)>='"+Dtos(dDmaInc)+"'"
Local cTop		:= "F6_FILIAL='"+xFilial("SF6")+"'   AND (F6_MESREF BETWEEN '"+AllTrim(Str(Month(dDmaInc)))+"' AND '"+AllTrim(Str(Month(dDmaFin)))+"') AND (F6_ANOREF BETWEEN '"+AllTrim(Str(Year(dDmaInc)))+"' AND '"+AllTrim(Str(Year(dDmaFin)))+"') AND F6_DTARREC>='"+Dtos(dDmaInc)+"'"
Local aArq		:= {"SF6",""}
Local aPeriodo	:= {"",""}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna o Periodo Inicial/Final                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetAM(Alltrim(aCfp[1][2]),@aPeriodo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Entrada                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF6")
FsQuery(aArq,1,cTop,cDbf,SF6->(IndexKey()))
dbGoTop()
While !Eof()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava Registro 41                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SF6->F6_DTVENC > dDmaInc
		dbSelectArea("R41")
		RecLock("R41",.T.)
		R41->PERINI	:= aPeriodo[1]
		R41->PERFIM	:= aPeriodo[2]
		R41->CODREC	:= StrZero(Val(SF6->F6_CODREC),5)	//Codigo da Receita
		R41->DTVENC	:= SF6->F6_DTVENC					//Data de Vencimento
		R41->VALOR	:= SF6->F6_VALOR					//Valor da Receita
		MsUnlock()
	Endif
	dbSelectArea("SF6")
	dbSkip()
Enddo
FsQuery(aArq,2)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg42  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Registro Tipo 42 - Obrigacoes Fiscais Pagas                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg42()

Local cDbf		:= "F6_FILIAL=='"+xFilial("SF6")+"' .AND. DTOS(F6_DTVENC)>='"+Dtos(dDmaInc)+"' .AND. DTOS(F6_DTVENC)<='"+Dtos(dDmaFin)+"'"
Local cTop		:= "F6_FILIAL='"+xFilial("SF6")+"' AND F6_DTVENC>='"+Dtos(dDmaInc)+"' AND F6_DTVENC<='"+Dtos(dDmaFin)+"'"
Local aArq		:= {"SF6",""}
Local aPeriodo	:= {"",""}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna o Periodo Inicial/Final                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetAM(Alltrim(aCfp[1][2]),@aPeriodo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Entrada                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF6")
FsQuery(aArq,1,cTop,cDbf,SF6->(IndexKey()))
dbGoTop()
While !Eof()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava Registro 42                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("R42")
	RecLock("R42",.T.)
	R42->CODREC	:= StrZero(Val(SF6->F6_CODREC),5)	//Codigo da Receita
	R42->DTPAG	:= SF6->F6_DTVENC					//Data do efetivo pagamento do Tributo
	R42->VALOR	:= SF6->F6_VALOR					//Valor da Receita
	R42->AGENT	:= SF6->F6_BANCO					//Codigo do Agente Arrecadador
	R42->DESCR	:= RetBanco()						//Descricao do Agente Arrecador
	MsUnlock()

	dbSelectArea("SF6")
	dbSkip()
Enddo
FsQuery(aArq,2)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg61  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Registro Tipo 61 - Municipios: Operacoes Internas de Produtos³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg61()

Local cDbf		:= ""
Local cTop		:= ""
Local aArq		:= {"SD1",""}
Local cA2CodMun	:= GetNewPar("MV_DAC01","")		//Campo do SA2 que contem o Codigo do Municipio, conforme tabela da DAC
Local lA2CodMun	:= SA2->(FieldPos(cA2CodMun)) > 0
Local cCodMun	:= ""
Local cB5Codigo	:= GetNewPar("MV_DAC02","")		//Campo do SB5 que contem o Codigo do Produto e/ou Servico, conforme tabela da DAC
Local lB5Codigo	:= SB5->(FieldPos(cB5Codigo)) > 0
Local cCodigo	:= ""
Local dDtIni	:= dDmaInc
Local dDtFim	:= dDmaFin

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento do Filtro para Mes Abril³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAbril	//Mes de Abril entrega anual do ano anterior a partir 2003
	dDtIni := dProcIni
	dDtFim := dProcFim
Endif
cDbf := "D1_FILIAL=='"+xFilial("SD1")+"' .AND. DTOS(D1_DTDIGIT)>='"+Dtos(dDtIni)+"' .AND. DTOS(D1_DTDIGIT)<='"+Dtos(dDtFim)+"' .AND. LEFT(D1_CF,1)=='1' .AND. D1_TIPO$'N'"
cTop := "D1_FILIAL='"+xFilial("SD1")+"' AND D1_DTDIGIT>='"+Dtos(dDtIni)+"' AND D1_DTDIGIT<='"+Dtos(dDtFim)+"' AND D1_CF LIKE '1%' AND D1_TIPO='N'"

dbSelectArea("SD1")
FsQuery(aArq,1,cTop,cDbf,SD1->(IndexKey()))
dbGoTop()
While !Eof()

	If lA2CodMun .And. lB5Codigo
		cCodMun := RetCodMun("E",cA2CodMun)
		cCodigo := RetCodigo("E",cB5Codigo)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava Registro 61                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cA2CodMun) .And. !Empty(cB5Codigo)
			dbSelectArea("R61")
			dbSetOrder(1)
			If !dbSeek(cCodMun)
				RecLock("R61",.T.)
				R61->CODMUN	:= cCodMun			//Codigo do Municipio
			Else
				RecLock("R61",.F.)
			Endif
			R61->CODPROD	:= cCodigo			//Codigo do Produto
			R61->QTDE		+= SD1->D1_QUANT	//Quantidade 
			R61->VALOR		+= SD1->D1_TOTAL	//Valor Total
			MsUnlock()		
		Endif
	Endif
	
	dbSelectArea("SD1")
	dbSkip()
Enddo	
FsQuery(aArq,2)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg63  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Regitro 63: Operacoes realizadas por UF - Entradas           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg63()

Local cDbf			:= ""
Local cTop			:= ""
Local aArq			:= {"SF3",""}
Local cUf			:= ""
Local cCfopPE		:= GetNewPar("MV_DAC04","")			//Cfop's de ST Petroleo e Energia
Local dDtIni		:= dDmaInc
Local dDtFim		:= dDmaFin

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento do Filtro para Mes Abril³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAbril	//Mes de Abril entrega anual do ano anterior a partir 2003
	dDtIni := dProcIni
	dDtFim := dProcFim
Endif
cDbf := "F3_FILIAL=='"+xFilial("SF3")+"' .AND. DTOS(F3_ENTRADA)>='"+Dtos(dDtIni)+"' .AND. DTOS(F3_ENTRADA)<='"+Dtos(dDtFim)+"' .AND. LEFT(F3_CFO,1)<'5' .AND. F3_TIPO<>'S' .AND. EMPTY(F3_DTCANC)"
cTop := "F3_FILIAL='"+xFilial("SF3")+"' AND F3_ENTRADA>='"+Dtos(dDtIni)+"' AND F3_ENTRADA<='"+Dtos(dDtFim)+"' AND (F3_CFO LIKE '1%' OR F3_CFO LIKE '2%' OR F3_CFO LIKE '3%') AND F3_TIPO NOT IN('S') AND F3_DTCANC=''"
           
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Entrada                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF3")
FsQuery(aArq,1,cTop,cDbf,SF3->(IndexKey()))
dbGoTop()
While !Eof()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava Registro 63                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cUf := RetDados("UF","E")
	dbSelectArea("R63")
	dbSetOrder(1)
	If !dbSeek(cUf)
		RecLock("R63",.T.)
		R63->UF		:= cUf
	Else
		RecLock("R63",.F.)
	Endif
	R63->VALCONT	+= SF3->F3_VALCONT
	R63->BASEICM	+= SF3->F3_BASEICM
	R63->OUTRICM	+= SF3->F3_OUTRICM
	If SF3->F3_ICMSRET > 0 .And. SF3->F3_CFO$cCfopPE
		R63->ICMRETPET	+= SF3->F3_ICMSRET					//ICMS ST Petroleo e Energia
	Else
		R63->ICMSRET	+= SF3->F3_ICMSRET
	Endif
	MsUnlock()	

	dbSelectArea("SF3")
	dbSkip()
Enddo	

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg64  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Regitro 64: Operacoes realizadas por UF - Saidas             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg64()

Local cDbf		:= ""
Local cTop		:= ""
Local aArq		:= {"SF3",""}
Local cIE		:= ""
Local cUf		:= ""
Local cCACEAL	:= "240/241/243/245/246/247/248"	//Contribuinte Inscrito no CACEAL
Local dDtIni	:= dDmaInc
Local dDtFim	:= dDmaFin

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento do Filtro para Mes Abril³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAbril	//Mes de Abril entrega anual do ano anterior a partir 2003
	dDtIni := dProcIni
	dDtFim := dProcFim
Endif
cDbf := "F3_FILIAL=='"+xFilial("SF3")+"' .AND. DTOS(F3_ENTRADA)>='"+Dtos(dDtIni)+"' .AND. DTOS(F3_ENTRADA)<='"+Dtos(dDtFim)+"' .AND. LEFT(F3_CFO,1)>='5' .AND. F3_TIPO<>'S' .AND. EMPTY(F3_DTCANC)"
cTop := "F3_FILIAL='"+xFilial("SF3")+"' AND F3_ENTRADA>='"+Dtos(dDtIni)+"' AND F3_ENTRADA<='"+Dtos(dDtFim)+"' AND (F3_CFO LIKE '5%' OR F3_CFO LIKE '6%' OR F3_CFO LIKE '7%') AND F3_TIPO NOT IN('S') AND F3_DTCANC=''"
       
dbSelectArea("SF3")
FsQuery(aArq,1,cTop,cDbf,SF3->(IndexKey()))
dbGoTop()
While !Eof()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava Registro 64                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIE := RetDados("IE","S")
	cUf := RetDados("UF","S")
	dbSelectArea("R64")
	dbSetOrder(1)
	If !dbSeek(cUf)
		RecLock("R64",.T.)
		R64->UF	:= cUf
	Else
		RecLock("R64",.F.)
	Endif
	If Left(Alltrim(cIE),3) $ cCACEAL			//Contribuinte Inscrito no CACEAL
		R64->VALCONT	+= SF3->F3_VALCONT
		R64->BASEICM	+= SF3->F3_BASEICM
	Else                						//Contribuinte Nao Inscrito no CACEAL
		R64->NVALCONT	+= SF3->F3_VALCONT		//Valor Contabil Nao Contribuinte
		R64->NBASEICM	+= SF3->F3_BASEICM		//Base de Calculo Nao Contribuinte
	Endif
	R64->OUTRICM	+= SF3->F3_OUTRICM
	R64->ICMSRET	+= SF3->F3_ICMSRET
	MsUnlock()	

	dbSelectArea("SF3")
	dbSkip()
Enddo

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg65  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Registro Tipo 65 - Estoque e Balanco                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg65()

Local aValMerc	:= {0,0,0,0,0,0}
Local dDtIni	:= dDmaInc
Local dDtFim	:= dDmaFin

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento do Filtro para Mes Abril³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAbril	//Mes de Abril entrega anual do ano anterior a partir 2003
	dDtIni := dProcIni
	dDtFim := dProcFim
Endif

dbSelectArea("SB1")
dbSetOrder(1)
While !Eof()

	aSaldo := RetEst(SB1->B1_COD,RetFldProd(SB1->B1_COD,"B1_LOCPAD"))						   		//Valor do Estoque Inicial/Final

	aValMerc[1] += Iif(SB1->B1_CLASFIS $ "00/10/20/50/51/60/70",aSaldo[1],0)	//Tributada Inicial
	aValMerc[2] += Iif(SB1->B1_CLASFIS $ "00/10/20/50/51/60/70",aSaldo[2],0)	//Tributada Final
	aValMerc[3] += Iif(SB1->B1_CLASFIS $ "30/40/41",aSaldo[1],0)				//Isenta Inicial
	aValMerc[4] += Iif(SB1->B1_CLASFIS $ "30/40/41",aSaldo[2],0)				//Isenta Final
	aValMerc[5] += Iif(SB1->B1_CLASFIS == "90",aSaldo[1],0)					//Outras
	aValMerc[6] += Iif(SB1->B1_CLASFIS == "90",aSaldo[2],0)					//Outras
	
	dbSelectArea("SB1")
	dbSkip()
Enddo	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava Registro 65                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("R65")
RecLock("R65",.T.)	
R65->DTBALANCO	:= dDtFim			//Data do Balanco
R65->TRIBINI 	:= aValMerc[1]		//Tributada Inicial
R65->TRIBFIM 	:= aValMerc[2]		//Tributada Final
R65->ISENINI 	:= aValMerc[3]		//Isenta Inicial
R65->ISENFIM 	:= aValMerc[4]		//Isenta Final
R65->OUTRINI 	:= aValMerc[5]		//Outras Inicial
R65->OUTRFIM 	:= aValMerc[6]		//Outras Final
MsUnlock()
	
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetEst     ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a o Estoque Inicial e/ou Final                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetEst(cProduto,cLocal)

Local aArea		:= GetArea()
Local aSaldo	:= {0,0}

dbSelectArea("SB9")
dbSetOrder(1)
If dbSeek(xFilial("SB9")+cProduto+cLocal+Dtos(dProcIni))		//Saldo Inicial
	aSaldo[1] := SB9->B9_VINI1
Endif
If dbSeek(xFilial("SB9")+cProduto+cLocal+Dtos(dProcFim))		//Saldo Final
	aSaldo[2] := SB9->B9_VINI1
Endif
RestArea(aArea)

Return(aSaldo)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetBanco   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a Descricao do Agente Arrecadador                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetBanco()
Local aArea	:= GetArea()
Local cRet	:= ""
Local nTamNBanco := TamSX3('A6_NREDUZ')[1]

dbSelectArea("SX5")
If dbSeek(xFilial("SX5")+'0N'+(cAliasSF6)->F6_BANCO)
	cRet := Substr(X5Descri(),1,nTamNBanco)
Endif
RestArea(aArea)
Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetCodMun  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o Codigo do Municipio do SA1/SA2                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetCodMun(cTp,cCpo)

Local aArea	:= GetArea()
Local cRet	:= ""

If cTp == "E"	//Tabela de Fornecedores
	dbSelectArea("SA2")
	dbSetOrder(1)
	If dbSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA)
		cRet := StrZero(Val(SA2->&(cCpo)),6)
    Endif
Else			//Tabela de Clientes
	dbSelectArea("SA1")
	dbSetOrder(1)
	If dbSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA)
		cRet := StrZero(Val(SA1->&(cCpo)),6)
    Endif
Endif
RestArea(aArea)

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetCodigo  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o Codigo do Produto/Servico, conforme Tabela DAC     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetCodigo(cTp,cCpo)

Local aArea	:= GetArea()
Local cRet	:= ""
Local cSeek	:= ""

dbSelectArea("SB5")
dbSetOrder(1)
If cTp == "E"		//Entrada
	cSeek := xFilial("SB5")+SD1->D1_COD
Else 	  			//Saida
	cSeek := xFilial("SB5")+SD2->D2_COD
Endif

If dbSeek(cSeek)
	cRet := SB5->&(cCpo)
Endif
RestArea(aArea)

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetAM      ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a Competencia da Declaracao (AAAAMM)                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetAM(cPeriodo,aPeriodo)

Local cRet 		:= ""
Local cPerIni	:= StrZero(Year(dDmaInc),4)+StrZero(Month(dDmaInc),2)
Local cPerFim	:= StrZero(Year(dDmaFin),4)+StrZero(Month(dDmaFin),2)

Default aPeriodo := {"",""}
                
Do Case
	Case cPeriodo == "Mensal"
		cRet 		:= cPerFim
		aPeriodo[1]	:= cPerFim
		aPeriodo[2]	:= cPerFim
	Case cPeriodo == "Quadrimestral"
		If cMes$"04/08/12"
			cRet 		:= cPerFim
			aPeriodo[1]	:= cPerIni
			aPeriodo[2]	:= cPerFim
		Else 
			_aTotal[99] := .F.	//Nao processa o DAC
			Aviso("Atencao","Meses validos para o quadrimestre sao: 04, 08 e 12",{"Ok"})
		Endif
	Case cPeriodo == "Anual"
		cRet 		:= StrZero(Year(dDmaFin),4)+"00"
		aPeriodo[1]	:= cPerIni
		aPeriodo[2]	:= cPerFim
EndCase

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetDados   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna IE, CPNJ ou UF                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetDados(cTp,cES)

Local aArea	:= GetArea()
Local cRet	:= ""
Local cSeek	:= SF3->F3_CLIEFOR+SF3->F3_LOJA

If cES == "E"	//Entrada
	If SF3->F3_TIPO$"DB"
		cES := "S"
	Endif
Else			//Saida
	If SF3->F3_TIPO$"DB"
		cES := "E"
	Endif
Endif	

If cES == "E"	//Entrada
	dbSelectArea("SA2")
	dbSetOrder(1)
	If dbSeek(xFilial("SA2")+cSeek)
		Do Case
			Case cTp == "IE"
				cRet := Alltrim(SA2->A2_INSCR)
			Case cTp == "CNPJ"
				cRet := Alltrim(SA2->A2_CGC)
		Otherwise
				cRet := Alltrim(SA2->A2_EST)
		EndCase
	Endif
Else
	dbSelectArea("SA1")
	dbSetOrder(1)
	If dbSeek(xFilial("SA1")+cSeek)
		Do Case
			Case cTp == "IE"
				cRet := Alltrim(SA1->A1_INSCR)
			Case cTp == "CNPJ"
				cRet := Alltrim(SA1->A1_CGC)
		Otherwise
				cRet := Alltrim(SA1->A1_EST)
		EndCase
	Endif	
Endif
RestArea(aArea)

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetEspecie ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 22.12.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a especie da NF conforme anexo do layout             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetEspecie(cModelo)

Local aArea	:= GetArea()
Local cRet	:= "048"		//Nota Fiscal

Do Case
	Case cModelo == "01"	
		cRet := "048"	//Nota Fiscal
	Case cModelo == "02"
		cRet := "081"	//Nota Fiscal Venda ao Consumidor
	Case cModelo == "04"
		cRet := "068"
	Case cModelo == "06"
		cRet := "047"
	Case cModelo == "07"
		cRet := "078"
	Case cModelo == "08"
		cRet := "017"
	Case cModelo == "09"
		cRet := "015"
	Case cModelo == "10"
		cRet := "012"
	Case cModelo == "11"
		cRet := "016"
	Case cModelo == "18"
		cRet := "087"
	Case cModelo == "21"
		cRet := "062"
	Case cModelo == "22"
		cRet := "064"
EndCase

RestArea(aArea)

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetAIDF    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 22.12.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o Numero da AIDF                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cSerie   = Serie da Nota Fiscal                              ³±±
±±³          ³cNFiscal = Numero da Nota Fiscal                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet[1]  = .T. Existe Numero da AIDF ou .F. Nao Existe       ³±±
±±³          ³aRet[2]  = Numero da AIDF                                    ³±±
±±³          ³aRet[3]  = Inicio do Intervalo (Primeira Nota Fiscal)        ³±±
±±³          ³aRet[4]  = Fim do Intervalo (Ultima Nota Fiscal)             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetAIDF(cSerie,cNFiscal)

Local aArea	:= GetArea()
Local aRet	:= {.F.,"","",""}

//Tratamento da Serie da NF
cSerie := IIf(Empty(cSerie),TamSX3("F3_SERIE")[1],cSerie)
dbSelectArea("SFS")
dbSetOrder(2)
If dbSeek(xFilial("SFS")+cSerie)
	While !Eof() .And. SFS->FS_FILIAL+SFS->FS_SERIE == xFilial("SFS")+cSerie
		If Val(cNFiscal) >= Val(SFS->FS_NUMINI) .And. Val(cNFiscal) <= Val(SFS->FS_NUMFIM)
			aRet[1] := .T.
			aRet[2] := StrZero(Val(SFS->FS_AIDF),11)
			aRet[3] := SFS->FS_NUMINI
			aRet[4] := SFS->FS_NUMFIM
			Exit
		Endif
		dbSelectArea("SFS")
		dbSkip()
	Enddo
Endif

RestArea(aArea)

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTemp   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTemp()

Local aStru		:= {}
Local cArq		:= ""
Local cArq46	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 00 - Cabecalho do Arquivo                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aStru,{"IE"			,"C",009,0})	//IE - CACEAL
AADD(aStru,{"TP_DECLARA"	,"C",001,0})	//Tipo de Declaracao: "O"-Original ou "R"-Retificadora
AADD(aStru,{"PERIODO"		,"C",001,0})	//Indicador do Periodo: "M"-Mensal, "Q"-Quadrimestral ou "A"-Anual
AADD(aStru,{"COMPETENC"		,"C",006,0})	//Competencia da Declaracao - AAAAMM
AADD(aStru,{"SIMPLES"		,"C",003,0})	//Contribuinte simples nacional

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R00")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 01 - Enderecos de Correio Eletronico                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"ECONTRIB"		,"C",060,0})	//E-mail do Contribuinte
AADD(aStru,{"ECONT"			,"C",060,0})	//E-mail do Contador
AADD(aStru,{"ERESP"			,"C",060,0})	//E-mail do Responsavel
AADD(aStru,{"TELCONT"		,"C",015,0})	//Telefone do Contador
AADD(aStru,{"TELRESP"		,"C",015,0})	//Telefone do Responsavel

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R01")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 10 - Identificador da Declaracao                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"CACEAL"		,"C",011,0})
AADD(aStru,{"CNPJCPF"		,"C",014,0})
AADD(aStru,{"RAZSOC"		,"C",040,0})
AADD(aStru,{"PERINI"		,"C",006,0})
AADD(aStru,{"PERFIM"		,"C",006,0})
AADD(aStru,{"DTINI"			,"C",008,0})
AADD(aStru,{"DTFIM"			,"C",008,0})
AADD(aStru,{"INDMOV"		,"C",001,0})
AADD(aStru,{"CAMPO10"		,"C",002,0})		//Faixa de Recolhimento (Recalculado pelo Sistema)
AADD(aStru,{"CAMPO11"		,"C",002,0})		//EPP e ME
AADD(aStru,{"CRC"			,"C",010,0})		//CRC do Contador
AADD(aStru,{"CPFCONT"		,"C",011,0})		//CPF do Contador
AADD(aStru,{"NOMECONT"		,"C",040,0})		//Nome do Contador
AADD(aStru,{"CPFRESP"		,"C",011,0})		//CPF do Responsavel
AADD(aStru,{"NOMERESP"		,"C",040,0})		//Responsavel 
AADD(aStru,{"INDENC"		,"C",001,0})		//Indicador de Encerramento
AADD(aStru,{"SIMPLES"		,"C",003,0})  		//Contribuinte simples nacional

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R10")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 21 - Entrada de Mercadorias, Bens e/ou Aquisicao ...      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"MESREF"		,"C",010,0})
AADD(aStru,{"PERINI"		,"C",006,0})
AADD(aStru,{"PERFIM"		,"C",006,0})
AADD(aStru,{"CFOP"			,"C",004,0})
AADD(aStru,{"VALCONT"		,"N",014,2})
AADD(aStru,{"BASEICM"		,"N",014,2})
AADD(aStru,{"VALICM"		,"N",014,2})
AADD(aStru,{"ISENICM"		,"N",014,2})
AADD(aStru,{"OUTRICM"		,"N",014,2})
AADD(aStru,{"VLRCONT"		,"N",014,2})		//Valor Contabil de Mercadorias c/ICMS Antecipado e fase de tributacao encerrada

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R21")
IndRegua("R21",cArq,"CFOP+MESREF")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 22 - Saidas de Mercadorias, Bens e/ou Aquisicao  ...      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"MESREF"		,"C",010,0})
AADD(aStru,{"PERINI"		,"C",006,0})
AADD(aStru,{"PERFIM"		,"C",006,0})
AADD(aStru,{"CFOP"			,"C",004,0})
AADD(aStru,{"VALCONT"		,"N",014,2})
AADD(aStru,{"BASEICM"		,"N",014,2})
AADD(aStru,{"VALICM"		,"N",014,2})
AADD(aStru,{"ISENICM"		,"N",014,2})
AADD(aStru,{"OUTRICM"		,"N",014,2})
AADD(aStru,{"VLRCONT"		,"N",014,2})		//Valor Contabil de Mercadorias c/ICMS Antecipado e fase de tributacao encerrada

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R22")
IndRegua("R22",cArq,"CFOP+MESREF")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 25 - Totais de Entrada de Mercadorias, Bens e/ou  ...     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"PERINI"		,"C",006,0})
AADD(aStru,{"PERFIM"		,"C",006,0})
AADD(aStru,{"TPOPER"		,"C",001,0})
AADD(aStru,{"VALCONT"		,"N",014,2})
AADD(aStru,{"BASEICM"		,"N",014,2})
AADD(aStru,{"VALICM"		,"N",014,2})
AADD(aStru,{"ISENICM"		,"N",014,2})
AADD(aStru,{"OUTRICM"		,"N",014,2})
AADD(aStru,{"VLRCONT"		,"N",014,2})

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R25")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 31 - Apuracao do ICMS                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"PERINI"		,"C",006,0})
AADD(aStru,{"PERFIM"		,"C",006,0})
AADD(aStru,{"SLDCREDANT"	,"N",014,2})	//Saldo Credor do Periodo Anterior
AADD(aStru,{"DEDUCAO"		,"N",014,2})	//Deducoes
AADD(aStru,{"HDEDUCAO"		,"C",100,0})	//Historico de Deducoes
AADD(aStru,{"SLDPERISEG"	,"N",014,2})	//Saldo credor ou a recolher do ICMS para o periodo seguinte
AADD(aStru,{"ICMSDEBIT"	,"N",014,2})	//Valor das saidas com debito do imposto
AADD(aStru,{"TOTOUTDEB"	,"N",014,2})	//Total de Outros Debitos informados no registro tipo "33"
AADD(aStru,{"ESTCRED"		,"N",014,2})	//Estorno de Credito
AADD(aStru,{"HESTCRED"		,"C",100,0})	//Historico Estorno de Credito
AADD(aStru,{"TOTDEB"		,"N",014,2})	//Total do debito do ICMS
AADD(aStru,{"ICMSCREDI"	,"N",014,2})	//Valor das entradas com credito do imposto
AADD(aStru,{"TOTOUTCRE"	,"N",014,2})	//Total de Outros Creditos informados no registro tipo "33"
AADD(aStru,{"ESTDEB"		,"N",014,2})	//Estorno de Debito
AADD(aStru,{"HESTDEB"		,"C",100,0})	//Historico Estorno de Debito
AADD(aStru,{"TOTCRED"		,"N",014,2})	//Total do credito do ICMS


cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R31")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 32 - Apuracao do ICMS - Produtor Rural                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"PERINI"		,"C",006,0})
AADD(aStru,{"PERFIM"		,"C",006,0})
AADD(aStru,{"SLDCREDANT"	,"N",014,2})	//Saldo Credor do Periodo Anterior
AADD(aStru,{"DEDUCAO"		,"N",014,2})	//Deducoes
AADD(aStru,{"HDEDUCAO"		,"C",100,0})	//Historico de Deducoes
AADD(aStru,{"SLDPERISEG"	,"N",014,2})	//Saldo credor ou a recolher do ICMS para o periodo seguinte
AADD(aStru,{"ICMSDEBIT"	,"N",014,2})	//Valor das saidas com debito do imposto
AADD(aStru,{"TOTOUTDEB"	,"N",014,2})	//Total de Outros Debitos informados no registro tipo "33"
AADD(aStru,{"ESTCRED"		,"N",014,2})	//Estorno de Credito
AADD(aStru,{"HESTCRED"		,"C",100,0})	//Historico Estorno de Credito
AADD(aStru,{"TOTDEB"		,"N",014,2})	//Total do debito do ICMS
AADD(aStru,{"ICMSCREDI"	,"N",014,2})	//Valor das entradas com credito do imposto
AADD(aStru,{"TOTOUTCRE"	,"N",014,2})	//Total de Outros Creditos informados no registro tipo "33"
AADD(aStru,{"ESTDEB"		,"N",014,2})	//Estorno de Debito
AADD(aStru,{"HESTDEB"		,"C",100,0})	//Historico Estorno de Debito
AADD(aStru,{"TOTCRED"		,"N",014,2})	//Total do credito do ICMS
AADD(aStru,{"ICMSRETST"	,"N",014,2})	//ICMS Retido por ST


cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R32")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 33 - Detalhamento de Outros Debitos e Outros Creditos ... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"PERINI"		,"C",006,0})
AADD(aStru,{"PERFIM"		,"C",006,0})
AADD(aStru,{"TRANSAC"		,"N",014,2})	//Transferencia de Creditos Acumulados
AADD(aStru,{"OUTDEB"		,"C",014,0})	//Outros Debitos
AADD(aStru,{"HOUTDEB"		,"C",100,0})	//Historico Outros Debitos
AADD(aStru,{"ICMANTEC"		,"N",014,2})	//ICMS Antecipado
AADD(aStru,{"CREDPRES"		,"C",014,0})	//Credito Presumido
AADD(aStru,{"CRDPRE21"		,"N",014,2})	//Credito Presumido 21
AADD(aStru,{"CRDATIVO"		,"C",014,0})	//Credito Ativo Imobilizado
AADD(aStru,{"CREDTRANS"	,"C",014,0})	//Credito recebido por Transferencia
AADD(aStru,{"ICMIMPOR"		,"N",014,2})	//ICMS Importacao
AADD(aStru,{"ICMRESTI"		,"N",014,2})	//ICMS Restituicao
AADD(aStru,{"OUTCRED"		,"C",014,0})	//Outros Creditos
AADD(aStru,{"HOUTCRED"		,"C",100,0})	//Historico Outros de Creditos


cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R33")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 41 - Obrigacoes Fiscais Apuradas                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"PERINI"	,"C",006,0})
AADD(aStru,{"PERFIM"	,"C",006,0})	
AADD(aStru,{"CODREC"	,"C",005,0})	//Codigo da Receita
AADD(aStru,{"DTVENC"	,"D",008,0})	//Data de Vencimento
AADD(aStru,{"VALOR"		,"N",014,2})	//Valor da Receita

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R41")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 42 - Obrigacoes Fiscais Pagas                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"CODREC"	,"C",005,0})	//Codigo da Receita
AADD(aStru,{"DTPAG"		,"D",008,0})	//Data do efetivo Pagamento do Tributo
AADD(aStru,{"VALOR"		,"N",014,2})	//Valor da Receita
AADD(aStru,{"AGENT"		,"C",003,0})	//Agente Arrecadador
AADD(aStru,{"DESCR"		,"C",040,0})	//Descricao do Agente

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R42")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 43 - Entrada Interestaduais ST - Inscrito no CACEAL       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"CACEAL"	,"C",011,0})
AADD(aStru,{"BASERET"	,"N",014,2})	
AADD(aStru,{"ICMSRET"	,"N",014,2})
AADD(aStru,{"DEVOL"		,"N",014,2})	//Devolucoes
AADD(aStru,{"ICMSDEV"	,"N",014,2})	//ICMS Devolucoes
AADD(aStru,{"RESSARC"	,"N",014,2})	//Ressarcimentos

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R43")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 44 - Entrada Interestaduais ST - nao inscrito no CACEAL   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"CNPJ"		,"C",014,0})
AADD(aStru,{"TPGUIA"	,"C",001,0})
AADD(aStru,{"BASERET"	,"N",014,2})
AADD(aStru,{"ICMSRET"	,"N",014,2})
AADD(aStru,{"DEVOL"		,"N",014,2})	//Devolucoes
AADD(aStru,{"ICMSDEV"	,"N",014,2})	//ICMS Devolucoes

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R44")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 45 - Relatorio de Notas Fiscais                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"AIDF"		,"C",011,0})	//Numero AIDF
AADD(aStru,{"MODELO"		,"C",002,0})	//Modelo da NF
AADD(aStru,{"ESPECIE"	,"C",003,0})	//Especie da NF
AADD(aStru,{"SERIE"		,"C",003,0})	//Serie da NF
AADD(aStru,{"SUBSERIE"	,"C",002,0})	//Sub-Serie da NF
AADD(aStru,{"NFINI"		,"C",TamSX3("F2_DOC")[1],0})	//NF Inicial do Intervalo
AADD(aStru,{"NFFIM"		,"C",TamSX3("F2_DOC")[1],0})	//NF Final do Intervalo
AADD(aStru,{"NFCANC"		,"N",006,0})	//Qtde. NF Canceladas


cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R45")
IndRegua("R45",cArq,"AIDF")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 46 - Notas Fiscais Canceladas                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq46	:= ""
AADD(aStru,{"AIDF"		,"C",011,0})	//Numero AIDF
AADD(aStru,{"MODELO"		,"C",002,0})	//Modelo da NF
AADD(aStru,{"ESPECIE"	,"C",003,0})	//Especie da NF
AADD(aStru,{"SERIE"		,"C",003,0})	//Serie da NF
AADD(aStru,{"SUBSERIE"	,"C",002,0})	//Sub-Serie da NF
AADD(aStru,{"NFINI"		,"C",TamSX3("F2_DOC")[1],0})	//NF Inicial do Intervalo
AADD(aStru,{"NFFIM"		,"C",TamSX3("F2_DOC")[1],0})	//NF Final do Intervalo
AADD(aStru,{"NFISCAL"	,"C",TamSX3("F2_DOC")[1],0})	//Numero da NF

cArq46 := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq46,"R46")
IndRegua("R46",cArq46,"AIDF+NFISCAL")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 61 - Municipios: Operacoes Internas de Produtos           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"CODMUN"	,"C",006,0})	//Codigo do Municipio
AADD(aStru,{"CODPROD"	,"C",003,0})	//Codigo do Produto
AADD(aStru,{"QTDE"		,"N",014,4})	//Quantidade 
AADD(aStru,{"VALOR"		,"N",014,2})	//Valor Total

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R61")
IndRegua("R61",cArq,"CODMUN")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 62 - Municipios: Operacoes Internas de Servicos           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"CODMUN"	,"C",006,0})	//Codigo do Municipio
AADD(aStru,{"CODSERV"	,"C",003,0})	//Codigo do Produto
AADD(aStru,{"VALOR"		,"N",014,2})	//Valor Total
AADD(aStru,{"CUSTPROP"	,"N",014,2})	//Valor proporcional do servico por municipio

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R62")
IndRegua("R62",cArq,"CODMUN")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 63 - Operacoes realizadas por UF - Entradas               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"UF"		,"C",002,0})
AADD(aStru,{"VALCONT"	,"N",014,2})
AADD(aStru,{"BASEICM"	,"N",014,2})
AADD(aStru,{"OUTRICM"	,"N",014,2})
AADD(aStru,{"ICMRETPET"	,"N",014,2})			//ICMS ST Petroleo e Energia
AADD(aStru,{"ICMSRET"	,"N",014,2})

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R63")
IndRegua("R63",cArq,"UF")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 64 - Operacoes realizadas por UF - Saidas                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"UF"		,"C",002,0})
AADD(aStru,{"VALCONT"	,"N",014,2})
AADD(aStru,{"NVALCONT"	,"N",014,2})		//Valor Contabil Nao Contribuinte
AADD(aStru,{"BASEICM"	,"N",014,2})
AADD(aStru,{"NBASEICM"	,"N",014,2})		//Base de Calculo Nao Contribuinte
AADD(aStru,{"OUTRICM"	,"N",014,2})
AADD(aStru,{"ICMSRET"	,"N",014,2})

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R64")
IndRegua("R64",cArq,"UF")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 65 - Estoque e Balanco                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"DTBALANCO"	,"D",008,0})	//Data do Balanco
AADD(aStru,{"TRIBINI"	,"N",014,2})	//Tributada Inicial
AADD(aStru,{"TRIBFIM"	,"N",014,2})	//Tributada Final
AADD(aStru,{"ISENINI"	,"N",014,2})	//Isenta Inicial
AADD(aStru,{"ISENFIM"	,"N",014,2})	//Isenta Final
AADD(aStru,{"OUTRINI"	,"N",014,2})	//Outras
AADD(aStru,{"OUTRFIM"	,"N",014,2})	//Outras

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R65")

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CFP        ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 17.01.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina CFP                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CFP()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao das variaveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aTxtPre 		:= {}
Local aPaineis 		:= {}
Local cTitObj1		:= ""
Local cTitObj2		:= ""       
Local nPos			:= 0
Local cMask1		:= Replicate("!",60)	//Mascara do E-mail
Local nMask1		:= 60
Local cMask2		:= Replicate("!",15)	//Mascara do Telefone
Local nMask2		:= 15
Local cMask3		:= Replicate("!",40)	//Mascara do Nome do Responsavel
Local nMask3		:= 40

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta wizard com as perguntas necessarias³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aTxtPre,"Assistente de parametrizacao da DAC-AL")
AADD(aTxtPre,"Atencao")
AADD(aTxtPre,"Preencha as informacoes solicitadas")
AADD(aTxtPre,"DAC - Declaracao de Atividades do Contribuinte - Governo do Estado de     Alagoas")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Painel com as informacoes necessarias   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aPaineis,{})
nPos :=	Len(aPaineis)
aAdd(aPaineis[nPos],"Assistente de parametrizacao")
aAdd(aPaineis[nPos],"Preenchimento das informacoes necessarias para geracao do arquivo magnetico")
aAdd(aPaineis[nPos],{})

cTitObj1 :=	"Tipo de Declaracao ?" 				//Cfp[1][01]
cTitObj2 :=	"Periodo da Declaracao ?"       	//Cfp[1][02]
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{3,,,,,{"Original","Retificadora"},,})
aAdd(aPaineis[nPos][3],{3,,,,,{"Mensal","Quadrimestral","Anual"},,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

cTitObj1 :=	"Declaracao com Movimento ?"		//Cfp[1][03]
cTitObj2 :=	"Encerramento de Atividades ?"		//Cfp[1][04]
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{3,,,,,{"Sim","Nao"},,})
aAdd(aPaineis[nPos][3],{3,,,,,{"Nao","Sim"},,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})     

cTitObj1 :=	"E-mail do Contribuinte ?"			//Cfp[1][05]
cTitObj2 :=	"Nome do Responsavel Legal ?"   	//Cfp[1][06]
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{2,,cMask1,1,,,,nMask1})
aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,nMask3})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

cTitObj1 :=	"E-mail do Responsavel Legal ?"		//Cfp[1][07]
cTitObj2 :=	"CPF do Responsavel Legal ?"		//Cfp[1][08]
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{2,,cMask1,1,,,,nMask1})
aAdd(aPaineis[nPos][3],{2,,"!!!!!!!!!!!",1,,,,11})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

cTitObj1 :=	"Telefone do Responsavel Legal ?"	//Cfp[1][09]
cTitObj2 :=	"Nome do Contador ?"				//Cfp[1][10]
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{2,,cMask2,1,,,,nMask2})
aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,nMask3})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

cTitObj1 :=	"E-mail do Contador ?"				//Cfp[1][11]
cTitObj2 :=	"CPF do Contador ?" 				//Cfp[1][12]
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{2,,cMask1,1,,,,nMask1})
aAdd(aPaineis[nPos][3],{2,,"!!!!!!!!!!!",1,,,,11})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

cTitObj1 :=	"CRC do Contador ?"					//Cfp[1][13]
cTitObj2 :=	"Telefone do Contador ?"			//Cfp[1][14]
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{2,,"!!!!!!!!!!",1,,,,10})
aAdd(aPaineis[nPos][3],{2,,cMask2,1,,,,nMask2})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

cTitObj1 :=	"Data de Fechamento do Estoque ?"		//Cfp[1][15]
cTitObj2 :=	"Optante pelo Simples Nacional ?"		//Cfp[1][16]
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{2,,"@!",3,0,,,8})
aAdd(aPaineis[nPos][3],{3,,,,,{"Nao","Sim"},,})

Return(xMagWizard(aTxtPre,aPaineis,"DAC"))

