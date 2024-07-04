#INCLUDE "GPEXINIL.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GpFormLoc ºAutor  ³Silvia Taguti       º Data ³  02/18/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Criacao de Formulas - Localizacoes                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC  	     ³  Motivo da Alteracao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Leandro Dr. ³23/09/12³M12RH01	 ³Unificacao da Folha.   		      ³±±
±±³            ³        ³RHU210_02_05³Projeto Versao 12					  ³±±
±±³Marcos Cout.³08/03/17³MRH-7420  	 ³Realizar ajustes de compatibilização³±±
±±³            ³        ³            ³dos progra³mas para Mercado Internaci±±
±±³            ³        ³          	 ³onal                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GpFormLoc()

Local aItensForm	:= {}
Local cFilRC2		:= xFilial("RC2")
Local cNomeForm		:= ""
Local cDescForm		:= ""
Local cDescDet		:= ""
Local cVersao		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MONTAGEM DO SALARIO MENSAL			            			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeForm 		:= PADR("SALARIO MENSAL",TAMSX3("RC2_CODIGO")[1])
cResult			:= PADR("SALMES",TAMSX3("RC2_RETURN")[1])
cDescForm		:= STR0001  	//"SALARIO MENSAL DOS FUNCIONARIOS"
cDescDet		:= STR0002	    //"MONTA O SALARIO MENSAL DOS FUNCIONARIOS. Exemplo: Se Funcionario Mensalista, e o proprio salario do Cadastro , se Horista a composicao e o Salario Hora Multiplicado por Horas Mensais."
cVersao			:= "001"
aItensForm	 	:= {}

RC2->( dbSetOrder(2) )
If RC2->(! dbSeek(cFilRC2 + cNomeForm)) .Or. RC2->RC2_VERSAO # cVersao
	
	//--           		Origem	Codigo  	Seq  	Tipo	Tipo	Resultado			Opera01    	Tipo	Form01				Opera02	Tipo  	Form02		Opera03
	//--													Result. 				  				Form1								Form2
	If cPaisLoc <> "DOM"
		Aadd(aItensForm, {"S_","SALMES","0010",".CON.","2","","","1","SRA->RA_TIPOPGT","==","5",'"M"',".AND."})
		Aadd(aItensForm, {"S_","SALMES","0020",".CON.","2","","","1","SRA->RA_CATFUNC","$","5",'"M*C*P*A*E"',".END."})
		Aadd(aItensForm, {"S_","SALMES","0030",".EXE.","1","SRA->RA_SALARIO","","1","","","1","",".END."})
		Aadd(aItensForm, {"S_","SALMES","0040",".CON.","2","","","1","SRA->RA_TIPOPGT","=","5",'"S"',".AND."})
		Aadd(aItensForm, {"S_","SALMES","0050",".CON.","2","","","1","SRA->RA_CATFUNC","=","5",'"S"',".END."})
		Aadd(aItensForm, {"S_","SALMES","0060",".EXE.","1","SRA->RA_SALARIO","/","5","7","*","5","30",".END."})
		Aadd(aItensForm, {"S_","SALMES","0070",".CON.","2","","","1","SRA->RA_CATFUNC","$","5",'"H*T*G"',".AND."})
		Aadd(aItensForm, {"S_","SALMES","0080",".CON.","2","","","2","C__ROTEIRO","==","5",'"FOL"',".END."})
		Aadd(aItensForm, {"S_","SALMES","0090",".EXE.","2","NCOMPHRS",":=","2","NORMAL","+","2","DESCANSO",".CNT."})
		Aadd(aItensForm, {"S_","SALMES","0100",".EXE.","1","SRA->RA_SALARIO","*","2","NCOMPHRS","","1","",".END."})
		Aadd(aItensForm, {"S_","SALMES","0110",".CON.","2","","","1","SRA->RA_CATFUNC","$","5",'"H*T*G"',".END."})
		Aadd(aItensForm, {"S_","SALMES","0120",".EXE.","1","SRA->RA_SALARIO","*","1","SRA->RA_HRSMES","","1","",".END."})
		Aadd(aItensForm, {"S_","SALMES","0130",".CON.","2","","","1","SRA->RA_CATFUNC","=","5",'"D"',".END."})
		Aadd(aItensForm, {"S_","SALMES","0140",".EXE.","1","SRA->RA_SALARIO","*","5","30","","1","",".END."})
	Else
		Aadd(aItensForm, {"S_","SALMES","0010",".CON.","2","","","1","SRA->RA_CATFUNC","==","5",'"M"',".END."})
		Aadd(aItensForm, {"S_","SALMES","0020",".EXE.","1","SRA->RA_SALARIO","","1","","","1","",".END."})
		Aadd(aItensForm, {"S_","SALMES","0030",".CON.","2","","","1","SRA->RA_CATFUNC","$","5",'"H*T*G"',".END."})
		Aadd(aItensForm, {"S_","SALMES","0040",".EXE.","1","SRA->RA_SALARIO","*","1","SRA->RA_HRSMES","","1","",".END."})
		Aadd(aItensForm, {"S_","SALMES","0050",".CON.","2","","","1","SRA->RA_CATFUNC","==","5",'"D"',".END."})
		Aadd(aItensForm, {"S_","SALMES","0060",".EXE.","1","SRA->RA_SALARIO","*","1","SRA->RA_HRSMES","/","5","SRA->RA_HRSDIA",".END."})
	Endif
	fFormGrava(cNomeForm,cDescForm,cResult,cDescDet,cVersao,aItensForm)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MONTAGEM DO SALARIO HORA			            			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeForm 		:= PADR("SALARIO HORA",TAMSX3("RC2_CODIGO")[1])
cResult			:= PADR("SALHORA",TAMSX3("RC2_RETURN")[1])
cDescForm		:= STR0003  	//"SALARIO HORA DOS FUNCIONARIOS"
cDescDet		:= STR0004	    //"MONTA O SALARIO HORAS DOS FUNCIONARIOS. Exemplo: Se Funcionario Horista e o proprio salario do cadastro, se mensalista  e o salario do cadastro dividido por horas mensais, se Diarista e o salario dia do cadastro * 30 dividido por horas mensais."
cVersao			:= "001"
aItensForm	 	:= {}
If RC2->(! dbSeek(cFilRC2 + cNomeForm)) .Or. RC2->RC2_VERSAO # cVersao
	
	//--           		Origem	Codigo  	Seq  	Tipo	Tipo	Resultado			Opera01    	Tipo	Form01				Opera02	Tipo  	Form02		Opera03
	//--													Result. 				  				Form1								Form2
	If cPaisLoc <> "DOM"
		Aadd(aItensForm, {"S_","SALHORA","0010",".CON.","2","","","1","SRA->RA_TIPOPGT","==","5",'"M"',".AND."})
		Aadd(aItensForm, {"S_","SALHORA","0020",".CON.","2","","","1","SRA->RA_CATFUNC","$","5",'"M*C*P*A*E"',".END."})
		Aadd(aItensForm, {"S_","SALHORA","0030",".EXE.","1","sra->ra_salario","/","1","SRA->RA_HRSMES","","1","",".END."})
		Aadd(aItensForm, {"S_","SALHORA","0040",".CON.","2","","","1","SRA->RA_TIPOPGT","=","5",'"S"',".AND."})
		Aadd(aItensForm, {"S_","SALHORA","0050",".CON.","2","","","1","SRA->RA_CATFUNC","=","5",'"S"',".END."})
		Aadd(aItensForm, {"S_","SALHORA","0060",".EXE.","2","SALHORA",":=","1","SRA->RA_SALARIO","/","5","7",".CNT."})
		Aadd(aItensForm, {"S_","SALHORA","0070",".EXE.","2","SALHORA","*","5","30","/","1","SRA->RA_HRSMES",".END."})
		Aadd(aItensForm, {"S_","SALHORA","0080",".CON.","2","","","1","SRA->RA_CATFUNC","$","5",'"H*T*G"',".END."})
		Aadd(aItensForm, {"S_","SALHORA","0090",".EXE.","1","SRA->RA_SALARIO","","5","","","1","",".END."})
		Aadd(aItensForm, {"S_","SALHORA","0100",".CON.","2","","","1","SRA->RA_CATFUNC","=","5",'"D"',".END."})
		Aadd(aItensForm, {"S_","SALHORA","0110",".EXE.","1","SRA->RA_SALARIO","*","5","30","/","1","SRA->RA_HRSMES",".END."})
	Else  
		Aadd(aItensForm, {"S_","SALHORA","0010",".CON.","2","","","1","SRA->RA_CATFUNC","==","5",'"M"',".END."})
		Aadd(aItensForm, {"S_","SALHORA","0020",".EXE.","1","SRA->RA_SALARIO","/","1","SRA->RA_HRSMES","","1","",".END."})
		Aadd(aItensForm, {"S_","SALHORA","0030",".CON.","2","","","1","SRA->RA_CATFUNC","$","5",'"H*T*G"',".END."})
		Aadd(aItensForm, {"S_","SALHORA","0040",".EXE.","1","SRA->RA_SALARIO","","1","","","1","",".END."})
		Aadd(aItensForm, {"S_","SALHORA","0050",".CON.","2","","","1","SRA->RA_CATFUNC","=","5",'"D"',".END."})
		Aadd(aItensForm, {"S_","SALHORA","0060",".EXE.","1","SRA->RA_SALARIO","/","1","SRA->RA_HRSDIA","","1","",".END."})
	Endif
	fFormGrava(cNomeForm,cDescForm,cResult,cDescDet,cVersao,aItensForm)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MONTAGEM DO SALARIO DIA			            			        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeForm 		:= PADR("SALARIO DIA",TAMSX3("RC2_CODIGO")[1])
cResult			:= PADR("SALDIA",TAMSX3("RC2_RETURN")[1])
cDescForm		:= STR0005  	//"SALARIO DIA DOS FUNCIONARIOS"
cDescDet		:= STR0006	    //"MONTA O SALARIO POR DIA DOS FUNCIONARIOS. Exemplo: Se Funcionario Diarista e o proprio salario do cadastro, se mensalista  e o salario do cadastro dividido por 30, se Horista e o salario hora do cadastro multiplicado por horas mensais e dividido por 30 ."
cVersao			:= "001"
aItensForm	 	:= {}
If RC2->(! dbSeek(cFilRC2 + cNomeForm)) .Or. RC2->RC2_VERSAO # cVersao
	
	//--           		Origem	Codigo  	Seq  	Tipo	Tipo	Resultado			Opera01    	Tipo	Form01				Opera02	Tipo  	Form02		Opera03
	//--													Result. 				  				Form1								Form2
	If cPaisLoc <> "DOM"
		Aadd(aItensForm, {"S_","SALDIA","0010",".CON.","2","","","1","SRA->RA_TIPOPGT","==","5",'"M"',".AND."})
		Aadd(aItensForm, {"S_","SALDIA","0020",".CON.","2","","","1","SRA->RA_CATFUNC","$","5",'"M*C*P*A*E"',".END."})
		Aadd(aItensForm, {"S_","SALDIA","0030",".EXE.","1","sra->ra_salario","/","5","30","","1","",".END."})
		Aadd(aItensForm, {"S_","SALDIA","0040",".CON.","2","","","1","SRA->RA_TIPOPGT","=","5",'"S"',".AND."})
		Aadd(aItensForm, {"S_","SALDIA","0050",".CON.","2","","","1","SRA->RA_CATFUNC","=","5",'"S"',".END."})
		Aadd(aItensForm, {"S_","SALDIA","0060",".EXE.","1","SRA->RA_SALARIO","/","5","7","","5","",".END."})
		Aadd(aItensForm, {"S_","SALDIA","0070",".CON.","2","","","1","SRA->RA_CATFUNC","$","5",'"H*T*G"',".END."})
		If cPaisLoc <> "URU"
			Aadd(aItensForm, {"S_","SALDIA","0080",".EXE.","1","SRA->RA_SALARIO","*","1","SRA->RA_HRSMES","/","5","30",".END."})
		Else
			Aadd(aItensForm, {"S_","SALDIA","0080",".EXE.","1","SRA->RA_SALARIO","*","1","SRA->RA_HRSMES","/","5","25",".END."})
		Endif
		Aadd(aItensForm, {"S_","SALDIA","0090",".CON.","2","","","1","SRA->RA_CATFUNC","=","5",'"D"',".END."})
		Aadd(aItensForm, {"S_","SALDIA","0100",".EXE.","1","SRA->RA_SALARIO","","5","","","1","",".END."})
	Else
		Aadd(aItensForm, {"S_","SALDIA","0020",".CON.","2","","","1","SRA->RA_CATFUNC","==","5",'"M"',".END."})
		Aadd(aItensForm, {"S_","SALDIA","0030",".EXE.","1","SRA->RA_SALARIO","/","5","(SRA->RA_HRSMES/SRA->RA_HRSDIA)",,"1","",".END."})
		Aadd(aItensForm, {"S_","SALDIA","0070",".CON.","2","","","1","SRA->RA_CATFUNC","$","5",'"H*T*G"',".END."})
		Aadd(aItensForm, {"S_","SALDIA","0080",".EXE.","1","SRA->RA_SALARIO","*","1","SRA->RA_HRSDIA","","1","",".END."})
		Aadd(aItensForm, {"S_","SALDIA","0090",".CON.","2","","","1","SRA->RA_CATFUNC","=","5",'"D"',".END."})
		Aadd(aItensForm, {"S_","SALDIA","0100",".EXE.","1","SRA->RA_SALARIO","","5","","","1","",".END."})
	Endif
	fFormGrava(cNomeForm,cDescForm,cResult,cDescDet,cVersao,aItensForm)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MONTAGEM DO SALARIO BASE DO MES		            			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeForm 		:= PADR("SALARIO BASE",TAMSX3("RC2_CODIGO")[1])
cResult			:= PADR("SALARIO",TAMSX3("RC2_RETURN")[1])
cDescForm		:= STR0007  	//"SALARIO BASE MES DOS FUNCIONARIOS"
cDescDet		:= STR0008	    //"VARIAVEL PARA ARMAZENAR O SALARIO BASE DO MES SEM A INCORPORACAO DE VERBAS NO SALARIO."
cVersao			:= "001"
aItensForm	 	:= {}
If RC2->(! dbSeek(cFilRC2 + cNomeForm)) .Or. RC2->RC2_VERSAO # cVersao
	//--           		Origem	Codigo  	Seq  	Tipo	Tipo	Resultado			Opera01    	Tipo	Form01				Opera02	Tipo  	Form02		Opera03
	//--													Result. 				  				Form1								Form2
	Aadd(aItensForm, {"S_","SALARIO","0010",".EXE.","2","SALMES","","1","","","1","",".END."})
	fFormGrava(cNomeForm,cDescForm,cResult,cDescDet,cVersao,aItensForm)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VALORES FUTUROS						            			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeForm 		:= PADR("VALORES FUTUROS",TAMSX3("RC2_CODIGO")[1])
cResult			:= PADR("NVALFUT",TAMSX3("RC2_RETURN")[1])
cDescForm		:= STR0009  //"GERACAO DOS VALORES FUTUROS"
cDescDet		:= STR0010  //"VERIFICA NO ARQUIVO DE VALORES FUTUROS SE EXISTE MOVIMENTACOES PARA SER GERADA NA FOLHA DO MES."
cVersao			:= "001"
aItensForm	 	:= {}
If RC2->(! dbSeek(cFilRC2 + cNomeForm)) .Or. RC2->RC2_VERSAO # cVersao
	//--           	Origem	Codigo  	Seq  	Tipo	Tipo	Resultado			Opera01    	Tipo	Form01				Opera02	Tipo  	Form02		Opera03
	//--													Result. 				  				Form1								Form2
	Aadd(aItensForm, {"S_","NVALFUR","0010",".EXE.","3","FGERVALFUT()","","" ,""        ," " ,"" ,"" ,".END."})
	fFormGrava(cNomeForm,cDescForm,cResult,cDescDet,cVersao,aItensForm)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ DESCONTO DO ARREDONDAMENTO 13 NA FOLHA DE DEZEMBRO 			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeForm 		:= PADR("DESC ARRED 13",TAMSX3("RC2_CODIGO")[1])
cResult			:= PADR("NARRED13",TAMSX3("RC2_RETURN")[1])
cDescForm		:= STR0011  //"GERACAO DO DESCONTO DE ARREDONDAMENTO DA 2O. PARCELA"
cDescDet		:= STR0012	//"VERIFICA NO ARQUIVO DE 13O. SE HA ARREDONDAMENTO A SER DESCONTADO NA FOLHA DE DEZEMBRO"
cVersao			:= "001"
aItensForm	 	:= {}
If RC2->(! dbSeek(cFilRC2 + cNomeForm)) .Or. RC2->RC2_VERSAO # cVersao
	
	//--           		Origem	Codigo  	Seq  	Tipo	Tipo	Resultado			Opera01    	Tipo	Form01				Opera02	Tipo  	Form02		Opera03
	//--													Result. 				  				Form1								Form2
	Aadd(aItensForm, {"S_","NARRED13","0010",".CON.","" ,""            ,"","2","CSITFOLH","<>","5",'"D"',".AND."})
	Aadd(aItensForm, {"S_","NARRED13","0020",".CON.","" ,""            ,"","2","CSITFOLH","<>","5",'"D"',".END."})
	Aadd(aItensForm, {"S_","NARRED13","0030",".EXE.","3","FGERaRR13()" ,"","" ,""        ," " ,"" ,"" ,".END."})
	
	fFormGrava(cNomeForm,cDescForm,cResult,cDescDet,cVersao,aItensForm)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GERACAO DAS FERIAS DO MES NA FOLHA DE PAGAMENTO 			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeForm 		:= PADR("GERAR FERIAS",TAMSX3("RC2_CODIGO")[1])
cResult			:= PADR("CDIFFER",TAMSX3("RC2_RETURN")[1])
cDescForm		:= STR0013  //"GERACAO DA MOVIMENTACAO DE FERIAS NA FOLHA DE PAGAMENTO"
cDescDet		:= STR0014  //"VERIFICA SE HA FERIAS NO MES PARA O FUNCIONARIO E GERA NA FOLHA DE PAGAMENTO"
cVersao			:= "001"
aItensForm	 	:= {}
If RC2->(! dbSeek(cFilRC2 + cNomeForm)) .Or. RC2->RC2_VERSAO # cVersao
	
	//--           		Origem	Codigo  	Seq  	Tipo	Tipo	Resultado			Opera01    	Tipo	Form01				Opera02	Tipo  	Form02		Opera03
	//--													Result. 				  				Form1								Form2
	Aadd(aItensForm, {"S_","CDIFFER","0010",".CON." ,"" ,""            	,"","2","CSITFOLH"		,"$" 	,"5",'"A/F"'    ,".AND."})
	Aadd(aItensForm, {"S_","CDIFFER","0020",".CON." ,"" ,""            	,"","2","C__ROTEIRO"	,"<>"	,"5",'"FER"'	,".END."})
	Aadd(aItensForm, {"S_","CDIFFER","0030",".EXE.","3","GERAFER(aCodFol)"	,"","" ,""        		," "	,"" ,""       	,".END."})
	
	fFormGrava(cNomeForm,cDescForm,cResult,cDescDet,cVersao,aItensForm)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GERACAO DAS RESCISOES DO MES NA FOLHA DE PAGAMENTO 			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeForm 		:= PADR("GERAR RESCISOES",TAMSX3("RC2_CODIGO")[1])
