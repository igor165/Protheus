
#include "PROTHEUS.CH"
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLVLROPC   � Autor � Antonio de Padua  � Data � 14.11.2002 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Forma de Cobranca Padrao para Opcional...                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砄bservacao�  														  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砊ulio       �20.02.03� erro �  erro no campo BBV_PERADE na query...    潮�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
Function PLVLROPC(	cCodInt, cCodEmp, cMatric, cTipReg, _cNivel, cCodPla, cVerPla,;
cCodPro, cVerPro, cCodFor)
Local nCont
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define variaveis da rotina...                                       �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
LOCAL cSQL
LOCAL nFlag     := 0
LOCAL cCodFai   := ""
LOCAL nValor    := 0
LOCAL cNivFai   := ""
LOCAL cTipUsu   := BA1->BA1_TIPUSU
LOCAL cGrauPar  := BA1->BA1_GRAUPA
LOCAL cSexo     := BA1->BA1_SEXO
LOCAL nIdade    := Calc_Idade(dDatabase,BA1->BA1_DATNAS)
LOCAL cCodigo   := ""
Local cCodQtd

If _cNivel == "4"
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Verifica se para este usuario a opcional esta no USUARIO	          �
	//�                                                                     �
	//� opcional NIVEL USUARIO                                     	      �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Busca no nivel USUARIO...                                           �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	cSQL := "SELECT * FROM "+RetSQLName("BZX")+" WHERE "
	cSQL += "BZX_FILIAL = '"+xFilial("BZX")+"' AND "
	cSQL += "BZX_CODOPE = '"+cCodInt+"' AND "
	cSQL += "BZX_CODEMP = '"+cCodEmp+"' AND "
	cSQL += "BZX_MATRIC = '"+cMatric+"' AND "
	cSQL += "BZX_CODOPC = '"+cCodPro+"' AND "
	cSQL += "BZX_VEROPC = '"+cVerPro+"' AND "
	cSQL += "BZX_CODFOR = '"+cCodFor+"' AND "
	cSQL += " D_E_L_E_T_= ''"
	
	PLSQuery(cSQL,"TrbBZX")
	
	While !TrbBZX->(Eof())
		
		if nIdade >= TrbBZX->BZX_IDAINI .And. ;
			nIdade <= TrbBZX->BZX_IDAFIN
			nValor := TrbBZX->BZX_VALFAI
			cCodFai:= ""
			cNivFai:= "0"
			Exit
		Endif
		
		TrbBZX->(DbSkip())
	Enddo
	TrbBZX->(DbCloseArea())
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Verifica se para este usuario o opcional esta no nivel grupo/emp    �
	//�                                                                     �
	//� OPCINAL NIVEL GRUPO/EMPRESA                                         �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
ElseIf _cNivel == "3"
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Verifica se para este usuario a opcional esta na FAMILIA         �
	//�                                                                     �
	//� opcional NIVEL FAMILIA                                           �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Busca no nivel FAMILIA...                                           �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	cSQL := "SELECT BBY_CODFAI, BBY_VALFAI,BBY_TIPUSR,BBY_GRAUPA,BBY_SEXO,BBY_IDAINI,BBY_IDAFIN FROM "+RetSQLName("BBY")+" WHERE "
	cSQL += "BBY_FILIAL = '"+xFilial("BBY")+"' AND "
	cSQL += "BBY_CODOPE = '"+cCodInt+"' AND "
	cSQL += "BBY_CODEMP = '"+cCodEmp+"' AND "
	cSQL += "BBY_MATRIC = '"+cMatric+"' AND "
	cSQL += "BBY_CODOPC = '"+cCodPro+"' AND "
	cSQL += "BBY_VEROPC = '"+cVerPro+"' AND "
	cSQL += "BBY_CODFOR = '"+cCodFor+"' AND "
	cSQL += " D_E_L_E_T_= ''"
	cSQL += " ORDER BY BBY_TIPUSR DESC ,BBY_GRAUPA DESC ,BBY_SEXO DESC"
	
	PLSQuery(cSQL,"TrbBBY")
	
	While !TrbBBY->(Eof())
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para todos o sexo e tipo de usuario e grau de parentesco... �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if !Empty(TrbBBY->BBY_TIPUSR) .And. !Empty(TrbBBY->BBY_GRAUPA) .And. !Empty(TrbBBY->BBY_SEXO)
			if cTipUsu == TrbBBY->BBY_TIPUSR .And. ;
				cGrauPar == TrbBBY->BBY_GRAUPA .And.;
				(cSexo == TrbBBY->BBY_SEXO .Or. TrbBBY->BBY_SEXO == "3")
				if nIdade >= TrbBBY->BBY_IDAINI .And.;
					nIdade <= TrbBBY->BBY_IDAFIN
					nValor := TrbBBY->BBY_VALFAI
					cCodFai:= TrbBBY->BBY_CODFAI
					cNivFai:= "1"
					Exit
				Endif
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para todos o sexo e tipo de usuario...                      �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if !Empty(TrbBBY->BBY_TIPUSR) .And. Empty(TrbBBY->BBY_GRAUPA) .And. !Empty(TrbBBY->BBY_SEXO)
			if cTipUsu == TrbBBY->BBY_TIPUSR .And. ;
				(cSexo == TrbBBY->BBY_SEXO .Or. TrbBBY->BBY_SEXO == "3")
				if nIdade >= TrbBBY->BBY_IDAINI .And.;
					nIdade <= TrbBBY->BBY_IDAFIN
					nValor := TrbBBY->BBY_VALFAI
					cCodFai:= TrbBBY->BBY_CODFAI
					cNivFai:= "1"
					Exit
				EndIf
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para todos o tipo de usuario e grau parentesco...           �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if !Empty(TrbBBY->BBY_TIPUSR) .And. !Empty(TrbBBY->BBY_GRAUPA) .And. Empty(TrbBBY->BBY_SEXO)
			if cTipUsu == TrbBBY->BBY_TIPUSR .And. ;
				cGrauPar == TrbBBY->BBY_GRAUPA
				if nIdade >= TrbBBY->BBY_IDAINI .And. ;
					nIdade <= TrbBBY->BBY_IDAFIN
					nValor := TrbBBY->BBY_VALFAI
					cCodFai:= TrbBBY->BBY_CODFAI
					cNivFai:= "1"
					Exit
				Endif
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para todos o grau de parentesco e sexo                      �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if Empty(TrbBBY->BBY_TIPUSR) .And. !Empty(TrbBBY->BBY_GRAUPA) .And. !Empty(TrbBBY->BBY_SEXO)
			if cGrauPar == TrbBBY->BBY_GRAUPA .And.;
				(cSexo == TrbBBY->BBY_SEXO .Or. TrbBBY->BBY_SEXO == "3")
				if nIdade >= TrbBBY->BBY_IDAINI .And.;
					nIdade <= TrbBBY->BBY_IDAFIN
					nValor := TrbBBY->BBY_VALFAI
					cCodFai:= TrbBBY->BBY_CODFAI
					cNivFai:= "1"
					Exit
				Endif
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para somente o tipo de usuario...                           �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if !Empty(TrbBBY->BBY_TIPUSR) .And. Empty(TrbBBY->BBY_GRAUPA) .And. Empty(TrbBBY->BBY_SEXO)
			if cTipUsu == TrbBBY->BBY_TIPUSR
				if nIdade >= TrbBBY->BBY_IDAINI .And. ;
					nIdade <= TrbBBY->BBY_IDAFIN
					nValor := TrbBBY->BBY_VALFAI
					cCodFai:= TrbBBY->BBY_CODFAI
					cNivFai:= "1"
					Exit
				Endif
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para somente o sexo...                                      �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if Empty(TrbBBY->BBY_TIPUSR) .And. Empty(TrbBBY->BBY_GRAUPA) .And. !Empty(TrbBBY->BBY_SEXO)
			if (cSexo == TrbBBY->BBY_SEXO .Or. TrbBBY->BBY_SEXO == "3")
				if nIdade >= TrbBBY->BBY_IDAINI .And. ;
					nIdade <= TrbBBY->BBY_IDAFIN
					nValor := TrbBBY->BBY_VALFAI
					cCodFai:= TrbBBY->BBY_CODFAI
					cNivFai:= "1"
					Exit
				Endif
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para somente o grau de parentesco...                        �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if Empty(TrbBBY->BBY_TIPUSR) .And. !Empty(TrbBBY->BBY_GRAUPA) .And. Empty(TrbBBY->BBY_SEXO)
			if cGrauPar == TrbBBY->BBY_GRAUPA
				if nIdade >= TrbBBY->BBY_IDAINI .And. ;
					nIdade <= TrbBBY->BBY_IDAFIN
					nValor := TrbBBY->BBY_VALFAI
					cCodFai:= TrbBBY->BBY_CODFAI
					cNivFai:= "1"
					Exit
				Endif
			Endif
		Endif
		
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para somente a faixa...                                     �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if Empty(TrbBBY->BBY_TIPUSR) .And. Empty(TrbBBY->BBY_GRAUPA) .And. Empty(TrbBBY->BBY_SEXO)
			if nIdade >= TrbBBY->BBY_IDAINI .And. ;
				nIdade <= TrbBBY->BBY_IDAFIN
				nValor := TrbBBY->BBY_VALFAI
				cCodFai:= TrbBBY->BBY_CODFAI
				cNivFai:= "1"
				Exit
			Endif
		Endif
		
		TrbBBY->(DbSkip())
	Enddo
	TrbBBY->(DbCloseArea())
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Verifica se para este usuario o opcional esta no nivel grupo/emp    �
	//�                                                                     �
	//� OPCINAL NIVEL GRUPO/EMPRESA                                         �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
