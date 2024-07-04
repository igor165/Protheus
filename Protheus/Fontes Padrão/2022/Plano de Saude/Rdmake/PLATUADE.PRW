/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto     ³ PLATUADE   ³ Autor ³ Tulio Cesar          ³ Data ³ 15.10.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o  ³ Atualiza dados da adesao do subcontrato ou produto p a familia³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Advanced Protheus                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function PLATUADE()

If ! Pergunte("PLSPFM", .T.)
	Return
Endif         

If  ! msgyesno("Este programa ira copiar os valores de adesao do Subcontrato(PJ)/Produto(PF) para as familias")
    Return()
Endif    

MsAguarde({|| PlsAtuFam()}, "", "Migracao valor adesao para familia", .T.)

Return

Static Function PlsAtuFam
LOCAL cMes
LOCAL cAno
LOCAL cOpeDe
LOCAL cOpeAte
LOCAL cEmpDe
LOCAL cEmpAte
LOCAL cMatricDe
LOCAL cMatricAte
LOCAL cSQL
LOCAL aCriticas := {}

Pergunte("PLSPFM", .F.)

cMes      := mv_par01
cAno      := mv_par02
cOpeDe    := mv_par03
cOpeAte   := mv_par04
cEmpDe    := mv_par05
cEmpAte   := mv_par06
cMatricDe := mv_par07
cMatricAte:= mv_par08

cSQL := "SELECT R_E_C_N_O_ AS REG FROM "+RetSQLName("BA3")+" WHERE "
cSQL += "BA3_FILIAL = '"+xFilial("BA3")+"' AND "
cSQL += "BA3_CODINT >= '"+cOpeDe+"' AND BA3_CODINT <= '"+cOpeAte+"' AND "
cSQL += "BA3_CODEMP >= '"+cEmpDe+"' AND BA3_CODEMP <= '"+cEmpAte+"' AND "
cSQL += "BA3_MATRIC >= '"+cMatricDe+"' AND BA3_MATRIC <= '"+cMatricAte+"' AND "
cSQL += "D_E_L_E_T_ = ''"

PLSQuery(cSQL,"Trb")

