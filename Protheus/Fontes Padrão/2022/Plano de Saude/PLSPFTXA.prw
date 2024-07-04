
#include "PROTHEUS.CH"
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSTXPAD   Ё Autor Ё Antonio de Padua  Ё Data Ё 14.08.2002 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Forma de Cobranca Padrao para Taxa de Adesao...            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Advanced Protheus                                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁObservacaoЁ  														  Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSTXPAD(cCodInt, cCodEmp, cMatric, cTipReg, aCobTx, _cNivel, nValBas)
Local nCont
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da rotina...                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL cSQL
LOCAL nFlag     := 0
LOCAL cCodFai   := ""
LOCAL nPerct    := 0
LOCAL nValor    := 0
LOCAL cNivFai   := ""
LOCAL cTipUsu   := BA1->BA1_TIPUSU
LOCAL cGrauPar  := BA1->BA1_GRAUPA
LOCAL cSexo     := BA1->BA1_SEXO
LOCAL nIdade    := Calc_Idade(dDatabase,BA1->BA1_DATNAS)
LOCAL cCodigo   := ""

If ! aCobTx[1]
	
	If _cNivel == "3"
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se para este usuario a taxa adesao esta na FAMILIA         Ё
		//Ё                                                                     Ё
		//Ё TAXA ADESAO NIVEL FAMILIA                                           Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Busca no nivel FAMILIA...                                           Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cSQL := "SELECT BRX_CODFAI, BRX_PERADE, BRX_VLRADE,BRX_TIPUSR,BRX_GRAUPA,BRX_SEXO,BRX_IDAINI,BRX_IDAFIN FROM "+RetSQLName("BRX")+" WHERE "
		cSQL += "BRX_FILIAL = '"+xFilial("BRX")+"' AND "
		cSQL += "BRX_CODOPE = '"+cCodInt+"' AND "
		cSQL += "BRX_CODEMP = '"+cCodEmp+"' AND "
		cSQL += "BRX_MATRIC = '"+cMatric+"' AND "
		cSQL += " D_E_L_E_T_= ''"
		cSQL += " ORDER BY BRX_TIPUSR DESC ,BRX_GRAUPA DESC ,BRX_SEXO DESC"
		
		PLSQuery(cSQL,"TrbBRX")
		
		While !TrbBRX->(Eof())
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para todos o sexo e tipo de usuario e grau de parentesco... Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBRX->BRX_TIPUSR) .And. !Empty(TrbBRX->BRX_GRAUPA) .And. !Empty(TrbBRX->BRX_SEXO)
				if cTipUsu == TrbBRX->BRX_TIPUSR .And. ;
					cGrauPar == TrbBRX->BRX_GRAUPA .And.;
					(cSexo == TrbBRX->BRX_SEXO .Or. TrbBRX->BRX_SEXO == "3")
					if nIdade >= TrbBRX->BRX_IDAINI .And.;
						nIdade <= TrbBRX->BRX_IDAFIN
						nValor := TrbBRX->BRX_VLRADE
						nPerct := TrbBRX->BRX_PERADE
						cCodFai:= TrbBRX->BRX_CODFAI
						cNivFai:= "1"
						Exit
					Endif
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para todos o sexo e tipo de usuario...                      Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBRX->BRX_TIPUSR) .And. Empty(TrbBRX->BRX_GRAUPA) .And. !Empty(TrbBRX->BRX_SEXO)
				if cTipUsu == TrbBRX->BRX_TIPUSR .And. ;
					(cSexo == TrbBRX->BRX_SEXO .Or. TrbBRX->BRX_SEXO == "3")
					if nIdade >= TrbBRX->BRX_IDAINI .And.;
						nIdade <= TrbBRX->BRX_IDAFIN
						nValor := TrbBRX->BRX_VLRADE
						nPerct := TrbBRX->BRX_PERADE
						cCodFai:= TrbBRX->BRX_CODFAI
						cNivFai:= "1"
						Exit
					EndIf
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para todos o tipo de usuario e grau parentesco...           Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBRX->BRX_TIPUSR) .And. !Empty(TrbBRX->BRX_GRAUPA) .And. Empty(TrbBRX->BRX_SEXO)
				if cTipUsu == TrbBRX->BRX_TIPUSR .And. ;
					cGrauPar == TrbBRX->BRX_GRAUPA
					if nIdade >= TrbBRX->BRX_IDAINI .And. ;
						nIdade <= TrbBRX->BRX_IDAFIN
						nValor := TrbBRX->BRX_VLRADE
						nPerct := TrbBRX->BRX_PERADE
						cCodFai:= TrbBRX->BRX_CODFAI
						cNivFai:= "1"
						Exit
					Endif
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para todos o grau de parentesco e sexo                      Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if Empty(TrbBRX->BRX_TIPUSR) .And. !Empty(TrbBRX->BRX_GRAUPA) .And. !Empty(TrbBRX->BRX_SEXO)
				if cGrauPar == TrbBRX->BRX_GRAUPA .And.;
					(cSexo == TrbBRX->BRX_SEXO .Or. TrbBRX->BRX_SEXO == "3")
					if nIdade >= TrbBRX->BRX_IDAINI .And.;
						nIdade <= TrbBRX->BRX_IDAFIN
						nValor := TrbBRX->BRX_VLRADE
						nPerct := TrbBRX->BRX_PERADE
						cCodFai:= TrbBRX->BRX_CODFAI
						cNivFai:= "1"
						Exit
					Endif
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para somente o tipo de usuario...                           Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBRX->BRX_TIPUSR) .And. Empty(TrbBRX->BRX_GRAUPA) .And. Empty(TrbBRX->BRX_SEXO)
				if cTipUsu == TrbBRX->BRX_TIPUSR
					if nIdade >= TrbBRX->BRX_IDAINI .And. ;
						nIdade <= TrbBRX->BRX_IDAFIN
						nValor := TrbBRX->BRX_VLRADE
						nPerct := TrbBRX->BRX_PERADE
						cCodFai:= TrbBRX->BRX_CODFAI
						cNivFai:= "1"
						Exit
					Endif
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para somente o sexo...                                      Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if Empty(TrbBRX->BRX_TIPUSR) .And. Empty(TrbBRX->BRX_GRAUPA) .And. !Empty(TrbBRX->BRX_SEXO)
				if (cSexo == TrbBRX->BRX_SEXO .Or. TrbBRX->BRX_SEXO == "3")
					if nIdade >= TrbBRX->BRX_IDAINI .And. ;
						nIdade <= TrbBRX->BRX_IDAFIN
						nValor := TrbBRX->BRX_VLRADE
						nPerct := TrbBRX->BRX_PERADE
						cCodFai:= TrbBRX->BRX_CODFAI
						cNivFai:= "1"
						Exit
					Endif
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para somente o grau de parentesco...                        Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if Empty(TrbBRX->BRX_TIPUSR) .And. !Empty(TrbBRX->BRX_GRAUPA) .And. Empty(TrbBRX->BRX_SEXO)
				if cGrauPar == TrbBRX->BRX_GRAUPA
					if nIdade >= TrbBRX->BRX_IDAINI .And. ;
						nIdade <= TrbBRX->BRX_IDAFIN
						nValor := TrbBRX->BRX_VLRADE
						nPerct := TrbBRX->BRX_PERADE
						cCodFai:= TrbBRX->BRX_CODFAI
						cNivFai:= "1"
						Exit
					Endif
				Endif
			Endif
			
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para somente a faixa...                                     Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if Empty(TrbBRX->BRX_TIPUSR) .And. Empty(TrbBRX->BRX_GRAUPA) .And. Empty(TrbBRX->BRX_SEXO)
				if nIdade >= TrbBRX->BRX_IDAINI .And. ;
					nIdade <= TrbBRX->BRX_IDAFIN
					nValor := TrbBRX->BRX_VLRADE
					nPerct := TrbBRX->BRX_PERADE
					cCodFai:= TrbBRX->BRX_CODFAI
					cNivFai:= "1"
					Exit
				Endif
			Endif
			
			TrbBRX->(DbSkip())
		Enddo
		TrbBRX->(DbCloseArea())
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se para este usuario a taxa adesao esta no nivel grupo/emp Ё
		//Ё                                                                     Ё
		//Ё TAXA ADESAO NIVEL GRUPO/EMPRESA                                     Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	ElseIf _cNivel == "2"
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Procura taxa de adeso a  nivel de tipo de usuario...                Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cSQL := "SELECT BR6_CODFAI, BR6_VLRADE,BR6_TIPUSR,BR6_GRAUPA,BR6_SEXO,BR6_IDAINI,BR6_IDAFIN,BR6_PERADE FROM "+RetSQLName("BR6")+" WHERE "
		cSQL += "BR6_FILIAL = '"+xFilial("BTN")+"' AND "
		cSQL += "BR6_CODIGO = '"+cCodInt+BA3->BA3_CODEMP+"' AND "
		cSQL += "BR6_NUMCON = '"+BA3->BA3_CONEMP+"' AND "
		cSQL += "BR6_VERCON = '"+BA3->BA3_VERCON+"' AND "
		cSQL += "BR6_SUBCON = '"+BA3->BA3_SUBCON+"' AND "
		cSQL += "BR6_VERSUB = '"+BA3->BA3_VERSUB+"' AND "
		cSQL += "BR6_CODPRO = '"+BA3->BA3_CODPLA+"' AND "
		cSQL += "BR6_VERPRO = '"+BA3->BA3_VERSAO+"' AND "
		cSQL += "D_E_L_E_T_ = ''"
		cSQL += " ORDER BY BR6_TIPUSR DESC ,BR6_GRAUPA DESC ,BR6_SEXO DESC"
		
		PLSQuery(cSQL,"TrbBR6")
		
		TrbBR6->(DbGoTop())
		
		While ! TrbBR6->(Eof())
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para todos o sexo e tipo de usuario e grau de parentesco... Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBR6->BR6_TIPUSR) .And. !Empty(TrbBR6->BR6_GRAUPA) .And. !Empty(TrbBR6->BR6_SEXO)
				if cTipUsu == TrbBR6->BR6_TIPUSR .And. ;
					cGrauPar == TrbBR6->BR6_GRAUPA .And.;
					(cSexo == TrbBR6->BR6_SEXO .Or. TrbBR6->BR6_SEXO == "3")
					if nIdade >= TrbBR6->BR6_IDAINI .And.;
						nIdade <= TrbBR6->BR6_IDAFIN
						nValor := TrbBR6->BR6_VLRADE
						nPerct := TrbBR6->BR6_PERADE
						cCodFai:= TrbBR6->BR6_CODFAI
						cNivFai:= "4"
						Exit
					Endif
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para todos o sexo e tipo de usuario...                      Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBR6->BR6_TIPUSR) .And. Empty(TrbBR6->BR6_GRAUPA) .And. !Empty(TrbBR6->BR6_SEXO)
				if cTipUsu == TrbBR6->BR6_TIPUSR .And. ;
					(cSexo == TrbBR6->BR6_SEXO .Or. TrbBR6->BR6_SEXO == "3")
					if nIdade >= TrbBR6->BR6_IDAINI .And.;
						nIdade <= TrbBR6->BR6_IDAFIN
						nValor  := TrbBR6->BR6_VLRADE
						nPerct := TrbBR6->BR6_PERADE
						cCodFai := TrbBR6->BR6_CODFAI
						cNivFai := "2"
						Exit
					Endif
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para todos o tipo de usuario e grau parentesco...           Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBR6->BR6_TIPUSR) .And. !Empty(TrbBR6->BR6_GRAUPA) .And. Empty(TrbBR6->BR6_SEXO)
				if cTipUsu == TrbBR6->BR6_TIPUSR .And. ;
					cGrauPar == TrbBR6->BR6_GRAUPA
					if nIdade >= TrbBR6->BR6_IDAINI .And.;
						nIdade <= TrbBR6->BR6_IDAFIN
						nValor  := TrbBR6->BR6_VLRADE
						nPerct := TrbBR6->BR6_PERADE
						cCodFai := TrbBR6->BR6_CODFAI
						cNivFai := "2"
						Exit
					Endif
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para todos o grau de parentesco e sexo                      Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if Empty(TrbBR6->BR6_TIPUSR) .And. !Empty(TrbBR6->BR6_GRAUPA) .And. !Empty(TrbBR6->BR6_SEXO)
				if cGrauPar == TrbBR6->BR6_GRAUPA .And.;
					(cSexo == TrbBR6->BR6_SEXO .Or. TrbBR6->BR6_SEXO == "3")
					if nIdade >= TrbBR6->BR6_IDAINI .And.;
						nIdade <= TrbBR6->BR6_IDAFIN
						nValor  := TrbBR6->BR6_VLRADE
						nPerct  := TrbBR6->BR6_PERADE
						cCodFai := TrbBR6->BR6_CODFAI
						cNivFai := "2"
						Exit
					Endif
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para somente o tipo de usuario...                           Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBR6->BR6_TIPUSR) .And. Empty(TrbBR6->BR6_GRAUPA) .And. Empty(TrbBR6->BR6_SEXO)
				if cTipUsu == TrbBR6->BR6_TIPUSR
					if nIdade >= TrbBR6->BR6_IDAINI .And.;
						nIdade <= TrbBR6->BR6_IDAFIN
						nValor  := TrbBR6->BR6_VLRADE
						nPerct  := TrbBR6->BR6_PERADE
						cCodFai := TrbBR6->BR6_CODFAI
						cNivFai := "2"
						Exit
					Endif
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para somente o sexo...                                      Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if Empty(TrbBR6->BR6_TIPUSR) .And. Empty(TrbBR6->BR6_GRAUPA) .And. !Empty(TrbBR6->BR6_SEXO)
				if (cSexo == TrbBR6->BR6_SEXO .Or. TrbBR6->BR6_SEXO == "3")
					if nIdade >= TrbBR6->BR6_IDAINI .And.;
						nIdade <= TrbBR6->BR6_IDAFIN
						nValor  := TrbBR6->BR6_VLRADE
						cCodFai := TrbBR6->BR6_CODFAI
						nPerct  := TrbBR6->BR6_PERADE
						cNivFai := "2"
						Exit
					Endif
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para somente o grau de parentesco...                        Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if Empty(TrbBR6->BR6_TIPUSR) .And. !Empty(TrbBR6->BR6_GRAUPA) .And. Empty(TrbBR6->BR6_SEXO)
				if cGrauPar == TrbBR6->BR6_GRAUPA
					if nIdade >= TrbBR6->BR6_IDAINI .And.;
						nIdade <= TrbBR6->BR6_IDAFIN
						nValor  := TrbBR6->BR6_VLRADE
						cCodFai := TrbBR6->BR6_CODFAI
						nPerct  := TrbBR6->BR6_PERADE
						cNivFai := "2"
						Exit
					Endif
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para somente a faixa...                                     Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if Empty(TrbBR6->BR6_TIPUSR) .And. Empty(TrbBR6->BR6_GRAUPA) .And. Empty(TrbBR6->BR6_SEXO)
				if nIdade >= TrbBR6->BR6_IDAINI .And.;
					nIdade <= TrbBR6->BR6_IDAFIN
					nValor  := TrbBR6->BR6_VLRADE
					cCodFai := TrbBR6->BR6_CODFAI
					nPerct  := TrbBR6->BR6_PERADE
					cNivFai := "2"
					Exit
				Endif
			Endif
			TrbBR6->(dbSkip())
		Enddo
		
		TrbBR6->(dbCloseArea())
		
	ElseIf _cNivel == "1"
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se para este usuario a taxa adesao esta no PRODUTO         Ё
		//Ё                                                                     Ё
		//Ё TAXA ADESAO NIVEL PRODUTO                                           Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Busca no nivel PRODUTO...                                           Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cSQL := "SELECT BRY_CODFAI, BRY_PERADE, BRY_VLRADE,BRY_TIPUSR,BRY_GRAUPA,BRY_SEXO,BRY_IDAINI,BRY_IDAFIN FROM "+RetSQLName("BRY")+" WHERE "
		cSQL += "BRY_FILIAL = '"+xFilial("BRY")+"' AND "
		cSQL += "BRY_CODIGO = '"+cCodInt+BA3->BA3_CODPLA+"' AND "
		cSQL += "BRY_VERSAO = '"+BA3->BA3_VERSAO+"' AND "
		cSQL += " D_E_L_E_T_= ''"
		cSQL += " ORDER BY BRY_TIPUSR DESC ,BRY_GRAUPA DESC ,BRY_SEXO DESC"
		
		PLSQuery(cSQL,"TrbBRY")
		
		While !TrbBRY->(Eof())
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para todos o sexo e tipo de usuario e grau de parentesco... Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBRY->BRY_TIPUSR) .And. !Empty(TrbBRY->BRY_GRAUPA) .And. !Empty(TrbBRY->BRY_SEXO)
				if cTipUsu == TrbBRY->BRY_TIPUSR .And. ;
					cGrauPar == TrbBRY->BRY_GRAUPA .And.;
					(cSexo == TrbBRY->BRY_SEXO .Or. TrbBRY->BRY_SEXO == "3")
					if nIdade >= TrbBRY->BRY_IDAINI .And.;
						nIdade <= TrbBRY->BRY_IDAFIN
						nValor := TrbBRY->BRY_VLRADE
						nPerct := TrbBRY->BRY_PERADE
						cCodFai:= TrbBRY->BRY_CODFAI
						cNivFai:= "3"
						Exit
					Endif
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para todos o sexo e tipo de usuario...                      Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBRY->BRY_TIPUSR) .And. Empty(TrbBRY->BRY_GRAUPA) .And. !Empty(TrbBRY->BRY_SEXO)
				if cTipUsu == TrbBRY->BRY_TIPUSR .And. ;
					(cSexo == TrbBRY->BRY_SEXO .Or. TrbBRY->BRY_SEXO == "3")
					if nIdade >= TrbBRY->BRY_IDAINI .And.;
						nIdade <= TrbBRY->BRY_IDAFIN
						nValor := TrbBRY->BRY_VLRADE
						nPerct := TrbBRY->BRY_PERADE
						cCodFai:= TrbBRY->BRY_CODFAI
						cNivFai:= "3"
						Exit
					EndIf
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para todos o tipo de usuario e grau parentesco...           Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBRY->BRY_TIPUSR) .And. !Empty(TrbBRY->BRY_GRAUPA) .And. Empty(TrbBRY->BRY_SEXO)
				if cTipUsu == TrbBRY->BRY_TIPUSR .And. ;
					cGrauPar == TrbBRY->BRY_GRAUPA
					if nIdade >= TrbBRY->BRY_IDAINI .And. ;
						nIdade <= TrbBRY->BRY_IDAFIN
						nValor := TrbBRY->BRY_VLRADE
						nPerct := TrbBRY->BRY_PERADE
						cCodFai:= TrbBRY->BRY_CODFAI
						cNivFai:= "3"
						Exit
					Endif
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para todos o grau de parentesco e sexo                      Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if Empty(TrbBRY->BRY_TIPUSR) .And. !Empty(TrbBRY->BRY_GRAUPA) .And. !Empty(TrbBRY->BRY_SEXO)
				if cGrauPar == TrbBRY->BRY_GRAUPA .And.;
					(cSexo == TrbBRY->BRY_SEXO .Or. TrbBRY->BRY_SEXO == "3")
					if nIdade >= TrbBRY->BRY_IDAINI .And.;
						nIdade <= TrbBRY->BRY_IDAFIN
						nValor := TrbBRY->BRY_VLRADE
						nPerct := TrbBRY->BRY_PERADE
						cCodFai:= TrbBRY->BRY_CODFAI
						cNivFai:= "3"
						Exit
					Endif
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para somente o tipo de usuario...                           Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBRY->BRY_TIPUSR) .And. Empty(TrbBRY->BRY_GRAUPA) .And. Empty(TrbBRY->BRY_SEXO)
				if cTipUsu == TrbBRY->BRY_TIPUSR
					if nIdade >= TrbBRY->BRY_IDAINI .And. ;
						nIdade <= TrbBRY->BRY_IDAFIN
						nValor := TrbBRY->BRY_VLRADE
						nPerct := TrbBRY->BRY_PERADE
						cCodFai:= TrbBRY->BRY_CODFAI
						cNivFai:= "3"
						Exit
					Endif
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para somente o sexo...                                      Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if Empty(TrbBRY->BRY_TIPUSR) .And. Empty(TrbBRY->BRY_GRAUPA) .And. !Empty(TrbBRY->BRY_SEXO)
				if (cSexo == TrbBRY->BRY_SEXO .Or. TrbBRY->BRY_SEXO == "3")
					if nIdade >= TrbBRY->BRY_IDAINI .And. ;
						nIdade <= TrbBRY->BRY_IDAFIN
						nValor := TrbBRY->BRY_VLRADE
						nPerct := TrbBRY->BRY_PERADE
						cCodFai:= TrbBRY->BRY_CODFAI
						cNivFai:= "3"
						Exit
					Endif
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para somente o grau de parentesco...                        Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if Empty(TrbBRY->BRY_TIPUSR) .And. !Empty(TrbBRY->BRY_GRAUPA) .And. Empty(TrbBRY->BRY_SEXO)
				if cGrauPar == TrbBRY->BRY_GRAUPA
					if nIdade >= TrbBRY->BRY_IDAINI .And. ;
						nIdade <= TrbBRY->BRY_IDAFIN
						nValor := TrbBRY->BRY_VLRADE
						nPerct := TrbBRY->BRY_PERADE
						cCodFai:= TrbBRY->BRY_CODFAI
						cNivFai:= "3"
						Exit
					Endif
				Endif
			Endif
			
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procura para somente a faixa...                                     Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if Empty(TrbBRY->BRY_TIPUSR) .And. Empty(TrbBRY->BRY_GRAUPA) .And. Empty(TrbBRY->BRY_SEXO)
				if nIdade >= TrbBRY->BRY_IDAINI .And. ;
					nIdade <= TrbBRY->BRY_IDAFIN
					nValor := TrbBRY->BRY_VLRADE
					nPerct := TrbBRY->BRY_PERADE
					cCodFai:= TrbBRY->BRY_CODFAI
					cNivFai:= "3"
					Exit
				Endif
			Endif
			
			TrbBRY->(DbSkip())
		Enddo
		TrbBRY->(DbCloseArea())
	Endif
