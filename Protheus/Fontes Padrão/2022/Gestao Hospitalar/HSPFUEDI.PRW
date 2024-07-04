#include "protheus.ch"
#include "topconn.ch"
#include "HSPFUEDI.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   ³ HS_InRemes º Autor ³ José Orfeu     º Data ³ 26/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao  ³ Verifica se a guia esta no remessa gerada                º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cRegAte - Numero do registro de atendimento do paciente  ³±±
±±³            ³ cNrSeqG - Numero da guia do atendimento do paciente      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ lRet    - Retonar .T. se a guia for encontrada na remessa³±±
±±³            ³           caso contrario retorna .F.                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_InRemes(cRegAte, cNrSeqG)
 Local lRet := .F., cAliasOld := Alias(), cSql := ""

 cSql := "SELECT GR0_REGATE FROM " + RetSqlName("GR0") + " " + ;
         "WHERE GR0_FILIAL = '" + xFilial("GR0") + "' AND D_E_L_E_T_ <> '*' AND " + ;
         "GR0_REGATE = '" + cRegAte + "' AND GR0_NRSEQG = '" + cNrSeqG + "'"

 TCQuery cSql New Alias "TMPREMES"

 lRet := TMPREMES->(!Eof())


 DbCloseArea()

 DbSelectArea(cAliasOld)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   ³ HS_TICnt º Autor ³ José Orfeu       º Data ³ 26/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao  ³ Calcula os totas da remessa                              º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cRegAte  - Numero do registro de atendimento do paciente ³±±
±±³            ³ cNrSeqG  - Numero da guia do atendimento do paciente     ³±±
±±³            ³ lIsTotal - Define se a quantidade entra no calculo, caso ³±±
±±³            ³            .T. multiplica pela quantidade, caso .F. não. ³±±
±±³            ³ cChvRem  - Chave de quebra da remessa para calculo do    ³±±
±±³            ³            total da remesa.                              ³±±  */

//Verificar como vai ficar o esquema de totalização ja que não é mais obrigatório o uso do arquivo GR0.
                                                                                 /*

±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ {nTotVal, nTotIte, nTotCnt, nTotMatM, nTotTaxD, nTotProc,³±±
±±³            ³ nTotFilm}                                                ³±±
±±³            ³ nTotVal - Retorna o valor total dependendo dos parametros³±±
±±³            ³           cRegAte e cNrSeqG, se os dois parametros forem ³±±
±±³            ³           informados retorna o total da guia, se somente ³±±
±±³            ³           o cRegAte for informado retorna o total do aten³±±
±±³            ³           dimento e caso nenhum dos dois forem informados³±±
±±³            ³           retorna o total da remessa, e caso lIsTotal for³±±
±±³            ³           igual a .F. nao usa a quantidade nos calculos. ³±±
±±³            ³                                                          ³±±
±±³            ³ nTotIte - Retorna o total de itens considerando tabem os ³±±
±±³            ³           detalhes citados acima.                        ³±±
±±³            ³                                                          ³±±
±±³            ³ nTotCnt - Retorna o total de guias ou atendimentos consi-³±±
±±³            ³           derando tambem os detalhes citados acima.      ³±±
±±³            ³                                                          ³±±
±±³            ³ nTotMatM- Total de material e medicamento considerando os³±±
±±³            ³           detalhes citados acima.                        ³±±
±±³            ³                                                          ³±±
±±³            ³ nTotTaxD- Total de taxas e diarias considerando tambem os³±±
±±³            ³           detalhes citados acima.                        ³±±
±±³            ³                                                          ³±±
±±³            ³ nTotProc- Total de procedimentos considerando tambem os  ³±±
±±³            ³           detalhes citados acima.                        ³±±
±±³            ³                                                          ³±±
±±³            ³ nTotFilm- Total de filme considerando tambem os detalhes ³±±
±±³            ³           citados acima.                                 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_TICnt(cRegAte, cNrSeqG, lIsTotal)
 Local nTotVal := 0, nTotIte := 0, nTotCnt := 0, cAliasOld := Alias()
 Local nTotMatM := 0, nTotTaxD := 0, nTotProc := 0, nTotFilm := 0

 Local cSqlTot := "", cCalculo := "ROUND(" + IIf(lIsTotal <> Nil .And. lIsTotal, "GR0_VALSER", "GR0_VALTOT") + ", 2)"
 Local cCondicao := IIf(cRegAte == Nil, "", "AND GR0_REGATE = '" + cRegAte + "'" + IIf(cNrSeqG == Nil, "", " AND GR0_NRSEQG = '" + cNrSeqG + "'"))
 Local cContador := "COUNT(DISTINCT " + IIf(cNrSeqG == Nil, "GR0_REGATE", "GR0_NRSEQG") + ") TOTCNT, COUNT(*) TOTITE"

 cSqlTot := "SELECT SUM(" + cCalculo + ") TOTVAL, " + cContador + " " + ;
            "FROM " + RetSqlName("GR0") + " " + ;
            "WHERE GR0_FILIAL = '" + xFilial("GR0") + "' AND D_E_L_E_T_ <> '*' " + cCondicao

 TCQuery cSqlTot New Alias "TMPTOTAIS"

 nTotVal := TMPTOTAIS->TOTVAL
 nTotIte := TMPTOTAIS->TOTITE
 nTotCnt := TMPTOTAIS->TOTCNT

 DbCloseArea()

 cSqlTot := "SELECT GR0_TIPSER, SUM(" + cCalculo + ") TOTDES " + ;
            "FROM " + RetSqlName("GR0") + " " + ;
            "WHERE GR0_FILIAL = '" + xFilial("GR0") + "' AND D_E_L_E_T_ <> '*' " + cCondicao + " " + ;
            "GROUP BY GR0_TIPSER"

 TCQuery cSqlTot New Alias "TMPTOTAIS"

 While !Eof()

  If     TMPTOTAIS->GR0_TIPSER == "P" /*  Procedimentos*/
   nTotProc += TMPTOTAIS->TOTDES
  ElseIf TMPTOTAIS->GR0_TIPSER == "F" /*  Filmes*/
   nTotFilm += TMPTOTAIS->TOTDES
  ElseIf TMPTOTAIS->GR0_TIPSER == "M" /*  Materiais e Medicamentos*/
   nTotMatM += TMPTOTAIS->TOTDES
  ElseIf TMPTOTAIS->GR0_TIPSER == "T" /*  Taxas e Diarias*/
   nTotTaxD += TMPTOTAIS->TOTDES
  EndIf

  DbSkip()
 End

 DbCloseArea()

 DbSelectArea(cAliasOld)
Return({nTotVal, nTotIte, nTotCnt, nTotMatM, nTotTaxD, nTotProc, nTotFilm})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   ³ HS_TLAtendi º Autor ³ José Orfeu    º Data ³ 26/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao  ³ Tipo de leito do atendimento                             º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cRegAte  - Numero do registro de atendimento do paciente ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ cTLAtendi- Retorna o tipo de leito usado no atendimento  ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_TLAtendi(cRegAte)
 Local cTLAtendi := " ", aArea := GetArea()

 DbSelectArea("GCY")
 DbSetOrder(1)
 DbSeek(xFilial("GCY") + cRegAte)

 DbSelectArea("GAV")      /* Leitos*/
 DbSetOrder(1)
 If !Empty(GCY->GCY_QUAINT + GCY->GCY_LEIINT) .And. DbSeek(xFilial("GAV") + GCY->GCY_CODLOC + GCY->GCY_QUAINT + GCY->GCY_LEIINT)
  If     GAV->GAV_MODELO == "0" // Ambulatorio
   cTLAtendi := "5" // Consultorio/Ambulatorio/S.A.D.T
  ElseIf GAV->GAV_MODELO == "1" .And. FS_NLeitos(GCY->GCY_CODLOC, GCY->GCY_QUAINT) == 1 // Enfermaria
   cTLAtendi := "4" // Apartamento
  ElseIf GAV->GAV_MODELO == "1" .And. FS_NLeitos(GCY->GCY_CODLOC, GCY->GCY_QUAINT) == 2 // Enfermaria
   cTLAtendi := "2" // Enfermaria com 2 leitos
  ElseIf GAV->GAV_MODELO == "1" .And. FS_NLeitos(GCY->GCY_CODLOC, GCY->GCY_QUAINT) >= 3 // Enfermaria
   cTLAtendi := "3" // Enfermaria com 3 ou mais leitos
  ElseIf GAV->GAV_MODELO == "2" // Apartamento
   cTLAtendi := "4" // Apartamento
  ElseIf GAV->GAV_MODELO == "3" // Suite
   cTLAtendi := "1" // Quarto Individual
  ElseIf GAV->GAV_MODELO == "4" // Sala Cirurgica
   cTLAtendi := "1" // Quarto Individual
  ElseIf GAV->GAV_MODELO == "5" // UTI
   cTLAtendi := "1" // Quarto Individual
  ElseIf GAV->GAV_MODELO == "6" // UTI-NEO
   cTLAtendi := "1" // Quarto Individual
  ElseIf GAV->GAV_MODELO == "7" // SEMI-UTI
   cTLAtendi := "1" // Quarto Individual
  EndIf
 Else
  cTLAtendi := "5" // Consultorio/Ambulatorio/S.A.D.T
 EndIf

 RestArea(aArea)
Return(cTLAtendi)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   ³ FS_NLeitos º Autor ³ José Orfeu     º Data ³ 26/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao  ³ Quantidade de leitos do quarto                           º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cCodLoc  - Setor do quarto                               ³±±
±±³            ³ cQuaInt  - Quarto                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ nQtdLei  - Quantidade de leitos do quarto                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_NLeitos(cCodLoc, cQuaInt)
 Local cAliasOld := Alias(), nQtdLei := 0, cSqlLeito := ""

 cSqlLeito := "SELECT COUNT(GAV_LEITO) NQTDLEI FROM " + RetSqlName("GAV") + " " + ;
              "WHERE GAV_FILIAL = '" + xFilial("GAV") + "' AND D_E_L_E_T_ <> '*' AND " + ;
                    "GAV_CODLOC = '" + cCodLoc + "' AND GAV_QUARTO = '" + cQuaInt + "'"

 TCQuery cSqlLeito New Alias "TMPLEITO"

 nQtdLei := TMPLEITO->NQTDLEI

 DBCloseArea()

 DbSelectArea(cAliasOld)
Return(nQtdLei)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   ³ HS_TPAtendi º Autor ³ José Orfeu    º Data ³ 26/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao  ³ Tipo de atendimento                                      º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cRegAte  - Numero do registro do atendimento             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ cTPAtendi- Retorna o tipo do atendimento                 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_TPAtendi(cRegAte)
 Local cTPAtendi := "", aArea := GetArea()

 DbSelectArea("GCY")
 DbSetOrder(1)
 DbSeek(xFilial("GCY") + cRegAte)

 DbSelectArea("GCS")
 DbSetOrder(1)
 DbSeek(xFilial("GCS") + GCY->GCY_CODLOC)
 //Tipos de setor GCS_TIPLOC
 //0=Intern.;1=Ambulat.;2=P.Atendto;3=Enfermagem;4=C.Cirurgico;5=Marcacao;6=Reserva C.C.;7=Administ.;8=Bercario;9=Laudo;A=Farmacia

 // Tipos de Atendimento
 //If     GCY->GCY_ATENDI == "0" // Hospitalar
 //ElseIf GCY->GCY_ATENDI == "1" // Ambulatorial
 //ElseIf GCY->GCY_ATENDI == "2" // Pronto Atendimento
 //EndIf

 If GCY->GCY_ACITRA == "1" // 1-Sim
  cTPAtendi := "9" // Acidente de trabalho
 ElseIf GCS->GCS_TIPLOC == "4" // 4-Centro Cirurgico
  cTPAtendi := "7" // Cirurgico
 Else
  cTPAtendi := "6" // Clinico / Pre-Natal
 EndIf

 RestArea(aArea)
