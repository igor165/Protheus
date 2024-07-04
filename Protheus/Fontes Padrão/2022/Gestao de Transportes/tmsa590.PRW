#Include "TMSA590.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

Static lTMALocal   := ExistBlock('TMALOCAL')

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA590  ³ Autor ³Rodrigo A Sartorio     ³ Data ³ 12/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Enderecamento por documento de transporte                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA590()

LOCAL cIndex  	:= "",cKey := "",cCond := "",nIndex := 0,cViagemVazia := Criavar("DUD_VIAGEM",.F.)
LOCAL aCampos 	:= {}
Local aFldDUD 	:= {}
Local nX		:= 0

//Ajuste de Novos Helps
PutHelp("PTMSA59001",{"Não Endereçado"},{"Unaddressed "},{"Sin Direccion"},.F.)

//Tratamento para chamar automaticamente a rotina de enderecamento sem controle de estoque
//caso a TES do parametro MV_TESDR esteja configurada para isso
If TmsChkTES('1')
	If SF4->F4_ESTOQUE == "N"
		TMSA595()
		Return .F.
	EndIf
Else
	Return .F.
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Define Array contendo as Rotinas a executar do programa     ³
//³ ----------- Elementos contidos por dimensao ------------    ³
//³ 1. Nome a aparecer no cabecalho                             ³
//³ 2. Nome da Rotina associada                                 ³
//³ 3. Usado pela rotina                                        ³
//³ 4. Tipo de Transa‡„o a ser efetuada                         ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados            ³
//³    2 - Simplesmente Mostra os Campos                        ³
//³    3 - Inclui registros no Bancos de Dados                  ³
//³    4 - Altera o registro corrente                           ³
//³    5 - Remove o registro corrente do Banco de Dados         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := { { STR0001,"TMSXPesqui",0,1}} //"Pesquisar"

PRIVATE cCadastro := STR0002 //"Enderecamento por documento"

PRIVATE lEstornoT590 := .F. // Variavel que indica quando esta processando o estorno