Endif
if nPerct >0
	nValor := nValBas * nPerct/100
endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Le tabela de descontos de acordo com tabela de faixa etaria...      Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if _cNivel == "3"
	cCodigo := cCodInt+cCodEmp+cMatric
	nFlag := 1
ElseIf _cNivel == "2"
	cCodigo := cCodInt+cCodEmp
	nFlag := 2
Elseif _cNivel == "1"
	cCodigo := cCodInt+BA3->BA3_CODPLA
	nFlag := 3
Endif

aVetRet := PLSMFPDeTx(cCodigo,BA3->BA3_VERSAO,cTipReg,cGrauPar,cSexo,cCodInt+cCodEmp+cMatric,nValor,cCodFai,nFlag,BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB,BA3->BA3_CODPLA)
nCont := 0

For nCont := 1 to Len(aVetRet)
	if aVetRet[nCont,1] > 0
		if aVetRet[nCont,3] == "1"
			nValor := nValor - aVetRet[nCont,1]
		Elseif aVetRet[nCont,3] == "2"
			nValor := nValor + aVetRet[nCont,1]
		Endif
	Endif
	if aVetRet[nCont,2] > 0
		if aVetRet[nCont,3] == "1"
			nValor := nValor - (nValor * aVetRet[nCont,2]/100)
		Elseif aVetRet[nCont,3] == "2"
			nValor := nValor + (nValor * aVetRet[nCont,2]/100)
		Endif
	Endif
