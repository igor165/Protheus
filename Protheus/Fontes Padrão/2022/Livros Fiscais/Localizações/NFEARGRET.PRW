#INCLUDE "PROTHEUS.CH"
#INCLUDE "NFEARGRE.CH"

#DEFINE CGETFILE_TYPE GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNFEARGRET บAutor  ณMarcello            บFecha ณ 02/06/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa os arquivos de resposta enviado pela AFIP para a  บฑฑ
ฑฑบ          ณ emissao de faturas eletronicas.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ NFEARG - Faturas Eletronicas - Argentina                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function NfeArgRet()
Local aPaginas := {}
Local aTitulos := {}
Local oBtnProc, oBtnSai

Private oArq, cArq := Space(200)
Private oFolder, oRecus, aRecus := {Array(9)}, oAprov, aAprov := {Array(10)}
Private oFtArialB
Private oDlg
Private oImpFat

DEFINE FONT oFtArialB NAME "Arial" SIZE 0, -13 BOLD

aPaginas := {"RECUSADAS","APROVADAS"}
aTitulos := {STR0001,STR0002} //"Recusadas"###"Aprovadas"
DEFINE MSDIALOG oDlg TITLE STR0003 + " - " + STR0004 FROM 000,000 TO 600,800 PIXEL OF oMainWnd //"Faturas Eletronicas"###"Recepcao de Arquivos"
	@05,05 SAY STR0005 FONT oFtArialB PIXEL OF oDlg //"Arquivo de resposta:"
	@15,05 MSGET oArq VAR cArq SIZE 270,08 PIXEL OF oDlg
	DEFINE SBUTTON oBtnProc FROM 013,279 TYPE 1 ACTION NfeArgMt(cArq) ENABLE PIXEL OF oDlg
		oBtnProc:cToolTip:=STR0033 //"Processar Arquivo"
	DEFINE SBUTTON FROM 013,309 TYPE 14 ACTION NfeArgArq() ENABLE  PIXEL OF oDlg
	DEFINE SBUTTON oBtnSai FROM 013,339 TYPE 2 ACTION (oDlg:End()) ENABLE PIXEL OF oDlg
		oBtnSai:cToolTip:=STR0034 //"Sair"
	DEFINE SBUTTON oImpFat FROM 013,369 TYPE 6 ACTION (NfeArgImp()) DISABLE PIXEL OF oDlg
	oFolder := TFolder():New(030,005,aTitulos,aPaginas,oDlg,,,,.T.,.F.,390,265)
		oRecus := TWBrowse():New(005,005,380,240,,{STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012},{30,30,,20,35,35},oFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Item"###"Pto Venda"###"Fatura"###"Serie"###"Data"###"Data Rec"###"Motivo"
			oRecus:SetArray(aRecus)
			oRecus:bLine:={|| If(Len(aRecus)>0,{"",aRecus[oRecus:nAt,1],aRecus[oRecus:nAt,2],aRecus[oRecus:nAt,3],aRecus[oRecus:nAt,4],aRecus[oRecus:nAt,5],aRecus[oRecus:nAt,6]},{})}
		oAprov := TWBrowse():New(005,005,380,240,,{STR0006,STR0007,STR0008,STR0009,STR0010,STR0013,STR0014,STR0012},{30,30,,20,35,50,35},oFolder:aDialogs[2],,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Item"###"Pto Venda"###"Fatura"###"Serie"###"Data"###"CAE"###"Vcto.CAE"###"Motivo"
			oAprov:SetArray(aAprov)
			oAprov:bLine:={|| If(Len(aAprov)>0,{"",aAprov[oAprov:nAt,1],aAprov[oAprov:nAt,2],aAprov[oAprov:nAt,3],aAprov[oAprov:nAt,4],aAprov[oAprov:nAt,5],aAprov[oAprov:nAt,6],aAprov[oAprov:nAt,7]},{})}
ACTIVATE MSDIALOG oDlg CENTERED
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNFEARGARQ บAutor  ณMarcello            บFecha ณ 02/06/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ativa o seletor de arquivos                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ NFEARG - Faturas Eletronicas - Argentina                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NfeArgArq()
Local cArquivo

cArquivo := cGetFile(STR0032,STR0015,0,"C:\",.T.,CGETFILE_TYPE) //"Texto (*.txt) |*.TXT|Todos (*.*) |*.*|"###"Seleciona Arquivo"
If !Empty(cArquivo)
	cArq := cArquivo
	oArq:Refresh()
	oImpFat:lActive := .F.
	/*_*/
	aAProv := {}
	oAprov:SetArray(aAProv)
	oAprov:bLine:={|| If(Len(aAprov)>0,{"",aAprov[oAprov:nAt,1],aAprov[oAprov:nAt,2],aAprov[oAprov:nAt,3],aAprov[oAprov:nAt,4],aAprov[oAprov:nAt,5],aAprov[oAprov:nAt,6],aAprov[oAprov:nAt,7]},{})}
	oAprov:Refresh()
	/**/
	aRecus := {}
	oRecus:SetArray(aRecus)
	oRecus:bLine:={|| If(Len(aRecus)>0,{"",aRecus[oRecus:nAt,1],aRecus[oRecus:nAt,2],aRecus[oRecus:nAt,3],aRecus[oRecus:nAt,4],aRecus[oRecus:nAt,5],aRecus[oRecus:nAt,6]},{})}
	oRecus:Refresh()
Endif
oArq:SetFocus()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNFEARGMT  บAutor  ณMarcello            บFecha ณ 06/06/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe a barra de progresso e executa a rotina de processa- บฑฑ
ฑฑบ          ณ mento do arquivo texto.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ NFEARG - Faturas Eletronicas - Argentina                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NfeArgMt(cArqTxt)
Private oDlgMt,oMeter
Private oSMeter

If !Empty(cArqTxt)
	DEFINE MSDIALOG oDlgMt TITLE STR0004 FROM 000,000 TO 160,323 PIXEL OF oDlg //"Recepcao de Arquivos"
	@10,05 Say STR0016 FONT oFtArialB PIXEL OF oDlgMt //"Aguarde o processamento do arquivo."
	@50,05 SAY oSMeter VAR STR0017 FONT oFtArialB PIXEL OF oDlgMt //"Aguarde"
	oMeter:=TMeter():New(60,05,,100,oDlgMt,150,10,,.T.,oFtArialB,STR0018,.T.,,,GetSysColor(13),GetSysColor(),.F.) //"Registros AFIP"
	oMeter:Set(0)
	ACTIVATE MSDIALOG oDlgMt CENTERED ON INIT NfeArgProc(cArqTxt)
Else
	oArq:SetFocus()
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNFEARGPROCบAutor  ณMarcello            บFecha ณ 05/06/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ativa o seletor de arquivos                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ NFEARG - Faturas Eletronicas - Argentina                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NfeArgProc(cArqTxt)
Local lRet 		:= .T.
Local lEncNota 	:= .F.
Local nReg 		:= 0
Local nNrReg 	:= 0
Local nMot		:= 0
Local nG 		:= 0
Local nX		:= 0
Local aRegistro := ""
Local cNFiscal 	:= ""
Local cSerie	:= ""
Local cNota 	:= ""
Local cFilSF 	:= ""
Local cEspec 	:= ""
Local cCodM		:= ""
Local cDescr 	:= ""
Local cPtoVenda := ""

aAprov := {}
aRecus := {}

SF1->(DbSetOrder(1))
SF2->(DbSetOrder(1))
SF3->(DbSetOrder(6))
SA1->(DbSetOrder(1))
SA2->(DbSetOrder(1))
If File(cArqTxt)
	FT_FUse(cArqTxt)
	FT_FGotop()
	nNrReg := FT_FLastRec()
	If nNrReg > 0
		oMeter:Set(0)
		oMeter:nTotal := nNrReg
		nReg := 0
		oMeter:Show()
		While !(FT_FEof())
			aRegistro := LeReg()
			If !Empty(aRegistro)
				If aRegistro[1] == 2 .Or. aRegistro[1] == 4
					cNota := aRegistro[5]
					nNotas := Val(aRegistro[6]) - Val(aRegistro[5]) + 1
					For nG := 1 to nNotas
						Do Case
							//Aprobacion
							Case aRegistro[1] == 2
								cNFiscal := aRegistro[4] + cNota
								cSerie := If(aRegistro[03]$"01,02,03","A","B")
								cPtoVenda := Substr(cNFiscal,1,4)
								If ExistBlock('NFEARGR1')
									cSerie := ExecBlock('NFEARGR1',.F.,.F.,{aRegistro[03],cSerie,cPtoVenda})
								Endif
								cSerie := Padr(cSerie,TamSX3("F1_SERIE")[1])
								If aRegistro[3] == "03" .Or. aRegistro[3] == "08"
									cFilSF := xFilial("SF1")
									lEncNota := .F.
									If SF1->(DbSeek(cFilSF+cNFiscal+cSerie))
										While !lEncNota .And. SF1->F1_FILIAL == cFilSF .And. SF1->F1_DOC == cNFiscal .And. SF1->F1_SERIE == cSerie
											cEspec := AllTrim(SF1->F1_ESPECIE)
											If cEspec $ "NCC,NCI"
												If Empty(SF1->F1_CAE) .And. Empty(SF1->F1_VCTOCAE)
													lEncNota := .T.
													RecLock("SF1",.F.)
													Replace SF1->F1_CAE 	With aRegistro[10]
													Replace SF1->F1_VCTOCAE	With aRegistro[11]
													Replace SF1->F1_MOTIVO	With aRegistro[12]
													SF1->(MsUnLock())
												Else
													Aadd(aRecus,{aRegistro[04],cNota,cSerie,aRegistro[02],aRegistro[11],STR0035}) //"La factura ya tiene asignado su numero de CAE y/o la fecha de CAE"													
												 	SF1->(DbSkip())
												Endif
											Endif
											SF1->(DbSkip())
										Enddo
									Endif
									If lEncNota
										cFilSF := xFilial("SF3")
										If SF3->(DbSeek(cFilSF+cNFiscal+cSerie))
											RecLock("SF3",.F.)
											Replace SF3->F3_CAE 	With aRegistro[10]
											Replace SF3->F3_VCTOCAE	With aRegistro[11]
											SF3->(MsUnLock())
										Endif
	                                Endif
								Else
									cFilSF := xFilial("SF2")
									lEncNota := .F.
								
										If SF2->(DbSeek(xFilial("SF2")+cNFiscal+cSerie))
											While !lEncNota .And. SF2->F2_FILIAL == cFilSF .And. SF2->F2_DOC == cNFiscal .And. SF2->F2_SERIE == cSerie
												cEspec := AllTrim(SF2->F2_ESPECIE)
												If cEspec $ "NDI,NDC,NF"
													If Empty(SF2->F2_CAE) .And. Empty(SF2->F2_VCTOCAE)
														lEncNota := .T.
														RecLock("SF2",.F.)
														Replace SF2->F2_CAE 	With aRegistro[10]
														Replace SF2->F2_VCTOCAE	With aRegistro[11]
														Replace SF2->F2_MOTIVO	With aRegistro[12]
														SF2->(MsUnLock())
													Else
														Aadd(aRecus,{aRegistro[04],cNota,cSerie,aRegistro[02],aRegistro[11],STR0035})	 //"La factura ya tiene asignado su numero de CAE y/o la fecha de CAE"												
													 	SF2->(DbSkip())
													Endif
												Endif
											Enddo
											SF2->(DbSkip())
										Else
											Aadd(aRecus,{aRegistro[04],cNota,cSerie,aRegistro[02],aRegistro[11],STR0037}) //"No se encontro un registro SF2 corespondente"
										Endif
							
									If lEncNota
										cFilSF := xFilial("SF3")
										
										If SF3->(DbSeek(cFilSF+cNFiscal+cSerie))
											RecLock("SF3",.F.)
											Replace SF3->F3_CAE 	With aRegistro[10]
											Replace SF3->F3_VCTOCAE	With aRegistro[11]
											SF3->(MsUnLock())
										Endif
	                                Endif								
								Endif
								If lEncNota
									//Verifico e monto o array com os motivos aprobacion para imprimir depois.  
									//No arquivo de retorno o tamanho maximo para os motivos e 8, ou seja 3 motivos: xx;xx;xx
									Iif(Len(Alltrim(aRegistro[12]))>=8,nCont:=3,Iif(Len(Alltrim(aRegistro[12]))<=3,nCont:=1,nCont:=2))
									For nX := 1 to nCont
										nMot	:= Iif(nX==1,1, nMot+3)
										cCodM	:= Subst(aRegistro[12],nMot,2)
										cDescr 	:= PesqMotivo(cCodM)
										Aadd(aAprov,{aRegistro[04],cNota,cSerie,aRegistro[02],aRegistro[10],aRegistro[11],cDescr})
									Next
								Endif
								//Rechazo
							Case aRegistro[1] == 4
								//Verifico e monto o array com os motivos rechazo para imprimir depois.  
								//No arquivo de retorno o tamanho maximo para os motivos e 11, ou seja 4 motivos: xx;xx;xx;xx
								Iif(Len(Alltrim(aRegistro[12]))>=11,nCont:=4,Iif(Len(Alltrim(aRegistro[12]))<=3,nCont:=1,Iif(Len(Alltrim(aRegistro[12]))<=6,nCont:=2,nCont:=3)))								
								For nX := 1 to nCont
									nMot	:= Iif(nX==1,1, nMot+3)
									cCodM	:= Subst(aRegistro[12],nMot,2)
									cDescr 	:= PesqMotivo(cCodM)								
									Aadd(aRecus,{aRegistro[04],cNota,cSerie,aRegistro[02],aRegistro[11],cDescr})							
								Next
						EndCase
						oSMeter:cCaption := aRegistro[4] + cNota + "/" + cSerie
						oSMeter:Refresh()
						cNota := Soma1(cNota)
					Next
				Endif
			Endif
			nReg++
			oMeter:Set(nReg)
			FT_FSkip()
		Enddo
		oMeter:Hide()
	Else
		lRet := .F.
	Endif
	FT_FUse()
Else
	lRet := .F.
Endif
oDlgMt:End()
aAprov := ASort(aAprov,,,{|x,y| (x[3] + x[2]) < (y[3] + y[2])})
aRecus := ASort(aRecus,,,{|x,y| (x[3] + x[2]) < (y[3] + y[2])})
oRecus:SetArray(aRecus)
oRecus:bLine:={|| If(Len(aRecus)>0,{StrZero(oRecus:nAt,4),aRecus[oRecus:nAt,1],aRecus[oRecus:nAt,2],aRecus[oRecus:nAt,3],aRecus[oRecus:nAt,4],aRecus[oRecus:nAt,5],aRecus[oRecus:nAt,6]},{})}
oRecus:Refresh()
/*_*/
oAprov:SetArray(aAProv)
oAprov:bLine:={|| If(Len(aAprov)>0,{StrZero(oAProv:nAt,4),aAprov[oAprov:nAt,1],aAprov[oAprov:nAt,2],aAprov[oAprov:nAt,3],aAprov[oAprov:nAt,4],aAprov[oAprov:nAt,5],aAprov[oAprov:nAt,6],aAprov[oAprov:nAt,7]},{})}
oAprov:Refresh()
/*_*/
If !Empty(aAprov) .Or. !Empty(aRecus)
	oImpFat:lActive := .T.
	If Empty(aRecus)
		oFolder:nOption := 2
		oAprov:SetFocus()
	Else
		oFolder:nOption := 1
		oRecus:SetFocus()
	Endif
Else
	oImpFat:lActive := .F.
	oArq:SetFocus()
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLEREG     บAutor  ณMarcello            บFecha ณ 05/06/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ativa o seletor de arquivos                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ NFEARG - Faturas Eletronicas - Argentina                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LeReg()
Local aRet := {}
Local cReg := ""
Local cAux := ""
Local nTipoReg := 0

cReg := FT_FReadLn()
If !Empty(cReg)
	nTipoReg := Val(Substr(cReg,1,1))
	If nTipoReg > 0
		//01 Tipo de registro
		Aadd(aRet,nTipoReg)
		Do Case
			Case nTipoReg == 1
				//02 CUIT
				Aadd(aRet,Substr(cReg,2,11))
				//02 Solicitud
				Aadd(aRet,Substr(cReg,13,2))
				//03 Fecha presentacion
				cAux := Substr(cReg,15,8)
				cAux := Right(cAux,2) + "/" + Substr(cAux,5,2) + "/" + Left(cAux,4)
				Aadd(aRet,Ctod(cAux))
				//10 Cantidad de registros
				cAux := Substr(cReg,57,6)
				Aadd(aRet,Val(cAux))
			Case nTipoReg == 2
				//02 Fecha
				cAux := Substr(cReg,2,8)
				cAux := Right(cAux,2) + "/" + Substr(cAux,5,2) + "/" + Left(cAux,4)
				Aadd(aRet,Ctod(cAux))
				//03 Tipo Comprobante
				Aadd(aRet,Substr(cReg,10,2))
				//04 Punto de Venta
				Aadd(aRet,Substr(cReg,12,4))
				//05 Comprobante (desde)
				Aadd(aRet,Substr(cReg,16,8))
				//06 Comprobante (hasta)
				Aadd(aRet,Substr(cReg,24,8))
				//07 Tipo doc id
				Aadd(aRet,Substr(cReg,32,2))
				//08 Doc Id
				Aadd(aRet,Substr(cReg,34,11))
				//09 Resultado
				Aadd(aRet,Substr(cReg,135,1))
				//10 CAE
				Aadd(aRet,Substr(cReg,136,14))
				//11 Fecha Vencimiento
				cAux := Substr(cReg,150,8)
				cAux := Right(cAux,2) + "/" + Substr(cAux,5,2) + "/" + Left(cAux,4)
				Aadd(aRet,Ctod(cAux))
				//12 Motivo
				Aadd(aRet,Substr(cReg,158,8))
			Case nTipoReg == 3
				//Cantidad de registros tipo dois
				cAux := Substr(cReg,39,6)
				Aadd(aRet,Val(cAux))
			Case nTipoReg == 4
				//02 Fecha
				cAux := Substr(cReg,2,8)
				cAux := Right(cAux,2) + "/" + Substr(cAux,5,2) + "/" + Left(cAux,4)
				Aadd(aRet,Ctod(cAux))
				//03 Tipo Comprobante
				Aadd(aRet,Substr(cReg,10,2))
				//04 Punto de Venta
				Aadd(aRet,Substr(cReg,12,4))
				//05 Comprobante (desde)
				Aadd(aRet,Substr(cReg,16,8))
				//06 Comprobante (hasta)
				Aadd(aRet,Substr(cReg,24,8))
				//07 Tipo doc id
				Aadd(aRet,Substr(cReg,32,2))
				//08 Doc Id
				Aadd(aRet,Substr(cReg,34,11))
				//09 Resultado
				Aadd(aRet,Substr(cReg,135,1))
				//10 Relleno - compatibilizar con tipo dos
				Aadd(aRet,"")
				//11 Fecha rechazo
				cAux := Substr(cReg,136,8)
				cAux := Right(cAux,2) + "/" + Substr(cAux,5,2) + "/" + Left(cAux,4)
				Aadd(aRet,Ctod(cAux))
				//12 Motivo
				Aadd(aRet,Substr(cReg,144,11))
			Case nTipoReg == 5
				//Cantidad de registros tipo 4
				cAux := Substr(cReg,39,6)
				Aadd(aRet,Val(cAux))
		EndCase
	Endif
Endif
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNFEARGIMP บAutor  ณMarcello            บFecha ณ 07/06/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa a rotina de impressao do resultado                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ NFEARG - Faturas Eletronicas - Argentina                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NfeArgImp()
Local oDlgImp

Private oIRecus, lIRecus := .F., oIAProv, lIAprov := .F.

lIAprov := (Len(aAprov) > 0  .And. Len(aRecus) == 0)
lIRecus := (Len(aAprov) == 0 .And. Len(aRecus) >  0)
DEFINE MSDIALOG oDlgImp TITLE STR0003 + " - " + STR0019 FROM 000,000 TO 200,323 PIXEL OF oDlg //"Faturas Eletronicas"###"Impressao do resultado"
@10,05 CHECKBOX oIRecus VAR lIRecus PROMPT STR0020 SIZE 150,10 FONT oFtArialB PIXEL OF oDlgImp //"Faturas Recusadas"
oIRecus:lActive := (Len(aRecus) > 0) .And. (Len(aAprov) > 0)
@30,05 CHECKBOX oIAprov VAR lIAprov PROMPT STR0021 SIZE 150,10 FONT oFtArialB PIXEL OF oDlgImp //"Faturas Aprovadas"
oIAprov:lActive := (Len(aAprov) > 0) .And. (Len(aRecus) > 0)
DEFINE SBUTTON FROM 085,100 TYPE 1 ACTION (NfeArgIRes(),oDLgImp:End()) ENABLE PIXEL OF oDlgImp
DEFINE SBUTTON FROM 085,130 TYPE 2 ACTION (oDlgImp:End()) ENABLE PIXEL OF oDlgImp
ACTIVATE MSDIALOG oDlgImp CENTERED
oArq:SetFocus()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNFEARGIRESบAutor  ณMarcello            บFecha ณ 07/06/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime o resultado do arquivo texto                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ NFEARG - Faturas Eletronicas - Argentina                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NfeArgIRes()

lEnd    := .F.
cDesc1  := STR0022 //"Imprime relatorio com as facturas aprovadas e recusadas."
cDesc2  := ""
cDesc3  := ""
cString := "SF3"
cabec1  := ""
cabec2  := ""
aLinha  := {}
aReturn := {STR0023,1,STR0024,1,2,1,"",1} //"Zebrado"###"Administracao"
nJuros  := 0
nLastKey:= 0
nomeprog:= "NFEARG"
limite  :=  132
tamanho := "M"
Titulo  := STR0003 + " - " + STR0025 //"Faturas Eletronicas"###"Resultado solicitacao CAE"
wnrel :="NFEARG"
wnrel :=SetPrint(cString,wnrel,,Titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,tamanho,,.F.)
If nLastKey != 27
	SetDefault(aReturn,cString)
	If nLastKey != 27
		If lIRecus
			RptStatus({|lEnd| NfeArgRec(@lEnd)})
		Endif
		If lIAprov
			RptStatus({|lEnd| NfeArgApr(@lEnd)})
		Endif
		If aReturn[5] == 1
			Set Printer To
			dbCommitAll()
			Ourspool(wnrel)
		Endif
		MS_FLUSH()
	Endif
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNFEARGREC บAutor  ณMarcello            บFecha ณ 07/06/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime o resultado do arquivo texto - faturas recusadas   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ NFEARG - Faturas Eletronicas - Argentina                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NfeArgRec(lEnd)
Local nI 		:= 0
Local nLin 		:= 80
Local nItem		:= 0
Local cTexto 	:= ""
Local cSerie 	:= ""

/*
Recusadas
Item  Fatura             Data       Data Rec.   Motivo Rec.
0     06                24          36          48
1234  123412345678/123  12/12/1234  12/12/1234  12345678901234567890123456789012345678901234567
*/

Titulo := STR0003 + " - " + STR0026 //"Faturas Eletronicas"###"Relacao de Faturas Recusadas"
cabec1 := STR0027 //"Item  Fatura             Data       Data Rec.   Motivo Rec."
m_pag := 1
nI := 0
nItem := 0
nFim := Len(aRecus)
SetRegua(nFim)
cSerie := aRecus[1,3]
While nI < nFim .And. !lEnd
	nI++
	If nLin >55
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
		nLin := PRow() + 1
		cSerie := aRecus[nI,03]
	Endif
	If cSerie <> aRecus[nI,03] 
		If nItem > 0
			cTexto := STR0028 + AllTrim(cSerie) + ": " + Str(nItem,4) //" Itens de serie "
			ctexto := Padl(cTexto,limite,"-")
			@nLin,000 PSay cTexto
			nItem := 0
			nLin++
		Endif
		nLin++
		cSerie := aRecus[nI,03]
	Endif
	@nLin,000 PSay StrZero(nI,4)
	@nLin,006 PSay aRecus[nI,01] + aRecus[nI,02] + "/" + aRecus[nI,03]
	@nLin,024 PSay aRecus[nI,04]
	@nLin,036 PSay aRecus[nI,05]
	@nLin,048 PSay aRecus[nI,06]
	nLin++
	nItem++
	IncRegua()
	If lEnd
		nI := nFim
		@nLin+2,000 PSay STR0029 //"IMPRESSAO CANCELADA PELO USUARIO."
	Endif
Enddo
If nItem > 0 .And. !lEnd
	cTexto := STR0028 + AllTrim(cSerie) + ": " + Str(nItem,4) //" Itens de serie "
	ctexto := Padl(cTexto,limite,"-")
	@nLin,000 PSay cTexto
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNFEARGAPR บAutor  ณMarcello            บFecha ณ 07/06/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime o resultado do arquivo texto - faturas recusadas   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ NFEARG - Faturas Eletronicas - Argentina                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NfeArgApr(lEnd)
Local nI 		:= 0
Local nLin 		:= 80
Local nFim 		:= 0
Local nItem 	:= 0
Local cSerie 	:= ""
Local cTexto 	:= ""

/*
Aprovadas
Item  Fatura              Data      Vcto CAE    CAE             Motivo
00    06                24          36          48              64
1234  123412345678/123  12/12/1234  12/12/1234  12345678901234  12345678901234567890123456789012345678901234567890123456789012345678
*/

Titulo := STR0003 + " - " + STR0030 //"Faturas Eletronicas"###"Relacao de Faturas Aprovadas"
cabec1 := STR0031 //"Item  Fatura              Data      Vcto CAE    CAE             Motivo"
m_pag := 1
nI := 0
nItem := 0
nFim := Len(aAprov)
SetRegua(nFim)
cSerie := aAprov[1,3]
While nI < nFim .And. !lEnd
	nI++
	If nLin >55
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
		nLin := PRow() + 1
		cSerie := aAprov[nI,03]
	Endif
	If cSerie <> aAprov[nI,03] 
		If nItem > 0
			cTexto := STR0028 + AllTrim(cSerie) + ": " + Str(nItem,4) //" Itens de serie "
			ctexto := Padl(cTexto,limite,"-")
			@nLin,000 PSay cTexto
			nItem := 0
			nLin++
		Endif
		nLin++
		cSerie := aAprov[nI,03]
	Endif	
	@nLin,000 PSay StrZero(nI,4)
	@nLin,006 PSay aAprov[nI,01] + aAprov[nI,02] + "/" + aAprov[nI,03]
	@nLin,024 PSay aAprov[nI,04]
	@nLin,036 PSay aAprov[nI,06]
	@nLin,048 PSay aAprov[nI,05]
	@nLin,064 PSay aAprov[nI,07]
	nLin++
	nItem++
	IncRegua()                                                         
	
	If lEnd
		nI := nFim
		@nLin+2,000 PSay STR0029 //"* * * IMPRESSAO CANCELADA PELO USUARIO * * *"
	Endif
Enddo
If nItem > 0 .And. !lEnd
	cTexto := STR0028 + AllTrim(cSerie) + ": " + Str(nItem,4) //" Itens de serie "
	ctexto := Padl(cTexto,limite,"-")
	@nLin,000 PSay cTexto
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ PesqMotivo   ณAutor ณ Luciana Pires        ณDataณ 02/01/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Pesquisa no arquivo SX5 a descricao do motivo da aprovacao ณฑฑ 
ฑฑณ          ณ e/ou reprovacao do retorno da AFIP                         ณฑฑ 
ฑฑณ          ณ texto.                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PesqMotivo(cCod)                                              

Local cDescr   := ""
Local aAreaSX5 := {}
Local aAreaAtu := GetArea()

cCod := cCod+Space(TAMSX3("X5_CHAVE")[01]-Len(AllTrim(cCod)))

dbSelectArea("SX5")
aAreaSX5 := GetArea()
dbSetOrder(1)
If dbSeek(xFilial("SX5")+"MU"+cCod)
	cDescr := X5DESCRI()
Else
	cDescr := Alltrim(cCod)
EndIf
RestArea(aAreaSX5)
RestArea(aAreaAtu)

Return(cDescr)