ElseIf _cNivel == "2"
	cCodQtd := PlsOpcQtd(	cCodInt,cCodEmp,cConEmp,cVerCon,cSubCon,cVerSub,;
							cCodPla,cVersao,cCodPro,cVerPro,cForPag,cTipUsu,cSexo,cGrauPar)

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Procura opcional o nivel de tipo de usuario...                      �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	cSQL := "SELECT BBX_CODFAI, BBX_VALFAI,BBX_TIPUSR,BBX_GRAUPA,BBX_SEXO,BBX_IDAINI,BBX_IDAFIN FROM "+RetSQLName("BBX")+" WHERE "
	cSQL += "BBX_FILIAL = '"+xFilial("BBX")+"' AND "
	cSQL += "BBX_CODIGO = '"+cCodInt+BA3->BA3_CODEMP+"' AND "
	cSQL += "BBX_NUMCON = '"+BA3->BA3_CONEMP+"' AND "
	cSQL += "BBX_VERCON = '"+BA3->BA3_VERCON+"' AND "
	cSQL += "BBX_SUBCON = '"+BA3->BA3_SUBCON+"' AND "
	cSQL += "BBX_VERSUB = '"+BA3->BA3_VERSUB+"' AND "
	cSQL += "BBX_CODPRO = '"+cCodPla+"' AND "
	cSQL += "BBX_VERPRO = '"+cVerPla+"' AND "
	cSQL += "BBX_CODOPC = '"+cCodPro+"' AND "
	cSQL += "BBX_VEROPC = '"+cVerPro+"' AND "
	cSQL += "BBX_CODFOR = '"+cCodFor+"' AND "
	cSQL += "BBX_CODQTD = '"+cCodQtd+"' AND "
	cSQL += "D_E_L_E_T_ = ''"
	cSQL += " ORDER BY BBX_TIPUSR DESC ,BBX_GRAUPA DESC ,BBX_SEXO DESC"
	
	BBX->(PLSQuery(cSQL,"TrbBBX"))
	
	TrbBBX->(DbGoTop())
	
	While ! TrbBBX->(Eof())
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para todos o sexo e tipo de usuario e grau de parentesco... �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if !Empty(TrbBBX->BBX_TIPUSR) .And. !Empty(TrbBBX->BBX_GRAUPA) .And. !Empty(TrbBBX->BBX_SEXO)
			if cTipUsu == TrbBBX->BBX_TIPUSR .And. ;
				cGrauPar == TrbBBX->BBX_GRAUPA .And.;
				(cSexo == TrbBBX->BBX_SEXO .Or. TrbBBX->BBX_SEXO == "3")
				if nIdade >= TrbBBX->BBX_IDAINI .And.;
					nIdade <= TrbBBX->BBX_IDAFIN
					nValor := TrbBBX->BBX_VALFAI
					cCodFai:= TrbBBX->BBX_CODFAI
					cNivFai:= "4"
					Exit
				Endif
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para todos o sexo e tipo de usuario...                      �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if !Empty(TrbBBX->BBX_TIPUSR) .And. Empty(TrbBBX->BBX_GRAUPA) .And. !Empty(TrbBBX->BBX_SEXO)
			if cTipUsu == TrbBBX->BBX_TIPUSR .And. ;
				(cSexo == TrbBBX->BBX_SEXO .Or. TrbBBX->BBX_SEXO == "3")
				if nIdade >= TrbBBX->BBX_IDAINI .And.;
					nIdade <= TrbBBX->BBX_IDAFIN
					nValor  := TrbBBX->BBX_VALFAI
					cCodFai := TrbBBX->BBX_CODFAI
					cNivFai := "2"
					Exit
				Endif
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para todos o tipo de usuario e grau parentesco...           �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if !Empty(TrbBBX->BBX_TIPUSR) .And. !Empty(TrbBBX->BBX_GRAUPA) .And. Empty(TrbBBX->BBX_SEXO)
			if cTipUsu == TrbBBX->BBX_TIPUSR .And. ;
				cGrauPar == TrbBBX->BBX_GRAUPA
				if nIdade >= TrbBBX->BBX_IDAINI .And.;
					nIdade <= TrbBBX->BBX_IDAFIN
					nValor  := TrbBBX->BBX_VALFAI
					cCodFai := TrbBBX->BBX_CODFAI
					cNivFai := "2"
					Exit
				Endif
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para todos o grau de parentesco e sexo                      �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if Empty(TrbBBX->BBX_TIPUSR) .And. !Empty(TrbBBX->BBX_GRAUPA) .And. !Empty(TrbBBX->BBX_SEXO)
			if cGrauPar == TrbBBX->BBX_GRAUPA .And.;
				(cSexo == TrbBBX->BBX_SEXO .Or. TrbBBX->BBX_SEXO == "3")
				if nIdade >= TrbBBX->BBX_IDAINI .And.;
					nIdade <= TrbBBX->BBX_IDAFIN
					nValor  := TrbBBX->BBX_VALFAI
					cCodFai := TrbBBX->BBX_CODFAI
					cNivFai := "2"
					Exit
				Endif
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para somente o tipo de usuario...                           �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if !Empty(TrbBBX->BBX_TIPUSR) .And. Empty(TrbBBX->BBX_GRAUPA) .And. Empty(TrbBBX->BBX_SEXO)
			if cTipUsu == TrbBBX->BBX_TIPUSR
				if nIdade >= TrbBBX->BBX_IDAINI .And.;
					nIdade <= TrbBBX->BBX_IDAFIN
					nValor  := TrbBBX->BBX_VALFAI
					cCodFai := TrbBBX->BBX_CODFAI
					cNivFai := "2"
					Exit
				Endif
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para somente o sexo...                                      �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if Empty(TrbBBX->BBX_TIPUSR) .And. Empty(TrbBBX->BBX_GRAUPA) .And. !Empty(TrbBBX->BBX_SEXO)
			if (cSexo == TrbBBX->BBX_SEXO .Or. TrbBBX->BBX_SEXO == "3")
				if nIdade >= TrbBBX->BBX_IDAINI .And.;
					nIdade <= TrbBBX->BBX_IDAFIN
					nValor  := TrbBBX->BBX_VALFAI
					cCodFai := TrbBBX->BBX_CODFAI
					cNivFai := "2"
					Exit
				Endif
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para somente o grau de parentesco...                        �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if Empty(TrbBBX->BBX_TIPUSR) .And. !Empty(TrbBBX->BBX_GRAUPA) .And. Empty(TrbBBX->BBX_SEXO)
			if cGrauPar == TrbBBX->BBX_GRAUPA
				if nIdade >= TrbBBX->BBX_IDAINI .And.;
					nIdade <= TrbBBX->BBX_IDAFIN
					nValor  := TrbBBX->BBX_VALFAI
					cCodFai := TrbBBX->BBX_CODFAI
					cNivFai := "2"
					Exit
				Endif
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para somente a faixa...                                     �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if Empty(TrbBBX->BBX_TIPUSR) .And. Empty(TrbBBX->BBX_GRAUPA) .And. Empty(TrbBBX->BBX_SEXO)
			if nIdade >= TrbBBX->BBX_IDAINI .And.;
				nIdade <= TrbBBX->BBX_IDAFIN
				nValor  := TrbBBX->BBX_VALFAI
				cCodFai := TrbBBX->BBX_CODFAI
				cNivFai := "2"
				Exit
			Endif
		Endif
		TrbBBX->(dbSkip())
	Enddo
	
	TrbBBX->(dbCloseArea())
	