Next

Return({aCobTx[1],nValor,cCodFai,cNivFai})

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSMFPDeTx Ё Autor Ё Antonio de Padua  Ё Data Ё 21.08.2002 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Desconto por faixa etaria taxa de Adesao                   Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Advanced Protheus                                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ cCodigo  - Codigo de PLano								  Ё╠╠
╠╠Ё          Ё cVersao  - Versao do Plano (Ex.: 001,002)				  Ё╠╠
╠╠Ё          Ё cTipUsu  - Tipo do Usuario (Ex.: T=Titular, D=Dependente)  Ё╠╠
╠╠Ё          Ё cGrauPar - Grau de Parentesco (Ex.: 01=Filho,02=Filha)     Ё╠╠
╠╠Ё          Ё cSexo    - Sexo do Usuario (Ex.: 1=Masculino)              Ё╠╠
╠╠Ё          Ё cMatric  - Matricula da Familia 							  Ё╠╠
╠╠Ё          Ё nVlrFai  - Valor da Faixa Etaria (Para calculo)            Ё╠╠
╠╠Ё          Ё cCodFai  - Codigo da Faixa (Para procurar o desconto)      Ё╠╠
╠╠Ё          Ё nTipo    - Flag para saber se foi Faixa da Familia/Empresa/Produto Ё╠╠
╠╠Ё          Ё cConEmp  - Contrato Empresa   						      Ё╠╠
╠╠Ё          Ё cVerCon  - Versao do Contrato                              Ё╠╠
╠╠Ё          Ё cSubCon  - Sub Contrato                                    Ё╠╠
╠╠Ё          Ё cVerSub  - Versao do Sub Contrato                          Ё╠╠
╠╠Ё          Ё cCodPla  - Codigo do Plano sem Operadora                   Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
//Retorna o {Valor do Desconto, Percentual de Desconto}
//
//
/*/
Static Function PLSMFPDeTx(cCodigo,cVersao,cTipUsu,cGrauPar,cSexo,cMatric,nVlrFai,cCodFai,nTipo,cConEmp,cVerCon,cSubCon,cVerSub,cCodPla)

Local nQtdUsr := 0
Local aRetorno := {}
Local aRetDesFai := {}
Local cSql

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifico quantos usuarios existem deste tipo na familia...          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local aQtdUsrTip := PLSQTDUSR(cMatric,1,"VET")
Local aQtdUsrGra := PLSQTDUSR(cMatric,2,"VET")
Local nQtdUsrTot := PLSQTDUSR(cMatric)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pesquiso com todos os parametros...                                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := "SELECT BIH_CODTIP FROM "+RetSQLName("BIH")+" WHERE "
cSQL += " D_E_L_E_T_= ''"
PLSQuery(cSQL,"TrbBIH")

cSQL := "SELECT BRP_CODIGO FROM "+RetSQLName("BRP")+" WHERE "
cSQL += " D_E_L_E_T_= ''"
PLSQuery(cSQL,"TrbBRP")

If nTipo == 1
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Faco uma Sql dos dados que usarei para nao mais ir no banco de dados..Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cSQL := "SELECT BFZ_PERCEN,BFZ_VALOR,BFZ_TIPO,BFZ_TIPUSR,BFZ_GRAUPA,BFZ_QTDDE,BFZ_QTDATE FROM "+RetSQLName("BFZ")+" WHERE "
	cSQL += "BFZ_FILIAL = '"+xFilial("BFZ")+"' AND "
	cSQL += "BFZ_CODOPE = '"+Substr(cMatric,1,4)+"' AND "
	cSQL += "BFZ_CODEMP = '"+Substr(cMatric,5,4)+"' AND "
	cSQL += "BFZ_MATRIC = '"+Substr(cMatric,9,6)+"' AND "
	cSQL += "BFZ_CODFAI = '"+cCodFai+"'"
	cSQL += " AND D_E_L_E_T_= ''"
	cSQL += " ORDER BY BFZ_TIPUSR DESC ,BFZ_GRAUPA DESC"
	
	PLSQuery(cSQL,"TrbBFZ")
	
	While ! TrbBFZ->(Eof())
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё 1 - Desc/Acres eh dado com as informacoes referente a familia do usuario..Ё
		//Ё 2 - Desc/Acres eh dado com as informacoes referente ao usuario...         Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		if TrbBFZ->BFZ_QTDATE > 0
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFZ->BFZ_TIPUSR) .And. ! Empty(TrbBFZ->BFZ_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					TRBBRP->(DbGoTop())
					While ! TRBBRP->(Eof()) .And. !lFlag
						if TRBBIH->BIH_CODTIP == TrbBFZ->BFZ_TIPUSR .And.;
							TRBBRP->BRP_CODIGO == TrbBFZ->BFZ_GRAUPA
							nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBFZ->BFZ_TIPUSR})
							nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBFZ->BFZ_GRAUPA})
							if nPosTip > 0 .And. nPosGra > 0
								if aQtdUsrTip[nPosTip,2] >= TrbBFZ->BFZ_QTDDE  .And.;
									aQtdUsrTip[nPosTip,2] <= TrbBFZ->BFZ_QTDATE .And.;
									aQtdUsrGra[nPosTip,2] >= TrbBFZ->BFZ_QTDDE  .And.;
									aQtdUsrGra[nPosTip,2] <= TrbBFZ->BFZ_QTDATE
									aadd (aRetorno, {TrbBFZ->BFZ_VALOR,TrbBFZ->BFZ_PERCEN,TrbBFZ->BFZ_TIPO})
									lFlag  := .T.
								Endif
							Endif
						Endif
						TRBBRP->(DbSkip())
					Enddo
					TRBBIH->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido somente o Grau de parentesco...             Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFZ->BFZ_GRAUPA)	 .And.  Empty(TrbBFZ->BFZ_TIPUSR)
				TRBBRP->(DbGoTop())
				While ! TRBBRP->(Eof()) .And. !lFlag
					if TRBBRP->BRP_CODIGO == TrbBFZ->BFZ_GRAUPA
						nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBFZ->BFZ_GRAUPA})
						if nPosGra > 0
							if aQtdUsrGra[nPosTip,2] >= TrbBFZ->BFZ_QTDDE  .And.;
								aQtdUsrGra[nPosTip,2] <= TrbBFZ->BFZ_QTDATE
								aadd (aRetorno, {TrbBFZ->BFZ_VALOR,TrbBFZ->BFZ_PERCEN,TrbBFZ->BFZ_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBRP->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido somente o Tipo de Usuario...                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFZ->BFZ_TIPUSR) .And. Empty(TrbBFZ->BFZ_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					if TRBBIH->BIH_CODTIP == TrbBFZ->BFZ_TIPUSR
						nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBFZ->BFZ_TIPUSR})
						if nPosTip > 0
							if aQtdUsrTip[nPosTip,2] >= TrbBFZ->BFZ_QTDDE  .And.;
								aQtdUsrTip[nPosTip,2] <= TrbBFZ->BFZ_QTDATE
								aadd (aRetorno, {TrbBFZ->BFZ_VALOR,TrbBFZ->BFZ_PERCEN,TrbBFZ->BFZ_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBIH->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se nada esta preenchido, somente qtd de usuarios 		        Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if Empty(TrbBFZ->BFZ_TIPUSR) .And. Empty(TrbBFZ->BFZ_GRAUPA)
				if nQtdUsrTot >= TrbBFZ->BFZ_QTDDE  .And.;
					nQtdUsrTot <= TrbBFZ->BFZ_QTDATE
					aadd (aRetorno, {TrbBFZ->BFZ_VALOR,TrbBFZ->BFZ_PERCEN,TrbBFZ->BFZ_TIPO})
				Endif
			Endif
			
		Else
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFZ->BFZ_TIPUSR) .And. ! Empty(TrbBFZ->BFZ_GRAUPA)
				if cTipUsu == TrbBFZ->BFZ_TIPUSR .And. cGrauPar == TrbBFZ->BFZ_GRAUPA
					aadd (aRetorno, {TrbBFZ->BFZ_VALOR,TrbBFZ->BFZ_PERCEN,TrbBFZ->BFZ_TIPO})
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido somente o Grau de parentesco...             Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFZ->BFZ_GRAUPA)	 .And.  Empty(TrbBFZ->BFZ_TIPUSR)
				if cGrauPar == TrbBFZ->BFZ_GRAUPA
					aadd (aRetorno, {TrbBFZ->BFZ_VALOR,TrbBFZ->BFZ_PERCEN,TrbBFZ->BFZ_TIPO})
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido somente o Tipo de Usuario...                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFZ->BFZ_TIPUSR) .And. Empty(TrbBFZ->BFZ_GRAUPA)
				if TrbBFZ->BFZ_TIPUSR == cTipUsu
					aadd (aRetorno, {TrbBFZ->BFZ_VALOR,TrbBFZ->BFZ_PERCEN,TrbBFZ->BFZ_TIPO})
				Endif
			Endif
			
		Endif
		
		TrbBFZ->(DbSkip())
	Enddo
	TrbBFZ->(DbCloseArea())
	
ElseIf nTipo == 2
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Faco uma Sql dos dados que usarei para nao mais ir no banco de dados..Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cSQL := "SELECT BFV_PERCEN,BFV_VALOR,BFV_TIPO,BFV_TIPUSR,BFV_GRAUPA,BFV_QTDDE,BFV_QTDATE FROM "+RetSQLName("BFV")+" WHERE "
	cSQL += "BFV_FILIAL = '"+xFilial("BFV")+"' AND "
	cSQL += "BFV_CODIGO = '"+cCodigo+"' AND "
	cSQL += "BFV_NUMCON = '"+cConEmp+"' AND "
	cSQL += "BFV_VERCON = '"+cVerCon+"' AND "
	cSQL += "BFV_SUBCON = '"+cSubCon+"' AND "
	cSQL += "BFV_VERSUB = '"+cVerSub+"' AND "
	cSQL += "BFV_CODPRO = '"+cCodPla+"' AND "
	cSQL += "BFV_VERPRO = '"+cVersao+"' AND "
	cSQL += "BFV_CODFAI = '"+cCodFai+"'"
	cSQL += " AND D_E_L_E_T_= ''"
	cSQL += " ORDER BY BFV_TIPUSR DESC ,BFV_GRAUPA DESC"
	
	PLSQuery(cSQL,"TrbBFV")
	
	While ! TrbBFV->(Eof())
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё 1 - Desc/Acres eh dado com as informacoes referente a familia do usuario..Ё
		//Ё 2 - Desc/Acres eh dado com as informacoes referente ao usuario...         Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		if  TrbBFV->BFV_QTDATE > 0
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFV->BFV_TIPUSR) .And. ! Empty(TrbBFV->BFV_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					TRBBRP->(DbGoTop())
					While ! TRBBRP->(Eof()) .And. !lFlag
						if TRBBIH->BIH_CODTIP == TrbBFV->BFV_TIPUSR .And.;
							TRBBRP->BRP_CODIGO == TrbBFV->BFV_GRAUPA
							nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBFV->BFV_TIPUSR})
							nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBFV->BFV_GRAUPA})
							if nPosTip > 0 .And. nPosGra > 0
								if aQtdUsrTip[nPosTip,2] >= TrbBFV->BFV_QTDDE  .And.;
									aQtdUsrTip[nPosTip,2] <= TrbBFV->BFV_QTDATE .And.;
									aQtdUsrGra[nPosTip,2] >= TrbBFV->BFV_QTDDE  .And.;
									aQtdUsrGra[nPosTip,2] <= TrbBFV->BFV_QTDATE
									aadd (aRetorno, {TrbBFV->BFV_VALOR,TrbBFV->BFV_PERCEN,TrbBFV->BFV_TIPO})
									lFlag  := .T.
								Endif
							Endif
						Endif
						TRBBRP->(DbSkip())
					Enddo
					TRBBIH->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido somente o Grau de parentesco...             Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFV->BFV_GRAUPA)	 .And.  Empty(TrbBFV->BFV_TIPUSR)
				TRBBRP->(DbGoTop())
				While ! TRBBRP->(Eof()) .And. !lFlag
					if TRBBRP->BRP_CODIGO == TrbBFV->BFV_GRAUPA
						nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBFV->BFV_GRAUPA})
						if nPosGra > 0
							if aQtdUsrGra[nPosTip,2] >= TrbBFV->BFV_QTDDE  .And.;
								aQtdUsrGra[nPosTip,2] <= TrbBFV->BFV_QTDATE
								aadd (aRetorno, {TrbBFV->BFV_VALOR,TrbBFV->BFV_PERCEN,TrbBFV->BFV_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBRP->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido somente o Tipo de Usuario...                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFV->BFV_TIPUSR) .And. Empty(TrbBFV->BFV_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					if TRBBIH->BIH_CODTIP == TrbBFV->BFV_TIPUSR
						nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBFV->BFV_TIPUSR})
						if nPosTip > 0
							if aQtdUsrTip[nPosTip,2] >= TrbBFV->BFV_QTDDE  .And.;
								aQtdUsrTip[nPosTip,2] <= TrbBFV->BFV_QTDATE
								aadd (aRetorno, {TrbBFV->BFV_VALOR,TrbBFV->BFV_PERCEN,TrbBFV->BFV_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBIH->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se nada esta preenchido, somente qtd de usuarios 		        Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if Empty(TrbBFV->BFV_TIPUSR) .And. Empty(TrbBFV->BFV_GRAUPA)
				if nQtdUsrTot >= TrbBFV->BFV_QTDDE  .And.;
					nQtdUsrTot <= TrbBFV->BFV_QTDATE
					aadd (aRetorno, {TrbBFV->BFV_VALOR,TrbBFV->BFV_PERCEN,TrbBFV->BFV_TIPO})
				Endif
			Endif
			
		Else
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFV->BFV_TIPUSR) .And. ! Empty(TrbBFV->BFV_GRAUPA)
				if cTipUsu == TrbBFV->BFV_TIPUSR .And. cGrauPar == TrbBFV->BFV_GRAUPA
					aadd (aRetorno, {TrbBFV->BFV_VALOR,TrbBFV->BFV_PERCEN,TrbBFV->BFV_TIPO})
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido somente o Grau de parentesco...             Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFV->BFV_GRAUPA)	 .And.  Empty(TrbBFV->BFV_TIPUSR)
				if cGrauPar == TrbBFV->BFV_GRAUPA
					aadd (aRetorno, {TrbBFV->BFV_VALOR,TrbBFV->BFV_PERCEN,TrbBFV->BFV_TIPO})
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido somente o Tipo de Usuario...                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFV->BFV_TIPUSR) .And. Empty(TrbBFV->BFV_GRAUPA)
				if TrbBFV->BFV_TIPUSR == cTipUsu
					aadd (aRetorno, {TrbBFV->BFV_VALOR,TrbBFV->BFV_PERCEN,TrbBFV->BFV_TIPO})
				Endif
			Endif
			
		Endif
		
		TrbBFV->(DbSkip())
	Enddo
	
	TrbBFV->(DbCloseArea())
	
ElseIf nTipo == 3
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Faco uma Sql dos dados que usarei para nao mais ir no banco de dados..Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cSQL := "SELECT BFX_PERCEN,BFX_VALOR,BFX_TIPO,BFX_TIPUSR,BFX_GRAUPA,BFX_QTDDE,BFX_QTDATE FROM "+RetSQLName("BFX")+" WHERE "
	cSQL += "BFX_FILIAL = '"+xFilial("BFX")+"' AND "
	cSQL += "BFX_CODIGO = '"+cCodigo+"' AND "
	cSQL += "BFX_VERSAO = '"+cVersao+"' AND "
	cSQL += "BFX_CODFAI = '"+cCodFai+"'"
	cSQL += " AND D_E_L_E_T_= ''"
	cSQL += " ORDER BY BFX_TIPUSR DESC ,BFX_GRAUPA DESC"
	
	PLSQuery(cSQL,"TrbBFX")
	
	While ! TrbBFX->(Eof())
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё 1 - Desc/Acres eh dado com as informacoes referente a familia do usuario..Ё
		//Ё 2 - Desc/Acres eh dado com as informacoes referente ao usuario...         Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		if TrbBFX->BFX_QTDATE > 0
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFX->BFX_TIPUSR) .And. ! Empty(TrbBFX->BFX_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					TRBBRP->(DbGoTop())
					While ! TRBBRP->(Eof()) .And. !lFlag
						if TRBBIH->BIH_CODTIP == TrbBFX->BFX_TIPUSR .And.;
							TRBBRP->BRP_CODIGO == TrbBFX->BFX_GRAUPA
							nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBFX->BFX_TIPUSR})
							nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBFX->BFX_GRAUPA})
							if nPosTip > 0 .And. nPosGra > 0
								if aQtdUsrTip[nPosTip,2] >= TrbBFX->BFX_QTDDE  .And.;
									aQtdUsrTip[nPosTip,2] <= TrbBFX->BFX_QTDATE .And.;
									aQtdUsrGra[nPosTip,2] >= TrbBFX->BFX_QTDDE  .And.;
									aQtdUsrGra[nPosTip,2] <= TrbBFX->BFX_QTDATE
									aadd (aRetorno, {TrbBFX->BFX_VALOR,TrbBFX->BFX_PERCEN,TrbBFX->BFX_TIPO})
									lFlag  := .T.
								Endif
							Endif
						Endif
						TRBBRP->(DbSkip())
					Enddo
					TRBBIH->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido somente o Grau de parentesco...             Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFX->BFX_GRAUPA)	 .And.  Empty(TrbBFX->BFX_TIPUSR)
				TRBBRP->(DbGoTop())
				While ! TRBBRP->(Eof()) .And. !lFlag
					if TRBBRP->BRP_CODIGO == TrbBFX->BFX_GRAUPA
						nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBFX->BFX_GRAUPA})
						if nPosGra > 0
							if aQtdUsrGra[nPosTip,2] >= TrbBFX->BFX_QTDDE  .And.;
								aQtdUsrGra[nPosTip,2] <= TrbBFX->BFX_QTDATE
								aadd (aRetorno, {TrbBFX->BFX_VALOR,TrbBFX->BFX_PERCEN,TrbBFX->BFX_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBRP->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido somente o Tipo de Usuario...                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFX->BFX_TIPUSR) .And. Empty(TrbBFX->BFX_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					if TRBBIH->BIH_CODTIP == TrbBFX->BFX_TIPUSR
						nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBFX->BFX_TIPUSR})
						if nPosTip > 0
							if aQtdUsrTip[nPosTip,2] >= TrbBFX->BFX_QTDDE  .And.;
								aQtdUsrTip[nPosTip,2] <= TrbBFX->BFX_QTDATE
								aadd (aRetorno, {TrbBFX->BFX_VALOR,TrbBFX->BFX_PERCEN,TrbBFX->BFX_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBIH->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se nada esta preenchido, somente qtd de usuarios 		        Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if Empty(TrbBFX->BFX_TIPUSR) .And. Empty(TrbBFX->BFX_GRAUPA)
				if nQtdUsrTot >= TrbBFX->BFX_QTDDE  .And.;
					nQtdUsrTot <= TrbBFX->BFX_QTDATE
					aadd (aRetorno, {TrbBFX->BFX_VALOR,TrbBFX->BFX_PERCEN,TrbBFX->BFX_TIPO})
				Endif
			Endif
			
		Else
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFX->BFX_TIPUSR) .And. ! Empty(TrbBFX->BFX_GRAUPA)
				if cTipUsu == TrbBFX->BFX_TIPUSR .And. cGrauPar == TrbBFX->BFX_GRAUPA
					aadd (aRetorno, {TrbBFX->BFX_VALOR,TrbBFX->BFX_PERCEN,TrbBFX->BFX_TIPO})
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido somente o Grau de parentesco...             Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFX->BFX_GRAUPA)	 .And.  Empty(TrbBFX->BFX_TIPUSR)
				if cGrauPar == TrbBFX->BFX_GRAUPA
					aadd (aRetorno, {TrbBFX->BFX_VALOR,TrbBFX->BFX_PERCEN,TrbBFX->BFX_TIPO})
				Endif
			Endif
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se esta preenchido somente o Tipo de Usuario...                Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !Empty(TrbBFX->BFX_TIPUSR) .And. Empty(TrbBFX->BFX_GRAUPA)
				if TrbBFX->BFX_TIPUSR == cTipUsu
					aadd (aRetorno, {TrbBFX->BFX_VALOR,TrbBFX->BFX_PERCEN,TrbBFX->BFX_TIPO})
				Endif
			Endif
			
		Endif
		
		TrbBFX->(DbSkip())
	Enddo
	TrbBFX->(DbCloseArea())
Endif

TrbBRP->(DbCloseArea())
TrbBIH->(DbCloseArea())

Return(aRetorno)

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSTXPAD   Ё Autor Ё Antonio de Padua  Ё Data Ё 14.08.2002 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Forma de Cobranca Padrao para Taxa de Adesao...            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Advanced Protheus                                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁObservacaoЁ  														  Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSTXFIX(aCobTx, cCodFor, nUsuarios, nLido, nValCont, nValCob)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da rotina...                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local nValor := 0

If nUsuarios = nLido
   	nValor := Round(nValCont - nValCob, 2)
Else
	nValor := Round(nValCont / nUsuarios, 2)
	nValCob += nValor
Endif    


Return({aCobTx[1],nValor,"",""})