Return(cTPAtendi)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   ³ HS_TDocPac º Autor ³ José Orfeu     º Data ³ 26/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao  ³ Tipo de documento e documento do paciente                º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cRegAte  - Numero do registro de atendimento do paciente ³±±
±±³            ³ cNrSeqG  - Numero da guia do atendimento do paciente     ³±±
±±³            ³ nTDesDoc - Tamanho da descricao do documento             ³±±
±±³            ³ nTNumDoc - Tamanho do numero do documento                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Array {cTpValDoc, cTPDesDoc, cNumDoc}                    ³±±
±±³            ³ cTpValDoc - Tipo de documento configurado no cadastro do ³±±
±±³            ³             convenio da guia do atendimento.             ³±±
±±³            ³                                                          ³±±
±±³            ³ cTpDesDoc - Descricao do documento configurado no cadas- ³±±
±±³            ³             tro do convenio da guia do atendimento.      ³±±
±±³            ³                                                          ³±±
±±³            ³ cNumDoc   - Numero do documento informado no cadastro do ³±±
±±³            ³             paciente.                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_TDocPac(cRegAte, cNrSeqG, nTDesDoc, nTNumDoc)
 Local cNumDoc := Space(nTNumDoc), cTpValDoc := Space(1), cTpDesDoc := Space(nTDesDoc), aArea := GetArea()

 DbSelectArea("GCY")
 DbSetOrder(1)
 DbSeek(xFilial("GCY") + cRegAte)

 DbSelectArea("GCZ")
 DbSetOrder(1)
 DbSeek(xFilial("GCZ") + cNrSeqG)

 DbSelectArea("GD4")
 DbSetOrder(1)
 DbSeek(xFilial("GD4") + GCZ->GCZ_REGGER + GCZ->GCZ_CODPLA)

 IF     GCY->GCY_ATENDI == "0" // Hospitalar
		cTpValDoc := HS_RCfgCP(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, "_TPDINT")
	Else
		cTpValDoc := HS_RCfgCP(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, "_TPDAMB")
	EndIf

	If     cTpValDoc == "0" // 0=RG-RG
		cNumDoc   := GBH->GBH_RG
		cTpDesDoc := "RG "
	ElseIf cTpValDoc == "1" // 1=CF-CPF
		cNumDoc := GBH->GBH_CPF
		cTpDesDoc := "CPF"
	ElseIf cTpValDoc == "2" // 2=CP-Cart.Prof.
		cNumDoc := GBH->GBH_NUMCP
		cTpDesDoc := "CLT"
	ElseIf cTpValDoc == "3" // 3=SE-Senha
		cNumDoc := GCZ->GCZ_NRSEN1
		cTpDesDoc := "SEN"
	ElseIf cTpValDoc == "4" // 4=GU-Guia
		cNumDoc := GCZ->GCZ_NRGUIA
		cTpDesDoc := "NRG"
	ElseIf cTpValDoc == "5" // 5=CT-Carteirinha
		cNumDoc   := GD4->GD4_MATRIC
		cTpDesDoc := "MAT"
	EndIF

	If Empty(cNumDoc)
	 If     !Empty(GBH->GBH_RG)
   cNumDoc   := GBH->GBH_RG
   cTpDesDoc := "RG "
  ElseIf !Empty(GBH->GBH_CPF)
   cNumDoc   := GBH->GBH_CPF
   cTpDesDoc := "CPF"
  ElseIf !Empty(GBH->GBH_NUMCP)
   cNumDoc   := GBH->GBH_NUMCP
   cTpDesDoc := "CLT"
  Else
   cNumDoc   := Space(nTNumDoc)
   cTpDesDoc := Space(nTDesDoc)
  EndIf
	EndIf

 RestArea(aArea)
Return({cTpValDoc, PadR(AllTrim(cTPDesDoc), nTDesDoc), PadR(AllTrim(cNumDoc), nTNumDoc)})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   ³ HS_RTipDes º Autor ³ José Orfeu     º Data ³ 26/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao  ³ Tipo de despesa                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±º Parametros ³ cTipSer - Tipo do serviço executado                      º±±
±±º            ³ cTipDes - Tipo da despesas                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±º Retorno    ³ cRTipDes- Tipo do serviço executado                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_RTipDes(cTipSer, cTipDes)
 Local cRTipDes := "0"

 If     cTipSer == "M" .And. cTipDes == "0" // 0-Material
  cRTipDes := "1"
 ElseIf cTipSer == "M" .And. cTipDes == "1" // 1-Medicamento
  cRTipDes := "2"
 Else
  cRTipDes := "0"
 Endif

Return(cRTipDes)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   ³ HS_RUniDes º Autor ³ José Orfeu     º Data ³ 26/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao  ³ Unidade da despesa                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±º Parametros ³ cTipSer - Tipo do serviço executado                      º±±
±±º            ³ cCodDes - Codigo da despesa                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±º Retorno    ³ cRUniDes- Unidade de medida da despesa, caso a despesa   º±±
±±º            ³           nao for um Mat/Med retorna 33 (EDI)            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_RUniDes(cTipSer, cCodDes)
 Local cRUniDes := "33", aArea := GetArea()

 If cTipSer == "M" // Materiais e Medicamentos
  DbSelectArea("SB1")
  DbSetOrder(1)
  If DbSeek(xFilial("SB1") + cCodDes)
   If !Empty(cRUniDes := SB1->B1_UM)
    DbSelectArea("SAH")
    DbSetOrder(1)
    If DbSeek(xFilial("SAH") + cRUniDes)
     cRUniDes := SAH->AH_COD_SIS
    EndIf
   EndIf
  EndIf
 EndIf

 If Empty(cRUniDes)
  cRUniDes := "**"
 EndIf

 RestArea(aArea)
Return(cRUniDes)

Function HS_RSerPri(nTipo, cNrSeqG)
 Local aArea    := GetArea()
 Local cRetorno := IIf(nTipo == 1, Space(8), Space(Len(GE7->GE7_CODCRM)))

 If GCZ->GCZ_NRSEQG <> cNrSeqG
  DbSelectArea("GCZ")
  DbSetOrder(1)
  DbSeek(xFilial("GCZ") + cNrSeqG)
 EndIf

 If GCY->GCY_REGATE <> GCZ->GCZ_REGATE
  DbSelectArea("GCY")
  DbSetOrder(1)
  DbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)
 EndIf

 DbSelectArea("GE7")
 DbSetOrder(2)
 DbSeek(xFilial("GE7") + GCZ->GCZ_NRSEQG)

 If nTipo == 1
  cRetorno := PadL(AllTrim(GE7->GE7_CODPRT), 8, "0")
 ElseIf nTipo = 2
  If Empty(cRetorno := GE7->GE7_CODCRM)
   cRetorno := GCY->GCY_CODCRM
  EndIf
 Endif

 RestArea(aArea)
Return(cRetorno)

Function HS_RPerMed()
 Local aArea    := GetArea()
 Local nPercent := 0

 DbSelectArea("GMC")
 DbSetOrder(1)
 DbSeek(xFilial("GMC") + GR0->GR0_CODATO)

 nPercent := Str(Int(GMC->GMC_PERCEN), 3)

 RestArea(aArea)
Return(nPercent)

Function HS_RTPALTA(cRegAte)
 Local cRTpAlta := "0", aArea := GetArea()

 DbSelectArea("GCY")
 DbSetOrder(1)
 DbSeek(xFilial("GCY") + cRegAte)

 If !Empty(GCY->GCY_TPALTA)
  DbSelectArea("GF4")
  DbSetOrder(1)
  If DbSeek(xFilial("GF4") + GCY->GCY_TPALTA)
   cRTpAlta := GF4->GF4_TPAREM
  EndIf
 EndIf

 RestArea(aArea)
Return(cRTpAlta)

Function HS_DToC(dData, nFormato, cSeparador)
 Local cRData := ""
 Local cDia := StrZero(Day(dData), 2)
 Local cMes := StrZero(Month(dData), 2)
 Local cAno := StrZero(Year(dData), 4)

 Default nFormato   := 1
 Default cSeparador := "/"

 If     nFormato == 1 // DD/MM/YY
  cRData := cDia + cSeparador + cMes + cSeparador + SubStr(cAno, 3, 2)
 ElseIf nFormato == 2 // DD/MM/YYYY
  cRData := cDia + cSeparador + cMes + cSeparador + cAno
 ElseIf nFormato == 3 // MM/DD/YY
  cRData := cMes + cSeparador + cDia + cSeparador + SubStr(cAno, 3, 2)
 ElseIf nFormato == 4 // MM/DD/YYYY
  cRData := cMes + cSeparador + cDia + cSeparador + cAno
 ElseIf nFormato == 5 // YY/MM/DD
  cRData := SubStr(cAno, 3, 2) + cSeparador + cMes + cSeparador + cDia
 ElseIf nFormato == 6 // YYYY/MM/DD
  cRData := cAno + cSeparador + cMes + cSeparador + cDia
 EndIf

Return(cRData)

Function HS_IncRem(cCodCon)
 Local aArea := GetArea()
 Local cSeqRem := ""

 DbSelectArea("GA9")
 DbSetOrder(1)
 If DbSeek(xFilial("GA9") + cCodCon)
  If Type("__lIncReme") <> "U" .And. __lIncReme

   RecLock("GA9", .F.)
    GA9->GA9_SEQREM := IIf(Empty(GA9->GA9_SEQREM), StrZero(1, Len(GA9->GA9_SEQREM)), Soma1(GA9->GA9_SEQREM, Len(GA9->GA9_SEQREM)))
   MsUnLock()

  EndIf
  cSeqRem := GA9->GA9_SEQREM
 EndIf


 RestArea(aArea)
Return(cSeqRem)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_RETOPERºAutor  ³Luiz Pereira S. Jr. º Data ³  03/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que retorna os codigos da operadora na ANS, o do Con-º±±
±±º          ³venio na operador e o codigo de conectividade.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_RetOper(cLote, cTpGuia, cCodCon, cFilFat)
 Local aArea   := GetArea(), aAreaSM0 := SM0->(GetArea())
 Local cTRegra := ""
 Local aRetOpe := { "" ,; // 01 - Cod. ANS - GNF_CODOPE
                    "" ,; // 02 - Cod. Convenio na Operadora - GNF_CDOPER
                    "" }  // 03 - Cod. Conectividade - GNF_CONECT

 Default cLote   := ""
 Default cTpGuia := ""
 Default cCodCon := ""
 Default cFilFat := ""

 If !Empty(cLote)
  cTRegra := HS_IniPadr("GAT", 1, cLote, "GAT_TIPATE")
  cCodCon := GAT->GAT_CODCON
 ElseIf !Empty(cTpGuia)
  cTRegra := HS_IniPadr("GCU", 1, cTpGuia, "GCU_TPGUIA")
 EndIf

 If HS_IniPadr("GA9", 1, cCodCon, "GA9_CNPJOP") <> "1" //Cod. Operadora
  aRetOpe[1] := SM0->M0_CGC

  DbSelectArea("SM0")
  DbSetOrder(1) // M0_CODIGO + M0_FILIAL
  If !Empty(cFilFat) .And. DbSeek(IIF(FindFunction("FWGRPCompany"), FWGRPCompany(),SM0->M0_CODIGO) + 	cFilFat)
   aRetOpe[1] := SM0->M0_CGC
  EndIf

  RestArea(aAreaSM0)
 EndIf

 DbSelectArea("GNF")
 DbSetOrder(2) //GNF_FILIAL+GNF_CODCON+GNF_TREGRA
 If DbSeek(xFilial("GNF") + GA9->GA9_CODCON + cTRegra)

  If !Empty(GNF->GNF_CODOPE) .And. Empty(aRetOpe[1])
   aRetOpe[1] := GNF->GNF_CODOPE
  EndIf

  If !Empty(GNF->GNF_CDOPER)
   aRetOpe[2] := GNF->GNF_CDOPER
  EndIf

  If !Empty(GNF->GNF_CONECT)
   aRetOpe[3] := GNF->GNF_CONECT
  EndIf

 EndIf

 // Caso os valores ainda não tenham sido preenchidos.. busca o valor no convenio
 If Empty(aRetOpe[1])
  aRetOpe[1] := GA9->GA9_CODOPE
 EndIf

 If Empty(aRetOpe[2])
  If GA9->GA9_CNPJOP == '0'
   aRetOpe[2] := SM0->M0_CGC
  else
   aRetOpe[2] := GA9->GA9_CDOPER
  EndIf
 EndIf

 If Empty(aRetOpe[3])
  aRetOpe[3] := GA9->GA9_CONECT
 EndIf

 RestArea(aArea)
Return(aRetOpe)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_RETCBO ºAutor  ³Luiz Pereira S. Jr. º Data ³  03/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o codigo do CBO correspondente ao CRM da despesa.   º±±
±±º          ³As regras para retorno do codigo estao conforme solicitacao.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_RetCBO(cGczCodCrm, cGcyCodCrm, cGczCodDes)
 Local cCboTiss := ""
 Local cCodEsp  := ""
 Local aArea    := GetArea()

 If !Empty(cGczCodCrm)
  cCboTiss := HS_IniPadr("GBJ", 1, cGczCodCrm, "GBJ_CBOTIS")
 EndIf
 If Empty(cCboTiss) .And. !Empty(cGcyCodCrm)
  cCobTiss := HS_IniPadr("GBJ", 1, cGcyCodCrm, "GBJ_CBOTIS")
 EndIf
 If Empty(cCboTiss) .And. !Empty(cGczCodDes)
  cCodEsp  := HS_IniPadr("GA7", 1, cGczCodDes, "GA7_CODESP")
  cCobTiss := HS_IniPadr("GFR", 1, cCodEsp   , "GFR_CBOTIS")
 EndIf
 If Empty(cCboTiss)
  If !Empty(cGczCodCrm)
   cCodEsp  := HS_IniPadr("GBJ", 1, cGczCodCrm, "GBJ_CODESP")
  EndIf
  If Empty(cCodEsp) .And. !Empty(cGcyCodCrm)
   cCodEsp  := HS_IniPadr("GBJ", 1, cGcyCodCrm, "GBJ_CODESP")
  EndIf
  if Empty(cCodEsp)
   cCobTiss := ""
  Else
   cCobTiss := HS_IniPadr("GFR", 1, cCodEsp   , "GFR_CBOTIS")
  EndIf
 EndIf

 RestArea(aArea)