PRIVATE lAllMark    := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Pergunte("TMA590",.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                            ³
	//³ mv_par01        	// Filial Documento De                      ³
	//³ mv_par02        	// Filial Documento Ate                     ³
	//³ mv_par03        	// Documento De                             ³
	//³ mv_par04        	// Documento Ate                            ³
	//³ mv_par05        	// Serie De                                 ³
	//³ mv_par06        	// Serie Ate                                ³
	//³ mv_par07        	// De Filial Origem Viagem                  ³
	//³ mv_par08        	// Ate Filial Origem Viagem                 ³
	//³ mv_par09        	// De Viagem                                ³
	//³ mv_par10        	// Ate Viagem                               ³
	//³ mv_par11        	// Mostra documentos  1 - Sem enderecar     ³
	//³                                           2 - Ja enderecados    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	// Estabelece os campos a serem exibidos na MSSELECT
	
	Aadd( aCampos, { "DUD_OK", "", "", "" } )
	
	aFldDUD := ApBuildHeader("DUD")
	For nX := 1 To Len(aFldDUD)
		If  GetSX3Cache(aFldDUD[nX][2], "X3_BROWSE") == "S" .And. (aFldDUD[nx][10] != "V")
			aAdd(aCampos, {aFldDUD[nX][2],"", aFldDUD[nX][1], aFldDUD[nX][3]})
		EndIf
	Next

	aSize(aFldDUD, 0)
	aFldDUD := Nil 
		
	cIndex := CriaTrab(nil,.f.)
	dbSelectArea("DUD")
	cKey := IndexKey()
	cCond:= 'DUD_FILIAL=="'+xFilial("DUD")+'".And.DUD_FILORI=="'+cFilAnt+'".And.'
	cCond+= 'DUD_FILDOC>="'+mv_par01+'".And.DUD_FILDOC<="'+mv_par02+'".And.'
	cCond+= 'DUD_DOC>="'+mv_par03+'".And.DUD_DOC<="'+mv_par04+'".And.'
	cCond+= 'DUD_SERIE>="'+mv_par05+'".And.DUD_SERIE<="'+mv_par06+'".And.'
	cCond+= 'DUD_FILVGE>="'+mv_par07+'".And.DUD_FILVGE<="'+mv_par08+'".And.'
	cCond+= 'DUD_NUMVGE>="'+mv_par09+'".And.DUD_NUMVGE<="'+mv_par10+'"'
	// Documentos sem enderecar
	If mv_par11 == 1
		cCond += '.And.DUD_ENDERE=="1"'
		AADD(aRotina,{ STR0003,"TMSA590End",0,6}) //"Enderecar"
	// Documentos ja enderecados
	ElseIf mv_par11 == 2
		lEstornoT590 := .T.
		cCond += '.And.DUD_ENDERE=="2".And.DUD_VIAGEM=="'+cViagemVazia+'"'
		AADD(aRotina,{ STR0004,"TMSA590End",0,2}) //"eStornar"
	EndIf
	IndRegua("DUD",cIndex,cKey,,cCond)
	nIndex := RetIndex("DUD")
	dbSetOrder(nIndex+1)
	dbGotop()
	If BOF() .and. EOF()
		HELP(" ",1,"RECNO")
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Endereca a funcao de BROWSE                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMarca := GetMark()
		MarkBrow("DUD","DUD_OK","",aCampos,,cMarca,"TMSA590All(@lAllMark)")
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura condicao anterior do arquivo                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("DUD")
	RetIndex("DUD")
	DbClearFilter()
	If File(cIndex+OrdBagExt())
		Ferase(cIndex+OrdBagExt())
	Endif
EndIf

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA590End³ Autor ³Rodrigo A Sartorio     ³ Data ³ 12/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao que processa o enderecamento por documento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA590                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA590End(cAlias,cCampo,nOpcE,cMarca,lInverte)

LOCAL nOpca    := 0,oDlg
LOCAL aObjects := {},aPosObj :={}
LOCAL aSize    := MsAdvSize()
LOCAL aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
LOCAL cEndVazio:=Criavar("DUH_LOCALIZ",.F.)
LOCAL aButtons := If(lEstornoT590,{},{ {'AUTOM',{|| TMSA590Dig(aCols,nPosArmazem,nPosEndereco) },STR0005}}) //"Endereco para todos documentos"
LOCAL nTamMax  := 0
LOCAL aAreaDUD := DUD->( GetArea() )
LOCAL cTesEnt  := GetMV("MV_TESDR",,"") // Tes de Entrada
Local cArmazem := ""
Local aAreaSBZ
                
SF4->( DbSetOrder( 1 ) )
SF4->(MsSeek(xFilial('SF4') + cTesEnt, .F.)) 

PRIVATE nPosFilDoc:=0,nPosEndereco:=0,nPosNumSeq:=0,nPosDoc:=0,nPosSerie:=0,nPosCod:=0,nPosQuant:=0,nPosCli:=0,nPosLoja:=0,nPosArmazem:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do AHeader.                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aHeader := {}
aTam:=TamSX3("DTC_FILDOC")	
Aadd(aHeader,{RetTitle("DTC_FILDOC"),"DTC_FILDOC"	,PesqPict("DTC","DTC_FILDOC",atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTC"," "})
aTam:=TamSX3("DTC_DOC")	
Aadd(aHeader,{RetTitle("DTC_DOC")	,"DTC_DOC"		,PesqPict("DTC","DTC_DOC"	,atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTC"," "})
aTam:=TamSX3("DTC_SERIE")	
Aadd(aHeader,{RetTitle("DTC_SERIE")	,"DTC_SERIE"	,PesqPict("DTC","DTC_SERIE"	,atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTC"," "})
aTam:=TamSX3("DTC_CLIREM")	
Aadd(aHeader,{RetTitle("DTC_CLIREM"),"DTC_CLIREM"	,PesqPict("DTC","DTC_CLIREM",atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTC"," "})
aTam:=TamSX3("DTC_LOJREM")	
Aadd(aHeader,{RetTitle("DTC_LOJREM"),"DTC_LOJREM"	,PesqPict("DTC","DTC_LOJREM",atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTC"," "})
aTam:=TamSX3("DTC_NUMNFC")	
Aadd(aHeader,{RetTitle("DTC_NUMNFC"),"DTC_NUMNFC"	,PesqPict("DTC","DTC_NUMNFC",atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTC"," "})
aTam:=TamSX3("DTC_SERNFC")
Aadd(aHeader,{RetTitle("DTC_SERNFC"),"DTC_SERNFC"	,PesqPict("DTC","DTC_SERNFC",atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTC"," "})
aTam:=TamSX3("DTC_CODPRO")
Aadd(aHeader,{RetTitle("DTC_CODPRO"),"DTC_CODPRO"	,PesqPict("DTC","DTC_CODPRO",atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTC"," "})
aTam:=TamSX3("DTC_QTDVOL")
Aadd(aHeader,{RetTitle("DTC_QTDVOL"),"DTC_QTDVOL"	,PesqPict("DTC","DTC_QTDVOL",atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTC"," "})
aTam:=TamSX3("DB_LOCAL")
Aadd(aHeader,{RetTitle("DB_LOCAL")	,"DB_LOCAL"		,PesqPict("SDB","DB_LOCAL"	,atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"SDB"," "})
aTam:=TamSX3("DB_LOCALIZ")
Aadd(aHeader,{RetTitle("DB_LOCALIZ"),"DB_LOCALIZ"	,PesqPict("SDB","DB_LOCALIZ",atam[1]),aTam[1],aTam[2],"Tmsa590Cad(aCols[n,nPosArmazem],M->DB_LOCALIZ)",USADO, "C" ,"SDB"," "})
aTam:=TamSX3("DB_NUMSEQ")
Aadd(aHeader,{RetTitle("DB_NUMSEQ")	,"DB_NUMSEQ"	,PesqPict("SDB","DB_NUMSEQ"	,atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"SDB"," "})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Descobre a posicao do Endereco                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosFilDoc:=aScan(aHeader,{|x| AllTrim(x[2])=="DTC_FILDOC"})
nPosCod:=aScan(aHeader,{|x| AllTrim(x[2])=="DTC_CODPRO"})
nPosArmazem:=aScan(aHeader,{|x| AllTrim(x[2])=="DB_LOCAL"})
nPosEndereco:=aScan(aHeader,{|x| AllTrim(x[2])=="DB_LOCALIZ"})
nPosNumSeq:=aScan(aHeader,{|x| AllTrim(x[2])=="DB_NUMSEQ"})
nPosDoc:=aScan(aHeader,{|x| AllTrim(x[2])=="DTC_NUMNFC"})
nPosSerie:=aScan(aHeader,{|x| AllTrim(x[2])=="DTC_SERNFC"})
nPosQuant:=aScan(aHeader,{|x| AllTrim(x[2])=="DTC_QTDVOL"})
nPosCli:=aScan(aHeader,{|x| AllTrim(x[2])=="DTC_CLIREM"})
nPosLoja:=aScan(aHeader,{|x| AllTrim(x[2])=="DTC_LOJREM"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCols  := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols auxiliar para gravacao de registros.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aColsAux:={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
    Final(STR0008) //"Atualizar SIGACUS.PRW !!!"
Endif
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
    Final(STR0009) //"Atualizar SIGACUSA.PRX !!!"
Endif
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
    Final(STR0010) //"Atualizar SIGACUSB.PRX !!!"
Endif

dbSelectArea("SDA")
dbSetOrder(1)
dbSelectArea("SD1")
dbSetOrder(1)
dbSelectArea("DTC")
dbSetOrder(3)
dbSelectArea("DUD")
dbGotop()
While !Eof()
	// Verifica se o item esta marcado
	If IsMark("DUD_OK",cMarca,lInverte)
		If !TmsPsqDY4(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE)			
			// Pesquisa no arquivo de NFS do cliente
			dbSelectArea("DTC")
			dbSeek(xFilial()+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE)
			While !Eof() .And. DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE == xFilial()+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE
			   If SF4->F4_ESTOQUE = 'S' 
					If SD1->(dbSeek(xFilial("SD1")+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM+DTC->DTC_CODPRO))
						If lEstornoT590 .Or. (SDA->(dbSeek(xFilial("SDA")+DTC->DTC_CODPRO+SD1->D1_LOCAL+SD1->D1_NUMSEQ+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM)) .And. SDA->DA_SALDO > 0)
							nTamMax++
							AADD(aCols,{DTC_FILDOC,DTC_DOC,DTC_SERIE,DTC_CLIREM,DTC_LOJREM,DTC_NUMNFC,DTC_SERNFC,DTC_CODPRO,SDA->DA_SALDO,SD1->D1_LOCAL,cEndVazio,SD1->D1_NUMSEQ,.F.})	
							AADD(aColsAux,{DUD->(Recno()),""})
						EndIf
					EndIf						
				Else        
					nTamMax++  
					//-- Ponto de Entrada utilizado para retornar o Armazem
					If lTMALocal
						cArmazem := ExecBlock( 'TMALOCAL', .F., .F., { DTC_FILDOC, DTC_DOC, DTC_SERIE } )	
					Else
						If RetArqProd(DTC_CODPRO)
							cArmazem :=	Posicione("SB1",1,xFilial("SB1")+DTC_CODPRO,"B1_LOCPAD")	
						Else
							If RetArqProd(DTC_CODPRO)
								cArmazem :=	Posicione("SB1",1,xFilial("SB1")+DTC_CODPRO,"B1_LOCPAD")	
							Else
								aAreaSBZ:= GetArea()
								cArmazem :=	Posicione("SBZ",1,xFilial("SBZ")+DTC_CODPRO,"BZ_LOCPAD")	
								RestArea(aAreaSBZ)
							Endif	
						EndIf											
						AADD(aCols,{DTC_FILDOC,DTC_DOC,DTC_SERIE,DTC_CLIREM,DTC_LOJREM,DTC_NUMNFC,DTC_SERNFC,DTC_CODPRO,DTC_QTDVOL,cArmazem,cEndVazio,"",.F.})	
						AADD(aColsAux,{DUD->(Recno()),""})				
					EndIf
				EndIf		
				dbSkip()				
			EndDo
		Else
			// Pesquisa no arquivo de NFS do cliente
			DbSelectArea("DY4")
			DbSetOrder(1) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
			If DY4->(MsSeek( xFilial('DY4') + DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE  ))				
				While !Eof() .And. DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE == xFilial()+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE
				   If SF4->F4_ESTOQUE = 'S' 
						If SD1->(dbSeek(xFilial("SD1")+DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM+DY4->DY4_CODPRO))
							If lEstornoT590 .Or. (SDA->(dbSeek(xFilial("SDA")+DY4->DY4_CODPRO+SD1->D1_LOCAL+SD1->D1_NUMSEQ+DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM)) .And. SDA->DA_SALDO > 0)
								nTamMax++
								AADD(aCols,{DY4_FILDOC,DY4_DOC,DY4_SERIE,DY4_CLIREM,DY4_LOJREM,DY4_NUMNFC,DY4_SERNFC,DY4_CODPRO,SDA->DA_SALDO,SD1->D1_LOCAL,cEndVazio,SD1->D1_NUMSEQ,.F.})	
								AADD(aColsAux,{DUD->(Recno()),""})
							EndIf
						EndIf
					Else        
						nTamMax++  
						//-- Ponto de Entrada utilizado para retornar o Armazem
						If lTMALocal
							cArmazem := ExecBlock( 'TMALOCAL', .F., .F., { DY4_FILDOC, DY4_DOC, DY4_SERIE } )	
						Else
							If RetArqProd(DY4_CODPRO)
								cArmazem :=	Posicione("SB1",1,xFilial("SB1")+DY4_CODPRO,"B1_LOCPAD")	
							Else
								aAreaSBZ:= GetArea()
								cArmazem :=	Posicione("SBZ",1,xFilial("SBZ")+DY4_CODPRO,"BZ_LOCPAD")	
								RestArea(aAreaSBZ)
							Endif	
						EndIf											
						AADD(aCols,{DY4_FILDOC,DY4_DOC,DY4_SERIE,DY4_CLIREM,DY4_LOJREM,DY4_NUMNFC,DY4_SERNFC,DY4_CODPRO,DY4_QTDVOL,cArmazem,cEndVazio,"",.F.})	
						AADD(aColsAux,{DUD->(Recno()),""})				
					EndIf	
					dbSkip()
				EndDo		
			Endif		
		EndIf	
			
			
		dbSelectArea("DUD")
	EndIf
	dbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela para visualizacao das informacoes      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCols) > 0
	AADD(aObjects,{100,100,.T.,.T.,.F.})
	aPosObj:=MsObjSize(aInfo,aObjects)
	DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]
		oGet := MSGetDados():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],nOpcE,"AllwaysTrue","TMSA590TOK","",.F.,,,,nTamMax) // Aumentado numero maximo de linhas na GetDados
		oGet:oBrowse:aAlter := {"DB_LOCALIZ"}
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| IIF(oGet:TudoOk(),(nOpca:=1,oDlg:End()),)},{||oDlg:End()},,aButtons))		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Confirma Enderecamento / Estorno do Enderecamento       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpca == 1
		Processa({|lEnd| TMA590Grv(.F.,nPosCod,nPosArmazem,nPosEndereco,nPosNumSeq,nPosDoc,nPosSerie,nPosCli,nPosLoja,nPosQuant)},STR0006,STR0007,.F.) //"Enderecando Documentos"###"Aguarde Processamento"
	EndIf
Else
	HELP(" ",1,"RECNO") //"Nao existem registros no arquivo em pauta"
EndIf

RestArea( aAreaDUD )

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA590Dig³ Autor ³Rodrigo A Sartorio     ³ Data ³ 13/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Digita o endereco que sera sugerido para todos documentos  ³±±
±±³          ³ a serem enderecados.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aCols - Acols a ser preenchido com o endereco digitado.    ³±±
±±³          ³ nPosArmazem - Posicao do armazem no acols                  ³±±
±±³          ³ nPosEndereco- Posicao do endereco no acols                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA590                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA590Dig(aCols,nPosArmazem,nPosEndereco)

LOCAL nTam
LOCAL oDlg,nOpca:=0
LOCAL cArmazem :=Criavar("DB_LOCAL",.F.)
LOCAL cEndereco:=Criavar("DB_LOCALIZ",.F.)
LOCAL nTamArma:=Len(cArmazem)                      
LOCAL nTamEnd:=Len(cEndereco)                      
LOCAL cPictureAr:=PesqPict("SDB","DB_LOCAL",nTamArma)
LOCAL cPictureEnd:=PesqPict("SDB","DB_LOCALIZ",nTamEnd)
LOCAL cLabel:=RetTitle("DB_LOCAL")+" / "+RetTitle("DB_LOCALIZ")

DEFINE MSDIALOG oDlg TITLE STR0005 From 145,0 To 270,400 OF oMainWnd PIXEL	
	@ 10,15 TO 40,185 LABEL cLabel OF oDlg PIXEL
	@ 20,20 MSGET cArmazem  Picture cPictureAr  Valid NaoVazio(cArmazem) OF oDlg PIXEL
	@ 20,35 MSGET cEndereco Picture cPictureEnd Valid Tmsa590cad (cArmazem,cEndereco) OF oDlg PIXEL
	
	DEFINE SBUTTON FROM 50,131 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
	DEFINE SBUTTON FROM 50,158 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg

// Caso tenha digitado o endereco valido
If nOpca == 1
	For nTam:=1 to Len(aCols)
		// Muda enderecos relacionados ao armazem digitado
		If aCols[nTam,nPosArmazem] == cArmazem
			aCols[nTam,nPosEndereco]:=cEndereco	
		EndIf
	Next nTam
EndIf
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA590Grv³ Autor ³Rodrigo A Sartorio     ³ Data ³ 13/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava o enderecamento / estorno do enderecamento efetuado  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA590                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMA590Grv()

LOCAL aLinSDB:={},aCabSDA:={},cItem:=0,cTipo:=0,nRecno:=0,lOkRecno:=.T.
LOCAL nz:=0
LOCAL cTesEnt:= GetMV("MV_TESDR",,"") // Tes de Entrada
                
SF4->( DbSetOrder( 1 ) )
SF4->(MsSeek(xFilial('SF4') + cTesEnt, .F.)) 

PRIVATE lMsErroAuto	:=	.F.
dbSelectArea("SDA")
dbSetOrder(1)
dbSelectArea("SDB")
dbSetOrder(1)
ProcRegua(Len(aCols))
// Percorre o aCols verificando os enderecos destino
For nz:=1 to Len(aCols)
	IncProc()        
	
	If SF4->F4_ESTOQUE == "S"
		aLinSDB:={}
		aCabSDA:={}
		// Obtem informacoes do item a ser estornado e executa a distribuicao/estorno
		// de produtos.
		Aadd(aCabSDA,{'DA_PRODUTO',aCols[nz,nPosCod],Nil})
		Aadd(aCabSDA,{'DA_LOCAL',aCols[nz,nPosArmazem],Nil})
		Aadd(aCabSDA,{'DA_NUMSEQ',aCols[nz,nPosNumSeq],Nil})
		Aadd(aCabSDA,{'DA_DOC',aCols[nz,nPosDoc],Nil})
		Aadd(aCabSDA,{'DA_SERIE',aCols[nz,nPosSerie],Nil})
		// Estorno do enderecamento
		If lEstornoT590
			cTipo:="1"
			SDA->(dbSeek(xFilial("SDA")+aCols[nz,nPosCod]+aCols[nz,nPosArmazem]+aCols[nz,nPosNumSeq]+aCols[nz,nPosDoc]+aCols[nz,nPosSerie]+aCols[nz,nPosCli]+aCols[nz,nPosLoja]))
			SDB->(dbSeek(xFilial("SDB")+aCols[nz,nPosCod]+aCols[nz,nPosArmazem]+aCols[nz,nPosNumSeq]+aCols[nz,nPosDoc]+aCols[nz,nPosSerie]+aCols[nz,nPosCli]+aCols[nz,nPosLoja]))
			While !(SDB->(Eof())) .And.  SDB->(DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA) == xFilial("SDB")+aCols[nz,nPosCod]+aCols[nz,nPosArmazem]+aCols[nz,nPosNumSeq]+aCols[nz,nPosDoc]+aCols[nz,nPosSerie]+aCols[nz,nPosCli]+aCols[nz,nPosLoja]
				aLinSDB:={}
				// Ignora itens ja estornados
				If SDB->DB_ESTORNO <> "S"
					nRecno:=SDB->(Recno())
					cItem:=SDB->DB_ITEM
					Aadd(aLinSDB,{'DB_PRODUTO',aCols[nz,nPosCod],NIL})
					Aadd(aLinSDB,{'DB_LOCAL',aCols[nz,nPosArmazem],NIL})
					Aadd(aLinSDB,{'DB_NUMSEQ',aCols[nz,nPosNumSeq],NIL})
					Aadd(aLinSDB,{'DB_DOC',aCols[nz,nPosDoc],NIL})				
					Aadd(aLinSDB,{'DB_SERIE',aCols[nz,nPosSerie],NIL})				
					Aadd(aLinSDB,{'DB_CLIFOR',aCols[nz,nPosCli],NIL})				
					Aadd(aLinSDB,{'DB_LOJA',aCols[nz,nPosLoja],NIL})								
					Aadd(aLinSDB,{'DB_ITEM',cItem,NIL})												
					Aadd(aLinSDB,{'DB_ESTORNO','S',NIL})																
					MATA265(aCabSDA,{aLinSDB},4)
					SDB->(dbGoto(nRecno))
				EndIf
				SDB->(dbSkip())
				If lMsErroAuto
					MostraErro()
					// Caso tenha ocorrido erro em algum enderecamento abandona o laco
					Exit	
				EndIf
			EndDo
		// Enderecamento
		Else
			cTipo:="2"
			SDB->(dbSeek(xFilial("SDB")+aCols[nz,nPosCod]+aCols[nz,nPosArmazem]+aCols[nz,nPosNumSeq]+aCols[nz,nPosDoc]+aCols[nz,nPosSerie]+aCols[nz,nPosCli]+aCols[nz,nPosLoja]+"zz",.T.))
		   SDB->(dbSkip(-1))
			If SDB->(DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA) == xFilial("SDB")+aCols[nz,nPosCod]+aCols[nz,nPosArmazem]+aCols[nz,nPosNumSeq]+aCols[nz,nPosDoc]+aCols[nz,nPosSerie]+aCols[nz,nPosCli]+aCols[nz,nPosLoja]
				cItem:=StrZero(Val(SDB->DB_ITEM)+1,Len(SDB->DB_ITEM))
			Else
				cItem:=StrZero(1,Len(SDB->DB_ITEM))	
			EndIf
			Aadd(aLinSDB,{'DB_ITEM',cItem,NIL})
			Aadd(aLinSDB,{'DB_LOCAL',aCols[nz,nPosArmazem],NIL})
			Aadd(aLinSDB,{'DB_LOCALIZ',aCols[nz,nPosEndereco],NIL})
			Aadd(aLinSDB,{'DB_QUANT',aCols[nz,nPosQuant],NIL})
			Aadd(aLinSDB,{'DB_DATA',dDataBase,NIL})
			Aadd(aLinSDB,{'DB_PRODUTO',aCols[nz,nPosCod],NIL})
			Mata265(aCabSDA,{aLinSDB},3)
		EndIf                          					
		//-- Se houve problemas na distribuicao de produtos, apresenta o motivo do erro
		If lMsErroAuto
			MostraErro()
			// Caso tenha ocorrido erro em algum enderecamento abandona o laco
			Exit	
		Else
			// Marca no array auxiliar documento como OK ref a enderecamento
			aColsAux[nz,2]:="OK"
		EndIf 		
	Else                             
		// Estorno do enderecamento
		If lEstornoT590
			cTipo:="1"	
	      DUH->(dbSetOrder(1))
			If DUH->( MsSeek( cSeek := xFilial("DUH")+cFilAnt+aCols[nz,nPosDoc]+aCols[nz,nPosSerie]+aCols[nz,nPosCli]+aCols[nz,nPosLoja] ))  		
			   RecLock('DUH',.F.)
			   dbDelete()
				MsUnlock()			  
			EndIf	
		Else
			cTipo:="2"	
	      DUH->(dbSetOrder(1))
			If !DUH->( MsSeek( cSeek := xFilial("DUH")+cFilAnt+aCols[nz,nPosDoc]+aCols[nz,nPosSerie]+aCols[nz,nPosCli]+aCols[nz,nPosLoja] )) 		
			   RecLock('DUH',.T.)
				DUH->DUH_FILIAL := xFilial('DUH')
				DUH->DUH_CLIREM := aCols[nz,nPosCli]
				DUH->DUH_LOJREM := aCols[nz,nPosLoja]
				DUH->DUH_FILORI := cFilAnt
				DUH->DUH_NUMNFC := aCols[nz,nPosDoc]			
				DUH->DUH_SERNFC := aCols[nz,nPosSerie]       
				DUH->DUH_QTDVOL := aCols[nz,nPosQuant]
				DUH->DUH_LOCAL  := aCols[nz,nPosArmazem]
				DUH->DUH_LOCALI := aCols[nz,nPosEndereco]
				If (DUH->(FieldPos('DUH_CODPRO'))>0)   
					DUH->DUH_CODPRO := aCols[nz,nPosCod]   
				EndIf	
				DUH->DUH_STATUS := "1"
				MsUnlock()			  
			EndIf								
		EndIf	
		// Marca no array auxiliar documento como OK ref a enderecamento
		aColsAux[nz,2]:="OK"			
		
	EndIf	
		
Next nz

// Verifica todos documentos do DUD antes de gravar o flag como ENDERECADO / ESTORNADO
nz:=1
While nz <= Len(aColsAux)
	nRecno:=aColsAux[nz,1]
	lOkRecno:=.T.
	While nz <= Len(aColsAux) .And. nRecno == aColsAux[nz,1]
		If aColsAux[nz,2] <> "OK"
			lOkRecno:=.F.		
		EndIf
		nz++
	End
	// Caso todos os registros estejam OK grava o flag no campo DUD_ENDERE
	If lOkRecno
		DUD->(dbGoto(nRecno))
    	Reclock("DUD",.F.)
		Replace DUD_ENDERE With cTipo
		MsUnlock()
	EndIf
EndDo
	
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA590TOK³ Autor ³Rodrigo A Sartorio     ³ Data ³ 13/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a getdados utilizada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA590                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA590TOK()

Local nTam:=0
Local lRet:=.T.
Local cTexto:=""
// Validacao quando efetua enderecamento
For nTam:=1 to Len(aCols)
	// Muda enderecos relacionados ao armazem digitado
	If Empty(aCols[nTam,nPosEndereco])
		cTexto:=aCols[nTam,nPosDoc]+" / "+aCols[nTam,nPosSerie]
		Help (" ",1,"TMSA59001",,cTexto,3,1) //"Nao Enderecado"
		lRet:=.F.	
	EndIf
	If !lRet
		Exit	
	EndIf
Next nTam

RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA590CAD³ Autor ³Patricia A. Salomao   ³ Data ³18.02.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria automaticamente o Endereco informado, se o mesmo nao   ³±±
±±³          ³existir.Nao permite que o mesmo Endereco seja utilizado para³±±
±±³          ³Filiais Destino Diferentes.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA590CAD(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Local                                              ³±±
±±³          ³ ExpC2 - Endereco                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function Tmsa590Cad(cLocal, cLocaliz)

Local lRet 		   := .T.

Default cLocal     := ""
Default cLocaliz   := ""

SBE->(dbSetOrder(1))
If !SBE->(MsSeek(xFilial("SBE")+ cLocal + cLocaliz ) )
	If !Empty(cLocaliz) .And. MsgYesNo(STR0011) //"O Local/Endereco informado nao esta cadastrado. Deseja Cadastrar ?"
		RegToMemory('SBE',.T.)
		M->BE_LOCAL   := cLocal
		M->BE_LOCALIZ := cLocaliz
		AxIncluiAuto("SBE",,,3,SBE->(Recno()) )
		RecLock("SBE", .F.)
		SBE->BE_DATGER := dDataBase
		SBE->BE_HORGER := Left(StrTran(Time(),":",""),4)
		SBE->(MsUnLock())
	Else
		Return ( .F. )
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tmsa590All³ Autor ³ Patricia A. Salomao   ³ Data ³01.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca / Desmarca todos os registros.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa590All(ExpL1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Controla se Marca/Desmarca todos os registros      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function Tmsa590All(lAllMark)

If lAllMark
	ResetInvert()
Else
	SetInvert()
EndIf
lAllMark := !lAllMark

MarkBRefresh()

Return nil