cResult			:= PADR("LGERRES",TAMSX3("RC2_RETURN")[1])
cDescForm		:= STR0015  //"GERACAO DA MOVIMENTACAO DE RESCISAO NA FOLHA DE PAGAMENTO"
cDescDet		:= STR0016  //"VERIFICA SE HOUVE RESCISAO NO MES PARA O FUNCIONARIO E GERA NA FOLHA DE PAGAMENTO"
cVersao			:= "002"
aItensForm	 	:= {}
If RC2->(! dbSeek(cFilRC2 + cNomeForm)) .Or. RC2->RC2_VERSAO # cVersao
	
	//--           		Origem	Codigo  	Seq  	Tipo	Tipo	Resultado			Opera01    	Tipo	Form01				Opera02	Tipo  	Form02		Opera03
	//--													Result. 				  				Form1								Form2
	Aadd(aItensForm, {"S_","LGERRES","0010",".CON." ,"" ,""                        ,"","2","CSITFOLH"  ,"==" ,"5",'"D"'     ,".AND."})
	Aadd(aItensForm, {"S_","LGERRES","0020",".CON." ,"" ,""                        ,"","2","C__ROTEIRO","==" ,"5",'"FOL"'   ,".END."})
	Aadd(aItensForm, {"S_","LGERRES","0030",".EXE.","3","GERARESC(CFOLMES,CSEMANA,@LGERRES)","","" ,""        ," " ,"" ,""       ,".CNT."})
	Aadd(aItensForm, {"S_","LGERRES","0040",".CON." ,"" ,""                        ,"","2" ,"LGERRES"  ,"==" ,"5",'.T.',".END."})	
	Aadd(aItensForm, {"S_","LGERRES","0050",".EXE." ,"3" ,"GRAVACALC()"            ,"" ," ",""         ,""   ,"" ,""   ,".CNT."})
	Aadd(aItensForm, {"S_","LGERRES","0060",".EXE." ,"3" ,"FINALFUN()"             ,"" ," ",""         ,""   ,"" ,""   ,".END."})
	
	fFormGrava(cNomeForm,cDescForm,cResult,cDescDet,cVersao,aItensForm)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CARREGAR A MOVIMENTACAO DO MES NA MATRIZ DE CALCULO     	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeForm 		:= PADR("CARREGA MOVIMENTO",TAMSX3("RC2_CODIGO")[1])
cResult			:= PADR("APD",TAMSX3("RC2_RETURN")[1])
cDescForm		:= STR0017  //"CARREGA A MOVIMENTACAO DO FUNCIONARIO NO MES PARA A MATRIZ DE CALCULO"
cDescDet		:= STR0018  //"VERIFICA SE FUNCIONARIO TEM MOVIMENTACAO NO MES E CARREGA NA MATRIZ DE CALCULO"
cVersao			:= "001"
aItensForm	 	:= {}
If RC2->(! dbSeek(cFilRC2 + cNomeForm)) .Or. RC2->RC2_VERSAO # cVersao
	
	//--           		Origem	Codigo  	Seq  	Tipo	Tipo	Resultado			Opera01    	Tipo	Form01				Opera02	Tipo  	Form02		Opera03
	//--													Result. 				  				Form1								Form2
	Aadd(aItensForm, {"S_","APD","0010",".EXE." ,"3" ,"fCarMvto(SRA->RA_FILIAL,SRA->RA_MAT,cSemana)","","","","" ,"","",".END."})
	
	fFormGrava(cNomeForm,cDescForm,cResult,cDescDet,cVersao,aItensForm)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CARREGAR A MOVIMENTACAO DO MES NA MATRIZ DE CALCULO     	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeForm 		:= PADR("CARGA TABELAS",TAMSX3("RC2_CODIGO")[1])
