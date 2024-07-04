#INCLUDE "GPER070.CH" 
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡cao    ³GP056Fer  ³ Autor ³ Emerson Campos                    ³ Data ³ 18/10/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrica‡…o ³ Impressao de Programação de Rateio Ferias                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GP056Fer()                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC            ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³MOHANAD ODEH³          ³M12RH01/REQ     ³                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³                ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function GP056Fer()
Local cString :="SRA"        	    // ALIAS DO ARQUIVO PRINCIPAL (Base)
Local aOrd	  := {STR0001,STR0003,STR0081} //"Matricula"###"Nome"###"C.Custo do Movto"
Local cDesc1  := STR0005			//"Emiss„o da Provis„o de F‚rias."
Local cDesc2  := STR0006			//"ser  impresso de acordo com os parametros solicitados"
Local cDesc3  := STR0007			//"pelo usu rio."
Local cTpRtProv	:= "RPF"			//RPF - Rateio Provisao Férias
Private aReturn  := {STR0008, 1,STR0009, 2, 2, 1, "",1 }		// "Zebrado"###"Administra‡„o"
Private nomeprog := "GPER070"
Private nLastKey := 0
Private cPerg	 := "GPR070"
Private cPict1  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 999,999,999.99",TM(999999999,14,MsDecimais(1)))  // "@E 99,999,999,999.99
Private cPict2  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 999999999.99"  ,TM(999999999,12,MsDecimais(1)))  // "@E 999999999.99
Private cPict3  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 9999999999.99" ,TM(9999999999,13,MsDecimais(1)))  // "@E 9999999999.99
Private cPict4  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 99999999999.99",TM(99999999999,14,MsDecimais(1)))  // "@E 99999999999.99
Private cPict5  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 9999999.99"  ,TM(9999999,10,MsDecimais(1)))  		// "@E 9999999.99
//VARIAVEIS UTILIZADAS NA FUNCAO IMPR
Private Titulo	 := STR0078			//"PROVISŽO MENSAL DE FERIAS "
Private AT_PRG	 := "GPER070"
Private wCabec0  := 1
Private wCabec1  := STR0011 //"Data Base: "
Private CONTFL   :=1
Private LI		 :=0
Private nTamanho :="M"

TCInternal(5,"*OFF")   // Desliga Refresh no Lock do Top

//VERIFICA AS PERGUNTAS SELECIONADAS
Pergunte("GPR070",.F.)

//ENVIA CONTROLE PARA A FUNCAO SETPRINT
wnrel:="GPER070"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

//CARREGA VARIAVEIS PRIVATES COMUNS A GPEA070,GPER070 E GPEM070
GPEProvisao(wnRel,cString,Titulo,,2,,cTpRtProv)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GP056Dec  ³ Autor ³ Emerson Campos                    ³ Data ³ 25/10/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrica‡…o ³ Impressao de Programação de Rateio Decimo Terceiro                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GP056Dec()                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC            ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³                ³                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³                ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GP056Dec()
Local cString := "SRA"        			// Alias do arquivo principal (Base)
Local aOrd	  := {STR0001,STR0003,STR0081}   //"Matricula"###"Nome"###"C.Custo do Movto"
Local cDesc1  := STR0059				//"Emiss„o de Provis„o de 13o Salario."
Local cDesc2  := STR0006				//"Ser  impresso de acordo com os parametros solicitados pelo"
Local cDesc3  := STR0007				//"usu rio."
Local cTpRtProv	:= "RP13"				//RP13 - Rateio Provisao Decimo Terceiro
Private cPict1  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 999,999,999.99",TM(999999999,14,MsDecimais(1)))  // "@E 99,999,999,999.99
Private cPict2  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 999999999.99"  ,TM(999999999,12,MsDecimais(1)))  // "@E 999999999.99
Private cPict3  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 9999999999.99" ,TM(9999999999,13,MsDecimais(1)))  // "@E 9999999999.99
Private cPict4  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 99999999999.99",TM(99999999999,14,MsDecimais(1)))  // "@E 99999999999.99
Private cPict5  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 9999999.99"  ,TM(9999999,10,MsDecimais(1)))  		// "@E 9999999.99
Private aReturn  := {STR0008,1,STR0009, 2, 2, 1, "",1 }		// "Zebrado"###"Administra‡„o"
Private NomeProg := "GPER090"
Private nLastKey := 0
Private cPerg	 := "GPR090"
//VARIAVEIS UTILIZADAS NA FUNCAO IMPR
Private Titulo	 := STR0079		//"PROVISŽO MENSAL DE 13o SALARIO"
Private AT_PRG	 := "GPER090"
Private wCabec0  := 1
Private wCabec1  := STR0011	//"Data Base: "
Private CONTFL	 := 1
Private LI		 := 0
Private nTamanho := "M"

TCInternal(5,"*OFF")   // DESLIGA REFRESH NO LOCK DO TOP

//VERIFICA AS PERGUNTAS SELECIONADAS
Pergunte("GPR090",.F.)

//ENVIA CONTROLE PARA A FUNCAO SETPRINT
wnrel := "GPER090"            //Nome Default do relatorio em Disco
wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

//CARREGA VARIAVEIS PRIVATES COMUNS A GPEA070,GPER070 E GPEM070
GPEProvisao(wnRel,cString,Titulo,,3,,cTpRtProv)
Return