ElseIf _cNivel == "1"
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Verifica se para este usuario a opcional esta no PRODUTO         �
	//�                                                                     �
	//� opcional NIVEL PRODUTO                                           �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Busca no nivel PRODUTO...                                           �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	cSQL := "SELECT BBV_CODFAI, BBV_VALFAI,BBV_TIPUSR,BBV_GRAUPA,BBV_SEXO,BBV_IDAINI,BBV_IDAFIN FROM "+RetSQLName("BBV")+" WHERE "
	cSQL += "BBV_FILIAL = '"+xFilial("BBV")+"' AND "
	cSQL += "BBV_CODIGO = '"+cCodInt+cCodPla+"' AND "
	cSQL += "BBV_VERSAO = '"+cVerPla+"' AND "
	cSQL += "BBV_CODOPC = '"+cCodPro+"' AND "
	cSQL += "BBV_VEROPC = '"+cVerPro+"' AND "
	cSQL += "BBV_CODFOR = '"+cCodFor+"' AND "
	cSQL += " D_E_L_E_T_= ''"
	cSQL += " ORDER BY BBV_TIPUSR DESC ,BBV_GRAUPA DESC ,BBV_SEXO DESC"
	
	PLSQuery(cSQL,"TrbBBV")
	
	While !TrbBBV->(Eof())
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para todos o sexo e tipo de usuario e grau de parentesco... �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if !Empty(TrbBBV->BBV_TIPUSR) .And. !Empty(TrbBBV->BBV_GRAUPA) .And. !Empty(TrbBBV->BBV_SEXO)
			if cTipUsu == TrbBBV->BBV_TIPUSR .And. ;
				cGrauPar == TrbBBV->BBV_GRAUPA .And.;
				(cSexo == TrbBBV->BBV_SEXO .Or. TrbBBV->BBV_SEXO == "3")
				if nIdade >= TrbBBV->BBV_IDAINI .And.;
					nIdade <= TrbBBV->BBV_IDAFIN
					nValor := TrbBBV->BBV_VALFAI
					cCodFai:= TrbBBV->BBV_CODFAI
					cNivFai:= "3"
					Exit
				Endif
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para todos o sexo e tipo de usuario...                      �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if !Empty(TrbBBV->BBV_TIPUSR) .And. Empty(TrbBBV->BBV_GRAUPA) .And. !Empty(TrbBBV->BBV_SEXO)
			if cTipUsu == TrbBBV->BBV_TIPUSR .And. ;
				(cSexo == TrbBBV->BBV_SEXO .Or. TrbBBV->BBV_SEXO == "3")
				if nIdade >= TrbBBV->BBV_IDAINI .And.;
					nIdade <= TrbBBV->BBV_IDAFIN
					nValor := TrbBBV->BBV_VALFAI
					cCodFai:= TrbBBV->BBV_CODFAI
					cNivFai:= "3"
					Exit
				EndIf
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para todos o tipo de usuario e grau parentesco...           �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if !Empty(TrbBBV->BBV_TIPUSR) .And. !Empty(TrbBBV->BBV_GRAUPA) .And. Empty(TrbBBV->BBV_SEXO)
			if cTipUsu == TrbBBV->BBV_TIPUSR .And. ;
				cGrauPar == TrbBBV->BBV_GRAUPA
				if nIdade >= TrbBBV->BBV_IDAINI .And. ;
					nIdade <= TrbBBV->BBV_IDAFIN
					nValor := TrbBBV->BBV_VALFAI
					cCodFai:= TrbBBV->BBV_CODFAI
					cNivFai:= "3"
					Exit
				Endif
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para todos o grau de parentesco e sexo                      �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if Empty(TrbBBV->BBV_TIPUSR) .And. !Empty(TrbBBV->BBV_GRAUPA) .And. !Empty(TrbBBV->BBV_SEXO)
			if cGrauPar == TrbBBV->BBV_GRAUPA .And.;
				(cSexo == TrbBBV->BBV_SEXO .Or. TrbBBV->BBV_SEXO == "3")
				if nIdade >= TrbBBV->BBV_IDAINI .And.;
					nIdade <= TrbBBV->BBV_IDAFIN
					nValor := TrbBBV->BBV_VALFAI
					cCodFai:= TrbBBV->BBV_CODFAI
					cNivFai:= "3"
					Exit
				Endif
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para somente o tipo de usuario...                           �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if !Empty(TrbBBV->BBV_TIPUSR) .And. Empty(TrbBBV->BBV_GRAUPA) .And. Empty(TrbBBV->BBV_SEXO)
			if cTipUsu == TrbBBV->BBV_TIPUSR
				if nIdade >= TrbBBV->BBV_IDAINI .And. ;
					nIdade <= TrbBBV->BBV_IDAFIN
					nValor := TrbBBV->BBV_VALFAI
					cCodFai:= TrbBBV->BBV_CODFAI
					cNivFai:= "3"
					Exit
				Endif
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para somente o sexo...                                      �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if Empty(TrbBBV->BBV_TIPUSR) .And. Empty(TrbBBV->BBV_GRAUPA) .And. !Empty(TrbBBV->BBV_SEXO)
			if (cSexo == TrbBBV->BBV_SEXO .Or. TrbBBV->BBV_SEXO == "3")
				if nIdade >= TrbBBV->BBV_IDAINI .And. ;
					nIdade <= TrbBBV->BBV_IDAFIN
					nValor := TrbBBV->BBV_VALFAI
					cCodFai:= TrbBBV->BBV_CODFAI
					cNivFai:= "3"
					Exit
				Endif
			Endif
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para somente o grau de parentesco...                        �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if Empty(TrbBBV->BBV_TIPUSR) .And. !Empty(TrbBBV->BBV_GRAUPA) .And. Empty(TrbBBV->BBV_SEXO)
			if cGrauPar == TrbBBV->BBV_GRAUPA
				if nIdade >= TrbBBV->BBV_IDAINI .And. ;
					nIdade <= TrbBBV->BBV_IDAFIN
					nValor := TrbBBV->BBV_VALFAI
					cCodFai:= TrbBBV->BBV_CODFAI
					cNivFai:= "3"
					Exit
				Endif
			Endif
		Endif
		
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Procura para somente a faixa...                                     �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if Empty(TrbBBV->BBV_TIPUSR) .And. Empty(TrbBBV->BBV_GRAUPA) .And. Empty(TrbBBV->BBV_SEXO)
			if nIdade >= TrbBBV->BBV_IDAINI .And. ;
				nIdade <= TrbBBV->BBV_IDAFIN
				nValor := TrbBBV->BBV_VALFAI
				cCodFai:= TrbBBV->BBV_CODFAI
				cNivFai:= "3"
				Exit
			Endif
		Endif
		
		TrbBBV->(DbSkip())
	Enddo
	TrbBBV->(DbCloseArea())