cResult			:= PADR("LTABELAS",TAMSX3("RC2_RETURN")[1])
cDescForm		:= STR0019  //"CARREGA AS TABELAS NECESSARIAS PARA O CALCULO DA FOLHA"
cDescDet		:= STR0018  //"CARREGA AS TABELAS NECESSARIAS PARA O CALCULO DA FOLHA"
cVersao			:= "005"
aItensForm	 	:= {}
If RC2->(! dbSeek(cFilRC2 + cNomeForm)) .Or. RC2->RC2_VERSAO # cVersao
	
	//--           		Origem	Codigo  	Seq Tipo	Tipo	Resultado			                Opera01    	Tipo	Form01				Opera02	Tipo  	Form02		Opera03
	//--												Result. 				  				                Form1								Form2
	If cPaisLoc == "ARG"
		Aadd(aItensForm, {"S_","LTABELAS","0010",".CON." ,"" ,""               ,""  ,"2","cFilCalc"							          											,"<>","5",'SRA->RA_FILIAL' ,".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0020",".EXE." ,"2" ,"cFilCalc"      ,":=","3","SRA->RA_FILIAL"								  											,""  ,"" ,""    ,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0030",".CON." ,"3" ,"" 					,""  ,"3","SetValMOPRE(@nMopre)"          													,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0040",".CON." ,"3",""					,""  ,"3","Sal_Min(@Val_SalMin,MesAno(dDataBase))"      									,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0050",".CON." ,"3",""					,""  ,"3","SETIRLOC(@aIR)"      																	,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0060",".CON." ,"3",""					,""  ,"3","Sal_FamiArg(aSalFamArg,MesAno(dDataBase))"      							,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0070",".CON." ,"3",""				 	,""  ,"3" ,"FP_CODFOL(@aCodFol,SRA->RA_FILIAL)"          ,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0080",".CON." ,"3",""					,""  ,"3","Val_Refe(@aRefeicao,SRA->RA_FILIAL)"         									,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0090",".CON." ,"3",""					,""  ,"3","FCarParam(SRA->RA_FILIAL)" 		          										,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0100",".CON." ,"3",""					,""  ,"3","CompMes(@Normal,@Descanso,MesAno(dDataBase))"									,""  ,"" ,""   ,".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0110",".EXE." ,"2" ,"NSVNORMAL"     ,":=","2","NORMAL"									  												,""  ,"" ,""	,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0120",".EXE." ,"2" ,"NSVDESCAN"     ,":=","2","DESCANSO"									  												,""  ,"" ,""	,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0130",".EXE." ,"2" ,"LTABELAS"      ,":=","5",'.T.'									      											,""  ,"" ,""	,".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0140",".CON." ,"" ,""               ,""  ,"2","LTABELAS"								      											,"<>","5",'.T.',".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0150",".EXE." ,"3" ,"FINALCALC()"   ,""  ,"" ,""									          											,""  ,"" ,""	,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0160",".EXE." ,"2" ,"LTABELAS"		,":=","5",'.F.'									      											,""  ,"" ,""	,".END."})
	ElseIf cPaisLoc == "CHI"
		Aadd(aItensForm, {"S_","LTABELAS","0010",".CON." ,"" ,""               ,""  ,"2","cFilCalc"							          											,"<>","5",'SRA->RA_FILIAL' ,".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0020",".EXE." ,"2" ,"cFilCalc"      ,":=","3","SRA->RA_FILIAL"								  											,""  ,"" ,""    ,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0030",".CON." ,"3",""					,""  ,"3","Sal_Min(@Val_SalMin,MesAno(dDataBase))"      									,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0040",".CON." ,"3" ,"" 					,""  ,"3","SetValUNS(@nValUF,@nValUTM)"          											,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0050",".CON." ,"3" ,"" 					,""  ,"3","SetAportePa(@aAporte)"          													,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0060",".CON." ,"3" ,"" 					,""  ,"3","SetSalFam(@aSalFam)"          														,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0070",".CON." ,"3" ,"" 					,""  ,"3","SETIRLOC(@aIR)"          															,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0080",".CON." ,"3",""				 	,""  ,"3" ,"FP_CODFOL(@aCodFol,SRA->RA_FILIAL)"          								,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0090",".CON." ,"3",""			 			,""  ,"3" ,"FCarParam(SRA->RA_FILIAL)" 		          									,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0100",".CON." ,"3",""					,""  ,"3" ,"CompMes(@Normal,@Descanso,MesAno(dDataBase))"								,""  ,"" ,""   ,".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0110",".EXE." ,"2" ,"NSVNORMAL"     ,":=","2","NORMAL"									  												,""  ,"" ,""	,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0120",".EXE." ,"2" ,"NSVDESCAN"     ,":=","2","DESCANSO"									  												,""  ,"" ,""	,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0130",".EXE." ,"2" ,"LTABELAS"      ,":=","5",'.T.'									      											,""  ,"" ,""	,".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0140",".CON." ,"" ,""               ,""  ,"2","LTABELAS"								      											,"<>","5",'.T.',".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0150",".EXE." ,"3" ,"FINALCALC()"   ,""  ,"" ,""									          											,""  ,"" ,""	,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0160",".EXE." ,"2" ,"LTABELAS"		,":=","5",'.F.'									      											,""  ,"" ,""	,".END."})
	ElseIf cPaisLoc == "PAR"
		Aadd(aItensForm, {"S_","LTABELAS","0010",".CON." ,"" ,""               ,""  ,"2","cFilCalc"							          											,"<>","5",'SRA->RA_FILIAL' ,".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0020",".EXE." ,"2" ,"cFilCalc"      ,":=","3","SRA->RA_FILIAL"								  											,""  ,"" ,""   ,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0030",".CON." ,"3" ,"" 					,""  ,"3","LOC_IPS(@nIPSPatr,@nIPSFunc,MesAno(dDataBase))"  							,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0040",".CON." ,"3",""					,""  ,"3" ,"Sal_Min(@Val_SalMin,MesAno(dDataBase))"      								,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0050",".CON." ,"3",""					,""  ,"3" ,"Sal_Fami(@nLimSF1,@nVal_SF1,@nLimSF2,@nVal_SF2,MesAno(dDataBase))"	,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0060",".CON." ,"3",""					,""  ,"3" ,"Seg_Vida(@aSeguro,SRA->RA_FILIAL)"           ,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0070",".CON." ,"3",""				 	,""  ,"3" ,"FP_CODFOL(@aCodFol,SRA->RA_FILIAL)"          ,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0080",".CON." ,"3",""					,""  ,"3" ,"FCarParam(SRA->RA_FILIAL)" 		          									,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0090",".CON." ,"3",""					,""  ,"3" ,"CompMes(@Normal,@Descanso,MesAno(dDataBase))"								,""  ,"" ,""   ,".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0100",".EXE." ,"2" ,"NSVNORMAL"     ,":=","2","NORMAL"									  												,""  ,"" ,""	,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0110",".EXE." ,"2" ,"NSVDESCAN"     ,":=","2","DESCANSO"									  												,""  ,"" ,""	,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0120",".EXE." ,"2" ,"LTABELAS"      ,":=","5",'.T.'									      											,""  ,"" ,""	,".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0130",".CON." ,"" ,""               ,""  ,"2","LTABELAS"								      											,"<>","5",'.T.',".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0140",".EXE." ,"3" ,"FINALCALC()"   ,""  ,"" ,""									          											,""  ,"" ,""	,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0150",".EXE." ,"2" ,"LTABELAS"		,":=","5",'.F.'									      											,""  ,"" ,""	,".END."})
	ElseIf cPaisLoc == "URU"
		Aadd(aItensForm, {"S_","LTABELAS","0010",".CON." ,"" ,""               ,""  ,"2","cFilCalc"							          											,"<>","5",'SRA->RA_FILIAL' ,".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0020",".EXE." ,"2" ,"cFilCalc"      ,":=","3","SRA->RA_FILIAL"								  											,""  ,"" ,""   ,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0030",".CON." ,"3",""					,""  ,"3","Sal_Min(@Val_SalMin,MesAno(dDataBase))"      									,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0040",".CON." ,"3",""					,""  ,"3","LOC_BPS(@nBPSPatr,@nBPSFunc,@nBPSConsC,@nBPSCot,MesAno(dDataBase))"      			,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0050",".CON." ,"3",""					,""  ,"3","LOC_FRL(@nFRLPatr,@nFRLFunc,MesAno(dDataBase))"      						,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0060",".CON." ,"3",""					,""  ,"3","LOC_FONASA(@nFonasCot,@nFonasPatr,@nFonasFunc,MesAno(dDataBase),,@nFonasDep,@nFonasSM,@nFonasSDep)"      ,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0070",".CON." ,"3",""					,""  ,"3","SETIRLOC(@aIR)"      																	,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0080",".CON." ,"3",""				 	,""  ,"3","FP_CODFOL(@aCodFol,SRA->RA_FILIAL)"          ,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0090",".CON." ,"3",""					,""  ,"3","FCarParam(SRA->RA_FILIAL)" 		          									,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0100",".CON." ,"3",""					,""  ,"3","CompMes(@Normal,@Descanso,MesAno(dDataBase))"								,""  ,"" ,""   ,".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0110",".EXE." ,"2" ,"NSVNORMAL"     ,":=","2","NORMAL"									  												,""  ,"" ,""	,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0120",".EXE." ,"2" ,"NSVDESCAN"     ,":=","2","DESCANSO"									  												,""  ,"" ,""	,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0130",".EXE." ,"2" ,"LTABELAS"      ,":=","5",'.T.'									      											,""  ,"" ,""	,".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0140",".CON." ,"" ,""               ,""  ,"2","LTABELAS"								      											,"<>","5",'.T.',".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0150",".EXE." ,"3" ,"FINALCALC()"   ,""  ,"" ,""									          											,""  ,"" ,""	,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0160",".EXE." ,"2" ,"LTABELAS"		,":=","5",'.F.'									      											,""  ,"" ,""	,".END."})
	ElseIf cPaisLoc == "DOM"
		Aadd(aItensForm, {"S_","LTABELAS","0010",".CON." ,"" ,""               ,""  ,"2","cFilCalc"							          											,"<>","5",'SRA->RA_FILIAL' ,".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0020",".EXE." ,"2" ,"cFilCalc"      ,":=","3","SRA->RA_FILIAL"								  											,""  ,"" ,""    ,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0030",".CON." ,"3",""					,""  ,"3","Sal_Min(@Val_SalMin,MesAno(dDataBase))"      									,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0040",".CON." ,"3",""					,""  ,"3","LOC_SEGSOC(@aSegSoc)"      															,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0050",".CON." ,"3",""					,""  ,"3","SETIRLOC(@aIR)"      																	,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0080",".CON." ,"3",""				 	,""  ,"3" ,"FP_CODFOL(@aCodFol,SRA->RA_FILIAL)"         	 								,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0090",".CON." ,"3",""					,""  ,"3" ,"FCarParam(SRA->RA_FILIAL)" 		          									,""  ,"" ,""   ,".AND."})
		Aadd(aItensForm, {"S_","LTABELAS","0100",".CON." ,"3",""					,""  ,"3" ,"CompMes(@Normal,@Descanso,MesAno(dDataBase))"								,""  ,"" ,""   ,".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0110",".EXE." ,"2" ,"NSVNORMAL"     ,":=","2","NORMAL"									  												,""  ,"" ,""	,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0120",".EXE." ,"2" ,"NSVDESCAN"     ,":=","2","DESCANSO"									  												,""  ,"" ,""	,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0130",".EXE." ,"2" ,"LTABELAS"      ,":=","5",'.T.'									      											,""  ,"" ,""	,".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0140",".CON." ,"" ,""               ,""  ,"2","LTABELAS"								      											,"<>","5",'.T.',".END."})
		Aadd(aItensForm, {"S_","LTABELAS","0150",".EXE." ,"3" ,"FINALCALC()"   ,""  ,"" ,""									          											,""  ,"" ,""	,".CNT."})
		Aadd(aItensForm, {"S_","LTABELAS","0160",".EXE." ,"2" ,"LTABELAS"		,":=","5",'.F.'									      											,""  ,"" ,""	,".END."})
	Endif	                                                                                                                                                           
	fFormGrava(cNomeForm,cDescForm,cResult,cDescDet,cVersao,aItensForm)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CARREGAR A FORMULA PARA CALCULO DA ASSITENCIA MEDICA    	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeForm 		:= PADR("CARGA TABLOC",TAMSX3("RC2_CODIGO")[1])
cResult			:= PADR("LTABLOC",TAMSX3("RC2_RETURN")[1])
cDescForm		:= STR0030   //"CARGA DE TABELAS LOCALIZADAS"
cDescDet		:= STR0030   //"CARGA DE TABELAS LOCALIZADAS"
cVersao			:= "002"
aItensForm	 	:= {}
If RC2->(! dbSeek(cFilRC2 + cNomeForm)) .Or. RC2->RC2_VERSAO # cVersao
	
	//--           		Origem	Codigo  	Seq Tipo	Tipo	Resultado			                Opera01    	Tipo	Form01				Opera02	Tipo  	Form02		Opera03
	//--												Result. 				  				                Form1								Form2
  	If cPaisLoc == "CHI"
  		Aadd(aItensForm, {"S_","LTABLOC","0010",".EXE.","3" ,"LOC_SEGSOC(@aAFP)"	,"","" ,"" ," " ,"" ,"" ,".CNT."})
  		Aadd(aItensForm, {"S_","LTABLOC","0020",".EXE.","3" ,"SetISAPRE(@aISAPRE)","","" ,"" ," " ,"" ,"" ,".END."})
	ElseIf cPaisLoc == "URU"
		Aadd(aItensForm, {"S_","LTABLOC","0010",".CON." ,"" ,""                                       ,""  ,"2","cCodAssM"					,"<>"   ,"1"    ,'SRA->RA_ASMEDIC' ,".END."})
		Aadd(aItensForm, {"S_","LTABLOC","0020",".EXE." ,"3" ,"CarAssMed()" 			                 ,""  ," ",""							,""     ,""     ,""                ,".CNT."})
		Aadd(aItensForm, {"S_","LTABLOC","0030",".EXE." ,"1" ,"SRA->RA_ASMEDIC"                   	 ,""  ," ",""							,""     ,""     ,""                ,".END."})
		Aadd(aItensForm, {"S_","LTABLOC","0040",".CON." ,"" ,""                                       ,""  ,"2","cCodAssM"					,"=="   ,"1"    ,'SRA->RA_ASMEDIC' ,".END."})
		Aadd(aItensForm, {"S_","LTABLOC","0050",".EXE.","2","CalcAsmed"								,":=","5",".T."							,""		,"1"	,""					,".CNT."})
		Aadd(aItensForm, {"S_","LTABLOC","0060",".EXE." ,"1" ,"SRA->RA_ASMEDIC"                   	 ,""  ," ",""							,""     ,""     ,""                ,".END."})	
	Endif	
	fFormGrava(cNomeForm,cDescForm,cResult,cDescDet,cVersao,aItensForm)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CARREGAR A MOVIMENTACAO DO MES NA MATRIZ DE CALCULO     	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeForm 		:= PADR("GRAVA CALCULO",TAMSX3("RC2_CODIGO")[1])
cResult			:= PADR("LGRAVA",TAMSX3("RC2_RETURN")[1])
cDescForm		:= STR0021   //"GRAVACAO DO CALCULO "
cDescDet		:= STR0022   //"GRAVACAO DO CACLULO DA FOLHA"
cVersao			:= "002"
aItensForm	 	:= {}
If RC2->(! dbSeek(cFilRC2 + cNomeForm)) .Or. RC2->RC2_VERSAO # cVersao
	
	//--           		Origem	Codigo  	Seq Tipo	Tipo	Resultado			                Opera01    	Tipo	Form01				Opera02	Tipo  	Form02		Opera03
	//--												Result. 				  				                Form1								Form2
	Aadd(aItensForm, {"S_","LGRAVA","0010",".EXE." ,"3" ,"GRAVACALC()"                              ,""  ," ",""								          ,""  ,"" ,""  ,".END."})
	
	fFormGrava(cNomeForm,cDescForm,cResult,cDescDet,cVersao,aItensForm)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CARREGAR A MOVIMENTACAO DO MES NA MATRIZ DE CALCULO     	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeForm 		:= PADR("CARGA A.D.T.S.",TAMSX3("RC2_CODIGO")[1])
cResult			:= PADR("SIND_ANT",TAMSX3("RC2_RETURN")[1])
cDescForm		:= STR0031   //"CARGA DA TABELA DE ADICIONAL TEMPO SERVICO"
cDescDet		:= STR0031   //"CARGA DA TABELA DE ADICIONAL TEMPO SERVICO"
cVersao			:= "001"
aItensForm	 	:= {}
If RC2->(! dbSeek(cFilRC2 + cNomeForm)) .Or. RC2->RC2_VERSAO # cVersao
	
	//--           		Origem	Codigo  	Seq Tipo	Tipo	Resultado			                Opera01    	Tipo	Form01				Opera02	Tipo  	Form02		Opera03
	//--												Result. 				  				                Form1								Form2
	Aadd(aItensForm, {"S_","SIND_ANT","0010",".CON." ,"" ,""                                       ,""  ,"2","SIND_ANT"					,"<>"   ,"1"    ,'SRA->RA_SINDICA' ,".END."})
	Aadd(aItensForm, {"S_","SIND_ANT","0020",".EXE." ,"3" ,"CARR_ADTS(aCodfol)"                    ,""  ," ",""							,""     ,""     ,""                ,".CNT."})
	Aadd(aItensForm, {"S_","SIND_ANT","0030",".EXE." ,"1" ,"SRA->RA_SINDICA"                    		,""  ," ",""							,""     ,""     ,""                ,".END."})
	
	fFormGrava(cNomeForm,cDescForm,cResult,cDescDet,cVersao,aItensForm)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MONTAGEM DA FORMULA DE CALCULO DE PROVISAO CHILE			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cPaisLoc = "CHI"
	cNomeForm 		:= PADR("PROVFER",TAMSX3("RC2_CODIGO")[1])
	cResult			:= PADR("nValProv",TAMSX3("RC2_RETURN")[1])
	cDescForm		:= STR0032  	//"Calculo da provisao de ferias"
	cDescDet		:= STR0033	    //"Calculo da provisao de ferias + encargos."
	cVersao			:= "002"
	aItensForm	 	:= {}
	If RC2->(! dbSeek(cFilRC2 + cNomeForm)) .Or. RC2->RC2_VERSAO # cVersao
    		
	//--           		Origem	Codigo   	Seq Tipo	Tipo	Resultado			                Opera01    	Tipo	Form01				Opera02	Tipo  	Form02		Opera03
	//--												Result. 				  				                Form1								Form2
		Aadd(aItensForm, {"S_","PROVFER","0010",".EXE." ,"3" ,"M_VALPROF", ":=", "5","0"						,""		,"1" ,""				    		,".CNT."})
		Aadd(aItensForm, {"S_","PROVFER","0020",".EXE." ,"3" ,"M_RESULTAD",":=","5","0"							,""		,"1" ,""							,".CNT."})
		Aadd(aItensForm, {"S_","PROVFER","0030",".EXE." ,"3" ,"M_VALMANT", ":=","5","0"							,""		,"1" ,""							,".CNT."})
		Aadd(aItensForm, {"S_","PROVFER","0040",".EXE." ,"3" ,"M_DFVEN",   ":=","5","0"							,""		,"1" ,""							,".CNT."})
		Aadd(aItensForm, {"S_","PROVFER","0050",".EXE." ,"3" ,"M_DFPRO",   ":=","5","0"							,""		,"1" ,""							,".CNT."})
		Aadd(aItensForm, {"S_","PROVFER","0060",".EXE." ,"3" ,"dDtMant",   ":=","5","MonthSub(dDataBase,1)"		,""		,"1" ,""							,".CNT."})
		Aadd(aItensForm, {"S_","PROVFER","0070",".EXE." ,"3" ,"FPOSREG('SRF',1,SRA->RA_FILIAL+SRA->RA_MAT,,)"	,""	    ,"1" ,""  ,"" ,"1" ,"" 				,".CNT."})
		Aadd(aItensForm, {"S_","PROVFER","0080",".CON." ,"3" ,"","","","! Empty(SRF->RF_DATABAS)"				,""		,"1" ,"" 							,".END."})
		Aadd(aItensForm, {"S_","PROVFER","0090",".EXE." ,"3" ,"Calc_Fer(SRF->RF_DATABAS,ddatabase,@M_DFVEN,@M_DFPRO)"	,""	,"1"  ,"" ,""  ,"1",""  		,".CNT."})
		Aadd(aItensForm, {"S_","PROVFER","0100",".EXE." ,"3" ,"M_VALPROF",":=","3","(SALDIA*(M_DFVEN+M_DFPRO)) * M_PERCENC"           ,"/" ,"3","M_DIASANO" ,".CNT."})
		Aadd(aItensForm, {"S_","PROVFER","0110",".EXE." ,"3" ,"FGERAVERBA(ACODFOL[776][1],M_VALPROF,M_DFVEN+M_DFPRO,,,,,,,,.T.,)","","3","","","1",""		,".CNT."})
		Aadd(aItensForm, {"S_","PROVFER","0120",".EXE." ,"2" ,"M_VALMANT",":=","3",'FBUSCAACM(ACODFOL[776][1],,dDtMant,dDtMant,"V",)',"","1",""				,".CNT."})
		Aadd(aItensForm, {"S_","PROVFER","0130",".EXE." ,"3" ,"M_RESULTAD",":=","3","(M_VALPROF -  M_VALMANT)","","3",""									,".CNT."})
		Aadd(aItensForm, {"S_","PROVFER","0140",".EXE." ,"3" ,"FGERAVERBA(ACODFOL[130][1],M_RESULTAD,,,,,,,,,.T.,)","","1","","","1",""						,".END."})
	Endif
	fFormGrava(cNomeForm,cDescForm,cResult,cDescDet,cVersao,aItensForm)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GpGeraRotLocºAutor  ³Microsiga           º Data ³  02/18/04 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera Roteiro de Calculo - Localizacoes                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGeraRotLoc(cFil,lPadrao,aRotPadrao,aRoteiro)
Local cROT_FOL	:= ""
Local cROT_ADI	:= ""
Local cROT_FER	:= ""
Local cROT_RES	:= ""
Local cROT_131	:= ""
Local cROT_132	:= ""
Local cROT_LUC := ""
Local lRet		:= .T.

aAdd( aRotPadrao , { "FOL" , STR0023 } )	//"FOLHA"
aAdd( aRotPadrao , { "ADI" , STR0024 } )	//"ADIANTAMENTO"
aAdd( aRotPadrao , { "FER" , STR0025 } )	//"FERIAS"
aAdd( aRotPadrao , { "RES" , STR0026 } ) 	//"RESCISAO"
aAdd( aRotPadrao , { "131" , STR0027 } )	//"1a. PARCELA DO 13o. SALARIO"
aAdd( aRotPadrao , { "132" , STR0028 } )	//"2a. PARCELA DO 13o. SALARIO"
If cPaisLoc == "DOM"
	aAdd( aRotPadrao , { "LUC" , STR0029 } )	//"Participacao nos Lucros
Endif
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis p/facilitar a visualizacao e manutencao dos roteiros³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cROT_FOL := aRotPadrao[ 1 , 1 ]
cROT_ADI := aRotPadrao[ 2 , 1 ]
cROT_FER := aRotPadrao[ 3 , 1 ]
cROT_RES := aRotPadrao[ 4 , 1 ]
cROT_131 := aRotPadrao[ 5 , 1 ]
cROT_132 := aRotPadrao[ 6 , 1 ]
If cPaisLoc == "DOM"
	cROT_LUC := aRotPadrao[ 7 , 1 ]
Endif
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Se nao For para Retornar o aRotPadrao Carrega os Roteiros     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !( lPadrao )
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Adiciona o Roteiro de Calculo da folha ( FOL )			   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	RotFol( cROT_FOL , c__Roteiro , cPaisLoc , @aRoteiro )
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Adiciona o Roteiro de Calculo do Adiantamento   			   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	RotAdi( cROT_ADI , c__Roteiro , cPaisLoc , @aRoteiro )
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Adiciona o Roteiro de Calculo da 1a. Parcela do 13o. Salario ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Rot131( cROT_131 , c__Roteiro , cPaisLoc , @aRoteiro )
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Adiciona o Roteiro de Calculo da 2a. Parcela do 13o. Salario ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Rot132( cROT_132 , c__Roteiro , cPaisLoc , @aRoteiro )
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Adiciona o Roteiro de Calculo da Rescisao					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	RotRes( cROT_RES , c__Roteiro , cPaisLoc , @aRoteiro )
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Adiciona o Roteiro de Calculo de Ferias  					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	RotFer( cROT_FER , c__Roteiro , cPaisLoc , @aRoteiro )
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Adiciona o Roteiro de Calculo de Participacao Lucro          |
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If cPaisLoc == "DOM"
		RotLuc( cROT_LUC , c__Roteiro , cPaisLoc , @aRoteiro )
	Endif
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Efetua a Geracao dos Roteiros Padroes    					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	lRet := FCriaRotLoc( cFil , c__Roteiro , aRotPadrao )
Else
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Caso contrario Retorna apenas o aRotPadrao					³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	lRet := lPadrao
EndIF

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RotFol			  ³ Equipe Advanced RH	  ³ Data ³    	  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Adiciona os Roteiros Padroes FOL      				 	        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function RotFol( cROT_FOL , c__Roteiro , cPaisLoc , aRoteiro )

If c__Roteiro == cROT_FOL .And. cPaisLoc = 'ARG'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ROTEIRO DO CALCULO DE FOLHA - ARGENTINA                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRoteiro,{ cROT_FOL,'00010','','Carga Tablas de Calculo'		,'','S_CARGA TABELAS','' , 'NI347' } )
	Aadd(aRoteiro,{ cROT_FOL,'00020','','Carga Tabla Adic.Tiempo Servicio','','S_CARGA A.D.T.S.','' , 'NI351' } )
	Aadd(aRoteiro,{ cROT_FOL,'00030','','Carga Conceptos del Movto. para Calculo'	,'','S_CARREGA MOVIMEN','' , 'NI341' } )
	Aadd(aRoteiro,{ cROT_FOL,'00040','','Montaje de Sueldo Mensual'	,'','S_SALARIO MENSAL','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00050','','Montaje de Sueldo Hora'   	,'','S_SALARIO HORA','' , 'NI310' } )
	Aadd(aRoteiro,{ cROT_FOL,'00060','','Montaje de Sueldo Dia'    	,'','S_SALARIO DIA','' , 'NI311' } )
	Aadd(aRoteiro,{ cROT_FOL,'00070','','Montaje de Sueldo Base'   	,'','S_SALARIO BASE','' , 'NI312' } )
	Aadd(aRoteiro,{ cROT_FOL,'00080','','Var.p/Calc.Dissidio','Type("lDissidio")="U"','lDissidio := .F.','' , 'NI337' } )
	Aadd(aRoteiro,{ cROT_FOL,'00090','','Calculo do Salario Dissidio','lDissidio','FSalDiss(@Salario,@SalHora,@SalDia,@SalMes,,cTipoAum)','' , 'NI338' } )	
	Aadd(aRoteiro,{ cROT_FOL,'00100','','Preserva aPd p/Dissidio','lDissidio','aPdOld := aClone(aPD)','' , 'NI381' } )
	Aadd(aRoteiro,{ cROT_FOL,'00110','','Generacion de la Resc.en el Movto del Calc.','','S_GERAR RESCISOES','' , 'NI343' } )
	Aadd(aRoteiro,{ cROT_FOL,'00120','','Generacion Val.Futuros en el Movto del Calc.' ,'','S_VALORES FUTUROS','NI344' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00130','','DIAS TRABAJADOS '    			,'','FDiasTrab(@DiasTrab,cDiasMes,@lAdmissao)'   ,'' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00140','','DIAS DE LICENCIA   ' 			,'','FDiasAfast(@nDiasAfas,@DiasTrab)'           ,'' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00150','','CALCULO D.S.R'       			,'','FCalcDSR(@nDsr,lAdmissao,@nHorasTrab,@nHorasDsr)','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00160','','GENERA SUELDO'       			,'','FGravaSal(aCodFol,Diastrab,nHorasTrab,nDsr,nHorasDsr)','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00170','','SITUACION'           			,'cSitFolh = "O"','DESPREZAFUNCIONARIO','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00180','','VALORIZA CONCEPTOS'  			,'','FValoriza(@aPd,aCodFol,@SalMes,@SalDia,@SalHora,Val_SalMin,DiasTrab)','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00190','','CALCULO LICENCIAS'   			,'','FAfastados(aCodFol)','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00200','','VACACIONES'          			,'','LOCGerVac()','' , '' } ) 
	Aadd(aRoteiro,{ cROT_FOL,'00210','','Calcula Dif. Ferias'			,'','FCalcDifFer(aCodFol)','', '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00220','','Variavel Sal. Incorporado','','P_ADCINTEG := If(P_ADCINTEG == Nil,.F.,P_ADCINTEG)','', 'NI245' } )
	Aadd(aRoteiro,{ cROT_FOL,'00230','','Codigo Ad.Tiempo Servicio','','cCodAdt  := Space(3)','', 'NI246' } )
	Aadd(aRoteiro,{ cROT_FOL,'00240','','Valor Ad.Tiempo Servicio','','nAdtServ := 0.00','', 'NI247' } )
	Aadd(aRoteiro,{ cROT_FOL,'00250','','Calcula Ad.Tiempo Servicio','','fCalAdt(aCodfol,@nAdtServ,"S",SalMes,,P_ADCINTEG)','', 'NI248' } )
	Aadd(aRoteiro,{ cROT_FOL,'00260','','LICENCIAS ESPECIALES'			,'','LOCLicEsp()','' , '' } ) 
	Aadd(aRoteiro,{ cROT_FOL,'00270','','ASIGN. FAMILIARES'   			,'SRA->RA_CATFUNC <> "A"','LOCSALFAM()','' , '' } ) 
	Aadd(aRoteiro,{ cROT_FOL,'00280','','PRESENTISMO'         			,'SRA->RA_CATFUNC <> "A".And.!Empty(SRA->RA_SINDICA)','LOCPresent()','' , '' } ) 
	Aadd(aRoteiro,{ cROT_FOL,'00290','','APORTE JUBILACION'   			,'SRA->RA_CATFUNC <> "A"','LOCJUBILA()','' , '' } ) 
	Aadd(aRoteiro,{ cROT_FOL,'00300','','OBRA SOCIAL'         			,'SRA->RA_CATFUNC <> "A"','LOCOBRSOC()','' , '' } ) 
	Aadd(aRoteiro,{ cROT_FOL,'00310','','LEY 19.032'          			,'SRA->RA_CATFUNC <> "A"','LOCAPLEY1()','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00320','','SINDICATO'           			,'SRA->RA_CATFUNC <> "A".And.!Empty(SRA->RA_SINDICA)','LOCSINDIC()','' , '' } ) 
	Aadd(aRoteiro,{ cROT_FOL,'00330','','ANSES'               			,'.F.','LOCANSES()','' , '' } ) //Consultar contador
	Aadd(aRoteiro,{ cROT_FOL,'00340','','Calc. tickets'       			,'SRA->RA_CATFUNC <> "A"','CalRefeicao(aCodFol,aRefeicao)','', '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00350','','CALCULO DE ART'      			,'','LOC_ART()','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00360','','DIF. AGUINALDO'      			,'cComp13 = "S"','LOCDIFAGUI()','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00370','','RETENCIONES GANANCIA'			,'','LOCGANANC()','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00380','','NETO A COBRAR'       			,'','fLiquido(aCodfol,aCodfol[47,1],nValArred,aCodfol[43,1],.T.,aCodFol[45,1],.T.)','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00390','','PRORRATEO C.COSTO'   			,'cSitFolh # "D"','fEncarCc()','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00400','','Grava o Calculo '				,'','S_GRAVA CALCULO','', 'NI346' } )
ElseIf c__Roteiro == cROT_FOL .And. cPaisLoc = 'CHI'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ROTEIRO DO CALCULO DE FOLHA - CHILE                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRoteiro,{ cROT_FOL,'00010','','Carga Tablas de Calculo'		,'','S_CARGA TABELAS','' , 'NI347' } )
	Aadd(aRoteiro,{ cROT_FOL,'00020','','Carga Conceptos del Movto. para Calculo'	,'','S_CARREGA MOVIMEN','' , 'NI341' } )
	Aadd(aRoteiro,{ cROT_FOL,'00030','','Montaje de Sueldo Mensual'	,'','S_SALARIO MENSAL','' , 'NI462' } )
	Aadd(aRoteiro,{ cROT_FOL,'00040','','Montaje de Sueldo Hora'   	,'','S_SALARIO HORA','' , 'NI310' } )
	Aadd(aRoteiro,{ cROT_FOL,'00050','','Montaje de Sueldo Dia'    	,'','S_SALARIO DIA','' , 'NI311' } )
	Aadd(aRoteiro,{ cROT_FOL,'00060','','Montaje de Sueldo Base'   	,'','S_SALARIO BASE','' , 'NI312' } )
	Aadd(aRoteiro,{ cROT_FOL,'00070','','Var.p/Calc.Dissidio','Type("lDissidio")="U"','lDissidio := .F.','' , 'NI337' } )
	Aadd(aRoteiro,{ cROT_FOL,'00080','','Calculo do Salario Dissidio','lDissidio','FSalDiss(@Salario,@SalHora,@SalDia,@SalMes,,cTipoAum)','' , 'NI338' } )	
	Aadd(aRoteiro,{ cROT_FOL,'00090','','Preserva aPd p/Dissidio','lDissidio','aPdOld := aClone(aPD)','' , 'NI381' } )
	Aadd(aRoteiro,{ cROT_FOL,'00100','','Generacion de la Resc.en el Movto del Calc.','','S_GERAR RESCISOES','' , 'NI343' } )
	Aadd(aRoteiro,{ cROT_FOL,'00110','','Generacion Val.Futuros en el Movto del Calc.' ,'','S_VALORES FUTUROS','' , 'NI344' } )
	Aadd(aRoteiro,{ cROT_FOL,'00120','','Carga Tablas de Calculo'		,'','S_CARGA TABLOC','' , 'NI347' } )
	Aadd(aRoteiro,{ cROT_FOL,'00130','','DIAS TRABAJADOS '    			,'','FDiasTrab(@DiasTrab,cDiasMes,@lAdmissao)'   ,'' , 'NI463' } )
	Aadd(aRoteiro,{ cROT_FOL,'00140','','DIAS DE LICENCIA   '	 		,'','FDiasAfast(@nDiasAfas,@DiasTrab)'           ,'' , 'NI464' } )
	Aadd(aRoteiro,{ cROT_FOL,'00150','','CALCULO D.S.R'       			,'','FCalcDSR(@nDsr,lAdmissao,@nHorasTrab,@nHorasDsr)','' , 'NI465' } )
	Aadd(aRoteiro,{ cROT_FOL,'00160','','GENERA SUELDO'       			,'','FGravaSal(aCodFol,Diastrab,nHorasTrab,nDsr,nHorasDsr)','' , 'NI466' } )
	Aadd(aRoteiro,{ cROT_FOL,'00170','','SITUACION'           			,'cSitFolh = "O"','DESPREZAFUNCIONARIO','' , 'NI467' } )
	Aadd(aRoteiro,{ cROT_FOL,'00180','','VALORIZA CONCEPTOS'  			,'','FValoriza(@aPd,aCodFol,@SalMes,@SalDia,@SalHora,Val_SalMin,DiasTrab)','' , 'NI468' } )
	Aadd(aRoteiro,{ cROT_FOL,'00190','','CALCULO LICENCIAS'   			,'','FAfastados(aCodFol)','' , 'NI469' } )
	Aadd(aRoteiro,{ cROT_FOL,'00200','','VACACIONES'          			,'','LOCGerVac()'   , '' , 'NI470' } )
	Aadd(aRoteiro,{ cROT_FOL,'00210','','CARGAS FAMILIARES'   			,'','LOCSALFAM()'   , '' , 'NI471' } )
	Aadd(aRoteiro,{ cROT_FOL,'00220','','GRATIFICACION'       			,'','LOCGratif()' , '' , 'NI472' } )
	Aadd(aRoteiro,{ cROT_FOL,'00240','','CALCULO SALUD'       			,'','LOCSalud()'    , '' , 'NI473' } )
	Aadd(aRoteiro,{ cROT_FOL,'00250','','SEGURO SOCIAL AFP'   			,'','LOCSegSoc()'   , '' , 'NI474' } )
	Aadd(aRoteiro,{ cROT_FOL,'00260','','Calc. Pensao Alim. '		   ,'','FCalcPensao(aCodFol[64,1],aCodFol[66,1],aCodFol[56,1],0,dData_Pgto)','', 'NI475' } )
	Aadd(aRoteiro,{ cROT_FOL,'00270','','IMPUESTO A LA RENTA' 			,'','LOCGananc()'   , '' , 'NI476' } )
	Aadd(aRoteiro,{ cROT_FOL,'00280','','APORTE PATRONAL'     			,'','LOCAportePa()' , '' , 'NI477' } )
	Aadd(aRoteiro,{ cROT_FOL,'00290','','AST. MEDICA'         			,'','AssiMed(aCodfol)','' , 'NI478' } )
	Aadd(aRoteiro,{ cROT_FOL,'00310','','NETO A COBRAR'       			,'','fLiquido(aCodfol,aCodfol[47,1],nValArred,aCodfol[43,1],.T.,aCodFol[45,1],.T.)','' , 'NI479' } )
	Aadd(aRoteiro,{ cROT_FOL,'00320','','PRORRATEO C.COSTO'   			,'cSitFolh # "D"','fEncarCc()','' , 'NI480' } )
	Aadd(aRoteiro,{ cROT_FOL,'00330','','PROVISION VACACIONES'   		,'','S_PROVFER' , '', 'NI461' } )
	Aadd(aRoteiro,{ cROT_FOL,'00340','','TOTALIZA CONCEPTOS'  			,'','LOCTOTCON()' , '' , 'NI481' } )
	Aadd(aRoteiro,{ cROT_FOL,'00350','','Grava o Calculo '				,'','S_GRAVA CALCULO','', 'NI346' } )
Elseif c__Roteiro == cROT_FOL .And. cPaisLoc = 'PAR'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ROTEIRO DO CALCULO DE FOLHA - PARAGUAI                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRoteiro,{ cROT_FOL,'00010','','Carga Tablas de Calculo'		,'','S_CARGA TABELAS','' , 'NI347' } )
	Aadd(aRoteiro,{ cROT_FOL,'00020','','Carga Conceptos del Movto. para Calculo'	,'','S_CARREGA MOVIMEN','' , 'NI341' } )
	Aadd(aRoteiro,{ cROT_FOL,'00030','','Montaje de Sueldo Mensual'	,'','S_SALARIO MENSAL','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00040','','Montaje de Sueldo Hora'   	,'','S_SALARIO HORA','' , 'NI310' } )
	Aadd(aRoteiro,{ cROT_FOL,'00050','','Montaje de Sueldo Dia'    	,'','S_SALARIO DIA','' , 'NI311' } )
	Aadd(aRoteiro,{ cROT_FOL,'00060','','Montaje de Sueldo Base'   	,'','S_SALARIO BASE','' , 'NI312' } )
	Aadd(aRoteiro,{ cROT_FOL,'00070','','Var.p/Calc.Dissidio','Type("lDissidio")="U"','lDissidio := .F.','' , 'NI337' } )
	Aadd(aRoteiro,{ cROT_FOL,'00080','','Calculo do Salario Dissidio','lDissidio','FSalDiss(@Salario,@SalHora,@SalDia,@SalMes,,cTipoAum)','' , 'NI338' } )	
	Aadd(aRoteiro,{ cROT_FOL,'00090','','Preserva aPd p/Dissidio','lDissidio','aPdOld := aClone(aPD)','' , 'NI381' } )
	Aadd(aRoteiro,{ cROT_FOL,'00100','','Generacion de la Resc.en el Movto del Calc.','','S_GERAR RESCISOES','' , 'NI343' } )
	Aadd(aRoteiro,{ cROT_FOL,'00110','','Generacion Val.Futuros en el Movto del Calc.' ,'','S_VALORES FUTUROS','NI344' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00120','','DIAS TRABAJADOS'     			,'','FDiasTrab(@DiasTrab,cDiasMes,@lAdmissao)'   ,'','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00130','','DIAS DE LICENCIA'    			,'','FDiasAfast(@nDiasAfas,@DiasTrab)'           ,'','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00140','','CALCULO D.S.R'       			,'','FCalcDSR(@nDsr,lAdmissao,@nHorasTrab,@nHorasDsr)','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00150','','GENERA SUELDO'       			,'','FGravaSal(aCodFol,DiasTRab,nHorasTrab,nDsr,nHorasDsr)','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00160','','SITUACION'           			,'cSitFolh = "O"'    ,'DESPREZAFUNCIONARIO','','' } )       
	Aadd(aRoteiro,{ cROT_FOL,'00170','','VALORIZA CONCEPTOS'  			,'','FValoriza(@aPd,aCodFol,@SalMes,@SalDia,@SalHora,Val_SalMin,DiasTrab)','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00180','','CALCULO LICENCIAS'   			,'','FAfastados(aCodFol)','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00190','','ASIGN. FAMILIARES'   			,'','LOCSALFAM()','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00200','','DESC. VACACIONES'    			,'','LOCGERVAC()','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00210','','DIF. AGUINALDO'      			,'cComp13 = "S"','LOCDIFAGUI()','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00220','','APORTE JUBILACION'   			,'','LOCJUBILA()','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00230','','Calculo Seguro'				,'','CalSeguro(aCodFol,@nSeguro,@nSegEmp,@Seguro_B,aSeguro)','', 'NI460' } )
	Aadd(aRoteiro,{ cROT_FOL,'00240','','NETO A COBRAR'       			,'','fLiquido(aCodfol,aCodfol[47,1],nValArred,aCodfol[43,1],.T.,aCodFol[45,1],.F.)','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00250','','PRORRATEO C.COSTO'   			,'cSitFolh # "D"'		 ,'fEncarCc()','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00260','','Grava o Calculo '				,'','S_GRAVA CALCULO','', 'NI346' } )
Elseif c__Roteiro == cROT_FOL .And. cPaisLoc = 'URU'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ROTEIRO DO CALCULO DE FOLHA - URUGUAI                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRoteiro,{ cROT_FOL,'00010','','Carga Tablas de Calculo'		,'','S_CARGA TABELAS','' , 'NI347' } )
	Aadd(aRoteiro,{ cROT_FOL,'00020','','Carga Conceptos del Movto. para Calculo'	,'','S_CARREGA MOVIMEN','' , 'NI341' } )
	Aadd(aRoteiro,{ cROT_FOL,'00030','','Montaje de Sueldo Mensual'	,'','S_SALARIO MENSAL','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00040','','Montaje de Sueldo Hora'   	,'','S_SALARIO HORA','' , 'NI310' } )
	Aadd(aRoteiro,{ cROT_FOL,'00050','','Montaje de Sueldo Dia'    	,'','S_SALARIO DIA','' , 'NI311' } )
	Aadd(aRoteiro,{ cROT_FOL,'00060','','Montaje de Sueldo Base'   	,'','S_SALARIO BASE','' , 'NI312' } )
	Aadd(aRoteiro,{ cROT_FOL,'00070','','Var.p/Calc.Dissidio','Type("lDissidio")="U"','lDissidio := .F.','' , 'NI337' } )
	Aadd(aRoteiro,{ cROT_FOL,'00080','','Calculo do Salario Dissidio','lDissidio','FSalDiss(@Salario,@SalHora,@SalDia,@SalMes,,cTipoAum)','' , 'NI338' } )	
	Aadd(aRoteiro,{ cROT_FOL,'00090','','Preserva aPd p/Dissidio','lDissidio','aPdOld := aClone(aPD)','' , 'NI381' } )
	Aadd(aRoteiro,{ cROT_FOL,'00100','','Geracao das ferias no Movto. de calculo'	,'','S_GERAR FERIAS','' , 'NI342' } )
	Aadd(aRoteiro,{ cROT_FOL,'00110','','Generacion de la Resc.en el Movto del Calc.','','S_GERAR RESCISOES','' , 'NI343' } )
	Aadd(aRoteiro,{ cROT_FOL,'00120','','Generacion Val.Futuros en el Movto del Calc.' ,'','S_VALORES FUTUROS','NI344' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00130','','Carga Tablas de Calculo'		,'','S_CARGA TABLOC','' , 'NI486' } )	
	Aadd(aRoteiro,{ cROT_FOL,'00140','','DIAS TRABAJADOS'     			,''                         ,'FDiasTrab(@DiasTrab,cDiasMes,@lAdmissao)'   ,'','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00150','','DIAS DE LICENCIA'    			,''                         ,'FDiasAfast(@nDiasAfas,@DiasTrab)'           ,'','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00160','','CALCULO D.S.R'       			,''                         ,'FCalcDSR(@nDsr,lAdmissao,@nHorasTrab,@nHorasDsr)','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00170','','GENERA SUELDO'       			,''                         ,'FGravaSal(aCodFol,DiasTRab,nHorasTrab,nDsr,nHorasDsr)','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00180','','SITUACION'           			,'cSitFolh = "O"'    ,'DESPREZAFUNCIONARIO','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00190','','CALCULO LICENCIAS'   			,''                         ,'FAfastados(aCodFol)','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00200','','VALORIZA CONCEPTOS'  			,''                         ,'FValoriza(@aPd,aCodFol,@SalMes,@SalDia,@SalHora,Val_SalMin,DiasTrab)','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00210','','Calcula Dif. Ferias','','FCalcDifFer(aCodFol)','', '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00220','','PRIMA ANTIGUEDAD'    			,''						  		   ,'LOCATSER()','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00230','','SUSTUTIVO DE CARNE'  			,''						  		   ,'LOCSUSCAR(1)','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00240','','DIF. AGUINALDO'      			,'cComp13 = "S"','LOCDIFAGUI()','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00250','','ADELANTO AGUI'       			,''                         ,'LOCADEAGUI()','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00260','','Calc. Ticket Alimentacion'  	,'','LocTicketAlim(aCodfol)','', 'NI487' } )	
	Aadd(aRoteiro,{ cROT_FOL,'00270','','APORTE JUBILACION'   			,''						  		   ,'LOCJUBILA()','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00280','','CALCULO FONASA'       			,''                         ,'LOCFONASA()','' , 'NI499' } )
	Aadd(aRoteiro,{ cROT_FOL,'00290','','Calc. Pensao Alim. '			,'','FCalcPensao(aCodFol[64,1],aCodFol[66,1],aCodFol[56,1],0,dData_Pgto)','', '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00300','','Calc. Ass. Medica'				,'','AssiMed(aCodfol)','', 'NI484' } )
	Aadd(aRoteiro,{ cROT_FOL,'00310','','Calc. Ass. Odontologica'   	,'','fAssOdon(aCodfol)','', 'NI485' } )	
	Aadd(aRoteiro,{ cROT_FOL,'00320','','Calc. Seguro de Vida'       	,'','LocSeguro(aCodfol)','', 'NI488' } )	                                                 	
	Aadd(aRoteiro,{ cROT_FOL,'00330','','Calc. Exceso de Partidas en Especie' ,'','LocExceso(aCodfol)','', 'NI489' } )
    Aadd(aRoteiro,{ cROT_FOL,'00340','','RETENCIONES GANANCIA'           ,''                         ,'If(MesAno(dDataBase) < "200707",LOCGANANC(),LOCIRPF())','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00350','','CJPPU'  			            ,''						  		  ,'LocCJPPU()','','NI490' } )
	Aadd(aRoteiro,{ cROT_FOL,'00360','','Fondo de Solidariedad'  		,''						  		  ,'LocFonSol()','','NI491' } )
	Aadd(aRoteiro,{ cROT_FOL,'00370','','Focer'                  		,''						  		  ,'LocFocer()','','NI492' } )
	Aadd(aRoteiro,{ cROT_FOL,'00380','','Fosvoc'                  		,''						  		  ,'LocFosvoc()','','NI493' } )	
	Aadd(aRoteiro,{ cROT_FOL,'00390','','Fondos Sociales de la Construcción ' 	,''					      ,'LocFonSoc()','','NI511' } )	
	Aadd(aRoteiro,{ cROT_FOL,'00400','','VALORIZA CONCEPTOS'  			,''						  		  ,'FValoriza(@aPd,aCodFol,@SalMes,@SalDia,@SalHora,Val_SalMin,DiasTrab)','','' } )	
    Aadd(aRoteiro,{ cROT_FOL,'00410','','CALC. MONTO NOMINAL ',''                         ,'LOCBASNOM()','' , '' } )
	Aadd(aRoteiro,{ cROT_FOL,'00420','','NETO A COBRAR'       			,''						  		  ,'fLiquido(aCodfol,aCodfol[47,1],nValArred,aCodfol[43,1],.T.,,)','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00430','','PRORRATEO C.COSTO'   			,'SRA->RA_SITFOLH # "D"'	  ,'fEncarCc()','','' } )
	Aadd(aRoteiro,{ cROT_FOL,'00440','','Grava o Calculo '				,'','S_GRAVA CALCULO','', 'NI346' } )
Endif

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ RotAdi	  		  ³ Equipe Advanced RH	  ³ Data ³    	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Adiciona os Roteiros Padroes ADI      	     		 	        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function RotAdi( cROT_ADI , c__Roteiro , cPaisLoc , aRoteiro )

If c__Roteiro == cROT_ADI .And. cPaisLoc == "CHI"
	Aadd(aRoteiro,{ cROT_ADI,'00010','','Carga Tablas de Calculo'  	,'','S_CARGA TABELAS','' , 'NI347' } )
	Aadd(aRoteiro,{ cROT_ADI,'00020','','Carga Conceptos del Movto. para Calculo'  	,'','S_CARREGA MOVIMEN','' , 'NI341' } )
	Aadd(aRoteiro,{ cROT_ADI,'00030','','Carga Tablas de Calculo'		,'','S_CARGA TABLOC','' , 'NI347' } )
	Aadd(aRoteiro,{ cROT_ADI,'00040','','Porcentaje > 0'					,'SRA->RA_PERCADT = 0 .Or. SRA->RA_TIPOPGT = "S"','Calcule := "N"','' , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00050','','Situacion Normal'				,'SRA->RA_SITFOLH # SPACE(1)','Calcule := "N"', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00060','','Dias Trabajados'					,'','FDiasAdiant(@Diastb,@dDtAfMat)', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00070','','Variable p/Definir Pago Sal.Maternidad','','cPgSalMat := fPgMater()','' , 'NI207 16' } )
	Aadd(aRoteiro,{ cROT_ADI,'00080','','Consiste los Dias Trabajados','(DiasTb >= 15 .And. SRA->RA_SITFOLH#"D") .Or. ( SRA->RA_SITFOLH = "A" .And. SRA->RA_AFASFGT = "Q" .And. cPgSalMat="S" )','Calcule := "S"','Calcule := "N"','' } )
	Aadd(aRoteiro,{ cROT_ADI,'00090','','Testea Admision'					,'SRA->RA_ADMISSA > dDataBase','Calcule := "N"','','' } )
	Aadd(aRoteiro,{ cROT_ADI,'00100','','Mas que 15 dias'					,'dDataBase - SRA->RA_ADMISSA < 15','Calcule := "N"','','' } )
	Aadd(aRoteiro,{ cROT_ADI,'00110','','Dias Trabajados Salario Maternidad','SRA->RA_SITFOLH="A" .AND. SRA->RA_AFASFGT="Q" .AND. cPgSalMat="S"','DIASTB:=30','','NI205 05'} )
	Aadd(aRoteiro,{ cROT_ADI,'00120','','Composicion Mes'					,'cCompMes = "S" .And. SRA->RA_CATFUNC = "H"','cTip := "B"','cTip := "A"','NI205 03'} )
	Aadd(aRoteiro,{ cROT_ADI,'00130','','Salarios'							,'','fSalario(@Salario,@SalHora,@Saldia,@SalMes,cTip)', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00140','','Adm. o Propor.'					,'cAdtoPro = "S" .And. SRA->RA_SITFOLH # "D" .And. MesAno(SRA->RA_ADMISSA) <= MesAno(dDataBase)','Calcule := "S"','','NI204 12' } )
	Aadd(aRoteiro,{ cROT_ADI,'00150','','Inicializar aPd'					,'','aPd := {}','','NI204 13' } )
	Aadd(aRoteiro,{ cROT_ADI,'00160','','Valoriza'							,'','FValoriza(aPd,aCodFol,@SalMes,@SalDia,@SalHora,Val_SalMin)', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00170','','Carga Adelanto'					,'','FCarPDAdiant()', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00180','','DIAS TRABAJADOS '    			,'','FDiasTrab(@DiasTrab)'   ,'' , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00190','','DIAS DE LICENCIA   ' 			,'','FDiasAfast(@nDiasAfas,@DiasTrab)'           ,'' , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00200','','Guarda verbas       '			,'SRA->RA_ANTLIQ == "1" .And. SRA->RA_PERCADT > 0 .And. SRA->RA_ANTICI = 0','aPdTmp:=aClone(aPd)', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00210','','Limpiar aPd    '					,'SRA->RA_ANTLIQ == "1" .And. SRA->RA_PERCADT > 0 .And. SRA->RA_ANTICI = 0','aPd := {}','','' } )
	Aadd(aRoteiro,{ cROT_ADI,'00220','','Carrega valores informados'	,'SRA->RA_ANTLIQ == "1" .And. SRA->RA_PERCADT > 0 .And. SRA->RA_ANTICI = 0','Aeval(aPdTmp,{|x| IIf(x[7]=="I",AAdd(aPd,x),Nil) })','' , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00230','','SUELDO '             			,'SRA->RA_ANTLIQ == "1" .And. SRA->RA_PERCADT > 0 .And. SRA->RA_ANTICI = 0','FSalario(@Salario,@SalHora,@SalDia,@SalMes)','' , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00240','','CALCULO D.S.R'       			,'SRA->RA_ANTLIQ == "1" .And. SRA->RA_PERCADT > 0 .And. SRA->RA_ANTICI = 0','FCalcDSR(@nDsr,lAdmissao,@nHorasTrab,@nHorasDsr)','' , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00250','','GENERA SUELDO'       			,'SRA->RA_ANTLIQ == "1" .And. SRA->RA_PERCADT > 0 .And. SRA->RA_ANTICI = 0','FGravaSal(aCodFol,Diastrab,nHorasTrab,nDsr,nHorasDsr)','' , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00260','','GRATIFICACION'       			,'SRA->RA_ANTLIQ == "1" .And. SRA->RA_PERCADT > 0 .And. SRA->RA_ANTICI = 0','LOCGratif()'   , '' , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00270','','CALCULO SALUD'       			,'SRA->RA_ANTLIQ == "1" .And. SRA->RA_PERCADT > 0 .And. SRA->RA_ANTICI = 0','LOCSalud()'    , '' , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00280','','SEGURO SOCIAL AFP'   			,'SRA->RA_ANTLIQ == "1" .And. SRA->RA_PERCADT > 0 .And. SRA->RA_ANTICI = 0','LOCSegSoc()'   , '' , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00290','','IMPUESTO A LA RENTA' 			,'SRA->RA_ANTLIQ == "1" .And. SRA->RA_PERCADT > 0 .And. SRA->RA_ANTICI = 0','LOCGananc()'   , '' , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00300','','Adelandto Informado' 			,'','FVerAdiant()', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00310','','Calcula ?'							,'Calcule # "S"' , 'DESPREZAFUNCIONARIO', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00320','','Restaura Verbas'     			,'SRA->RA_ANTLIQ == "1" .And. SRA->RA_PERCADT > 0 .And.  SRA->RA_ANTICI = 0','aPd:=aClone(aPdTmp)', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00330','','Calcula Liquido'     			,' ','CALCLIQ(VAL_ADTO+nValOutros,0)', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00340','','Redondeo'       					,'nValArred > 0','CALC_ARRE(@VAL_LIQ,@nValArred,@VAL_ARRE)', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00350','','Genera Adelanto'					,'VAL_LIQ # 0' ,'FGeraVerba(aCodfol[7,1],Round(VAL_LIQ,MsDecimais(1)) ,0.00,cSEMANA, ,"V","A")', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00360','','Genera Redondeo'					,'VAL_ARRE # 0','FGeraVerba(aCodfol[8,1],VAL_ARRE,0.00,cSEMANA , ,"V","A")', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00370','','Grava o Calculo '				,'','S_GRAVA CALCULO','', 'NI350' } )
ElseIf c__Roteiro == cROT_ADI
	Aadd(aRoteiro,{ cROT_ADI,'00010','','Carga Tablas de Calculo'  	,'','S_CARGA TABELAS','' , 'NI347' } )
	Aadd(aRoteiro,{ cROT_ADI,'00020','','Carga Conceptos del Movto. para Calculo'  	,'','S_CARREGA MOVIMEN','' , 'NI341' } )
	Aadd(aRoteiro,{ cROT_ADI,'00030','','Percentual > 0','SRA->RA_PERCADT = 0 .Or. SRA->RA_TIPOPGT = "S"','Calcule := "N"','' , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00040','','Situacao Normal','SRA->RA_SITFOLH # SPACE(1)','Calcule := "N"', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00050','','Dias Trabalhados','','FDiasAdiant(@Diastb,@dDtAfMat)', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00060','','Variavel p/Definir Pagto.Sal.Maternidade','','cPgSalMat := fPgMater()','' , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00070','','Consiste os Dias Trabalhados','(DiasTb >= 15 .And. SRA->RA_SITFOLH#"D") .Or. ( SRA->RA_SITFOLH = "A" .And. SRA->RA_AFASFGT = "Q" .And. cPgSalMat="S" )','Calcule := "S"','Calcule := "N"','' } )
	Aadd(aRoteiro,{ cROT_ADI,'00080','','Testa Admissao','SRA->RA_ADMISSA > dDataBase','Calcule := "N"','','' } )
	Aadd(aRoteiro,{ cROT_ADI,'00090','','Mais que 15 dias','( dDataBase - SRA->RA_ADMISSA + 1 ) < 15','Calcule := "N"','','' } )
	Aadd(aRoteiro,{ cROT_ADI,'00100','','Dias Trabalhados Salario Maternidade','SRA->RA_SITFOLH="A" .AND. SRA->RA_AFASFGT="Q" .AND. cPgSalMat="S"','DIASTB:=30','',''} )
	Aadd(aRoteiro,{ cROT_ADI,'00110','','Composicao Mes','cCompMes = "S" .And. SRA->RA_CATFUNC = "H"','cTip := "B"','cTip := "A"',''} )
	Aadd(aRoteiro,{ cROT_ADI,'00120','','Montagem do Salario Mensal','SRA->RA_CATFUNC # "T"','S_SALARIO MENSAL','' , 'NI255' } )
	Aadd(aRoteiro,{ cROT_ADI,'00130','','Montagem do Salario Hora'  ,'SRA->RA_CATFUNC # "T"','S_SALARIO HORA','' , 'NI313' } )
	Aadd(aRoteiro,{ cROT_ADI,'00140','','Montagem do Salario Dia'   ,'SRA->RA_CATFUNC # "T"','S_SALARIO DIA','' , 'NI314' } )
	Aadd(aRoteiro,{ cROT_ADI,'00150','','Montagem do Salario Base'  ,'SRA->RA_CATFUNC # "T"','S_SALARIO BASE','' , 'NI315' } )
	Aadd(aRoteiro,{ cROT_ADI,'00160','','Variavel Tarefas  ' ,'SRA->RA_CATFUNC == "T"','aTarefas := {}','', 'NI256' } )
	Aadd(aRoteiro,{ cROT_ADI,'00170','','Geracao de Tarefas' ,'SRA->RA_CATFUNC == "T"','GeraTarefa(dDataDe,dDataAte,@aTarefas,"N")','', 'NI257' } )
	Aadd(aRoteiro,{ cROT_ADI,'00180','','Salario Tarefeiro','SRA->RA_CATFUNC == "T" .And. Len(aTarefas) > 0','Aeval(aTarefas, { |X| SalMes += X[2] })', '', 'NI258' } )
	Aadd(aRoteiro,{ cROT_ADI,'00190','','Adm. ou Propor.','cAdtoPro = "S" .And. SRA->RA_SITFOLH # "D" .And. MesAno(SRA->RA_ADMISSA) <= MesAno(dDataBase)','Calcule := "S"','','' } )
	Aadd(aRoteiro,{ cROT_ADI,'00200','','Inicializar aPd','','aPd := {}','','' } )
	Aadd(aRoteiro,{ cROT_ADI,'00210','','Variavel Sal. Incorporado','','P_ADCINTEG := If(P_ADCINTEG == Nil,.F.,P_ADCINTEG)','', 'NI259' } )
	Aadd(aRoteiro,{ cROT_ADI,'00220','','Codigo Ad.Tempo Servico','','cCodAdt  := Space(3)','', 'NI260' } )
	Aadd(aRoteiro,{ cROT_ADI,'00230','','Valor Ad.Tempo Servico','','nAdtServ := 0.00','', 'NI261' } )
	Aadd(aRoteiro,{ cROT_ADI,'00240','','Calcula Ad.Tempo Servico','','fCalAdt(aCodfol,@nAdtServ,"S",SalMes,,P_ADCINTEG)','', 'NI262' } )
	Aadd(aRoteiro,{ cROT_ADI,'00250','','Valor Periculosidade','','nPeric := 0.00','', 'NI263' } )
	Aadd(aRoteiro,{ cROT_ADI,'00260','','Calcula Periculosidade','','Pericul(aCodfol,@nPeric,SalMes,SalHora,"S",P_ADCINTEG)','', 'NI264' } )
	Aadd(aRoteiro,{ cROT_ADI,'00270','','Codigo Insalubridade','','cCodIns := Space(3)','', 'NI265' } )
	Aadd(aRoteiro,{ cROT_ADI,'00280','','Valor Insalubridade','','nInsal  := 0.00','', 'NI266' } )
	Aadd(aRoteiro,{ cROT_ADI,'00290','','Calcula Insalubridade','','Insalub(aCodfol,Val_SalMin,@nInsal,"S",SalHora,P_ADCINTEG)','', 'NI267' } )
	Aadd(aRoteiro,{ cROT_ADI,'00300','','Valoriza','','FValoriza(aPd,aCodFol,@SalMes,@SalDia,@SalHora,Val_SalMin)', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00310','','Carrega Adiant.','','FCarPDAdiant()', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00320','','Adiant Informado','','FVerAdiant()', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00330','','Calcula Base Inicial','','FBaseIni()', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00340','','Calcula ?','Calcule # "S"' , 'DESPREZAFUNCIONARIO', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00350','','Soma Codigos Adiant','','FSomaAdiant()', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00360','','Reduzir Base de IR','fLocaliaPd(aCodFol[408,1]) > 0', 'Base_Ini := Max( Base_Ini - 100, 0 )','', 'NI377' } )
	Aadd(aRoteiro,{ cROT_ADI,'00370','','Calc. Pensao Alim. ','','FCalcPensao("XXX",aCodFol[9,1],aCodFol[58,1],0,dData_Pgto)','', '' } )	
	Aadd(aRoteiro,{ cROT_ADI,'00380','','Calcula I.R.?','','FM010IncIR()', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00390','','Calcula Liquido',' ','CALCLIQ(VAL_ADTO+nValOutros,IR_CALC)', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00400','','Arredondamento','nValArrAd > 0','CALC_ARRE(@VAL_LIQ,@nValArrAd,@VAL_ARRE)', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00410','','Gera I.R.','IR_CALC > 0.10','FGeraVerba(aCodFol[12,1],IR_CALC,0.00,CSEMANA , ,"V","A")', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00420','','Gera Base IR','BASE_INI # 0','FGeraVerba(AcODFOL[10,1],BASE_INI,0.00,CSEMANA , ,"V","A")', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00430','','Gera Valor Dep.','VAL_DEDDEP # 0','FGeraVerba(aCodfol[59,1],VAL_DEDDEP,Val(SRA->RA_Depir),CSEMANA , ,"V","A")', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00440','','Gera Adiantamento','VAL_ADTO # 0','FGeraVerba(aCodfol[7,1],Val_adto,0.00,CSEMANA, ,"V","A")', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00450','','Gera Arredondamento','VAL_ARRE # 0','FGeraVerba(aCodfol[8,1],VAL_ARRE,0.00,CSEMANA , ,"V","A")', ''  , '' } )
	Aadd(aRoteiro,{ cROT_ADI,'00460','','Grava o Calculo ','','S_GRAVA CALCULO','', 'NI350' } )
Endif

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Rot131			  ³ Equipe Advanced RH	  ³ Data ³    	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Adiciona os Roteiros Padroes 131	        			 	        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Rot131( cROT_131 , c__Roteiro , cPaisLoc , aRoteiro )

If c__Roteiro == cROT_131 .And. cPaisLoc = 'ARG'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ROTEIRO DO CALCULO AGUINALDOS/13§ SALARIO - ARGENTINA        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRoteiro,{ cROT_131,'00010','','VALORIZA CONCEPTOS'   	,'','FValoriza(aPd,aCodFol,@Salmes,@Saldia,@SalHora,Val_SalMin,,,.T.)','', '' } )
	Aadd(aRoteiro,{ cROT_131,'00020','','DEFINE AGUINALDOS'    	,'','cCod1Parc13 := aCodFol[22,1]+","+aCodFol[023,1]+","+aCodFol[108,1]+","+aCodfol[109,1]+","+aCodFol[30,1]+","+aCodFol[128,1]+","+aCodFol[26,1]+","+aCodFol[172,1]+","+aCodFol[173,1]','', '' } )
	Aadd(aRoteiro,{ cROT_131,'00030','','LIMPIA VECTOR'        ,'','aPd := { }','', '' } )
	Aadd(aRoteiro,{ cROT_131,'00040','','PROMEDIO'             ,'','F131Medias()','', '' } )
	Aadd(aRoteiro,{ cROT_131,'00050','','AGUINALDO'            ,'','F132CARSRI(aPd,.T.)','','' } )
	Aadd(aRoteiro,{ cROT_131,'00060','','N§ PROPORCIONALIDAD'  ,'','fAvos13(@nAvos,dDataRef,nAvosFal13,0,"1")','', '' } )
	Aadd(aRoteiro,{ cROT_131,'00070','','AGUINALDOS'           ,'','LOCAGUINAL()'   ,'','' } )
	Aadd(aRoteiro,{ cROT_131,'00080','','APORTE JUBILACION'		,'SRA->RA_CATFUNC <> "A"','LOCJUBILA()','' , '' } ) //Revisado
	Aadd(aRoteiro,{ cROT_131,'00090','','OBRA SOCIAL'          ,'SRA->RA_CATFUNC <> "A"','LOCOBRSOC()','' , '' } ) //Revisado
	Aadd(aRoteiro,{ cROT_131,'00100','','LEY 19.032'           ,'SRA->RA_CATFUNC <> "A"','LOCAPLEY1()','' , '' } )
	Aadd(aRoteiro,{ cROT_131,'00110','','SINDICATO'            ,'SRA->RA_CATFUNC <> "A".And.!Empty(SRA->RA_SINDICA)','LOCSINDIC()','' , '' } ) //Revisado
	Aadd(aRoteiro,{ cROT_131,'00120','','ANSES'                ,'.F.','LOCANSES()','' , '' } ) //Consultar contador
	Aadd(aRoteiro,{ cROT_131,'00130','','CALCULO DE ART'       ,'','LOC_ART()','' , '' } )
	Aadd(aRoteiro,{ cROT_131,'00140','','RETENCIONES GANANCIA' ,'','LOCGANANC()','' , '' } )
	Aadd(aRoteiro,{ cROT_131,'00150','','NETO A COBRAR'        ,'','fLiquido(aCodfol,aCodfol[21,1],0,,.F.,,.F.)','','' } )
ElseIf c__Roteiro == cROT_131 .And. cPaisLoc = 'PAR'
	Aadd(aRoteiro,{ cROT_131,'00010','','VALORIZA CONCEPTOS'   ,'','FValoriza(aPd,aCodFol,@Salmes,@Saldia,@SalHora,Val_SalMin,,,.T.)','','' } )
	Aadd(aRoteiro,{ cROT_131,'00020','','DEFINE AGUINALDOS'    ,'','cCod1Parc13 := aCodFol[22,1]+","+aCodFol[023,1]+","+aCodFol[108,1]+","+aCodfol[109,1]+","+aCodFol[30,1]+","+aCodFol[128,1]+","+aCodFol[26,1]+","+aCodFol[172,1]+","+aCodFol[173,1]','','' } )
	Aadd(aRoteiro,{ cROT_131,'00030','','LIMPIA VECTOR'        ,'','aPd := { }','','' } )
	Aadd(aRoteiro,{ cROT_131,'00040','','AGUINALDO'            ,'','F132CARSRI(aPd)','','' } )
	Aadd(aRoteiro,{ cROT_131,'00050','','PROMEDIO'             ,'','F131Medias()','','' } )
	Aadd(aRoteiro,{ cROT_131,'00060','','N§ PROPORCIONALIDAD'  ,'','fAvos13(@nAvos,dDataRef,nAvosFal13,0,"1")','','' } )
	Aadd(aRoteiro,{ cROT_131,'00070','','LICENCIAS'            ,'SRA->RA_SITFOLH = "A"','DESPREZAFUNCIONARIO','','' } )
	Aadd(aRoteiro,{ cROT_131,'00080','','AGUINALDOS'           ,'','LOCAGUINAL()','','' } )
	Aadd(aRoteiro,{ cROT_131,'00090','','NETO A COBRAR'        ,'','fLiquido(aCodfol,aCodfol[21,1],0,,.F.,,.F.)','','' } )
ElseIf c__Roteiro == cROT_131 .And. cPaisLoc = 'URU'
	Aadd(aRoteiro,{ cROT_131,'00010','','VALORIZA CONCEPTOS'   ,'','FValoriza(aPd,aCodFol,@Salmes,@Saldia,@SalHora,Val_SalMin,,,.T.)','','' } )
	Aadd(aRoteiro,{ cROT_131,'00020','','DEFINE AGUINALDOS'    ,'','cCod1Parc13 := aCodFol[22,1]+","+aCodFol[023,1]+","+aCodFol[108,1]+","+aCodfol[109,1]+","+aCodFol[30,1]+","+aCodFol[128,1]+","+aCodFol[26,1]+","+aCodFol[172,1]+","+aCodFol[173,1]','','' } )
	Aadd(aRoteiro,{ cROT_131,'00030','','LIMPIA VECTOR'        ,'','aPd := { }','','' } )
	Aadd(aRoteiro,{ cROT_131,'00040','','AGUINALDO'            ,'','F132CARSRI(aPd,.T.)','','' } )
	Aadd(aRoteiro,{ cROT_131,'00050','','CALCULA PROMEDIOS  '	,'','F131Medias()','', '' } )
	Aadd(aRoteiro,{ cROT_131,'00060','','N§ PROPORCIONALIDAD'  ,'','fAvos13(@nAvos,dDataRef,nAvosFal13,0,"1")','','' } )
	Aadd(aRoteiro,{ cROT_131,'00070','','AGUINALDOS'           ,'','LOCAGUINAL()','','' } )
	Aadd(aRoteiro,{ cROT_131,'00080','','APORTE JUBILACION'    ,'','LOCJUBILA()','','' } )
	Aadd(aRoteiro,{ cROT_131,'00090','','CALCULO FONASA'        ,'','LOCFONASA()','' , 'NI500' } )
	Aadd(aRoteiro,{ cROT_131,'00100','','CJPPU'  		       ,'','LocCJPPU()','','NI501' } )
	Aadd(aRoteiro,{ cROT_131,'00110','','Fondo de Solidariedad','' ,'LocFonSol()','','NI502' } )
	Aadd(aRoteiro,{ cROT_131,'00120','','Calc. Pensao Alim. '	,'','FCalcPensao("XXX",aCodFol[71,1],aCodFol[172,1],0,dData_Pgto)','', '' } )
    Aadd(aRoteiro,{ cROT_131,'00130','','RETENCIONES GANANCIA' ,'','If(MesAno(dDataBase) < "200707",LOCGANANC(),LOCIRPF())','' , '' } )
	Aadd(aRoteiro,{ cROT_131,'00140','','NETO A COBRAR'        ,'','fLiquido(aCodfol,aCodfol[21,1],If(lArredonda,nValArred,0),aCodfol[26,1],.F.,,.F.,,,dData_Pgto)','','' } )
ElseIf c__Roteiro == cROT_131 .And. cPaisLoc = 'DOM'
	Aadd(aRoteiro,{ cROT_131,'00010','','VALORIZA CONCEPTOS'   ,''								,'FValoriza(aPd,aCodFol,@Salmes,@Saldia,@SalHora,Val_SalMin,,,.T.)','','' } )
	Aadd(aRoteiro,{ cROT_131,'00020','','DEFINE AGUINALDOS'    ,''								,'cCod1Parc13 := aCodFol[22,1]+","+aCodFol[023,1]+","+aCodFol[108,1]+","+aCodfol[109,1]+","+aCodFol[30,1]+","+aCodFol[128,1]+","+aCodFol[26,1]+","+aCodFol[172,1]+","+aCodFol[173,1]','','' } )
	Aadd(aRoteiro,{ cROT_131,'00030','','LIMPIA VECTOR'        ,''								,'aPd := { }','','' } )
	Aadd(aRoteiro,{ cROT_131,'00040','','AGUINALDOS'           ,''								,'LOCAGUINAL()','','' } )
	Aadd(aRoteiro,{ cROT_131,'00050','','SEGURO SOCIAL IDSS'   ,'SRA->RA_IDSS = "1"'		,'LOCSegSoc()','' , '' } )
	Aadd(aRoteiro,{ cROT_131,'00060','','RETENCIONES GANANCIA'	,''                      ,'LOCGANANC()','' , '' } )
	Aadd(aRoteiro,{ cROT_131,'00070','','NETO A COBRAR'        ,''								,'fLiquido(aCodfol,aCodfol[21,1],0,,.F.,,.F.)','','' } )
ElseIf c__Roteiro == cROT_131 .And. cPaisLoc = 'CHI'
	Aadd(aRoteiro,{ cROT_131,'00010','','Carga Tablas de Calculo'	,'','S_CARGA TABELAS','' , 'NI347' } )
	Aadd(aRoteiro,{ cROT_131,'00020','','Carga Conceptos del Movto. para Calculo'	,'','S_CARREGA MOVIMEN','' , 'NI341' } )
	Aadd(aRoteiro,{ cROT_131,'00030','','Montaje de Sueldo Mensual','','S_SALARIO MENSAL','' , '' } )
	Aadd(aRoteiro,{ cROT_131,'00040','','Montaje de Sueldo Hora'   ,'','S_SALARIO HORA','' , 'NI310' } )
	Aadd(aRoteiro,{ cROT_131,'00050','','Montaje de Sueldo Dia'    ,'','S_SALARIO DIA','' , 'NI311' } )
	Aadd(aRoteiro,{ cROT_131,'00060','','Montaje de Sueldo Base'   ,'','S_SALARIO BASE','' , 'NI312' } )
	Aadd(aRoteiro,{ cROT_131,'00070','','Valoriza Verbas    '  ,'','FValoriza(aPd,aCodFol,@Salmes,@Saldia,@SalHora,Val_SalMin,,,.T.)','', '' } )
	Aadd(aRoteiro,{ cROT_131,'00080','','Define Codigos 13§ '  ,'','cCod1Parc13 := aCodFol[22,1]+","+aCodFol[023,1]+","+aCodFol[108,1]+","+aCodfol[109,1]+","+aCodFol[30,1]+","+aCodFol[128,1]+","+aCodFol[26,1]+","+aCodFol[172,1]+","+aCodFol[173,1]','', '' } )
	Aadd(aRoteiro,{ cROT_131,'00090','','Limpa Vetor Verbas '  ,'','aPd := { }','', '' } )
	Aadd(aRoteiro,{ cROT_131,'00100','','AGUINALDO'            ,'','F131CARSRC(aPd)','','' } )
	Aadd(aRoteiro,{ cROT_131,'00110','','Calcula Medias     '  ,'','F131Medias()','', '' } )
	Aadd(aRoteiro,{ cROT_131,'00120','','Se ja pagou Adiant.'  ,'nAntec13 > 0 .AND. ! lCompl1Parc','DESPREZAFUNCIONARIO','', '' } )
	Aadd(aRoteiro,{ cROT_131,'00130','','N§ PROPORCIONALIDAD'  ,'','fAvos13(@nAvos,dDataRef,nAvosFal13,0,"1")','', '' } )
	Aadd(aRoteiro,{ cROT_131,'00140','','Consiste Afastamentos','SRA->RA_SITFOLH = "A" .And. ! SRA->RA_AFASFGT$ "8*O*P*Q*X"','DESPREZAFUNCIONARIO','','NI205 04' } )
	Aadd(aRoteiro,{ cROT_131,'00150','','AGUINALDOS'           ,'','LOCAGUINAL()'   ,'','' } )
	Aadd(aRoteiro,{ cROT_131,'00160','','Calc. Pensao Alim. ','','FCalcPensao("XXX","XXX",aCodFol[172,1],0,dData_Pgto)','', '' } )
	Aadd(aRoteiro,{ cROT_131,'00170','','Subtrai Pensao     ','','fSubtPensao(@n13Sal)','', '' } )
	Aadd(aRoteiro,{ cROT_131,'00180','','Zerar Valor do Liquido','','n13Liq := 0','', '' } )
	Aadd(aRoteiro,{ cROT_131,'00190','','Gera Verba Desconto','lGeraDesc = .T.','FGeraVerba(aCodfol[23,1],n13Sal,,Semana)','', '' } )
Endif

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Rot132			  ³ Equipe Advanced RH	  ³ Data ³    	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Adiciona os Roteiros Padroes 132	    				 	        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Rot132( cROT_132 , c__Roteiro , cPaisLoc , aRoteiro )

If c__Roteiro == cROT_132 .And. cPaisLoc = 'ARG'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ROTEIRO DO CALCULO AGUINALDOS/13§ SALARIO - ARGENTINA        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRoteiro,{ cROT_132,'00010','','VALORIZA CONCEPTOS'   ,'','FValoriza(aPd,aCodFol,@Salmes,@Saldia,@SalHora,Val_SalMin,,,.T.)','', '' } )
	Aadd(aRoteiro,{ cROT_132,'00020','','DEFINE AGUINALDOS'    ,'','cCod1Parc13 := aCodFol[22,1]+","+aCodFol[023,1]+","+aCodFol[108,1]+","+aCodfol[109,1]+","+aCodFol[30,1]+","+aCodFol[128,1]+","+aCodFol[26,1]+","+aCodFol[172,1]+","+aCodFol[173,1]','', '' } )
	Aadd(aRoteiro,{ cROT_132,'00030','','LIMPIA VECTOR'        ,'','aPd := { }','', '' } )
	Aadd(aRoteiro,{ cROT_132,'00040','','CARGA AGUINALDO  '    ,'','F132CARSRI(aPd)','', '' } )
	Aadd(aRoteiro,{ cROT_132,'00050','','PROMEDIO'             ,'','F132Medias()','', '' } )
	Aadd(aRoteiro,{ cROT_132,'00060','','N§ PROPORCIONALIDAD'  ,'','fAvos13(@nAvos,dDataRef,nAvosFal13,0,"1")','', '' } )
	Aadd(aRoteiro,{ cROT_132,'00070','','LICENCIAS   '         ,'SRA->RA_SITFOLH = "A"','DESPREZAFUNCIONARIO','','' } )
	Aadd(aRoteiro,{ cROT_132,'00080','','AGUINALDOS'           ,'','LOCAGUINAL()'   ,'','' } )
	Aadd(aRoteiro,{ cROT_132,'00090','','APORTE JUBILACION'	 	,'SRA->RA_CATFUNC <> "A"','LOCJUBILA()','' , '' } ) //Revisado
	Aadd(aRoteiro,{ cROT_132,'00100','','OBRA SOCIAL'          ,'SRA->RA_CATFUNC <> "A"','LOCOBRSOC()','' , '' } ) //Revisado
	Aadd(aRoteiro,{ cROT_132,'00110','','LEY 19.032'           ,'SRA->RA_CATFUNC <> "A"','LOCAPLEY1()','' , '' } )
	Aadd(aRoteiro,{ cROT_132,'00120','','SINDICATO'            ,'SRA->RA_CATFUNC <> "A".And.!Empty(SRA->RA_SINDICA)','LOCSINDIC()','' , '' } ) //Revisado
	Aadd(aRoteiro,{ cROT_132,'00130','','ANSES'                ,'SRA->RA_CATFUNC <> "A" .And. .F.','LOCANSES()','' , '' } ) //Consultar contador
	Aadd(aRoteiro,{ cROT_132,'00140','','CALCULO DE ART'       ,'','LOC_ART()','' , '' } )
	Aadd(aRoteiro,{ cROT_132,'00150','','RETENCIONES GANANCIA' ,'','LOCGANANC()','' , '' } )
	Aadd(aRoteiro,{ cROT_132,'00160','','NETO A COBRAR'        ,'','fLiquido(aCodfol,aCodfol[21,1],0,,.F.,,.F.)','','' } )
ElseIf c__Roteiro == cROT_132 .And. cPaisLoc = 'PAR'
	Aadd(aRoteiro,{ cROT_132,'00010','','VALORIZA CONCEPTOS'   ,'','FValoriza(aPd,aCodFol,@Salmes,@Saldia,@SalHora,Val_SalMin,,,.T.)','','' } )
	Aadd(aRoteiro,{ cROT_132,'00020','','DEFINE AGUINALDOS'    ,'','cCod1Parc13 := aCodFol[22,1]+","+aCodFol[023,1]+","+aCodFol[108,1]+","+aCodfol[109,1]+","+aCodFol[30,1]+","+aCodFol[128,1]+","+aCodFol[26,1]+","+aCodFol[172,1]+","+aCodFol[173,1]','','' } )
	Aadd(aRoteiro,{ cROT_132,'00030','','LIMPIA VECTOR'        ,'','aPd := { }','','' } )
	Aadd(aRoteiro,{ cROT_132,'00040','','LICENCIAS'            ,'SRA->RA_SITFOLH = "A"','DESPREZAFUNCIONARIO','','' } )
	Aadd(aRoteiro,{ cROT_132,'00050','','AGUINALDOS'           ,'','LOCAGUINAL()','','' } )
	Aadd(aRoteiro,{ cROT_132,'00060','','NETO A COBRAR'        ,'','fLiquido(aCodfol,aCodfol[21,1],0,,.F.,,.F.)','','' } )
ElseIf c__Roteiro == cROT_132 .And. cPaisLoc = 'URU'
	Aadd(aRoteiro,{ cROT_132,'00010','','VALORIZA CONCEPTOS'   ,'','FValoriza(aPd,aCodFol,@Salmes,@Saldia,@SalHora,Val_SalMin,,,.T.)','','' } )
	Aadd(aRoteiro,{ cROT_132,'00020','','DEFINE AGUINALDOS'    ,'','cCod1Parc13 := aCodFol[22,1]+","+aCodFol[023,1]+","+aCodFol[108,1]+","+aCodfol[109,1]+","+aCodFol[30,1]+","+aCodFol[128,1]+","+aCodFol[26,1]+","+aCodFol[172,1]+","+aCodFol[173,1]','','' } )
	Aadd(aRoteiro,{ cROT_132,'00030','','LIMPIA VECTOR'        ,'','aPd := { }','','' } )
	Aadd(aRoteiro,{ cROT_132,'00040','','N§ PROPORCIONALIDAD'  ,'','fAvos13(@nAvos,dDataRef,nAvosFal13,0,"1")','','' } )
	Aadd(aRoteiro,{ cROT_132,'00050','','Cargar aguinaldo  '   ,'','F132CARSRI(aPd)','', '' } )
	Aadd(aRoteiro,{ cROT_132,'00060','','AGUINALDOS'           ,'','LOCAGUINAL()','','' } )
	Aadd(aRoteiro,{ cROT_132,'00070','','APORTE JUBILACION'    ,'','LOCJUBILA()','','' } )
	Aadd(aRoteiro,{ cROT_132,'00080','','CALCULO FONASA'        ,'','LOCFONASA()','' , 'NI503' } )
	Aadd(aRoteiro,{ cROT_132,'00090','','CJPPU'  		       ,'','LocCJPPU()','','NI504' } )
	Aadd(aRoteiro,{ cROT_132,'00100','','Fondo de Solidariedad','' ,'LocFonSol()','','NI505' } )
	Aadd(aRoteiro,{ cROT_132,'00110','','Calc. Pensao Alim. ','','FCalcPensao("XXX",aCodFol[71,1],aCodFol[128,1],0,dData_Pgto)','', '' } )
   	Aadd(aRoteiro,{ cROT_132,'00120','','RETENCIONES GANANCIA' ,'','If(MesAno(dDataBase) < "200707",LOCGANANC(),LOCIRPF())','' , '' } )
	Aadd(aRoteiro,{ cROT_132,'00130','','NETO A COBRAR'        ,'','fLiquido(aCodfol,aCodfol[21,1],nValArred,aCodfol[26,1],.F.,,.F.)','','' } )
ElseIf c__Roteiro == cROT_132 .And. cPaisLoc = 'DOM'
	Aadd(aRoteiro,{ cROT_132,'00010','','SUELDO'               ,''                      ,'FSalario(@Salario,@SalHora,@SalDia,@SalMes)','','' } )
	Aadd(aRoteiro,{ cROT_132,'00020','','VALORIZA CONCEPTOS'   ,''								,'FValoriza(aPd,aCodFol,@Salmes,@Saldia,@SalHora,Val_SalMin,,,.T.)','','' } )
	Aadd(aRoteiro,{ cROT_132,'00030','','DEFINE AGUINALDOS'    ,''								,'cCod1Parc13 := aCodFol[22,1]+","+aCodFol[023,1]+","+aCodFol[108,1]+","+aCodfol[109,1]+","+aCodFol[30,1]+","+aCodFol[128,1]+","+aCodFol[26,1]+","+aCodFol[172,1]+","+aCodFol[173,1]','','' } )
	Aadd(aRoteiro,{ cROT_132,'00040','','LIMPIA VECTOR'        ,''								,'aPd := { }','','' } )
	Aadd(aRoteiro,{ cROT_132,'00050','','CALCULAS PROMEDIOS '	,'','F132Medias()','', '' } )
	Aadd(aRoteiro,{ cROT_132,'00060','','AGUINALDOS'           ,''								,'LOCAGUINAL()','','' } )
	Aadd(aRoteiro,{ cROT_132,'00070','','SEGURO SOCIAL IDSS'   ,'SRA->RA_IDSS = "1"'		,'LOCSegSoc()','' , '' } )
	Aadd(aRoteiro,{ cROT_132,'00080','','RETENCIONES GANANCIA'	,''                      ,'LOCGANANC()','' , '' } )
	Aadd(aRoteiro,{ cROT_132,'00090','','NETO A COBRAR'        ,''								,'fLiquido(aCodfol,aCodfol[21,1],0,,.F.,,.F.)','','' } )
ElseIf c__Roteiro == cROT_132 .And. cPaisLoc = 'CHI'
	Aadd(aRoteiro,{ cROT_132,'00010','','Carga Tablas de Calculo'	,'','S_CARGA TABELAS','' , 'NI347' } )
	Aadd(aRoteiro,{ cROT_132,'00020','','Carga Tablas de Calculo'	,'','S_CARGA TABLOC','' , 'NI347' } )
	Aadd(aRoteiro,{ cROT_132,'00030','','Carga Conceptos del Movto. para Calculo'	,'','S_CARREGA MOVIMEN','' , 'NI341' } )
	Aadd(aRoteiro,{ cROT_132,'00040','','Montaje de Sueldo Mensual','','S_SALARIO MENSAL','' , '' } )
	Aadd(aRoteiro,{ cROT_132,'00050','','Montaje de Sueldo Hora'   ,'','S_SALARIO HORA','' , 'NI310' } )
	Aadd(aRoteiro,{ cROT_132,'00060','','Montaje de Sueldo Dia'    ,'','S_SALARIO DIA','' , 'NI311' } )
	Aadd(aRoteiro,{ cROT_132,'00070','','Montaje de Sueldo Base'   ,'','S_SALARIO BASE','' , 'NI312' } )
	Aadd(aRoteiro,{ cROT_132,'00080','','DIAS TRABAJADOS '    	,'','FDiasTrab(@DiasTrab,cDiasMes,@lAdmissao)'   ,'' , '' } )
	Aadd(aRoteiro,{ cROT_132,'00090','','DIAS DE LICENCIA   ' 	,'','FDiasAfast(@nDiasAfas,@DiasTrab)'           ,'' , '' } )
	Aadd(aRoteiro,{ cROT_132,'00100','','Valoriza Verbas    '	,'','FValoriza(aPd,aCodFol,@Salmes,@Saldia,@SalHora,Val_SalMin,,,.T.)','', '' } )
	Aadd(aRoteiro,{ cROT_132,'00110','','Limpa Vetor Verbas '	,'','aPd := { }','', '' } )
	Aadd(aRoteiro,{ cROT_132,'00120','','Carrega 13§ 2¦ Parc'	,'','F132CARSRI(aPd)','', '' } )
	Aadd(aRoteiro,{ cROT_132,'00130','','Calcula Medias     '	,'','F132Medias()','', '' } )
	Aadd(aRoteiro,{ cROT_132,'00140','','N§ PROPORCIONALIDAD'  ,'','fAvos13(@nAvos,dDataRef,nAvosFal13,0,"1")','', '' } )
	Aadd(aRoteiro,{ cROT_132,'00150','','AGUINALDOS'           ,'','LOCAGUINAL()'   ,'','' } )
	Aadd(aRoteiro,{ cROT_132,'00160','','CALCULO SALUD'       	,'','LOCSalud()'    , '' , '' } )
	Aadd(aRoteiro,{ cROT_132,'00170','','SEGURO SOCIAL AFP'   	,'','LOCSegSoc()'   , '' , '' } )
	Aadd(aRoteiro,{ cROT_132,'00180','','Calc. Pensao Alim. ','','FCalcPensao("XXX",aCodFol[71,1],aCodFol[128,1],0,dData_Pgto)','', '' } )	
	Aadd(aRoteiro,{ cROT_132,'00190','','NETO A COBRAR'        ,'','fLiquido(aCodfol,aCodfol[21,1],0,,.F.,,.F.)','','' } )
Endif

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ RotRes			  ³ Equipe Advanced RH	  ³ Data ³    	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Adiciona os Roteiros Padroes RES	    				 	        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function RotRes( cROT_RES , c__Roteiro , cPaisLoc , aRoteiro )

If c__Roteiro == cROT_RES .And. cPaisLoc = 'ARG'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ROTEIRO DO CALCULO LIQUIDACION/RESCISAO - ARGENTINA          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRoteiro,{ cROT_RES,'00010','','CALCULO PROMEDIO'    ,'','GPEXMED(SRF->RF_DATABAS, ,dDataDem,dDataDem,dDataDem,SalHora,Val_Salmin,aCodfol,lMesAtu,.T.)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00020','','VALORIZA CONCEPTOS'  ,'','FValoriza(aPd,aCodfol,,Saldia,Salhora)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00030','','DIAS TRABAJADOS'		  ,'','DiasTrabRes(@DiasTrab)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00040','','BUSCAR PROMEDIO'     ,'','BuscaMed(@nMedFerv,@nMedFerp,@nMed13o,@nMedAviso,@nDesc13)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00050','','MEDIA PROMEDIO'      ,'','nProMed  := 6' ,'','' } )
	Aadd(aRoteiro,{ cROT_RES,'00060','','PORCENTUAL PROMEDIO' ,'','nPercPro := 25','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00070','','SALDO DE SALARIO'		,'','FSaldoSal(DiasTrab)','',''} )
	Aadd(aRoteiro,{ cROT_RES,'00080','','VACACIONES NO GOZADAS','','fFerias(aPd,aCodfol,nMedFerv,nMedFerp,nDferInd)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00090','','LIQUIDACION'         ,'','LOCLiquid()'   ,'','' } )
	Aadd(aRoteiro,{ cROT_RES,'00100','','VAL. FUTUROS'        ,'cCompl # "S" .or. ( cCompl == "S" .and. MesAno( GetMemVar("RG_DATADEM") ) == MesAno( GetMemVar("RG_DTGERAR") ) ) ','fGerValFut("R")','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00110','','ABATER LIQUIDACION'  ,'( cCompl == "S" .and. MesAno( GetMemVar("RG_DATADEM") ) < MesAno( GetMemVar("RG_DTGERAR") ) )'    ,'fAbatPago()','' , '' } )
	Aadd(aRoteiro,{ cROT_RES,'00120','','APORTE JUBILACION'   ,'','LOCJUBILA()','' , '' } )
	Aadd(aRoteiro,{ cROT_RES,'00130','','OBRA SOCIAL'         ,'','LOCOBRSOC()','' , '' } )
	Aadd(aRoteiro,{ cROT_RES,'00140','','LEY 19.032'          ,'','LOCAPLEY1()','' , '' } )
	Aadd(aRoteiro,{ cROT_RES,'00150','','SINDICATO'           ,'','LOCSINDIC()','' , '' } )
	Aadd(aRoteiro,{ cROT_RES,'00160','','IMPUESTO GANACIAS'   ,'','LOCGANANC()','' , '' } )
	Aadd(aRoteiro,{ cROT_RES,'00170','','SEGURO VIDA'         ,'cCompl # "S" .or. ( cCompl == "S" .and. MesAno( M->RG_DATADEM ) == MesAno( M->RG_DTGERAR ) )','CalSeguro(aCodFol,@nSeguro,@nSegEmp,@Seguro_B,aSeguro)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00180','','AST. MEDICA'         ,'cCompl # "S" .or. ( cCompl == "S" .and. MesAno( GetMemVar("RG_DATADEM") ) == MesAno( GetMemVar("RG_DTGERAR") ) ) .And. aIncRes[11] = "S"','AssiMed(aCodfol)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00190','','CREA VARIABLE'       ,'','nLiq := 0.00','',''} )
	Aadd(aRoteiro,{ cROT_RES,'00200','','INSUF. DE SALDO'     ,'nLiq < 0.00','fGeraVerba(aCodfol[045,1],nLiq * (-1), , , , ,"R")','','' })
	Aadd(aRoteiro,{ cROT_RES,'00210','','SUMA PROVENTOS'      ,'','Aeval( aPd ,{ |X|  SomaInc(X,1,@nValProv, , , , , ,.F.,aCodFol) })','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00220','','SUMA DESCUENTOS'     ,'','Aeval( aPd ,{ |X|  SomaInc(X,2,@nValDesc, , , , , ,.F.,aCodFol) })','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00230','','NETO A COBRAR'       ,'','fGeraVerba(aCodfol[126,1],nValProv - nValDesc, , , , ,"R")','','' } )
ElseIf c__Roteiro == cROT_RES .And. cPaisLoc = 'CHI'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ROTEIRO DO CALCULO LIQUIDACION/RESCISAO - CHILE              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRoteiro,{ cROT_RES,'00010','','CALCULO PROMEDIO'    ,'','GPEXMED(SRF->RF_DATABAS, ,dDataDem,dDataDem,dDataDem,SalHora,Val_Salmin,aCodfol,lMesAtu,.T.)','','NI383' } )
	Aadd(aRoteiro,{ cROT_RES,'00020','','VALORIZA CONCEPTOS'  ,'','FValoriza(aPd,aCodfol,,Saldia,Salhora)','','NI384' } )
	Aadd(aRoteiro,{ cROT_RES,'00030','','DIAS TRABAJADOS '    ,'SRA->RA_CATFUNC$ "M*C" .And. Day(dDatadem) >= If(Month(dDatadem)==2, If((Mod(Year(dDatadem),4)==0), 29, 28), 30) ','DiasTrab := 30 ','DiasTrab := Day(dDataDem)','NI385' } )
	Aadd(aRoteiro,{ cROT_RES,'00040','','CALCULO DE DIAS  ','','FDiasAfast(@nDiasAfas,@DiasTrab,dDataDem,,cPgSalMat)','','NI386' } )
	Aadd(aRoteiro,{ cROT_RES,'00050','','BUSCAR PROMEDIO'     ,'','BuscaMed(@nMedFerv,@nMedFerp,@nMed13o,@nMedAviso,@nDesc13)','','NI387' } )
	Aadd(aRoteiro,{ cROT_RES,'00060','','SALDO DE SALARIO'    ,'','FSaldoSal(DiasTrab)','','NI388'} )
	Aadd(aRoteiro,{ cROT_RES,'00070','','PROMEDIO BASE IR'    ,'','nProMed  := 24' ,'','NI389' } )
	Aadd(aRoteiro,{ cROT_RES,'00080','','LIQUIDACION'         ,'','LOCLiquid()'   ,'','NI390' } )
	Aadd(aRoteiro,{ cROT_RES,'00090','','CARGAS FAMILIARES'   ,'','LOCSALFAM()'   , '' , 'NI391' } )
	Aadd(aRoteiro,{ cROT_RES,'00100','','GRATIFICACION'       ,'','LOCGratif()'   , '' , 'NI392' } )
	Aadd(aRoteiro,{ cROT_RES,'00110','','VAL. FUTUROS'        ,'cCompl # "S" .or. ( cCompl == "S" .and. MesAno( GetMemVar("RG_DATADEM") ) == MesAno( GetMemVar("RG_DTGERAR") ) ) ','fGerValFut("R")','','NI393' } )
	Aadd(aRoteiro,{ cRot_RES,'00130','','ISAPRE' 			   ,'','LOCSALUD(dDataDem)','' , 'NI335' } )
	Aadd(aRoteiro,{ cRot_RES,'00140','','A.F.P.' 		   	  ,'','LOCSEGSOC()','', 'NI336' } )
	Aadd(aRoteiro,{ cROT_RES,'00150','','Calculo Pensao Rescisao','','fCalcPensao(aCodfol[64,1],aCodFol[66,1],aCodFol[56,1],0,M->RG_DATAHOM," ")','','NI394'} )		
	Aadd(aRoteiro,{ cROT_RES,'00160','','Calculo Pensao Ferias','','fCalcPensao(aCodfol[65,1],aCodFol[67,1],aCodFol[170,1],0,M->RG_DATAHOM,"FER")','','NI395'} )	
	Aadd(aRoteiro,{ cROT_RES,'00170','','Calculo Pensao 13o.','','fCalcPensao(aCodfol[70,1],aCodFol[71,1],aCodFol[128,1],0,M->RG_DATAHOM,"13o")','','NI396' } )	
	Aadd(aRoteiro,{ cROT_RES,'00180','','IMPUESTO A LA RENTA' ,'','LOCGANANC()','' , 'NI397' } )
	Aadd(aRoteiro,{ cROT_RES,'00190','','APORTE PATRONAL'     ,'','LOCAportePa()' , '' , 'NI382' } )
	Aadd(aRoteiro,{ cROT_RES,'00200','','SEGURO VIDA'         ,'cCompl # "S" .or. ( cCompl == "S" .and. MesAno( M->RG_DATADEM ) == MesAno( M->RG_DTGERAR ) )','CalSeguro(aCodFol,@nSeguro,@nSegEmp,@Seguro_B,aSeguro)','','NI398' } )
	Aadd(aRoteiro,{ cROT_RES,'00220','','CREA VARIABLE'       ,'','nLiq := 0.00','','NI399'} )
	Aadd(aRoteiro,{ cROT_RES,'00230','','Graba Neto Liquidacion  ','','fLiquido(aCodfol,aCodFol[126,1],0,"",.T.,aCodFol[045,1],.T.,.T.,.T.)','','NI400' })//	Aadd(aRoteiro,{ cROT_RES,'00210','','INSUF. DE SALDO'     ,'nLiq < 0.00','fGeraVerba(aCodfol[045,1],nLiq * (-1), , , , ,"R")','','' }) -> Substituido pelo grava liquido
	Aadd(aRoteiro,{ cROT_RES,'00240','','SUMA PROVENTOS'      ,'','Aeval( aPd ,{ |X|  SomaInc(X,1,@nValProv, , , , , , ,aCodFol) })','','NI401' } )
	Aadd(aRoteiro,{ cROT_RES,'00250','','SUMA DESCUENTOS'     ,'','Aeval( aPd ,{ |X|  SomaInc(X,2,@nValDesc, , , , , , ,aCodFol) })','','NI402' } )
	Aadd(aRoteiro,{ cROT_RES,'00260','','NETO A COBRAR'       ,'','nLiq := 0.00','','NI403' } )//	Aadd(aRoteiro,{ cROT_RES,'00240','','NETO A COBRAR'       ,'','fGeraVerba(aCodfol[126,1],nValProv - nValDesc, , , , ,"R")','','' } )-> Substituido a validacao para que nao faca nada
	Aadd(aRoteiro,{ cROT_RES,'00270','','TOTALIZA CONCEPTOS'  ,'','LOCTOTCON()' , '' , 'NI404' } )
ElseIf c__Roteiro == cROT_RES .And. cPaisLoc = 'PAR'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ROTEIRO DO CALCULO LIQUIDACION/RESCISAO - PARAGUAI           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRoteiro,{ cROT_RES,'00010','','CALCULO PROMEDIO'    ,'','GPEXMED(SRF->RF_DATABAS, ,dDataDem,dDataDem,dDataDem,SalHora,Val_Salmin,aCodfol,lMesAtu,.T.)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00020','','VALORIZA CONCEPTOS'  ,'','FValoriza(aPd,aCodfol,,Saldia,Salhora)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00030','','CALCULO DE LOS DIAS ','SRA->RA_CATFUNC$ "M*C" .And. (Day(dDatadem) > 30 .Or. (Month(dDataDem)=2 .And. Day(dDataDem)=28)) ','DiasTrab := 30 ','DiasTrab := Day(dDataDem)','' } )
	Aadd(aRoteiro,{ cROT_RES,'00040','','DIAS DE LICENCIA'    ,'','FDiasAfast(@nDiasAfas,@DiasTrab)'           ,'','' } )
	Aadd(aRoteiro,{ cROT_RES,'00050','','CALCULO LICENCIAS'   ,'','FAfastados(aCodFol)','' , '' } )
	Aadd(aRoteiro,{ cROT_RES,'00060','','SALDO DE SALARIO'	  ,'','FSaldoSal(DiasTrab)','',''} )
	Aadd(aRoteiro,{ cROT_RES,'00070','','LIQUIDACION'         ,'','LOCLIQUID()'   ,'','' } )
	Aadd(aRoteiro,{ cROT_RES,'00080','','VAL. FUTUROS'        ,'cCompl # "S" .or. ( cCompl == "S" .and. MesAno( GetMemVar("RG_DATADEM") ) == MesAno( GetMemVar("RG_DTGERAR") ) )','fGerValFut("R")','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00090','','ABATER LIQUIDACION'  ,'( cCompl == "S" .and. MesAno( GetMemVar("RG_DATADEM") ) < MesAno( GetMemVar("RG_DTGERAR") ) )','fAbatPago()','' , '' } )
	Aadd(aRoteiro,{ cROT_RES,'00100','','APORTE JUBILACION'   ,'','LOCJUBILA()','' , '' } )
	Aadd(aRoteiro,{ cROT_RES,'00110','','SEGURO VIDA'         ,'cCompl # "S" .or. ( cCompl == "S" .and. MesAno( M->RG_DATADEM ) == MesAno( M->RG_DTGERAR ) )','CalSeguro(aCodFol,@nSeguro,@nSegEmp,@Seguro_B,aSeguro)','','' } )	
	Aadd(aRoteiro,{ cROT_RES,'00120','','CREA VARIABLE'       ,'','nLiq := 0.00','',''} )
	Aadd(aRoteiro,{ cROT_RES,'00130','','INSUF. DE SALDO'     ,'nLiq < 0.00','fGeraVerba(aCodfol[045,1],nLiq * (-1), , , , ,"R")','','' })
	Aadd(aRoteiro,{ cROT_RES,'00140','','Graba Neto Liquidacion  ','','fLiquido(aCodfol,aCodFol[126,1],0,"",.T.,aCodFol[045,1],.T.,.T.,.T.)','','' })
	Aadd(aRoteiro,{ cROT_RES,'00150','','Suma de Haberes  ','','Aeval( aPd ,{ |X|  SomaInc(X,1,@nValProv, , , , , , ,aCodFol) })','',''} )
	Aadd(aRoteiro,{ cROT_RES,'00160','','Suma de Descontos','','Aeval( aPd ,{ |X|  SomaInc(X,2,@nValDesc, , , , , , ,aCodFol) })','','' } )

ElseIf c__Roteiro == cROT_RES .And. cPaisLoc = 'URU'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ROTEIRO DO CALCULO LIQUIDACION/RESCISAO - URUGUAI³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRoteiro,{ cROT_RES,'00010','','Carga Tablas de Calculo'		,''	,'S_CARGA TABLOC','' , 'NI347' } )	
	Aadd(aRoteiro,{ cROT_RES,'00020','','GUARDAR RESCISION '  ,'','LOCSIMVAC(1)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00030','','SIM. SUELDO'         ,'','FSalario(@Salario,@SalHora,@SalDia,@SalMes)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00040','','SIM. DIAS TRABAJADOS','','FDiasTrab(@DiasTrab,cDiasMes,@lAdmissao)'   ,'','' } )
	Aadd(aRoteiro,{ cROT_RES,'00050','','SIM. CALCULO D.S.R'  ,'','FCalcDSR(@nDsr,lAdmissao,@nHorasTrab,@nHorasDsr)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00060','','SIM. GENERA SUELDO'  ,'','FGravaSal(aCodFol,DiasTRab,nHorasTrab,nDsr,nHorasDsr)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00070','','SIM. VAL.CONCEPTOS'  ,'','FValoriza(@aPd,aCodFol,@SalMes,@SalDia,@SalHora,Val_SalMin,DiasTrab)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00080','','SIM. SUST.DE CARNE'  ,'','LOCSUSCAR(1)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00090','','SIM. PRIMA ANTIG'    ,'','LOCATSER()','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00100','','SIM. APORTE JUB.'    ,'','LOCJUBILA()','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00110','','SIM. CALCULO FONASA'  ,'','LOCFONASA()','' , 'NI506' } )
    Aadd(aRoteiro,{ cROT_RES,'00120','','SIM. RET. I.R.P.'    ,'','If(MesAno(dDataBase) < "200707",LOCGANANC(),LOCIRPF())','' , '' } )
	Aadd(aRoteiro,{ cROT_RES,'00130','','SIM. VAL.CONCEPTOS'  ,'','FValoriza(@aPd,aCodFol,@SalMes,@SalDia,@SalHora,Val_SalMin,DiasTrab)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00140','','RESTAURA RESCISION'  ,'','LOCSIMVAC(2)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00150','','CALCULO PROMEDIO'    ,'','GPEXMED(SRF->RF_DATABAS, ,dDataDem,dDataDem,dDataDem,SalHora,Val_Salmin,aCodfol,lMesAtu,.T.)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00160','','BUSCAR PROMEDIO'     ,'','BuscaMed(@nMedFerv,@nMedFerp,@nMed13o,@nMedAviso,@nDesc13)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00170','','VALORIZA CONCEPTOS'  ,'','FValoriza(aPd,aCodfol,,Saldia,Salhora)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00180','','FERIADO PAGO'        ,'SRA->RA_TIPOPGT="S" .And. Ascan(aPd,{|X|X[1]=aCodfol[311,1] .And. X[3]=cSemana .And. X[9] # "D"})=0 .And. nPosSem > 0','nDiasPag:=LocFerPag(aPeriodo[nPosSem][3],aPeriodo[nPosSem][4])','',''})
	Aadd(aRoteiro,{ cROT_RES,'00190','','GERA FERIADO PAGO'   ,'SRA->RA_TIPOPGT="S" .And. nDiasPag > 0','FGeraVerba(aCodfol[311,1],SALDIA*nDiasPag,nDiasPag)','',''})
	Aadd(aRoteiro,{ cROT_RES,'00200','','CALCULO DE LOS DIAS ','SRA->RA_CATFUNC$ "M*C" .And. Day(dDatadem) > 30 ','DiasTrab := 30 ','DiasTrab := Day(dDataDem)','' } )
	Aadd(aRoteiro,{ cROT_RES,'00210','','DIAS DE LICENCIA'    ,'','FDiasAfast(@nDiasAfas,@DiasTrab)'           ,'','' } )
	Aadd(aRoteiro,{ cROT_RES,'00220','','SALDO DE SALARIO'	  ,'SRA->RA_CATFUNC <> "H"','FSaldoSal(DiasTrab)','',''} )
	Aadd(aRoteiro,{ cROT_RES,'00230','','SUSTUTIVO DE CARNE'  ,'','LOCSUSCAR(1)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00240','','SUSTUT.DE CARNE RES' ,'','LOCSUSCAR(3)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00250','','PRIMA ANTIGUEDAD'    ,'','LOCATSER()','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00260','','LIQUIDACION'         ,'','LOCLIQUID()','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00270','','INDEMNIZACIÓN POR MATERNIDAD','cCompl # "S"','LocIndeniza(aCodfol)','', 'NI510' } )	
	Aadd(aRoteiro,{ cROT_RES,'00280','','VAL. FUTUROS'        ,'cCompl # "S"','fGerValFut("R")','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00290','','ABATER LIQUIDACION'  ,'cCompl = "S"','fAbatPago()','' , '' } )
	Aadd(aRoteiro,{ cROT_RES,'00300','','Calc. Ticket Alimentacion','( cCompl # "S" .or. ( cCompl == "S" .and. MesAno(GetMemVar("RG_DATADEM")) == MesAno(GetMemVar("RG_DTGERAR")) ) )','LocTicketAlim(aCodfol)','', 'NI487' } )			
	Aadd(aRoteiro,{ cROT_RES,'00310','','APORTE JUBILACION'   ,'','LOCJUBILA()','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00320','','CALCULO FONASA'       ,'','LOCFONASA()','' ,'NI494' } )  
	Aadd(aRoteiro,{ cROT_RES,'00330','','CJPPU'  		       ,'','LocCJPPU()','','NI495' } )
	Aadd(aRoteiro,{ cROT_RES,'00340','','Fondo de Solidariedad','' ,'LocFonSol()','','NI496' } )
	Aadd(aRoteiro,{ cROT_RES,'00350','','Focer'                ,'' ,'LocFocer() ','','NI497' } )
	Aadd(aRoteiro,{ cROT_RES,'00360','','Fosvoc'               ,'' ,'LocFosvoc() ','','NI498' } )
	Aadd(aRoteiro,{ cROT_RES,'00370','','Fondos Sociales de la Construcción ' 	,''	,'LocFonSoc()','','NI512' } )	
	Aadd(aRoteiro,{ cROT_RES,'00380','','SALARIO VACACIONAL'  ,'','LOCSALVAC()','' , '' } )
	Aadd(aRoteiro,{ cROT_RES,'00390','','Calculo Pensao Rescisao','','fCalcPensao(aCodfol[64,1],aCodFol[66,1],aCodFol[56,1],0,M->RG_DATAHOM," ")','',''} )		
	Aadd(aRoteiro,{ cROT_RES,'00400','','Calculo Pensao Ferias','','fCalcPensao(aCodfol[65,1],aCodFol[67,1],aCodFol[170,1],0,M->RG_DATAHOM,"FER")','',''} )	
	Aadd(aRoteiro,{ cROT_RES,'00410','','Calculo Pensao 13o.','','fCalcPensao(aCodfol[70,1],aCodFol[71,1],aCodFol[128,1],0,M->RG_DATAHOM,"13o")','','' } )	
	Aadd(aRoteiro,{ cROT_RES,'00420','','Assistencia Medica'     ,'( cCompl # "S" .or. ( cCompl == "S" .and. MesAno(GetMemVar("RG_DATADEM")) == MesAno(GetMemVar("RG_DTGERAR")) ) )','AssiMed(aCodfol,.T.)','','NI484' } )
	Aadd(aRoteiro,{ cROT_RES,'00430','','Calc. Ass. Odontologica','( cCompl # "S" .or. ( cCompl == "S" .and. MesAno(GetMemVar("RG_DATADEM")) == MesAno(GetMemVar("RG_DTGERAR")) ) )','fAssOdon(aCodfol)'   ,'','NI485' } )
   	Aadd(aRoteiro,{ cROT_RES,'00440','','CALCULO DE IRP'     ,'','If(MesAno(dDataBase) < "200707",LOCGANANC(),LOCIRPF())','' , '' } )
	Aadd(aRoteiro,{ cROT_RES,'00450','','SUMA PROVENTOS'      ,'','Aeval( aPd ,{ |X|  SomaInc(X,1,@nValProv, , , , , , ,aCodFol) })','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00460','','SUMA DESCUENTOS'     ,'','Aeval( aPd ,{ |X|  SomaInc(X,2,@nValDesc, , , , , , ,aCodFol) })','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00470','','NETO A COBRAR		  '  ,'','fLiquido(aCodfol,aCodFol[126,1],0,"",.T.,aCodFol[045,1],.T.,.T.,.T.)','','' })
ElseIf c__Roteiro == cROT_RES .And. cPaisLoc = 'DOM'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ROTEIRO DO CALCULO LIQUIDACION/RESCISAO-REPUBLICA DOMINICANA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRoteiro,{ cROT_RES,'00010','','VALORIZA CONCEPTOS'  ,''								,'FValoriza(aPd,aCodfol,,Saldia,Salhora)','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00020','','DIAS TRABAJADOS '    ,''                      ,'LOCDIARES()'   ,'','' } )
	Aadd(aRoteiro,{ cROT_RES,'00030','','SALDO DE SALARIO'    ,''								,'FSaldoSal(DiasTrab)','',''} )
	Aadd(aRoteiro,{ cROT_RES,'00040','','Carga Tablas de Calculo'		,''	,'S_CARGA TABLOC','' , 'NI347' } )
	Aadd(aRoteiro,{ cROT_RES,'00050','','LIQUIDACION'         ,''								,'LOCLiquid()'   ,'','' } )
	Aadd(aRoteiro,{ cROT_RES,'00060','','SEGURO SOCIAL IDSS'  ,'SRA->RA_IDSS = "1"'		,'LOCSegSoc()','' , '' } )
	Aadd(aRoteiro,{ cROT_RES,'00070','','RETENCIONES GANANCIA',''                      ,'LOCGANANC()','' , '' } )
	Aadd(aRoteiro,{ cROT_RES,'00080','','SUMA PROVENTOS'      ,''								,'Aeval( aPd ,{ |X|  SomaInc(X,1,@nValProv, , , , , , ,aCodFol) })','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00090','','SUMA DESCUENTOS'     ,''								,'Aeval( aPd ,{ |X|  SomaInc(X,2,@nValDesc, , , , , , ,aCodFol) })','','' } )
	Aadd(aRoteiro,{ cROT_RES,'00100','','Grava Liquido Rescisao  ','','fLiquido(aCodfol,aCodFol[126,1],0,"",.T.,"",.T.,.T.,.T.)','','' })
Endif

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ RotFer			  ³ Equipe Advanced RH	  ³ Data ³ 	   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Adiciona os Roteiros Padroes FER	    				 			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function RotFer( cROT_FER , c__Roteiro , cPaisLoc , aRoteiro )

If c__Roteiro == cROT_FER .And. cPaisLoc = 'ARG'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ROTEIRO DO CALCULO DE FERIAS/VACACIONES - ARGENTINA          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRoteiro,{ cROT_FER,'00010','','Carrega Lancto das Ferias','','fCarApdFer(@aPd)','','NI367' } )
	Aadd(aRoteiro,{ cROT_FER,'00020','','CALCULO DE PROMEDIOS' ,'','GPEXMED(GetMemVar("RH_DATABAS"),CTOD(""),GetMemVar("RH_DATAINI"),CTOD(""),dDatabase,SalHora,Val_Salmin,aCodfol,lMesAtu,.T.,.F.)','','NI207 09' } )
	Aadd(aRoteiro,{ cROT_FER,'00030','','VALORIZA CONCEPTOS'   ,'','FValoriza(aPd,aCodfol,,Saldia,Salhora)','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00040','','PROMEDIO'             ,'','fMedFer(@nMediaOut,@nMediaHrs,@nMedia13s,@nAntec13o)','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00050','','MEDIA PROMEDIO'       ,'','nProMed  := 6' ,'','' } )
	Aadd(aRoteiro,{ cROT_FER,'00060','','PORCENTUAL PROMEDIO'  ,'','nPercPro := 25','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00070','','PORC. VACACIONES'     ,'','nPercVac := 30','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00080','','APORTES'              ,'','nAportes := 20','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00090','','VACACIONES'           ,'','LOCFERIAS()'   ,'','' } )
	Aadd(aRoteiro,{ cROT_FER,'00100','','APORTE JUBILACION'    ,'SRA->RA_CATFUNC <> "A"','LOCJUBILA()','' , '' } ) //Revisado
	Aadd(aRoteiro,{ cROT_FER,'00110','','OBRA SOCIAL'          ,'SRA->RA_CATFUNC <> "A"','LOCOBRSOC()','' , '' } ) //Revisado
	Aadd(aRoteiro,{ cROT_FER,'00120','','LEY 19.032'           ,'SRA->RA_CATFUNC <> "A"','LOCAPLEY1()','' , '' } )
	Aadd(aRoteiro,{ cROT_FER,'00130','','RETENCIONES GANANCIA' ,'','LOCGANANC()','' , '' } )
	Aadd(aRoteiro,{ cROT_FER,'00140','','SUMA PROVENTOS   '    ,'','Aeval( aPd ,{ |X| If (X[1] <> aCodFol[22,1],SomaInc(X,1,@nValProv, , , , , , ,aCodFol),"") })','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00150','','TOTALIZADOES'         ,'','nValProv := nValDesc := 0.00'   ,'','' } )
	Aadd(aRoteiro,{ cROT_FER,'00160','','SUMA PROVENTOS'       ,'','Aeval( aPd ,{ |X|  SomaInc(X,1,@nValProv, , , , , ,.F. ,aCodFol) })','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00170','','SUMA DESCUENTOS'      ,'','Aeval( aPd ,{ |X|  SomaInc(X,2,@nValDesc, , , , , ,.F. ,aCodFol) })','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00180','','NETO A COBRAR'        ,'','fLiqFer()','','' } )
ElseIf c__Roteiro == cROT_FER .And. cPaisLoc = 'CHI'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ROTEIRO DO CALCULO DE FERIAS/VACACIONES - Chile              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRoteiro,{ cROT_FER,'00010','','Carrega Lancto das Ferias','','fCarApdFer(@aPd)','','NI367' } )
	Aadd(aRoteiro,{ cROT_FER,'00020','','CALCULO PROMEDIO'    ,'','GPEXMED(GetMemVar("RH_DATABAS"),CTOD(" "),GetMemVar("RH_DATAINI"),CTOD(""),dDatabase,SalHora,Val_Salmin,aCodfol,,,.F.)','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00030','','VALORIZA CONCEPTOS'  ,'','FValoriza(aPd,aCodfol,,Saldia,Salhora)','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00040','','PROMEDIO'            ,'','fMedFer(@nMediaOut,@nMediaHrs,@nMedia13s,@nAntec13o)','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00050','','VACACIONES'          ,'','LOCFERIAS()' ,'','' } )
	Aadd(aRoteiro,{ cROT_FER,'00060','','GRATIFICACION'       ,'','LOCGratif()' , '' , '' } )
	Aadd(aRoteiro,{ cROT_FER,'00070','','Calc. Pensao Alim. ','','FCalcPensao(aCodFol[65,1],aCodFol[67,1],aCodFol[170,1],0,M->RH_DTRECIB)','', '' } )
	Aadd(aRoteiro,{ cROT_FER,'00080','','SUMA PROVENTOS'      ,'','Aeval( aPd ,{ |X| If (X[1] <> aCodFol[22,1],SomaInc(X,1,@nValProv, , , , , , ,aCodFol),"") })','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00090','','TOTALIZADOES'        ,'','nValProv := nValDesc := 0.00','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00100','','SUMA PROVENTOS'      ,'','Aeval( aPd ,{ |X|  SomaInc(X,1,@nValProv, , , , , , ,aCodFol) })','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00110','','SUMA DESCUENTOS'     ,'','Aeval( aPd ,{ |X|  SomaInc(X,2,@nValDesc, , , , , , ,aCodFol) })','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00120','','NETO A COBRAR'       ,'','fLiqFer()','','' } )
ElseIf c__Roteiro == cROT_FER .And. cPaisLoc = 'PAR'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ROTEIRO DO CALCULO DE FERIAS/VACACIONES - PARAGUAI           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRoteiro,{ cROT_FER,'00010','','Carrega Lancto das Ferias','','fCarApdFer(@aPd)','','NI367' } )
	Aadd(aRoteiro,{ cROT_FER,'00020','','VALORIZA CONCEPTOS'  ,'','FValoriza(aPd,aCodfol,,Saldia,Salhora)','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00030','','VACACIONES'          ,'','LOCFERIAS()','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00040','','DIAS DE VAC. DOBLE'  ,'','fDiasDobra(@nDDobro)','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00050','','GEN. DE VAC. DOBLES' ,'nDDobro > 0','fGeraVerba(aCodFol[224,1],nDDobro * GetMemVar("RH_SALDIA"),nDDobro)','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00060','','APORTE JUBILACION'   ,'','LOCJUBILA()','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00070','','SUMA PROVENTOS'      ,'','Aeval( aPd ,{ |X| If (X[1] <> aCodFol[22,1],SomaInc(X,1,@nValProv, , , , , , ,aCodFol),"") })','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00080','','TOTALIZADORES'       ,'','nValProv := nValDesc := 0.00','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00090','','SUMA PROVENTOS'      ,'','Aeval( aPd ,{ |X|  SomaInc(X,1,@nValProv, , , , , , ,aCodFol) })','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00100','','SUMA DESCUENTOS'     ,'','Aeval( aPd ,{ |X|  SomaInc(X,2,@nValDesc, , , , , , ,aCodFol) })','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00110','','NETO A COBRAR'       ,'','fLiqFer()','','' } )
ElseIf c__Roteiro == cROT_FER .And. cPaisLoc = 'URU'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ROTEIRO DO CALCULO DE FERIAS/VACACIONES - URUGUAI            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRoteiro,{ cROT_FER,'00010','','Carrega Lancto das Ferias','','fCarApdFer(@aPd)','','NI367' } )
	Aadd(aRoteiro,{ cROT_FER,'00020','','Calculo das Medias'	,'','GPEXMED(GetMemVar("RH_DATABAS"),CTOD(""),GetMemVar("RH_DATAINI"),CTOD(""),CTOD("31/12/"+Str(Year(GetMemVar("RH_DATABAS")),4))+1,SalHora,Val_Salmin,aCodfol,lMesAtu,.T.,.F.)','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00030','','Valoriza as Verbas'	,'','FValoriza(aPd,aCodfol,,Saldia,Salhora)','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00040','','VACACIONES'          ,'','LOCFERIAS()','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00050','','SUSTUTIVO DE CARNE'  ,'','LOCSUSCAR(2)','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00060','','APORTE JUBILACION'   ,'','LOCJUBILA()','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00070','','CALCULO FONASA'       ,'','LOCFONASA()','' , 'NI507' } )
	Aadd(aRoteiro,{ cROT_FER,'00080','','CJPPU'  		       ,'','LocCJPPU()','','NI508' } )
	Aadd(aRoteiro,{ cROT_FER,'00090','','Fondo de Solidariedad','' ,'LocFonSol()','','NI509' } )	
	Aadd(aRoteiro,{ cROT_FER,'00100','','SALARIO VACACIONAL'  ,'','LOCSALVAC()','' , '' } )
	Aadd(aRoteiro,{ cROT_FER,'00110','','Calc. Pensao Alim. ','','FCalcPensao(aCodFol[65,1],aCodFol[67,1],aCodFol[170,1],0,M->RH_DTRECIB)','', '' } )
  	Aadd(aRoteiro,{ cROT_FER,'00120','','RETENCIONES GANANCIA','','If(MesAno(dDataBase) < "200707",LOCGANANC(),LOCIRPF())','' , '' } )
	Aadd(aRoteiro,{ cROT_FER,'00130','','SUMA PROVENTOS'      ,'','Aeval( aPd ,{ |X| If (X[1] <> aCodFol[22,1],SomaInc(X,1,@nValProv, , , , , , ,aCodFol),"") })','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00140','','TOTALIZADORES'       ,'','nValProv := nValDesc := 0.00','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00150','','SUMA PROVENTOS'      ,'','Aeval( aPd ,{ |X|  SomaInc(X,1,@nValProv, , , , , , ,aCodFol) })','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00160','','SUMA DESCUENTOS'     ,'','Aeval( aPd ,{ |X|  SomaInc(X,2,@nValDesc, , , , , , ,aCodFol) })','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00170','','NETO A COBRAR'       ,'','fLiqFer()','','' } )
ElseIf c__Roteiro == cROT_FER .And. cPaisLoc = 'DOM'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ROTEIRO DO CALCULO DE FERIAS/VACACIONES - REPUBLICA DOMINICA.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRoteiro,{ cROT_FER,'00010','','Carrega Lancto das Ferias','','fCarApdFer(@aPd)','','NI367' } )
	Aadd(aRoteiro,{ cROT_FER,'00020','','VALORIZA CONCEPTOS'  ,'','FValoriza(aPd,aCodfol,,Saldia,Salhora)','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00030','','Montaje de Sueldo Mensual'	,''	,'S_SALARIO MENSAL','' , '' } )
	Aadd(aRoteiro,{ cROT_FER,'00040','','Montaje de Sueldo Hora'   	,''	,'S_SALARIO HORA','' , 'NI310' } )
	Aadd(aRoteiro,{ cROT_FER,'00050','','Montaje de Sueldo Dia'    	,''	,'S_SALARIO DIA','' , 'NI311' } )
	Aadd(aRoteiro,{ cROT_FER,'00060','','Carga Tablas de Calculo'		,''	,'S_CARGA TABLOC','' , 'NI347' } )
	Aadd(aRoteiro,{ cROT_FER,'00070','','DIAS TRABAJADOS'     ,'','FDiasTrab(@DiasTrab,cDiasMes,@lAdmissao)'   ,'','' } )
	Aadd(aRoteiro,{ cROT_FER,'00080','','VACACIONES'          ,'','LOCFERIAS()','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00090','','DIAS DE VAC. DOBLE'  ,'','fDiasDobra(@nDDobro)','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00100','','GEN. DE VAC. DOBLES' ,'nDDobro > 0','fGeraVerba(aCodFol[224,1],nDDobro * GetMemVar("RH_SALDIA"),nDDobro)','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00110','','Valoriza as Verbas'  ,'','FValoriza(aPd,aCodfol,,Saldia,Salhora)','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00120','','SEGURO SOCIAL IDSS'  ,'SRA->RA_IDSS = "1"'       ,'LOCSegSoc()','' , '' } )
	Aadd(aRoteiro,{ cROT_FER,'00130','','SERVICIO ALIMENTAC'  ,''                         ,'LOCALIME()' ,'' , '' } )
	Aadd(aRoteiro,{ cROT_FER,'00140','','RETENCIONES GANANCIA',''                         ,'LOCGANANC()','' , '' } )
	Aadd(aRoteiro,{ cROT_FER,'00150','','SUMA PROVENTOS'      ,'','Aeval( aPd ,{ |X| If (X[1] <> aCodFol[22,1],SomaInc(X,1,@nValProv, , , , , , ,aCodFol),"") })','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00160','','TOTALIZADORES'       ,'','nValProv := nValDesc := 0.00','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00170','','SUMA PROVENTOS'      ,'','Aeval( aPd ,{ |X|  SomaInc(X,1,@nValProv, , , , , , ,aCodFol) })','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00180','','SUMA DESCUENTOS'     ,'','Aeval( aPd ,{ |X|  SomaInc(X,2,@nValDesc, , , , , , ,aCodFol) })','','' } )
	Aadd(aRoteiro,{ cROT_FER,'00190','','NETO A COBRAR'       ,'','FMatriz(aCodfol[102,1],nValProv - nValDesc)','','' } )
Endif

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ RotLuc		 	  ³ Silvia Taguti   		  ³ Data ³ 26.05.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Adiciona o  Roteiro  Participacao Lucro   		 	        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function RotLuc( cROT_LUC , c__Roteiro , cPaisLoc , aRoteiro )

If c__Roteiro == cROT_LUC .And. cPaisLoc == 'DOM'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ROTEIRO DO CALCULO DE PARTICIPACAO LUCRO                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRoteiro,{ cROT_LUC,'00010','','Montaje de Sueldo Mensual',''	,'S_SALARIO MENSAL','' , '' } )
	Aadd(aRoteiro,{ cROT_LUC,'00020','','Montaje de Sueldo Hora'   ,''	,'S_SALARIO HORA','' , 'NI310' } )
	Aadd(aRoteiro,{ cROT_LUC,'00030','','Montaje de Sueldo Dia'    ,''	,'S_SALARIO DIA','' , 'NI311' } )
	Aadd(aRoteiro,{ cROT_LUC,'00040','','VALORIZA CONCEPTOS'   		 ,''	,'FValoriza(aPd,aCodFol,@Salmes,@Saldia,@SalHora,Val_SalMin,,,.T.)','','' } )
	Aadd(aRoteiro,{ cROT_LUC,'00050','','PARTIC.DOS LUCROS'   		 ,''  ,'LOCLUCRO()' ,'' , '' } )
	Aadd(aRoteiro,{ cROT_LUC,'00060','','RETENCIONES GANANCIA'		 ,''  ,'LOCGANANC()','' , '' } )
	Aadd(aRoteiro,{ cROT_LUC,'00070','','NETO A COBRAR'        		 ,''	,'fLiquido(aCodfol,aCodfol[47,1],0,,.F.,,.F.)','','' } )
Endif

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ FCriaRotLoc	     ³ Autor		    		  ³ Data ³		  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Roteiro no SRM 									           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function FCriaRotLoc(cFil,cTipo,aRotPadrao)

Local aRotUsua	:= {}
Local aRotNovo	:= {}
Local cAlias	:= "SRM"
Local cDesc		:= ""
Local cSeq		:= ""
Local cSrySeqFil:= ""
Local lRet		:= .T.
Local nRoteiro	:= 0.00
Local nPosRot	:= 0.00
Local nTamSeq   := TamSX3( "RM_SEQ    ")[1]

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ RESPONSAVEL PELA ATUALIZACAO DO ROTEIRO					   ³
³ SE FOR ALTERADO O ROTEIRO, DEVE SER INCREMENTADO DE 1		   ³
³ E VERIFICAR O ULTIMO ROTEIRO CRIADO						   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cChave := "029"      /* Ultima Alteracao Tiago Malta 01/08/10 Ultimo 'NI512'*/ 
Local lRevisao := .F.

Begin Sequence

	cTipo := Upper( AllTrim( cTipo ) )
	IF ( nPosRot := aScan( aRotPadrao , { |x| x[1] == cTipo } ) ) > 0.00
		cDesc := aRotPadrao[ nPosRot , 2 ]
	EndIF
	
	dbSelectArea("SRM")
	// Avalia se necessita de Revisao
	If SRM->( dbSeek ( cFil + cTipo ) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizar a sequencia do campo RM_CHAVE com os NI			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SRM->RM_VERSAO < "023"
			fAtuNIRot(cFil, cTipo)
		EndIf

		While SRM->( !Eof() .and. RM_FILIAL + RM_CALCULO == cFil + cTipo )
			IF SRM->( Val(RM_SEQ)%10 = 0 .and. RM_VERSAO # cChave )
				lRevisao := .T.
				Exit
			EndIF
			SRM->( dbSkip() )
		EndDo
		IF !lRevisao
			lRet := .T.
			Break
		EndIF
		SRM->( dbSeek( cFil + cTipo ) )
		While SRM->( !Eof() .and. RM_FILIAL + RM_CALCULO == cFil + cTipo )
			cSeq := StrZero(VAL(SRM->RM_SEQ),nTamSeq)
			SRM->( aAdd(aRotUsua,{	RM_CALCULO	,; // 1 - Roteiro
									cSeq		,; // 2 - Sequencia	
									RM_SUBSEQ	,; // 3 - Sub-Sequencia
									RM_DESCRIC	,; // 4 - Descricao
									RM_IF		,; // 5 - Condicao
									RM_FORMULA	,; // 6 - Formula se Verdadeiro
									RM_FALSE	,; // 7 - Formula se Falso
									RM_CHAVE	 ; // 8 - Chave de Alteracao
								  }				 ;
						 )						 ;
				  )		 	
			SRM->( dbSkip() )
		EndDo
	EndIF
	
	IF Len(aRotUsua) > 0
		IF !FReorRot(@aRoteiro,@aRotUsua,nTamSeq)
			lRet := .F.
			Break
		EndIF
		aRotNovo := Aclone(aRotUsua)
	Else
		aRotNovo := Aclone(aRoteiro)
	EndIF
	
	dbSelectArea(cAlias)
	
	While .T.
		IF !( SRM->( dbSeek(cFil+cTipo) ) )
			Exit
		EndIF
		RecLock(cAlias,.F.,.T.)
		SRM->RM_FILIAL := "##"
		SRM->( MsUnlock() )
	EndDo
	
    // Ajustado a ordem de gravacao(integridade). Primeiro Pai(SRY) e depois a tabela filho(SRM).
	IF SRY->( !dbSeek( cFil + cTipo , .F. ) ) 
		
		cSrySeqFil := GetSrySeqFil(cFil)
		
		RecLock("SRY",.T.,.F.)
		SRY->RY_FILIAL	:= cFil
		SRY->RY_CALCULO	:= cTipo
		SRY->RY_DESC	:= cDesc
		SRY->RY_ORIGEM 	:= "1"
		SRY->RY_SEQFIL	:= cSrySeqFil
		SRY->( MsUnLock() )
	EndIF
	For nRoteiro := 1 To Len(aRotNovo)
		IF SRM->( dbSeek("##") )
			RecLock(cAlias,.F.)
		Else
			RecLock(cAlias,.T.)
		EndIF
		SRM->RM_FILIAL	:= cFil
		SRM->RM_CALCULO	:= aRotNovo[nRoteiro,1]
		SRM->RM_SEQ		:= aRotNovo[nRoteiro,2]
		SRM->RM_SUBSEQ	:= aRotNovo[nRoteiro,3]
		SRM->RM_DESCRIC	:= aRotNovo[nRoteiro,4]
		SRM->RM_IF		:= aRotNovo[nRoteiro,5]
		SRM->RM_FORMULA	:= aRotNovo[nRoteiro,6]
		SRM->RM_FALSE	:= aRotNovo[nRoteiro,7]
		SRM->RM_CHAVE	:= aRotNovo[nRoteiro,8]
		SRM->RM_VERSAO	:= cChave
		SRM->( MsUnlock() )
	Next nRoteiro
	
	SRM->( dbSeek("##") )
	While SRM->( !Eof() .and. RM_FILIAL == "##" )
		RecLock("SRM",.F.)
		SRM->( dbDelete() )
		SRM->( MsUnlock() )
		SRM->( dbSkip() )
	EndDo

End Sequence
	
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fAtuNIRot ºAutor  ³Mauricio Takakura   º Data ³  24/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Acertar os NI do campo RM_CHAVE para os itens de roteiros  º±±
±±º          ³ antigos, que estavam com valor em branco.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fAtuNIRot(cFilSRM, cCalcSRM) // De acordo com o tipo de calculo solicitado no FCriaRotLoc()

Local aArea		:= SRM->(GetArea())

Local cValNI

Local nSeq
Local nNewNI

Do Case
	Case cPaisLoc == "CHI"
		If cCalcSRM == 'FOL'
			nNewNI := 462 // Vai até 483
		ElseIf cCalcSRM == "RES"
			nNewNI := 383 // Vai até 406
		Else                            
			Return
		EndIf
	Otherwise
		Return
EndCase
	
DbSelectArea( "SRM" )
DbSetOrder(1)	//RM_FILIAL+RM_CALCULO+RM_SEQ+RM_SUBSEQ
SRM->( dbSeek( cFilSRM + cCalcSRM ) )

While SRM->( !Eof() .and. RM_FILIAL + RM_CALCULO == cFilSRM + cCalcSRM )
	nSeq 	:= Val(SRM->RM_SEQ)
	cValNI 	:= SubStr(SRM->RM_CHAVE,1,5)   

	If nSeq % 10 == 0.00 .and. cValNI == Space(5)
		RecLock("SRM",.F.)
		SRM->RM_CHAVE	:= 'NI'+StrZero(nNewNI,3)+Substr(SRM->RM_CHAVE,-3)
		SRM->( MsUnlock() )
		nNewNI++
	EndIf

	SRM->(DbSkip())

EndDo

RestArea(aArea)

Return