While ! Trb->(Eof())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona na familia...                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BA3->(DbGoTo(Trb->REG))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mensagem informativa...                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsProcTXT("Analisando a familia "+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona na forma de cobranca do subcontrato ou produto...              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BA3->BA3_TIPOUS == "1"
		BJ9->(DbSetOrder(1))
		If ! BJ9->(DbSeek(xFilial("BJ9")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
			aadd(aCriticas,{"BJ9","Forma de adesao nao cadastrada para o produto ["+BA3->BA3_CODPLA+"]",BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)})
			Trb->(DbSkip())
			Loop
		Endif
	Else
		BTK->(DbSetOrder(1))
		If ! BTK->(DbSeek(xFilial("BTK")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO)))
			aadd(aCriticas,{"BTK","Forma de adesao nao cadastrada para o subcontrato ["+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_SUBCON)+"]",BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)})
			Trb->(DbSkip())
			Loop
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona na faixa etaria do subcontrato ou produto...                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BA3->BA3_TIPOUS == "1"
		BRY->(DbSetOrder(1))
		If ! BRY->(DbSeek(xFilial("BRX")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
			aadd(aCriticas,{"BRY","Faixa Etaria de adesao nao cadastrada para o produto ["+BA3->BA3_CODPLA+"]",BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)})
			Trb->(DbSkip())
			Loop
		Endif
	Else
		BR6->(DbSetOrder(1))
		If ! BR6->(DbSeek(xFilial("BR6")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA)))
			aadd(aCriticas,{"BR6","Faixa Etaria de adesao nao cadastrada para o subcontrato ["+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_SUBCON)+"]",BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)})
			Trb->(DbSkip())
			Loop
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se nao existe a forma de cobranca da adesao na familia...       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BJL->(DbSetOrder(1))
	If ! BJL->(Dbseek(xFilial("BJL")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
		BJL->(RecLock("BJL",.T.))
		BJL->BJL_FILIAL := xFilial("BJL")
		BJL->BJL_CODOPE := BA3->BA3_CODINT
		BJL->BJL_CODEMP := BA3->BA3_CODEMP
		BJL->BJL_MATRIC := BA3->BA3_MATRIC
		BJL->BJL_CODFOR := IF(BA3->BA3_TIPOUS=="1",BJ9->BJ9_CODFOR,BTK->BTK_CODFOR)
		BJL->(MsUnLock())
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclusao das faixas caso seja pessoa juridica...                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BA3->BA3_TIPOUS == "2"
		While ! BR6->(Eof()) .And. BR6->(BR6_FILIAL+BR6_CODIGO+BR6_NUMCON+BR6_VERCON+BR6_SUBCON+BR6_VERSUB+BR6_CODPRO) == ;
			xFilial("BR6")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA)
			BRX->(DbSetOrder(1))
			If ! BRX->(Dbseek(xFilial("BRX")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+BR6->BR6_CODFOR+BR6->BR6_CODFAI))
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Incluo cada faixa etaria...                                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BRX->(RecLock("BRX",.T.))
					BRX->BRX_FILIAL := xFilial("BRX")
					BRX->BRX_CODOPE := BA3->BA3_CODINT
					BRX->BRX_CODEMP := BA3->BA3_CODEMP
					BRX->BRX_MATRIC := BA3->BA3_MATRIC
					BRX->BRX_CODFOR := BTK->BTK_CODFOR
					BRX->BRX_CODFAI := BR6->BR6_CODFAI
					BRX->BRX_TIPUSR := BR6->BR6_TIPUSR
					BRX->BRX_GRAUPA := BR6->BR6_GRAUPA
					BRX->BRX_VLRADE := BR6->BR6_VLRADE
					BRX->BRX_PERADE := BR6->BR6_PERADE
					BRX->BRX_SEXO   := BR6->BR6_SEXO
					BRX->BRX_IDAINI := BR6->BR6_IDAINI
					BRX->BRX_IDAFIN := BR6->BR6_IDAFIN
				BRX->(MsUnLock())
			Else
				BRX->( RecLock("BRX", .F.) )
					BRX->BRX_TIPUSR := BR6->BR6_TIPUSR
					BRX->BRX_GRAUPA := BR6->BR6_GRAUPA
					BRX->BRX_VLRADE := BR6->BR6_VLRADE
					BRX->BRX_PERADE := BR6->BR6_PERADE
				BRX->( msUnlock() )
			Endif
			
			BR6->(DbSkip())
		Enddo
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inclusao das faixas caso seja pessoa fisica...                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While ! BRY->(Eof()) .And. BRY->(BRY_FILIAL+BRY_CODPLA+BRY_VERSAO) == ;
			xFilial("BRX")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Incluo cada faixa etaria...                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BRX->(RecLock("BRX",.T.))
			BRX->BRX_FILIAL := xFilial("BRX")
			BRX->BRX_CODOPE := BA3->BA3_CODINT
			BRX->BRX_CODEMP := BA3->BA3_CODEMP
			BRX->BRX_MATRIC := BA3->BA3_MATRIC
			BRX->BRX_CODFOR := BJ9->BJ9_CODFOR
			BRX->BRX_CODFAI := BRY->BRY_CODFAI
			BRX->BRX_TIPUSR := BRY->BRY_TIPUSR
			BRX->BRX_GRAUPA := BRY->BRY_GRAUPA
			BRX->BRX_VLRADE := BRY->BRY_VLRADE
			BRX->BRX_PERADE := BRY->BRY_PERADE
			BRX->BRX_SEXO   := BRY->BRY_SEXO
			BRX->BRX_IDAINI := BRY->BRY_IDAINI
			BRX->BRX_IDAFIN := BRY->BRY_IDAFIN
			BRX->(MsUnLock())
			
			BRY->(DbSkip())
		Enddo
		
	Endif
	
	Trb->(DbSkip())
Enddo

Trb->(DbCloseArea())

If Len(aCriticas) > 0
   PLSCRIGEN(aCriticas,{ {"Tabela","@C",20} , {"Descricao","@C",400 } , {"Familia","@C",20 } },"Criticas")
Endif


Return