Return(cCboTiss)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_RETCID ºAutor  ³Luiz Pereira S. Jr. º Data ³  03/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o codigo do CID.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_RetCID(cGcyRegAte, cCodCon, cCpoVerImp, cRegra)
 Local cCodCid := ""
 Local aArea   := GetArea()

 Default cCpoVerImp := ""
 Default cRegra     := "1"

 DbSelectArea("GCY")
 DbSetOrder(1) //GCY_FILIAL+GCY_REGATE
 If DbSeek(xFilial("GCY") + cGcyRegAte)
  If !Empty(cCpoVerImp) //Se o campo estiver em branco não será verificado se imprime ou não.
   DbSelectArea("GA9")
   DbSetOrder(1) //GA9_FILIAL+GA9_CODCON
   If DbSeek(xFilial("GA9") + cCodCon)
    If GA9->&(cCpoVerImp) <> "1" // Campo de verificacao de impressao GA9_ICID??
     Return(cCodCid)
    EndIf
   EndIf
  EndIf

  If GCY->GCY_TPALTA $ GetMv("MV_TPALTA")
   Return(GCY->GCY_CIDINT)
  EndIf

  If cRegra == "1"
   If !Empty(GCY->GCY_CIDINT)
    cCodCid := GCY->GCY_CIDINT
   ElseIf !Empty(GCY->GCY_CIDALT)
    cCodCid := GCY->GCY_CIDALT
   ElseIf !Empty(GCY->GCY_CIDCMP)
    cCodCid := GCY->GCY_CIDCMP
   ElseIf !Empty(GCY->GCY_CIDCMI)
    cCodCid := GCY->GCY_CIDCMI
   EndIf

  ElseIf cRegra == "2"
   If !Empty(GCY->GCY_CIDALT) .And. !Empty(GCY->GCY_CIDINT)
    cCodCid := GCY->GCY_CIDALT
   ElseIf !Empty(GCY->GCY_CIDCMP)
    cCodCid := GCY->GCY_CIDCMP
   ElseIf !Empty(GCY->GCY_CIDCMI)
    cCodCid := GCY->GCY_CIDCMI
   EndIf

  ElseIf cRegra == "3"
   If !Empty(GCY->GCY_CIDALT) .And. !Empty(GCY->GCY_CIDINT) .And. (!Empty(GCY->GCY_CIDCMP) .Or. !Empty(GCY->GCY_CIDCMI))
		If !Empty(GCY->GCY_CIDCMP)
			cCodCid := GCY->GCY_CIDCMP
    	Else
    		cCodCid := GCY->GCY_CIDCMI
   		EndIf
   EndIf


  //sadt
  ElseIf cRegra == "4"
	If !Empty(GCZ->GCZ_CIDSOL)
		cCodCid := GCZ->GCZ_CIDSOL
	ElseIf !Empty(GCY->GCY_CIDALT)
		cCodCid := GCY->GCY_CIDALT
	ElseIf !Empty(GCY->GCY_CIDINT)
		cCodCid := GCY->GCY_CIDINT
	EndIf
  EndIf
 EndIf

 RestArea(aArea)
Return(cCodCid)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³HS_GERCIH   ³  SAUDE                      ³ Data ³ 07/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ GERACAO TXT CONTROLE DE INTERNACAO HOSPITALAR CIH          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs       ³ Portaria No. 1722, 22 Setembro de 2005, Ministerio da Saude³±±
±±³          ³ Altera a estrutura de Comunicacao de Internacao Hosp-CIH   ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HS_GERCIH()  // alterar o nome da funcao

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Declaracao de Variaveis Locais                                      ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cRootPath		:= GetSrvProfString( "RootPath", "" )

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Declaracao de Variaveis Privadas                                    ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cQuery
Private cPerg       := "HSPCIH"    // Pergunta da Chamada do Relatorio

CriaSx1()

If !Pergunte(cPerg,.T.)
	Return
EndIf

Processa({|| FS_GerArqs() },"Processando Atendimentos (Internacao)")

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                    ³
//³ mv_par01             // Data Inicial da Alta                            ³
//³ mv_par02             // Data Final da Alta                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CriaSx1   ³  SAUDE                        ³ Data ³ 07/12/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria perguntas da Rotina                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CriaSx1()
Local aRegs := {}
Local cPerg := "HSPCIH"