Endif

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Le tabela de descontos de acordo com tabela de faixa etaria...      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
if cNivFai == "1"
	cCodigo := cCodInt+cCodEmp+cMatric
	nFlag := 1
ElseIf cNivFai == "2"
	cCodigo := cCodInt+cCodEmp
	nFlag := 2
Elseif cNivFai == "3"
	cCodigo := cCodInt+BA3->BA3_CODPLA
	nFlag := 3
Endif
if nValor > 0
	aVetRet := PLSMFPDeOp(cCodigo,BA3->BA3_VERSAO,cTipReg,cGrauPar,cSexo,cCodInt+cCodEmp+cMatric,nValor,cCodQtd,cCodFai,nFlag,BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB,BA3->BA3_CODPLA)
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
Endif

Return({if(nValor>0 .And. (!Empty(cCodFai) .Or. cNivFai = "0"),.T.,.F.),nValor,cCodFai,cNivFai,cCodQtd})

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSMFPDeOp � Autor � Antonio de Padua  � Data � 21.08.2002 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Desconto por faixa etaria Opcional                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cCodigo  - Codigo de PLano								  潮�
北�          � cVersao  - Versao do Plano (Ex.: 001,002)				  潮�
北�          � cTipUsu  - Tipo do Usuario (Ex.: T=Titular, D=Dependente)  潮�
北�          � cGrauPar - Grau de Parentesco (Ex.: 01=Filho,02=Filha)     潮�
北�          � cSexo    - Sexo do Usuario (Ex.: 1=Masculino)              潮�
北�          � cMatric  - Matricula da Familia 							  潮�
北�          � nVlrFai  - Valor da Faixa Etaria (Para calculo)            潮�
北�          � cCodFai  - Codigo da Faixa (Para procurar o desconto)      潮�
北�          � nTipo    - Flag para saber se foi Faixa da Familia/Empresa/Produto 潮�
北�          � cConEmp  - Contrato Empresa   						      潮�
北�          � cVerCon  - Versao do Contrato                              潮�
北�          � cSubCon  - Sub Contrato                                    潮�
北�          � cVerSub  - Versao do Sub Contrato                          潮�
北�          � cCodPla  - Codigo do Plano sem Operadora                   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
//Retorna o {Valor do Desconto, Percentual de Desconto}
//
//
/*/
Function PLSMFPDeOp(cCodigo,cVersao,cTipUsu,cGrauPar,cSexo,cMatric,nVlrFai,cCodQtd,cCodFai,nTipo,cConEmp,cVerCon,cSubCon,cVerSub,cCodPla)

Local nQtdUsr := 0
Local aRetorno := {}
Local aRetDesFai := {}
Local cSql

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Verifico quantos usuarios existem deste tipo na familia...          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Local aQtdUsrTip := PLSQTDUSR(cMatric,1,"VET")
Local aQtdUsrGra := PLSQTDUSR(cMatric,2,"VET")
Local nQtdUsrTot := PLSQTDUSR(cMatric)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Pesquiso com todos os parametros...                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
cSQL := "SELECT BIH_CODTIP FROM "+RetSQLName("BIH")+" WHERE "
cSQL += " D_E_L_E_T_= ''"
PLSQuery(cSQL,"TrbBIH")

cSQL := "SELECT BRP_CODIGO FROM "+RetSQLName("BRP")+" WHERE "
cSQL += " D_E_L_E_T_= ''"
PLSQuery(cSQL,"TrbBRP")

If nTipo == 1
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Faco uma Sql dos dados que usarei para nao mais ir no banco de dados..�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	cSQL := "SELECT BG0_PERCEN, BG0_VALOR,BG0_TIPO,BG0_TIPUSR,BG0_GRAUPA,BG0_QTDDE,BG0_QTDATE FROM "+RetSQLName("BG0")+" WHERE "
	cSQL += "BG0_FILIAL = '"+xFilial("BG0")+"' AND "
	cSQL += "BG0_CODOPE = '"+Substr(cMatric,1,4)+"' AND "
	cSQL += "BG0_CODEMP = '"+Substr(cMatric,5,4)+"' AND "
	cSQL += "BG0_MATRIC = '"+Substr(cMatric,9,6)+"' AND "
	cSQL += "BG0_CODFAI = '"+cCodFai+"'"
	cSQL += " AND D_E_L_E_T_= ''"
	cSQL += " ORDER BY BG0_TIPUSR DESC ,BG0_GRAUPA DESC"
	
	PLSQuery(cSQL,"TrbBG0")
	
	While ! TrbBG0->(Eof())
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� 1 - Desc/Acres eh dado com as informacoes referente a familia do usuario..�
		//� 2 - Desc/Acres eh dado com as informacoes referente ao usuario...         �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if TrbBG0->BG0_QTDATE > 0
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...�
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBG0->BG0_TIPUSR) .And. ! Empty(TrbBG0->BG0_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					TRBBRP->(DbGoTop())
					While ! TRBBRP->(Eof()) .And. !lFlag
						if TRBBIH->BIH_CODTIP == TrbBG0->BG0_TIPUSR .And.;
							TRBBRP->BRP_CODIGO == TrbBG0->BG0_GRAUPA
							nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBG0->BG0_TIPUSR})
							nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBG0->BG0_GRAUPA})
							if nPosTip > 0 .And. nPosGra > 0
								if aQtdUsrTip[nPosTip,2] >= TrbBG0->BG0_QTDDE  .And.;
									aQtdUsrTip[nPosTip,2] <= TrbBG0->BG0_QTDATE .And.;
									aQtdUsrGra[nPosTip,2] >= TrbBG0->BG0_QTDDE  .And.;
									aQtdUsrGra[nPosTip,2] <= TrbBG0->BG0_QTDATE
									aadd (aRetorno, {TrbBG0->BG0_VALOR,TrbBG0->BG0_PERCEN,TrbBG0->BG0_TIPO})
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
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido somente o Grau de parentesco...             �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBG0->BG0_GRAUPA)	 .And.  Empty(TrbBG0->BG0_TIPUSR)
				TRBBRP->(DbGoTop())
				While ! TRBBRP->(Eof()) .And. !lFlag
					if TRBBRP->BRP_CODIGO == TrbBG0->BG0_GRAUPA
						nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBG0->BG0_GRAUPA})
						if nPosGra > 0
							if aQtdUsrGra[nPosTip,2] >= TrbBG0->BG0_QTDDE  .And.;
								aQtdUsrGra[nPosTip,2] <= TrbBG0->BG0_QTDATE
								aadd (aRetorno, {TrbBG0->BG0_VALOR,TrbBG0->BG0_PERCEN,TrbBG0->BG0_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBRP->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido somente o Tipo de Usuario...                �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBG0->BG0_TIPUSR) .And. Empty(TrbBG0->BG0_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					if TRBBIH->BIH_CODTIP == TrbBG0->BG0_TIPUSR
						nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBG0->BG0_TIPUSR})
						if nPosTip > 0
							if aQtdUsrTip[nPosTip,2] >= TrbBG0->BG0_QTDDE  .And.;
								aQtdUsrTip[nPosTip,2] <= TrbBG0->BG0_QTDATE
								aadd (aRetorno, {TrbBG0->BG0_VALOR,TrbBG0->BG0_PERCEN,TrbBG0->BG0_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBIH->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se nada esta preenchido, somente qtd de usuarios 		        �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if Empty(TrbBG0->BG0_TIPUSR) .And. Empty(TrbBG0->BG0_GRAUPA)
				if nQtdUsrTot >= TrbBG0->BG0_QTDDE  .And.;
					nQtdUsrTot <= TrbBG0->BG0_QTDATE
					aadd (aRetorno, {TrbBG0->BG0_VALOR,TrbBG0->BG0_PERCEN,TrbBG0->BG0_TIPO})
				Endif
			Endif
			
		Else
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...�
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBG0->BG0_TIPUSR) .And. ! Empty(TrbBG0->BG0_GRAUPA)
				if cTipUsu == TrbBG0->BG0_TIPUSR .And. cGrauPar == TrbBG0->BG0_GRAUPA
					aadd (aRetorno, {TrbBG0->BG0_VALOR,TrbBG0->BG0_PERCEN,TrbBG0->BG0_TIPO})
				Endif
			Endif
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido somente o Grau de parentesco...             �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBG0->BG0_GRAUPA)	 .And.  Empty(TrbBG0->BG0_TIPUSR)
				if cGrauPar == TrbBG0->BG0_GRAUPA
					aadd (aRetorno, {TrbBG0->BG0_VALOR,TrbBG0->BG0_PERCEN,TrbBG0->BG0_TIPO})
				Endif
			Endif
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido somente o Tipo de Usuario...                �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBG0->BG0_TIPUSR) .And. Empty(TrbBG0->BG0_GRAUPA)
				if TrbBG0->BG0_TIPUSR == cTipUsu
					aadd (aRetorno, {TrbBG0->BG0_VALOR,TrbBG0->BG0_PERCEN,TrbBG0->BG0_TIPO})
				Endif
			Endif
			
		Endif
		
		TrbBG0->(DbSkip())
	Enddo
	TrbBG0->(DbCloseArea())
	
ElseIf nTipo == 2
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Faco uma Sql dos dados que usarei para nao mais ir no banco de dados..�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	cSQL := "SELECT BGW_PERCEN,BGW_VALOR,BGW_TIPO,BGW_TIPUSR,BGW_GRAUPA,BGW_QTDDE,BGW_QTDATE,BGW_DATDE,BGW_DATATE FROM "+RetSQLName("BGW")+" WHERE "
	cSQL += "BGW_FILIAL = '"+xFilial("BGW")+"' AND "
	cSQL += "BGW_CODIGO = '"+cCodigo+"' AND "
	cSQL += "BGW_NUMCON = '"+cConEmp+"' AND "
	cSQL += "BGW_VERCON = '"+cVerCon+"' AND "
	cSQL += "BGW_SUBCON = '"+cSubCon+"' AND "
	cSQL += "BGW_VERSUB = '"+cVerSub+"' AND "
	cSQL += "BGW_CODPRO = '"+cCodPla+"' AND "
	cSQL += "BGW_VERPRO = '"+cVersao+"' AND "
	cSQL += "BGW_CODFAI = '"+cCodFai+"' AND "
	cSQL += "BGW_CODQTD = '"+cCodQtd+"'"
	cSQL += " AND D_E_L_E_T_= ''"
	cSQL += " ORDER BY BGW_TIPUSR DESC ,BGW_GRAUPA DESC"
	
	BGW->(PLSQuery(cSQL,"TrbBGW"))
	
	While ! TrbBGW->(Eof())
		
		If ! PLSMDesVld(TrbBGW->BGW_DATDE, TrbBGW->BGW_DATATE)
			TrbBGW->(DbSkip())
			Loop
		Endif
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� 1 - Desc/Acres eh dado com as informacoes referente a familia do usuario..�
		//� 2 - Desc/Acres eh dado com as informacoes referente ao usuario...         �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if  TrbBGW->BGW_QTDATE > 0
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...�
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBGW->BGW_TIPUSR) .And. ! Empty(TrbBGW->BGW_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					TRBBRP->(DbGoTop())
					While ! TRBBRP->(Eof()) .And. !lFlag
						if TRBBIH->BIH_CODTIP == TrbBGW->BGW_TIPUSR .And.;
							TRBBRP->BRP_CODIGO == TrbBGW->BGW_GRAUPA
							nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBGW->BGW_TIPUSR})
							nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBGW->BGW_GRAUPA})
							if nPosTip > 0 .And. nPosGra > 0
								if aQtdUsrTip[nPosTip,2] >= TrbBGW->BGW_QTDDE  .And.;
									aQtdUsrTip[nPosTip,2] <= TrbBGW->BGW_QTDATE .And.;
									aQtdUsrGra[nPosTip,2] >= TrbBGW->BGW_QTDDE  .And.;
									aQtdUsrGra[nPosTip,2] <= TrbBGW->BGW_QTDATE
									aadd (aRetorno, {TrbBGW->BGW_VALOR,TrbBGW->BGW_PERCEN,TrbBGW->BGW_TIPO})
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
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido somente o Grau de parentesco...             �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBGW->BGW_GRAUPA)	 .And.  Empty(TrbBGW->BGW_TIPUSR)
				TRBBRP->(DbGoTop())
				While ! TRBBRP->(Eof()) .And. !lFlag
					if TRBBRP->BRP_CODIGO == TrbBGW->BGW_GRAUPA
						nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBGW->BGW_GRAUPA})
						if nPosGra > 0
							if aQtdUsrGra[nPosTip,2] >= TrbBGW->BGW_QTDDE  .And.;
								aQtdUsrGra[nPosTip,2] <= TrbBGW->BGW_QTDATE
								aadd (aRetorno, {TrbBGW->BGW_VALOR,TrbBGW->BGW_PERCEN,TrbBGW->BGW_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBRP->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido somente o Tipo de Usuario...                �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBGW->BGW_TIPUSR) .And. Empty(TrbBGW->BGW_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					if TRBBIH->BIH_CODTIP == TrbBGW->BGW_TIPUSR
						nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBGW->BGW_TIPUSR})
						if nPosTip > 0
							if aQtdUsrTip[nPosTip,2] >= TrbBGW->BGW_QTDDE  .And.;
								aQtdUsrTip[nPosTip,2] <= TrbBGW->BGW_QTDATE
								aadd (aRetorno, {TrbBGW->BGW_VALOR,TrbBGW->BGW_PERCEN,TrbBGW->BGW_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBIH->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se nada esta preenchido, somente qtd de usuarios 		        �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if Empty(TrbBGW->BGW_TIPUSR) .And. Empty(TrbBGW->BGW_GRAUPA)
				if nQtdUsrTot >= TrbBGW->BGW_QTDDE  .And.;
					nQtdUsrTot <= TrbBGW->BGW_QTDATE
					aadd (aRetorno, {TrbBGW->BGW_VALOR,TrbBGW->BGW_PERCEN,TrbBGW->BGW_TIPO})
				Endif
			Endif
			
		Else
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...�
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBGW->BGW_TIPUSR) .And. ! Empty(TrbBGW->BGW_GRAUPA)
				if cTipUsu == TrbBGW->BGW_TIPUSR .And. cGrauPar == TrbBGW->BGW_GRAUPA
					aadd (aRetorno, {TrbBGW->BGW_VALOR,TrbBGW->BGW_PERCEN,TrbBGW->BGW_TIPO})
				Endif
			Endif
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido somente o Grau de parentesco...             �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBGW->BGW_GRAUPA)	 .And.  Empty(TrbBGW->BGW_TIPUSR)
				if cGrauPar == TrbBGW->BGW_GRAUPA
					aadd (aRetorno, {TrbBGW->BGW_VALOR,TrbBGW->BGW_PERCEN,TrbBGW->BGW_TIPO})
				Endif
			Endif
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido somente o Tipo de Usuario...                �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBGW->BGW_TIPUSR) .And. Empty(TrbBGW->BGW_GRAUPA)
				if TrbBGW->BGW_TIPUSR == cTipUsu
					aadd (aRetorno, {TrbBGW->BGW_VALOR,TrbBGW->BGW_PERCEN,TrbBGW->BGW_TIPO})
				Endif
			Endif
			
		Endif
		
		TrbBGW->(DbSkip())
	Enddo
	
	TrbBGW->(DbCloseArea())
	
ElseIf nTipo == 3
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Faco uma Sql dos dados que usarei para nao mais ir no banco de dados..�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	cSQL := "SELECT BFW_PERCEN,BFW_VALOR,BFW_TIPO,BFW_TIPUSR,BFW_GRAUPA,BFW_QTDDE,BFW_QTDATE FROM "+RetSQLName("BFW")+" WHERE "
	cSQL += "BFW_FILIAL = '"+xFilial("BFW")+"' AND "
	cSQL += "BFW_CODIGO = '"+cCodigo+"' AND "
	cSQL += "BFW_VERSAO = '"+cVersao+"' AND "
	cSQL += "BFW_CODFAI = '"+cCodFai+"'"
	cSQL += " AND D_E_L_E_T_= ''"
	cSQL += " ORDER BY BFW_TIPUSR DESC ,BFW_GRAUPA DESC"
	
	PLSQuery(cSQL,"TrbBFW")
	
	While ! TrbBFW->(Eof())
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� 1 - Desc/Acres eh dado com as informacoes referente a familia do usuario..�
		//� 2 - Desc/Acres eh dado com as informacoes referente ao usuario...         �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		if TrbBFW->BFW_QTDATE > 0
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...�
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBFW->BFW_TIPUSR) .And. ! Empty(TrbBFW->BFW_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					TRBBRP->(DbGoTop())
					While ! TRBBRP->(Eof()) .And. !lFlag
						if TRBBIH->BIH_CODTIP == TrbBFW->BFW_TIPUSR .And.;
							TRBBRP->BRP_CODIGO == TrbBFW->BFW_GRAUPA
							nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBFW->BFW_TIPUSR})
							nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBFW->BFW_GRAUPA})
							if nPosTip > 0 .And. nPosGra > 0
								if aQtdUsrTip[nPosTip,2] >= TrbBFW->BFW_QTDDE  .And.;
									aQtdUsrTip[nPosTip,2] <= TrbBFW->BFW_QTDATE .And.;
									aQtdUsrGra[nPosTip,2] >= TrbBFW->BFW_QTDDE  .And.;
									aQtdUsrGra[nPosTip,2] <= TrbBFW->BFW_QTDATE
									aadd (aRetorno, {TrbBFW->BFW_VALOR,TrbBFW->BFW_PERCEN,TrbBFW->BFW_TIPO})
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
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido somente o Grau de parentesco...             �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBFW->BFW_GRAUPA)	 .And.  Empty(TrbBFW->BFW_TIPUSR)
				TRBBRP->(DbGoTop())
				While ! TRBBRP->(Eof()) .And. !lFlag
					if TRBBRP->BRP_CODIGO == TrbBFW->BFW_GRAUPA
						nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBFW->BFW_GRAUPA})
						if nPosGra > 0
							if aQtdUsrGra[nPosTip,2] >= TrbBFW->BFW_QTDDE  .And.;
								aQtdUsrGra[nPosTip,2] <= TrbBFW->BFW_QTDATE
								aadd (aRetorno, {TrbBFW->BFW_VALOR,TrbBFW->BFW_PERCEN,TrbBFW->BFW_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBRP->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido somente o Tipo de Usuario...                �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBFW->BFW_TIPUSR) .And. Empty(TrbBFW->BFW_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					if TRBBIH->BIH_CODTIP == TrbBFW->BFW_TIPUSR
						nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBFW->BFW_TIPUSR})
						if nPosTip > 0
							if aQtdUsrTip[nPosTip,2] >= TrbBFW->BFW_QTDDE  .And.;
								aQtdUsrTip[nPosTip,2] <= TrbBFW->BFW_QTDATE
								aadd (aRetorno, {TrbBFW->BFW_VALOR,TrbBFW->BFW_PERCEN,TrbBFW->BFW_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBIH->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se nada esta preenchido, somente qtd de usuarios 		        �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if Empty(TrbBFW->BFW_TIPUSR) .And. Empty(TrbBFW->BFW_GRAUPA)
				if nQtdUsrTot >= TrbBFW->BFW_QTDDE  .And.;
					nQtdUsrTot <= TrbBFW->BFW_QTDATE
					aadd (aRetorno, {TrbBFW->BFW_VALOR,TrbBFW->BFW_PERCEN,TrbBFW->BFW_TIPO})
				Endif
			Endif
			
		Else
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...�
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBFW->BFW_TIPUSR) .And. ! Empty(TrbBFW->BFW_GRAUPA)
				if cTipUsu == TrbBFW->BFW_TIPUSR .And. cGrauPar == TrbBFW->BFW_GRAUPA
					aadd (aRetorno, {TrbBFW->BFW_VALOR,TrbBFW->BFW_PERCEN,TrbBFW->BFW_TIPO})
				Endif
			Endif
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido somente o Grau de parentesco...             �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBFW->BFW_GRAUPA)	 .And.  Empty(TrbBFW->BFW_TIPUSR)
				if cGrauPar == TrbBFW->BFW_GRAUPA
					aadd (aRetorno, {TrbBFW->BFW_VALOR,TrbBFW->BFW_PERCEN,TrbBFW->BFW_TIPO})
				Endif
			Endif
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//� Verifico se esta preenchido somente o Tipo de Usuario...                �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			if !Empty(TrbBFW->BFW_TIPUSR) .And. Empty(TrbBFW->BFW_GRAUPA)
				if TrbBFW->BFW_TIPUSR == cTipUsu
					aadd (aRetorno, {TrbBFW->BFW_VALOR,TrbBFW->BFW_PERCEN,TrbBFW->BFW_TIPO})
				Endif
			Endif
			
		Endif
		
		TrbBFW->(DbSkip())
	Enddo
	TrbBFW->(DbCloseArea())
Endif

TrbBRP->(DbCloseArea())
TrbBIH->(DbCloseArea())

Return(aRetorno)


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PlsOpcQtd  � Autor 砏agner Mobile Costa� Data � 14.11.2003 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Busca a tabela a indica de qual tabela devera ser utilizada潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus                                          潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
Function PlsOpcQtd(	cCodInt,cCodEmp,cConEmp,cVerCon,cSubCon,cVerSub,;
					cCodPla,cVersao,cCodOpc,cVerOpc,cForPag,cTipUsu,cSexo,cGrauPar)
Local nPos
Local cCodQtd := "ZZZ"
Local aQtdUsu
Local nQtdusu := 0

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Guardo Quantidade de Usuarios do Sub Contrato...                    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
aQtdUsu := PLQTUSEMP(cCodInt,cCodEmp,cConEmp,cVerCon,cSubCon,cVerSub)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Procura para todos as chaves preenchidas...                         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
cSQL := "SELECT BBW_CODFAI, BBW_TIPUSR,BBW_SEXO,BBW_QTDMIN,"
cSql += "BBW_QTDMAX FROM "+RetSQLName("BBW")+" WHERE "
cSQL += "BBW_FILIAL = '"+xFilial("BBW")+"' AND "
cSQL += "BBW_CODIGO = '"+cCodInt+cCodEmp+"' AND "
cSQL += "BBW_NUMCON = '"+cConEmp+"' AND "
cSQL += "BBW_VERCON = '"+cVerCon+"' AND "
cSQL += "BBW_SUBCON = '"+cSubCon+"' AND "
cSQL += "BBW_VERSUB = '"+cVerSub+"' AND "
cSQL += "BBW_CODPRO = '"+cCodPla+"' AND "
cSQL += "BBW_VERPRO = '"+cVersao+"' AND "
cSQL += "BBW_CODOPC = '"+cCodOpc+"' AND "
cSQL += "BBW_VEROPC = '"+cVerOpc+"' AND "
cSQL += "BBW_CODFOR = '"+cForPag+"' AND "
cSQL += "D_E_L_E_T_ = ''"

PLSQuery(cSQL,"TrbBBW")

While !TrbBBW->(Eof())
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Procura para todos o sexo e tipo de usuario... 					  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	if !Empty(TrbBBW->BBW_TIPUSR) .And. !Empty(TrbBBW->BBW_SEXO)
		if cTipUsu == TrbBBW->BBW_TIPUSR .And. ;
			(cSexo == TrbBBW->BBW_SEXO .Or. TrbBBW->BBW_SEXO == "3")
			nPos := aScan(aQtdUsu,{|x|x[1]==TrbBBW->BBW_TIPUSR .AND. (x[2]==TrbBBW->BBW_SEXO .OR. TrbBBW->BBW_SEXO == "3")})
			if nPos > 0
				if aQtdUsu[nPos,3] >= TrbBBW->BBW_QTDMIN .And.;
					aQtdUsu[nPos,3] <= TrbBBW->BBW_QTDMAX
					cCodQtd := TrbBBW->BBW_CODFAI
					Exit
				Endif
			Endif
		Endif
	Endif
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Procura para todos o tipo de usuario								 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	if !Empty(TrbBBW->BBW_TIPUSR) .And. (Empty(TrbBBW->BBW_SEXO) .or. TrbBBW->BBW_SEXO == "3")
		if cTipUsu == TrbBBW->BBW_TIPUSR
			nQtdUsu := 0
			For nPos := 1 To Len(aQtdUsu)
				nQtdUsu += If(aQtdUsu[nPos][1]==TrbBBW->BBW_TIPUSR,aQtdUsu[nPos][3], 0)
			Next
			if 	nQtdusu >= TrbBBW->BBW_QTDMIN .And.;
				nQtdUsu <= TrbBBW->BBW_QTDMAX
				cCodQtd := TrbBBW->BBW_CODFAI
				Exit
			Endif
		Endif
	Endif
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Procura para todos os sexos                                         �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	if Empty(TrbBBW->BBW_TIPUSR) .And. !Empty(TrbBBW->BBW_SEXO)
		if (cSexo == TrbBBW->BBW_SEXO .Or. TrbBBW->BBW_SEXO == "3")
			nQtdUsu := 0
			For nPos := 1 To Len(aQtdUsu)
				nQtdUsu += If(aQtdUsu[nPos][2]==TrbBBW->BBW_SEXO .OR. TrbBBW->BBW_SEXO == "3",aQtdUsu[nPos][3], 0)
			Next
			if 	nQtdusu >= TrbBBW->BBW_QTDMIN .And.;
				nQtdUsu <= TrbBBW->BBW_QTDMAX
				cCodQtd := TrbBBW->BBW_CODFAI
				Exit
			Endif
		Endif
	Endif
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Procura para somente a faixa...                                     �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	if Empty(TrbBBW->BBW_TIPUSR) .And. (Empty(TrbBBW->BBW_SEXO) .or. TrbBBW->BBW_SEXO == "3")
		nQtdUsu := 0
		For nPos := 1 To Len(aQtdUsu)
			nQtdUsu += aQtdUsu[nPos][3]
		Next
		if 	nQtdusu >= TrbBBW->BBW_QTDMIN .And.;
			nQtdUsu <= TrbBBW->BBW_QTDMAX
			cCodQtd := TrbBBW->BBW_CODFAI
			Exit
		Endif
	Endif
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Procura quando nem existe um tratamento de quantidade de usuarios...�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	if Empty(TrbBBW->BBW_TIPUSR) .And. (Empty(TrbBBW->BBW_SEXO) .or. TrbBBW->BBW_SEXO == "3")
		if 	TrbBBW->BBW_QTDMIN == 0 .And.;
			TrbBBW->BBW_QTDMAX == 999999
			cCodQtd := TrbBBW->BBW_CODFAI
			Exit
		Endif
	Endif
	
	
	TrbBBW->(dbSkip())
Enddo
TrbBBW->(dbCloseArea())


Return cCodQtd
