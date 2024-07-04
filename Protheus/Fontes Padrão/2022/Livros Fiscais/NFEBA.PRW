#Include "Protheus.Ch"
/*/                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³NFEBA     ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 01.12.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Nota Fiscal Eletronica - Bahia                              ³±±
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
Function NFEBA()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera arquivos temporarios ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GeraTemp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa os Registros Tipos 88-10 (Transportador) e 88-20 (Veiculos) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("R50")
dbGoTop()
While !Eof()
	If R50->A50_SITUAC <> "S"	//NF Cancelada
		dbSelectArea("SF2")
		dbSetOrder(1)
		If dbSeek(xFilial("SF2")+R50->A50_NFISC+R50->A50_SERIE+R50->A50_CLIFOR+R50->A50_LOJCF)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³88-10 - Dados do Transportador  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("X10")
			If !dbSeek(R50->A50_NFISC+R50->A50_SERIE)
				RecLock("X10",.T.)
				X10->SDOC	:= R50->A50_SDOC
				X10->SERIE	:= R50->A50_SERIE
				X10->NUMERO	:= R50->A50_NFISC
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Transportadora                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SA4")
				dbSetOrder(1)
				If dbSeek(xFilial("SA4")+SF2->F2_TRANSP)		
					X10->CNPJ_CPF	:= IIf(!Empty(SA4->A4_CGC),SA4->A4_CGC,Replicate("0",14))
					X10->IE			:= IIf(!Empty(SA4->A4_INSEST),SA4->A4_INSEST,Replicate("0",14))
					X10->NOME		:= SA4->A4_NOME
					X10->MUN		:= SA4->A4_MUN
					X10->UF			:= SA4->A4_EST
				Else
					X10->CNPJ_CPF	:= Replicate("0",14)
					X10->IE			:= Replicate("0",14)
				Endif
				X10->PESOBRU	:= SF2->F2_PBRUTO
				X10->PESOLIQ	:= SF2->F2_PLIQUI
				X10->FRETE		:= IIf(SF2->F2_FRETE>0,"1","0")	//1-CIF e 0-FOB
				MsUnlock()
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³88-20 - Dados do Veiculo        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("X20")
				RecLock("X20",.T.)
				X20->SDOC	:= R50->A50_SDOC
				X20->SERIE	:= R50->A50_SERIE
				X20->NUMERO	:= R50->A50_NFISC
				dbSelectArea("DA3")
				dbSetOrder(1)
				If dbSeek(xFilial("DA3")+SF2->F2_VEICUL1)
					X20->PLACA	:= StrTran(DA3->DA3_PLACA," ","")
					X20->UF  	:= DA3->DA3_ESTPLA
					X20->MUN	:= DA3->DA3_MUNPLA

					If dbSeek(xFilial("DA3")+SF2->F2_VEICUL2)
						X20->PLACA1	:= StrTran(DA3->DA3_PLACA," ","")
						X20->UF1	:= DA3->DA3_ESTPLA
						X20->MUN1	:= DA3->DA3_MUNPLA

						If dbSeek(xFilial("DA3")+SF2->F2_VEICUL3)
							X20->PLACA2	:= StrTran(DA3->DA3_PLACA," ","")
							X20->UF2	:= DA3->DA3_ESTPLA
							X20->MUN2	:= DA3->DA3_MUNPLA
						Endif
					Endif
				Endif
				MsUnlock()
			Endif
		Endif
	Endif
	dbSelectArea("R50")
	dbSkip()
Enddo

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTemp   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.12.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTemp()

Local aStru	:= {}
Local cArq	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 88-10 - Dados do Transportador                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aStru,{"SERIE"		,"C",TamSX3("F2_SERIE")[1],0})
AADD(aStru,{"NUMERO"	,"C",TamSX3("F2_DOC")[1],0})
AADD(aStru,{"CNPJ_CPF"	,"C",14,0})
AADD(aStru,{"IE"		,"C",14,0})
AADD(aStru,{"NOME"		,"C",35,0})
AADD(aStru,{"MUN"		,"C",30,0})
AADD(aStru,{"UF"		,"C",02,0})
AADD(aStru,{"PESOBRU"	,"N",TamSx3("F2_PBRUTO")[1],TamSx3("F2_PBRUTO")[2]})
AADD(aStru,{"PESOLIQ"	,"N",TamSx3("F2_PLIQUI")[1],TamSx3("F2_PLIQUI")[2]})
AADD(aStru,{"FRETE"		,"C",01,0})
AADD(aStru,{"SDOC"		,"C",03,0})

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"X10")
IndRegua("X10",cArq,"NUMERO+SERIE")
	
AADD(_aTotal[99],{cArq,"X10"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 88-20 - Dados do Veiculo                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"SERIE"		,"C",TamSX3("F2_SERIE")[1],0})
AADD(aStru,{"NUMERO"	,"C",TamSX3("F2_DOC")[1],0})
AADD(aStru,{"PLACA"		,"C",07,0})
AADD(aStru,{"UF"		,"C",02,0})
AADD(aStru,{"MUN"		,"C",30,0})
AADD(aStru,{"PLACA1"	,"C",07,0})
AADD(aStru,{"UF1"		,"C",02,0})
AADD(aStru,{"MUN1"		,"C",30,0})
AADD(aStru,{"PLACA2"	,"C",07,0})
AADD(aStru,{"UF2"		,"C",02,0})
AADD(aStru,{"MUN2"		,"C",30,0})
AADD(aStru,{"SDOC"		,"C",03,0})

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"X20")

AADD(_aTotal[99],{cArq,"X20"})

Return Nil