aadd(aRegs,{cPerg,"01","De data?","","","mv_ch0","D", 8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"02","Ate a data?","","","mv_ch0","D", 8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

PlsVldPerg( aRegs )

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FS_GerArqs³  SAUDE                        ³ Data ³ 07/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ GERA Arquivo                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs       ³ Portaria No. 1722, 22 Setembro de 2005, Ministerio da Saude³±±
±±³          ³ Altera a estrutura de Comunicacao de Internacao Hosp-CIH   ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_GerArqs()

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Declaracao de Variaveis Locais                                      ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cCamArq  		:= GetMV("MV_HSPCIH",.T.,"C:\CIHA\") 	// Caminho para o arquivo gerado em TXT
Local _MVCNES       := SuperGetMV("MV_HSPCNES")				// parametro do codigo CNES do Hospital
Local cNomArq       := _MVCNES + Alltrim(Str(Year(Mv_Par01))) + AllTrim(StrZero(Month(Mv_Par01),2)) + "." + "CHA" // gerar nome do arquivo
Local _MATRIC		:= ""
Local cArqNf        := ""
Local _aNasc		:= {}						// Array com informacoes dos nascidos
Local i				:= 0
Local lDados		:= .F.						// Retorna se ha dados no retorno da query
Local cTexto		:= ""						// Log para verificacao dos codigos da tabela base nao relacionados a tabela SUS
Local lTexto		:= .F.						// Verifica se ha log de tabela ou nao
Local cMask     	:= "Arquivos Texto (*.TXT) |*.txt|"
Local cTpFonte		:= ""
Local cRegANS		:= ""
Local cCNPJ			:= ""
Local cCodDesp      := ""
Local cCodApac      := ""
Local nQtdApac      := 0
Local nFirstGE7     := 0
Local lApac         := .F.
Local aStru01       := {}
Local aStru02       := {}
Local aRetCon       := {}
Local aRegAte       := {}
Local cPlanoSus		:= GetNewPar("MV_PSUSPAC","")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Percorre cPlanoSus em busca de "/" e substitui por "','"			 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPlanoSus := STRTRAN(cPlanoSus,'/',"','")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta estrutura das internacoes e atendimentos individualizados		 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aStru01,{"TIPO"      ,"C",003,0})
aadd(aStru01,{"GCY_REGATE","C",006,0})
aadd(aStru01,{"GCY_REGGER","C",006,0})
aadd(aStru01,{"GCY_NOME"  ,"C",040,0})
aadd(aStru01,{"CIDPRINC"  ,"C",008,0})
aadd(aStru01,{"GCY_CIDCMP","C",008,0})
aadd(aStru01,{"GCY_DATATE","C",008,0})
aadd(aStru01,{"GCY_DATALT","C",008,0})
aadd(aStru01,{"GCY_TPALTA","C",002,0})
aadd(aStru01,{"GCY_OBTDOC","C",008,0})
aadd(aStru01,{"CODPRO"    ,"C",010,0})
aadd(aStru01,{"CODSUS"    ,"C",010,0})
aadd(aStru01,{"QUANTIDADE","N",006,0})
aadd(aStru01,{"GUIA"      ,"C",020,0})
aadd(aStru01,{"GCZ_CODDES","C",010,0})

cNomStrInd := FWTemporaryTable():New( "IND" )
cNomStrInd :SetFields (aStru01)
cNomStrInd :AddIndex("01", {"GCY_NOME", "GCY_DATATE", "CODSUS", "GCY_REGGER"})

cNomStrInd:Create()

DbSelectArea("IND")
IND->(DbSetorder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta estrutura dos atendimentos consolidados               		 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aStru02,{"COMPET","C",006,0})
aadd(aStru02,{"CODDES","C",010,0})
aadd(aStru02,{"QTDDES","N",006,0})
aadd(aStru02,{"REGANS","C",006,0})
aadd(aStru02,{"TIPFON","C",001,0})

cNomStrCon := FWTemporaryTable():New( "CON" )
cNomStrCon :SetFields (aStru02)
cNomStrCon :AddIndex("01", {"REGANS", "CODDES"})

cNomStrCon:Create()

DbSelectArea("CON")
CON->(DbSetorder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lista internacoes			    									 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " SELECT 'INT' AS TIPO, GCY.GCY_REGATE, GCY.GCY_REGGER, GCY.GCY_NOME, CASE GCY.GCY_CIDALT WHEN ' ' THEN GCY.GCY_CIDINT ELSE GCY.GCY_CIDALT END AS CIDPRINC, "
cQuery += " GCY.GCY_CIDCMP, GCY.GCY_DATATE, GCY.GCY_DATALT, GCY.GCY_TPALTA, GCY.GCY_OBTDOC, 'INT' AS CODCON, GCZ.GCZ_NRGUIA AS GUIA, GCZ_CODDES"
cQuery += " FROM "+ RetSqlName("GCY")  + " GCY,"+ RetSqlName("GCS")  + " GCS ,"+ RetSqlName("GCZ")  + " GCZ "
cQuery += " WHERE GCS.GCS_CODLOC=GCY.GCY_LOCATE AND GCY.GCY_DATALT BETWEEN '" + DtoS(Mv_Par01) + "' AND '" + DtoS(Mv_Par02) + "' AND GCY.GCY_TPALTA<>'99' "
cQuery += " AND GCZ.GCZ_REGATE = GCY.GCY_REGATE "
cQuery += " AND GCS_TIPLOC='0' AND GCS.GCS_FILIAL = '" + XFILIAL("GCS") + "' AND GCY.GCY_FILIAL = '" + XFILIAL("GCY") +  "' AND GCZ.GCZ_FILIAL = '" + XFILIAL("GCZ") + "' "
cQuery += " AND GCS.D_E_L_E_T_ <> '*' AND GCY.D_E_L_E_T_ <> '*' AND GCZ.D_E_L_E_T_ <> '*'"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lista atendimentos ambulatoriais               						  	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery += " UNION "
cQuery += " SELECT 'AMB' AS TIPO, GCY.GCY_REGATE, GCY.GCY_REGGER, GCY.GCY_NOME, GCY.GCY_CIDALT AS CIDPRINC, GCY.GCY_CIDCMP, GCY.GCY_DATATE, "
cQuery += " GCY.GCY_DATALT, GCY.GCY_TPALTA, GCY.GCY_OBTDOC, GCZ.GCZ_CODCON AS CODCON, GCZ.GCZ_NRGUIA AS GUIA, GCZ_CODDES"
cQuery += " FROM "+ RetSqlName("GCY")  + " GCY,"+ RetSqlName("GCS")  + " GCS, "+ RetSqlName("GCZ")  + " GCZ "
cQuery += " WHERE GCS.GCS_CODLOC=GCY.GCY_LOCATE AND GCY.GCY_DATALT BETWEEN '" + DtoS(Mv_Par01) + "' AND '" + DtoS(Mv_Par02) + "' AND GCY.GCY_TPALTA<>'99' "
cQuery += " AND GCZ.GCZ_REGATE = GCY.GCY_REGATE "
cQuery += " AND GCZ_CODPLA NOT IN ('"+GetNewPar("MV_PSUSAIH","")+"','"+GetNewPar("MV_PSUSBPA","")+"','"+cPlanoSus+"') "
cQuery += " AND GCS_TIPLOC IN ('1','2') AND GCS.GCS_FILIAL = '" + XFILIAL("GCS") + "' AND GCY.GCY_FILIAL = '" + XFILIAL("GCY") + "' AND GCZ.GCZ_FILIAL = '" + XFILIAL("GCZ") + "' "
cQuery += " AND GCS.D_E_L_E_T_ <> '*' AND GCY.D_E_L_E_T_ <> '*' AND GCZ.D_E_L_E_T_ <> '*'"
TCQUERY cQuery NEW ALIAS "TMPQRY"

cTexto += Replicate("-",128)+CHR(13)+CHR(10)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona indices que serao utilizados          					  	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("GA7")
DbSetOrder(1) //GA7_FILIAL+GA7_CODPRO

DbSelectArea("GA8")
DbSetOrder(3) //GA8_FILIAL+GA8_TABPRO+GA8_CODPRO+GA8_DATVIG
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta arquivo temporário individualizado							  	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("TMPQRY")
DbGoTop()
While TMPQRY->(!Eof())
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Internacao utiliza regra do CIH          							  	 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If TMPQRY->TIPO == 'INT'
        IND->(RecLock("IND",.T.))
            IND->TIPO       := TMPQRY->TIPO
	        IND->GCY_REGATE := TMPQRY->GCY_REGATE
	    	 IND->GCY_REGGER := TMPQRY->GCY_REGGER
	    	 IND->GCY_NOME   := TMPQRY->GCY_NOME
            IND->CIDPRINC   := TMPQRY->CIDPRINC
            IND->GCY_CIDCMP := TMPQRY->GCY_CIDCMP
            IND->GCY_DATATE := TMPQRY->GCY_DATATE
            IND->GCY_DATALT := TMPQRY->GCY_DATALT
            IND->GCY_TPALTA := TMPQRY->GCY_TPALTA
            IND->GCY_OBTDOC := TMPQRY->GCY_OBTDOC
            IND->GUIA       := TMPQRY->GUIA
            IND->GCZ_CODDES := TMPQRY->GCZ_CODDES
        IND->(MsUnLock())
    Else

        DbSelectArea("GE7")
        DbSetOrder(3)//GE7_FILIAL+GE7_REGATE
        If GE7->(DbSeek(xFilial("GE7")+TMPQRY->GCY_REGATE))
            nFirstGE7 := GE7->(Recno())
            //Reinicializa variaveis APAC
            lApac := .F.
            nQtdApac   := 0
            cCodApac   := ""
            cCodDesp   := ""
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Este While verifica todos os procedimentos da guia a procura de um       ³
            //³ procedimento APAC. Caso exista, ele ira somar todas as quantidades para  ³
            //³ todas as vezes que o mesmo procedimento foi lancado (verificacao atraves ³
            //³ do codigo SUS). Caso nao exista APAC, e retornado a primeira despesa da  ³
            //³ guia para totalizar os procedimentos Consolidados e Individualizados     ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            While TMPQRY->GCY_REGATE == GE7->GE7_REGATE
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Verifica se existe tratamento (APAC)     							  	 ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                aRetCon := RetProcCon(GE7->GE7_CODDES,GE7->GE7_REGATE,@cTexto,@lTexto,.T.,cCodApac)
                If aRetCon [2] == "A"
                    lApac := .T.
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³ Incrementa somente se cCodApac vazio ou se retorno do codigo SUS for     ³
                    //³ igual a cCodApac. Realizado controle para prever erros do PE HSPROCIHA 	 ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    If Empty(cCodApac) .Or. (cCodApac == aRetCon[1])
                        nQtdApac += GE7->GE7_QTDDES
                    EndIf

                    If Empty(cCodApac) //Armazena o primeiro procedimento do tipo APAC Principal
                        cCodApac := aRetCon[1]
                        cCodDesp := GE7->GE7_CODDES
                    EndIf

                EndIf
                GE7->(DbSkip())
            EndDo
        EndIf
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Se for Tratamento registra somente o procedimento de APAC   		  	 ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If lApac
            IND->(RecLock("IND",.T.))
                IND->TIPO       := TMPQRY->TIPO
	        	IND->GCY_REGATE := TMPQRY->GCY_REGATE
	       		IND->GCY_REGGER := TMPQRY->GCY_REGGER
	    		IND->GCY_NOME   := TMPQRY->GCY_NOME
            	IND->CIDPRINC   := TMPQRY->CIDPRINC
            	IND->GCY_CIDCMP := TMPQRY->GCY_CIDCMP
            	IND->GCY_DATATE := TMPQRY->GCY_DATATE
            	IND->GCY_DATALT := TMPQRY->GCY_DATALT
            	IND->GCY_TPALTA := TMPQRY->GCY_TPALTA
            	IND->GCY_OBTDOC := TMPQRY->GCY_OBTDOC
            	IND->CODPRO     := cCodDesp
            	IND->CODSUS     := cCodApac
            	IND->QUANTIDADE := nQtdApac
            	IND->GUIA       := TMPQRY->GUIA
            	IND->GCZ_CODDES := TMPQRY->GCZ_CODDES
        	IND->(MsUnLock())
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Se for Atendimento Consolidado ou Individualizado, reposiciona no    	 ³
        //³ primeiro registro para processar todas as despesas                  	 ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        Else
            GE7->(DbGoTo(nFirstGE7))
            While TMPQRY->GCY_REGATE == GE7->GE7_REGATE
                aRetCon := RetProcCon(GE7->GE7_CODDES,GE7->GE7_REGATE,@cTexto,@lTexto,.F.)
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Contabiliza o Individualizado                               	      ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                If aRetCon [2] == "I"
                    DbSelectArea("IND")
                    DbSetOrder(1)//GCY_NOME+GCY_DATATE+CODSUS+GCY_REGGER
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³ Se encontrar registro para o mesmo paciente, data e procedimento incrementa ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    If !MsSeek(Substr(TMPQRY->GCY_NOME,1,40)+TMPQRY->GCY_DATATE+aRetCon[1]+TMPQRY->GCY_REGGER)
                     IND->(RecLock("IND",.T.))
            			IND->TIPO       := TMPQRY->TIPO
	        			IND->GCY_REGATE := TMPQRY->GCY_REGATE
	       			IND->GCY_REGGER := TMPQRY->GCY_REGGER
	    				IND->GCY_NOME   := TMPQRY->GCY_NOME
            			IND->CIDPRINC   := TMPQRY->CIDPRINC
            			IND->GCY_CIDCMP := TMPQRY->GCY_CIDCMP
            			IND->GCY_DATATE := TMPQRY->GCY_DATATE
            			IND->GCY_DATALT := TMPQRY->GCY_DATALT
            			IND->GCY_TPALTA := TMPQRY->GCY_TPALTA
            			IND->GCY_OBTDOC := TMPQRY->GCY_OBTDOC
            			IND->CODPRO     := GE7->GE7_CODDES
            			IND->CODSUS     := aRetCon[1]
            			IND->QUANTIDADE := GE7->GE7_QTDDES
            			IND->GUIA       := TMPQRY->GUIA
            			IND->GCZ_CODDES := TMPQRY->GCZ_CODDES
        			    IND->(MsUnLock())
        			Else
        			    IND->(RecLock("IND",.F.))
        			    IND->QUANTIDADE += GE7->GE7_QTDDES
        			    IND->(MsUnLock())
        			EndIf
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Consolidado incrementa totalizador                           	      ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                ElseIf aRetCon [2] == "C"
                	GA9->(DbSetOrder(1))
                	GA9->(DbSeek(xFilial("GA9")+TMPQRY->CODCON))
                	cTpFonte := GA9->GA9_TIPFPA
                	IIf(cTpFonte == "1",cRegANS:=Padr(GA9->GA9_CODOPE,6),cRegANS:=Space(6))

                    DbSelectArea("CON")
                    DbSetOrder(1)
                    If MsSeek(cRegANS+aRetCon[1])
                        CON->(RecLock("CON",.F.))
                        CON->QTDDES += GE7->GE7_QTDDES
                        CON->(MsUnLock())
                    Else
                        	CON->(RecLock("CON",.T.))
                        	CON->CODDES := aRetCon[1]
                        	CON->TIPFON := cTpFonte
                        	CON->REGANS := cRegANS
                        	CON->QTDDES := GE7->GE7_QTDDES
            	        	CON->COMPET := SubStr(TMPQRY->GCY_DATALT,5,2) + SubStr(TMPQRY->GCY_DATALT,1,4) //Competencia do Arquivo
                        	CON->(MsUnLock())
                    EndIf
                EndIf

                GE7->(DbSkip())
            EndDo
        EndIf
    EndIf

    TMPQRY->(DbSkip())
EndDo

TMPQRY->(DbCloseArea())

If Empty(cCamArq)
	MsgAlert ("Conteúdo do parâmetro 'MV_HSPCIH' inválido"+CHR(13)+CHR(10)+"O arquivo será gerado no diretório: 'C:\CIHA\'","Atenção")
	cCamArq := "C:\CIHA\"
Endif

If !ExistDir(cCamArq)
	MsgAlert("O diretório informado no parâmetro 'MV_HSPCIH' não foi encontrado","Atenção")
	Return
Endif

cArqNf := fCreate(cCamArq+cNomArq)  // Carrega o caminho e o nome do arquivo gerado

cTexto += Replicate("-",128)+CHR(13)+CHR(10)

//HEADER
cArqHEA := "1"						// Tipo de Registro (1 - Header)
cArqHEA += StrZero(Val(_MVCNES),7) 	// Codigo Nacional do Estabelecimento de Saude
cArqHEA += "1.0.2.0" 				// Versão do Aplicativo
FWrite(cArqNf,cArqHEA+CHR(13)+CHR(10))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa temporario de individualizado/internacao					  	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("IND")
IND->(DbGoTop())

While IND->(!Eof())
	DbSelectArea("GBH")
	DbSetOrder(1)   // GBH_FILIAL+GBH_CODPAC
	DbSeek(xFilial("GBH")+IND->GCY_REGGER)

	If aScan(aRegAte,IND->GCY_REGATE) > 0
		IND->(DbSkip())
		Loop
	Endif

	aAdd(aRegAte,IND->GCY_REGATE)

	lDados	:= .T.
	Do Case
	    Case IND->TIPO == 'INT'
	        cArqCIH := "2"								// Tipo de Registro (2 - Dados de Atendimento Individualizado - Internação)
	    Case IND->TIPO == 'AMB'
     	    cArqCIH := "4"								// Tipo de Registro (4 - Dados de Atendimento Individualizado - Ambulatorial)
	EndCase
	cArqCIH += UPPER(PadR(GBH->GBH_NOME,60)) 			// Nome do Paciente
	cArqCIH += UPPER(PadR(GBH->GBH_END,25)) 			// Endereco do Paciente
	cArqCIH += StrZero(Val(GBH->GBH_NUM),5)   			// Numero do Endereco
	cArqCIH += UPPER(PadR(GBH->GBH_COMPLE,15)) 		// Complemento
	cArqCIH += PadR(AllTrim(Left(Posicione("GAM",3,xFilial("GAM")+GBH->GBH_CEP,"GAM_CODIGO"),6)),6,"0") // Municipio
	cArqCIH += Padr(GBH->GBH_EST,2) 					// UF Paciente
	cArqCIH += StrZero(Val(GBH->GBH_CEP),8) 			// Cep do Paciente
	cDtNas  := DtoS(GBH->GBH_DTNASC)            		// Data de Nascimento do Paciente
	cArqCIH += SubStr(cDtNas,7,2) +  SubStr(cDtNas,5,2) + SubStr(cDtNas,1,4)	// Data de Nascimento do Paciente
	If GBH->GBH_SEXO = "0"
		 cSexPac := "M"
	Else
		 cSexPac := "F"
	EndIf
	cArqCIH += Padr(cSexPac,1) 				// Sexo do Paciente (F=Feminino, M=Masculino)
	cArqCIH += GBH->GBH_NUMCNS				// CNS CARTAO NACIONAL DE SAUDE DO PACIENTE
	If Empty(GBH->GBH_NUMCNS)
   		lTexto := .T.
  	    cTexto += STR0028 + IND->GCY_REGGER + ". " +CHR(13) + CHR(10) //"Necessário preencher o CNS do paciente do atendimento "
	EndIf

	If IND->TIPO == "INT"
	     sProced := RetMaxValD(IND->GCY_REGATE,@cTexto,@lTexto,IND->GCZ_CODDES)	// FUNCAO PARA IDENTIFICAR O PROC DE MAIOR VALOR E RETORNAR O PROCEDIMENTO DO SUS
	     _CodPROC:= sProced[1]
	     _CodSUS := sProced[2]
	Else
	     _CodPROC:= IND->CODPRO
	     _CodSUS := IND->CODSUS
	EndIf

	IF Empty(_CodSUS)
		cArqCIH += StrZero(Val(_CodSUS),10)
	Else
		cArqCIH += StrZero(Val(_CodSUS),10)
	EndIf

	cArqCIH += Padr(IND->CIDPRINC,4) 		//Cid Internacao
	cArqCIH += Padr(IND->GCY_CIDCMP,4) 		//Cid da Alta
	cArqCIH += SubStr(IND->GCY_DATATE,7,2) +  SubStr(IND->GCY_DATATE,5,2) + SubStr(IND->GCY_DATATE,1,4) 	//Data de Atendimento do Paciente
	If IND->TIPO == "INT"
		cArqCIH += SubStr(IND->GCY_DATALT,7,2) +  SubStr(IND->GCY_DATALT,5,2) + SubStr(IND->GCY_DATALT,1,4) 	//Data de Alta do Paciente
	Else
		cArqCIH += IIf(IND->GCY_DATATE <> IND->GCY_DATALT, Space(8),SubStr(IND->GCY_DATALT,7,2) +  SubStr(IND->GCY_DATALT,5,2) + SubStr(IND->GCY_DATALT,1,4)) 	//Data de Alta do Paciente
	EndIf

	cArqCIH += IIF(IND->TIPO == "INT",StrZero(Val(Posicione("GF4",1,xFilial("GF4")+IND->GCY_TPALTA,"GF4_TPASUS")),2),Space(2))		//Motivo da Alta
	cArqCIH += Padr(POSICIONE("GA9",1,XFILIAL("GA9")+POSICIONE("GCZ",2,XFILIAL("GCZ")+IND->GCY_REGATE,"GCZ_CODCON"),"GA9_TIPFPA"),1) 	//Tipo da Fonte Pagadora
	cTpFonte := Padr(POSICIONE("GA9",1,XFILIAL("GA9")+POSICIONE("GCZ",2,XFILIAL("GCZ")+IND->GCY_REGATE,"GCZ_CODCON"),"GA9_TIPFPA"),1) 	//Tipo da Fonte Pagadora

	If !Empty(_CodPROC)
		cArqCIH += PadR(Posicione("GA7",1,xFilial("GA7")+_CodPROC,"GA7_DESC"),40) //Posiciona Procedimento e Retorna Descricao
	Else
		cArqCIH += Space(040)
	EndIf

    cRegANS	:= PadR(POSICIONE("GA9",1,XFILIAL("GA9")+POSICIONE("GCZ",2,XFILIAL("GCZ")+IND->GCY_REGATE,"GCZ_CODCON"),"GA9_CODOPE"),6)				//Codigo da Operadora de Saude na ANS
	cCNPJ	:= PadR(POSICIONE("GA9",1,XFILIAL("GA9")+POSICIONE("GCZ",2,XFILIAL("GCZ")+IND->GCY_REGATE,"GCZ_CODCON"),"GA9_CGC"),14)  				//CNPJ da Operadora de Saude(CONVENIO)
	_MATRIC := POSICIONE("GD4",1,XFILIAL("GD4")+IND->GCY_REGGER+POSICIONE("GCZ",2,XFILIAL("GCZ")+IND->GCY_REGATE,"GCZ_CODPLA"),"GD4_MATRIC") 	//Numero da carteirinha do paciente no Convenio

	If cTpFonte == "1"
		If !Empty(cRegANS) .AND. !Empty(_MATRIC)
			cArqCIH += cRegANS 						//Codigo da Operadora de Saude na ANS
			cArqCIH += Space(14)					//CNPJ da Operadora de Saude(CONVENIO)
			cArqCIH += Padr(Alltrim(_MATRIC),30)	//numero da carteirinha do paciente
		Else
			cArqCIH += Space(06)	//Codigo da Operadora de Saude na ANS
			cArqCIH += cCNPJ		//CNPJ da Operadora de Saude(CONVENIO)
			cArqCIH += Space(30)	//numero da carteirinha do paciente
		Endif
	ElseIf cTpFonte == "9"
		cArqCIH += Space(06)	//Codigo da Operadora de Saude na ANS
		cArqCIH += cCNPJ		//CNPJ da Operadora de Saude(CONVENIO)
		cArqCIH += Space(30)	//numero da carteirinha do paciente
	Else
		cArqCIH += cRegANS						//Codigo da Operadora de Saude na ANS
		cArqCIH += cCNPJ						//CNPJ da Operadora de Saude(CONVENIO)
		cArqCIH += Padr(Alltrim(_MATRIC),30)	//numero da carteirinha do paciente
	EndIf

	cArqCIH += PadR(IND->GCY_OBTDOC,11) 	//Numero da Declaracao de Obito

	// Nascidos
	_aNasc := RetNasc(IND->GCY_REGATE, DtoS(Mv_Par01), DtoS(Mv_Par02))
	cArqCIH += StrZero(Len(_aNasc),1)	// Indica a quantidade de nascidos
	For i := 1 To 5						// até 5 nascidos, onde é o limite do layout do arquivo
		If i <= Len(_aNasc)
			cArqCIH += PadR(_aNasc[i],11)
		Else
			cArqCIH += Space(11)
		EndIf
	Next i

	_DiasUti:=RetDiasUTI(IND->GCY_REGATE) 		    // FUNCAO PARA RETORNAR O NUMERO DE DIAS DE UTI DO PACIENTE
	cArqCIH += StrZero(_DiasUti,3) 					// Numero de dias que o paciente ficou em UTI
	cArqCIH += StrZero(Val(IND->GCY_REGGER),12)	// Numero do prontuario
	cArqCIH += SubStr(IND->GCY_DATALT,5,2) + SubStr(IND->GCY_DATALT,1,4)	//Competencia do Arquivo
	IIf(IND->TIPO == "INT" ,cArqCIH += StrZero(sProced[3],6),cArqCIH += StrZero(IND->QUANTIDADE,6))  //Quantidade de Atendimentos Prestados
    cArqCIH += IIF(IND->TIPO == "AMB","01","02")   //Codigo da modalidade de atendimento
	cArqCIH += Padr(IND->GUIA,20)

	FWrite(cArqNf,cArqCIH+chr(13)+chr(10))

	IND->(DbSkip())
EndDo

IND->(DbCloseArea())
cNomStrInd:Delete()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa temporario de consolidado      							  	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("CON")
CON->(DbGoTop())
While CON->(!Eof())
    lDados	:= .T.
    cArqCIH := "5" // Tipo de Registro (5 - Movimento Consolidado)
    cArqCIH += Space(145)
    cArqCIH += CON->CODDES //Procedimento realizado
    cArqCIH += Space(26)
	cArqCIH  += CON->TIPFON //Tipo da Fonte Pagadora

	If CON->TIPFON == "1"
 		cArqCIH += Space(40)
    	cArqCIH += 	Padr(Alltrim(CON->REGANS),6) //Codigo da Operadora de Saude na ANS
	Else
    	cArqCIH += Space(46)
	EndIf

   	cArqCIH += Space(126)

    cArqCIH += CON->COMPET
    cArqCIH += Strzero(CON->QTDDES,6)
    cArqCIH += Space(22)

    FWrite(cArqNf,cArqCIH+chr(13)+chr(10))

    CON->(DbSkip())
EndDo
CON->(DbCloseArea())
cNomStrCon:Delete()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao existir movimentacao, gera Registro do tipo 3    			  	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lDados
	cArqCIH := "3"					// Tipo de Registro (3 - Sem movimento)
	FWrite(cArqNf,cArqCIH+chr(13)+chr(10))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe log de processamento se existir                   			  	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTexto
	cTexto		:= STR0017 + CHR(13) + CHR(10) + cTexto //"Códigos não relacionados "
	__cFileLog	:= MemoWrite(Criatrab(,.f.) + ".LOG", cTexto)

	DEFINE FONT oFont NAME "Mono AS" SIZE 5,12
	DEFINE MSDIALOG oDlg TITLE STR0018 From 3,0 to 340,417 PIXEL //"Tabela Base X Tabela SUS"
		@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont
		DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
		DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
	ACTIVATE MSDIALOG oDlg CENTER
EndIf

MsgAlert(STR0019 + cNomArq + STR0020 + cCamArq)//"Arquivo de Exportação CIHA (Comunicação de Informação Hospitalar e Ambulatorial),  " ###"  , gerado com sucesso no endereço:  "

FClose(cArqNf)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetMaxValD³ Saude                         ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o Procedimento de Maior Valor do Atendimento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RetMaxValD(cRegAte)                                        ³±±
±±³          ³ Seleciona todos os procedimento do atendimento             ³±±
±±³          ³ e retorna o de maior valor e Codigo SUS                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetMaxValD(cRegAte, cTexto, lTexto, cCodPrnc)

LOCAL cProcGA7		:=""    					// Procedimento
LOCAL cProcSUS		:=""
Local _MVTABSUS     := SuperGetMV("MV_TABSUS")	// tabela do SUS
Local nQtdGE7       := 0
Private cQuery
DEFAULT cCodPrnc := ""

//SELECIONA O PROCEDIMENTO MEDICO CIRURGICO DE MAIOR VALOR ONDE O EXECUTANTE E CIRURGIAO NA TABELA DE PROCEDIMENTOS REALIZADOS
cQuery := " SELECT MAX(GD7_VALDES) MAXVDES, GD7_CODDES AS GD7_CODDES, GD7_QTDDES AS GE7_QTDDES"
cQuery += " FROM "+ RetSqlName("GA7")  + " GA7,"+ RetSqlName("GD7")  + " GD7 "
cQuery += " WHERE GA7_FILIAL = '" + XFILIAL("GA7") + "' AND GD7_FILIAL = '" + XFILIAL("GD7") + "' "
cQuery += " AND GA7_CODPRO=GD7_CODDES AND GA7_TIPPRO='1' " 	//ONDE O TIPO DE PROCEDIMENTO HONORARIO NO CADASTRO DE PROCEDIMENTOS
cQuery += " AND GD7_REGATE='" + cRegAte + "' " 				//INDICA O REGISTRO DE ATENDIMENTO DO PACIENTE
If !EMPTY(cCodPrnc)
	cQuery += " AND GD7_CODDES='" + cCodPrnc + "' " 		//BUSCA O CODIGO PRINCIPAL QUANDO INCLUSO NA GCZ_CODDES
EndIf
cQuery += " AND GA7.D_E_L_E_T_!='*' AND GD7.D_E_L_E_T_!='*' "
cQuery += " GROUP BY GD7_CODDES, GD7_QTDDES "

cQuery += " UNION ALL "

cQuery += " SELECT MAX(GE7_VALDES) MAXVDES, GE7_CODDES AS GD7_CODDES, GE7_QTDDES AS GE7_QTDDES "
cQuery += " FROM "+ RetSqlName("GA7")  + " GA7,"+ RetSqlName("GE7")  + " GE7 "
cQuery += " WHERE GA7_FILIAL = '" + XFILIAL("GA7") + "' AND GE7_FILIAL = '" + XFILIAL("GE7") + "' "
cQuery += " AND GA7_CODPRO=GE7_CODDES AND GA7_TIPPRO='1' " 	//ONDE O TIPO DE PROCEDIMENTO HONORARIO NO CADASTRO DE PROCEDIMENTOS
cQuery += " AND GE7_REGATE='" + cRegAte + "' " 				//INDICA O REGISTRO DE ATENDIMENTO DO PACIENTE
If !EMPTY(cCodPrnc)
	cQuery += " AND GE7_CODDES='" + cCodPrnc + "' " 		//BUSCA O CODIGO PRINCIPAL QUANDO INCLUSO NA GCZ_CODDES
EndIf
cQuery += " AND GA7.D_E_L_E_T_!='*' AND GE7.D_E_L_E_T_!='*' "
cQuery += " GROUP BY GE7_CODDES, GE7_QTDDES "
cQuery += " ORDER BY MAXVDES DESC  "

TCQUERY cQuery NEW ALIAS "TMPMAXPROC"
DbSelectArea("TMPMAXPROC")
DbGoTop()

If !Eof() //VERIFICA SE RETORNOU PROCEDIMENTO
	cProcGA7 :=TMPMAXPROC->GD7_CODDES
	nQtdGE7  :=TMPMAXPROC->GE7_QTDDES

	_MVTABSUS:= PadR(AllTrim(_MVTABSUS), Len(GA8->GA8_TABPRO)) // Ajusta corretamente o tamanho de _MVTABSUS para o Posicione abaixo.
	cProcSUS :=Posicione("GA8",3,xFilial("GA8")+_MVTABSUS+cProcGA7,"GA8_CODPRT") //Posiciona no Procedimento e Retorna Codigo do SUS Equivalente
	If Empty(cProcSUS)
		lTexto := .T.
		cTexto += STR0021 + cProcGA7 + STR0022 + cRegAte + STR0023 + CHR(13) + CHR(10)//"A despesa " ### "referente ao Registro de Atendimento " ### " não possue relacionamento SUS."
	EndIf
Else
	lTexto := .T.
	cTexto += STR0024 + cRegAte + CHR(13) + CHR(10)//"Não foram encontradas Despesas referentes ao Registro de Atendimento "
EndIf

DbSelectArea("TMPMAXPROC")
DbCloseArea()

Return({cProcGA7,cProcSUS,nQtdGE7})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetProcCon³ Saude                         ³ Data ³ 11/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o tipo do procedimento                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Retorna o codigo SUS do procedimento, e sua classificacao: ³±±
±±³          ³ "A"-Apac / "I"-Individualizado / "C"-Consolidado           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetProcCon(cCodDes,cRegAte,cTexto,lTexto,lVerApac,cCodApac)
Local cMVTABSUS  := SuperGetMV("MV_TABSUS")	// tabela do SUS
Local cSql       := ""
Local cTipo      := ""
Local cCodSus    := ""
Local lLog       := .T.
Local lAIH       := .F.
Default cCodApac := ""

If ExistBlock("HSPROCIHA")
	aRetPonto := ExecBlock("HSPROCIHA",.F.,.F.,{cCodDes,cRegAte})
	cCodSus := aRetPonto[1]
	cTipo   := aRetPonto[2]
Else
	If GA8->(DbSeek(xFilial("GA8")+cMVTABSUS+cCodDes))
		cCodSus := GA8->GA8_CODPRT
		If GA7->(DbSeek(xFilial("GA7")+cCodSus))
			cSql := " SELECT GK6_CODINR, GK6_CODPRO FROM " + RetSqlName("GK6")
			cSql += " WHERE GK6_FILIAL = '"+xFilial("GK6")+"' "
			cSql += " AND GK6_CODPRO = '"+cCodSus+"' "
			cSql += " AND GK6_COMPET = '"+GA7->GA7_COMPET+"' "
			cSql += " AND D_E_L_E_T_ <> '*' "

			cSql := ChangeQuery(cSql)

			DbUseArea(.T., "TOPCONN", TcGenQry(,, cSql), "TMPGK6", .F., .F.)
			DbSelectArea("TMPGK6")
			TMPGK6->(DbGotop())

			While !(TMPGK6->(Eof()))
				If lVerApac
				    If TMPGK6->GK6_CODINR $ "06" //APAC Principal
					    If Empty(cCodApac) .Or. cCodApac == TMPGK6->GK6_CODPRO
						    cTipo := "A"
						    Exit
						Else
						    lLog := .F.
						EndIf
					EndIf
				Else
					If TMPGK6->GK6_CODINR == "01" //Consolidado
						cTipo := "C"
						Exit
					ElseIf TMPGK6->GK6_CODINR == "02" //Individualizado
						cTipo := "I"
						Exit
					EndIf
				EndIf

				//Verifica se informaram um procedimento de AIH
				If TMPGK6->GK6_CODINR $ "03/04/05"
				    lAIH := .T.
				EndIf

				TMPGK6->(DbSkip())
			Enddo

			TMPGK6->(DbCloseArea())

			If Empty(cTipo) .And. !lVerApac .And. lLog .And. !lAIH
			    lTexto := .T.
			    cTexto += STR0025 + cCodDes + STR0026 + cRegAte + "." + CHR(13) + CHR(10)//"Não foi encontrada classificação para a despesa " ### " referente ao Registro de Atendimento "
			ElseIf Empty(cTipo) .And. !lVerApac .And. lLog .And. lAIH
                lTexto := .T.
			    cTexto += STR0021 + cCodDes + STR0026 + cRegAte + STR0027 + CHR(13) + CHR(10)//"A despesa " ### " referente ao Registro de Atendimento " ### " (Atendimento Ambulatorial) esta parametrizada como procedimento do tipo AIH."
			EndIf
		Else
			lTexto := .T.
			cTexto += STR0021 + cCodDes + STR0022 + cRegAte + STR0023 + CHR(13) + CHR(10)//"A despesa " ### "referente ao Registro de Atendimento " ### " não possue relacionamento SUS."
		EndIf
	EndIf
EndIf

Return({cCodSus,cTipo})
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetDiasUTI³ Saude                         ³ Data ³ 13/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o Numero de dias que o Paciente ficou em UTI       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RetDiasUTI(cProc,cRegAte)                                  ³±±
±±³          ³ Seleciona o todos os procedimento do atendimento           ³±±
±±³          ³ e retorna o de maior valor                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetDiasUTI(cRegAte)

LOCAL _CodLoc		:=""		// codigo do setor
LOCAL _Quarto		:="" 		// quarto do paciente
LOCAL _Leito		:=""		// leito do paciente
LOCAL _DataE		:=cTOD("") 	// data de entrada do paciente
LOCAL nDIASUTI		:=0			// dias na UTI

cQuery:=""

cQuery := " SELECT GB1_CODLOC,GB1_QUARTO,GB1_LEITO,GB1_DATAE,GB1_DATAS "
cQuery += " FROM "+ RetSqlName("GAV")  + " GAV,"+ RetSqlName("GB1")  + " GB1 "
cQuery += " WHERE "
cQuery += " GAV_FILIAL='"+xFilial("GAV")+"' "
cQuery += " AND GB1_FILIAL='"+xFilial("GB1")+"' "
cQuery += " AND GAV_CODLOC=GB1_CODLOC "
cQuery += " AND GAV_QUARTO=GB1_QUARTO "
cQuery += " AND GAV_LEITO=GB1_LEITO "
cQuery += " AND GAV_TIPO='4' "       			//TIPO DE LEITO UTI
cQuery += " AND GB1_REGATE='" + cRegAte + "' " 	//INDICA O REGISTRO DE ATENDIMENTO DO PACIENTE
cQuery += " AND GB1.D_E_L_E_T_!='*' "
cQuery += " AND GAV.D_E_L_E_T_!='*' "
cQuery += " ORDER BY GB1_DATAE "                // ordem por data de entrada no arquivo de movimentacao paciente
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPDIASUTI",.F.,.T.)

Tcsetfield("TMPDIASUTI","GB1_DATAE","D")
Tcsetfield("TMPDIASUTI","GB1_DATAS","D")
DbSelectArea("TMPDIASUTI")
DbGoTop()
While !Eof()

	IF TMPDIASUTI->GB1_CODLOC<>_CodLoc .AND. TMPDIASUTI->GB1_QUARTO<>_Quarto .AND. TMPDIASUTI->GB1_LEITO<>_Leito .AND. TMPDIASUTI->GB1_DATAE<>_DataE
		nDIASUTI+=TMPDIASUTI->GB1_DATAS-TMPDIASUTI->GB1_DATAE
		_CodLoc:= TMPDIASUTI->GB1_CODLOC
		_Quarto:= TMPDIASUTI->GB1_QUARTO
		_Leito := TMPDIASUTI->GB1_LEITO
		_DataE := TMPDIASUTI->GB1_DATAE
    Endif
	DbSkip()
End
DbSelectArea("TMPDIASUTI")
DbCloseArea()
Return(nDIASUTI)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetNasc   ³ Saude                         ³ Data ³ 17/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o Numero da declacao dos nascidos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetNasc(cRegAte, dDataDe, dDataAte)
Local aArea		:= GetArea()
Local cQuery	:= ""
Local aRet		:= {}

cQuery := " SELECT GB2_STNASC, GB2_NRODEC "
cQuery += " FROM "+ RetSqlName("GB2")  + " GB2 "
cQuery += " WHERE "
cQuery += " GB2_REGATE = '" + cRegAte + "' " 	//INDICA O REGISTRO DE ATENDIMENTO DO PACIENTE
cQuery += " AND GB2_DATALT BETWEEN '" + dDataDe + "' AND '" + dDataAte + "' "
cQuery += " AND GB2.D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPNASC",.F.,.T.)

DbSelectArea("TMPNASC")
DbGoTop()

While !Eof()
	If TMPNASC->GB2_STNASC == "1"		// Nativivo
		AADD(aRet, AllTrim(TMPNASC->GB2_NRODEC))
	ElseIf TMPNASC->GB2_STNASC == "2"	// Natimorto
		AADD(aRet, "99999999")
	Else								// Obito fetal
		AADD(aRet, "        ")
	EndIf
	TMPNASC->(DbSkip())
End

DbSelectArea("TMPNASC")
DbCloseArea()
RestArea(aArea)
Return(aRet)


Function Hs_RRnNasc(cRegAte,nNivel)
 Local aArea := GetArea()
 Local cRet  := ""
 Local cSQL  := ""

 Default nNivel := 7

 If Type('cLinha') == "U"
  _SetOwnerPrvt('cLinha', '')
 EndIf

 If at('<ansTISS:declaracoesNascidosVivos>',cLinha) > 0
  return("")
 EndIf

 cSQL += "SELECT GB2_NRODEC "
	cSQL += "FROM " + RetSqlName("GB2") + " GB2 "
	cSQL += "WHERE GB2_REGATE='" + cRegAte + "' AND GB2.D_E_L_E_T_ <> '*' "

 TCQuery cSQL New Alias "TMPQRYRN"

	DbSelectArea("TMPQRYRN")
	DbGoTop()

	While TMPQRYRN->(!Eof())
			cRet += Fs_RetTag("<ansTISS:numeroDN>" , ALLTRIM(TMPQRYRN->GB2_NRODEC), nNivel + 1)     //Numero de Declaracoes de Nascidos Vivos (1..10)
	 DbSkip()
 EndDo

	if !Empty(cRet)
		cRet := SPACE(nNivel)+"<ansTISS:declaracoesNascidosVivos>"+chr(10)+cRet
		cRet += SPACE(nNivel)+"</ansTISS:declaracoesNascidosVivos>"+chr(10)
	EndIf

 cLinha += cRet

	DbSelectArea("TMPQRYRN")
	DbCloseArea()

 RestArea(aArea)
Return("")

Function Hs_REqpMed(cSeqDes, cSPrinc, cTagCodPro, identEquipe, lCpfME)
//HS_REQPMED(HSPEDI->SEQDES, IIF(HSPEDI->TIPO == "E", HSPEDI->SEQPRI,""),"conselhoProfissional")                                                                                                                                                            
Local aArea := GetArea()
Local cRet  := ""
Local cSQL  := ""

If Type('cLinha') == "U"
	_SetOwnerPrvt('cLinha', '')
EndIf

Default cSPrinc := ""
Default cTagCodPro := "conselhoProfissional"
Default lCpfME := .T.
Default identEquipe := "CPF"

cSQL += "    SELECT GE7.GE7_CODCRM, GBJ.GBJ_CIC, GA9.GA9_CDOPER, GBJ_CONSEL, GBJ_UFCONS, GE7.GE7_CODATO, "
cSQL += "           SRA.RA_NOME, GBJ.GBJ_CBOTIS, GBJ.GBJ_TIPPRO, GMC.GMC_PPTISS, GBJ.GBJ_CDOPER "
cSQL += "      FROM "+RetSqlName("GE7")+" GE7 "
cSQL += "      JOIN "+RetSqlName("GBJ")+" GBJ "
cSQL += "        ON GBJ.GBJ_FILIAL = '"+xFilial("GBJ")+"' AND GBJ.D_E_L_E_T_ <> '*' AND GBJ.GBJ_CRM = GE7.GE7_CODCRM "
cSQL += "      JOIN "+RetSqlName("GCZ")+" GCZ "
cSQL += "        ON GCZ.GCZ_FILIAL = '"+xFilial("GCZ")+"' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = GE7.GE7_NRSEQG "
cSQL += "      JOIN "+RetSqlName("GA9")+" GA9 "
cSQL += "        ON GA9.GA9_FILIAL = '"+xFilial("GA9")+"' AND GA9.D_E_L_E_T_ <> '*' AND GA9.GA9_CODCON = GCZ.GCZ_CODCON "
cSQL += "      JOIN "+RetSqlName("SRA")+" SRA "
cSQL += "        ON SRA.RA_FILIAL = '"+xFilial("SRA")+"' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO = GE7.GE7_CODCRM "
cSQL += " LEFT JOIN "+RetSqlName("GMC")+" GMC "
cSQL += "        ON GMC.GMC_FILIAL = '"+xFilial("GMC")+"' AND GMC.D_E_L_E_T_ <> '*' AND GMC.GMC_CODATO = GE7.GE7_CODATO "
cSQL += "  WHERE GE7.GE7_FILIAL = '"+ xFilial("GE7")+"' AND GE7.D_E_L_E_T_ <> '*' "

If !Empty(cSPrinc)
	cSQL += "     AND GE7.GE7_SPRINC = '"+cSPrinc+"' "
Else
	cSQL += "     AND GE7.GE7_SEQDES = '"+cSeqDes+"' "
EndIf

TCQuery cSQL New Alias "TMPQRYEQM"

DbSelectArea("TMPQRYEQM")
DbGoTop()


If GetNewPar("MV_TISSVER", "2.02.03") >= "3" .and. alltrim(cTagCodPro) == Upper("ident")
	
	While !TMPQRYEQM->(Eof())
		cRet += SPACE(08)+"<ans:identEquipe>"+chr(10)
		cRet += SPACE(09)+"<ans:identificacaoEquipe>"+chr(10)
				
		cRet += Fs_RetTag("<ans:grauPart>" , ALLTRIM(PLSGETVINC("BTU_CDTERM","GMC",.F.,"35", ALLTRIM(TMPQRYEQM->GE7_CODATO))), 10)
		
		cRet += SPACE(10)+"<ans:codProfissional>"+chr(10)
		
		If Upper(identEquipe) == "CODIGOPRESTADORNAOPERADORA"
			cRet += Fs_RetTag("<ans:codigoPrestadorNaOperadora>", ALLTRIM(TMPQRYEQM->GBJ_CDOPER), 11)
		Else
			cRet += Fs_RetTag("<ans:cpfContratado>", ALLTRIM(TMPQRYEQM->GBJ_CIC), 11)
		EndIf
		
		cRet += SPACE(10)+"</ans:codProfissional>"+chr(10)
		cRet += Fs_RetTag("<ans:nomeProf>" , ALLTRIM(TMPQRYEQM->RA_NOME), 10)
		cRet += Fs_RetTag("<ans:conselho>", ALLTRIM(PLSGETVINC("BTU_CDTERM","BAH",.F.,"26", ALLTRIM(TMPQRYEQM->GBJ_CONSEL))), 10)
		cRet += Fs_RetTag("<ans:numeroConselhoProfissional>"    , ALLTRIM(TMPQRYEQM->GE7_CODCRM), 10)
		cRet += Fs_RetTag("<ans:UF>"    , ALLTRIM(PLSGETVINC("BTU_CDTERM","SX5",.F.,"59", "12"+ALLTRIM(TMPQRYEQM->GBJ_UFCONS))), 10)
		cRet += Fs_RetTag("<ans:CBOS>"    , ALLTRIM(PLSGETVINC("BTU_CDTERM","GN1",.F.,"24", ALLTRIM(TMPQRYEQM->GBJ_CBOTIS))), 10)
		
		cRet += SPACE(09)+"</ans:identificacaoEquipe>"+chr(10)
		cRet += SPACE(08)+"</ans:identEquipe>"+chr(10)
		
		TMPQRYEQM->( dbSkip() )
	EndDo
		
		//cRet := SPACE(08)+"<ans:identEquipe>"+chr(10)+cRet
		//cRet += SPACE(08)+"</ans:identEquipe>"+chr(10)
		cRet += SPACE(07)+"</ans:procedimentoExecutado>"
		
		cLinha := strtran(cLinha, "</ans:procedimentoExecutado>"+chr(10), "")
		cLinha := strtran(cLinha, "</ans:procedimentosExecutados>"+chr(10), "")
		cLinha := Alltrim(cLinha)
		cLinha += cRet	
	
Else
	
	While TMPQRYEQM->(!Eof())
		cRet += SPACE(09)+"<ansTISS:membroEquipe>"+chr(10)
		cRet += SPACE(10)+  "<ansTISS:codigoProfissional>"+chr(10)
		
		If Upper(cTagCodPro) == "CONSELHOPROFISSIONAL"
			
			cRet += SPACE(11)+"<ansTISS:conselhoProfissional>"+chr(10)
			cRet += Fs_RetTag("<ansTISS:siglaConselho>" , ALLTRIM(TMPQRYEQM->GBJ_CONSEL), 12)
			cRet += Fs_RetTag("<ansTISS:numeroConselho>", ALLTRIM(TMPQRYEQM->GE7_CODCRM), 12)
			cRet += Fs_RetTag("<ansTISS:ufConselho>"    , ALLTRIM(TMPQRYEQM->GBJ_UFCONS), 12)
			cRet += SPACE(11)+"</ansTISS:conselhoProfissional>"+chr(10)
			
		ElseIf Upper(cTagCodPro) == "CNPJ"
			cRet += Fs_RetTag("<ansTISS:CNPJ>", ALLTRIM(TMPQRYEQM->GBJ_CIC), 11)
		ElseIf Upper(cTagCodPro) == "CPF"
			cRet += Fs_RetTag("<ansTISS:cpf>", ALLTRIM(TMPQRYEQM->GBJ_CIC), 11)
		ElseIf	Upper(cTagCodPro) == "CODIGOPRESTADORNAOPERADORA"
			cRet += Fs_RetTag("<ansTISS:codigoPrestadorNaOperadora>", ALLTRIM(TMPQRYEQM->GBJ_CDOPER), 11)
		EndIf
		
		cRet += SPACE(10)+  "</ansTISS:codigoProfissional>"+chr(10)
		cRet += SPACE(10)+  "<ansTISS:identificacaoProfissional>"+chr(10)
		cRet += Fs_RetTag("<ansTISS:nomeExecutante>", ALLTRIM(TMPQRYEQM->RA_NOME), 11)
		cRet += SPACE(11)+ "<ansTISS:conselhoProfissional>"+chr(10)
		cRet += Fs_RetTag("<ansTISS:siglaConselho>" ,ALLTRIM(TMPQRYEQM->GBJ_CONSEL), 12)
		cRet += Fs_RetTag("<ansTISS:numeroConselho>",ALLTRIM(TMPQRYEQM->GE7_CODCRM), 12)
		cRet += Fs_RetTag("<ansTISS:ufConselho>",ALLTRIM(TMPQRYEQM->GBJ_UFCONS), 12)
		cRet += SPACE(11)+ "</ansTISS:conselhoProfissional>"+chr(10)
		cRet += Fs_RetTag("<ansTISS:codigoCBOS>" ,HS_CBOTIS(ALLTRIM(TMPQRYEQM->GBJ_CBOTIS)), 11)
		cRet += SPACE(10)+ "</ansTISS:identificacaoProfissional>"+chr(10)
		If !Empty(ALLTRIM(TMPQRYEQM->GBJ_CIC)) .AND. lCpfME
			cRet += Fs_RetTag("<ansTISS:cpf>", ALLTRIM(TMPQRYEQM->GBJ_CIC), 10)
		EndIf
		cRet += Fs_RetTag("<ansTISS:posicaoProfissional>" ,IIF(!Empty(TMPQRYEQM->GE7_CODATO),ALLTRIM(GMC_PPTISS), IIF(TMPQRYEQM->GBJ_TIPPRO $ "1/9","12","11")), 10)
		cRet += SPACE(09)+"</ansTISS:membroEquipe>"+chr(10)
		
		DbSkip()
	EndDo
	
	cRet := SPACE(08)+"<ansTISS:equipe>"+chr(10)+cRet
	cRet += SPACE(08)+"</ansTISS:equipe>"+chr(10)
	cLinha += cRet
	
EndIf



DbSelectArea("TMPQRYEQM")
DbCloseArea()

RestArea(aArea)
Return("")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³HS_VSprin ³ Rogerio Tabosa                ³ Data ³ 25/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor total referente ao procedimento            ³±±
±±³          ³ calculado já com os valores da equipe                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HS_VSprin(cSPrinc, cG7)
Local aArea := GetArea()
Local cSql 		:= ""
Local nValEqp   := 0

Default cG7 := "GE7"

cSql := " SELECT " + cG7 + "_SEQDES SEQDES FROM " + RetSqlName(cG7) + " GE7 "
cSql += " WHERE GE7.GE7_SPRINC = '" + cSPrinc + "' AND D_E_L_E_T_ <> '*' AND GE7.GE7_FILIAL = '"+ xFilial("GE7")+ "'"
cSql += "   AND GE7.GE7_PGTMED <> '0'"

TCQuery cSQL New Alias "TMPVALEQP"

DbSelectArea("TMPVALEQP")
DbGoTop()

While !TMPVALEQP->(Eof())
	nValEqp += HS_CVALDES(cG7, TMPVALEQP->SEQDES)
	TMPVALEQP->(DbSkip())
End

DbSelectArea("TMPVALEQP")
DbCloseArea()

RestArea(aArea)

Return(nValEqp)

//Static Function FS_LogProc(nHandle, cLog)
// fWrite(nHandle, cLog + CHR(13) + CHR(10), Len(cLog + CHR(13) + CHR(10)))
//Return(Nil)

Static Function Fs_RetTag(cTag, cCont, nSpace)
 Local cRet := ""

 If Empty(cCont)
  cRet := Substr(cTag, 1, at(">", cTag)-1)+"/>"
 Else
  cRet := Space(nSpace) + cTag + cCont +  "</" + Substr(cTag, at("<", cTag)+1)
  __cHXml += cCont
//  FS_LogProc(nHdlCont,cCont)
 EndIf
 cRet += Chr(10)

Return(cRet)
Function HS_CBOTis(cCBO)
Local cRet := ""

If Len(cCBO) == 6
       If ISDIGIT(Substr(cCBO,5,1)) == .T.
          cRet := Substr(cCBO,1,4) + "." + Substr(cCBO,5,2)
     Else
      cRet := Substr(cCBO,1,4) + "-" + Substr(cCBO,5,2)
EndIf
ElseIf Len(cCBO) == 5
   If ISDIGIT(Substr(cCBO,4,1)) == .T.
   cRet := Substr(cCBO,1,3) + "." + Substr(cCBO,4,2)
   Else
cRet := Substr(cCBO,1,3) + "-" + Substr(cCBO,4,2)
EndIf
	else
   cRet := cCBO
EndIf

Return(cRet)

Function HS_DATTis(cDat)
Local cRet := ""

If Len(Alltrim(cDat)) == 8
	cRet := Substr(cDat, 1, 4)+"-"+Substr(cDat, 5, 2)+"-"+Substr(cDat, 7, 2)
EndIf

Return(cRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	   ³HS_SENDXML³ Autor ³ Rogerio Machado Tabosa³ data ³ 01/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Envio do XML para Web Service do Convenio                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		     ³ Gestao Hospitalar                            												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HS_SENDXML(cUrl,cArq,cCodSol)

LOCAL oXmlRec		:= NIL
LOCAL cXmlRet		:= ""
LOCAL cXml			:= ""
LOCAL cMsg			:= ""
LOCAL cSoap			:= ""
LOCAL cNodPai		:= ""
LOCAL cErro			:= ""
LOCAL cAviso    	:= ""
LOCAL cDirRaiz		:= "C:\MP811\Protheus_Data\TISS\CAIXAENTRADA\"
LOCAL cArqLocal		:= "D:\MP811\Protheus_Data\TISS\CAIXAENTRADA\00000000000000002678_8e2eb2df98a8a193126ca7d180f94dc5_ALEX.xml"
LOCAL cFile			:= "XML PROC TESTE2.xml"
LOCAL cWs			:= "tissTransmiteMensagem.apw"//?wsdl"//"tissTransmiteMensagem.apw"//tisssolicitacaoprocedimento
LOCAL cWsZip		:= "tissTransmiteMensagemZIP.apw" // Este ws s00o existe na versao 3
LOCAL lTranmiteZip 	:= .F.
Local aDadosAut := {}
Local aProcsAut := {}
Local i := 0
Local cTeste := MemoRead( "C:\MP811\Protheus_Data\TISS\CAIXAENTRADA\ARQTESTE.TXT" )
Local cEnvServ := GetEnvServer()

cDirRaiz := Upper(GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97()))
If SubString (cDirRaiz,Len(cDirRaiz),Len(cDirRaiz)) == "\"
	cDirRaiz += "TISS\CAIXAENTRADA\"
Else
	cDirRaiz += "\TISS\CAIXAENTRADA\"
EndIf

//cUrl			:= "http://webwork.no-ip.info/"+cWs
//cUrl			:= "http://localhost/"+cWs
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Defini que o tipo de pacote e xml										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpCtType( "text/xml; charset=UTF-8" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Log do inicio															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua(0)
IncProc(OemToAnsi(STR0001))//"Inicio Envio Online..."
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara protocolo soap para envio										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSoap += '<?xml version="1.0" encoding="UTF-8"?>'
cSoap += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
cSoap += '<soap:Body>'
cSoap += '<mensagemTISSString xmlns="http://www.ans.gov.br/tiss/ws/tipos/tissTransmiteMensagem/v20103">'
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o xml de envio														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(OemToAnsi(STR0003))//"Lendo arquivo xml..."
cXml := MemoRead( cArq )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Compacta o arquivo														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTranmiteZip
	cXml := DECODE64(cXml)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Prepara o xml para envio como string									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cXml := HtmlNoTags( cXml )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui o xml no pacote soap												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSoap += cXml

cSoap += '</mensagemTISSString>'
cSoap += '</soap:Body>'
cSoap += '</soap:Envelope>'
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o arquivo gerado anteriormente e grava o novo para o envio		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(STR0004)   //"Preparando Arquivo de Envio..."
FErase("\TISS\CAIXAENTRADA\ENVIO.XML")
nH := FCreate( "\TISS\CAIXAENTRADA\ENVIO.XML",2)
	FWrite(nH,cSoap)
FClose(nH)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia o arquivo para operadora											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(STR0006)  //"Enviando Arquivo para WebService..."
cXmlRet := HttpPostXml( cUrl+cWs , , cDirRaiz+"ENVIO.XML" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o retono foi com sucesso									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(cXmlRet) == 'U'
	cMsg := STR0008 //"Verifique a Conectividade com o Serviço!"
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o parse do soap de retorno										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(STR0009)  //"Verificando arquivo retornado..."
	oXmlRec	:= XmlParser( cXmlRet ,"_",@cErro,@cAviso )

	If 	XmlNodeExist(oXmlRec,"_DEFINITIONS") .And.;
		XmlNodeExist(oXmlRec:_DEFINITIONS,"_TYPES") .And.;
		XmlNodeExist(oXmlRec:_DEFINITIONS:_TYPES,"_SCHEMA") .And.;
		XmlNodeExist(oXmlRec:_DEFINITIONS:_TYPES:_SCHEMA,"_XMLNS_WSDL") .And.;
		Lower(oXmlRec:_DEFINITIONS:_TYPES:_SCHEMA:_XMLNS_WSDL:REALNAME) == 'xmlns:wsdl'

		cWs := "tissTransmiteMensagem.apw"
	//	cUrl:= "http://webwork.no-ip.info/"+cWs
		cXmlRet := HttpPostXml( cUrl , , cDirRaiz+"ENVIO.XML" )

		If ValType(cXmlRet) == 'U'
			Return STR0008// "Verifique a Conectividade com o Serviço!"
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta o parse do soap de retorno										 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oXmlRec	:= XmlParser( cXmlRet ,"_",@cErro,@cAviso )
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se tem erro no parse											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cErro) .And. Empty(cAviso)
		cNodPai	:= "oXmlRec"
		While .T.
		    If XmlChildCount( Eval( &( "{||"+cNodPai+"}" ) ) ) > 0
				oNodFilho := XmlGetchild( Eval( &( "{||"+cNodPai+"}" ) ) , XmlChildCount( Eval( &( "{||"+cNodPai+"}" ) ) ))
				If oNodFilho:Type <> "NOD"
					Exit
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se e a transacao transmiteMensagemZip							 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If "MENSAGEMTISSZIP" $ Upper(oNodFilho:REALNAME)
					oNodFilho := XmlGetchild( Eval( &( "{||"+cNodPai+"}" ) ) , XmlChildCount( Eval( &( "{||"+cNodPai+"}" ) ) ))
					cNodPai += ":_"+StrTran(StrTran(oNodFilho:REALNAME,":","_"),"-","_")
					cNodPai += ":_"+StrTran(StrTran(oNodFilho:REALNAME,":","_"),"-","_")
					Exit
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta NO pai															 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cNodPai += ":_"+StrTran(StrTran(oNodFilho:REALNAME,":","_"),"-","_")
			Else
				Exit
			EndIf
		EndDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe algum conteudo no pacote								 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty( Eval( &("{||"+cNodPai+":TEXT }") ) )
			cMsg := STR0010 // "Pacote SOAP-XML Vazio"
		Endif
	Else
	    cMsg := Iif( !Empty(cErro) ," Erro: "+cErro,"")
	    cMsg += Iif( !Empty(cAviso)," Aviso: "+cAviso,"")
		cMsg += STR0011  //", Erro ao tentar fazer o parse do arquivo xml"
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe o retorno se tudo ok												 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cMsg)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pega conteudo do obj mensagem String xml							     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cXml := Eval( &("{||"+cNodPai+":TEXT }") )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Descompacta ZIP	se for a transacao tissTransmitemensagemZIP				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTranmiteZip
			cXml := DECODE64(cXml)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o parse do xml de resposta											 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oXml := XmlParser( HtmlTags( cXml ) ,"_",@cErro,@cAviso )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso exita erro no parse do xml de retorno								 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cErro) .And. !Empty(cAviso)
		    cMsg := Iif( !Empty(cErro) ," Erro: "+cErro,"")
		    cMsg += Iif( !Empty(cAviso)," Aviso: "+cAviso,"")
			cMsg += STR0011 //", Erro ao tentar fazer o parse do arquivo xml"
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pega a resposta do processameto											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(STR0012) //"Verificando resposta do processamento..."


If ValType(oXml) <> "O"
	cMsg := "Arquivo XML de Retorno Incorreto"
	Return(cMsg)
EndIf

	If Empty(cMsg)
  		If Fs_ChkXml(oXml,"_ANS_MENSAGEMTISS:_ANS_CABECALHO:_ANS_FALHANEGOCIO")
			cMsg := STR0013 + "<br/>"  // "Falha na operacao<br/>"
			cMsg += oXml:_ANS_MENSAGEMTISS:_ANS_CABECALHO:_ANS_FALHANEGOCIO:_ANS_CODIGOGLOSA:TEXT+"  "
			cMsg += oXml:_ANS_MENSAGEMTISS:_ANS_CABECALHO:_ANS_FALHANEGOCIO:_ANS_DESCRICAOGLOSA:TEXT+"  "
			cMsg +=	IIf(Fs_ChkXml(oXml,"_ANS_MENSAGEMTISS:_ANS_CABECALHO:_ANS_FALHANEGOCIO:_ANS_OBSERVACAO"),oXml:_ANS_MENSAGEMTISS:_ANS_CABECALHO:_ANS_FALHANEGOCIO:_ANS_OBSERVACAO:TEXT," ")						//cMsg += oXml:_ANS_MENSAGEMTISS:_ANS_CABECALHO:_ANS_FALHANEGOCIO:_ANS_OBSERVACAO:TEXT
		ElseIf Fs_ChkXml(oXml,"_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_PROTOCOLORECEBIMENTO:_ANS_MENSAGEMDETALHEPROTOCOLO") .And. Fs_ChkXml(oXml,"_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_PROTOCOLORECEBIMENTO:_ANS_MENSAGEMDETALHEPROTOCOLO:_ANS_GUIAS:_ANS_DADOSGUIA:_ANS_PROCEDIMENTOS:_ANS_DADOSPROCEDIMENTO:_ANS_RELACAOGLOSA")
			cMsg := STR0014 + "<br/>"  //"Guia Glosada<br/>"
			cMsg += oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_PROTOCOLORECEBIMENTO:_ANS_MENSAGEMDETALHEPROTOCOLO:_ANS_GUIAS:_ANS_DADOSGUIA:_ANS_PROCEDIMENTOS:_ANS_DADOSPROCEDIMENTO:_ANS_RELACAOGLOSA:_ANS_TIPOGLOSA:_ANS_CODIGOGLOSA:TEXT+"<br/>"
			cMsg += oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_PROTOCOLORECEBIMENTO:_ANS_MENSAGEMDETALHEPROTOCOLO:_ANS_GUIAS:_ANS_DADOSGUIA:_ANS_PROCEDIMENTOS:_ANS_DADOSPROCEDIMENTO:_ANS_RELACAOGLOSA:_ANS_TIPOGLOSA:_ANS_DESCRICAOGLOSA:TEXT
		ElseIf Fs_ChkXml(oXml,"_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO")
			//If !Fs_ChkXml(oXml,"_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_DADOSAUTORIZACAO")
				If Fs_ChkXml(oXml,"_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_PROCEDIMENTOS:_ANS_PROCEDIMENTO:_ANS_GLOSAS:_ANS_MOTIVOGLOSA")
		 			cMsg := STR0014 + " - " //"GUIA GLOSADA - "
 						If  ValType(oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_PROCEDIMENTOS:_ANS_PROCEDIMENTO)=="O"
							cMsg += " Codigo: " + oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_PROCEDIMENTOS:_ANS_PROCEDIMENTO:_ANS_GLOSAS:_ANS_MOTIVOGLOSA:_ANS_CODIGOGLOSA:TEXT + " - "
							cMsg += " Motivo: " + oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_PROCEDIMENTOS:_ANS_PROCEDIMENTO:_ANS_GLOSAS:_ANS_MOTIVOGLOSA:_ANS_DESCRICAOGLOSA:TEXT + " - "
						Else
			     			For i := 1 to Len(oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_PROCEDIMENTOS:_ANS_PROCEDIMENTO)
						   		cMsg += " Codigo: " + oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_PROCEDIMENTOS:_ANS_PROCEDIMENTO[i]:_ANS_GLOSAS:_ANS_MOTIVOGLOSA:_ANS_CODIGOGLOSA:TEXT + " - "
						   		cMsg += " Motivo: " + oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_PROCEDIMENTOS:_ANS_PROCEDIMENTO[i]:_ANS_GLOSAS:_ANS_MOTIVOGLOSA:_ANS_DESCRICAOGLOSA:TEXT + " - "
			  				Next i
			  			EndIf
			  	Else

				cMsg := STR0015 //"Guia Processada "
				//Procedimentos Autorizados
				oXmlAut := oXml
				If  ValType(oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_PROCEDIMENTOS:_ANS_PROCEDIMENTO)=="O"
					AADD(aProcsAut,{oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_PROCEDIMENTOS:_ANS_PROCEDIMENTO:_ANS_IDENTIFICACAOPROCEDIMENTOS:_ANS_CODIGO:TEXT,;
					oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_PROCEDIMENTOS:_ANS_PROCEDIMENTO:_ANS_QUANTIDADESOLICITADA:TEXT,;
					oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_PROCEDIMENTOS:_ANS_PROCEDIMENTO:_ANS_QUANTIDADEAUTORIZADA:TEXT})
		   		Else
					For i := 1 to Len(oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_PROCEDIMENTOS:_ANS_PROCEDIMENTO)
						AADD(aProcsAut,{oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_PROCEDIMENTOS:_ANS_PROCEDIMENTO[i]:_ANS_IDENTIFICACAOPROCEDIMENTOS:_ANS_CODIGO:TEXT,;
						oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_PROCEDIMENTOS:_ANS_PROCEDIMENTO[i]:_ANS_QUANTIDADESOLICITADA:TEXT,;
						oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_PROCEDIMENTOS:_ANS_PROCEDIMENTO[i]:_ANS_QUANTIDADEAUTORIZADA:TEXT,;
						oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_PROCEDIMENTOS:_ANS_PROCEDIMENTO[i]:_ANS_QUANTIDADEAUTORIZADA:TEXT,;
						oXml:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_PROCEDIMENTOS:_ANS_PROCEDIMENTO[i]:_ANS_STATUSSOLICITACAOPROCEDIMENTO:TEXT})
					Next i
				EndIf
   				//Dados da autorizacao
   				If Fs_ChkXml(oXmlAut,"_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_DADOSAUTORIZACAO")
   					aDadosAut := {IIf(Fs_ChkXml(oXmlAut,"_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_STATUSSOLICITACAO"),oXmlAut:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_STATUSSOLICITACAO:TEXT,"3"),;
                 	IIf(Fs_ChkXml(oXmlAut,"_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_DADOSAUTORIZACAO:_ANS_DATAAUTORIZACAO"),oXmlAut:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_DADOSAUTORIZACAO:_ANS_DATAAUTORIZACAO:TEXT,DTOC(dDataBase)),;
                 	IIf(Fs_ChkXml(oXmlAut,"_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_DADOSAUTORIZACAO:_ANS_SENHAAUTORIZACAO"),oXmlAut:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_DADOSAUTORIZACAO:_ANS_SENHAAUTORIZACAO:TEXT,""),;
                 	IIf(Fs_ChkXml(oXmlAut,"_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_DADOSAUTORIZACAO:_ANS_VALIDADESENHA"),oXmlAut:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_DADOSAUTORIZACAO:_ANS_VALIDADESENHA:TEXT,""),;
                 	IIf(Fs_ChkXml(oXmlAut,"_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_DADOSAUTORIZACAO:_ANS_DIASAUTORIZADO"),oXmlAut:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_DADOSAUTORIZACAO:_ANS_DIASAUTORIZADO:TEXT,""),;
                 	IIf(Fs_ChkXml(oXmlAut,"_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_DADOSAUTORIZACAO:_ANS_DATAPROVAVELADMISHOSP"),oXmlAut:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_DADOSAUTORIZACAO:_ANS_DATAPROVAVELADMISHOSP:TEXT,DTOC(dDataBase))}
        		Else
        			If Fs_ChkXml(oXmlAut,"_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_IDENTIFICACAOAUTORIZACAO")
        			aDadosAut := {"",DTOC(dDataBase),oXmlAut:_ANS_MENSAGEMTISS:_ANS_OPERADORAPARAPRESTADOR:_ANS_AUTORIZACAOSERVICO:_ANS_IDENTIFICACAOAUTORIZACAO:_ANS_NUMEROGUIAOPERADORA:TEXT,"","",""}
        			For i := 1 to Len(aProcsAut)
        				If Alltrim(aProcsAut[i][5]) <> "1"
        					aDadosAut[1] := "3"
        				EndIf
        			Next i
        				aDadosAut [1] := IIf (aDadosAut [1] <> "3","1",aDadosAut [1])
        			Else
        			cMsg := "Dados da autorização insuficientes!"
        			Return(cMsg)
        			EndIf
        		EndIf
   				IncProc(STR0016)   //"Gravando retorno da solicitação..."
				Fs_GrvAut(cCodSol,aDadosAut,aProcsAut)
			 	EndIf
			//End If
		EndIf
 EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Defini que o tipo de pacote e html										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

HttpCtType( "text/html; charset=UTF-8" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														  	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cMsg


STATIC Function HtmlTags(cXml)

cXml := StrTran(cXml,"&lt;","<")
cXml := StrTran(cXml,"&gt;",">")
cXml := StrTran(cXml,"&amp;","&")
cXml := StrTran(cXml,"&quot;",'"')
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina															³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(cXml)

//	XmlNodeExist(oXml:_ANS_MENSAGEMTISS:_ANS_CABECALHO,"_ANS_FALHANEGOCIO")
Static Function Fs_ChkXml(oXml,cXml,cAux)

 //Local lRet := .F.//File(IIF(Substr(cDir, Len(cDir)) $ "\/",SubStr(cDir, 1, Len(cDir)-1),cDir))
 Local nPos      := 0
 Local lAchou    := .F.
 Private oXmlPrvt

 Default cAux := ""

 If (ValType(oXml)=="O")
  oXmlPrvt := oXml
 EndIf

If Len(cXml) == 1 .And. cXml == ":"
 Return(.T.)
ElseIf Substr(cXml,Len(cXml)) <> ":"
 cXml += ":"
EndIf

 If (nPos := at(":",cXml)) >0
//  cAux += IIf(Len(Alltrim(cAux))>0,":" + Substr(cXml,1,nPos-1), Substr(cXml,1,nPos-1))
  cAux := Substr(cXml,1,nPos-1)
  cXml := Substr(cXml,nPos+1,Len(cXml))
 EndIf

If XmlNodeExist(oXmlPrvt,cAux)
 If (ValType(&("oXmlPrvt:" + cAux))=="A")
  lAchou := Empty(cXml) .Or. Fs_ChkXml((&("oXmlPrvt:" + cAux))[1],cXml,cAux)
 Else
  oXmlPrvt := &("oXmlPrvt:" + cAux)
  lAchou := Empty(cXml) .Or. Fs_ChkXml(oXmlPrvt,cXml,cAux)
 EndIf
Else
 lAchou := .F.
EndIf

Return(lAchou)

//GRAVA DADOS DO XML RETORNADO REFERENTE A AUTORIZACAO DOS PROCEDIMENTOS
Static Function Fs_GrvAut(cCodSol,aDadosAut,aProcsAut)

Local aGe := {{"GE2",3},{"GE3",3}}
Local cAlias := ""
Local i:=0 , j:=0

Begin Transaction
	DbSelectArea("GNX")

	DbSetOrder(1)
 lAchou := DbSeek(xFilial("GNX") + cCodSol)

 RecLock("GNX", !lAchou)
  GNX->GNX_FILIAL  := xFilial("GNX")
  GNX->GNX_STATUS  := IIf(aDadosAut[1]=="1","2",IIf(aDadosAut[1]=="2","1","3"))
  GNX->GNX_DATSOL  := dDataBase
  GNX->GNX_HORSOL  := TIME()
  GNX->GNX_DATAUT  := CTOD(aDadosAut[2])
  GNX->GNX_SENHA   := aDadosAut[3]
  GNX->GNX_DATVLD  := CTOD(aDadosAut[4])
  If ValType(aDadosAut[5]) == "C"
	GNX->GNX_DIAAUT  := Val(aDadosAut[5])
  ElseIf ValType(aDadosAut[5]) == "N"
  	GNX->GNX_DIAAUT  := aDadosAut[5]
  EndIf
  GNX->GNX_DTPADM  := CTOD(aDadosAut[6])
 MsUnLock()

 DbSelectArea("GNX")
 DbCloseArea()

For i:= 1 To Len (aGe)
 cAlias := aGe[i][1]
 DbSelectArea(cAlias)
 DbSetOrder(aGe[i][2])
 For j := 1 To Len(aProcsAut)
 lAchou := DbSeek(xFilial(cAlias) + cCodSol + aProcsAut[j,1])
  If lAchou
   RecLock(aGe[i][1],!lAchou)
   &(cAlias + "->" + cAlias + "_DATAUT")  := CTOD(aDadosAut[2])
   &(cAlias + "->" + cAlias + "_HORAUT")   := TIME()
	If ValType(aDadosAut[4]) == "C"
		&(cAlias + "->" + cAlias + "_VALAUT")   := Val(aDadosAut[4])
	ElseIf ValType(aDadosAut[4]) == "N"
		&(cAlias + "->" + cAlias + "_VALAUT")   := aDadosAut[4]
	EndIf
   &(cAlias + "->" + cAlias + "_SENAUT")   := aDadosAut[3]
   &(cAlias + "->" + cAlias + "_QTDAUT")   := Val(aProcsAut[j,3])
   &(cAlias + "->" + cAlias + "_STATUS")   := IIf(aDadosAut[1]=="2","1",IIf(Val(aProcsAut[j,3])=Val(aProcsAut[j,2]),"2","3"))
   MsUnLock()
  EndIf
 Next j
 DbSelectArea(cAlias)
 DbCloseArea()
Next i

End Transaction

Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³HTotValXml³ Autor ³ Microsiga             ³ data ³ 15/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica valor para totalizador do procedimento no Xml Tiss³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	     ³ Gestao Hospitalar                      				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HTotValXml(cSeqPri,cSeqDes,cSeqPri,cPgtMed)
Local nVal := 0
Local cKey := ""
Local lPagMed := .F.
Local aArea   := GetArea()

If Empty(cSeqPri)
    If cPgtMed <> '0'
    	nVal := HS_CVALDES("GE7",cSeqDes)
    EndIf
Else
    GE7->(DbSetOrder(7))//GE7_FILIAL+GE7_SPRINC+GE7_SEQDES
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Verifica se ha procedimentos relacionados (atraves do GE7_SPRINC)       ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If GE7->(DbSeek(xFilial("GE7")+cSeqPri))
        cKey := GE7->(GE7_FILIAL+GE7_SPRINC)
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Verifica se ha alguma participacao com repasse						   ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        While GE7->(GE7_FILIAL+GE7_SPRINC) == cKey .And. !GE7->(Eof())
            If GE7->GE7_PGTMED <> '0'
                lPagMed := .T.
                Exit
            EndIf
            GE7->(DbSkip())
        EndDo
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    	//³ Se achou repasse, incrementa valor           							³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	If lPagMed
        	nVal := HS_VSPRIN(cSeqPri)
    	EndIf
    Else
        If cPgtMed <> '0'
            nVal := HS_VSPRIN(cSeqPri)
        Endif
    EndIf
EndIf

RestArea(aArea)

Return nVal
