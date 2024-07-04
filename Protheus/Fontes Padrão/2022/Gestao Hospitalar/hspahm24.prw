#INCLUDE "HSPAHM24.ch"
#include "protheus.ch"
#INCLUDE "TopConn.ch"


// Para chamar as rotinas do M24 de qualquer lugar do mÛdulo deve-se declarar a matriz aExecM24 :
// aExecM24[1] := "0" para internaÁ„o
//                "1" para ambulatorial
//                "2" para pronto atendimento
//                "3" para atendimento doacao
// aExecM24[2] := CÛdigo do registro de atendimento do paciente
// aExecM24[3] := "P" para usar os arquivos do paciente GD5, GD6 e GD7 ou
//                "F" para usar os arquivos do faturamento GE5, GE6 e G67
// aExecM24[4] := PosiÁ„o do aRotina da funÁ„o a ser executada

/******************************************************************************************************
Observacoes referentes as Tabelas GD5, GD6, GD7, GE5, GE6, GE7:
- Sempre que um campo for criado para alguma dessas tabelas, o mesmo devera ser criado para a tabela
  GG correspondente(GG5, GG6, GG7)
- Caso o campo nao tenha sido criado na GG a rotina do Faturamento por Pacote apresentara um erro, pois
  nao faz a validacao automatica da diferenca de campos entre essas tabelas.
******************************************************************************************************/

Function HS_CtrlM24(aExecM24)
Local aArea := HS_SavArea({{Alias(), 0, 0}})
Private __aGeISol := {} // itens a serem enviados para o controle de solicitacoes, sera utilizado na funcao de validacao do procedimento HS_VPROCED
Private __aGeMSol := {} // itens a serem enviados para o controle de solicitacoes, sera utilizado na funcao de validacao do codigo de barras (MAT/MED) HS_VCODBAR

If !Empty(aExecM24[2])
	DbSelectArea("GCY")
	DbSetOrder(1)
	DbSeek(xFilial("GCY") + aExecM24[2])
EndIf

If aExecM24[1] == "0" // InternaÁ„o
	HSPM24AI(aExecM24)
ElseIf aExecM24[1] == "1" // Ambulatorial
	HSPM24AA(aExecM24)
ElseIf aExecM24[1] == "2" // Pronto Atendimento
	HSPM24PA(aExecM24)
ElseIf aExecM24[1] == "3" // Atendimento de Doacao
	HSPM24AD(aExecM24)
EndIf

HS_ResArea(aArea)
Return(Nil)

Function HSPM24AI(aExecM24) // InternaÁ„o

 Local aRotAge := {{OemtoAnsi(STR0008), "HS_AgeM24" , 0, 02}, ;    //"&8-Agenda Cir."
                   {OemtoAnsi(STR0101), 'HS_ConsAge("C")', 0, 02}} //"Cons. Agenda"

 Local aRotRel := {{OemtoAnsi(STR0257), "HS_RelM24", 0, 02},; //"Docs/Relat"
                    {OemtoAnsi(STR0256), 'HS_MntTISS("M24",,, 1)', 0, 02},; //"Guias TISS"
                    {OemtoAnsi(STR0300), 'HS_RelSUS', 0, 02}} //"Docts SUS"

 Local aRotM24 := {{OemtoAnsi(STR0001), "axPesqui" , 1, 01} , ; // 01 //"&0-Pesquisar"
                   {OemtoAnsi(STR0002), "HS_RecM24", 2, 02} , ; // 02 //"&1-Consultar"
                   {OemtoAnsi(STR0003), "HS_RecM24", 3, 03} , ; // 03 //"&U-R.Cirurgica"
                   {OemtoAnsi(STR0004), "HS_RecM24", 4, 04} , ; // 04 //"&3-Alterar"
                   {OemtoAnsi(STR0005), "HS_P36Can", 5, 02} , ; // 05 //"&4-Cancelar"
                   {OemtoAnsi(STR0006), "HS_P36Ret", 6, 04} , ; // 06 //"&5-Retornar"
                   {OemtoAnsi(STR0007), "HS_RecM24", 7, 04} , ; // 07 //"&6-Guias"
                   {OemtoAnsi(STR0008),   aRotAge  , 8, 02} , ; // 08 //"&8-Agenda Cir."
                   {OemtoAnsi(STR0009),   aRotRel  , 9, 02} , ; // 09 //"&8-Docs/Relat."
                   {OemtoAnsi(STR0019), "HS_M30Tra", 10, 03}, ; // 10 //"&F-Transfere"
                   {OemtoAnsi(STR0010), "HS_MdLM24", 11, 02}, ; // 11 //"&O-Modif.Leito"
                   {OemtoAnsi(STR0102), "HS_PesMed", 12, 04}, ; // 12 //"&M-MÈdico"
                   {OemtoAnsi(STR0012), "HS_RecM24", 13, 03}, ; // 13 //"&R-Rec. Normal"
                   {OemtoAnsi(STR0013), "HS_RNaM24", 14, 02}, ; // 14 //"&N-RN"
                   {OemtoAnsi(STR0014), "HS_ExtM24", 15, 02}, ; // 15 //"&E-Extrato"
                   {OemtoAnsi(STR0103), "HS_GarM24", 16, 02}, ; // 16 //"&G-Garantia"
                   {OemtoAnsi(STR0104), "HS_PacM24", 17, 04}, ; // 17 //"&C-Paciente"
                   {OemtoAnsi(STR0015), "HS_LegM24", 18, 02}, ; // 18 //"&L-Legenda"
                   {OemtoAnsi(STR0283), "HSPAHM08(GCY->GCY_REGATE)", 19, 02}}// "Pedido de Exames"

 Private cM24Par01 := ""
 Private cCadastro := STR0016 //"InternaÁ„o"
 Private cPergM24  := "HSPMAI"
 Private cAgdFilAge := ""
 Private cAgdCodAge := ""
 Private cCodSol   := ""

 HS_ATXBGCS()

 HSPAHM24("0", aRotM24, aExecM24)

Return(Nil)

//========================================================================================================================================================================================================================================================================================
Function HSPM24AA(aExecM24) // Ambulatorial

 Local aRotAlt := {{OemtoAnsi(STR0105), "HS_CAlM24" , 0, 01}, ; // 01 //"Cancela Alta"
                   {OemtoAnsi(STR0011), "HS_AltM24", 0, 04}}    // 14 //"&A-Alta"

 Local aRotAge :=  {{OemtoAnsi(STR0018), "HS_AgeM24" , 0, 03}, ;     //"&7-Agenda Amb."
                   {OemtoAnsi(STR0101),  'HS_ConsAge("A")', 0, 02}}  //"Cons. Agenda"

 Local aRotSol :=  {{OemtoAnsi(STR0020), "HS_SPrM24" , 0, 03}, ;  // 01 //Sol. Pront
                    {OemtoAnsi(STR0106), 'HS_MntM04("GAI", 0, 2)', 0, 03}, ; //02 //"Sol. Mat/Med"
                   {OemtoAnsi(STR0283), "HSPAHM08(GCY->GCY_REGATE)", 0, 04}} //Pedido de Exames

 Local aRotRel := {{OemtoAnsi(STR0257), "HS_RelM24", 0, 02},; //"Docs/Relat"
                    {OemtoAnsi(STR0256), 'HS_MntTISS("M24",,, 1)', 0, 02},; //"Guias TISS"
                    {OemtoAnsi(STR0301), 'HSPRQUES("GFK", "GFK_CDANAM", "","",GCY->GCY_REGATE,,,GCY->GCY_CODLOC)', 0, 02}} //"Anamnese

 Local aRotCaixa := {{OemtoAnsi(STR0261), "HS_ImpCntP", 0, 02},; //"Conta PrÈvia"
                      {OemtoAnsi(STR0262), "HS_GerCaix(1)", 0, 02},; //"Gerar Caixa"
                      {OemtoAnsi(STR0263), "HS_GerCaix(2)", 0, 02},; //"Faturar"
                      {OemtoAnsi(STR0264), "HS_ExcCaix", 0, 02}}  //"Excluir Fatura"

 Local aRotM24 := {{OemtoAnsi(STR0001), "axPesqui" , 1, 01} , ; // 01 //"&0-Pesquisar"
                   {OemtoAnsi(STR0002), "HS_RecM24", 2, 02} , ; // 02 //"&1-Consultar"
                   {OemtoAnsi(STR0017), "HS_RecM24", 3, 03} , ; // 03 //"&2-Recepcionar"
                   {OemtoAnsi(STR0004), "HS_RecM24", 4, 04} , ; // 04 //"&3-Alterar"
                   {OemtoAnsi(STR0005), "HS_P36Can", 5, 02} , ; // 05 //"&4-Cancelar"
                   {OemtoAnsi(STR0006), "HS_P36Ret", 6, 04} , ; // 06 //"&5-Retornar"
                   {OemtoAnsi(STR0007), "HS_RecM24", 7, 04} , ; // 07 //"&6-Guias"
                   {OemtoAnsi(STR0018),    aRotAge , 8, 03} , ; // 08 //"&7-Agenda Amb."
                   {OemtoAnsi(STR0009),    aRotRel , 9, 02} , ; // 09 //"&8-Docs/Relat."
                   {OemtoAnsi(STR0019), "HS_RecM24", 10, 03}, ; // 10 //"&F-Transfere"
                   {OemtoAnsi(STR0107),     aRotSol, 11, 03}, ; // 11 //"&T-Solicitar"
                   {OemtoAnsi(STR0021), "HS_ExaM24", 12, 02}, ; // 12 //"&R-Res. Exames"
                   {OemtoAnsi(STR0022), "HS_RecM24", 13, 03}, ; // 13 //"&I-Encaixe"
                   {OemtoAnsi(STR0011),   aRotAlt  , 14, 04}, ; // 14 //"&A-Alta"
                   {OemtoAnsi(STR0014), "HS_ExtM24", 15, 02}, ; // 15 //"&E-Extrato"
                   {OemtoAnsi(STR0103), "HS_GarM24", 16, 02}, ; // 16 //"&G-Garantia"
                   {OemtoAnsi(STR0104), "HS_PacM24", 17, 04}, ; // 17 //"&C-Paciente"
                   {OemtoAnsi(STR0015), "HS_LegM24", 18, 02}, ; // 18 //"&L-Legenda"
                   {OemtoAnsi(STR0242), "HS_TriM24", 19, 04}, ; // 19 //"Triagem"
 				   {OemtoAnsi(STR0265),  aRotCaixa , 20, 04},;  // 20 //"Cai&xa"
				   {OemtoAnsi("Ctrl Sessıes"), "HS_CtrTer" , 20, 02} ,;
                   {OemtoAnsi("Pedido de Exames"), "HSPAHM08(GCY->GCY_REGATE)", 19, 02}}// "Pedido de Exames"

 Private cM24Par01 := ""
 Private cM24Par02 := CToD(" ")
 Private cM24Par03 := CToD(" ")

 Private cCadastro  := STR0023 //"Atendimento Ambulatorial"
 Private cPergM24   := "HSPMAA"
 Private cAgdFilAge := ""
 Private cAgdCodAge := ""
 Private __cTabPrUt := "" // Variavel utilizada para calculo do valor do procecimento

 HS_ATXBGCS()
 
 HSPAHM24("1", aRotM24, aExecM24)

Return(Nil)
//========================================================================================================================================================================================================================================================================================
Function HSPM24PA(aExecM24) // Pronto Atendimento

 Local aRotAlt := {{OemtoAnsi(STR0105), "HS_CAlM24" , 0, 01}, ; // 01 //"Cancela Alta"
                   {OemtoAnsi(STR0011), "HS_AltM24", 0, 04}}    // 14 //"&A-Alta"

 Local aRotAge :=  {{OemtoAnsi(STR0018), "HS_AgeM24" , 0, 03}, ;     //"&7-Agenda Amb."
                   {OemtoAnsi(STR0101),  'HS_ConsAge("A")', 0, 02}}  //"Cons. Agenda"

 Local aRotSol :=  {{OemtoAnsi(STR0020), "HS_SPrM24" , 0, 03}, ;  // 01 //Sol. Pront
                    {OemtoAnsi(STR0106), 'HS_MntM04("GAI", 0, 2)', 0, 03}, ; //02 //"Sol. Mat/Med"
                   {OemtoAnsi(STR0283), "HSPAHM08(GCY->GCY_REGATE)", 0, 04}} //Pedido Exames

 Local aRotRel := {{OemtoAnsi(STR0257), "HS_RelM24", 0, 02},; //"Docs/Relat"
                    {OemtoAnsi(STR0256), 'HS_MntTISS("M24",,, 1)', 0, 02},; //"Guias TISS"
                    {OemtoAnsi(STR0301), 'HSPRQUES("GFK", "GFK_CDANAM", "","",GCY->GCY_REGATE,,,GCY->GCY_CODLOC)', 0, 02}} //"Anamnese

 Local aRotCaixa := {{OemtoAnsi(STR0261), "HS_ImpCntP", 0, 02},;//"Conta PrÈvia"
                      {OemtoAnsi(STR0262), "HS_GerCaix(1)", 0, 02},;//"Gerar Caixa"
                      {OemtoAnsi(STR0263), "HS_GerCaix(2)", 0, 02},;//"Faturar"
                      {OemtoAnsi(STR0264), "HS_ExcCaix", 0, 02}} //"Excluir Fatura"

 Local aRotM24 := {{OemtoAnsi(STR0001), "axPesqui" , 1, 01} , ; // 01 //"&0-Pesquisar"
                   {OemtoAnsi(STR0002), "HS_RecM24", 2, 02} , ; // 02 //"&1-Consultar"
                   {OemtoAnsi(STR0017), "HS_RecM24", 3, 03} , ; // 03 //"&2-Recepcionar"
                   {OemtoAnsi(STR0004), "HS_RecM24", 4, 04} , ; // 04 //"&3-Alterar"
                   {OemtoAnsi(STR0005), "HS_P36Can", 5, 02} , ; // 05 //"&4-Cancelar"
                   {OemtoAnsi(STR0006), "HS_P36Ret", 6, 04} , ; // 06 //"&5-Retornar"
                   {OemtoAnsi(STR0007), "HS_RecM24", 7, 04} , ; // 07 //"&6-Guias"
                   {OemtoAnsi(STR0018),   aRotAge  , 8, 03} , ; // 08 //"&7-Agenda Amb."
                   {OemtoAnsi(STR0009),   aRotRel  , 9, 02} , ; // 09 //"&8-Docs/Relat."
                   {OemtoAnsi(STR0019), "HS_RecM24", 10, 03}, ; // 10 //"&F-Transfere"
                   {OemtoAnsi(STR0107),     aRotSol, 11, 03}, ; // 11 //"&T-Solicitar"
                   {OemtoAnsi(STR0021), "HS_ExaM24", 12, 02}, ; // 12 //"&R-Res. Exames"
                   {OemtoAnsi(STR0011),     aRotAlt, 13, 04}, ; // 13 //"&A-Alta"
                   {OemtoAnsi(STR0014), "HS_ExtM24", 14, 02}, ; // 14 //"&E-Extrato"
                   {OemtoAnsi(STR0103), "HS_GarM24", 15, 02}, ; // 15 //"&G-Garantia"
                   {OemtoAnsi(STR0104), "HS_PacM24", 16, 04}, ; // 16 //"&C-Paciente"
                   {OemtoAnsi(STR0015), "HS_LegM24", 17, 02}, ; // 17 //"&L-Legenda"
                   {OemtoAnsi(STR0233), "HS_TriM24", 18, 04}, ; // 18 //"&V-EvoluÁ„o"
                   {OemtoAnsi(STR0242), "HS_TriM24", 19, 04}, ; // 19 //"Triagem"
				   {OemtoAnsi(STR0265),  aRotCaixa , 20, 04},;
				   {OemtoAnsi(STR0286),"HSPAHM10(GCY->GCY_REGATE, GCY->GCY_CODLOC,,GCY->GCY_NOME,GCY->GCY_QUAINT,GCY->GCY_LEIINT)", 0, 4}} //"Enfermagem"
 Private cM24Par01 := ""
 Private cM24Par02 := CToD(" ")
 Private cM24Par03 := CToD(" ")
 Private cAgdCodAge := ""

 Private cCadastro := STR0024 //"Pronto Atendimento"
 Private cPergM24  := "HSPMPA"

 HS_ATXBGCS()
 
 HSPAHM24("2", aRotM24, aExecM24)

Return(Nil)
//========================================================================================================================================================================================================================================================================================

Function HSPM24AD(aExecM24) // Doacao

 Local aCampos := {{"T", "GHL"}}

 Local aRotAge :=  {{OemtoAnsi(STR0018), "HS_AgeM24" , 0, 03}, ;    //&7-Agenda Amb."
                    {OemtoAnsi(STR0101), 'HS_ConsAge("A")', 0, 02}} //"Cons. Agenda"

 Local aRotAlt := {{OemtoAnsi(STR0005), "HS_CAlM24", 0, 01}, ; // 01 //"Cancelar"
                   {OemtoAnsi(STR0196), "HS_AltM24", 0, 04}}   // 14 //"&V-Evas„o"

 Local aRotRel := {{OemtoAnsi(STR0257), "HS_RelM24", 0, 02},; //"Docs/Relat"
                    {OemtoAnsi(STR0256), 'HS_MntTISS("M24",,, 1)', 0, 02}} //"Guias TISS"

 Local aRotM24 := {{OemtoAnsi(STR0001), "axPesqui" , 1, 01} , ; // 01 //"&0-Pesquisar"
                   {OemtoAnsi(STR0002), "HS_RecM24", 2, 02} , ; // 02 //"&1-Consultar"
                   {OemtoAnsi(STR0017), "HS_RecM24", 3, 03} , ; // 03 //"&2-Recepcionar"
	               {OemtoAnsi(STR0004), "HS_RecM24", 7, 04} , ; // 04 //"&3-Alterar"
                   {OemtoAnsi(STR0005), "HS_P36Can", 5, 02} , ; // 05 //"&4-Cancelar"
                   {OemtoAnsi(STR0006), "HS_P36Ret", 6, 04} , ; // 06 //"&5-Retornar"
                   {OemtoAnsi(STR0018),    aRotAge , 8, 03} , ; // 08 //&7-Agenda Amb."
                   {OemtoAnsi(STR0009), aRotRel    , 9, 02} , ; // 09 //"&9-Docs/Relat."
                   {OemtoAnsi(STR0022), "HS_RecM24", 13, 03}, ; // 13 //"&I-Encaixe"
                   {OemtoAnsi(STR0196), aRotAlt    , 14, 04}, ; // 14 //"&V-Evas„o"
                   {OemtoAnsi(STR0014), "HS_ExtM24", 15, 02}, ; // 15 //"&F-Extrato"
                   {OemtoAnsi(STR0195), "HS_PacM24", 17, 04}, ; // 17 //"&D-Doadores"
                   {OemtoAnsi(STR0194), "HS_LibCol", 18, 03}, ; // 18 //"&B-Lib. Coleta"
                   {OemtoAnsi(STR0193), "HS_TriM24", 19, 04}, ; // 19 //"&P-PrÈ-Triagem"
                   {OemtoAnsi(STR0015), "HS_LegM24", 20, 02}}   // 18 //"&L-Legenda"

 Private cM24Par01 := ""
 Private cM24Par02 := CToD(" ")
 Private cM24Par03 := CToD(" ")

 Private cCadastro  := STR0150 //"Atendimento DoaÁ„o"
 Private cPergM24   := "HSPMAD"
 Private cAgdFilAge := ""
 Private cAgdCodAge := ""

 If !HS_ExisDic(aCampos)
  Return(.F.)
 EndIf

 HSPAHM24("3", aRotM24, aExecM24)

Return(Nil)

//===============================================================================================================================================================================================
Function HSPAHM24(cTipAte, aRotM24, aExecM24) //Inicio INTERNACAO
	Local aCorM24 := {}/*, nLinha := 0*/
	Local bKeyF12 := SetKey(VK_F12, {|| FS_FilM24(cTipAte, .T.)})
	Local aVParam := {}
	Local aRotAdic := {}
	Local aAVldVig := HS_AVldVig("MM")[1]
	Local aCampos  := {{"C", "GA9_CDOPER"},;
    	                {"C", "GA9_CNPJOP"},;
        	            {"C", "GCZ_TDTISS"},;
            	        {"C", "GA9_ICIDCO"},;
                	    {"C", "GCY_OBIMUL"},;
                    	{"C", "GCZ_TEDVLR"},;
	                    {"C", "GD7_TECUTI"}}

 Private lOrigemExt := .F.

 Private cAliasMM := IIf(aExecM24 == Nil .Or. aExecM24[3] == "P", "GD5", "GE5")
 Private cPrefiMM := IIf(aExecM24 == Nil .Or. aExecM24[3] == "P", "GD5->GD5", "GE5->GE5")
 Private cAliasTD := IIf(aExecM24 == Nil .Or. aExecM24[3] == "P", "GD6", "GE6")
 Private cPrefiTD := IIf(aExecM24 == Nil .Or. aExecM24[3] == "P", "GD6->GD6", "GE6->GE6")
 Private cAliasPR := IIf(aExecM24 == Nil .Or. aExecM24[3] == "P", "GD7", "GE7")
 Private cPrefiPR := IIf(aExecM24 == Nil .Or. aExecM24[3] == "P", "GD7->GD7", "GE7->GE7")
 Private __cTabPrUt := "" // Variavel utilizada para calculo do valor do procecimento

 Private aVarDef := {{"cGcsCodLoc"   , "GCS->GCS_CODLOC"}, ;
                     {"cGcsCodCCu"   , "GCS->GCS_CODCCU"}, ;
                     {"cGcsArmSet"   , "GCS->GCS_ARMSET"}, ;
                     {"cGcsArmFar"   , "GCS->GCS_ARMFAR"}, ;
                     {"M->GCY_NOMLOC", "GCS->GCS_NOMLOC"}}

 Private cFilM24 := "", lFilGm1 := .F. // Sera utilizada no filtro da consulta padr„o GCS
 Private cGczNrSeqG := Space(Len(GCZ->GCZ_NRSEQG))
 Private cLctCodLoc := Space(Len(GCS->GCS_CODLOC))
 Private cLctNrSeqG := Space(Len(GCZ->GCZ_NRSEQG))
 Private cGcyRegGer := Space(Len(GCY->GCY_REGGER))
 Private cGbjCodEsp := Space(Len(GBJ->GBJ_ESPEC1))
 Private cGbjTipPro := Space(Len(GBJ->GBJ_TIPPRO))
 Private cGcuCodTpg := Space(Len(GCU->GCU_CODTPG))
 Private cGczCodPla := Space(Len(GCZ->GCZ_CODPLA))
 Private cGcsCodLoc := Space(Len(GCS->GCS_CODLOC))
 Private cGcsCodCCu := Space(Len(GCS->GCS_CODCCU))
 Private cGcsArmSet := Space(Len(SB2->B2_LOCAL)) // Sera utilizado dentro da funÁ„o de validaÁ„o do material e medicamento. HS_VMatMed()
 Private cGcsArmFar := Space(Len(SB2->B2_LOCAL)) // Verificar de onde irei pegar esse valor SB2->B2_LOCAL que identifica o armazem que
                                                 // sera movimentado o estoque.
 Private cGA7CodPro := Space(Len(GA7->GA7_CODPRO))
 Private cObsCodCrm := Space(Len(GBJ->GBJ_CRM))
 Private oObjFocus

 Private __cFCdBKit := "HS_M24Kit()"                 // Sera utilizado dentro da funÁ„o de validaÁ„o do cÛdigo de barras do
 Private __cFVPrPct := "HS_M24Pct()"
 Private __cFMntEqp := "HS_MntEqp(oGDPr, oGDTD)"

 Private __cRCodDes := "oGDMM:aCols[oGDMM:nAt, nMMCODDES]" // material e medicamento. HS_VCodBar()

 Private __cFAgdAmb := "HS_M24Agd()"

 Private __MMQtdDe := CriaVar(PrefixoCpo(cAliasMM) + "_QTDDES")

 Private __aRMatMed := {{"oGDMM:aCols[oGDMM:nAt, nMMDDESPE]", "06"}, ; // Sera utilizado dentro da funÁ„o de validaÁ„o
                        {"oGDMM:aCols[oGDMM:nAt, nMMCODPRO]", "09"}, ; // do material e medicamento. HS_VMatMed()
                        {"oGDMM:aCols[oGDMM:nAt, nMMDESPRO]", "10"},;
                        {"oGDMM:aCols[oGDMM:nAt, nMMTABELA]", "11"},;
                        {"oGDMM:aCols[oGDMM:nAt, nMMUNICON]", "12"}}


 Private __aRTaxDia := {{"oGDTD:aCols[oGDTD:nAt, nTDDDESPE]", "06"}, ; // Sera utilizado dentro da funÁ„o de validaÁ„o da
                        {"oGDTD:aCols[oGDTD:nAt, nTDCODTXC]", "07"}, ; // taxa e diaria. HS_VTaxDia()
                        {"oGDTD:aCols[oGDTD:nAt, nTDDESTXC]", "08"},;
                        {"oGDTD:aCols[oGDTD:nAt, nTDTABELA]", "09"}}

 Private __aRProced := {{"oGDPR:aCols[oGDPR:nAt, nPRDDESPE]",     "06"}, ; // Sera utilizado dentro da funÁ„o de validaÁ„o do
                        {"oGDPR:aCols[oGDPR:nAt, nPRCODESP]",     "07"}, ; // procedimento. HS_VProced()
                        {"oGDPR:aCols[oGDPR:nAt, nPRNOMESP]",     "08"}, ; //
                        {"oGDPR:aCols[oGDPR:nAt, nPRINCIDE]", "02, 16"}, ;
                        {"oGDPR:aCols[oGDPR:nAt, nPRCODPRT]", "02, 15"}, ;
                        {"oGDPR:aCols[oGDPR:nAt, nPRDESPRT]", "02, 18"},;
                        {"oGDPR:aCols[oGDPR:nAt, nPRTABELA]", "02, 20"}}

 Private __aRLote   := {{"oGDMM:aCols[oGDMM:nAt, nMMNumLot]", "SB8->B8_NUMLOTE"}, ;
                        {"oGDMM:aCols[oGDMM:nAt, nMMLoteFo]", "SB8->B8_LOTEFOR"}, ;
                        {"oGDMM:aCols[oGDMM:nAt, nMMLoteCt]", "SB8->B8_LOTECTL"}, ;
                        {"oGDMM:aCols[oGDMM:nAt, nMMDtVali]", "SB8->B8_DTVALID"}}

 Private __aRProSel := {{"oGDMM:aCols[oGDMM:nAt, nMMNumLot]", "Space(Len(SB8->B8_NUMLOTE))"}, ;
                        {"oGDMM:aCols[oGDMM:nAt, nMMLoteFo]", "Space(Len(SB8->B8_LOTEFOR))"}, ;
                        {"oGDMM:aCols[oGDMM:nAt, nMMLoteCt]", "Space(Len(SB8->B8_LOTECTL))"}, ;
                        {"oGDMM:aCols[oGDMM:nAt, nMMDtVali]", "CToD('')"                   }, ;
                        {"oGDMM:aCols[oGDMM:nAt, nMMProAlt]", "GBI->GBI_PRODUT"            }, ;
                        {"oGDMM:aCols[oGDMM:nAt, nMMDPrAlt]", "HS_IniPadr('SB1', 1, GBI->GBI_PRODUT, 'B1_DESC',,.F.)"}}

 Private cGcyAtendi := cTipAte //0-InternaÁ„o  1-Ambulatorial  2-Pronto Atendimento 3-Atendimento Doacao 4-Clinicas
 Private cGcsTipLoc := IIf(cTipAte $ "14","1J",IIf(cTipAte == "0", IIF(FunName() == "HSPAHP12" .And. HS_TemRN(GCY->GCY_REGATE), "348B", "34B"), IIF(cTipAte == "3", "C", cTipAte)))
 Private aRotina    := aClone(aRotM24)

 Private aRotHM24	:= aClone(aRotina)
 Private lGd7SLaudo := .F. // Usado na entrada do campo GD7_SLAUDO
 Private lAltIncide := .T. // Usado na entrada do campo GD7_INCIDE e GE7_INCIDE

 Private __dDataVig := dDataBase
 Private __cHoraAtu := Time()
 Private dDatMov    := ctod("  /  /  ")
 Private cHorMov    := ""
 Private nDiasRet   := 0
 Private __cCtrEst  := ""
 Private lAutoriz   := .F.  // variavel que armazena o resultado para validacao da autorizacao para doacao
 Private cGbhCodPac := ""
 Private cUsu       := Space(Len(GCY->GCY_CODUSU))
 Private lGFR       := HS_LocTab("GFR", .F.)
 Private lIncPro    := .T.
 Private lOrc       := .F.
 Private cGO0NumOrc := ""
 Private cGA1CodPct := ""

 Private cMV_AteSus
 Private nMv_VldGui := 0
 Private __cCodCon  := ""
 Private __cCodBPA  := ""
 Private __cCodPAC  := ""
 Private __cCodAIH  := ""
 Private __aGeISol := {} // itens a serem enviados para o controle de solicitacoes, sera utilizado na funcao de validacao do procedimento HS_VPROCED
 Private __aGeMSol := {} // itens a serem enviados para o controle de solicitacoes, sera utilizado na funcao de validacao do codigo de barras (MAT/MED) HS_VCODBAR

 Private cStatusGAV := "0" // Var usada na funcao de filtro
 Private lIsCaixa := IsCaixaLoja(xNumCaixa())

 Private cLocReab := GetMv("MV_LOCREAB",,"")
 Private lAmbReab := GetMv("MV_AMBREAB",,.F.)

 Private cRetSxb := ""
 Private cRetCrm := ""

 If !HS_ExisDic(aCampos)
  Return(Nil)
 EndIf

 //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 //≥ Ponto de entrada - Adiciona rotinas ao aRotina       ≥
 //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
 If ExistBlock("HSM24ROT")
 	aRotAdic := ExecBlock("HSM24ROT", .F., .F., {cTipAte})
	 If ValType(aRotAdic) == "A"
	 	AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	 EndIf
 EndIf

	// Verifica se o parametro MV_ATESUS esta setado para SIM, ou seja, o Hospital atende o Plano SUS
 cMV_AteSus  := GetMv("MV_ATESUS")
 If cMV_AteSus == "S"
  aVParam     := {{"MV_PCONSUS", ""},{"MV_PSUSBPA", ""},{"MV_PSUSPAC", ""},{"MV_PSUSAIH", ""}}
  If !HS_VMVSUS(@aVParam)
	  Return()
	 Else
	  __cCodCon  := aVparam[1][2]
   __cCodBPA  := aVparam[2][2]
   __cCodPAC  := aVparam[3][2]
   __cCodAIH  := aVparam[4][2]
   aVparam := Nil
  EndIf
  If (nMv_VldGui := GetMv("MV_VLDGUIA",,0))  == 0
   Hs_MsgInf(STR0247,STR0034,STR0248)//"Parametro MV_VLDGUIA preenchido com conteudo invalido"###"AtenÁ„o"##"ValidaÁ„o parametro MV_VLDGUIA"
   Return()
  EndIf
	EndIf

 If GetMV("MV_ATCRMD") == "S"
 	aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMCODCRM]", "#IIf(Empty(oGDMM:aCols[oGDMM:nAt, nMMCODCRM]), M->GCY_CODCRM, oGDMM:aCols[oGDMM:nAt, nMMCODCRM])"})
 	aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMNOMMED]", "#IIf(Empty(oGDMM:aCols[oGDMM:nAt, nMMNOMMED]), M->GCY_NOMMED, oGDMM:aCols[oGDMM:nAt, nMMNOMMED])"})
 	aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDCODCRM]", "#IIf(Empty(oGDTD:aCols[oGDTD:nAt, nTDCODCRM]), M->GCY_CODCRM, oGDTD:aCols[oGDTD:nAt, nTDCODCRM])"})
 	aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDNOMMED]", "#IIf(Empty(oGDTD:aCols[oGDTD:nAt, nTDNOMMED]), M->GCY_NOMMED, oGDTD:aCols[oGDTD:nAt, nTDNOMMED])"})
 EndIf

 If aExecM24 <> Nil .And. aExecM24[3] == "F"
  aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMVALDES]", "02"})
  aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMPCUDES]", "03"})
  aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMPGTMED]", "13, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_TIPREC" }))) })
  aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMREPAMB]", "13, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_REPAMB" }))) })
  aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMREPINT]", "13, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_REPINT" }))) })
  aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMVALREP]", "13, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_VALREP" }))) })
  aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMVALREB]", "13, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_VALREP" }))) })

  aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDVALDES]", "02"})
  aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDPCUDES]", "03"})
  aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDPGTMED]", "10, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_TIPREC" }))) })
  aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDREPAMB]", "10, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_REPAMB" }))) })
  aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDREPINT]", "10, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_REPINT" }))) })
  aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDVALREP]", "10, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_VALREP" }))) })
  aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDVALREB]", "10, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_VALREP" }))) })

  aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRCOEFAM]", "02, 01, 02"})
  aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVALDES]", "02, 01, 01"})
  aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVFILME]", "02, 03"})
  aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVCUSOP]", "02, 02"})
  aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRPCUDES]", "03"})
  aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRURGDES]", "02, 14"})
  aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRCOECHP]", "02, 10"})
  aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRQTDCHP]", "02, 11"})
  aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRPGTMED]", "09, 01"})
  aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRCOECHM]", "02, 13"})
  aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRREPAMB]", "02, 12"})
  Iif( cAliasPR <> "GD7", aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRCOEDES]", "16, 02"}), Nil)
  aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVLRCOS]", "02, 24"})
  aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVALREP]", "09, 14"})

  If HS_ExisDic({{"C", cAliasPR+"_VALREB"}},.F.)
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVALREB]", "09, 14"})
  EndIf

 ElseIf  FunName() == "HSPAHP12"
  aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMVALDES]", "02"})
  aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMPGTMED]", "13, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_TIPREC" }))) })
  aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMREPAMB]", "13, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_REPAMB" }))) })
  aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMREPINT]", "13, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_REPINT" }))) })
  aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMVALREP]", "13, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_VALREP" }))) })
  aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMVALREB]", "13, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_VALREP" }))) })

  aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDVALDES]", "02"})
  aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDPGTMED]", "10, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_TIPREC" }))) })
  aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDREPAMB]", "10, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_REPAMB" }))) })
  aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDREPINT]", "10, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_REPINT" }))) })
  aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDVALREP]", "10, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_VALREP" }))) })
  aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDVALREB]", "10, " + AllTrim(Str(aScan(aAVldVIg, {| aVet | SubStr(aVet[2], At("_", aVet[2])) ==    "_VALREP" }))) })

  aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVALDES]", "02, 01, 01"})
  aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVFILME]", "02, 03"})
  aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRPGTMED]", "09, 01"})
  aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVALREP]", "09, 14"})

  If HS_ExisDic({{"C", cAliasPR+"_VALREB"}},.F.)
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVALREB]", "09, 14"})
  EndIf

   Iif( cAliasPR <> "GD7", aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRCOEDES]", "16, 02"}), Nil)

 EndIf

 // Serve para montar submenu no mbrowse
 //MBrMenu(<numero da linha do arotina>,<vetor com titulos>,<vetor com Action>)

 If cTipAte == "0"
  aCorM24 := {{"GCY->GCY_TPALTA  # '99'  .AND.  EMPTY(GCY->GCY_TPALTA) .AND.   HS_M24CCEs(GCY->GCY_CODLOC) == '4'" , "BR_VERMELHO"},; //Admitido no C.C./C.O.
              {"GCY->GCY_TPALTA  # '99'  .AND.  !EMPTY(GCY->GCY_TPALTA)"                                           ,  "BR_AMARELO"},; //Alta Medica
              {"GCY->GCY_TPALTA  # '99'  .AND.  EMPTY(GCY->GCY_TPALTA) .AND. !(HS_M24CCEs(GCY->GCY_CODLOC) $ '4B')", "BR_VERDE"   },; //Recepcao
              {"GCY->GCY_TPALTA  # '99'  .AND.  EMPTY(GCY->GCY_TPALTA) .AND.   HS_M24CCEs(GCY->GCY_CODLOC) == 'B'" , "BR_AZUL"    },; //Espera
              {"GCY->GCY_TPALTA == '99'"                                                                           , "BR_CINZA"   }}  //Cancelado
 ElseIf cTipAte $ "14"
  aCorM24 := {{"GCY->GCY_TPALTA  # '99'  .AND. !EMPTY(GCY->GCY_TPALTA)"                                            , "BR_AMARELO" },; //Alta Medica
              {"GCY->GCY_TPALTA  # '99'  .AND.  EMPTY(GCY->GCY_TPALTA)"                                            , "BR_VERDE"   },; //Recepcao
              {"GCY->GCY_TPALTA == '99'"                                                                           , "BR_CINZA"   }}  //Cancelado
 Else
  aCorM24 := {{"GCY->GCY_TPALTA  # '99'  .AND. !EMPTY(GCY->GCY_TPALTA)"                                            , "BR_AMARELO" },; //Alta Medica
              {"GCY->GCY_TPALTA  # '99'  .AND.  EMPTY(GCY->GCY_TPALTA)   .AND.  EMPTY(GCY->GCY_LEIINT)"            , "BR_VERDE"   },; //Recepcao
              {"GCY->GCY_TPALTA  # '99'  .AND.  EMPTY(GCY->GCY_TPALTA)   .AND. !EMPTY(GCY->GCY_LEIINT)"            , "BR_LARANJA" },; //Repouso
              {"GCY->GCY_TPALTA == '99'"                                                                           , "BR_CINZA"   }} //Cancelado
 Endif
 DbSelectArea("GCY")
 DbSetOrder(13) // GCY_FILIAL + GCY_LOCATE + GCY_DATSAI + GCY_DATATE

 If aExecM24 == Nil
  If FS_FilM24(cTipAte, .F.)
   mBrowse(06, 01, 22, 75, "GCY",,,,,, aCorM24,,,,,,,, cFilM24)
  EndIf
 Else
  cLctCodLoc := aExecM24[5] // Codigo do Setor
  cLctNrSeqG := aExecM24[6] // Numero da guia
  lOrigemExt := .T.
   nLinha := aScan(aRotina, {|aVet| aVet[3] == aExecM24[4]})
   &(aRotina[nLinha, 2] + "('GCY', " + AllTrim(Str(GCY->(RecNo()))) + ", " + AllTrim(Str(nLinha)) + ")")
 EndIf

 SetKey(VK_F12, bKeyF12)
Return(Nil)

//===========================================================================================================================================================================================================================================================================================
Function HS_RecM24(cAliasM24, nRegM24, nOpcM24)
 Local aCorLeito := {{"GAV->GAV_STATUS == '0' .Or. GAV->GAV_STATUS == ' '", "BR_VERDE"   , HS_RDescrB("GAV_STATUS", "0")},;
             								{"GAV->GAV_STATUS == '2'"                            , "BR_VERMELHO", HS_RDescrB("GAV_STATUS", "1")},;
             								{"GAV->GAV_STATUS == '1'"                            , "BR_MARROM"  , HS_RDescrB("GAV_STATUS", "2")},;
													       	{"GAV->GAV_STATUS == '3'"                            , "BR_BRANCO"  , HS_RDescrB("GAV_STATUS", "3")},;
             								{"GAV->GAV_STATUS == '4'"                            , "BR_PRETO"   , HS_RDescrB("GAV_STATUS", "4")},;
													       	{"GAV->GAV_STATUS == '5'"                            , "BR_CINZA"   , HS_RDescrB("GAV_STATUS", "5")}}
 Local aAlterOld := {"GD5_QDEVOL", "GD5_VALDES", "GD5_DESPER", "GD5_DESVAL", "GD5_DESOBS"}, aAlterNew := {}, nFCpoAlt := 0
 Local aCBrwPac  := {"GAV_REGATE", "GAV_REGGER", "GAV_NOME  ", "GAV_DATATE", "GAV_HORATE", "GAV_CODCRM", ;
                     "GAV_MEDICO", "GAV_CODLOC", "GAV_NOMLOC", "GAV_QUARTO", "GAV_LEITO ", "GAV_SEXO  ", ;
                     "GAV_MOTINT", "GAV_DMTINT" }
 Local aLegGe2 := 	{{"GE2_STATUS == '0'", "BR_VERDE"},{"GE2_STATUS == '1'", "BR_AMARELO"},;
                  	{"GE2_STATUS == '2'", "BR_AZUL"},{"GE2_STATUS == '3'", "BR_VERMELHO"},{"GE2_STATUS == '4'", "BR_PRETO"},{"GE2_STATUS == '5'", "BR_LARANJA"}}
 Local aLegGe3 := 	{{"GE3_STATUS == '0'", "BR_VERDE"},{"GE3_STATUS == '1'", "BR_AMARELO"},;
                  	{"GE3_STATUS == '2'", "BR_AZUL"},{"GE3_STATUS == '3'", "BR_VERMELHO"},{"GE3_STATUS == '4'", "BR_PRETO"},{"GE3_STATUS == '5'", "BR_LARANJA"}}

 Local aCposAlt  := {}, aCposObr 	:= {}, aCposGcy	 	:= {}, aHTD  		:= {}, aCTD  		:= {}, aOPesq := {}
 Local aSize 	 := {}, aObjects 	:= {}, aInfo 		:= {}, aPFolder 	:= {}, aPObjs 		:= {}, aPMBrow := {}
 Local aBtnBar   := {}, aCpoAltMM 	:= {}, aCpoAltPR 	:= {}, aCpoAltPG 	:= {}, aCpoVisMM 	:= {}, aCpoVisTD := {}
 Local aCpoVisPR := {}, aConEst   	:= {}, aHGCZ 		:= {}, aCGCZ 		:= {}, aHMM  	:= {}, aCMM  := {}, aMLocksSb2 := {}, aMLocksSb3 := {}
 Local aHPR  	 := {}, aCPR  		:= {}, aHGE2 		:= {}, aCGE2 		:= {}, aHGE3 	:= {}, aCGE3 := {}, aHGE8 := {},aCDesp := {}
 Local aHGDD 	 := {}, aCGDD 		:= {}, aPDesp:= {},aHGb1 := {}, aCGb1 := {}
 Local oDlgAten, oGDGb1, oPPesq    , dDatAte   := CTOD(""), oBrwLei
 Local bKeyF4, bKeyF5, bKeyF7, bKeyF8, bKeyF12 := SetKey(VK_F12)
 Local bKeyF6 		:= SetKey(VK_F6, {|| FS_MostObs(cGczCodPla, "GA9", " plano ", nOpcM24, .T.)})
 Local bKeyF9 		:= SetKey(VK_F9, {|| FS_MostObs(cGa7CodPro, "GA7", " procedimento ", nOpcM24)})
 Local bKeyF10 		:= SetKey(VK_F10, {|| FS_MostObs(cObsCodCrm, "GBJ", " mÈdico ", nOpcM24)})
 Local nGuias 		:= 0, nOpcAten := 0
 Local cGcyAtOrig 	:= cGcyAtendi, cGcsTLOld := cGcsTipLoc
 Local cRegAteOri 	:= GCY->GCY_REGATE

 Local cMovest 		:= UPPER(GetMv("MV_AUDMEST"))
 Local lNewDayAte 	:= IIF(HS_VldSx6({{"MV_NEWDATE",{"L","T/F","$"}}},.F.), GetMv("MV_NEWDATE"),.T.)
 Local nGDOpc    	:= IIf(Inclui .Or. aRotina[nOpcM24, 3] == 7, GD_INSERT + GD_UPDATE + GD_DELETE, 0) // 7-Guias
 Local lAteSUS 		:= (GetMV("MV_ATESUS", , "N") == "S")
 Local i := 0,j := 0, nAtAnt := 1 ,lIncOld := Inclui

 Local cOldRegAte 	:= "", cCpoNaoMM  := "", cCpoNaoTD := "", cCpoNaoPR 	:= "" , cRGAu      := ""
 Local cSolGnx 		:= "", cCondGE2   := "", cCondGE3  := "", cCondAtrib	:= "" , cCamposNao := ""
 Local cOldCodLoc 	:= "", cOldQuaInt := "", cOldLeiInt:= "", cGavModelo	:= "" , cSexoAu    := "", cDtNascAu := ""
 Local cGuiaBpa  	:= "", cGbiMovEst := "", cCondGcz  := ""
 Local cGbhRg 	    := "", cGbhRgOrg := "", cGbhUFEmis  := "",  cOrgEmiAu  := "", cUFEmisAu := ""

 Local lOkM24 		:= .T. , lFichas   := .F.,  lAchou:= .T. , lRecepAgd := .F.

Local nItens 	 := 0, nForGuia  := 0, nForMM    := 0, nPosGD    := 0, nGe3CodDes:= 0, nGddCodTxd:= 0, nGddPerg  := 0, nGddQtde  := 0
Local nPRDsGAte  := 0, nPRCdTAte := 0, nPRDsTAte := 0, nPRCodCid := 0, nPrVguiaI := 0, nGddDesc  := 0
Local nPrVguiaF := 0, nPRCodVia := 0, nPRCdGAte := 0, nPRCodKit := 0, nPRDesKit := 0
Local GCZCPFGES := 0, nnGCZTedVlr:= 0,nGCZTedUnd := 0
Local nGczStatus := 0, nGczINDCLI:= 0 ,nGczNumOrc:= 0, nGCZDtGuia:= 0, nGCZValSen:= 0
Local bAction01 	:= {||}
Local bAction02 	:= {||}
Local bOK			:= {||}
Local bCancel		:= {||}
Local lLMMALTA	:= iif(getnewpar("MV_LMMALTA","N") == "S",.T.,.F.)

Private lAltCodLoc := IIf(cGcyAtendi == "0" .And. aRotina[nOpcM24, 4] == 3, .T., .F.)
Private oGDMM , oGDTD, oGDPR, oGDGE2, oGDGE3, oGDGE8,oGDGcz // nao e possivel pq nao tem como passar o objeto oGDGcz para a funcao __cFAgdAmb := "HS_M24Agd()"
Private oFolAten, oFolDesp, oEncGcy, aGets := {}, aTela := {},aGuiaTISS 	:= {}
Private aGetsGcy := {}, aTelaGcy := {}, lOpcOk    := .F.
Private nGCZDsGuia:= 0
Private nGe8CodCrm := 0, nGe8NomMed:= 0, nGe8SeqDes:= 0, nGe8DatSol:= 0, nGe8QtDias:= 0, nGe8DatLib:= 0, nGe8QtdLib:= 0, nGe8DatVen:= 0, nGCZNRSEQG:= 0
Private nGCZCODTPG:= 0, nGCZDESTPG := 0, nGCZCODPLA := 0, nGCZDESPLA := 0, nGczCodCrm := 0,nGczNomMed := 0 // sao usadas no private
Private nGczSqCatP:= 0, nGczDsCatP := 0, nGczCodDes := 0, nGczCodPrt := 0, nGCZNrGuia := 0, nGCZNrSen1 := 0// sao usadas no private
Private nGCZNrSen2:= 0, nGCZNrSen3 := 0, nGCZQtDias := 0, nGczDdespe := 0// sao usadas no private
Private nMMQtdDes := 0, nMMCODDES  := 0, nMMDDESPE  := 0, nMMCodPct  := 0, nMMDesPct := 0,nMMCodKit := 0 //usado em __ Private
Private nMMDesKit := 0, nMMDatDes  := 0, nMMHorDes  := 0, nMMCodLoc  := 0, nMMNomLoc := 0,nMMCodBar := 0 //usado em __ Private
Private nMMStaReg := 0, nMMCODCRM  := 0, nMMNumOrc  := 0, nMMIteOrc  := 0
Private nTDQtdDes := 0, nTDCODDES  := 0, nTDCodKit  := 0, nTDDesKit  := 0,nTDCodLoc := 0, nTDNomLoc := 0,nTDHorDes := 0, nTDCODCRM := 0// usado em __cFCdBKit
Private nTDCodPct := 0, nTDDesPct  := 0, nTDDatDes  := 0, nTDStaReg  := 0
Private nPRStaReg := 0
Private nPRNOMESP := 0
Private nPRCODATO := 0
Private nPRDesAto := 0, nPRCodPct := 0, nPRDesPct := 0,nPRDatDes := 0, nPRHorDes := 0, nPRCodLoc := 0, nPRNomLoc := 0, nPRSPrinc := 0, nPRURGDES := 0//usadas em __cFMntEqp := "HS_MntEqp(oGDPr, oGDTD)"
Private nPROriDes := 0, nPRCodPrt := 0,nPRDesPrt := 0,nPRTABELA := 0
Private nPRDDESPE := 0,nPRCODCRM := 0,nPRNumOrc := 0, nPRCODDES := 0, nPRIteOrc := 0, nPRCODESP := 0,nPRSLaudo := 0,nPRCrmLau := 0,nPRNMeLau := 0 //nao pode pq e usada na funcao HS_M24Agd que nao tem como passar parametro
Private nGe3DDespe := 0,nGe2CodDes := 0, nGe2DDespe := 0, nGe2QtdSol := 0, nGe2QtdAut := 0, nGe2StaReg := 0  //nao pode pq e usada na funcao HS_M24Agd que nao tem como passar parametro
Private nGe3StaReg := 0,nGe3DatSol:= 0, nGe3HorSol := 0, nGe3QtdSol := 0, nGe3QtdAut := 0, nGe3SenAut := 0, nGe3DatAut := 0, nGe3HorAut := 0, nGe3ValAut := 0, nGe3NroAut := 0,nGe3ResAut := 0,  nGe3MnAuto := 0 //nao pode pq e usada na funcao HS_M24Agd que nao tem como passar parametro
Private nGe8StaReg := 0,nPRINCIDE := 0
Private cGO0Status := ""
Private cGO0Atendi := ""
Private oGDGdd ,aGczGd 	:= {}
Private nGczTATISS:= 0, nGczTIPCON:= 0
Private lNrGTissAt := .F.
Private nPRQTDDES := 0,nPRSeqDes := 0
Private nPRVALDES := 0, nPRPGTMED := 0, nMMVALREP := 0 , nGCZCPFGES := 0

//Retornaram para private
Private nPRVALREP := 0, nMMDesPer := 0,nTDDDESPE := 0,nPRDesPer  := 0, nPRDesVal := 0, nMMSeqDes  := 0, nMMDesVal := 0, nTDDesPer := 0, nTDDesVal := 0
Private nTDPGTMED  := 0, nPRVALREB  := 0,nMMCodPro := 0, nMMDesPro  := 0, nMMTABELA := 0, nMMUNICON := 0, nTDCodTxc := 0, nTDDesTxc := 0, nTDTABELA := 0
Private nMMNumLot := 0 , nMMLoteFo := 0, nMMLoteCt := 0, nMMDtVali := 0, nMMProAlt := 0, nMMDPrAlt  := 0, nMMNOMMED  := 0, nTDNOMMED := 0, nTDValDes := 0
Private nMMValDes := 0, nMMPCuDes := 0, nMMPGTMED := 0, nMMREPAMB := 0, nMMREPINT := 0, nMMVALREB := 0, nTDPCuDes := 0, nTDREPAMB := 0, nTDREPINT := 0
Private nTDVALREP := 0, nTDVALREB := 0, nPRCOEFAM := 0, nPRVFILME := 0, nPRVCUSOP := 0, nPRPCUDES := 0, nPRCOECHP := 0, nPRQTDCHP := 0, nPRCOECHM  := 0
Private nPRREPAMB := 0, nPRCoeDes := 0 , nPrVlrCos := 0, nMMTotDsc := 0, nMMQDevol := 0, nMMValTot := 0, nTDValTot := 0, nPRValTot := 0, nMMDesObs := 0, nTDSeqDes := 0
Private nTDTotDsc := 0, nTDDesObs := 0 ,nPrDesObs := 0, nPrTotDsc  := 0, aCGE8 	 := {}




 If Type("__aGeISol") # "U"
	__aGeISol := {}
	__aGeMSol := {}
 EndIf

 If nOpcM24 == 7 .AND. ("HSPM24" $ FUNNAME() .OR. "HSPAHM30" $ FUNNAME() .OR. "HSPAHM35" $ FUNNAME())//<> "HSPAHP12"
	If "HSPAHM30" $ FUNNAME() .AND. Type("MV_PAR01") # "U"
 		If cSetPerg $ GetMv("MV_NMVESTA",,".")
 	 		cGbiMovEst := "0"
 		Else
 	 		cGbiMovEst := ""
 	 	EndIf
 	 ElseIf "HSPAHM35" $ FUNNAME() .AND. Type("MV_PAR01") # "U"
 		If cSetPerg $ GetMv("MV_NMVESTA",,".")
 	 		cGbiMovEst := "0"
 		Else
 	 		cGbiMovEst := ""
 	 	EndIf
 	 Else
 	  	If cM24Par01 $ GetMv("MV_NMVESTA",,".")
 	 		cGbiMovEst := "0"
 		Else
 	 		cGbiMovEst := ""
 	 	EndIf
 	 EndIf
 EndIf

 If aRotina[nOpcM24, 3] == 10
  If GCY->(Eof())
   Help("", 1, "ARQVAZIO")
   lOkM24 := .F.

  ElseIf !Empty(GCY->GCY_TPALTA) .And. GCY->GCY_TPALTA <> "99"
   HS_MsgInf(STR0231, STR0034, STR0232) //"ImpossÌvel realizar a transferÍncia pois	paciente j· est· com alta."###"AtenÁ„o"###"TransferÍncia"
   lOkM24 := .F.

  ElseIf HS_CountTB("GAI", "GAI_REGATE = '" + GCY->GCY_REGATE + "' AND GAI_FLGATE IN ('0', '1')") > 0
   HS_MsgInf(STR0284, STR0034, STR0232) //"ImpossÌvel realizar a transferÍncia pois	paciente possui solicitaÁıes de materiais e medicamentos em aberto."###"AtenÁ„o"###"TransferÍncia"
   lOkM24 := .F.
  EndIf

 ElseIf (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3", aRotina[nOpcM24, 3] <> 7, aRotina[nOpcM24, 3] <> 4))
  If aRotina[nOpcM24, 3] # 10 .And. !HS_VldPar(StrTran(aRotina[nOpcM24, 1], "&", ""))
   lOkM24 := .F.

  EndIf

 ElseIf StrZero(nOpcM24, 2) $ IIf(cGcyAtendi == "0",  "04/07", "04/07/10") .And. GCY->GCY_TPALTA == "99"
  HS_MsgInf(STR0098, STR0034, aRotina[nOpcM24, 1]) //"Atendimento cancelado n„o pode ser alterado!"
  lOkM24 := .F.

 Endif

 If !lOkM24
  SetKey(VK_F4 , bKeyF4 )
  SetKey(VK_F5 , bKeyF5 )
  SetKey(VK_F6 , bKeyF6 )
  SetKey(VK_F7 , bKeyF7 )
  SetKey(VK_F8 , bKeyF8 )
  SetKey(VK_F9 , bKeyF9 )
  SetKey(VK_F10, bKeyF10)
  SetKey(VK_F12, bKeyF12)
  Return(Nil)
 EndIf

 bKeyF7 := SetKey(VK_F8, {|| FS_MLegMB(aCorLeito)})

 If cGcyAtendi $ "0/1/2/4" .And. StrZero(nOpcM24, 2) $ "03/07/"+IIF(cGcyAtendi # "2","13","")

  If FunName() # "HSPAHP12"
   if StrZero(nOpcM24, 2) # "07"
    Aadd(aBtnBar, {"SIMULACA",{|| FS_CopyOrc() },OemToAnsi(STR0187), OemToAnsi(STR0188)}) //"Gerar atendimento de um OrÁamento[F7]"###"OrÁamento"
    bKeyF7 := SetKey( VK_F7, { || FS_CopyOrc()} )
   EndIf

   If (lIsCaixa .And.  cGcyAtendi # "0")
    Aadd(aBtnBar, {"SIMULACA",{|| HS_FaciDsc(nGCZStatus) },OemToAnsi(STR0266), OemToAnsi(STR0267)}) //"Descontos por Grupo de Despesas"###"Descontos"
   EndIf

   If cGcyAtendi $ "12"
    Aadd(aBtnBar, {"ADICIONAR_001",{|| FS_IncMedS() },OemToAnsi("Incluir mÈdico solicitante"), OemToAnsi("Inc. MÈd.")})
   EndIf
  Else
   Aadd(aBtnBar, {"SIMULACA",{|| HS_FaciDsc(nGCZStatus) },OemToAnsi(STR0266), OemToAnsi(STR0267)}) //"Descontos por Grupo de Despesas"###"Descontos"
  EndIf

 ElseIf (cGcyAtendi == "3" .And. StrZero(aRotina[nOpcM24, 3],2) $ "13/02/07")
  Aadd(aBtnBar, {"NOTE_OCEAN", {|| FS_DadComp(nOpcM24) }, STR0213, STR0214}) //"DoaÁ„o"###"Dados"
 EndIf

 If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt)
  bKeyF4 := SetKey(VK_F4 , {|| HS_SelLote(IIf(!Empty(oGDMM:aCols[oGDMM:nAt, nMMProAlt]), oGDMM:aCols[oGDMM:nAt, nMMProAlt], oGDMM:aCols[oGDMM:nAt, nMMCodDes]), cGcsArmSet, oGDMM:aCols[oGDMM:nAt, nMMQtdDes],,HS_RetSet(cAliasMM, nMMSeqDes, nMMCodLoc, cLctCodLoc, oGDMM:oBrowse:nAt, oGDMM:aCols))})
  bKeyF5 := SetKey(VK_F5 , {|| HS_SelPAlt(oGDMM:aCols[oGDMM:nAt, nMMCodDes])})
 EndIf

 If FunName() == "HSPAHM30" // se a rotina for chamada do posto de enfermagem seleciona campos para alterar
  aCpoAltMM := {"GE2_DATSOL","GE2_HORSOL","GE2_QTDSOL","GE2_CODDES","GE2_DDESPE"}
  aCpoAltPR := {"GE3_DATSOL","GE3_HORSOL","GE3_QTDSOL","GE3_CODDES","GE3_DDESPE"}
  aCpoAltPG := {"GE8_CODCRM","GE8_NOMMED","GE8_DATSOL","GE8_HORSOL","GE8_QTDIAS"}
 Else
  aCpoAltMM := Nil
  aCpoAltPR := Nil
  aCpoAltPG := Nil
 EndIf

 If FunName() <> "HSPAHP12" // Se nao for chamado da rotina de faturamento bloqueia alteracao dos campos
  aCpoVisMM := {cAliasMM + "_CODLOC",  Nil,  Nil, cAliasMM + "_VALDES"}
  aCpoVisTD := {cAliasTD + "_CODLOC",  Nil,  Nil, cAliasTD + "_VALDES"}
  aCpoVisPR := {cAliasPR + "_CODLOC", Nil,  Nil, cAliasPR + "_VALDES", ;
                cAliasPR + "_VFILME"}

  cCpoNaoMM := cAliasMM + "_CODLOC/" + cAliasMM + "_NOMLOC"

  //Se usuario nao for caixa nao mostra
  If !lIsCaixa
   cCpoNaoMM += cAliasMM + "_DESPER/" + cAliasMM + "_DESVAL/" + cAliasMM + "_VALDES/" + cAliasMM + "_DESOBS/"
   cCpoNaoMM += cAliasMM + "_VALTOT/" + cAliasMM + "_TOTDSC/" + cAliasMM + "_PGTMED/" + cAliasMM + "_REPAMB/"
   cCpoNaoMM += cAliasMM + "_REPINT/" + cAliasMM + "_CODPRE/" + cAliasMM + "_VALREP/" + cAliasMM + "_NREXTM/"
   cCpoNaoMM += cAliasMM + "_VLRGLO/" + cAliasMM + "_VLRREC/" + cAliasMM + "_STATUS/" + cAliasMM + "_DATSTA/"
   cCpoNaoMM += cAliasMM + "_HORSTA/" + cAliasMM + "_VALREB/"
  Else
   aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMVALDES]", "02"})
  EndIf

  cCpoNaoTD := cAliasTD + "_CODLOC/" + cAliasTD + "_NOMLOC"

  //Se usuario nao for caixa nao mostra
  If !lIsCaixa
   cCpoNaoTD += cAliasTD + "_DESPER/" + cAliasTD + "_DESVAL/" + cAliasTD + "_VALDES/" + cAliasTD + "_DESOBS/"
   cCpoNaoTD += cAliasTD + "_VALTOT/" + cAliasTD + "_TOTDSC/" + cAliasTD + "_PGTMED/" + cAliasTD + "_REPAMB/"
   cCpoNaoTD += cAliasTD + "_REPINT/" + cAliasTD + "_CODPRE/" + cAliasTD + "_VALREP/" + cAliasTD + "_NREXTM/"
   cCpoNaoTD += cAliasTD + "_VLRGLO/" + cAliasTD + "_VLRREC/" + cAliasTD + "_STATUS/" + cAliasTD + "_DATSTA/"
   cCpoNaoTD += cAliasTD + "_HORSTA/" + cAliasTD + "_VALREB/"
  Else
   aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDVALDES]", "02"})
  EndIf

  cCpoNaoPR := cAliasPR + "_CODLOC/" + cAliasPR + "_NOMLOC/"
  cCpoNaoPR += cAliasPR + "_CGCFOR/" + cAliasPR + "_NNFFOR/"
  cCpoNaoPR += cAliasPR + "_CDGATE/" + cAliasPR + "_DSGATE/" + cAliasPR + "_CDTATE/" + cAliasPR + "_DSTATE/"
  cCpoNaoPR += cAliasPR + "_CODCID/" + cAliasPR + "_CIDSEC/" + cAliasPR + "_TDEAIH/" + cAliasPR + "_DDEAIH/"

  //Se usuario nao for caixa nao mostra
  If !lIsCaixa
   cCpoNaoPR += cAliasPR + "_DESPER/" + cAliasPR + "_DESVAL/" + cAliasPR + "_VALDES/" + cAliasPR + "_DESOBS/"
   cCpoNaoPR += cAliasPR + "_VALTOT/" + cAliasPR + "_TOTDSC/" + cAliasPR + "_COEDES/" + cAliasPR + "_COEFAM/"
   cCpoNaoPR += cAliasPR + "_VCUSOP/" + cAliasPR + "_VFILME/" + cAliasPR + "_PGTMED/"
   cCpoNaoPR += cAliasPR + "_VALREP/" + cAliasPR + "_VALREB/"
  Else
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVALDES]", "02, 01, 01"})
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRPGTMED]", "09, 01"})
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVALREP]", "09, 14"})
   If HS_ExisDic({{"C", cAliasPR+"_VALREB"}},.F.)
    aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVALREB]", "09, 14"})
   EndIf

  EndIf

 Else // Se for HSPAHP12
  If cGcyAtendi == "2"
   aCpoVisMM := { IIF(GCZ->GCZ_STATUS < "2", cAliasMM + "_VALDES", Nil)}
   aCpoVisTD := { IIF(GCZ->GCZ_STATUS < "2", cAliasTD + "_VALDES", Nil)}
   aCpoVisPR := { IIF(GCZ->GCZ_STATUS < "2", cAliasPR + "_VALDES", Nil)}
  Endif
  If cMV_AteSus == "S" // Atende SUS
   If GCZ->GCZ_CODPLA == __cCodBPA // BPA
    cCpoNaoPR := cAliasPR + "_CGCFOR/" + cAliasPR + "_NNFFOR/"
    cCpoNaoPr += cAliasPR + "_CODCID/" + cAliasPR + "_CIDSEC/" + cAliasPR + "_TDEAIH/" + cAliasPR + "_DDEAIH/"

   ElseIf GCZ->GCZ_CODPLA $ __cCodPAC // APAC
    cCpoNaoPR := cAliasPR + "_CDGATE/" + cAliasPR + "_DSGATE/" + cAliasPR + "_CDTATE/" + cAliasPR + "_DSTATE/" + cAliasPR + "_TDEAIH/" + cAliasPR + "_DDEAIH/"
   Else// atende SUS mas nao eh APAC nem BPA
    cCpoNaoPR := cAliasPR + "_CGCFOR/" + cAliasPR + "_NNFFOR/"
    cCpoNaoPR += cAliasPR + "_CDGATE/" + cAliasPR + "_DSGATE/" + cAliasPR + "_CDTATE/" + cAliasPR + "_DSTATE/"
    cCpoNaoPR += cAliasPR + "_CODCID/" + cAliasPR + "_CIDSEC/" + cAliasPR + "_TDEAIH/" + cAliasPR + "_DDEAIH/"
   EndIf
  Else // Nao atende SUS
   cCpoNaoPR := cAliasPR + "_CGCFOR/" + cAliasPR + "_NNFFOR/"
   cCpoNaoPR += cAliasPR + "_CDGATE/" + cAliasPR + "_DSGATE/" + cAliasPR + "_CDTATE/" + cAliasPR + "_DSTATE/"
   cCpoNaoPR += cAliasPR + "_CODCID/" + cAliasPR + "_CIDSEC/" + cAliasPR + "_TDEAIH/" + cAliasPR + "_DDEAIH/"
  EndIf
 EndIf

 If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3",  aRotina[nOpcM24, 3] <> 7, aRotina[nOpcM24, 3] <> 4))
  aSize := MsAdvSize(.T.)
  aObjects := {}
  AAdd( aObjects, { 100, 100, .T., .T., .T. } )

  aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
  aPFolder := MsObjSize( aInfo, aObjects )

  aObjects := {}
  AAdd( aObjects, { 100, 035, .T., .T. } )
  AAdd( aObjects, { 100, 025, .T., .T. } )
  AAdd( aObjects, { 100, 035, .T., .T., .T. } )
  AAdd( aObjects, { 100, 005, .T., .T., .T. } )

  aInfo  := { aPFolder[1, 1], aPFolder[1, 2], aPFolder[1, 3], aPFolder[1, 4], 0, 0 }
  aPObjs := MsObjSize( aInfo, aObjects, .T. )

  aObjects := {}
  AAdd( aObjects, { 100, 100, .T., .T. } )

  aInfo  := { 2, 2, aPObjs[3, 3], aPObjs[3, 4]-25, 0, 0 }
  aPDesp := MsObjSize( aInfo, aObjects )

  aObjects := {}
  AAdd( aObjects, { 100, 100, .T., .T. } )

  aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ]-25, 0, 0 }
  aPMBrow := MsObjSize( aInfo, aObjects )
 Else
  aSize := MsAdvSize(.T.)
  aObjects := {}
  AAdd( aObjects, { 100, 100, .T., .T., .T. } )

  aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
  aPFolder := MsObjSize( aInfo, aObjects )

  aObjects := {}
  AAdd( aObjects, { 100, 100, .T., .T.})

  aInfo  := { aPFolder[1, 1], aPFolder[1, 2], aPFolder[1, 3], aPFolder[1, 4], 0, 0 }
  aPObjs := MsObjSize( aInfo, aObjects, .T. )

  aObjects := {}
  AAdd( aObjects, { 100, 100, .T., .T. } )

  aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ]-25, 0, 0 }
  aPMBrow := MsObjSize( aInfo, aObjects )

 EndIf

 If aRotina[nOpcM24, 3] == 10 // 10-Transferencia do setor ambulatorial para o setor de internaÁ„o
  cGcsTipLoc := "34" // 3-Posto de enfermagem e 4-Centro Cirurgico
  cGcyAtOrig := cGcyAtendi
  cGcyAtendi := "0"
  Inclui     := .F.
  nGDOpc     := GD_UPDATE
 EndIf

 RegToMemory("GCY", .F.)
 HS_CposGcy(nOpcM24, @aCposObr, @aCposGcy, @aCposAlt, (FunName() == "HSPAHP12" .And. M->GCY_TPALTA <> '99' .And. (!Empty(M->GCY_DATALT) .AND. !lLMMALTA )))

 cGcyRegGer := M->GCY_REGGER
 cGbhDtNasc := M->GCY_DTNASC
 cGbhSexo   := M->GCY_SEXO
 If cGcyAtendi == "3"
  cGbhRG     := M->GCY_RG
  cGbhRgOrg  := M->GCY_ORGEMI
  cGbhUFEmis := M->GCY_UFEMIS
 EndIf

 If aRotina[nOpcM24, 3] == 10 // 10-Transferencia do setor ambulatorial para o setor de internaÁ„o
  Inclui        := lIncOld
  M->GCY_DATATE := CriaVar("GCY_DATATE")
  M->GCY_HORATE := CriaVar("GCY_HORATE")
  M->GCY_ATORIG := cGcyAtOrig
  M->GCY_ATENDI := "0"
 EndIf

 If aRotina[nOpcM24, 4] == 3
  If aRotina[nOpcM24, 3] == 10 // 10-Transferencia do setor ambulatorial para o setor de internaÁ„o
   lAltCodLoc    := .T.
   M->GCY_CLORIG := cM24Par01
   M->GCY_LOCATE := Space(Len(M->GCY_LOCATE))
   M->GCY_NLATEN := Space(Len(M->GCY_NLATEN))
   M->GCY_CODLOC := Space(len(M->GCY_CODLOC))
   M->GCY_NOMLOC := Space(Len(M->GCY_NOMLOC))
  Else
   M->GCY_LOCATE := cM24Par01
   M->GCY_CODLOC := IIf(cGcyAtendi == "0", M->GCY_CODLOC, cM24Par01)
   M->GCY_NOMLOC := HS_IniPadr("GCS", 1, M->GCY_CODLOC, "GCS_NOMLOC",,.F.)
  EndIf
 EndIf

 HS_DefVar("GCS", 1, M->GCY_CODLOC, aVarDef)

 If !lOrigemExt
  cLctCodLoc := cGcsCodLoc
 EndIf
If ((Type("cCC_SetEsp") # "U") ) .AND.  FunName()== "HSPAHM35"     // Verifica se a a Chamada È pela Lista de Espera do M35 para alteraÁ„o de Setor/Quarto
M->GCY_CODLOC:=cLctCodLoc
M->GCY_QUAINT:=Space(TamSx3("GCY_QUAINT")[1])
M->GCY_NOMLOC := HS_IniPadr("GCS", 1, cLctCodLoc, "GCS_NOMLOC",,.F.)
cGcsCodLoc:=cLctCodLoc
Endif

 cOldRegAte := M->GCY_REGATE

  If nOpcM24 <> 3 .AND. nOpcM24 <> 13 .AND. nOpcM24 <> 2
     If !LockByName("ExecM24" + cOldRegAte,.T.,.T.,.F.)
         HSPVerFiCo("ExecM24",cOldRegAte,.T.)
 	     Return(Nil)
     Else
         HSPGerFiCo("ExecM24",cOldRegAte)
     EndIf
 EndIf

 If aRotina[nOpcM24, 4] <> 3
  cCondGcz := "GCZ->GCZ_REGATE == '" + M->GCY_REGATE + "'"

  If FunName() $ "HSPAHP12/HSPAHA80" // Auditoria de contas
   cCondGcz += " .And. GCZ->GCZ_NRSEQG == '" + cLctNrSeqG + "'"
  Else
   If aRotina[nOpcM24, 4] <> 2 //Consultar
    cCondGcz += " .And. GCZ->GCZ_STATUS == '0'"
   EndIf
  EndIf
 EndIf

 // Monta aHeader e aCols com informaÁıes do arquivo de GUIAS do atendimento
 cCamposNao := "GCZ_DATATE/GCZ_NOME  "
 If cGcyAtendi != "0" // 0-Internacao
  cCamposNao += "/GCZ_QTDIAS"
 EndIf

 /* N„o Apresenta Campos do AIH, se o plano n„o for AIH */
 If FunName() <> "HSPAHP12" .Or. (GCZ->GCZ_CODPLA <> __cCodAIH)
 	cCamposNao += "/GCZ_CMCAIH/GCZ_DMCAIH/GCZ_IDGUIA/GCZ_AIHANT/GCZ_AIHPOS/GCZ_CDCBOR/GCZ_DSCBOR" + ;
	 														"/GCZ_CDCCNA/GCZ_DESCNA/GCZ_TPVINC/GCZ_RNNVIV/GCZ_RNNOBI/GCZ_RNALTA/GCZ_RNTRAN/GCZ_RNOBIT" + ;
	 														"/GCZ_CPRAU1/GCZ_DPRAU1/GCZ_CPRAU2/GCZ_DPRAU2/GCZ_CPRAU3/GCZ_DPRAU3/GCZ_CPRAU4/GCZ_DPRAU4" + ;
	 														"/GCZ_CPRAU5/GCZ_DPRAU5/GCZ_DIASAC/GCZ_DTADIA/GCZ_CPFAUD/GCZ_MESINI/GCZ_MESANT/GCZ_MESALT" + ;
	 												 	"/GCZ_IDAUTE/GCZ_CPFGES/GCZ_CODAUT"
 EndIf

 /* N„o Apresenta Campos do APAC, se o plano n„o for APAC */
 If FunName() <> "HSPAHP12" .Or. !(GCZ->GCZ_CODPLA $ __cCodPAC)
 	cCamposNao += "/GCZ_TPAPAC/GCZ_CMCPAC/GCZ_VGUIAI/GCZ_VGUIAF
 EndIf

 If FunName() <> "HSPAHP12" // Alteracao para nao permitir que sejam lancadas novas guias no atendimento
  If cGcyAtendi <> "0"
   DbSelectArea("GCZ")
   DbSetOrder(2)
   DbSeek(xFilial("GCZ") + M->GCY_REGATE) // GCZ_FILIAL+GCZ_REGATE
   If aRotina[nOpcM24, 3] == 7
    While GCZ->GCZ_REGATE == M->GCY_REGATE .AND. GCZ->GCZ_FILIAL == xFilial("GCZ") .AND. lAchou
     If GCZ->GCZ_STATUS <> "0"
      nGDOpc := IIf(Inclui .Or. aRotina[nOpcM24, 3] == 7, GD_UPDATE + GD_DELETE, 0)
      lAchou := .F.
     Endif
     DbSkip()
    EndDo
   Endif
  Else
   If !Empty(M->GCY_TPALTA) .AND. !lLMMALTA
    nGDOpc := 0
   Endif
  Endif
 Endif

 HS_BDados("GCZ", @aHGCZ, @aCGCZ,, 2, M->GCY_REGATE, IIf(Empty(cCondGcz), Nil, cCondGcz),,,,, cCamposNao,,,,,,,,,,,,,, IIF(aRotina[nOpcM24, 3] == 10, {"GCZ_CODTPG"}, Nil))

 nGCZNRSEQG := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_NRSEQG"})
 nGCZCODTPG := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_CODTPG"})
 nGCZDESTPG := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_DESTPG"})
 nGCZCODPLA := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_CODPLA"})
 nGCZDESPLA := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_DESPLA"})
 nGCZCODCRM := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_CODCRM"})
 nGCZNOMMED := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_NOMMED"})
 nGczStatus := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_STATUS"})
 nGCZNrGuia := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_NRGUIA"})
 nGCZDsGuia := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_DESTPG"})
 nGCZNrSen1 := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_NRSEN1"})
 nGCZNrSen2 := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_NRSEN2"})
 nGCZNrSen3 := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_NRSEN3"})
 nGCZQtDias := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_QTDIAS"})
 nGczSqCatP := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_SQCATP"})
 nGczDsCatP := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_DSCATP"})
 nGczIdGuia := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_IDGUIA"})
 nGczCodDes := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_CODDES"})
 nGczDdespe := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_DDESPE"})
 nGczCodPrt := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_CODPRT"})
 nGczTATISS := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_TATISS"})
 nGczTIPCON := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_TIPCON"})
 nGczINDCLI := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_INDCLI"})
 nPrVGuiaI :=  aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_VGUIAI"})
 nPrVGuiaF :=  aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_VGUIAF"})
 nGCZNumOrc := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_NUMORC"})
 nGCZDtGuia := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_DTGUIA"})
 nGCZValSen := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_VALSEN"})
 nGCZTedVlr := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_TEDVLR"})
 nGCZTedUnd := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_TEDUND"})
 nGCZCPFGES := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_CPFGES"})

 If cGcyAtendi <> "4" .And. cGcyAtendi <> "1" .And. cGcyAtendi <> "3" // 1-Atendimento Ambulatorial e 3-Doacao 4 - Clinicas
  // Monta aHeader e aCols com informaÁıes do arquivo de movimentaÁ„o de leito do atendimento
  HS_BDados("GB1", @aHGB1, @aCGB1,, 5, M->GCY_REGATE, "GB1->GB1_REGATE == '" + M->GCY_REGATE + "'")
 EndIf

 If aRotina[nOpcM24, 4] == 3

  If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-InternaÁ„o

   // Monta aHeader e aCols com informaÁıes das despesas com materiais e medicamentos
   HS_BDados(cAliasMM, @aHMM, @aCMM,, 2,, Nil, .T.,,,, cCpoNaoMM,,,,,, .T.,,,, IIf(aRotina[nOpcM24, 3] == 7, IIf(cAliasMM == "GD5", {"GD5_QDEVOL","GD5_CODLOC"}, Nil), Nil),,,, aCpoVisMM)

   // Monta aHeader e aCols com informaÁıes das despesas com taxas e diarias
   HS_BDados(cAliasTD, @aHTD, @aCTD,, 2,, Nil, .T.,,,, cCpoNaoTD,,,,,, .T.,,,,,,,, aCpoVisTD)

   // Monta aHeader e aCols com informaÁıes das despesas com procedimentos
   HS_BDados(cAliasPR, @aHPR, @aCPR,, 2,, Nil, .T.,,,, cCpoNaoPR,,,,,, .T.,,,,,,,, aCpoVisPR)
  EndIf

  If cGcyAtendi == "0"
   // Monta aHeader e aCols com informaÁıes das autorizaÁıes de materiais e medicamentos especiais
   HS_BDados("GE2", @aHGE2, @aCGE2,, 2, "", Nil, ,"GE2_STATUS",,,,,,,,aLegGe2)

   // Monta aHeader e aCols com informaÁıes das autorizaÁıes de materiais e medicamentos especiais
   HS_BDados("GE3", @aHGE3, @aCGE3,, 2, "", Nil, ,"GE3_STATUS",,,,,,,,aLegGe3)

   // Monta aHeader e aCols com informaÁıes das autorizaÁıes de materiais e medicamentos especiais
   HS_BDados("GE8", @aHGE8, @aCGE8,, 2, "", Nil, .T.)
  EndIf
 Else
  For nGuias := 1 To Len(aCGcz)
   If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-InternaÁ„o
    aHMM := {}; aCMM := {}
    aHTD := {}; aCTD := {}
    aHPR := {}; aCPR := {}

    IF FunName() == "HSPAHP12" .And. cMV_AteSus == "S"
   	 HS_INIGSUS(cAliasPr,aCGcz[nGuias, nGczNrSeqG],	aCGcz[nGuias, nGczCodPla])
    Endif

	If !Empty(cGuiaBpa) .AND. Empty(aCGcz[nGuias, nGCZNrGuia])
		aCGcz[nGuias, nGCZNrGuia] := cGuiaBpa
	EndIf
    // Monta aHeader e aCols com informaÁıes das despesas com materiais e medicamentos
    HS_BDados(cAliasMM, @aHMM, @aCMM,, 2,, cPrefiMM + "_NRSEQG == '" + aCGcz[nGuias, nGczNrSeqG] + IIf(FunName() == "HSPAHP12", "'", "' .And. " + cPrefiMM + "_CODLOC == '" + cLctCodloc + "'"), .T.,,,, cCpoNaoMM,,,,,, .T.,,,, IIf(aRotina[nOpcM24, 3] == 7, IIf(cAliasMM == "GD5", {"GD5_QDEVOL","GD5_CODLOC"}, Nil), Nil),,,, aCpoVisMM)

    // Monta aHeader e aCols com informaÁıes das despesas com taxas e diarias
    HS_BDados(cAliasTD, @aHTD, @aCTD,, 2,, cPrefiTD + "_NRSEQG == '" + aCGcz[nGuias, nGczNrSeqG] + IIf(FunName() == "HSPAHP12", "'", "' .And. " + cPrefiTD + "_CODLOC == '" + cLctCodloc + "'"), .T.,,,, cCpoNaoTD,,,,,, .T.,,,,,,,, aCpoVisTD)

    // Monta aHeader e aCols com informaÁıes das despesas com procedimentos
    HS_BDados(cAliasPR, @aHPR, @aCPR,, 2,, cPrefiPR + "_NRSEQG == '" + aCGcz[nGuias, nGczNrSeqG] + IIf(FunName() == "HSPAHP12", "'", "' .And. " + cPrefiPR + "_CODLOC == '" + cLctCodloc + "'"), .T.,,,, cCpoNaoPR,,,,,, .T.,,,,,,,, aCpoVisPR)

   EndIf

   If cGcyAtendi == "0"
    If HS_ExisDic({{"T", "GNX"}})
    	cSolGnx := FS_VSOLGE(M->GCY_REGATE)
    EndIf
    If Empty(cSolGnx)
    	cCondGE2 := "GE2->GE2_NRSEQG == '" + aCGcz[nGuias, nGczNrSeqG] + "' AND GE2->GE2_NRSEQG <> '" +  SPACE(TAMSX3("GE2_NRSEQG")[1]) + "' "
    	cCondGE3 := "GE3->GE3_NRSEQG == '" + aCGcz[nGuias, nGczNrSeqG] + "' AND GE3->GE3_NRSEQG <> '" +  SPACE(TAMSX3("GE3_NRSEQG")[1]) + "' "
    Else
    	cCondGE2 := " ((GE2->GE2_NRSEQG == '" + aCGcz[nGuias, nGczNrSeqG] + "' AND GE2->GE2_NRSEQG <> '" +  SPACE(TAMSX3("GE2_NRSEQG")[1]) + "') OR (GE2->GE2_CODSOL == '" + cSolGnx + "')) "
    	cCondGE3 := " ((GE3->GE3_NRSEQG == '" + aCGcz[nGuias, nGczNrSeqG] + "' AND GE3->GE3_NRSEQG <> '" +  SPACE(TAMSX3("GE3_NRSEQG")[1]) + "') OR (GE3->GE3_CODSOL == '" + cSolGnx + "')) "
    EndIf
    aHGE2 := {}; aCGE2 := {}
    aHGE3 := {}; aCGE3 := {}
    aHGE8 := {}; aCGE8 := {}

    // Monta aHeader e aCols com informaÁıes das autorizaÁıes de materiais e medicamentos especiais
    HS_BDados("GE2", @aHGE2, @aCGE2,, 2,, cCondGE2, ,"GE2_STATUS",,,,,,,,aLegGe2 )

    // Monta aHeader e aCols com informaÁıes das autorizaÁıes de materiais e medicamentos especiais
    HS_BDados("GE3", @aHGE3, @aCGE3,, 2,, cCondGE3, ,"GE3_STATUS",,,,,,,,aLegGe3)

    // Monta aHeader e aCols com informaÁıes das autorizaÁıes de materiais e medicamentos especiais
    HS_BDados("GE8", @aHGE8, @aCGE8,, 2,, "GE8->GE8_NRSEQG == '" + aCGcz[nGuias, nGczNrSeqG] + "'", .T.)
   EndIf

   HS_INITISS(4,nGuias,aCGcz[nGuias, nGczCodPla],aCGcz[nGuias, nGCZCODTPG],aCGcz[nGuias, nGczNrSeqG], aHGCZ, @aCGcz)

   aAdd(aGczGd, {nGuias, {}, {}, {}, {}, {}, {}})

   If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-InternaÁ„o
    aGczGd[Len(aGczGd), 2] := aClone(aCMM)
    aGczGd[Len(aGczGd), 3] := aClone(aCTD)
    aGczGd[Len(aGczGd), 4] := aClone(aCPR)
   EndIf

   If cGcyAtendi == "0"
    aGczGd[Len(aGczGd), 5] := aClone(aCGE2)
    aGczGd[Len(aGczGd), 6] := aClone(aCGE3)
    aGczGd[Len(aGczGd), 7] := aClone(aCGE8)
   EndIf
  Next

  nAtAnt := Len(aGczGd)
 EndIf


 For nFCpoAlt := 1 To Len(aHMM)
  IF aHMM[nFCpoAlt, 14] == "A"
   aAdd(aAlterNew, aHMM[nFCpoAlt, 2])
  EndIf
 Next

 nMMStaReg := aScan(aHMM, {|aVet| aVet[2] ==                     "HSP_STAREG"})
 nMMQDevol := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_QDEVOL"})
 nMMCodLoc := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_CODLOC"})
 nMMNomLoc := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_NOMLOC"})
 nMMDatDes := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_DATDES"})
 nMMHorDes := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_HORDES"})
 nMMSeqDes := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_SEQDES"})
 nMMQtdDes := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_QTDDES"})
 nMMCODDES := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_CODDES"})
 nMMCODBAR := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_CODBAR"})
 nMMDDESPE := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_DDESPE"})
 nMMNumLot := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_NUMLOT"})
 nMMLoteFo := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_LOTEFO"})
 nMMLoteCt := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_LOTECT"})
 nMMDtVali := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_DTVALI"})
 nMMProAlt := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_PROALT"})
 nMMDPrAlt := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_DPRALT"})
 nMMCodPct := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_CODPCT"})
 nMMDesPct := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_DESPCT"})
 nMMCodKit := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_CODKIT"})
 nMMDesKit := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_DESKIT"})
 nMMValDes := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_VALDES"})
 nMMPCuDes := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_PCUDES"})
 nMMCodPro := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_CODPRO"})
 nMMDesPro := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_DESPRO"})
 nMMTABELA := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_TABELA"})
 nMMUNICON := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_UNICON"})
 nMMDESPER := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_DESPER"})
 nMMDESVAL := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_DESVAL"})
 nMMDESOBS := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_DESOBS"})
 nMMVALTOT := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_VALTOT"})
 nMMTOTDSC := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_TOTDSC"})
 nMMCODCRM := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_CODCRM"})
 nMMNOMMED := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_NOMMED"})
 nMMPGTMED := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_PGTMED"})
 nMMREPAMB := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_REPAMB"})
 nMMREPINT := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_REPINT"})
 nMMVALREP := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_VALREP"})
 nMMNREXTM := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_NREXTM"})
 nMMVLRGLO := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_VLRGLO"})
 nMMVALREB := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_VALREB"})
 //Plano de tratamento
 nMMNumOrc := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_NUMORC"})
 nMMIteOrc := aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_ITEORC"})

 nTDStaReg := aScan(aHTD, {|aVet| aVet[2] ==                     "HSP_STAREG"})
 nTDCodLoc := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_CODLOC"})
 nTDNomLoc := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_NOMLOC"})
 nTDSeqDes := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_SEQDES"})
 nTDDatDes := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_DATDES"})
 nTDHorDes := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_HORDES"})
 nTDQTDDES := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_QTDDES"})
 nTDCODDES := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_CODDES"})
 nTDDDESPE := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_DDESPE"})
 nTDCodPct := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_CODPCT"})
 nTDDesPct := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_DESPCT"})
 nTDCodKit := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_CODKIT"})
 nTDDesKit := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_DESKIT"})
 nTDValDes := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_VALDES"})
 nTDPCuDes := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_PCUDES"})
 nTDCodTxc := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_CODTXC"})
 nTDDesTxc := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_DESTXC"})
 nTDTABELA := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_TABELA"})
 nTDDESPER := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_DESPER"})
 nTDDESVAL := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_DESVAL"})
 nTDDESOBS := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_DESOBS"})
 nTDVALTOT := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_VALTOT"})
 nTDTOTDSC := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_TOTDSC"})
 nTDCODCRM := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_CODCRM"})
 nTDNOMMED := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_NOMMED"})
 nTDPGTMED := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_PGTMED"})
 nTDREPAMB := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_REPAMB"})
 nTDREPINT := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_REPINT"})
 nTDVALREP := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_VALREP"})
 nTDNREXTM := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_NREXTM"})
 nTDVLRGLO := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_VLRGLO"})
 nTDVALREB := aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_VALREB"})

 nPRStaReg := aScan(aHPR, {|aVet| aVet[2] ==                     "HSP_STAREG"})
 nPRCodLoc := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODLOC"})
 nPRNomLoc := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_NOMLOC"})
 nPRSeqDes := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_SEQDES"})
 nPRDatDes := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DATDES"})
 nPRHorDes := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_HORDES"})
 nPRQTDDES := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_QTDDES"})
 nPRCODDES := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODDES"})
 nPRDDESPE := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DDESPE"})
 nPRCODESP := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODESP"})
 nPRNOMESP := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_NOMESP"})
 nPRCODCRM := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODCRM"})
 nPRNOMMED := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_NOMMED"})
 nPRCODATO := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODATO"})
 nPRDESATO := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DESATO"})
 nPRCodVia := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODVIA"})
 nPRCodPct := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODPCT"})
 nPRDesPct := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DESPCT"})
 nPRCodKit := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODKIT"})
 nPRDesKit := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DESKIT"})
 nPRSPrinc := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_SPRINC"})
 nPRCOEFAM := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_COEFAM"})
 nPRVALDES := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_VALDES"})
 nPRVFILME := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_VFILME"})
 nPRVCUSOP := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_VCUSOP"})
 nPRPCUDES := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_PCUDES"})
 nPRURGDES := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_URGDES"})
 nPRCOECHP := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_COECHP"})
 nPRQTDCHP := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_QTDCHP"})
 nPRPGTMED := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_PGTMED"})
 nPRCOECHM := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_COECHM"})
 nPRREPAMB := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_REPAMB"})
 nPRVALREP := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_VALREP"})
 nPRVALREB := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_VALREB"})
 nPRSLaudo := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_SLAUDO"})
 nPRCrmLau := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CRMLAU"})
 nPRNMeLau := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_NMELAU"})
 nPRINCIDE := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_INCIDE"})
 nPRCoeDes := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_COEDES"})
 nPROriDes := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_ORIDES"})
 nPRCodPrt := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODPRT"})
 nPRDesPrt := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DESPRT"})
 nPRVlrCos := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_VLRCOS"})
 If cMV_AteSus == "S"
  nPRCdGAte := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CDGATE"})
  nPRDsGAte := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DSGATE"})
  nPRCdTAte := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CDTATE"})
  nPRDsTAte := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DSTATE"})
  nPRCodCid := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODCID"})
  nPRCidSec := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CIDSEC"})
 EndIf
 nPRTABELA := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_TABELA"})
 nPRDESPER := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DESPER"})
 nPRDESVAL := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DESVAL"})
 nPRDESOBS := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DESOBS"})
 nPRVALTOT := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_VALTOT"})
 nPRTOTDSC := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_TOTDSC"})

 //Plano de tratamento
 nPRNumOrc := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_NUMORC"})
 nPRIteOrc := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_ITEORC"})

 nGe2StaReg := aScan(aHGE2, {|aVet| aVet[2] == "GE2_STATUS"})
 nGe2CodDes := aScan(aHGE2, {|aVet| aVet[2] == "GE2_CODDES"})
 nGe2DDespe := aScan(aHGE2, {|aVet| aVet[2] == "GE2_DDESPE"})
 nGe2QtdAut := aScan(aHGE2, {|aVet| aVet[2] == "GE2_QTDAUT"})
 nGe2QtdSol := aScan(aHGE2, {|aVet| aVet[2] == "GE2_QTDSOL"})
 nGe2SeqDes := aScan(aHGE2, {|aVet| aVet[2] == "GE2_SEQDES"})
 nGe2DatSol := aScan(aHGE2, {|aVet| aVet[2] == "GE2_DATSOL"})

 nGe3StaReg := aScan(aHGE3, {|aVet| aVet[2] == "GE3_STATUS"})
 nGe3CodDes := aScan(aHGE3, {|aVet| aVet[2] == "GE3_CODDES"})
 nGe3DDespe := aScan(aHGE3, {|aVet| aVet[2] == "GE3_DDESPE"})
 nGe3CodPrt := aScan(aHGE3, {|aVet| aVet[2] == "GE3_CODPRT"})
 nGe3SeqDes := aScan(aHGE3, {|aVet| aVet[2] == "GE3_SEQDES"})
 nGe3DatSol := aScan(aHGE3, {|aVet| aVet[2] == "GE3_DATSOL"})
 nGe3HorSol := aScan(aHGE3, {|aVet| aVet[2] == "GE3_HORSOL"})
 nGe3QtdSol := aScan(aHGE3, {|aVet| aVet[2] == "GE3_QTDSOL"})
 nGe3QtdAut := aScan(aHGE3, {|aVet| aVet[2] == "GE3_QTDAUT"})
 nGe3SenAut := aScan(aHGE3, {|aVet| aVet[2] == "GE3_SENAUT"})
 nGe3DatAut := aScan(aHGE3, {|aVet| aVet[2] == "GE3_DATAUT"})
 nGe3HorAut := aScan(aHGE3, {|aVet| aVet[2] == "GE3_HORAUT"})
 nGe3ValAut := aScan(aHGE3, {|aVet| aVet[2] == "GE3_VALAUT"})
 nGe3NroAut := aScan(aHGE3, {|aVet| aVet[2] == "GE3_NROAUT"})
 nGe3ResAut := aScan(aHGE3, {|aVet| aVet[2] == "GE3_RESAUT"})
 nGe3ValAut := aScan(aHGE3, {|aVet| aVet[2] == "GE3_VALAUT"})
 nGe3MnAuto := aScan(aHGE3, {|aVet| aVet[2] == "GE3_MNAUTO"})

 nGe8StaReg := aScan(aHGE8, {|aVet| aVet[2] == "HSP_STAREG"})
 nGe8CodCrm := aScan(aHGE8, {|aVet| aVet[2] == "GE8_CODCRM"})
 nGe8NomMed := aScan(aHGE8, {|aVet| aVet[2] == "GE8_NOMMED"})
 nGe8SeqDes := aScan(aHGE8, {|aVet| aVet[2] == "GE8_SEQDES"})
 nGe8DatSol := aScan(aHGE8, {|aVet| aVet[2] == "GE8_DATSOL"})
 nGe8QtDias := aScan(aHGE8, {|aVet| aVet[2] == "GE8_QTDIAS"})
 nGe8DatLib := aScan(aHGE8, {|aVet| aVet[2] == "GE8_DATLIB"})
 nGe8QtdLib := aScan(aHGE8, {|aVet| aVet[2] == "GE8_QTDLIB"})
 nGe8DatVen := aScan(aHGE8, {|aVet| aVet[2] == "GE8_DATVEN"})

 If !Inclui
  HS_IniPadr("GCY", 1, cOldRegAte, "GCY_NOME",,.F.)
  cGavModelo := HS_IniPadr("GAV", 1, M->GCY_CODLOC + M->GCY_QUAINT + M->GCY_LEIINT, "GAV_MODELO",,.F.)
 EndIf



 If aRotina[nOpcM24, 3] == 7 // 7-Guias
  Inclui := .T.
 EndIf


 Define MsDialog oDlgAten Title OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd PIXEL
  If cGcyAtendi $ "134" // 1-Atendimento Ambulatorial ou 3-Atendimento Doacao 4 - Clinicas
   @ aPFolder[1, 1], aPFolder[1, 2] FOLDER oFolAten SIZE aPFolder[1, 3], aPFolder[1, 4]+10 Pixel OF oDlgAten Prompts STR0025 //"&1-Dados Gerais"
  Else
   @ aPFolder[1, 1], aPFolder[1, 2] FOLDER oFolAten SIZE aPFolder[1, 3], aPFolder[1, 4]+10 Pixel OF oDlgAten Prompts STR0025, STR0026, STR0087 //"&1-Dados Gerais"###"&2-Mapa de leitos" //"MovimentaÁ„o de leito"
  EndIf

  // Dados do atendimento
  aGets := {}
  aTela := {}
  oEncGcy := MsMGet():New("GCY", nRegM24, nOpcM24,,,, aCposGcy, IIF(aRotina[nOpcM24, 3] <> 4, {aPObjs[1, 1], aPObjs[1, 2]-10, aPObjs[1, 3], aPObjs[1, 4]-04}, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}), aCposAlt, 2,,,, oFolAten:aDialogs[1])
  oEncGcy:oBox:Align := CONTROL_ALIGN_TOP
  oEncGcy:oBox:bSetGet :=  {|| IIF(SUBSTR(Readvar(),4,3) == "GCY", FS_GrFGcy(), .T.)}
  If aRotina[nOpcM24, 3] == 10 // 10-Transferencia do setor ambulatorial para o setor de internaÁ„o
   oEncGcy:AENTRYCTRLS[aScan(oEncGcy:aGets, {| aVet | "GCY_LOCATE" $ aVet})]:BGOTFOCUS := {|| HS_M24When("GCY_LOCATE")}
   oEncGcy:AENTRYCTRLS[aScan(oEncGcy:aGets, {| aVet | "GCY_CODLOC" $ aVet})]:BGOTFOCUS := {|| HS_M24When("GCY_CODLOC")}
  EndIf

  If cGcyAtendi == "3"
   oEncGcy:AENTRYCTRLS[aScan(oEncGcy:aGets, {| aVet | "GCY_NMBENE" $ aVet})]:BGOTFOCUS  := {|| FS_LimpFil(cGbhSexo, cGbhDtNasc, cGbhRg, cGbhRgOrg, cGbhUFEmis,cGbhDtNasc,@cGbhSexo,@cGbhRg, @cGbhRgOrg, @cGbhUFEmis,@cSexoAu, @cDtNascAu, @cRGAu , @cOrgEmiAu , @cUFEmisAu)}
   oEncGcy:AENTRYCTRLS[aScan(oEncGcy:aGets, {| aVet | "GCY_NMBENE" $ aVet})]:BLOSTFOCUS := {|| FS_LimpFil(cGbhSexo, cGbhDtNasc, cGbhRg, cGbhRgOrg, cGbhUFEmis,cGbhDtNasc,@cGbhSexo,@cGbhRg, @cGbhRgOrg, @cGbhUFEmis,@cSexoAu, @cDtNascAu, @cRGAu , @cOrgEmiAu , @cUFEmisAu)}
   oEncGcy:AENTRYCTRLS[aScan(oEncGcy:aGets, {| aVet | "GCY_DSBENE" $ aVet})]:BGOTFOCUS  := {|| FS_LimpFil(cGbhSexo, cGbhDtNasc, cGbhRg, cGbhRgOrg, cGbhUFEmis,cGbhDtNasc,@cGbhSexo,@cGbhRg, @cGbhRgOrg, @cGbhUFEmis,@cSexoAu, @cDtNascAu, @cRGAu , @cOrgEmiAu , @cUFEmisAu)}
   oEncGcy:AENTRYCTRLS[aScan(oEncGcy:aGets, {| aVet | "GCY_DSBENE" $ aVet})]:BLOSTFOCUS := {|| FS_LimpFil(cGbhSexo, cGbhDtNasc, cGbhRg, cGbhRgOrg, cGbhUFEmis,cGbhDtNasc,@cGbhSexo,@cGbhRg, @cGbhRgOrg, @cGbhUFEmis,@cSexoAu, @cDtNascAu, @cRGAu , @cOrgEmiAu , @cUFEmisAu)}
  EndIf

  aGetsGcy := aClone(aGets)
  aTelaGcy := aClone(aTela)

  // Dados das Guias
  If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3",  aRotina[nOpcM24, 3] <> 7, aRotina[nOpcM24, 3] <> 4))
   oGDGCZ := MsNewGetDados():New(aPObjs[2, 1]+2, aPObjs[2, 2]-09, aPObjs[2, 3]+2, aPObjs[2, 4]-04, nGDOpc,,,,,, 99999,,,, oFolAten:aDialogs[1], aHGCZ, aCGCZ)
   oGDGcz:oBrowse:Align := CONTROL_ALIGN_TOP
   oGDGCZ:bChange  	    := {|| FS_SACols(FunName() == "HSPAHP12",@aGuiaTISS,@lNrGTissAt,@nAtAnt,@nGczNrSeqG,@nGczStatus,@nGCZNUMORC)}
   oGDGCZ:bLinhaOk 	    := {|| FS_VACols()}
   oGDGCZ:oBrowse:bGotFocus :=  {|| FS_GczGFoc()}
   oGDGCZ:oBrowse:bLostFocus := {|| FS_GczLFoc()}
   oGDGCZ:oBrowse:bDelete := {|| IIF(FS_VldGuia(@nGe3CodDes,@nGe3CodPrt), oGDGCZ:DelLine(), Nil)}

   If     cGcyAtendi == "0" // 0-InternaÁ„o
    If lOrigemExt
     @ aPObjs[3, 1]+04, aPObjs[3, 2]-09 FOLDER oFolDesp SIZE aPObjs[3, 3]+04, aPObjs[3, 4]-10 Pixel OF oFolAten:aDialogs[1] Prompts STR0027, STR0028, STR0029, STR0030, STR0031, STR0032, STR0033 //"&3-Procedimentos"###"&4-Materiais / Medicamentos"###"&5-Taxas / Diarias"###"&6-Despesas fixas"###"&7-Autorizacao de Mat/Med"###"&8-Autorizacao de procedimento"###"&9-Controle de guias"
    Else
     @ aPObjs[3, 1]+04, aPObjs[3, 2]-09 FOLDER oFolDesp SIZE aPObjs[3, 3]+04, aPObjs[3, 4]-10 Pixel OF oFolAten:aDialogs[1] Prompts STR0030, STR0031, STR0032, STR0033 //&6-Despesas fixas"###"&7-Autorizacao de Mat/Med"###"&8-Autorizacao de procedimento"###"&9-Controle de guias"
    EndIf
   ElseIf cGcyAtendi $ "14" // 1-Atendimento Ambulatorial / Clinicas
    @ aPObjs[3, 1]+04, aPObjs[3, 2]-09 FOLDER oFolDesp SIZE aPObjs[3, 3]+04, aPObjs[3, 4]-10 Pixel OF oFolAten:aDialogs[1] Prompts STR0027, STR0028, STR0029 //"&3-Procedimentos"###"&4-Materiais / Medicamentos"###"&5-Taxas / Diarias"
   ElseIf cGcyAtendi == "2" // 2-Pronto Atendimento
    @ aPObjs[3, 1]+04, aPObjs[3, 2]-09 FOLDER oFolDesp SIZE aPObjs[3, 3]+04, aPObjs[3, 4]-10 Pixel OF oFolAten:aDialogs[1] Prompts STR0027, STR0028, STR0029, STR0030 //"&3-Procedimentos"###"&4-Materiais / Medicamentos"###"&5-Taxas / Diarias"###"&6-Despesas fixas"
   ElseIf cGcyAtendi == "3" // 3-Atendimento Doacao
    @ aPObjs[3, 1]+04, aPObjs[3, 2]-09 FOLDER oFolDesp SIZE aPObjs[3, 3]+04, aPObjs[3, 4]-10 Pixel OF oFolAten:aDialogs[1] Prompts STR0027, STR0028, STR0029 //"&3-Procedimentos"###"&4-Materiais / Medicamentos"###"&5-Taxas / Diarias"
   EndIF
   oFolDesp:Align := CONTROL_ALIGN_ALLCLIENT

   If aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&3-"}) > 0
    aAdd(aOPesq, {"oGDPR", "03"})
    oGDPR := MsNewGetDados():New(aPDesp[1, 1], aPDesp[1, 2], aPDesp[1, 3], aPDesp[1, 4], nGDOpc,,,,, /*nFreeze*/, 99999,,,, oFolDesp:aDialogs[aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&3-"})], aHPR, aCPR)
    oGDPR:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT
    Iif (lAteSUS .And. cGcyAtendi == '0' .And. FunName() == "HSPAHP12" .And. (GCZ->GCZ_CODPLA $ __cCodAIH),oGDPR:oBrowse:Disable(),"")
    If aRotina[nOpcM24, 4] == 3 .Or. aRotina[nOpcM24, 4] == 4
     oGDPR:oBrowse:bLostFocus := {|| FS_PRLFoc(@cCondAtrib)}
     oGDPR:oBrowse:bGotFocus  := {|| FS_PRGFoc(oGDPr) }
     oGDPR:bChange            := {|| FS_PRGFoc(oGDPr), FS_ChgGD(oGDPR, nPRCodLoc), IIf(cGcyAtendi == "4" .AND. !EMPTY(oGDPR:aCols[oGDPR:nAt, nPRCODDES]), FS_PROCPLS(oGDPR:aCols[oGDPR:nAt, nPRCODDES]),Nil)}
     oGDPR:oBrowse:bAdd       := { || FS_AddLin( oGDPr, nPRCodLoc, nPRNomLoc, nPrDatDes, nPrHordes ) }
     oGDPR:bLinhaOk           := {|| IIF(oGDPR:aCols[oGDPR:nAt, nPRStareg] <> "BR_VERDE", !EMPTY(oGDPR:aCols[oGDPR:nAt, nPRCODDES]) .And. HS_VDatDes(oGDPR:aCols[oGDPR:nAt, nPRDatDes],SUBSTR(oGDPR:aCols[oGDPR:nAt, nPRHorDes], 1, 5)),.T.) .And. FS_PRLiOk() .And. HS_SLaudo(.T.) }
     oGDPR:cFieldOk           := "HS_PRFiOk() .And. HS_GDAtrib(oGDPR, {{nPRStaReg, 'BR_AMARELO', 'BR_VERDE'}})"
     oGDPR:oBrowse:bDelete    := {|| HS_GDAtrib(oGDPR, {{nPRStaReg, "BR_CINZA", "BR_VERDE"}}), Iif(HS_DelInci() .And. HS_VExcLau() .And. FS_VExSoli(oGDPr,nPRSeqDes,"GE3", nPRStaReg),{oGDPr:DelLine(),oGDPr:oBrowse:Refresh()},Nil)}
    EndIf
   EndIf

   If aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&4-"}) > 0
    aAdd(aOPesq, {"oGDMM", "04"})
    oGDMM := MsNewGetDados():New(aPDesp[1, 1], aPDesp[1, 2], aPDesp[1, 3], aPDesp[1, 4], nGDOpc,,,,, /*nFreeze*/, 99999,,,, oFolDesp:aDialogs[aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&4-"})], aHMM, aCMM)
    oGDMM:oBrowse:Align     := CONTROL_ALIGN_ALLCLIENT
    If aRotina[nOpcM24, 4] == 3 .Or. aRotina[nOpcM24, 4] == 4
     oGDMM:bChange           := {|| IIf(cAliasMM == "GD5" .And. aRotina[nOpcM24, 3] == 7, HS_CtrlBrw(oGDMM, nMMSeqDes, aAlterNew, aAlterOld), .T.), FS_ChgGD(oGDMM, nMMCodLoc),__cCtrEst := IIF(nMMCodLoc == 0,cLctCodLoc,oGDMM:aCols[oGDMM:nAt, nMMCodLoc])}
     oGDMM:bLinhaOk          := {|| IIF(oGDMM:aCols[oGDMM:nAt, nMMStareg] <> "BR_VERDE",IIF(cAliasMM == "GD5", HS_VldM24(      ,20   ,          ,         ,oGDMM:aCols[oGDMM:nAt, nMMDatDes],    ,          ,@oGDGcz,,lRecepAgd,lNrGTissAt,@nPrVguiaF,@nGCZNRSEQG,@nGCZDsGuia,@cGavModelo,@cOldLeiInt,@cOldQuaInt,cGbjCodEsp  ,cGA7CodPro,cObsCodCrm,cGbjTipPro,cCondAtrib,nPRCODESP,/*nPRDatDes*/,/*nPRCODDES*/,cOldCodLoc,cGbhDtNasc,cGbhSexo,cGbhRg, cGbhRgOrg, cGbhUFEmis,lRecepAgd), ;
                         !EMPTY(oGDMM:aCols[oGDMM:nAt, nMMCodDes]) .And. HS_VDatDes(oGDMM:aCols[oGDMM:nAt, nMMDatDes], oGDMM:aCols[oGDMM:nAt, nMMHorDes])),.T.) .And. HS_VQtdMM(oGDMM:aCols[oGDMM:nAt, nMMQtdDes])}
     oGDMM:cFieldOk          := "IIF(cAliasMM == 'GD5', HS_VldM24(,20), Nil), IIf(oGDMM:oBrowse:nColPos <> nMMQDevol, HS_GDAtrib(oGDMM, {{nMMStaReg, 'BR_AMARELO', 'BR_VERDE'}}), .T.)"
     oGDMM:oBrowse:bGotFocus := {|| FS_MMGFoc(oGDMM, aAlterNew, aAlterOld, nOpcM24,cOldLeiInt,cOldQuaInt,nMMCodLoc,cLctCodLoc,nMMSeqDes)}
     oGDMM:oBrowse:beditcol  := {|| __cCtrEst := IIF(nMMCodLoc == 0,cLctCodLoc,oGDMM:aCols[oGDMM:nAt, nMMCodLoc])}
     oGDMM:oBrowse:bAdd       := { || FS_AddLin( oGDMM, nMMCodLoc, nMMNomLoc, nMMDatDes, nMMHordes ) }
     If cAliasMM == "GD5"
      oGDMM:oBrowse:bDelete := {|| FS_MatMed(oGDMM,nMMQDevol)}

     Else
      oGDMM:oBrowse:bDelete := {|| HS_GDAtrib(oGDMM, {{nMMStaReg, "BR_CINZA", "BR_VERDE"}}), oGDMM:DelLine()}
     EndIf
    EndIf
   EndIf

   If aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&5-"}) > 0
    aAdd(aOPesq, {"oGDTD", "05"})
    oGDTD := MsNewGetDados():New(aPDesp[1, 1], aPDesp[1, 2], aPDesp[1, 3], aPDesp[1, 4], nGDOpc,,,,, /*nFreeze*/, 99999,,,, oFolDesp:aDialogs[aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&5-"})], aHTD, aCTD)
    oGDTD:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
    Iif (lAteSUS .And. cGcyAtendi == '0' .And. (GCZ->GCZ_CODPLA $ __cCodAIH),oGDTD:oBrowse:Disable(),"")
    If aRotina[nOpcM24, 4] == 3 .Or. aRotina[nOpcM24, 4] == 4
     oGDTD:bChange         := {|| FS_ChgGD(oGDTD, nTDCodLoc)}
     oGDTD:oBrowse:bGotFocus := {|| FS_TDGFoc(oGDTD,nTDCodCrm)}
     oGDTD:bLinhaOk        := {|| IIF(oGDTD:aCols[oGDTD:nAt, nTDStareg] <> "BR_VERDE", !EMPTY(oGDTD:aCols[oGDTD:nAt, nTDCodDes]) .And. HS_VDatDes(oGDTD:aCols[oGDTD:nAt, nTDDatDes], oGDTD:aCols[oGDTD:nAt, nTDHorDes]),.T.)}
     oGDTD:cFieldOk        := "HS_GDAtrib(oGDTD, {{nTDStaReg, 'BR_AMARELO', 'BR_VERDE'}})"
     oGDTD:oBrowse:bAdd       := { || FS_AddLin( oGDTD, nTDCodLoc, nTDNomLoc, nTDDatDes, nTDHordes ) }
     oGDTD:oBrowse:bDelete := {|| HS_GDAtrib(oGDTD, {{nTDStaReg, "BR_CINZA", "BR_VERDE"}}), oGDTD:DelLine()}
    EndIf
   EndIf

   If aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&7-"}) > 0
    aAdd(aOPesq, {"oGDGe2", "07"})
    oGDGe2 := MsNewGetDados():New(aPDesp[1, 1], aPDesp[1, 2], aPDesp[1, 3], aPDesp[1, 4], nGDOpc,,,,aCpoAltMM, /*nFreeze*/, 99999,,,, oFolDesp:aDialogs[aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&7-"})], aHGe2, aCGe2)
    oGDGe2:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
	oGDGe2:oBrowse:BlDblClick := {|| FS_DbClkGE(oGDGe2)}
   EndIf

   If aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&8-"}) > 0
    aAdd(aOPesq, {"oGDGe3", "08"})
    oGDGe3 := MsNewGetDados():New(aPDesp[1, 1], aPDesp[1, 2], aPDesp[1, 3], aPDesp[1, 4], 0,,,,aCpoAltPR, /*nFreeze*/, 99999,,,, oFolDesp:aDialogs[aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&8-"})], aHGe3, aCGe3)
    oGDGe3:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
	oGDGe3:oBrowse:BlDblClick := {|| FS_DbClkGE(oGDGe3)}
   EndIf

   If aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&9-"}) > 0
    aAdd(aOPesq, {"oGDGe8", "09"})
    oGDGe8 := MsNewGetDados():New(aPDesp[1, 1], aPDesp[1, 2], aPDesp[1, 3], aPDesp[1, 4], nGDOpc,,,,aCpoAltPG, /*nFreeze*/, 99999,,,, oFolDesp:aDialogs[aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&9-"})], aHGe8, aCGe8)
    oGDGe8:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
    If aRotina[nOpcM24, 4] == 3 .Or. aRotina[nOpcM24, 4] == 4
     oGDGe8:oBrowse:bGotFocus := {|| FS_LimpAtr()}
     oGDGe8:cFieldOk        := "HS_GDAtrib(oGDGe8, {{nGe8StaReg, 'BR_AMARELO', 'BR_VERDE'}})"
     oGDGe8:oBrowse:bDelete := {|| HS_GDAtrib(oGDGe8, {{nGe8StaReg, "BR_CINZA", "BR_VERDE"}}), oGDGe8:DelLine()}
    EndIf
   EndIf

   If aRotina[nOpcM24, 3] == 10 //transferencia, valida dados paciente e medico
    HS_VldM24(, 4)
    HS_VldM24(, 5)
   EndIf

   // AmarraÁ„o plano x acomodaÁ„o
   If aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&6-"}) > 0 //cGcyAtendi # "1"
    aAdd(aOPesq, {"oGDGdd", "06"})
    If aRotina[nOpcM24, 4] <> 3
     cGczCodPla := aCGcz[1, nGczCodPla]
     cGczNrSeqG := aCGcz[1, nGczNrSeqG]
    EndIf
    // Despesas fixas
    cGavModelo := Posicione("GAV",1,xFilial("GAV")+M->GCY_CODLOC + M->GCY_QUAINT + M->GCY_LEIINT,"GAV_MODELO")

	aTrbHis:={}

    FS_M24DF(IIf(aRotina[nOpcM24, 4] <> 3, cGavModelo, ""), .F., oGDGdd, aRotina[nOpcM24, 4] <> 3,aHGDD,@nGddCodTxd,@nGddPerg,@nGddQtde,@nGddDesc,@aCGdd/*oGDGdd*/)

    cGavModelo := Posicione("GAV",1,xFilial("GAV")+M->GCY_CODLOC + M->GCY_QUAINT + M->GCY_LEIINT,"GAV_MODELO")

    oGDGdd := MsNewGetDados():New(aPDesp[1, 1], aPDesp[1, 2], aPDesp[1, 3], aPDesp[1, 4], 0,,,,,, Len(aCGdd),,,, oFolDesp:aDialogs[aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&6-"})], aHGDD, aCGDD)
    oGDGdd:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT
    oGDGdd:oBrowse:BlDblClick := {|| HS_MBDFixa(cGczCodPla, cGavModelo, oGDGdd, @nGddCodTxd, @nGddPerg)}
   EndIf
  EndIf

  If cGcyAtendi <> "1" .And. cGcyAtendi <> "3" .And. cGcyAtendi <> "4"// 7-Despesas e 1-Atendimento Ambulatorial e 3-Doacao
   // Mapa de Leitos
   oBrwLei := HS_MBrow(oFolAten:aDialogs[2], "GAV", {aPMBrow[1, 1]-10, aPMBrow[1, 2]+2, aPMBrow[1, 4]-6, aPMBrow[1, 3]-20},,,, aCorLeito,,,,,,,,, aCBrwPac,,,, .T.)
   //Usado somente para posicionamento no Relatorio Imp Cad da Lib.
	If   FunName() <> "HSPAHM30" .And. FunName() <> "HSPAHP12"
		If aRotina[nOpcM24, 4] == 2 .or. aRotina[nOpcM24, 4] == 4 .and. aRotina[nOpcM24, 3]<> 7
			oImpCad :=  HS_MBrow(oFolAten:aDialogs[2], "GCY"    , {005, 000, 435, 110},"'" + GCY->GCY_REGATE + "'","'" + GCY->GCY_REGATE + "'",/*"GCM_STATUS"*/, /*aCores*/, /*"GCM_OK"*/, /*aResMar*/, /*@aItensMar*/,          , /*bViewReg*/, .F.  , /*cFunMB*/,  .F.   , /*aColsBrw*/, /*cFunAM*/, /*aRotMB*/, /*aCIniBrw*/, /*lVirtual*/)
			oImpCad:LVisible:=.F.
		Endif
	Endif
  EndIf

  If cGcyAtendi <> "1" .And. cGcyAtendi <> "3" .And. cGcyAtendi <> "4"// 7-Despesas e 1-Atendimento Ambulatorial e 3-Doacao
   // Dados da movimentaÁ„o de leito do atendimento
   oGDGb1 := MsNewGetDados():New(aPMBrow[1, 1]-10, aPMBrow[1, 2]+2, aPMBrow[1, 3]+9, aPMBrow[1, 4]-4, 0,,,,,, 99999,,,, oFolAten:aDialogs[3], aHGb1, aCGb1)
   oGDGb1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
  EndIf

  If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3",  aRotina[nOpcM24, 3] <> 7, aRotina[nOpcM24, 3] <> 4))
   oPPesq	:=	tPanel():New(aPObjs[4, 1], aPObjs[4, 2],, oFolAten:aDialogs[1],,,,,, aPObjs[4, 3], aPObjs[4, 4])
   oPPesq:Align := CONTROL_ALIGN_BOTTOM

   aSort(aOPesq,,, {| X, Y | X[2] < Y[2]})
   oFolDesp:bChange:= {|| HS_GDPesqu(,, &(aOPesq[oFolDesp:nOption, 1]), oPPesq, 001, .T.) }

   HS_GDPesqu(,, &(aOPesq[oFolDesp:nOption, 1]), @oPPesq, 001, .T.)
  EndIf
  
  bAction01 := {|| IIF(StrZero(aRotina[nOpcM24, 3], 2) $ IIF(cGcyAtendi == "2", "03", "03/13") .And. lNewDayAte, ChkNewDay(@oDlgAten, .F., "HS_CposM24", .T.), Nil)}
  bAction02 := {|| IIf(IIF(aRotina[nOpcM24, 3] == 7, FS_GczGFoc(), .T.) .And. !FS_LstAgd(nOpcM24,oGDGDD), oDlgAten:End(), .T.)}
  bOK		:= {|| nOpcAten := 1, IIf(FS_AtenOk(aGetsGcy, aTelaGcy, nOpcM24, aCposObr,nGczTATISS,nGczTIPCON,nGczDtGuia,nGCZValSen),;
													oDlgAten:End(),;
													nOpcAten:= 0)}
  bCancel	:= {|| nOpcAten := 0, oDlgAten:End()}
 Activate MsDialog oDlgAten ON INIT Eval ({|| EnchoiceBar(oDlgAten,bOK,bCancel,,aBtnBar),Eval(bAction01),Eval(bAction02)})
 
 If aRotina[nOpcM24, 3] == 7
  Inclui := .T.
 EndIf

 If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3",  aRotina[nOpcM24, 3] <> 7, aRotina[nOpcM24, 3] <> 4))
  HS_ReutGui(nOpcAten)
 EndIf

 IF nOpcAten == 0
  FS_RetLei(cOldCodLoc,cOldQuaInt,cOldLeiInt)

  While __lSx8
   RollBackSxe()
  End
 Else
  If aRotina[nOpcM24, 4] # 2 // Caso n„o seja consulta entra na funÁ„o de gravaÁ„o
   lOpcOk := .T.
   If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3",  aRotina[nOpcM24, 3] <> 7, aRotina[nOpcM24, 3] <> 4))
    If (nPosGD := aScan(aGczGd, {| aVet | aVet[1] == oGDGcz:nAt})) == 0
     aAdd(aGczGd, {oGDGcz:nAt, {}, {}, {}, {}, {}, {}})
     nPosGD := Len(aGczGd)
    EndIf

    If aRotina[nOpcM24, 4] == 3 .And. dDataBase <> Date()
     If MsgYesNo(STR0285, STR0034) //"Deseja gravar o atendimento com a data retroativa?"###"AtenÁ„o"
      dDatAte := dDataBase
     Else
      dDatAte := Date()
      HS_CposM24(dDatAte, .F.)
     EndIf
    Else
     dDatAte := M->GCY_DATATE
    EndIf

    If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-InternaÁ„o
     aGczGd[nPosGD, 2] := aClone(oGDMM:aCols)
     aGczGd[nPosGD, 3] := aClone(oGDTD:aCols)
     aGczGd[nPosGD, 4] := aClone(oGDPR:aCols)
    EndIf

    If cGcyAtendi == "0"
     aGczGd[nPosGD, 5] := aClone(oGDGE2:aCols)
     aGczGd[nPosGD, 6] := aClone(oGDGE3:aCols)
     aGczGd[nPosGD, 7] := aClone(oGDGE8:aCols)
    Endif

    For nForGuia := 1 To Len(aGczGD)
     aCDesp := aClone(aGczGD[nForGuia, 2])

     For nForMM := 1 To Len(aCDesp)

      If aCDesp[nForMM, nMMStaReg] <> "BR_VERDE" .And. ;
         (aConEst:= HS_CONEST(aCDesp[nForMM, nMMCodDes], HS_RetSet(cAliasMM, nMMSeqDes, nMMCodLoc, cLctCodLoc, nForMM, aCDesp))[1]) .And. ;
         IIf(FunName() == "HSPAHP12", cMovest == "S", .T.) // Validacao da movimentacao do estoque para auditoria

       If aScan(aMLocksSb2, aCDesp[nForMM, nMMCodDes] + cGcsArmSet) == 0
        aAdd(aMLocksSb2, aCDesp[nForMM, nMMCodDes] + cGcsArmSet)
       EndIf

       If aScan(aMLocksSb3, aCDesp[nForMM, nMMCodDes]) == 0
        aAdd(aMLocksSb3, aCDesp[nForMM, nMMCodDes])
       EndIf

      EndIf

     Next
    Next
   EndIf

   If Len(aMLocksSb2) > 0
    aSort(aMLocksSb2,,, {| X, Y | X < Y})
   EndIf

   If Len(aMLocksSb3) > 0
    aSort(aMLocksSb3,,, {| X, Y | X < Y})
   EndIf

   If IIf(Len(aMLocksSb2) > 0, MultLock("SB2", aMLocksSb2, 1), .T.) .And. ;
      IIf(Len(aMLocksSb3) > 0, MultLock("SB3", aMLocksSb3, 1), .T.)

    Begin Transaction
    	If ExistBlock("HSM24BTR")
 		   Execblock("HSM24BTR", .F., .F.,{nOpcM24})
 	   EndIf

     FS_GrvM24(nOpcM24, cRegAteOri,oGDGDD,@aGuiaTISS,@nGe3CodDes,@nGddCodTxd,@nGddPerg,@nGddQtde,nTDValTot,@nTDTotDsc,@nTDValDes,@nMMSeqDes,@nMMNumLot,@nMMDtVali,@nMMValDes,dDatAte,nGczStatus,nMMProAlt,nGczNrSeqG,NPRCODVIA,nPRINCIDE)

     If lOrc //Atualiza orcamento
      DBSelectArea("GO0")
      DbSetOrder(1) //NUMORC
      DbSeek(xFilial("GO0") + cGO0NumOrc)
      RecLock("GO0", .F.)
       GO0->GO0_STATUS := "1" //Confirmado
       GO0->GO0_REGATE := M->GCY_REGATE
       GO0->GO0_REGGER := M->GCY_REGGER
      MsUnLock()
     EndIf

     If ExistBlock("HSM24ETR")
 		   Execblock("HSM24ETR", .F., .F.,{nOpcM24})
 	   EndIf

 	HSM24PTCLI(nOpcM24)

    End Transaction

    While __lSx8
     ConfirmSx8()
    End

    //Ponto de entrada apos a gravacao do atendimento
	If ExistBlock("HSM24ATE")
		Execblock("HSM24ATE",.f.,.f.,{.T.})
	Endif

    lFichas := .F.
    If cGcyAtendi == "0"    //Internacao
     If nOpcM24 == 3 .Or. nOpcM24 == 13
      lFichas := .T.
     EndIf
    ElseIf cGcyAtendi $ "14"  //Ambulatorio ou Clinicas
     If nOpcM24 == 3 .Or. nOpcM24 == 13
      lFichas := .T.
     EndIf
    ElseIf cGcyAtendi == "2"   //Pronto Atendimento
     If nOpcM24 == 3
      lFichas := .T.
     EndIf
    ElseIf cGcyAtendi == "3"   //Atendimento Doacao
     If aRotina[nOpcM24, 4] == 3 .Or. aRotina[nOpcM24, 4] == 13
      lFichas := .T.
     EndIf
    EndIf

    If lFichas

     GDN->(dbSetOrder(1))
     If GDN->(DbSeek(xFilial("GDN") + M->GCY_LOCATE))

	 			 HSPAHP44(.T., GCY->GCY_LOCATE, {{"GBH", 1, M->GCY_REGGER}})
     EndIf

     HS_MntTISS("M24")

     If ExistBlock("HSM24FCH") .And. cGcyAtendi $ "1/2/4"
      Execblock("HSM24FCH",.f.,.f.,{.T.})
     Endif

    EndIf

   EndIf
  EndIf
 EndIf

 DbSelectArea("GCY")
 SetKey(VK_F4 , bKeyF4 )
 SetKey(VK_F5 , bKeyF5 )
 SetKey(VK_F6 , bKeyF6 )
 SetKey(VK_F7 , bKeyF7 )
 SetKey(VK_F8 , bKeyF8 )
 SetKey(VK_F9 , bKeyF9 )
 SetKey(VK_F10, bKeyF10)
 SetKey(VK_F12, bKeyF12)
 cGcyAtendi := cGcyAtOrig
 cGcsTipLoc := cGcsTLOld

 If StrZero(nOpcM24, 2) $ "08/10"
  MBrChgLoop(.F.)
 EndIf
//Grava os itens para visualizacao no controle de solicitacoes
If ((Type("__aGeISol") # "U" .AND. Len(__aGeISol) > 0) .OR. (Type("__aGeMSol") # "U" .AND. Len(__aGeMSol) > 0))   .AND. nOpcAten <> 0
	FS_GrvSol(M->GCY_REGATE,__aGeISol,__aGeMSol)
EndIf
If cGcyAtendi $ "1/4" .AND. nOpcAten == 1 .AND. HS_ExisDic({{"T", "GP9"}}, .F.)//Ambulatorio ou Clinicas // Abre tela do pedido de exames onde sera verificado se ter· alguma solicitacao para laboratorio
	HSPAHM08(M->GCY_REGATE, "", M->GCY_CODLOC , , .T.)
EndIf
UnLockByName("ExecM24" + M->GCY_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",Alltrim(M->GCY_REGATE))
If ((Type("cCC_SetEsp") # "U") .and. nOpcAten == 1 .and. cGcyAtendi == "0") .AND.  FunName()== "HSPAHM35"
	cCC_SetEsp:=GCY->GCY_CODLOC
	cCC_QuarEsp:=GCY->GCY_QUAINT
	cCC_LeiEsp:=GCY->GCY_LEIINT
Endif
If HS_ExisDic({{"C", "GCS_LSTESP"}}, .F.) .and.  nOpcM24 ==3 .and. cGcyAtendi == "0" .and. nOpcAten == 1
		If HS_CountTB("GT6", "GT6_REGGER = '" + M->GCY_REGGER + "'OR (GT6_CODLOC = '" + GCY->GCY_CODLOC + "' AND  GT6_CODAGE = '" + cAgdCodAge + "')") > 0
  		HS_ExclEs(M->GCY_REGGER)
  	Endif
Endif

Return(nOpcAten == 1)
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ FS_VExSoli ≥ Autor ≥ Gest„o Hospitalar     ≥ Data ≥12.05.2009≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥V·lida se despesa com procedimento pode ser excluida de acordo≥±±
±±≥          ≥com o Status da SolicitaÁ„o na GE.                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ExpL1: Se despesa pode ser excluida                           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ ValidaÁ„o deleÁ„o de item                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function FS_VExSoli(oGDDesp, nSeqDes, cAlias, nStaReg)
Local lRet := .T.

If Hs_ExisDic({{"C","GE3_STATUS"}},.F.)
	If !Empty(oGDDesp:aCols[oGDDesp:nAt, nSeqDes])
		DbSelectArea(cAlias)
		DbSetOrder(4) //GE3_FILIAL+GE3_NSEQGD+GE3_STATUS
		If DbSeek(xFilial(cAlias) + oGDDesp:aCols[oGDDesp:nAt, nSeqDes])
			If &(cAlias + "->" + cAlias + "_STATUS") <> "0"
				HS_MsgInf(STR0293,STR0034,STR0149)//"A despesa n„o pode ser excluida. A solicitaÁ„o de autorizaÁ„o j· est· sendo processada."###
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_DbClkGE∫Autor  ≥Rogerio Tabosa      ∫ Data ≥ 11/05/09    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥Funcao para apresentar a tela de legenda para itens         ∫±±
±±∫          ≥em processo de autorizaÁ„o                                  ∫±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_DbClkGE(oGet)

If ValType(oGet:aCols[oGet:nAt, oGet:oBrowse:ColPos]) == "C"
	If "BR_" $ oGet:aCols[oGet:nAt, oGet:oBrowse:ColPos]
		FS_LEGDGE()
 	EndIf
Else
	Return(Nil)
EndIf

Return(Nil)


Static Function FS_LEGDGE()
Local aLegenda := {{"BR_VERDE"   , "Pendente" }, ;
                   {"BR_AMARELO", "Aguardando AutorizaÁ„o"}, ;
                   {"BR_AZUL"   , "Autorizada"},;
                   {"BR_VERMELHO"  , "N„o Autorizada"},;
                   {"BR_PRETO"  , "Cancelado"},;
                   {"BR_LARANJA"  , "Particular"}}

BrwLegenda(STR0294, STR0211, aLegenda) //"AutorizaÁ„o de itens"###"Legenda"
Return(Nil)
/******************************************************************************************************************/

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HSPAHM24  ∫Autor  ≥Microsiga           ∫ Data ≥  08/29/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function FS_LstAgd(nOpcM24,oGDGdd)
  // Agenda ambulatorial, Cirurgica e Doacao
  If cGcyAtendi $ "1/4" .And. aRotina[nOpcM24, 3] == 3 .Or. ; // 3-RecepÁ„o da agenda ambulatorial e Clinicas
     cGcyAtendi == "0" .And. aRotina[nOpcM24, 3] == 3 .Or. ; // 3-RecepÁ„o Cirurgica
     cGcyAtendi == "3" .And. aRotina[nOpcM24, 3] == 3        // 3-Doacao
   If !HS_LstAgd(cM24Par01, dDataBase, IIf(cGcyAtendi == "0", "GMJ", "GM8")) // Busca pacientes agendados.
    Return(.F.)
   EndIf
   oEncGcy:Refresh()
  EndIf
Return(.T.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HSPAHM24  ∫Autor  ≥Microsiga           ∫ Data ≥  08/29/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_GrvM24(nOpcM24, cRegAteOri,oGDGdd   ,aGuiaTiss,nGe3CodDes  ,nGddCodTxd,nGddPerg  ,nGddQtde  ,nTDValTot,nTDTotDsc   ,nTDValDes,nMMSeqDes  ,nMMNumLot,nMMDtVali,nMMValDes ,dDatAte,nGczStatus,nMMProAlt,nGczNrSeqG,NPRCODVIA,nPRINCIDE)
Local lExGcyMat := Hs_ExisDic({{"C","GCY_MATRIC"}},.F.)
Local cProgram   := ""

If aRotina[nOpcM24, 4] == 3 // Incluis„o

	M->GCY_REGATE := HS_VSxeNum("GCY", "M->GCY_REGATE", 1)
	ConfirmSx8()

ElseIf GCY->GCY_REGATE <> M->GCY_REGATE

	DbSelectArea("GCY")
	DbSetOrder(1)
	DbSeek(xFilial("GCY") + M->GCY_REGATE)
EndIf

DbSelectArea("GBH")
DbSetOrder(1) //GBH_FILIAL+GBH_CODPAC
If DbSeek(xFilial("GBH") + M->GCY_REGGER) .And. GBH->GBH_IDPATE <> "1"
	RecLock("GBH", .F.)
	GBH->GBH_IDPATE := "1"
	MsUnlock()
EndIf


DbSelectArea("GCY")
RecLock("GCY", aRotina[nOpcM24, 4] == 3)
HS_GrvCpo("GCY")
GCY->GCY_CODUSU := cUsu
If aRotina[nOpcM24, 4] == 3
	GCY->GCY_DATATE := dDatAte
Endif
If (aRotina[nOpcM24, 4] == 4 .OR. aRotina[nOpcM24, 4] == 3) .AND. lExGcyMat
	GCY->GCY_MATRIC := IIF(cGczCodPla == GD4->GD4_CODPLA,GD4->GD4_MATRIC, "")
EndIf
MsUnLock()

If cGcyAtendi == "3"
	FS_GrvCol(nOpcM24) // Gera Coleta
	If aRotina[nOpcM24, 3] == 13
		FS_GrvDado(M->GCY_REGGER, nOpcM24) //Grava dados do histÛrico
	EndIf
EndIf

If (cGcyAtendi $ "14" .And. aRotina[nOpcM24, 4] == 3) // 3-Agenda Ambulatorial    4 - Clinicas
	If aRotina[nOpcM24, 3] <> 13 //Encaixe
		DbSelectArea("GM8")
		DbSetOrder( IIF(Hs_ExisDic({{"C","GM8_AGDPRC"}},.F.), 12,1) ) //GM8_FILIAL+GM8_AGDPRC
		If DbSeek(xFilial("GM8") + cAgdCodAge)
			If !Empty(GM8->GM8_REGGER) .AND. GM8->GM8_REGGER <> M->GCY_REGGER
				MsgStop("Inconscistencia na recepÁ„o, tente novamente (acionar o suporte)! ") //"N„o existe data de vigÍncia para o plano."
				DisarmTransaction()
				Return(.F.)
			EndIf
			While GM8->(!Eof()) .And. GM8->GM8_FILIAL = xFilial("GM8") .And.;
				IIF(Hs_ExisDic({{"C","GM8_AGDPRC"}},.F.), GM8->GM8_AGDPRC, GM8->GM8_CODAGE) == cAgdCodAge
				RecLock("GM8", .F.)
					GM8->GM8_STATUS := "3" // Atendido
					GM8->GM8_REGATE := M->GCY_REGATE
					GM8->GM8_REGGER := M->GCY_REGGER
				MsUnLock()
				If GM8->( FieldPos('GM8_PROGRA') ) > 0
					cProgram := GM8->GM8_PROGRA
				EndIf

				DbSkip()
			EndDO
		EndIf
	EndIf

ElseIf (cGcyAtendi == "0" .And. aRotina[nOpcM24, 4] == 3) // 3-Agenda Cirurgica
	DbSelectArea("GMJ")
	DbSetOrder(1)
	If DbSeek(xFilial("GMJ") + cAgdCodAge) //GMJ/1
		RecLock("GMJ", .F.)
		GMJ->GMJ_STATUS := "3" // Atendido
		GMJ->GMJ_REGATE := M->GCY_REGATE
		MsUnLock()
	EndIf
Endif

// 4-AlteraÁ„o
// 10-Transferencia de Leito(InternaÁ„o) ou Tranferencia AMB/PA para internaÁ„o
If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3",  aRotina[nOpcM24, 3] <> 7, aRotina[nOpcM24, 3] <> 4))
	If StrZero(aRotina[nOpcM24, 3],2) <> "04"
		FS_GrvGuia(aRotina[nOpcM24, 4] == 3, nOpcM24,@aGuiaTiss,@nGe3CodDes,nTDValTot,@nTDTotDsc,@nTDValDes,@nMMSeqDes,@nMMNumLot,@nMMDtVali,@nMMProAlt,@nMMValDes,@nGczNrSeqG,@nGczStatus,NPRCODVIA,nPRINCIDE)
	EndIf
EndIf

If cGcyAtendi <> "1" .AND. cGcyAtendi <> "4"// Atendimento Ambulatorial
	If (aRotina[nOpcM24, 4] == 3 .OR. aRotina[nOpcM24, 4] == 4) .And. !Empty(M->GCY_CODLOC) .And. !Empty(M->GCY_QUAINT)
		DbSelectArea("GAV")
		DbSetOrder(1)
		If DbSeek(xFilial("GAV") + M->GCY_CODLOC + M->GCY_QUAINT + M->GCY_LEIINT)
			If aRotina[nOpcM24, 4] == 3 .Or. aRotina[nOpcM24, 3] == 4 //Inclusao ou opcao = Alterar
				HS_GrvMovH(M->GCY_REGATE, M->GCY_CODLOC, M->GCY_QUAINT, M->GCY_LEIINT, IIF(aRotina[nOpcM24, 4] == 3,"0","9") , M->GCY_DATATE, M->GCY_HORATE,,,,, .F.)
			EndIf
			If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3",  aRotina[nOpcM24, 3] <> 7, aRotina[nOpcM24, 3] <> 4))
				HS_GTxdFix(M->GCY_CODLOC, M->GCY_REGATE, cGczCodPla, oGDGdd:aCols, nGddPerg, nGddCodTxd, nGddQtde, M->GCY_DATATE)
			Endif
		EndIf
	EndIf
EndIf

If aRotina[nOpcM24, 4] == 3 // Inclus„o
	HS_GEndPro(M->GCY_LOCATE, M->GCY_REGGER, M->cGcyAtendi)
EndIf

If aRotina[nOpcM24, 3] == 10 //transferencia, da alta no atendimento original
	DbSelectArea("GCY")
	DbSetOrder(1)
	DbSeek(xFilial("GCY") + cRegAteOri)
	RecLock("GCY", .F.)
	GCY->GCY_ATEDST := M->GCY_REGATE
	MsUnLock()
	HS_AltM24()
EndIf

If FunName() == "HSPM24AA"
	If GCY->(FieldPos("GCY_SEQSES")) > 0
		DbSelectArea("GCY")
		DbSetOrder(1)
		DbSeek(xFilial("GCY") + M->GCY_REGATE)
		RecLock("GCY", .F.)
		GCY->GCY_SEQSES := HS_RTSQSES(M->GCY_REGATE)
		MsUnLock()
	EndIf
EndIf

If Findfunction('PlsAtuBOQ') .AND. HS_ExisDic({{"T", "BOQ"}}, .F.)
	PlsAtuBOQ(M->GCY_REGGER,cProgram)
Endif
Return(Nil)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_GrvGuia∫ Autor ≥ Jose Orfeu         ∫ Data ≥  18/11/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Grava guias do atendimento                                 ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Administracao Hospitalar                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function FS_GrvGuia(lInclui,nOpcM24,aGuiaTISS,nGe3CodDes,nTDValTot,nTDTotDsc,nTDValDes,nMMSeqDes,nMMNumLot,nMMDtVali,nMMProAlt,nMMValDes,nGczNrSeqG,nGczStatus,NPRCODVIA,nPRINCIDE)
 Local nForGcz := 0, cAliasOld := Alias(), nPosGD := 0, lFound := .F., nPosGPar := 0
 Local aCtrlVias := {}, aIncide := {}, aDespExcec := {{cAliasMM, {}}, {cAliasTD, {}}, {cAliasPR, {}}}, cGa9TipCon := ""
 Local nUGcz := Len(oGDGcz:aHeader) + 1
 Local nPGuia,nForVDes := 0
 Local cCoddes   := " "
 Local aAuxGczGd := {}

 For nForGcz := 1 To Len(oGDGcz:aCols)
  DbSelectArea("GCZ")
  DbSetOrder(1)
  lFound := IIf(!Empty(oGDGcz:aCols[nForGcz, nGczNrSeqG]) .And. !lInclui, DbSeek(xFilial("GCZ") + oGDGcz:aCols[nForGcz, nGczNrSeqG]), .F.)

  If FunName() == "HSPAHP12" .And. lFound .And. oGDGcz:aCols[nForGcz, nGczStatus] > "2"
   Loop
  EndIf

  If !oGDGcz:aCols[nForGcz, nUGCZ]
   If !lFound
    M->GCZ_NRSEQG := HS_VSxeNum("GCZ", "M->GCZ_NRSEQG", 1)
    ConfirmSx8()
   Else
    M->GCZ_NRSEQG := oGDGcz:aCols[nForGcz, nGczNrSeqG]
   EndIf

   nPosGD := aScan(aGczGd, {| aVet | aVet[1] == nForGcz})

	If FunName() == "HSPAHP12"
        nPosVDes := ASCAN(oGDPR:aHeader,{| aVet | aVet[2] == cAliasPR + "_VALDES" })
        nPosCDes := ASCAN(oGDPR:aHeader,{| aVet | aVet[2] == cAliasPR + "_CODDES" })
        nMaxVal  := 0
        For nForVDes := 1 to Len(oGDPR:aCols)
			If oGDPR:aCols[nForVDes,nPosVDes] > nMaxVal .And. !oGDPR:aCols[nForVDes,Len(oGDPR:aHeader) + 1]
			 nMaxVal := oGDPR:aCols[nForVDes,nPosVDes]
			 cCoddes := oGDPR:aCols[nForVDes,nPosCDes]
			EndIf
        Next nForVDes
    Endif

   RecLock("GCZ", !lFound)
    HS_GRVCPO("GCZ", oGDGcz:aCols, oGDGcz:aHeader, nForGcz)
    GCZ->GCZ_FILIAL := xFilial("GCZ")
    GCZ->GCZ_NRSEQG := M->GCZ_NRSEQG
    GCZ->GCZ_REGATE := M->GCY_REGATE
    GCZ->GCZ_REGGER := M->GCY_REGGER
    GCZ->GCZ_NOME   := M->GCY_NOME
    If !(oGDGcz:aCols[oGDGcz:nAt, nGczCodPla] $__cCodAIH)
    GCZ->GCZ_CODDES := cCoddes
    EndIf
    If HS_ExisDic({{"C","GCZ_ALTGUI"}})
     GCZ->GCZ_ALTGUI := IIF(aScan(aGuiaTiss,{|aVet| aVet[1] ==  nForGcz}) > 0,"0","1")
    EndIf

    If (oGDGcz:aCols[nForGcz, nGCZCODPLA] $ __cCodPAC)
     If !Empty(oGDGcz:aCols[oGDGcz:nAt, nGCZNrGuia]) .And. FunName() # "HSPAHP12"
      If HS_CountTB("GCZ", " GCZ_NRGUIA  = '" + oGDGcz:aCols[oGDGcz:nAt, nGCZNrGuia] + "' AND GCZ_NRSEQG <> '"+M->GCZ_NRSEQG+"'") == 0
       GCZ->GCZ_TPAPAC := "1"
      Else
       GCZ->GCZ_TPAPAC := "2"
      EndIf
     EndIf

     If Empty(GCZ->GCZ_VGUIAI) .And. Empty(GCZ->GCZ_VGUIAF)
     GCZ->GCZ_VGUIAI := M->GCY_DATATE
     GCZ->GCZ_VGUIAF := M->GCY_DATATE + nMv_VldGui
    EndIf

    EndIf

    GCZ->GCZ_CODCON := HS_IniPadr("GCM", 2, oGDGcz:aCols[nForGcz, nGCZCODPLA], "GCM_CODCON",,.F.)
    If cAliasMM == "GE5"
     // Se o alias dos Mat/Meds for GE5 significa que a rotina esta sendo chamado da rotina de faturamento
     // portanto grava a guia diretamento no faturamento.
     GCZ->GCZ_STATUS := "2"
    EndIf
    GCZ->GCZ_DATATE := M->GCY_DATATE
    GCZ->GCZ_ATENDI := M->GCY_ATENDI
    GCZ->GCZ_LOCATE := M->GCY_LOCATE
    GCZ->GCZ_CANCEL := "0"
    If !lFound .And. HS_ExisDic({{"C", "GCZ_FILFAT"}})
					GCZ->GCZ_FILFAT := HS_RetFilF(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, GCZ->GCZ_LOCATE, GCZ->GCZ_CODTPG)
     GCZ->GCZ_FILATE := cFilAnt
    EndIf
    GCZ->GCZ_LOGARQ := HS_LogArq()
   MsUnlock()

   If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-InternaÁ„o
    If (cGa9TipCon := HS_RCfgCP(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, "_TIPCON")) == "1" // 1-Particular
     nPosGPar := nPosGD
    EndIf

    HS_GrvMM(cAliasMM, nPosGD, lInclui, nOpcM24, @aDespExcec, cGa9TipCon,,,,nMMSeqDes,nMMNumLot,nMMDtVali,nMMProAlt,nMMValDes)

    aAuxGczGd := aClone(aGczGd)

    HS_GrvGD(cAliasTD, 1    , nPosGD, 3    , oGDTD:aHeader, "M->" + PrefixoCpo(cAliasTD) + "_SEQDES", lInclui,nTDSeqDes          , nTDCodDes, nTDCodLoc,          , @aDespExcec, cGa9TipCon, nTDStaReg ,    ,         ,lInclui, nOpcM24,aGuiaTISS,aAuxGczGd,nGe3CodDes,nPRCodVia,nPRINCIDE)//,nTDValTot,nTDTotDsc,nTDValDes)
    HS_GrvGD(cAliasPR, 1 , nPosGD, 4 , oGDPR:aHeader, "M->" + PrefixoCpo(cAliasPR) + "_SEQDES", lInclui,nPRSeqDes           , nPRCodDes, nPRCodLoc, @aCtrlVias, @aDespExcec, cGa9TipCon, nPRStaReg,       ,@aIncide ,lInclui, nOpcM24,aGuiaTISS,aAuxGczGd,nGe3CodDes,nPRCodVia,nPRINCIDE)//,nTDValTot,nTDTotDsc,nTDValDes)
   EndIf

  Else
   If lFound
    If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-InternaÁ„o
     // Verificar esquema de devoluÁ„o
     FS_DelGD(cAliasTD, 2, GCZ->GCZ_NRSEQG, cPrefiTD + "_NRSEQG == '" + GCZ->GCZ_NRSEQG + "'")
     FS_DelGD(cAliasPR, 2, GCZ->GCZ_NRSEQG, cPrefiPR + "_NRSEQG == '" + GCZ->GCZ_NRSEQG + "'")
    EndIf

    If Type("__aMarkBrow") <> "U"
     If (nPGuia := aScan(__aMarkBrow, {| aVet | aVet[1] == GCZ->GCZ_NRSEQG})) > 0
      aDel(__aMarkBrow, nPGuia)
      aSize(__aMarkBrow, Len(__aMarkBrow) - 1)
     EndIf
    EndIf

    RecLock("GCZ", .F., .F.)
     DbDelete()
    MsUnLock()
    WriteSx2("GCZ")
   Endif
  Endif
 Next

 // Caso tenha despesas que est„o definidas como exceÁ„o para o convenio da guia
 // cria uma nova guia com convenio definido como particular para lanÁar as despesas
 If (Len(aDespExcec[1][2]) > 0 .Or. Len(aDespExcec[2][2]) > 0 .Or. Len(aDespExcec[3][2]) > 0) .And. ;
    (cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt)) // 0-InternaÁ„o
  If nPosGPar > 0 .Or. HS_IGuiaP(M->GCY_REGATE, M->GCY_REGGER, IIf(cAliasMM == "GE5", "2", "0"), M->GCY_ATENDI, M->GCY_DATATE, M->GCY_LOCATE)

   If nPosGPar == 0
    aAdd(aGczGd, {Len(aGczGD)+1, {}, {}, {}, {}, {}, {}})
    nPosGPar := Len(aGczGD)

    aAdd(oGDGcz:aCols, {})

    For nForGcz := 1 to Len(oGDGcz:aHeader)
     If oGDGcz:aHeader[nForGcz, 2] == "HSP_STAREG"
      aAdd(oGDGcz:aCols[len(oGDGcz:aCols)], "BR_VERMELHO")
     Else
      aAdd(oGDGcz:aCols[len(oGDGcz:aCols)], CriaVar(oGDGcz:aHeader[nForGcz, 2]))
     EndIf
    Next
    aAdd(oGDGcz:aCols[len(oGDGcz:aCols)], .F.)

   EndIf

   aGczGd[nPosGPar, 2] := aClone(aDespExcec[1][2]) // Materiais e Medicamentos
   aGczGd[nPosGPar, 3] := aClone(aDespExcec[2][2]) // Taxas e Diarias
   aGczGd[nPosGPar, 4] := aClone(aDespExcec[3][2]) // Procedimentos

   HS_GrvMM(cAliasMM, nPosGPar, lInclui, nOpcM24, @aDespExcec, cGa9TipCon,,,,nMMSeqDes,nMMNumLot,nMMProAlt,nMMProAlt,nMMValDes)


   HS_GrvGD(cAliasTD, 1, nPosGPar, 3, oGDTD:aHeader, "M->" + PrefixoCpo(cAliasTD) + "_SEQDES", lInclui,          , nTDCodDes, nTDCodLoc,,,, nTDStaReg)
   HS_GrvGD(cAliasPR, 1, nPosGPar, 4, oGDPR:aHeader, "M->" + PrefixoCpo(cAliasPR) + "_SEQDES", lInclui, nPRCodDes, nPRCodLoc, @aCtrlVias,,, nPrStaReg, ,@aIncide)
  EndIf
 EndIf

 If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-InternaÁ„o
  HS_CalcVias(aCtrlVias, cAliasPR, {1, IIf(cAliasPr == "GD7", 5, 7)}, .T., aIncide) // Efetua calculo de vias
 EndIf

 If FindFunction('Hs_MsgM24') .And. cGcyAtendi == "0"
  HS_MsgM24(M->GCY_REGATE, aGczGD, cAliasPR, cAliasMM)
 EndIf

 //Funcao para efetuar o calculo da taxa/servico para despesas de material e taxa/diaria
 If FunName() == "HSPAHP12"
  FS_ClTxSrv(cAliasTD, M->GCY_REGATE)
 EndIf

 DbSelectArea(cAliasOld)
Return(Nil)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HSPAHM24  ∫Autor  ≥Microsiga           ∫ Data ≥  08/30/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function HS_GrvGD(cAlias , nOrdem, nPosGD, nDesp, aHGD , cCpoCh , lInclui, nGDSeqDes, nGDCodDes, nGDCodLoc, aCtrlVias, aDespExcec, cGa9TipCon, nGDStaReg, aCGd, aIncide,lInclui, nOpcM24,aGuiaTISS,aAuxGczGd,nGe3CodDes,nPRCodVia,nPRINCIDE)
Local nForGD := 0, lFound := .F., aRValDes := {}, aRCrdMed := {}, cSPrinc := "", cAtPrinc := "XXXXXX", nPSeqDes := 0
Local cPArq :=  cAlias + "->" + PrefixoCpo(cAlias), cCodLoc := "", nLSPrinc := 0
Local aRAtoMed  := {}, nPosVias := 0, nUGD := Len(aHGD) + 1
Local aTabPre   := {}, nIncidProc := 0, cCodDes := "", dDatDes := Nil
Local nQtDigInc := 0 , cSTmpPrinc := "", lNExGnx := .F., cCdGNX := ""
Local cAliasOld := "", nPMedi := 0, nPProc := 0, cTipAto := ""
Local lRepCDsc  := IIF(HS_VldSx6({{"MV_REPCDSC",{"L","T/F","$"}}},.F.),GetMv("MV_REPCDSC"),.F.) //Repasse com Desconto
Local aAVldVig := HS_AVldVig("TD")[1]
Local aTDExAih	:= {}
Local lExTDEAIH := HS_ExisDic({{"C", cAliasPR+"_TDEAIH"}},.F.)
Local nApoio	:= 0
Local cAnest	:= ""
Local lAnest	:= .F.

If cAlias == cAliasPR
	nLSPrinc := HS_CfgSx3(oGDPR:aHeader[nPRSPrinc, 2])[SX3->(FieldPos("X3_TAMANHO"))]
EndIf

Default aCGd := aClone(aGczGD[nPosGD, nDesp])

For nForGD := 1 To Len(aCGd)
	If aCGD[nForGD, nGDStaReg] <> "BR_VERDE" .And. !Empty(aCGd[nForGD, nGDCodDes])
		DbSelectArea(cAlias)
		DbSetOrder(nOrdem)
		lFound := IIf(!Empty(aCGd[nForGd, nGdSeqDes]) .And. !lInclui, DbSeek(xFilial(cAlias) + aCGd[nForGd, nGdSeqDes]), .F.)

		If !(cAlias $ "GE2/GE3/GE8")
			If lFound
				cCodLoc := IIf(nGDCodLoc > 0 .And. !Empty(aCGd[nForGD, nGDCodLoc]), aCGd[nForGD, nGDCodLoc], &(cPArq + "_CODLOC"))
			Else
				cCodLoc := IIf(nGDCodLoc > 0 .And. !Empty(aCGd[nForGD, nGDCodLoc]), aCGd[nForGD, nGDCodLoc], cLctCodLoc)
			EndIf
		EndIf

		If !aCGd[nForGD, nUGD]
			If     cAlias == cAliasTD
				aRValDes := HS_RValTD(aCGd[nForGD, nGDCodDes], GCZ->GCZ_CODPLA, cCodLoc,, aCGd[nForGD, nTDDatDes], ,HS_RetCrm(aCGd, nForGD, nTDCodCrm, M->GCY_CODCRM), aCGd[nForGD, nTDHorDes], {cGcyAtendi, M->GCY_CARATE})
			ElseIf cAlias == cAliasPR
				If aCGd[nForGD, nPROriDes] == "2" // 2-Incidencia
					//Procurar o procedimento que gerou a incidÍncia
					cSTmpPrinc := IIf(!Empty(aCGd[nForGD, nPRSPrinc]), aCGd[nForGD, nPRSPrinc], StrZero(aCGd[nForGD, aHGD[nPRSPrinc, 4]]))
					If (nPIncide := aScan(aCGd, {| aVet | aVet[nPRSPrinc] == cSTmpPrinc .And. aVet[nPROriDes] <> "2"})) <> 0

						cCodDes   := aCGd[nPIncide, nGDCodDes]
						dDatDes   := IIf(nPRDatDes > 0 .And. !Empty(aCGd[nPIncide, nTDDatDes]), aCGd[nPIncide, nTDDatDes], dDataBase)
						nQtDigInc := IIf(nPrIncide > 0 .And. !Empty(aCGd[nPIncide, nPrIncide]), aCGd[nPIncide, nPrIncide], 0)

						aTabPre    := HS_RTabPre("GC6", GCZ->GCZ_CODPLA, cCodDes, dDatDes)
						nIncidProc := HS_IniPadr("GA7", 1, cCodDes, "GA7_INCIDE",,.F.)

						DbSelectArea("GAU")
						DbSetOrder(2)
						DbSeek(xFilial("GAU") + aTabPre[1] + GA7->GA7_CODGPP)

						aRValDes := HS_RValPr(aCGd[nForGD, nGDCodDes], GCZ->GCZ_CODPLA, cCodLoc, aCGd[nForGD, nPRHorDes], aCGd[nForGD, nPRUrgDes], aCGd[nForGD, nPRCodCrm], aCGd[nForGD, nPRCODATO], {cGcyAtendi, M->GCY_ATORIG, M->GCY_IDADE, M->GCY_SEXO, M->GCY_CARATE},, aCGd[nForGD, nPRDatDes], {GAU->GAU_FORVAL, cCodDes, nQtDigInc, nIncidProc})

						cSTmpPrinc := ""

					EndIf

				Else // Nao eh incidencia
					aRValDes := HS_RValPr(aCGd[nForGD, nGDCodDes], GCZ->GCZ_CODPLA, cCodLoc, aCGd[nForGD, nPRHorDes], aCGd[nForGD, nPRUrgDes], aCGd[nForGD, nPRCodCrm], aCGd[nForGD, nPRCODATO], {cGcyAtendi, M->GCY_ATORIG, M->GCY_IDADE, M->GCY_SEXO, M->GCY_CARATE},, aCGd[nForGD, nPRDatDes])
				EndIf
			EndIf

			// Para permitir a gravaÁ„o do valor da despesa digitado pelo usu·rio
			If     cAlias == "GE7" .Or. (FunName() == "HSPAHP12" .And. cAlias == "GD7")
				If nPRValDes > 0
					aRValDes[2][1][1] := aCGd[nForGD, nPRValDes]
				EndIf

				If nPRVFilme > 0
					aRValDes[2][3]    := aCGd[nForGD, nPRVFilme]
				EndIf

				If nPRPgtMed > 0
					aRValDes[9][1]    := aCGd[nForGD, nPRPgtMed]
				EndIf
			ElseIf cAlias == "GE6" .And. nTDValDes > 0
				aRValDes[2] := aCGd[nForGD, nTDValDes]
			EndIf

			//( Se for Taxa/Diaria ou Procedimento ) o Tipo do Convenio for 0-Convenio a despesa for uma exceÁ„o e fatura para particular
			// Armazena matriz para lanÁar na guia de despesas particulares.
			If (cAlias == cAliasTD .Or. cAlias == cAliasPR) .And. cGa9TipCon == "0" .And. aRValDes[4][1] .And. aRValDes[4][2] == "1"
				aAdd(aDespExcec[IIf(cAlias == cAliasTD, 2, 3)][2], aClone(aCGd[nForGD]))
				Loop
			EndIf

			If !lFound
				&(cCpoCh) := HS_VSxeNum(cAlias, cCpoCh, nOrdem)
				ConfirmSx8()
			Else
				&(cCpoCh) := aCGd[nForGd, nGdSeqDes]
			EndIf

			If cAlias == cAliasPR // Se for procedimento grava matriz para calculo de vias de acesso
				cTipAto := HS_RAtoMed(1, aCGd[nForGD, nPRCodAto] + "1", .T.)[3]
				If aRValDes[13] .And. !Empty(aCGd[nForGD, nPRCodVia])
					If (nPosVias := aScan(aCtrlVias, {| aVet | aVet[1] == aCGd[nForGD, nPRDatDes] .And. aVet[2] == aCGd[nForGD, nPRCodCrm]})) == 0
						aAdd(aCtrlVias, {aCGd[nForGD, nPRDatDes], aCGd[nForGD, nPRCodCrm], {}})
						nPosVias := Len(aCtrlVias)
					EndIf
					aAdd(aCtrlVias[nPosVias][3], {aRValDes[2][1][1] + aRValDes[2][2], aCGd[nForGD, nPRCodVia], &(cCpoCh), 0, 0, aCGd[nForGD][nPRSPrinc], aCGd[nForGD][nPRCodDes]})
				ElseIf cTipAto == "5"
					If (nPMedi := aScan(aCtrlVias, {| aVet1 | (nPProc := aScan(aVet1[3], {| aVet2 |  aVet2[6] == aCGd[nForGD][nPRSPrinc]})) > 0})) > 0
						aCtrlVias[nPMedi][3][nPProc][5] := aRValDes[2][1][1] + aRValDes[2][2]
					EndIf
				EndIf
			EndIf

			If cAlias $ "GD5/GD7" .AND. FUNNAME() <> "HSPAHP12" .AND. HS_ExisDic({{"T", "GNX"}}, .F.)
				FS_CrAuto(cAlias, GCZ->GCZ_CODPLA, aCGd[nForGD, nGDCodDes],&(cCpoCh),IIf(cAlias == "GD5","3","4"),aCGd[nForGD, IIf(cAlias == "GD5",nMMQtdDES,nPRQTDDES)],lFound,GCZ->GCZ_NRSEQG) // Controle de autorizacoes
			EndIf
			RecLock(cAlias, !lFound)
			HS_GRVCPO(cAlias, aCGd, aHGD, nForGD)
			&(cPArq + "_FILIAL") := xFilial(cAlias)
			&(cPArq + "_SEQDES") := &(cCpoCh)
			&(cPArq + "_NRSEQG") := GCZ->GCZ_NRSEQG
			&(cPArq + "_REGATE") := GCZ->GCZ_REGATE

			If cAlias $ "GD6/GD7"
				&(cPArq + "_FATPAR") := aRValDes[4][2]
			ElseIf cAlias == "GE7"
				&(cPArq + "_CODCON") := GCZ->GCZ_CODCON
			EndIf

			If !(cAlias $ "GE2/GE3/GE8")
				&(cPArq + "_CODLOC") := cCodLoc
				&(cPArq + "_VALDES") := IIf(cAlias == cAliasPR, aRValDes[2][1][1], aRValDes[2])
				&(cPArq + "_PCUDES") := aRValDes[3]
				&(cPArq + "_GLODES") := IIf(aRValDes[4][1], "2", "0")
				&(cPArq + "_LOGARQ") := HS_LogArq()
			EndIf

			If     cAlias == cAliasTD // Taxas e Diarias
				&(cPArq + "_PGTMED") := aRValDes[10][01]
				&(cPArq + "_REPAMB") := aRValDes[10][aRValDes[12]]
				&(cPArq + "_VALREP") := aCGd[nForGD, nTDQtdDes] * aRValDes[10][05]
				&(cPArq + "_CODPRE") := aRValDes[11]

				If HS_ExisDic({{"C", cAliasTD + "_VALREB"}}, .F.)
					&(cPArq + "_VALREB") := aCGd[nForGD, nTDQtdDes] * aRValDes[10][05]

					If nTDTotDsc > 0 .And. nTDValTot > 0
						&(cPArq + "_VALREP") := (aCGd[nForGD, nTDQtdDes] * aRValDes[10][05]) * IIF(lRepCDsc, (aCGd[nForGD, nTDTotDsc] / aCGd[nForGD, nTDValTot]), 1)
					EndIf

				EndIf

			ElseIf cAlias == cAliasPR // Procedimentos
				cAnest := Posicione("GMC",1,xFilial("GMC")+aCGd[nForGD,nPRCODATO]+'1',"GMC_TIPATM")
				If cAnest == '5'
					lAnest := .T.
				EndIf
				If aCGd[nForGD, nPRCODDES] == GCZ->GCZ_CODDES .Or. lAnest
					If Empty(aCGd[nForGD, nPRSeqDes])
						If aCGd[nForGD, nPRSPrinc] == StrZero(nForGD, nLSPrinc) .Or. (Soma1(aCGd[nForGD, nPRSPrinc]) == StrZero(nForGD, nLSPrinc) .AND. nApoio == 0)
							nApoio ++
							cSPrinc  := &(cCpoCh)
							cAtPrinc := aCGd[nForGD, nPRSPrinc]
							&(cPrefiPR + "_SPRINC") := cSPrinc
						ElseIf aCGd[nForGD, nPRSPrinc] == cAtPrinc
							&(cPrefiPR + "_SPRINC") := cSPrinc
						EndIf
					EndIf
				EndIf

				If aRValdes[16][02] <> 1 .And. ValType(aIncide) # "U"
					Aadd(aIncide,{ &(cCpoCh)  ,aRValdes[16][02]})
				Endif
				If IsInCallStack("HSPAHAIH") .AND. !Empty(&(cPrefiPR + "_CODCRM")) .AND. lExTDEAIH
					If Empty(&(cPrefiPR + "_TDEAIH"))
						aTDExAih := HS_TDEXAIH(&(cPrefiPR + "_CODCRM"))
						&(cPrefiPR + "_TDEAIH") := aTDExAih[1]
						&(cPrefiPR + "_DDEAIH") := aTDExAih[2]
					EndIf
				EndIf
				&(cPrefiPR + "_CODPRE") := aRValDes[14]
				&(cPrefiPR + "_COEFAM") := aRValDes[2][1][2]
				&(cPrefiPR + "_COEDES") := IIf(nPRCoeDes > 0, aCGd[nForGD, nPRCoeDes], aRValDes[16][02])
				&(cPrefiPR + "_URGDES") := aRValDes[2][14]
				&(cPrefiPR + "_COECHP") := aRValDes[2][10]
				&(cPrefiPR + "_QTDCHP") := aRValDes[2][11]
				If !Empty(aRValDes[2][18]) .AND. !Empty(aRValDes[2][15])
					&(cPrefiPR + "_CODPRT") := aRValDes[2][15]
					&(cPrefiPR + "_DESPRT") := aRValDes[2][18]
				EndIf
				&(cPrefiPR + "_VLRCOS") := aRValDes[2][24]
				&(cPrefiPR + "_PGTMED") := aRValDes[9][1]
				&(cPrefiPR + "_COECHM") := aRValDes[9][aRValDes[11]]
				&(cPrefiPR + "_REPAMB") := aRValDes[9][aRValDes[10]]

				If cMV_AteSus == "S" // Se atende SUS
					If GCZ->GCZ_CODPLA == __cCodBPA // Se atende SUS e o tipo de plano eh BPA

						If Empty(&(cPrefiPR + "_CDGATE"))
							&(cPrefiPR + "_CDGATE") := aRValDes[15][2][1]
						EndIf
						If Empty(&(cPrefiPR + "_CDTATE"))
							&(cPrefiPR + "_CDTATE") := aRValDes[15][3][1]
						EndIf
					EndIf
					If GCZ->GCZ_CODPLA == __cCodBPA .Or. GCZ->GCZ_CODPLA $ __cCodPAC  // Se atende SUS e eh BPA ou APAC
						//					If Empty(&(cPrefiPR + "_CODCID"))
						//						&(cPrefiPR + "_CODCID") := aRValDes[15][4][1]
						//					EndIf
					EndIf
				EndIf

				If !Empty( &(cPrefiPR + "_SPRINC"))
					aScan(aCtrlVias, {| aVet1 | (nPSeqDes := aScan(aVet1[3], {| aVet2 |  aVet2[6] ==   &(cPrefiPR + "_SPRINC")}))})
				Else
					aScan(aCtrlVias, {| aVet1 | (nPSeqDes := aScan(aVet1[3], {| aVet2 |  aVet2[3] ==  &(cCpoCh)}))})
				Endif

				If HS_ExisDic({{"C", cAliasPR + "_VALREB"}}, .F.) .And. nPRTotDsc > 0 .And. nPRValTot > 0
					&(cPrefiPR + "_VALREB") :=  (aRValDes[9][14] * IIf(nPSeqDes > 0, 1, aRValDes[16][02])) * aCGd[nForGD, nPRQtdDes]
					&(cPrefiPR + "_VALREP") :=  ((aRValDes[9][14] * IIf(nPSeqDes > 0, 1, aRValDes[16][02])) * aCGd[nForGD, nPRQtdDes]) * IIF(lRepCDsc,(aCGd[nForGD, nPRTotDsc] / aCGd[nForGD, nPRValTot]),1)
				Else
					&(cPrefiPR + "_VALREP") := (aRValDes[9][14] * IIf(nPSeqDes > 0, 1, aRValDes[16][02])) * aCGd[nForGD, nPRQtdDes]
				EndIf

				If HS_ExisDic({{"C", cAliasPR + "_VLREPF"}})
					&(cPrefiPR + "_VLREPF") := aCGd[nForGD, nPRQtdDes] * aRValDes[9][17]
				EndIf

				&(cPrefiPR + "_VCUSOP") := aRValDes[2][2]
				&(cPrefiPR + "_VFILME") := aRValDes[2][3]
			EndIf
			MsUnlock()


			If cAlias == cAliasPR .And. nPRSLaudo > 0

				If aCGd[nForGD, nPRSLaudo] == "1" // 1-Sim p/ Solicitacao de Laudo
					HS_GSLaudo(GCZ->GCZ_REGATE, GCY->GCY_NOME, aCGd[nForGD, nGDCodDes], IIF(Empty(GCZ->GCZ_CODCRM),aCGd[nForGD, nPRCodCrm],GCZ->GCZ_CODCRM), aCGd[nForGD, nPRCrmLau], cCodLoc, &(cCpoCh), aCGd[nForGD, nPRDatDes])
				Else // Nao p/ SolicitaÁ„o do Laudo
					cAliasOld := Alias()
					DbSelectArea("GBY")
					DbSetOrder(4)
					If DbSeek(xFilial("GBY") + &(cCpoCh))
						RecLock("GBY", .F., .F.)
						DbDelete()
						MsUnlock()
						WriteSx2("GBY")
					EndIf
					DbSelectArea(cAliasOld)
				EndIf

			EndIf
		Else
			If lFound

				If cAlias == cAliasPR .And. nPRSLaudo > 0 //Apaga as solicitacoes de laudo..
					cAliasOld := Alias()
					DbSelectArea("GBY")
					DbSetOrder(4)
					If DbSeek(xFilial("GBY") + aCGd[nForGd, nGdSeqDes])
						RecLock("GBY", .F., .F.)
						DbDelete()
						MsUnlock()
						WriteSx2("GBY")
					EndIf
					DbSelectArea(cAliasOld)
				EndIf

				If Hs_ExisDic({{"C","GE3_STATUS"}},.F.)
					If cAlias == cAliasPR //Apaga as solicitacoes de autorizaÁ„o (GE)
						cAliasOld := Alias()
						DbSelectArea("GE3")
						DbSetOrder(4)
						If DbSeek(xFilial("GE3") + aCGd[nForGd, nGdSeqDes])
							cCdGnx := GE3->GE3_CODSOL
							RecLock("GE3", .F., .F.)
							DbDelete()
							MsUnlock()
							WriteSx2("GE3")
						EndIf
						DbSelectArea(cAliasOld)
					EndIf
					If cAlias == "GD5" .OR. cAlias == "GE5"   //Apaga as solicitacoes de autorizaÁ„o (GE)
						cAliasOld := Alias()
						DbSelectArea("GE2")
						DbSetOrder(4)
						If DbSeek(xFilial("GE2") + aCGd[nForGd, nGdSeqDes])
							cCdGnx := GE3->GE3_CODSOL
							RecLock("GE2", .F., .F.)
							DbDelete()
							MsUnlock()
							WriteSx2("GE2")
						EndIf
						DbSelectArea(cAliasOld)
					EndIf
					If !Empty(cCdGnx)
						cAliasOld := Alias()
						DbSelectArea("GE3")
						DbSetOrder(3)
						If !DbSeek(xFilial("GE3") + cCdGnx)
							lNExGnx := .T.
						Else
							lNExGnx := .F.
						EndIf
						DbSelectArea("GE2")
						DbSetOrder(3)
						If !DbSeek(xFilial("GE2") + cCdGnx)
							lNExGnx := .T.
						Else
							lNExGnx := .F.
						EndIf
						If lNExGnx // Verifica se apos a delecao do item da GE3 se era o unico existente deleta tb o cabecalho na GNX
							DbSelectArea("GNX")
							DbSetOrder(1)
							If DbSeek(xFilial("GNX") + cCdGnx)
								RecLock("GNX", .F., .F.)
								DbDelete()
								MsUnlock()
								WriteSx2("GNX")
							EndIf
						EndIf
						DbSelectArea(cAliasOld)
					EndIf
				EndIf
				RecLock(cAlias, .F., .F.)
				DbDelete()
				MsUnLock()
				WriteSx2(cAlias)
				/**** Processo para gravar o codigo do procedimento principal, apos a gravacao do banco ***/
				If FUNNAME() $ "HSPM24"
					cWhere := cAlias + "_NRSEQG ='" + GCZ->GCZ_NRSEQG + "'"
					cCoddes := FS_Max(cAlias + "_VALDES", cAlias , cWhere, cAlias + "_CODDES", cAlias + "_CODDES", "MAXCPO DESC") 	// Regra para trazer o codigo do procedimento de maior valor da guia
					DbSelectArea("GCZ")
					RecLock("GCZ",.F.)
					GCZ->GCZ_CODDES := cCoddes
					MsUnlock()
				Endif
			EndIf
		EndIf
	Endif
Next
Return(Nil)


Static Function FS_DelGD(cAlias, nOrdem, cChave, cCond)
 cCond := StrTran(cCond, cAlias + "->", "")
 cCond := StrTran(cCond, "==", "=")
 cCond := StrTran(cCond, ".", "")
 TCSQLExec("UPDATE " + RetSqlName(cAlias) + " SET D_E_L_E_T_ = '*' WHERE " + PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial(cAlias) + "' AND " + cCond)
Return(Nil)

Function HS_GrvMM(cAlias, nPosGd, lInclui, nOpcM24, aDespExcec, cGa9TipCon, aCDesp, lVldDev, aHeader,nMMSeqDes,nMMNumLot,nMMDtVali,nMMProAlt,nMMValDes)

 Local nForMM := 0, lFound := .F., aRValDes := {}, cCodLoc := ""
 Local nQtdSol := 0, nQtdDev := 0, cCodDev := "", aIDevSet := {}, aIDevFar := {}
 Local nUMM := 0
 Local aIteSol := {}
 Local lVldMM  := .T.
 Local lM24    := IIF(ValType(lVldDev)# "U", lVldDev, .T.)
 Local cMovest   := UPPER(GetMv("MV_AUDMEST"))
 Default aCDesp := aClone(aGczGD[nPosGD, 2])

 If Len(aCDesp) > 0
 	nUMM := Len(aCDesp[1])
 EndIf

 For nForMM := 1 To Len(aCDesp)

  If aCDesp[nForMM, nMMStaReg] <> "BR_VERDE" .And. !Empty(aCDesp[nForMM, nMMCodDes])
   DbSelectArea(cAlias)
   DbSetOrder(1)
   lFound := IIf(!Empty(aCDesp[nForMM, nMMSeqDes]) .And. !lInclui, DbSeek(xFilial(cAlias) + aCDesp[nForMM, nMMSeqDes]), .F.)
   lVldMM := IIF(lM24, IIf(aRotina[nOpcM24, 3] == 7 .And. nMMQDevol > 0, aCDesp[nForMM, nMMQDevol] == 0, .T.), .T.)

   If !(cAlias $ "GE2/GE3/GE8")
    If lFound
     cCodLoc := IIf(nMMCodLoc > 0 .And. !Empty(aCDesp[nForMM, nMMCodLoc]), aCDesp[nForMM, nMMCodLoc], &(cPrefiMM + "_CODLOC"))
    Else
     cCodLoc := IIf(nMMCodLoc > 0 .And. !Empty(aCDesp[nForMM, nMMCodLoc]), aCDesp[nForMM, nMMCodLoc], cLctCodLoc)
    EndIf
   EndIf

   If lVldMM .And. !aCDesp[nForMM, nUMM]
    aRValDes := HS_RValMM(GCZ->GCZ_CODPLA, aCDesp[nForMM, nMMCodDes], cGcsArmSet,, aCDesp[nForMM, nMMDatDes],,aCDesp[nForMM, nMMCodCrm], cCodLoc, aCDesp[nForMM, nMMHorDes],{cGcyAtendi, M->GCY_CARATE})

    // Para permitir a gravaÁ„o do valor da despesa digitado pelo usu·rio
    If cAliasMM == "GE5"
     aRValDes[2] := aCDesp[nForMM, nMMValDes]
    EndIf

    //Se o Tipo do Convenio for 0-Convenio e a despesa for uma exceÁ„o e fatura particular
    // Armazena matriz para lanÁar na guia de despesas particulares.
    If cGa9TipCon == "0" .And. aRValDes[4][1] .And. aRValDes[4][2] == "1"
     aAdd(aDespExcec[1][2], aClone(aCDesp[nForMM]))
     Loop
    EndIf

    nQtdSol := FS_MovEst(cAlias, aCDesp, nForMM, aRValDes, lFound, aHeader,nMMNumLot,nMMLoteCt,nMMDtVali,nMMProAlt)

    If nQtdSol > 0 .And. !lFound
     aAdd(aIteSol, {nForMM, nQtdSol})
    EndIf
   Else
    If lFound
     nQtdDev := IIf(nMMQDevol == 0 .Or. aCDesp[nForMM, nMMQDevol] == 0, aCDesp[nForMM, nMMQtdDes], aCDesp[nForMM, nMMQDevol])
     cCodDev := IIf(!Empty(aCDesp[nForMM, nMMProAlt]), aCDesp[nForMM, nMMProAlt], aCDesp[nForMM, nMMCodDes])

     If cAliasMM == "GE5" .Or. Empty(&(cPrefiMM + "_SOLICI"))
      RecLock(cAlias, .F., .F.)
       If nQtdDev == &(cPrefiMM + "_QTDDES") .Or. aCDesp[nForMM,Len(aCDesp[nForMM])]
        DbDelete()
      	Else
        &(cPrefiMM + "_QTDDES") -= nQtdDev
	      EndIf
       MsUnLock()
       aAdd(aIDevSet, {nForMM, nQtdDev, cCodDev, "", "",aCDesp[nForMM][nMMCodLoc]})
     Else
       aAdd(aIDevFar, {nForMM, nQtdDev, cCodDev, &(cPrefiMM + "_SOLICI"), &(cPrefiMM + "_ITESOL")})
     EndIf
    Endif
   EndIf
	If cAliasMM == "GD5" .AND. !lFound .AND. HS_ExisDic({{"T", "GNX"}}, .F.)// Controle de Autorizacoes
		FS_CrAuto(cAliasMM, GCZ->GCZ_CODPLA, aCDesp[nForMM, nMMCodDes],,IIf(cAlias == "GD5","3","4"),aCDesp[nForMM, nMMQtdDes],lFound,GCZ->GCZ_NRSEQG) // Controle de autorizacoes
	EndIf
  EndIf
 Next

 If cAliasMM == "GD5" .And. Len(aIteSol) > 0
  FS_IncSol(aCDesp, aIteSol,nMMProAlt )
 EndIf

 If cAliasMM == "GD5" .And. Len(aIDevSet) > 0 .Or. Len(aIDevFar) > 0
 	If FunName() == "HSPAHP12" .and. cMovest == "N"
    	Return(nil)
 	Else
  FS_IncDev(aCDesp, {aIDevSet, aIDevFar})
 	EndIf
 EndIf
Return(Nil)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HSPAHM24  ∫Autor  ≥Microsiga           ∫ Data ≥  08/29/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function FS_MovEst(cAlias, aCDesp, nForMM, aRValDes, lFound, aHeader,nMMNumLot,nMMLoteCt,nMMDtVali,nMMProAlt)

 Local aArea     := GetArea(), aConEst := {}
 Local nLcto     := 0, aMovEst := {}
 Local aQtdLcto  := {}, nQtdLcto := 0, cCodLoc := ""
 Local nTQtdLcto := aCDesp[nForMM, nMMQtdDes]
 Local cCodDes   := IIf(!Empty(aCDesp[nForMM, nMMProAlt]), aCDesp[nForMM, nMMProAlt], aCDesp[nForMM, nMMCodDes])
 Local cMovest   := UPPER(GetMv("MV_AUDMEST"))
 Local lMovEst   := .F.
 Local cEstNeg   := GETMV("MV_ESTNEG")
 Local aAVldVig  := HS_AVldVig("MM")[1]
 Local lRepCDsc  := IIF(HS_VldSx6({{"MV_REPCDSC",{"L","T/F","$"}}},.F.),GetMv("MV_REPCDSC"),.F.) //Repasse com Desconto

 Default aHeader := oGDMM:aHeader

 lMovEst := (aConEst := HS_CONEST(cCodDes, HS_RetSet(cAliasMM, nMMSeqDes, nMMCodLoc, cLctCodLoc, nForMM, aCDesp,lFound))[1]) .And. ;
             IIf(FunName() == "HSPAHP12", cMovest == "S", .T.) // Validacao da movimentacao do estoque para auditoria

 If !lFound .And. cAlias == "GD5" .And. lMovEst
  If Rastro(cCodDes)
   DbSelectArea("SB8")
   DbSetOrder(1)
   DbSeek(xFilial("SB8") + PadR(AllTrim(cCodDes), Len(SB8->B8_PRODUTO)) + cGcsArmSet + DToS(dDataBase), .T.)
   If Empty(aCDesp[nForMM, nMMNumLot]) .And. Empty(aCDesp[nForMM, nMMLoteCt])
    While !Eof() .And. SB8->B8_FILIAL  == xFilial("SB8") .And. ;
                       SB8->B8_PRODUTO == PadR(AllTrim(cCodDes), Len(SB8->B8_PRODUTO)) .And. ;
                       SB8->B8_LOCAL   == cGcsArmSet .And. ;
                       SB8->B8_DTVALID >= dDataBase .And. nTQtdLcto > 0
     If SB8->B8_SALDO > 0
      nQtdLcto  := SB8->B8_SALDO
      nQtdLcto  := IIf(nQtdLcto >= nTQtdLcto, nTQtdLcto, nQtdLcto)
      nTQtdLcto -= nQtdLcto
      aAdd(aQtdLcto, {nQtdLcto, SB8->B8_LOTEFOR, SB8->B8_NUMLOTE, SB8->B8_LOTECTL, SB8->B8_DTVALID})
     EndIf

     DbSkip()
    End
   Else
    nQtdLcto  := SB8->B8_SALDO
    nQtdLcto  := IIf(nQtdLcto >= nTQtdLcto, nTQtdLcto, nQtdLcto)
    nTQtdLcto -= nQtdLcto
    aAdd(aQtdLcto, {nQtdLcto, SB8->B8_LOTEFOR, SB8->B8_NUMLOTE, SB8->B8_LOTECTL, SB8->B8_DTVALID})
   EndIf
  Else
   If nTQtdLcto > aRValDes[7][4] .And. aRValDes[7][4] > 0 .AND. cEstNeg <> "S"// Qtd. Lcto > que o Saldo do produto no armazem do posto e o saldo > que zero
    nQtdLcto  := aRValDes[7][4]
    nTQtdLcto -= nQtdLcto
    aAdd(aQtdLcto, {nQtdLcto, "", "", "", CToD("")})
   ElseIf nTQtdLcto > aRValDes[7][4] .And. aRValDes[7][4] <= 0 .AND. cEstNeg <> "S"// Qtd. Lcto > que o Saldo do produto no armazem do posto e o saldo < OU = a zero
    aQtdLcto := {}
   Else
    aAdd(aQtdLcto, {nTQtdLcto, "", "", "", CToD("")})
    nTQtdLcto := 0
   EndIf
  EndIf
 Else
  aAdd(aQtdLcto, {nTQtdLcto, "", "", "", CToD("")})
  nTQtdLcto := 0
 EndIf

 // Movimenta estoque
 For nLcto := 1 To Len(aQtdLcto)
  If !lFound .And. cAlias == "GD5" .And. lMovEst
   aMovEst := HS_MovEst("S", cCodDes, aQtdLcto[nLcto, 1], cGcsArmSet, cUserName, cGcsCodCCu, , aQtdLcto[nLcto, 3], aQtdLcto[nLcto, 4], aQtdLcto[nLcto, 5],,,, GCZ->GCZ_REGATE)
  Else
   aMovEst := {.T., &(cPrefiMM + "_NUMSEQ")}
  EndIf

  If lFound
   cCodLoc := IIf(nMMCodLoc > 0 .And. !Empty(aCDesp[nForMM, nMMCodLoc]), aCDesp[nForMM, nMMCodLoc], &(cPrefiMM + "_CODLOC"))
  Else
   cCodLoc := IIf(nMMCodLoc > 0 .And. !Empty(aCDesp[nForMM, nMMCodLoc]), aCDesp[nForMM, nMMCodLoc], cLctCodLoc)
  EndIf

  If aMovEst[1]
   If !lFound
    &("M->" + PrefixoCpo(cAliasMM) + "_SEQDES") := HS_VSxeNum(cAliasMM, "M->" + PrefixoCpo(cAliasMM) + "_SEQDES", 1)
    ConfirmSx8()
   Else
    &("M->" + PrefixoCpo(cAliasMM) + "_SEQDES") := aCDesp[nForMM, nMMSeqDes]
   EndIf

   RecLock(cAlias, !lFound)
    HS_GRVCPO(cAlias, aCDesp, aHeader, nForMM)
    &(cPrefiMM + "_FILIAL") := xFilial(cAlias)
    &(cPrefiMM + "_QTDDES") := aQtdLcto[nLcto, 1]
    &(cPrefiMM + "_VALDES") := aRValDes[2]
    &(cPrefiMM + "_PCUDES") := aRValDes[3]
    &(cPrefiMM + "_GLODES") := IIf(aRValDes[4][1], "2", "0")
    &(cPrefiMM + "_LOGARQ") := HS_LogArq()
    &(cPrefiMM + "_CODLOC") := cCodLoc

    &(cPrefiMM + "_PGTMED") := aRValDes[13][01]
    &(cPrefiMM + "_REPAMB") := aRValDes[13][aRValDes[15]]
    &(cPrefiMM + "_VALREP") := aCDesp[nForMM, nMMQtdDes] * aRValDes[13][05]

    If HS_ExisDic({{"C", cAliasMM + "_VALREB"}}, .F.)
     &(cPrefiMM + "_VALREB") := aCDesp[nForMM, nMMQtdDes] * aRValDes[13][05]
     If nMMTotDsc > 0 .And. nMMValTot > 0
      &(cPrefiMM + "_VALREP") := (aCDesp[nForMM, nMMQtdDes] * aRValDes[13][05]) * IIF(lRepCDsc, (aCDesp[nForMM, nMMTotDsc] / aCDesp[nForMM, nMMValTot]), 1)
     EndIf
    EndIf

    If cAlias == "GD5"
      &(cPrefiMM + "_FATPAR") := aRValDes[4][2]
    EndIf

    If !lFound
     &(cPrefiMM + "_SEQDES") := &("M->" + PrefixoCpo(cAliasMM) + "_SEQDES")
     &(cPrefiMM + "_NRSEQG") := GCZ->GCZ_NRSEQG
     &(cPrefiMM + "_REGATE") := GCZ->GCZ_REGATE
     &(cPrefiMM + "_LOTEFO") := aQtdLcto[nLcto, 2]
     &(cPrefiMM + "_NUMLOT") := aQtdLcto[nLcto, 3]
     &(cPrefiMM + "_LOTECT") := aQtdLcto[nLcto, 4]
     &(cPrefiMM + "_DTVALI") := aQtdLcto[nLcto, 5]
     &(cPrefiMM + "_NUMSEQ") := aMovEst[2]
    EndIf
   MsUnlock()
  EndIf
 Next

 RestArea(aArea)
Return(nTQtdLcto)

Static Function FS_IncSol(aCDesp, aIteSol,nMMProAlt )
 Local nIteSol := 0

 M->GAI_SOLICI := HS_VSxeNum("GAI", "M->GAI_SOLICI", 1)
 ConfirmSx8()

 DbSelectArea("GAI")
 DbSetOrder(1)
 RecLock("GAI", .T.)
  GAI->GAI_FILIAL := xFilial("GAI")
  GAI->GAI_SOLICI := M->GAI_SOLICI
  GAI->GAI_ALMORI := cGcsArmFar
  GAI->GAI_REQUIS := "1" // 1-Paciente
  GAI->GAI_ALMSOL := cGcsArmSet
  GAI->GAI_REGATE := M->GCY_REGATE
  GAI->GAI_NOMPAC := M->GCY_NOME
  GAI->GAI_CODLOC := cLctCodLoc
  GAI->GAI_DATSOL := IIf(M->GCY_ATENDI == "0", dDataBase, M->GCY_DATATE)
  GAI->GAI_HORSOL := IIf(M->GCY_ATENDI == "0", Time()   , M->GCY_HORATE)
  GAI->GAI_FLGATE := "0"
  GAI->GAI_URGENC := "0"
  GAI->GAI_LOGARQ := HS_LogArq()
 MsUnLock()

 DbSelectArea("GAJ")
 DbSetOrder(1)
 For nIteSol := 1 To Len(aIteSol)
  RecLock("GAJ", .T.)
   GAJ->GAJ_FILIAL := xFilial("GAJ")
   GAJ->GAJ_SOLICI := M->GAI_SOLICI
   GAJ->GAJ_ITESOL := StrZero(nIteSol, Len(GAJ->GAJ_ITESOL))
   GAJ->GAJ_PROSOL := aCDesp[aIteSol[nIteSol, 1], nMMCodDes]
   GAJ->GAJ_QTDSOL := aIteSol[nIteSol, 2]
   GAJ->GAJ_CODKIT := aCDesp[aIteSol[nIteSol, 1], nMMCodKit]
   GAJ->GAJ_PROALT := aCDesp[aIteSol[nIteSol, 1], nMMProAlt]
   If HS_ExisDic({{"C", "GAJ_CODCRM"}}, .F.)
    GAJ->GAJ_CODCRM := aCDesp[aIteSol[nIteSol, 1], nMMCodCrm]
   EndIf
   GAJ->GAJ_LOGARQ := HS_LogArq()
   If HS_ExisDic({{"C", "GAJ_CODPCT"}}, .F.)
      GAJ->GAJ_CODPCT := aCDesp[aIteSol[nIteSol, 1], nMMCodpct]
   EndIf
  MsUnLock()
 Next
Return(Nil)

Static Function FS_IncDev(aCDesp, aIteDev)
 Local nForDev := 0, nForIte := 0, nIteDev := 1
 Local lMovEst := .T.
 Local aConEst := {}

 For nForDev := 1 To Len(aIteDev)
  If Len(aIteDev[nForDev]) > 0
   DbselectArea("GBD")
   DbSetOrder(1)

   nIteDev := 1

   M->GBD_NUMDEV := HS_VSxeNum("GBD", "M->GBD_NUMDEV", 1)
   ConfirmSx8()

   RecLock("GBD", .T.)
    GBD->GBD_FILIAL := xFilial("GBD")
    GBD->GBD_NUMDEV := M->GBD_NUMDEV
    GBD->GBD_REGATE := M->GCY_REGATE
    GBD->GBD_CODLOC := cLctCodLoc
		 	if Hs_ExisDic({{"C","GBD_ALMORI"}},.F.)
			  GBD->GBD_ALMORI := cGcsArmFar
			 Endif
    GBD->GBD_DATDEV := dDatMov
    GBD->GBD_FLGDEV := IIf(nForDev == 1, "2", "0")
    GBD->GBD_LOGARQ := HS_LogArq()
   MsUnLock()

   For nForIte := 1 To Len(aIteDev[nForDev])
    DbSelectArea("GBE")
    DbSetOrder(1)
    RecLock("GBE", .T.)
     GBE->GBE_FILIAL := xFilial("GBE")
     GBE->GBE_NUMDEV := M->GBD_NUMDEV
     GBE->GBE_ITEDEV := StrZero(nIteDev++, Len(GBE->GBE_ITEDEV))
     GBE->GBE_SOLICI := aIteDev[nForDev][nForIte][4]
     GBE->GBE_ITESOL := aIteDev[nForDev][nForIte][5]
     GBE->GBE_DATSOL := dDatMov
     GBE->GBE_PRODEV := aIteDev[nForDev][nForIte][3]
     GBE->GBE_QTDADV := aIteDev[nForDev][nForIte][2]
     GBE->GBE_QTDDEV := IIf(nForDev == 1, aIteDev[nForDev][nForIte][2], 0)
     GBE->GBE_SEQDES := aCDesp[aIteDev[nForDev][nForIte][1], nMMSeqDes]
     GBE->GBE_LOGDEV := HS_LogArq()
     GBE->GBE_LOGARQ := HS_LogArq()
    MsUnlock()

    HS_GrvGnr(GBE->GBE_SEQDES , GBE->GBE_SOLICI, GBE->GBE_ITESOL, GBE->GBE_PRODEV, GBE->GBE_QTDADV)

    If nForDev == 1
     If lMovEst := aConEst := (HS_CONEST(aIteDev[nForDev][nForIte][3], HS_RetSet(cAliasMM, nMMSeqDes, nMMCodLoc,;
                                          cLctCodLoc, aIteDev[nForDev][nForIte][1], aCDesp,.T.))[1])

      If ValType('aIteDev[nForDev][nForIte][6]') <> 'U'
          cGcsArmSet := cGcsArmSet := HS_IniPadR("GCS", 1, aIteDev[nForDev][nForIte][6], "GCS_ARMSET",, .F.)
      EndIf

      HS_MovEst("E", aIteDev[nForDev][nForIte][3], aIteDev[nForDev][nForIte][2], cGcsArmSet, cUserName, cGcsCodCCu,, ;
               aCDesp[aIteDev[nForDev][nForIte][1], nMMNumLot], aCDesp[aIteDev[nForDev][nForIte][1], nMMLoteCt], ;
               aCDesp[aIteDev[nForDev][nForIte][1], nMMDtVali],,, dDatMov, M->GCY_REGATE)
     Endif
    EndIf
   Next
  EndIf
 Next
Return(Nil)

// Inicializador do campo X3_INIBRW
Function HS_IBrM24(cAlias, nOrdem, cChave, cCampo)
 Local cRet := ""
 If !Empty(HS_CfgSx3(cCampo)[SX3->(FieldPos("X3_CBOX"))])
  cRet := HS_RDescrB(cCampo, HS_IniPadr(cAlias, nOrdem, cChave, cCampo,,.F.))
 Else
  cRet := HS_IniPadr(cAlias, nOrdem, cChave, cCampo,,.F.)
 EndIf
Return(cRet)

/****************************************************************************************/
// ValidaÁıes de todos os campos dos atendimentos
Function HS_VldM24(cChave, nVld, lVldEmpty, cCpoDesc, dDataMM , lMsg, lRetorno,OXPTO ,cGuiaBpa  ,lNrGTissAt,nPrVguiaF,nGCZNRSEQG, nGCZDsGuia,cGavModelo,cOldLeiInt,cOldQuaInt,cGbjCodEsp,cGA7CodPro,cObsCodCrm,cGbjTipPro,cCondAtrib,nPRCODESP,nPRD,nPR,cOldCodLoc,cGbhDtNasc,cGbhSexo,cGbhRg, cGbhRgOrg, cGbhUFEmis,lRecepAgd)
Local lExDicSt 	:= Hs_ExisDic({{"C","GE3_STATUS"}},.F.) .AND. "GD7" $ (ReadVar()) .AND. Type("oGDPr") <> "U" .AND. Type("nPRQTDDES") <> "U"
Local lRet := .T., cAliasOld := Alias(), cSexoQuarto := "", aRet := {}, nCont := 0, nPosDes := 0, cOldReadV := "", nTab := 0, nPos := 0
Local aRVldVig	:= {{ 0, IIf(cGcyAtendi $ "14", "GC1_NDIASR", "GC1_NDIASP")}, ;
	{"", IIf(cGcyAtendi == "0", "GC1_TPGINT", IIf(cGcyAtendi $ "14", "GC1_TPGAMB", "GC1_TPGPAT"))},;
	{"", IIf(cGcyAtendi $ "14", "GC1_HORRTA", "GC1_HORRTP")}}

Local dMvUlmes := GETMV("MV_ULMES")
Local cMvMMAlt := GETMV("MV_LMMALTA")
Local nMvIdMin := GETMV("MV_IDMIN")
Local nMvIdMax := GETMV("MV_IDMAX")
Local cMvTxSrv := GETMV("MV_TXSERV")
Local cMVDoaPlPd := ""
Local lAchou     := .F. , lRetPlano := .T.
Local cGczNrGuia := SPACE(TAMSX3("GCZ_NRGUIA")[1])
Local lVldGui  := .T., lVldPreco := .T.
Local aArea    := GetArea()
Local cIdade   := "", cSexo := "", cOk := "", cFiltro := ""
Local cMovest  := UPPER(GetMv("MV_AUDMEST"))
Local lMovEst  := .F.
Local aConEst  := {}
Local aLaudo   := {}
Local aRValDes := {}, aCadPro := {}
Local cGcuTgTISS := ""
Local cVldCrm := "", cVldUsr := ""
Local cHoraMM := ""
Local  aTabs := {"PR", "TD"}
Local  oObj
Local cGA1Cod := ""
Local lExGcyMat := Hs_ExisDic({{"C","GCY_MATRIC"}},.F.)
Local lAteSUS := (GetMV("MV_ATESUS", , "N") == "S")
Local cMedPadr := GetMv('MV_CRMPADH')
Local cDiaUti := GetMv("MV_DIARUTI", , "")
Local cProcLaq:= GetMv("MV_PROLAQ", , "")
Local cProReg:= GetMv("MV_PROREG", , "")
Local cProcedSUS:= ""
Local aVldAih := {}
Local lPrc := .T.
Local cSqlCrm := ""
Local lAltEsp := GetNewPar("MV_GHALTES",.F.) .And. Iif(Type("cGczCodPla") # "U" .And. cGczCodPla <> Nil,cGczCodPla $ GetNewPar("MV_PSUSBPA",""),.F.)
Local cCodProc := ""
Local cCodCrm := ""
Local nProc := 0
Local lIntegr	:= GetMv("MV_HSPPLS")
Local cMvPRPARTO := GetMV("MV_PRPARTO")

Private cRegGer := ""
Private cFilAtu	:= xFilial("GCY")

Default lMsg := .T.
Default lRetorno := .F.
Default cOldCodLoc 	:= "", cOldQuaInt := "", cOldLeiInt:= ""

If lRetorno
	aRVldVig[2][2] := "GC1_TPGRET"
EndIf

If nVld == 1 // ValidaÁ„o do Setor
	lRet := IIf(Empty(cChave) .And. !lVldEmpty, .T., HS_VldCSet(cChave, IIf(cCpoDesc == Nil, "M->GCY_NOMLOC", cCpoDesc), cGcsTipLoc, HS_RDescrB("GCY_ATENDI", cGcyAtendi)))
	IF lRet== .F.
		HS_Sx1M24(cPergM24,"1")
		HS_FilGcs()
	Endif
	If !lFilGm1
		If Empty(cChave)
			M->GCY_QUAINT := Space(Len(GCY->GCY_LEIINT))
			M->GCY_LEIINT := Space(Len(GCY->GCY_LEIINT))
		EndIf
		HS_VldM24(, 9)
	EndIf
ElseIf nVld == 2 // ValidaÁ„o da data de nascimento do paciente
	cGbhDtNasc := M->GCY_DTNASC
	lRet := .T.
ElseIf nVld == 3 // ValidaÁ„o do sexo do paciente
	If (lRet := Vazio()) .Or. (lRet := Pertence("01"))
		cGbhSexo := M->GCY_SEXO
	EndIf
ElseIf nVld == 4 // ValidaÁ„o do prontu·rio do paciente
	cRegGer := M->GCY_REGGER
	IF     lRet := Empty(M->GCY_REGGER)
		HS_MsgInf(STR0035, STR0034, STR0134) //"O prontu·rio È obrigatÛrio."###"AtenÁ„o"###"ValidaÁ„o do Prontu·rio"
	ElseIf !(lRet := HS_SeekRet("GBH", "M->GCY_REGGER", 1, .F.,,,,, .T.))
		HS_MsgInf(STR0036, STR0034, STR0134) //"Prontu·rio n„o encontrado."###"AtenÁ„o"###"ValidaÁ„o do Prontu·rio"
	ElseIf (lRet := IIf(cGCYAtendi <> "3", HS_VAltPac(M->GCY_REGGER), .T.) )
		If cGcyAtendi == "3" // 3-Doacao
			DbSelectArea("GBH")
			DbSetOrder(1) // GBH_FILIAL + GBH_CODPAC
			DbSeek(xFilial("GBH") + M->GCY_REGGER)
			cIdade := HS_A58Age(GBH->GBH_DTNASC)
			cSexo  := GBH->GBH_SEXO
			If Empty(nMvIdMin)
				HS_MsgInf(STR0181, STR0034, STR0173)//"Por favor preencha o par‚metro que indica a idade mÌnima para doaÁ„o."###"AtenÁ„o"###"ValidaÁ„o da Idade"
				Return(.F.)
			ElseIf lRet := Val(Substr(cIdade, 1, 3)) < nMvIdMin
				If lAutoriz := MsgYesNo(STR0180, STR0173)//"O doador È menor de idade. Deseja autoriz·-lo?"###"ValidaÁ„o de Idade"
					If !FS_Login()
						Return(.F.)
					EndIf
				EndIf
			ElseIf Empty(nMvIdMax)
				HS_MsgInf(STR0179, STR0034, STR0173)//"Por favor preencha o par‚metro que indica a idade m·xima para doaÁ„o."###"AtenÁ„o"###"ValidaÁ„o da Idade"
				Return(.F.)
			ElseIf lRet := Val(Substr(cIdade, 1, 3)) > nMvIdMax
				If lAutoriz := MsgYesNo(STR0203, STR0173)//"AtenÁ„o o doador ultrapassa a idade m·xima permitida para doaÁ„o. Deseja Autoriz·-lo."###"ValidaÁ„o de Idade"
					If !FS_Login()
						Return(.F.)
					EndIf
				EndIf
			EndIf

		EndIf

		DbSelectArea("GD4")
		If cGcyAtendi == "3" //Doacao

			cMVDoaPlPd := AllTrim(GetMV("MV_DOAPLPD"))
			DbSetOrder(4) // Procurar por plano padrao para doaÁ„o
			If DbSeek(xFilial("GD4") + M->GCY_REGGER + "1") // pega convenio/plano padrao do paciente
				If !HS_VPlaSet(cGcsCodLoc, GD4->GD4_CODPLA, .F.) // Verifica se o plano eh permitido no setor
					If !HS_VPlaSet(cGcsCodLoc, cMVDoaPlPd, .F.)
						HS_MsgInf(STR0205 + cMVDoaPlPd + STR0206 + cGcsCodLoc + STR0207, STR0034, STR0134) //"Plano [" ### "] n„o permitido no Setor [" ### "] Verificar plano padr„o para doaÁ„o no par‚metro MV_DOAPLPD."###"AtenÁ„o"###"ValidaÁ„o do Prontu·rio"
						Return(.F.)
					EndIf
					lRetPlano := .F.
				EndIf
			Else //N„o achou plano padrao para doacao. Deve pegar do parametro

				If !HS_VPlaSet(cGcsCodLoc, cMVDoaPlPd, .F.)
					HS_MsgInf(STR0205 + cMVDoaPlPd + STR0206 + cGcsCodLoc + STR0207, STR0034, STR0134)//"Plano [" ### "] n„o permitido no Setor [" ### "] Verificar plano padr„o para doaÁ„o no par‚metro MV_DOAPLPD."###"AtenÁ„o"###"ValidaÁ„o do Prontu·rio"
					Return(.F.)
				EndIf
				lRetPlano := .F.
			EndIf
		Else // cGcyAtendi <> "3" nao eh doacao - execucao normal dos outros atendimentos
			DbSetOrder(2)
			DbSeek(xFilial("GD4") + M->GCY_REGGER + "1") // pega convenio/plano padrao do paciente

			If !HS_VPlaSet(cM24Par01, GD4->GD4_CODPLA, .F.)
				HS_MsgInf(STR0205 + GD4->GD4_CODPLA + STR0206 + cM24Par01 + "]", STR0034, STR0134)//"Plano [" ### "] n„o permitido no Setor [" ###"AtenÁ„o"###"ValidaÁ„o do Prontu·rio"
				Return(.F.)
			EndIf
		EndIF

		If lRetPlano //Encontrou plano padrao no cadastro de paciente
			If !HS_ConPlaA(GD4->GD4_CODCON, GD4->GD4_CODPLA) //verifica se o Conv e Plano estao Ativos
				Return(.F.)
			EndIf
		EndIf

		If (lRet := IIf(lRetPlano, HS_VMatPla(GD4->GD4_MATRIC, GD4->GD4_CODPLA), .T.))

			If !HS_VldVig("GC1", "GC1_FILIAL = '" + xFilial("GC1") + "' AND GC1_CODPLA = '" + IIf(lRetPlano, GD4->GD4_CODPLA, cMVDoaPlPd) + "'", "GC1_DATVIG", @aRVldVig, dDataBase)
				MsgStop(STR0108) //"N„o existe data de vigÍncia para o plano."
				Return(.F.)
			EndIf
			nDiasRet := aRVldVig[1][1]

			DbSelectArea("GFD")
			DbSetOrder(3)
			If DbSeek(xFilial("GFD") + M->GCY_REGGER + "1") //GFD_FILIAL+GFD_REGGER+GFD_IDPADR
				M->GCY_CODRES := GFD->GFD_SEQRES
				M->GCY_NOMRES := GFD->GFD_NOME
			EndIf

			cGczCodPla := IIf(lRetPlano, GD4->GD4_CODPLA, cMVDoaPlPd)
			cGcuCodTpg := aRVldVig[2][1]

			cGczNrGuia := FS_VLDSUS(IIf(lRetPlano, GD4->GD4_CODPLA, cMVDoaPlPd), M->GCY_REGATE)

			cGczNrGuia := IIF(Empty(cGczNrGuia),IIF(!Empty(oGDGcz:aCols[IIF(oGDGcz # Nil, oGDGcz:nAt, 1), nGCZNrGuia]),oGDGcz:aCols[IIF(oGDGcz # Nil, oGDGcz:nAt, 1), nGCZNrGuia],SPACE(TAMSX3("GCZ_NRGUIA")[1])),cGczNrGuia)
			If !lRecepAgd
				If Empty (oGDGcz:aCols[IIF(oGDGcz # Nil, oGDGcz:nAt, 1), nGCZNrGuia])
					cGczNrGuia := HS_IniTISS(3,IIF(oGDGcz # Nil, oGDGcz:nAt, 1),GD4->GD4_CODPLA,cGcuCodTpg,,oGDGcz:aHeader,oGDGcz:aCols)
				ElseIf lNrGTissAt
					HS_DelNrGT(IIF(oGDGcz # Nil, oGDGcz:nAt, 1))
					cGczNrGuia := HS_IniTISS(3,IIF(oGDGcz # Nil, oGDGcz:nAt, 1),GD4->GD4_CODPLA,cGcuCodTpg,,oGDGcz:aHeader,oGDGcz:aCols)
				EndIf
			EndIf

			If oGDGcz # Nil
				// Preenchimento dos campos Codigo do Plano e Descricao do Plano
				oGDGcz:aCols[oGDGcz:nAt, nGczCodPla] := IIf(lRetPlano, GD4->GD4_CODPLA, cMVDoaPlPd)
				oGDGcz:aCols[oGDGcz:nAt, nGczDesPla] := HS_IniPadr("GCM", 2, IIf(lRetPlano, GD4->GD4_CODPLA, cMVDoaPlPd), "GCM_DESPLA",,.F.)
				If lRetPlano
					oGDGcz:aCols[oGDGcz:nAt, nGczSqCatP] := GD4->GD4_SQCATP
					oGDGcz:aCols[oGDGcz:nAt, nGczDsCatP] := HS_IniPadr("GFV", 1, GD4->GD4_CODPLA + GD4->GD4_SQCATP, "GFV_NOMCAT",,.F.)
				EndIf
				oGDGcz:aCols[oGDGcz:nAt, nGCZNrGuia] := cGczNrGuia
				If !Empty(cGcuCodTpg)
					oGDGcz:aCols[oGDGcz:nAt, nGCZCODTPG] := cGcuCodTpg
					oGDGcz:aCols[oGDGcz:nAt, nGCZDESTPG] := HS_IniPadr("GCU", 1, cGcuCodTpg, "GCU_DESTPG",,.F.)
				Else
					oGDGcz:aCols[oGDGcz:nAt, nGCZCODTPG] := SPACE(LEN(GCZ->GCZ_CODTPG))
					oGDGcz:aCols[oGDGcz:nAt, nGCZDESTPG] := SPACE(LEN(GCU->GCU_DESTPG))
				EndIf
				oGDGcz:oBrowse:Refresh()
			Else
				// Preenchimento dos campos Codigo do Plano e Descricao do Plano
				aCGcz[1, nGczCodPla] := IIf(lRetPlano, GD4->GD4_CODPLA, cMVDoaPlPd)
				aCGcz[1, nGczDesPla] := HS_IniPadr("GCM", 2, IIf(lRetPlano, GD4->GD4_CODPLA, cMVDoaPlPd), "GCM_DESPLA",,.F.)
				aCGcz[1, nGCZNrGuia] := cGczNrGuia
				If !Empty(cGcuCodTpg)
					aCGcz[1, nGCZCODTPG] := cGcuCodTpg
					aCGcz[1, nGCZDESTPG] := HS_IniPadr("GCU", 1, cGcuCodTpg, "GCU_DESTPG",,.F.)
				Else
					aCGcz[1, nGCZCODTPG] := SPACE(LEN(GCZ->GCZ_CODTPG))
					aCGcz[1, nGCZDESTPG] := SPACE(LEN(GCU->GCU_DESTPG))
				EndIf
			EndIf

			If ExistBlock("HSVPAM24")
				lRet := Execblock("HSVPAM24",.f.,.f.,Nil)
			Endif

			cGcyRegGer    := IIf(lRet, M->GCY_REGGER                            , Space(Len(GCY->GCY_REGGER)))
			M->GCY_NOME   := IIf(lRet, GBH->GBH_NOME                            , Space(Len(GCY->GCY_NOME  )))
			M->GCY_DTNASC := IIf(lRet, GBH->GBH_DTNASC                          , CToD(" ")                  )
			M->GCY_SEXO   := IIf(lRet, GBH->GBH_SEXO                            , Space(Len(GCY->GCY_SEXO  )))
			M->GCY_IDADE  := IIf(lRet, HS_AgeGer(GBH->GBH_DTNASC, M->GCY_DATATE), Space(Len(GCY->GCY_IDADE )))
			If lExGcyMat
				M->GCY_MATRIC := IIf(lRet, IIF(cGczCodPla == GD4->GD4_CODPLA,GD4->GD4_MATRIC, "") , Space(Len(GCY->GCY_MATRIC )))
			EndIf
			If cGcyAtendi == "3"
				M->GCY_RG     := IIf(lRet, GBH->GBH_RG                              , Space(Len(GCY->GCY_RG    )))
				M->GCY_ORGEMI := IIf(lRet, GBH->GBH_ORGEMI                          , Space(Len(GCY->GCY_ORGEMI)))
				M->GCY_UFEMIS := IIf(lRet, GBH->GBH_UFEMIS                          , Space(Len(GCY->GCY_UFEMIS)))
			EndIf

			cGbhDtNasc    := M->GCY_DTNASC
			cGbhSexo      := M->GCY_SEXO
		EndIf
	EndIf
	if lRet
		If !Hsm54Fin()
			lRet := .F.
		EndIf
	endif
ElseIf nVld == 5 // ValidaÁ„o do CRM do mÈdico
	IF     !(lRet := !Empty(M->GCY_CODCRM))
		HS_MsgInf(STR0037, STR0034, STR0135) //"O CRM do profissional È obrigatÛrio."###"AtenÁ„o"###"ValidaÁ„o do MÈdico"
	ElseIf !(lRet := HS_SeekRet("SRA","M->GCY_CODCRM", 11, .F., "GCY_NOMMED", "RA_NOME",,, .T.)) .Or. ;
		!(lRet := HS_SeekRet("GBJ","M->GCY_CODCRM",  1, .F.,,,,, .T.))
		HS_MsgInf(STR0038, STR0034, STR0135) //"CRM do profissional n„o encontrado."###"AtenÁ„o"###"ValidaÁ„o do MÈdico"
	ElseIf GBJ->GBJ_STATUS # "1"
		HS_MsgInf(STR0061, STR0034, STR0135) //"MÈdico encontra-se inativo em seu cadastro."###"AtenÁ„o"###"ValidaÁ„o do MÈdico"
		lRet := .F.
	Else
		FS_IniGE8() // INICIALIZA PRORROGACAO DE GUIAS
		M->GCY_CODCLI := GBJ->GBJ_CODCLI
		M->GCY_DESCLI := HS_IniPadr("GCW", 1, GBJ->GBJ_CODCLI, "GCW_DESCLI",,.F.)
		If oGDPR # Nil .And. !Empty(IIf(cGcyAtendi $ "14", GBJ->GBJ_CODPRO, GBJ->GBJ_CPROPA)) .And. ;
			!Empty(HS_IniPadr("GA7", 1, IIf(cGcyAtendi $ "14", GBJ->GBJ_CODPRO, GBJ->GBJ_CPROPA), "GA7_CODPRO",,.F.))
			cGbjCodEsp := GA7->GA7_CODESP
			If lIncPro
				cOldReadVar := ReadVar()

				__ReadVar := "M->" + cAliasPR + "_CODDES"
				&("M->" + cAliasPR + "_CODDES") := GA7->GA7_CODPRO
				If &(HS_CfgSx3(cAliasPR + "_CODDES")[SX3->(FieldPos("X3_VALID"))])
					oGDPR:aCols[oGDPR:nAt, nPRCodDes] := GA7->GA7_CODPRO

					__ReadVar := "M->" + cAliasPR + "_CODCRM"
					&("M->" + cAliasPR + "_CODCRM") := M->GCY_CODCRM
					If &(HS_CfgSx3(cAliasPR + "_CODCRM")[SX3->(FieldPos("X3_VALID"))])
						oGDPR:aCols[oGDPR:nAt, nPRCodCrm] := M->GCY_CODCRM
						oGDPR:aCols[oGDPR:nAt, nPRNomMed] := M->GCY_NOMMED
					EndIf
				EndIf

				__ReadVar := cOldReadVar
			Endif
			If lGFR
				oGDPR:aCols[oGDPR:nAt, nPRNomEsp] := HS_IniPadr("GFR", 1, GA7->GA7_CODESP, "GFR_DSESPE",,.F.)
			Else
				oGDPR:aCols[oGDPR:nAt, nPRNomEsp] := HS_IniPadr("SX5", 1, "EM" + GA7->GA7_CODESP, "X5_DESCRI",,.F.)
			Endif
			If nPRSLaudo > 0
				aLaudo     := HS_IsLaudo(cGcsCodLoc, GA7->GA7_CODPRO)
				lGd7SLaudo := aLaudo[2]
				oGDPR:aCols[oGDPR:nAt, nPRSLaudo] := IIf(aLaudo[1], "1", "0")
				oGDPR:aCols[oGDPR:nAt, nPRCrmLau] := IIf(!Empty(oGDGcz:aCols[oGDGcz:nAt, nGczCodCrm]), oGDGcz:aCols[oGDGcz:nAt, nGczCodCrm], oGDPR:aCols[oGDPR:nAt, nPRCrmLau])
				oGDPR:aCols[oGDPR:nAt, nPRNMeLau] := IIf(!Empty(oGDGcz:aCols[oGDGcz:nAt, nGczNomMed]), oGDGcz:aCols[oGDGcz:nAt, nGczNomMed], oGDPR:aCols[oGDPR:nAt, nPRNMeLau])
			EndIf
			oGDPR:oBrowse:Refresh()
			If ExistBlock("HSM24VLP")
				ExecBlock("HSM24VLP", .F., .F., {cChave, nVld, lVldEmpty, cCpoDesc, dDataMM})
			EndIf
		EndIf
	EndIf
ElseIf nVld == 6 // ValidaÁ„o do cÛdigo da clinica
	IF     !(lRet := !Empty(M->GCY_CODCLI))
		HS_MsgInf(STR0039, STR0034, STR0136) //"O cÛdigo da clÌnica È obrigatÛrio."###"AtenÁ„o"###"ValidaÁ„o da ClÌnica"
	ElseIf !(lRet := HS_SeekRet("GCW","M->GCY_CODCLI", 1, .F., "GCY_DESCLI", "GCW_DESCLI",,, .T.))
		HS_MsgInf(STR0040, STR0034, STR0136) //"ClÌnica n„o encontrada."###"AtenÁ„o"###"ValidaÁ„o da ClÌnica"
	EndIf
ElseIf nVld == 7 // ValidaÁ„o da origem do paciente
	IF     !(lRet := !Empty(M->GCY_ORIPAC))
		HS_MsgInf(STR0041, STR0034, STR0137) //"O cÛdigo da origem do paciente È obrigatÛrio."###"AtenÁ„o"###"ValidaÁ„o da origem do Paciente"
	ElseIf !(lRet := HS_SeekRet("GD0","M->GCY_ORIPAC", 1, .F., "GCY_DORIPAC", "GD0_DORIPA",,, .T.))
		HS_MsgInf(STR0042, STR0034, STR0137) //"Origem do paciente n„o encontrada."###"AtenÁ„o"###"ValidaÁ„o da origem do Paciente"
	EndIf
ElseIf nVld == 8 // ValidaÁ„o do carater do atendimento
	IF !(lRet := !Empty(M->GCY_CARATE))
		HS_MsgInf(STR0043, STR0034, STR0138) //"O cÛdigo do carater do atendimento È obrigatÛrio."###"AtenÁ„o"###"ValidaÁ„o do carater do atendimento."
	ElseIf !(lRet := HS_SeekRet("GD1","M->GCY_CARATE", 1, .F., "GCY_DCARAT", "GD1_DCARAT",,, .T.))
		HS_MsgInf(STR0044, STR0034, STR0138) //"Carater do atendimento n„o encontrado."###"AtenÁ„o"###"ValidaÁ„o do carater do atendimento."
	EndIf
ElseIf nVld == 9 // ValidaÁ„o do quarto do atendimento
	If ReadVar() == "M->GCY_QUAINT" .And. !Empty(M->GCY_QUAINT)
		M->GCY_CODLOC := GAV->GAV_CODLOC
	EndIf

	HS_DefVar("GCS", 1, M->GCY_CODLOC, aVarDef)

	If Empty(M->GCY_QUAINT)
		M->GCY_LEIINT := Space(Len(GCY->GCY_LEIINT))
		FS_M24DF("", .F., oGDGdd, .F.)
		Return(.T.)
	EndIf

	If !HS_SeekRet("GAV","M->GCY_CODLOC+M->GCY_QUAINT+M->GCY_LEIINT", 1, .F.,,,,, .T.)
		HS_MsgInf(STR0302, STR0034, STR0139) //"Favor Utilizar a consulta F3 do campo Quarto Inter."###"AtenÁ„o"###"ValidaÁ„o do quarto"
		Return(.F.)
	ElseIf !(GAV->GAV_STATUS $ "05") .And. GAV->GAV_REGATE # M->GCY_REGATE
		HS_MsgInf(STR0046, STR0034, STR0139) //"Quarto ocupado."###"AtenÁ„o"###"ValidaÁ„o do quarto"
		Return(.F.)
	ElseIf GAV->GAV_TIPO == "6"
		HS_MsgInf(STR0100, STR0034, STR0140)//"Tipo de quarto n„o permitido!"###"AtenÁ„o"###"Valida„o de InternaÁ„o"
		Return(.F.)
	Else
		cSexoQuarto := HS_Sexo_Quarto(M->GCY_CODLOC, M->GCY_QUAINT)
		If !Empty(cSexoQuarto) .And. cSexoQuarto != "2" .And. cSexoQuarto != HS_IniPadr("GBH", 1, M->GCY_REGGER, "GBH_SEXO",,.F.)
			HS_MsgInf(STR0047 + X3COMBO("GAV_SEXO", cSexoQuarto), STR0034, STR0141) //"Quarto inv·lido - j· ocupado por paciente de sexo "###"AtenÁ„o"###"ValidaÁ„o do sexo do paciente"
			Return(.F.)
		ElseIf !LockByName(xFilial("GAV") + M->GCY_CODLOC + M->GCY_QUAINT + M->GCY_LEIINT, .T., .T., .F.)   //Trava  o novo leito no semaforo
			cUsrBloq := HSPVerFiCo("GAV",xFilial("GAV") + M->GCY_CODLOC + M->GCY_QUAINT + M->GCY_LEIINT,.F.)
			HS_MsgInf(STR0280+" - "+cUsrBloq, STR0034, STR0139) //"Este leito encontra-se bloqueado por outro usu·rio."###"AtenÁ„o"###"ValidaÁ„o do sexo do paciente"
			Return(.F.)
		Else

			If cOldCodLoc + cOldQuaInt + cOldLeiInt <> M->GCY_CODLOC + M->GCY_QUAINT + M->GCY_LEIINT
				UnLockByName(xFilial("GAV") + cOldCodLoc + cOldQuaInt + cOldLeiInt, .T., .T., .F.) //Libera o leito antigo no semaforo
				HSPDelFiCo("GAV",xFilial("GAV") + cOldCodLoc + cOldQuaInt + cOldLeiInt)
			EndIf

			DbSelectArea("GCY")
			cOldCodLoc := M->GCY_CODLOC
			cOldQuaInt := M->GCY_QUAINT
			cOldLeiInt := M->GCY_LEIINT
			cGavModelo := GAV->GAV_MODELO
			FS_M24DF(cGavModelo, .T., oGDGdd, !Inclui)
		EndIf
	Endif
ElseIf nVld == 10 // ValidaÁ„o do codigo da via de acesso.
	IF !Empty(&(ReadVar())) .And. !(lRet := HS_SeekRet("GE4","'" + &("M->" + PrefixoCpo(cAliasPR) + "_CODVIA") + "'", 1, .F., PrefixoCpo(cAliasPR) + "_DESVIA", "GE4_DESVIA",,, .T.))
		HS_MsgInf(STR0088, STR0034, STR0142) //"Via de acesso n„o encontrada."###"AtenÁ„o"###"ValidaÁ„o da via de acesso"
	EndIf
ElseIf nVld == 11 // ValidaÁ„o do campo GCY_ACITRA
	If M->GCY_ACITRA # "1"
		M->GCY_CODEMP := Space(Len(M->GCY_CODEMP))
		M->GCY_EMPRES := Space(Len(M->GCY_EMPRES))
		lRet := .T.
	Else
		lRet := Pertence("01")
	EndIf
Elseif nVld == 12 // ValidaÁ„o do Codigo da Empresa
	If M->GCY_ACITRA == "1" .And. !Empty(M->GCY_CODEMP) .And. !HS_SeekRet("GAE", "M->GCY_CODEMP", 1, .F., "GCY_EMPRES", "GAE_NOME",,, .T.)
		HS_MsgInf(STR0048, STR0034, STR0143) //"Empresa n„o encontrada."###"AtenÁ„o"###"ValidaÁ„o da empresa"
		lRet := .F.
	Endif
Elseif nVld == 13 // ValidaÁ„o do Codigo do Plano do Convenio
	cGczCodPla := M->GCZ_CODPLA
	IF !(lRet := !Empty(M->GCZ_CODPLA))
		HS_MsgInf(STR0049, STR0034, STR0144) //"O cÛdigo do plano de convÍnio È obrigatÛrio."###"AtenÁ„o"###"ValidaÁ„o do plano"
	ElseIf !(lRet := HS_SeekRet("GCM","M->GCZ_CODPLA", 2, .F., "GCZ_DESPLA", "GCM_DESPLA",,, .T.))
		HS_MsgInf(STR0050, STR0034, STR0144) //"Plano de convÍnio n„o encontrado."###"AtenÁ„o"###"ValidaÁ„o do plano"
	ElseIf !(lRet := HS_SeekRet("GCV", "oGDGcz:aCols[oGDGcz:nAt, nGczCodTpg]+M->GCZ_CODPLA", 1, .F.,,,,, .T.))
		HS_MsgInf(STR0051, STR0034, STR0144) //"Plano de convÍnio n„o permitido para o tipo de guia selecionado."###"AtenÁ„o"###"ValidaÁ„o do plano"
	ElseIf !(lRet := !HS_SeekRet("GM0","M->GCY_CODLOC+M->GCZ_CODPLA", 1, .F.,,,,, .T.))
		HS_MsgInf(STR0052, STR0034, STR0144) //"Plano de convÍnio n„o permitido para o setor selecionado."###"AtenÁ„o"###"ValidaÁ„o do plano"
	ElseIf (FunName() == "HSPAHP12" .And. SuperGetMv("MV_ATESUS",nil,"N") == "S" .And.  cGczCodPla $ __cCodPAC)
 		HS_MsgInf(STR0319, STR0034, STR0144) //"N„o È possÌvel selecionar plano APAC."###"AtenÁ„o"###"ValidaÁ„o do plano"
	    lRet := .F.
	Else
		lRet := .T.
		DbSelectArea("GCM")
		DbSetOrder(2)
		DbSeek(xFilial("GCM") + M->GCZ_CODPLA)

		DbSelectArea("GA9")
		DbSetOrder(1)
		DbSeek(xFilial("GA9") + GCM->GCM_CODCON)

		DbSelectArea("GD4")
		DbSetOrder(1)//GD4_REGGER + GD4_CODPLA
		lAchou := DbSeek(xFilial("GD4") + M->GCY_REGGER + M->GCZ_CODPLA)
		If !HS_ConPlaA(GCM->GCM_CODCON, IIF(lAchou, GD4->GD4_CODPLA, M->GCZ_CODPLA)) //verifica se o Conv e Plano estao Ativos
			Return(.F.)
		EndIf

		If lAchou
			If lRet := HS_VldPac(M->GCY_REGGER, M->GCZ_CODPLA )
				oGDGcz:aCols[oGDGcz:nAt, nGczSqCatP] := GD4->GD4_SQCATP
				oGDGcz:aCols[oGDGcz:nAt, nGczDsCatP] := HS_IniPadr("GFV", 1, GD4->GD4_CODPLA + GD4->GD4_SQCATP, "GFV_NOMCAT",,.F.)
			Else
				Return(.F.)
			EndIf
		EndIf

		If GA9->GA9_TIPCON == "0"
			If (lRet := HS_SeekRet("GD4","M->GCY_REGGER+M->GCZ_CODPLA", 1, .F.,,,,, .T.))
				If !Empty(GA9->GA9_VLDMAT)
					lRet := HS_VMatPla(GD4->GD4_MATRIC, GD4->GD4_CODPLA)
				Endif
			Else
				HS_MsgInf(STR0053, STR0034, STR0144) //"Paciente n„o possui o plano de convÍnio informado."###"AtenÁ„o"###"ValidaÁ„o do plano"
			Endif
		Endif
		If lRet
			cGczNrGuia := FS_VLDSUS(M->GCZ_CODPLA, M->GCY_REGATE)

			cGczNrGuia := IIF(Empty(cGczNrGuia),IIF(!Empty(oGDGcz:aCols[IIF(oGDGcz # Nil, oGDGcz:nAt, 1), nGCZNrGuia]),oGDGcz:aCols[IIF(oGDGcz # Nil, oGDGcz:nAt, 1), nGCZNrGuia],SPACE(TAMSX3("GCZ_NRGUIA")[1])),cGczNrGuia)
			If !lRecepAgd
				If Empty (oGDGcz:aCols[IIF(oGDGcz # Nil, oGDGcz:nAt, 1), nGCZNrGuia])
					cGczNrGuia := HS_IniTISS(3,IIF(oGDGcz # Nil, oGDGcz:nAt, 1),cGczCodPla,cGcuCodTpg,,oGDGcz:aHeader,oGDGcz:aCols)
				ElseIf lNrGTissAt
					HS_DelNrGT(IIF(oGDGcz # Nil, oGDGcz:nAt, 1))
					cGczNrGuia := HS_IniTISS(3,IIF(oGDGcz # Nil, oGDGcz:nAt, 1),cGczCodPla,cGcuCodTpg,,oGDGcz:aHeader,oGDGcz:aCols)
				EndIf
			EndIf


			oGDGcz:aCols[oGDGcz:nAt, nGczNrGuia] :=  cGczNrGuia
			oGDGcz:oBrowse:Refresh()
		Endif
	EndIf

Elseif nVld == 14 // ValidaÁ„o do tipo de guia
	cGcuApoio := cGcuCodTpg
	IF     !(lRet := !Empty(M->GCZ_CODTPG))
		HS_MsgInf(STR0054, STR0034, STR0145) //"O cÛdigo do tipo de guia È obrigatÛrio."###"AtenÁ„o"###"ValidaÁ„o do tipo de guia"
	ElseIf !(lRet := HS_SeekRet("GCU","M->GCZ_CODTPG", 1, .F., "GCZ_DESTPG", "GCU_DESTPG",,, .T.))
		HS_MsgInf(STR0055, STR0034, STR0145) //"Tipo de guia n„o encontrado."###"AtenÁ„o"###"ValidaÁ„o do tipo de guia"
		Fs_RefDes(cGcuApoio,nGCZDsGuia)
	ElseIf !(lRet := (GCU->GCU_TPGUIA $ IIf(cGcyAtendi == "0", "06", IIf(cGcyAtendi == "1","01235", IIf(cGcyAtendi == "2","045","012345")))))
		HS_MsgInf(STR0056, STR0034, STR0145) //"Tipo de guia n„o permitido no setor."###"AtenÁ„o"###"ValidaÁ„o do tipo de guia"
		Fs_RefDes(cGcuApoio)
	ElseIf !(lRet := Empty(oGDGcz:aCols[oGDGcz:nAt, nGczCodPla]) .Or. HS_SeekRet("GCV", "M->GCZ_CODTPG+oGDGcz:aCols[oGDGcz:nAt, nGczCodPla]", 1, .F.,,,,, .T.))
		HS_MsgInf(STR0057, STR0034, STR0145) //"Tipo de guia n„o permitido para o plano selecionado."###"AtenÁ„o"###"ValidaÁ„o do tipo de guia"
		Fs_RefDes(cGcuApoio)
	Else
		lRet := IIf(cGcyAtendi == "0", .T., FS_VldDesG(M->GCZ_CODTPG)) // Verifica se existem procedimentos lanÁados na guia que n„o s„o permitidos no tipo de guia informado
		If lRet
			cGczNrGuia := IIF(Empty(cGczNrGuia),IIF(!Empty(oGDGcz:aCols[IIF(oGDGcz # Nil, oGDGcz:nAt, 1), nGCZNrGuia]),oGDGcz:aCols[IIF(oGDGcz # Nil, oGDGcz:nAt, 1), nGCZNrGuia],SPACE(TAMSX3("GCZ_NRGUIA")[1])),cGczNrGuia)
			If !lRecepAgd
				If Empty (oGDGcz:aCols[IIF(oGDGcz # Nil, oGDGcz:nAt, 1), nGCZNrGuia])
					cGczNrGuia := HS_IniTISS(3,IIF(oGDGcz # Nil, oGDGcz:nAt, 1),oGDGcz:aCols[oGDGcz:nAt, nGczCodPla],cGcuCodTpg,,oGDGcz:aHeader,oGDGcz:aCols)
				ElseIf lNrGTissAt
					HS_DelNrGT(IIF(oGDGcz # Nil, oGDGcz:nAt, 1))
					cGczNrGuia := HS_IniTISS(3,IIF(oGDGcz # Nil, oGDGcz:nAt, 1),oGDGcz:aCols[oGDGcz:nAt, nGczCodPla],cGcuCodTpg,,oGDGcz:aHeader,oGDGcz:aCols)
				EndIf
			EndIf
			cGcuApoio	:= M->GCZ_CODTPG
			cGcuCodTpg	:= M->GCZ_CODTPG
		EndIf
		Fs_RefDes(cGcuApoio)
	EndIf

Elseif nVld == 15 // ValidaÁ„o do cÛdigo do mÈdico (CRM)
	If !Vazio() .And. (!(lRet := HS_SeekRet("SRA","M->GCZ_CODCRM", 11, .F., "GCZ_NOMMED", "RA_NOME",,, .T.)) .Or. ;
		!(lRet := HS_SeekRet("GBJ","M->GCZ_CODCRM",  1, .F.,,,,, .T.)))

		aCadPro := HS_CadPro(, oGDGcz, nGCZCODCRM, nGCZNOMMED,,, .T.)

		If aCadPro[1]
			lRet := .T.
		Else
			HS_MsgInf(aCadPro[2], STR0034, STR0135) //"O CRM do profissional È obrigatÛrio."###"AtenÁ„o"###"ValidaÁ„o do MÈdico"
		Endif
	ElseIf GBJ->GBJ_STATUS # "1"
		HS_MsgInf(STR0061, STR0034, STR0135) //"MÈdico encontra-se inativo em seu cadastro."###"AtenÁ„o"###"ValidaÁ„o do MÈdico"
		lRet := .F.
	ElseIf !(GBJ->GBJ_TIPPRO $ "0/1/2")
		HS_MsgInf(STR0246, STR0034, STR0135) //"Profissional n„o È do tipo mÈdico em seu cadastro. Verifique."###"AtenÁ„o"###"ValidaÁ„o do MÈdico"
		lRet := .F.
	Else
		cObsCodCrm := &(ReadVar())
	EndIf
	If lRet .AND. IsInCallStack("HSPAHAIH") .AND. (oGDGcz:aCols[oGDGcz:nAt, nGczCodPla] $ __cCodAIH )
		oGDGcz:aCols[oGDGcz:nAt, nGczCPFGES] := GBJ->GBJ_CIC
	EndIF
Elseif nVld == 16 // ValidaÁ„o da especialidade do mÈdico que executou o procedimento
	IF     !(lRet := !Empty(&("M->" + PrefixoCpo(cAliasPR) + "_CODESP")))
		HS_MsgInf(STR0059, STR0034, STR0146) //"A especialidade do profissional È obrigatÛria."###"AtenÁ„o"###"ValidaÁ„o da especialidade"
	Else
		If lGFR .And. !(lRet := HS_SeekRet("GFR", &("M->" + PrefixoCpo(cAliasPR) + "_CODESP"), 1, .F., PrefixoCpo(cAliasPR) + "_NOMESP", "GFR_DSESPE"))
			HS_MsgInf(STR0060, STR0034, STR0146) //"Especialidade n„o encontrada."###"AtenÁ„o"###"ValidaÁ„o da especialidade"
		ElseIf !lGFR .And. !(lRet := HS_SeekRet("SX5", "'EM" + &("M->" + PrefixoCpo(cAliasPR) + "_CODESP") +"'", 1, .F., PrefixoCpo(cAliasPR) + "_NOMESP", "X5_DESCRI"))
			HS_MsgInf(STR0060, STR0034, STR0146) //"Especialidade n„o encontrada."###"AtenÁ„o"###"ValidaÁ„o da especialidade"
		Endif
	EndIf
ElseIf nVld == 17 // ValidaÁ„o CRM do mÈdico que executou o procedimento
	If ReadVar() $ "M->" + PrefixoCpo(cAliasPR) + "_CODCRM/M->" + PrefixoCpo(cAliasPR) + "_CRMLAU" //ValidaÁ„o para Procedimento
		If !(lRet := !Empty(&(ReadVar())))
			HS_MsgInf(STR0037, STR0034, STR0135) //"O CRM do profissional È obrigatÛrio."###"AtenÁ„o"###"ValidaÁ„o do MÈdico"
		ElseIf !(lRet := HS_SeekRet("SRA", "'" + &(ReadVar()) + "'", 11, .F., IIF(ReadVar() == "M->GD7_CRMLAU", PrefixoCpo(cAliasPR) + "_NMELAU", PrefixoCpo(cAliasPR) + "_NOMMED"), "RA_NOME",,, IIF(ReadVar() == "M->GD7_CRMLAU",.F.,.T.))) .Or. ;
			!(lRet := HS_SeekRet("GBJ", "'" + &(ReadVar()) + "'",  1, .F.,,,,, .T.))
			HS_MsgInf(STR0058, STR0034, STR0135) //"Profissional n„o encontrado."###"AtenÁ„o"###"ValidaÁ„o do MÈdico"
		ElseIf !(lRet := !(GBJ->GBJ_STATUS # "1"))
			HS_MsgInf(STR0061, STR0034, STR0135) //"O profissional est· inativo"###"AtenÁ„o"###"ValidaÁ„o do MÈdico"
		ElseIf lAltEsp
			nProc	:= aScan(oGDPR:aHeader, {|aVet| aVet[2] == cAliasPR + "_CODDES"})

			cCodCrm := &("M->" + cAliasPR + "_CODCRM")
			cCodProc:= oGDPR:aCols[oGDPR:nAt,nProc]

			cSqlCrm += "SELECT GBJ.GBJ_CRM FROM " + RetSqlName("GBJ") + " GBJ "
			cSqlCrm += "LEFT JOIN " + RetSqlName("GFP") + " GFP ON GFP_FILIAL = '" + xFilial("GFP") + "' AND GFP.GFP_CODCRM = GBJ.GBJ_CRM AND GFP.D_E_L_E_T_ <> '*' "
			cSqlCrm += "WHERE GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' "
			cSqlCrm += "AND GBJ.GBJ_STATUS = '1' AND  GBJ.GBJ_CRM = '" + cCodCrm + "' AND(GBJ_ESPEC1 IN "
			cSqlCrm += "(SELECT GFR_CDESPE ESP01 FROM " + RetSqlName("GA7") + " GA7 "
			cSqlCrm += "LEFT JOIN " + RetSqlName("GHD") + " GHD ON GHD_FILIAL = '" + xFilial("GHD") + "' AND GHD.GHD_CODPRO = GA7.GA7_CODPRO AND GHD.D_E_L_E_T_ <> '*' "
			cSqlCrm += "INNER JOIN " + RetSqlName("GFR") + " GFR ON GFR_FILIAL = '" + xFilial("GFR") + "' AND (GFR.GFR_CDESPE = GA7.GA7_CODESP OR GFR.GFR_CBOSUS = GHD.GHD_CODCBO) AND GFR.D_E_L_E_T_ <> '*' "
			cSqlCrm += "WHERE GA7.GA7_CODPRO = '" + cCodProc + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' GROUP BY GFR_CDESPE)"
			cSqlCrm += "OR GBJ_ESPEC2 IN "
			cSqlCrm += "(SELECT GFR_CDESPE ESP02 FROM " + RetSqlName("GA7") + " GA7 "
			cSqlCrm += "LEFT JOIN " + RetSqlName("GHD") + " GHD ON GHD_FILIAL = '" + xFilial("GHD") + "' AND GHD.GHD_CODPRO = GA7.GA7_CODPRO AND GHD.D_E_L_E_T_ <> '*' "
			cSqlCrm += "INNER JOIN " + RetSqlName("GFR") + " GFR ON GFR_FILIAL = '" + xFilial("GFR") + "' AND (GFR.GFR_CDESPE = GA7.GA7_CODESP OR GFR.GFR_CBOSUS = GHD.GHD_CODCBO) AND GFR.D_E_L_E_T_ <> '*' "
			cSqlCrm += "WHERE GA7.GA7_CODPRO = '" + cCodProc + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' GROUP BY GFR_CDESPE)"
			cSqlCrm += "OR GBJ_ESPEC3 IN "
			cSqlCrm += "(SELECT GFR_CDESPE ESP03 FROM " + RetSqlName("GA7") + " GA7 "
			cSqlCrm += "LEFT JOIN " + RetSqlName("GHD") + " GHD ON GHD_FILIAL = '" + xFilial("GHD") + "' AND GHD.GHD_CODPRO = GA7.GA7_CODPRO AND GHD.D_E_L_E_T_ <> '*' "
			cSqlCrm += "INNER JOIN " + RetSqlName("GFR") + " GFR ON GFR_FILIAL = '" + xFilial("GFR") + "' AND (GFR.GFR_CDESPE = GA7.GA7_CODESP OR GFR.GFR_CBOSUS = GHD.GHD_CODCBO) AND GFR.D_E_L_E_T_ <> '*' "
			cSqlCrm += "WHERE GA7.GA7_CODPRO = '" + cCodProc + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' GROUP BY GFR_CDESPE)"
			cSqlCrm += "OR GFP_CODESP IN "
			cSqlCrm += "(SELECT GFR_CDESPE ESPN FROM " + RetSqlName("GA7") + " GA7 "
			cSqlCrm += "LEFT JOIN " + RetSqlName("GHD") + " GHD ON GHD_FILIAL = '" + xFilial("GHD") + "' AND GHD.GHD_CODPRO = GA7.GA7_CODPRO AND GHD.D_E_L_E_T_ <> '*' "
			cSqlCrm += "INNER JOIN " + RetSqlName("GFR") + " GFR ON GFR_FILIAL = '" + xFilial("GFR") + "' AND (GFR.GFR_CDESPE = GA7.GA7_CODESP OR GFR.GFR_CBOSUS = GHD.GHD_CODCBO) AND GFR.D_E_L_E_T_ <> '*' "
			cSqlCrm += "WHERE GA7.GA7_CODPRO = '" + cCodProc + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' GROUP BY GFR_CDESPE)) "
			cSqlCrm += "GROUP BY GBJ.GBJ_CRM"

			cSqlCrm := ChangeQuery(cSqlCrm)
			TCQUERY cSqlCrm NEW ALIAS "TMPCDCRM"

			If TMPCDCRM->(Eof())
				HS_MsgInf(STR0062, STR0034, STR0135) //"A especialidade do profissional È inv·lida para o procedimento."###"AtenÁ„o"###"ValidaÁ„o do MÈdico"
				RestArea(aArea)
				TMPCDCRM->(DbCloseArea())
				Return (.F.)
			Endif
			TMPCDCRM->(DbCloseArea())
		ElseIf SUBSTR(ReadVar(), 8) == "CODCRM"
			If !(lRet := FS_VldEsp( &(ReadVar()) ))
				If lMsg
					HS_MsgInf(STR0062, STR0034, STR0135) //"A especialidade do profissional È inv·lida para o procedimento."###"AtenÁ„o"###"ValidaÁ„o do MÈdico"
				EndIf
			ElseIf cAliasPR == "GE7" .Or. (cAliasPR == "GD7" .And. FunName() == "HSPAHP12") .Or. lIsCaixa

				lVldPreco := !(oGDGcz:aCols[oGDGcz:nAt, nGczCodPla] $ __cCodBPA+"/"+__cCodPAC+"/"+__cCodAIH)

				If lRet := HS_VProHon(cGczCodPla, IIF(lIsCaixa, cGcsCodLoc, oGDPR:aCols[oGDPR:nAt, nPRCODLOC]), oGDPR:aCols[oGDPR:nAt, nPRCODDES], lVldPreco,, ;
					oGDPR:aCols[oGDPR:nAt, nPRHORDES], "2", &(ReadVar()), ;
					oGDPR:aCols[oGDPR:nAt, nPRCODATO], {cGcyAtendi, M->GCY_ATORIG, M->GCY_IDADE, M->GCY_SEXO, M->GCY_CARATE},, oGDPR:aCols[oGDPR:nAt, nPRDATDES],,IIF(lAteSUS .And. IIF(!Empty(GCZ->GCZ_CODPLA),GCZ->GCZ_CODPLA,cGczCodPla) $ __cCodAIH,oGDPR:aCols[oGDPR:nAt, nPRQTDDES],NIL))[1]
					lRet := HS_CalcDsc()
				EndIf
		     
		       If lIsCaixa	
					If IIF(Type("lCalRet") # "U", lCalRet,.T.)
						//Carregando Dias de Retorno
						HS_VldVig("GC1", "GC1_FILIAL = '" + xFilial("GC1") + "' AND GC1_CODPLA = '" + IIf(lRetPlano, GD4->GD4_CODPLA, cMVDoaPlPd) + "'", "GC1_DATVIG", @aRVldVig, dDataBase)
						nDiasRet   := aRVldVig[1][1]
					EndIf
	
					//Mostra atendimento anteriores realizados para o mesmo medico e com o mesmo proced.
					aRet := HS_ProMed(&(ReadVar()), oGDPR:aCols[oGDPR:nAt, nPRCODDES], M->GCY_REGGER, nDiasRet, aRVldVig[2][1],aRVldVig[3][1], cLctCodLoc)
	
					If FunName() == "HSPM24AA" .And. aRet[1] > 0 .And. aRet[2] == .F.
						M->GCY_CODCRM := SPACE(LEN(GCY->GCY_CODCRM))
						M->GCY_NOMMED := SPACE(LEN(SRA->RA_NOME))
						M->GCY_CODCLI := SPACE(LEN(GCY->GCY_CODCLI))
						M->GCY_DESCLI := SPACE(LEN(GCW->GCW_DESCLI))
						M->GCY_ORIPAC := SPACE(LEN(GCY->GCY_ORIPAC))
						M->GCY_DORIPA := SPACE(LEN(GD0->GD0_DORIPA))
					EndIf
	
					DbSelectArea("GCS")
					DbSetOrder(1)
					DbSeek(xFilial("GCS") + M->GCY_CODLOC)
	
					If GCS->GCS_TIPLOC == "J" .AND. lRet .AND. lIntegr .AND. !Empty(oGDPR:aCols[oGDPR:nAt, nPRCODDES])
						lRet := HS_VPROPLS(M->GCY_REGGER, oGDGcz:aCols[oGDGcz:nAt, nGczCodPla], M->GD7_CODCRM, oGDPR:aCols[oGDPR:nAt, nPRCODDES])
					EndIf
				Endif	
			ElseIf (cAliasPR == "GD7" .And. FunName() <> "HSPAHM30" .And. FunName() <> "HSPAHP12") .And. !EMPTY(oGDPR:aCols[oGDPR:nAt, nPRCODDES])

				If IIF(Type("lCalRet") # "U", lCalRet,.T.)
					//Carregando Dias de Retorno
					HS_VldVig("GC1", "GC1_FILIAL = '" + xFilial("GC1") + "' AND GC1_CODPLA = '" + IIf(lRetPlano, GD4->GD4_CODPLA, cMVDoaPlPd) + "'", "GC1_DATVIG", @aRVldVig, dDataBase)
					nDiasRet   := aRVldVig[1][1]
				EndIf

				//Mostra atendimento anteriores realizados para o mesmo medico e com o mesmo proced.
				aRet := HS_ProMed(M->GD7_CODCRM, oGDPR:aCols[oGDPR:nAt, nPRCODDES], M->GCY_REGGER, nDiasRet, aRVldVig[2][1],aRVldVig[3][1], cLctCodLoc)

				If FunName() == "HSPM24AA" .And. aRet[1] > 0 .And. aRet[2] == .F.
					M->GCY_CODCRM := SPACE(LEN(GCY->GCY_CODCRM))
					M->GCY_NOMMED := SPACE(LEN(SRA->RA_NOME))
					M->GCY_CODCLI := SPACE(LEN(GCY->GCY_CODCLI))
					M->GCY_DESCLI := SPACE(LEN(GCW->GCW_DESCLI))
					M->GCY_ORIPAC := SPACE(LEN(GCY->GCY_ORIPAC))
					M->GCY_DORIPA := SPACE(LEN(GD0->GD0_DORIPA))
				EndIf

				DbSelectArea("GCS")
				DbSetOrder(1)
				DbSeek(xFilial("GCS") + M->GCY_CODLOC)

				If GCS->GCS_TIPLOC == "J" .AND. lRet .AND. lIntegr .AND. !Empty(oGDPR:aCols[oGDPR:nAt, nPRCODDES])
					lRet := HS_VPROPLS(M->GCY_REGGER, oGDGcz:aCols[oGDGcz:nAt, nGczCodPla], M->GD7_CODCRM, oGDPR:aCols[oGDPR:nAt, nPRCODDES])
				EndIf
			EndIf
		EndIf
	ElseIf ReadVar() $ "M->GCZ_CRMAUT"
		If !(lRet := HS_SeekRet("SRA", ReadVar(), 11, .F.,"GCZ_MEDAUT", "RA_NOME",,, .T.) )
			Hs_MsgInf(STR0058, STR0034, STR0135)
		EndIf
	ElseIf ReadVar() $ "M->" + PrefixoCpo(cAliasMM) + "_CODCRM/M->" + PrefixoCpo(cAliasTD) + "_CODCRM" //ValidaÁ„o para MAT/MED - TAX/DIA
		If !Empty(&(ReadVar()))
			If !(lRet := HS_SeekRet("SRA", "'" + &(ReadVar()) + "'", 11, .F., PrefixoCpo(IIf(ReadVar() $ "M->" + PrefixoCpo(cAliasMM) + "_CODCRM",cAliasMM, cAliasTD)) + "_NOMMED", "RA_NOME",,, .T.)) .Or. !(lRet := HS_SeekRet("GBJ", "'" + &(ReadVar()) + "'",  1, .F.,,,,, .T.))
				HS_MsgInf(STR0058, STR0034, STR0135) //"Profissional n„o encontrado."###"AtenÁ„o"###"ValidaÁ„o do MÈdico"
			ElseIf !(lRet := !(GBJ->GBJ_STATUS # "1"))
				HS_MsgInf(STR0061, STR0034, STR0135) //"O profissional est· inativo"###"AtenÁ„o"###"ValidaÁ„o do MÈdico"
			ElseIf !(lRet := IIf(ReadVar() $ "M->" + PrefixoCpo(cAliasMM) + "_CODCRM", !HS_VExtMed(cAliasMM, oGDMM:aCols[oGDMM:nAt, nMMSeqDes]), !HS_VExtMed(cAliasTD, oGDTD:aCols[oGDTD:nAt, nTDSeqDes])))//Se extrato mÈdico j· foi gerado n„o deixar passar
				HS_MsgInf("O profissional n„o pode ser alterado, pois o extrato mÈdico j· foi gerado", STR0034, STR0135)

			ElseIf ReadVar() $ "M->" + PrefixoCpo(cAliasMM) + "_CODCRM"
				If &(ReadVar()) <> oGDMM:aCols[oGDMM:nAt, nMMCodCrm] .And. !Empty(oGDMM:aCols[oGDMM:nAt, nMMCodDes])// Pode ser chamado davalidaÁ„o do VMatMed -- N„o ser· validado Mat/Med novamente
					lRet := HS_VMatMed(cGczCodPla, oGDMM:aCols[oGDMM:nAt, nMMCodDes], cGcsArmSet,,, {.F., __MMQtdDe},/*lMsg*/,/*dVigencia*/, HS_RetSet(cAliasMM, nMMSeqDes, nMMCodLoc, cLctCodLoc, oGDMM:nAt, oGDMM:aCols), &(ReadVar()), oGDMM:aCols[oGDMM:nAt, nMMHorDes], {cGcyAtendi, M->GCY_CARATE})

				EndIf

			ElseIf ReadVar() $ "M->" + PrefixoCpo(cAliasTD) + "_CODCRM"
				If &(ReadVar()) <> oGDTD:aCols[oGDTD:nAt, nTDCodCrm] .And. !Empty(oGDTD:aCols[oGDTD:nAt, nTDCodDes])// Pode ser chamado davalidaÁ„o do VTaxDia -- N„o ser· validado Tax/Dia novamente
					lRet := HS_VTaxDia(cGczCodPla, cGcsCodLoc, oGDTD:aCols[oGDTD:nAt, nTDCodDes],,,, oGDTD:aCols[oGDTD:nAt, nTDDatDes], &(ReadVar()), oGDTD:aCols[oGDTD:nAt, nTDHorDes], {cGcyAtendi, M->GCY_CARATE})
				EndIf
			EndIf

		EndIf
	EndIf
	If lret
		cObsCodCrm := &(ReadVar())
	Endif
ElseIf nVld == 18 // Codigo do Ato MÈdico
	IF !(lRet := HS_SeekRet("GMC","'" + &("M->" + PrefixoCpo(cAliasPR) + "_CODATO") + "'", 1, .F., PrefixoCpo(cAliasPR) + "_DESATO", "GMC_DESATO",,, .T.))
		HS_MsgInf(STR0063, STR0034, STR0147) //"Ato mÈdico n„o encontrado."###"AtenÁ„o"###"ValidaÁ„o do ato mÈdico"
	ElseIf !(lRet := !(GMC->GMC_IDEATI # "1"))
		HS_MsgInf(STR0064, STR0034, STR0147) //"Ato mÈdico est· inativo."###"AtenÁ„o"###"ValidaÁ„o do ato mÈdico"
	EndIf
	If cAliasPR == "GE7" .Or. (cAliasPR == "GD7" .And. FunName() == "HSPAHP12") .Or. lIsCaixa
		If lRet := HS_VProHon(cGczCodPla, IIF(lIsCaixa, cGcsCodLoc, oGDPR:aCols[oGDPR:nAt, nPRCODLOC]), oGDPR:aCols[oGDPR:nAt, nPRCODDES], lVldPreco,, ;
			oGDPR:aCols[oGDPR:nAt, nPRHORDES], "2", oGDPR:aCols[oGDPR:nAt, nPRCodCrm], ;
			&(ReadVar()), {cGcyAtendi, M->GCY_ATORIG, M->GCY_IDADE, M->GCY_SEXO, M->GCY_CARATE},, oGDPR:aCols[oGDPR:nAt, nPRDATDES])[1]
			lRet := HS_CalcDsc()
		EndIf
	EndIf
ElseIf nVld == 19
	IF !(lRet := (Empty(&("M->" + PrefixoCpo(cAliasPR) + "_CRMLAU")) .Or. ;
		HS_SeekRet("SRA","'" + &("M->" + PrefixoCpo(cAliasPR) + "_CRMLAU") + "'", 11, .F., PrefixoCpo(cAliasPR) + "_NMELAU", "RA_NOME",,, .T.)))
		HS_MsgInf(STR0058, STR0034, STR0135) //"Profissional n„o encontrado."###"AtenÁ„o"###"ValidaÁ„o do MÈdico"
	EndIf
ElseIf nVld == 20

	If dDataMM <> Nil .Or. (SubStr(ReadVar(), 8) $ "DATDES/HORDES")
		dDataMM := IIF((SubStr(ReadVar(), 8) == "DATDES"), M->GD5_DATDES, oGDMM:aCols[oGDMM:nAt, nMMDATDES])
		cHoraMM := IIF((SubStr(ReadVar(), 8) == "HORDES"), M->GD5_HORDES, SUBSTR(oGDMM:aCols[oGDMM:nAt, nMMHORDES], 1, 5))

		If (SubStr(ReadVar(), 8) $ "DATDES/HORDES") .And. Type(ReadVar()) <> "U"
			If M->GCY_DATALT == dDataMM  .AND. cHoraMM > M->GCY_HORALT
				oGDMM:aCols[oGDMM:nAt, nMMHORDES] := M->GCY_HORALT
				oGDMM:Refresh()
				cHoraMM := SUBSTR(oGDMM:aCols[oGDMM:nAt, nMMHORDES], 1, 5)
			Endif
		Endif

		lMovEst := (aConEst := HS_CONEST(oGDMM:aCols[oGDMM:nAt, nMMCODDES], IIF(nMMCodLoc == 0, cLctCodLoc, oGDMM:aCols[oGDMM:nAt, nMMCodLoc]))[1]) .And. ;
		IIf(FunName() == "HSPAHP12", cMovest == "S", .T.) // Validacao da movimentacao do estoque para auditoria

		If !Empty(dMvUlmes) .AND. !(lRet := !(!(dDataMM  > dMvUlmes))) .And. lMovest
			HS_MsgInf(STR0109, STR0034, STR0110) //"A Data do lanÁamento da despesa È menor ou igual ao ˙ltimo fechamento de estoque, n„o ser· possÌvel efetuar o lanÁamento."###"AtenÁ„o"###"LanÁamento Mat/Med"
		Else

			If !EMPTY(M->GCY_TPALTA) .And. !Empty(oGDGcz:aCols[oGDGcz:nAt, Iif(Empty(nGCZNRSEQG), 30, nGCZNRSEQG) ])
				If FunName() <> "HSPAHP12"
					DbSelectArea("GCZ")
					DbSetOrder(2) //filial+regate
					If DbSeek(xFilial("GCZ")+ M->GCY_REGATE + "0" + oGDGcz:aCols[oGDGcz:nAt, nGCZNRSEQG])
						If cMvMMAlt == "N"
							HS_MsgInf(STR0111, STR0034, STR0110) //"Atendimento n„o pode ter movimentaÁıes de mat/med."###"AtenÁ„o"###"LanÁamento Mat/Med"
							Return .F.
						Endif
					Else
						HS_MsgInf(STR0132, STR0034, STR0110)//"N„o existe  guia em aberto para este atendimento."###"AtenÁ„o"###"LanÁamento Mat/Med"
						Return .F.
					Endif
				Endif
			Endif
			If !HS_VldHora(cHoraMM)
				HS_MsgInf("A hora do lanÁamento da despesa [" + cHoraMM + "] deve estar ente 00:00 e 23:59.", "AtenÁ„o", "LanÁamento de despesas")
				lRet := .F.
			ElseIf !(lRet := !(dDataMM  < M->GCY_DATATE .Or. (dDataMM  == M->GCY_DATATE .And. cHoraMM < substr(M->GCY_HORATE,1,5))))
				HS_MsgInf(STR0112, STR0034, STR0110)  //"Despesa n„o pode ser lanÁada com data anterior a data do atendimento."###"AtenÁ„o"###"LanÁamento Mat/Med"
			ElseIf !Empty(M->GCY_DATALT) .AND. !(lRet := !(dDataMM   > M->GCY_DATALT .Or. (dDataMM  == M->GCY_DATALT .And. cHoraMM > M->GCY_HORALT)))
				HS_MsgInf(STR0113, STR0034, STR0110) //"Despesa n„o pode ser lanÁada com data posterior a data da alta."###"AtenÁ„o"###"LanÁamento Mat/Med"
			ElseIf !(lRet := !(dDataMM  > dDataBase .Or. (dDataMM  == dDataBase .And. cHoraMM > Time())))
				HS_MsgInf(STR0133, STR0034, STR0110) //"Despesa n„o pode ser lanÁada com data posterior a data corrente.""###"AtenÁ„o"###"LanÁamento Mat/Med"
			Endif
		Endif
	Endif

ElseIf nVld == 21  //Codigo Motivo Cobranca AIH
	If !(lRet := HS_SeekRet("GH8","M->GCZ_CMCAIH",1,.F.,"GCZ_DMCAIH","GH8_DMCAIH",,.T.) )
		HS_MsgInf(STR0114, STR0034, STR0115) //"Motivo de CobranÁa n„o cadastrado."###"AtenÁ„o"###"Cadastro Motivo de CobranÁa"
	EndIf

ElseIf nVld == 22 //Codigo Oficio
	If !(lRet := HS_SeekRet("GH2","M->GCZ_CDCBOR",1,.F.,"GCZ_DSCBOR","GH2_DESCBO",,.T.) )
		HS_MsgInf(STR0116, STR0034, STR0117) //"OfÌcio n„o cadastrado"###"AtenÁ„o"###"Cadastro OfÌcio"
	EndIf

ElseIf nVld == 23 //Codigo Nac. Atv Economica
	If !(lRet := HS_SeekRet("GHB","M->GCZ_CDCCNA",1,.F.,"GCZ_DESCNA","GHB_DESCNA",,.T.) )
		HS_MsgInf(STR0118, STR0034, STR0119) //"CÛdigo nacional de atividade econÙmica n„o cadastrado."###"AtenÁ„o"###"Cadastro Nac. Ativ. Econ."
	EndIf

ElseIf nVld == 24 //Campos RNs
	For nCont := 1 To Len(oGDPR:aCols)
		If !oGDPR:aCols[nCont, Len(oGDPR:aHeader) + 1]
			If lRet := AllTrim(oGDPR:aCols[nCont, nPRCODDES]) $ cMvPRPARTO
				Exit
			Else
				lRet := .F.
			EndIf
		EndIf
	Next

ElseIf nVld == 25 //Data autorizacao
	If GCZ->GCZ_CODPLA == __cCodAIH
		If !(lRet := M->GCZ_DATAUT >= M->GCY_DATATE)
			HS_MsgInf(STR0120, STR0034, STR0121) //"Data da AutorizaÁ„o inferior a data do Atendimento."###"AtenÁ„o"###"ValidaÁ„o de campos"
		ElseIf !(lRet := M->GCZ_DATAUT <= DDATABASE)
			HS_MsgInf(STR0122, STR0034, STR0121) //"Data da AutorizaÁ„o superior a data atual."###"AtenÁ„o"###"ValidaÁ„o de campos"
		EndIf
	ElseIf !(lRet := !(!Empty(M->GCY_DATALT) .And. M->GCZ_DATAUT >	M->GCY_DATALT))
		HS_MsgInf(STR0259, STR0034, STR0260)  //"Data de autorizaÁ„o superior a data da alta."###"AtenÁ„o"###"ValidaÁ„o da data de autorizaÁ„o"
	EndIf

ElseIf nVld == 26 //Proced. Autor.
	If ReadVar() == "M->GCZ_CPRAU1"
		If !(lRet := HS_SeekRet("GA7","M->GCZ_CPRAU1",1,.F.,"GCZ_DPRAU1","GA7_DESC",,.T.) )
			HS_MsgInf(STR0123, STR0034, STR0124) //"CÛdigo do Procedimento n„o cadastrado."###"AtenÁ„o"###"Cadastro Procedimento"
		EndIf
	ElseIf ReadVar() == "M->GCZ_CPRAU2"
		If !(lRet := HS_SeekRet("GA7","M->GCZ_CPRAU2",1,.F.,"GCZ_DPRAU2","GA7_DESC",,.T.) )
			HS_MsgInf(STR0123, STR0034, STR0124) //"CÛdigo do Procedimento n„o cadastrado."###"AtenÁ„o"###"Cadastro Procedimento"
		EndIf
	ElseIf ReadVar() == "M->GCZ_CPRAU3"
		If !(lRet := HS_SeekRet("GA7","M->GCZ_CPRAU3",1,.F.,"GCZ_DPRAU3","GA7_DESC",,.T.) )
			HS_MsgInf(STR0123, STR0034, STR0124) //"CÛdigo do Procedimento n„o cadastrado."###"AtenÁ„o"###"Cadastro Procedimento"
		EndIf
	ElseIf ReadVar() == "M->GCZ_CPRAU4"
		If !(lRet := HS_SeekRet("GA7","M->GCZ_CPRAU4",1,.F.,"GCZ_DPRAU4","GA7_DESC",,.T.) )
			HS_MsgInf(STR0123, STR0034, STR0124) //"CÛdigo do Procedimento n„o cadastrado."###"AtenÁ„o"###"Cadastro Procedimento"
		EndIf
	ElseIf ReadVar() == "M->GCZ_CPRAU5"
		If !(lRet := HS_SeekRet("GA7","M->GCZ_CPRAU5",1,.F.,"GCZ_DPRAU5","GA7_DESC",,.T.) )
			HS_MsgInf(STR0123, STR0034, STR0124) //"CÛdigo do Procedimento n„o cadastrado."###"AtenÁ„o"###"Cadastro Procedimento"
		EndIf
	EndIf

ElseIf nVld == 27 //Acompanhante
	If M->GCY_ACOMPA == "1" //Nao
		lRet := .F.
		M->GCY_NMACOM := SPACE(LEN(GCY->GCY_NMACOM))
	EndIf

ElseIf nVld == 29
	If ReadVar() == "M->" + PrefixoCpo(cAliasPR) + "_CODCID"
		If!(lRet := HS_SeekRet("GAS","'" + &("M->" + PrefixoCpo(cAliasPR) + "_CODCID") + "'", 1, .F.,,,,.T.))
			HS_MsgInf(STR0125, STR0034, STR0126) //"CÛdigo do CID n„o cadastrado."###"AtenÁ„o"###"LanÁamento de Despesas"
		EndIf
		If!(lRet := HS_SeekRet("GHH","'" + oGDPR:aCols[oGDPR:nAt, nPRCODDES] + &("M->" + PrefixoCpo(cAliasPR) + "_CODCID") + "'", 1, .F.,,,,.T.))
			HS_MsgInf(STR0183 + " [" + oGDPR:aCols[oGDPR:nAt, nPRCODDES] + "]", STR0034, STR0126) //"O CID informado nao est· relacionado com o procedimento"###"AtenÁ„o"###"LanÁamento de Despesas"
		EndIf
	ElseIf ReadVar() == "M->" + PrefixoCpo(cAliasPR) + "_CIDSEC"
		If !(Empty(&("M->" + PrefixoCpo(cAliasPR) + "_CIDSEC")))
			If!(lRet := HS_SeekRet("GAS","'" + &("M->" + PrefixoCpo(cAliasPR) + "_CIDSEC") + "'", 1, .F.,,,,.T.))
				HS_MsgInf(STR0125, STR0034, STR0126) //"CÛdigo do CID n„o cadastrado."###"AtenÁ„o"###"LanÁamento de Despesas"
			EndIf
			If!(lRet := HS_SeekRet("GHH","'" + oGDPR:aCols[oGDPR:nAt, nPRCODDES] + &("M->" + PrefixoCpo(cAliasPR) + "_CIDSEC") + "'", 1, .F.,,,,.T.))
				HS_MsgInf(STR0183 + " [" + oGDPR:aCols[oGDPR:nAt, nPRCODDES] + "]", STR0034, STR0126) //"O CID informado nao est· relacionado com o procedimento"###"AtenÁ„o"###"LanÁamento de Despesas"
			EndIf
		EndIf

	ElseIf ReadVar() == "M->" + PrefixoCpo(cAliasPR) + "_CDGATE"
		If !(lRet := HS_SeekRet("GH3","'" + &("M->" + PrefixoCpo(cAliasPR) + "_CDGATE") + "'", 1, .F., PrefixoCpo(cAliasPR) + "_DSGATE", "GH3_DSGATE",,.T.))
			HS_MsgInf(STR0128, STR0034, STR0126) //"CÛdigo do grupo de atendimento n„o cadastrado."###"AtenÁ„o"###"LanÁamento de Despesas"
		ElseIf !(lRet := HS_SeekRet("GHF","'" + oGDPR:aCols[oGDPR:nAt, nPRCODDES] + &("M->" + PrefixoCpo(cAliasPR) + "_CDGATE") + "'", 1, .F.,,,,.T.))
			HS_MsgInf(STR0185 + " [" + oGDPR:aCols[oGDPR:nAt, nPRCODDES] + "]", STR0034, STR0126) //"O Grupo de Atendimento informado n„o est· relacionado com o procedimento."###"AtenÁ„o"###"LanÁamento de Despesas"
		Else
			cCodFEta := HS_FEtaria(M->GCY_REGATE)
			aRetGAte := HS_RetGAte(oGDPR:aCols[oGDPR:nAt, nPRCODDES], cCodFEta)
			If aRetGAte[2] .And. !(lRet := &(ReadVar()) == aRetGAte[1]) //tem relacionamento com faixa etaria
				HS_MsgInf(STR0208, STR0034, STR0126)
			EndIf
		EndIf

	ElseIf ReadVar() == "M->" + PrefixoCpo(cAliasPR) + "_CDTATE"
		If!(lRet := HS_SeekRet("GH4","'" + &("M->" + PrefixoCpo(cAliasPR) + "_CDTATE") + "'", 1, .F., PrefixoCpo(cAliasPR) + "_DSTATE", "GH4_DSTATE",,.T.))
			HS_MsgInf(STR0129, STR0034, STR0126) //"CÛdigo do tipo de atendimento n„o cadastrado."###"AtenÁ„o"###"LanÁamento de Despesas"
		EndIf
		If!(lRet := HS_SeekRet("GHG","'" + oGDPR:aCols[oGDPR:nAt, nPRCODDES] + &("M->" + PrefixoCpo(cAliasPR) + "_CDTATE") + "'", 1, .F.,,,,.T.))
			HS_MsgInf(STR0186 + " [" + oGDPR:aCols[oGDPR:nAt, nPRCODDES] + "]", STR0034, STR0126) //"O Tipo de Atendimento informado n„o est· relacionado com o procedimento."###"AtenÁ„o"###"LanÁamento de Despesas"
		EndIf
	Endif

ElseIf nVld == 30
	If cMv_Atesus == "S"
		If FunName() <> "HSPAHP12" .AND. oGDGcz:aCols[oGDGcz:nAt, nGczCodPla] $ __cCodBPA+"/"+__cCodPAC+"/"+__cCodAIH
			HS_MsgInf(STR0130, STR0034, STR0131) //"AlteraÁ„o n„o permitida para este plano."###"AtenÁ„o"###"ValidaÁ„o Nr guia"
			lRet := .F.
		ElseIf FunName() == "HSPAHP12" .AND. oGDGcz:aCols[oGDGcz:nAt, nGczCodPla] == __cCodBPA
			HS_MsgInf(STR0130, STR0034, STR0131) //"AlteraÁ„o n„o permitida para este plano."###"AtenÁ„o"###"ValidaÁ„o Nr guia"
			lRet := .F.
		Endif
	Endif
	If lRet
		If !(lVldGui := HS_VLDGUI(oGDGcz:aCols[oGDGcz:nAt, nGczCodPla]))
			lRet := .F.
		Endif
	Endif

	If lVldGui .AND. oGDGcz:aCols[oGDGcz:nAt, nGczCodPla] == __cCodAIH .AND. FunName() == "HSPAHP12"
		If HS_CountTB("GCZ", "GCZ_NRGUIA  = '" + M->GCZ_NRGUIA + "' AND GCZ_REGATE = '"+ M->GCY_REGATE + "' ") > 0
			oGDGcz:aCols[oGDGcz:nAt, nGczIdGuia] := "5"
		Else
			oGDGcz:aCols[oGDGcz:nAt, nGczIdGuia] := "1"
		Endif
	Endif
ElseIf nVld == 31  // Validacao dos campos GCY_NMBENE e GCY_HOSBEN
	If ReadVar() == "M->GCY_NMBENE" .And. !Empty(M->GCY_NMBENE)
		If !(lRet := HS_SeekRet('GBH','M->GCY_NMBENE',1,.F.,'GCY_DSBENE','GBH_NOME'))
			HS_MsgInf("Este doador n„o existe", "AtenÁ„o", "ValidaÁ„o de doador")
		EndIf
	EndIf

	If ReadVar() == "M->GCY_CDMOTD"
		M->GCY_NMBENE := Space(Len(GCY->GCY_NMBENE))
		M->GCY_DSBENE := Space(Len(GCY->GCY_DSBENE))
		M->GCY_HOSBEN := Space(Len(GCY->GCY_HOSBEN))
	EndIf

	If ReadVar() == "M->GCY_DSBENE" .And. !Empty(cGbhCodPac)
		M->GCY_NMBENE := cGbhCodPac
	EndIf

ElseIf nVld == 32 // Tipo de Doacao
	If !(lRet := HS_SeekRet("GGE", "M->GCY_CDTIPD", 1, .F., "GCY_DSTIPD", "GGE_DSTIPD"))
		HS_MsgInf(STR0176, STR0034, STR0177)//"Este tipo de doaÁ„o n„o existe."###"AtenÁ„o"###"ValidaÁ„o de Tipo de DoaÁ„o"
	ElseIf !(lRet := FS_VldInt())
		Return(.F.)
	EndIf
ElseIf nVld == 33 // ValidaÁ„o do RG do paciente

	If !Empty(M->GCY_RG) .And. !Empty(M->GCY_ORGEMI) .And. !Empty(M->GCY_UFEMIS)
		If (lRet := HS_SeekRet("GBH","M->GCY_RG + M->GCY_ORGEMI + M->GCY_UFEMIS", 6, .F., "GCY_REGGER", "GBH_CODPAC",,, .T.))
			cGbhRg    := M->GCY_RG
			cGbhRgOrg := M->GCY_ORGEMI
			cGbhUFEmis := M->GCY_UFEMIS
			lTmpInclui := Inclui
			lTmpAltera := Altera
			Inclui := .F.
			Altera := .T.
			HS_A58('GBH', GBH->(RecNo()), 4)
			Inclui := lTmpInclui
			Altera := lTmpAltera

			// Retorna os Valores da AlteraÁ„o do Paciente
			M->GCY_RG     := cGbhRg
			M->GCY_RGORG  := cGbhRgOrg
			M->GCY_UFEmis := cGbhUFEmis
			HS_VldM24(, 4)
		Else
			// Funcao que limpa o historico de conteudo dos parametros
			HS_PosSX1({{"HSM24D", "01", Nil}, {"HSM24D", "02", Nil}, {"HSM24D", "03", Nil}, {"HSM24D", "04", Nil}, {"HSM24D", "05", Nil}, {"HSM24D", "06", Nil}, {"HSM24D", "07", Nil}, {"HSM24D", "08", Nil}})

			If Pergunte("HSM24D", .T.)
				cFiltro := HS_FilRG()
				If lRet := HS_ConPac(, .F., cFiltro)
					M->GCY_REGGER := GBH->GBH_CODPAC
					lRet := HS_VldM24(, 4)
				EndIf
			EndIf
		EndIf

		If !FS_VldInap(M->GCY_REGGER)
			Return(.F.)
		ElseIf Empty(M->GCY_CDTIPD)
			If !FS_VldPer(cSexo)
				Return(.F.)
			EndIf
		EndIf

	EndIf

ElseIf nVld == 34 // ValidaÁ„o do CODDES TISS
	If !EMPTY(M->GCZ_CODDES) .And. !(lRet := HS_SeekRet("GA7", "M->GCZ_CODDES", 1, .F., "GCZ_DDESPE", "GA7_DESC",,, .T.))
		HS_MsgInf(STR0123, STR0034, STR0121) //"CÛdigo do Procedimento n„o cadastrado."###"AtenÁ„o"###"ValidaÁ„o de campos"
	ElseIf !EMPTY(M->GCZ_CODDES) .And. !(lRet := HS_SeekRet("GCX", "oGDGcz:aCols[oGDGcz:nAt, nGCZCODTPG]+M->GCZ_CODDES", 1, .F.,,,,,.T.))
		HS_MsgInf(STR0092 + AlLTrim(M->GCZ_CODDES) + STR0093 , STR0013, STR0157) // "AtenÁ„o" //"O procedimento ["###"] n„o È permitido no tipo de guia informado" //"Procedimento"
	ElseIf !EMPTY(M->GCZ_CODDES) .And. !(lRet := HS_SeekRet("GM2", "M->GCY_LOCATE+M->GCZ_CODDES", 1, .F.,,,,,.T.))
		HS_MsgInf(STR0092 + AlLTrim(M->GCZ_CODDES) +  STR0279, STR0013, STR0157)  //"O procedimento ["###"] n„o È permitido no setor."
	Else
		aRValDes := HS_RValPr(M->GCZ_CODDES, oGDGcz:aCols[oGDGcz:nAt, nGczCodPla], M->GCY_LOCATE, Time(), "2", "",, {M->GCY_ATENDI, M->GCY_ATORIG, M->GCY_IDADE, M->GCY_SEXO, M->GCY_CARATE},, DDATABASE)
		oGDGcz:aCols[oGDGcz:nAt, nGczCodPrt] := aRValDes[2][15]
	EndIf

ElseIf nVld == 35 // ValidaÁ„o do TATIS
	If !EMPTY(M->GCZ_TATISS) .And. !(lRet := HS_SeekRet("G08", "M->GCZ_TATISS", 1, .F., "GCZ_DTATIS", "G08_DESCRI",,, .T.))
		HS_MsgInf(STR0129, STR0034, STR0121) //"CÛdigo do tipo de atendimento n„o cadastrado."###"AtenÁ„o"###"ValidaÁ„o de campos"
	EndIf

ElseIf nVld == 36 // ValidaÁ„o do TIPCON
	If !EMPTY(M->GCZ_TIPCON) .And. !(lRet := HS_SeekRet("G12", "M->GCZ_TIPCON", 1, .F., "GCZ_DTIPCO", "G12_DESCRI",,, .T.))
		HS_MsgInf(STR0229, STR0034, STR0121) //"Tipo de Consulta n„o encontrado"###"AtenÁ„o"###"ValidaÁ„o de campos"
	EndIf

ElseIf nVld == 37
	If !Vazio() .And. (!(lRet := HS_SeekRet("SRA","M->GCY_CRMALT", 11, .F., "GCY_MEDALT", "RA_NOME",,, .T.)) .Or. ;
		!(lRet := HS_SeekRet("GBJ","M->GCY_CRMALT",  1, .F.,,,,, .T.)))

		HS_MsgInf(STR0038, STR0034, STR0135) //"CRM do profissional n„o encontrado."###"AtenÁ„o"###"ValidaÁ„o do MÈdico"

	ElseIf GBJ->GBJ_STATUS # "1"
		HS_MsgInf(STR0061, STR0034, STR0135) //"MÈdico encontra-se inativo em seu cadastro."###"AtenÁ„o"###"ValidaÁ„o do MÈdico"
		lRet := .F.
	EndIf

ElseIf nVld == 38 // ValidaÁ„o do CODDES
	If SubStr(ReadVar(), 4, 3) $ "GD5/GE5"
		If lRet := HS_VCodBar(@&(ReadVar()), cAliasMM + "_CODDES",,, HS_M24LOCK("GD5"), .F.) 
		    oGDMM:aCols[oGDMM:nAt,  nMMProAlt]:=" "
		    oGDMM:aCols[oGDMM:nAt,  nMMDPrAlt]:=" "
		    
			lRet := HS_CalcDsc()
		EndIf

	ElseIf SubStr(ReadVar(), 4, 3) $ "GD6/GE6"
		If !(lRet := &("M->" + cAliasTD + "_CODDES") <> PADR(cMvTxSrv, Len(GD6->GD6_CODDES)))
			HS_MsgInf(STR0281, STR0034, STR0282)   //"Taxa/Di·ria n„o pode ser lanÁada para paciente, pois È utilizada para c·lculo de taxa/serviÁo."###"AtenÁ„o"###"ValidaÁ„o de taxa/di·ria"
		EndIf

		If lRet
			If lRet := HS_VTaxDia(cGczCodPla, cGcsCodLoc, &(ReadVar()),,,, oGDTD:aCols[oGDTD:nAt, nTDDatDes],HS_RetCrm(oGDTD:aCols, oGDTD:nAt, nTDCodCrm, M->GCY_CODCRM), oGDTD:aCols[oGDTD:nAt, nTDHorDes], {cGcyAtendi, M->GCY_CARATE}, .T.)

				If !Empty(oGDTD:aCols[oGDTD:nAt, nTDCodCrm])//SimulaÁ„o de digitaÁ„o do CRM
					cVldCrm := HS_CfgSx3(cAliasTD + "_CODCRM")[SX3->(FieldPos("X3_VALID"))]
					cVldUsr := HS_CfgSx3(cAliasTD + "_CODCRM")[SX3->(FieldPos("X3_VLDUSER"))]

					cOldReadVar := ReadVar()
					__ReadVar := "M->" + cAliasTD + "_CODCRM"
					&("M->" + cAliasTD + "_CODCRM") := oGDTD:aCols[oGDTD:nAt, nTDCodCrm]
					lRet := IIf(!Empty(cVldCrm), &(cVldCrm), .T.) .And. IIf(!Empty(cVldUsr), &(cVldUsr), .T.)
					__ReadVar := cOldReadVar
				EndIf
			EndIf
		EndIf

		lRet := lRet .And. HS_CalcDsc()

	ElseIf SubStr(ReadVar(), 4, 3) $ "GD7/GE7"
		If lExDicSt //Verifica se pode haver alteracao caso o item esteja em processo de autorizacao
			If !Empty(oGDPR:aCols[oGDPR:nAt, nPRSeqDes])
				cStatus := HS_VSTAUT(oGDPR:aCols[oGDPR:nAt, nPRSeqDes], "GE3")
				If cStatus == "1" .OR. cStatus == "2"
					HS_MsgInf(STR0295, STR0034, STR0121)
					Return(.F.)
				EndIf
			EndIf
		EndIf
		If !(lRet := HS_VProced(cGczCodPla, cGcsCodLoc, &(ReadVar()),,,,,,,,, oGDPR:aCols[oGDPR:nAt, nPRDATDES],,IIF(lAteSUS .And. IIF(!Empty(GCZ->GCZ_CODPLA),GCZ->GCZ_CODPLA,cGczCodPla) $ __cCodAIH,oGDPR:aCols[oGDPR:nAt, nPRQTDDES],NIL))) .And. !EMPTY(&(ReadVar()))
			oGDPR:aCols[oGDPR:nAt, nPRCODCRM] := SPACE(Len(GD7->GD7_CODCRM))
			oGDPR:aCols[oGDPR:nAt, nPRNOMMED] := SPACE(Len(SRA->RA_NOME))
			lPrc := lRet
			lRet := HS_CalcDsc()
		EndIf
	EndIf

	If lRet .And. cGcyAtendi $ '1/2/4'
		HS_VldAuto(&("oGD"+IIF(SubStr(ReadVar(), 4, 3) $ "GD7/GE7","PR","MM")+":aCols[oGD"+IIF(SubStr(ReadVar(), 4, 3) $ "GD7/GE7","PR","MM")+":nAt, n"+IIF(SubStr(ReadVar(), 4, 3) $ "GD7/GE7","PR","MM")+"DatDes]"))
	EndIf

	If SubStr(ReadVar(), 4, 3) $ "GD7"  .And. lAteSUS .And. GCZ->GCZ_CODPLA $ __cCodAIH .And. cGcyAtendi == '0'  .And. FunName() == "HSPAHP12"
		cProcedSUS := HS_IniPadr("GA7", 1, M->GD7_CODDES, "GA7_CODSUS",,.F.)
		If !Empty(cProcedSUS)
			If lRet .And. (SubStr(M->GD7_CODDES, 1, 2) == '07'  .OR. SubStr(cProcedSUS, 1, 2) == '07') .And. !Empty(cMedPadr)
				oGDPR:aCols[oGDPR:nAt, nPRCODCRM] := cMedPadr + SPACE(LEN(M->GCY_CODCRM) - Len(cMedPadr))
				oGDPR:aCols[oGDPR:nAt, nPRNOMMED] := Iif(HS_SeekRet("SRA", "'" + cMedPadr + "'",  11, .F.,,,,, .T.) , SRA->RA_NOME,"")

			ElseIf lRet .And. ((SubStr(M->GD7_CODDES, 1, 6) == '080201' .OR. SubStr(cProcedSUS, 1, 6) == '080201') .OR. (AllTrim(M->GD7_CODDES) $ Alltrim(cProReg).OR. AllTrim(cProcedSUS) $ Alltrim(cProReg)))
				oGDPR:aCols[oGDPR:nAt, nPRCODCRM] := M->GCY_CODCRM
				oGDPR:aCols[oGDPR:nAt, nPRNOMMED] := Iif(HS_SeekRet("SRA", "'" + M->GCY_CODCRM + "'",  11, .F.,,,,, .T.) , SRA->RA_NOME,"")
			EndIf
		Else
			If lRet .And. SubStr(M->GD7_CODDES, 1, 2) == '07' .And. !Empty(cMedPadr)
				oGDPR:aCols[oGDPR:nAt, nPRCODCRM] := cMedPadr + SPACE(LEN(M->GCY_CODCRM) - Len(cMedPadr))
				oGDPR:aCols[oGDPR:nAt, nPRNOMMED] := Iif(HS_SeekRet("SRA", "'" + cMedPadr + "'",  11, .F.,,,,, .T.) , SRA->RA_NOME,"")
			ElseIf lRet .And. (SubStr(M->GD7_CODDES, 1, 6) == '080201' .oR. AllTrim(M->GD7_CODDES) $ Alltrim(cProReg))
				oGDPR:aCols[oGDPR:nAt, nPRCODCRM] := M->GCY_CODCRM
				oGDPR:aCols[oGDPR:nAt, nPRNOMMED] := Iif(HS_SeekRet("SRA", "'" + M->GCY_CODCRM + "'",  11, .F.,,,,, .T.) , SRA->RA_NOME,"")
			EndIf
		EndIf

		lVldPreco := !(oGDGcz:aCols[oGDGcz:nAt, nGczCodPla] $ __cCodBPA+"/"+__cCodPAC+"/"+__cCodAIH)

		If lRet := HS_VProHon(cGczCodPla, IIF(lIsCaixa, cGcsCodLoc, oGDPR:aCols[oGDPR:nAt, nPRCODLOC]), M->GD7_CODDES, lVldPreco,, ;
			oGDPR:aCols[oGDPR:nAt, nPRHORDES], "2", oGDPR:aCols[oGDPR:nAt, nPRCODCRM], ;
			oGDPR:aCols[oGDPR:nAt, nPRCODATO], {cGcyAtendi, M->GCY_ATORIG, M->GCY_IDADE, M->GCY_SEXO, M->GCY_CARATE},, oGDPR:aCols[oGDPR:nAt, nPRDATDES],,IIF(lAteSUS .And. GCZ->GCZ_CODPLA $ __cCodAIH,oGDPR:aCols[oGDPR:nAt, nPRQTDDES],""))[1]
			lRet := HS_CalcDsc()
		EndIf

		If lPrc
			//	If  Alltrim(M->GD7_CODDES) $ Alltrim(cPrAIH)
			If	AllTrim(M->GD7_CODDES) $ GetMV("MV_PRPARTO") .OR. AllTrim(IIf(Empty(cProcedSUS),M->GD7_CODDES,cProcedSUS)) $ GetMV("MV_PRPARTO")
				HS_PrParto()  // Tratamento dos dados referentes ao parto
			EndIf

			If  SubStr(AllTrim(M->GD7_CODDES), 1, 2) == '07' .OR.  SubStr(AllTrim(IIf(Empty(cProcedSUS),M->GD7_CODDES,cProcedSUS)), 1, 2)  == '07'
				HS_PrcOPM ()  // Tratamento dos procedimentos de OPM
			EndIf

			If  AllTrim(M->GD7_CODDES) $ Alltrim(cDiaUti)  .OR.  AllTrim(IIf(Empty(cProcedSUS),M->GD7_CODDES,cProcedSUS)) $ Alltrim(cDiaUti)
				HS_PrcDia() // tratamento dos procedimentod de diaria
			EndIf

			If  AllTrim(M->GD7_CODDES) $ Alltrim(cProcLaq) .OR.  AllTrim(IIf(Empty(cProcedSUS),M->GD7_CODDES,cProcedSUS)) $ Alltrim(cProcLaq)
				HS_PrcLaq()   // Tratamento dos dados de Laqueadura
			EndIf

			If	AllTrim(M->GD7_CODDES) $ Alltrim(cProReg)  .OR.  AllTrim(IIf(Empty(cProcedSUS),M->GD7_CODDES,cProcedSUS)) $ Alltrim(cProReg)
				HS_PrcReg()    // Tratamento dos dados do Registro de Nascimento
			EndIf
		EndIf
	EndIf


ElseIf nVld == 39 // ValidaÁ„o do Data Inicial e Final da Guia quando Atendimento for APAC
	If ReadVar() == "M->GCZ_VGUIAI"
		If (!Empty(oGDGcz:aCols[oGDGcz:nAt, nPrVguiaI])) .And. (!Empty(oGDGcz:aCols[oGDGcz:nAt, nPrVguiaF]))
			If M->GCZ_VGUIAI >  oGDGcz:aCols[oGDGcz:nAt, nPrVguiaF]
				Hs_MsgInf(STR0167, STR0034, STR0249)//"Data inv·lida"###"AtenÁ„o"###"ValidaÁ„o da v·lida da guia SUS APAC"
				lRet := .F.
			EndIf
		EndIf
	ElseIf ReadVar() == "M->GCZ_VGUIAF"
		If (!Empty(oGDGcz:aCols[oGDGcz:nAt, nPrVguiaI])) .And. (!Empty(oGDGcz:aCols[oGDGcz:nAt, nPrVguiaF]))
			If oGDGcz:aCols[oGDGcz:nAt, nPrVguiaI] >  M->GCZ_VGUIAF
				Hs_MsgInf(STR0167, STR0034, STR0249)//"Data inv·lida"###"AtenÁ„o"###"ValidaÁ„o da v·lida da guia SUS APAC"
				lRet := .F.
			EndIf
		EndIf
	ElseIf ReadVar() == "M->GCZ_TPAPAC"
		If M->GCZ_TPAPAC # GCZ->GCZ_TPAPAC
			If M->GCZ_TPAPAC $ "13"
				If HS_CountTB("GCZ", "GCZ_NRGUIA  = '" + oGDGcz:aCols[oGDGcz:nAt, nGCZNrGuia] + "' AND GCZ_TPAPAC = '"+M->GCZ_TPAPAC+"'")  > 0
					Hs_MsgInf(STR0251,STR0034,STR0250)//"N˙mero da guia j· cadastrado com esse tipo de APAC."###AtenÁ„o###"ValidaÁ„o Nr. da Guia APAC"
					lRet := .F.
				EndIf
			ElseIf (M->GCZ_TPAPAC == "2")
				If (HS_CountTB("GCZ", "GCZ_NRGUIA  = '" + oGDGcz:aCols[oGDGcz:nAt, nGCZNrGuia] + "' AND GCZ_TPAPAC = '1' ")  == 0)//.Or.(GCZ->GCZ_TPAPAC == "1")
					Hs_MsgInf(STR0252,STR0034,STR0250)//"N„o h· guia inicial para essa guia."###AtenÁ„o###"ValidaÁ„o Nr. da Guia APAC"
				EndIf
			EndIf
		EndIf
	ElseIf ReadVar() == "M->GCZ_CMCPAC"
		If HS_CountTB("GH7", "GH7_CMCPAC  = '" + M->GCZ_CMCPAC + "'")  == 0
			Hs_MsgInf(STR0114,STR0034,STR0253)//"Motivo de CobranÁa n„o cadastrado."###AtenÁ„o###"ValidaÁ„o Motivo de CobranÁa"
			lRet := .F.
		EndIf
	EndIf

ElseIf nVld == 40 // ValidaÁ„o dos Valores de Desconto
	lRet := Positivo() .And. HS_CalcDsc() //Calcula Desconto e Valida se usuario pode aplicar o desc.

ElseIf nVld == 41 //ValidaÁ„o da Obs. do desconto
	If ReadVar() $ "M->GD5_DESOBS/M->GE5_DESOBS"
		lRet := oGDMM:aCols[oGDMM:nAt, nMMDESVAL] > 0
	ElseIf ReadVar() $ "M->GD6_DESOBS/M->GE6_DESOBS"
		lRet := oGDTD:aCols[oGDTD:nAt, nTDDesVal] > 0
	ElseIf ReadVar() $ "M->GD7_DESOBS/M->GE7_DESOBS"
		lRet := oGDPR:aCols[oGDPR:nAt, nPRDesVal] > 0
	EndIf
	If !lRet
		HS_MsgInf(STR0268, STR0034, STR0269)//"ImpossÌvel preencher o campo ObservaÁ„o do desconto, pois o valor do desconto est· zerado."###"AtenÁ„o"###"ValidaÁ„o de Desconto"
	EndIf

ElseIf nVld == 42 //ValidaÁ„o do PGTMED
	If lRet := Pertence("0123") .And. HS_GDAtrib(oGDPR, {{nPRStaReg, "BR_AMARELO", "BR_VERDE"}})
		If &(ReadVar()) == "0"
			lRet := HS_CalcDsc()
		EndIf
	EndIf
ElseIf nVld == 43
	If lRet := Pertence('012') .And. HS_GDAtrib(oGDPR, {{nPRStaReg, 'BR_AMARELO', 'BR_VERDE'}})
		If cAliasPR == "GE7" .Or. (cAliasPR == "GD7" .And. FunName() == "HSPAHP12")
			If lRet := HS_VProHon(cGczCodPla, oGDPR:aCols[oGDPR:nAt, nPRCODLOC], oGDPR:aCols[oGDPR:nAt, nPRCODDES], .T.,, ;
				oGDPR:aCols[oGDPR:nAt, nPRHORDES], &(ReadVar()), oGDPR:aCols[oGDPR:nAt, nPRCODCRM], ;
				oGDPR:aCols[oGDPR:nAt, nPRCODATO], {cGcyAtendi, M->GCY_ATORIG, M->GCY_IDADE, M->GCY_SEXO, M->GCY_CARATE},, oGDPR:aCols[oGDPR:nAt, nPRDATDES])[1]
				lRet := HS_CalcDsc()
			EndIf
		EndIf
	EndIf

ElseIf nVld == 44
	If !EMPTY(&(ReadVar()))
		cGA1Cod := SPACE(LEN(GA1->GA1_CODPCT))
		For nTab := 1 To Len(aTabs)
			oObj := &("oGD" + aTabs[nTab])
			nPos := &("n" + aTabs[nTab] + "CodPct")
			For nCont := 1 To Len(oObj:aCols)
				If !oObj:aCols[nCont, Len(oObj:aHeader)+1] .And. !Empty(oObj:aCols[nCont, nPos]) .And. AT(oObj:aCols[nCont, nPos], cGA1Cod) == 0
					cGA1Cod += IIF(!Empty(cGA1Cod), "/", "") + oObj:aCols[nCont, nPos]
				EndIf
			Next
		Next

		If !(lRet := &(ReadVar()) $ cGA1Cod)
			HS_MsgInf("O procedimento Padr„o [" + AlLTrim(&(ReadVar())) + "] n„o est· lanÁado na conta", STR0013, STR0157)
		Else
			HS_SeekRet("GA1", "'" + &("M->" + SubStr(ReadVar(), 4, 3) + "_CODPCT") + "'", 1, .F., SubStr(ReadVar(), 4, 3) + "_DESPCT", "GA1_DESC",,,.T.)
		EndIf
	EndIf
ElseIf nVld == 45 // ValidaÁ„o clinica secundaria
	If HS_ExisDic({{"C", "GCY_CLISEC"}}, .F.)
		If !Empty(M->GCY_CLISEC)
			If !(lRet := HS_SeekRet("GCW","M->GCY_CLISEC", 1, .F., "GCY_DSCLIS", "GCW_DESCLI",,, .T.) )
				HS_MsgInf(STR0040, STR0034, STR0136) //"ClÌnica n„o encontrada."###"AtenÁ„o"###"ValidaÁ„o da ClÌnica"
			EndIf
		Else
			lRet := .T.
		EndIf
	EndIf
ElseIf nVld == 46
	If !(lRet := (aVldAih := HS_Modulo11(&(ReadVar()), 13,1,.T.,.T.))[1])
		Hs_MsgInf(aVldAih[2],"AtenÁ„o", "ValidaÁ„o SolicitaÁ„o de AIH")
	EndIF
	If lRet .AND. IsInCallStack("HSPAHAIH") .AND. (oGDGcz:aCols[oGDGcz:nAt, nGczCodPla] $ __cCodAIH )
		oGDGcz:aCols[oGDGcz:nAt, nGCZNrGuia] := &(ReadVar())
	EndIF
Elseif nVld == 47 // ValidaÁ„o do CNAER SUS
	If !Empty(M->GCY_CNASUS) .And. !HS_SeekRet("GR1", "M->GCY_CNASUS", 1, .F., "GCY_DESCNA", "GR1_DESCRI",,, .T.)
		HS_MsgInf(STR0296, STR0034, STR0297) //"CNAER n„o encontrado."###"AtenÁ„o"###"ValidaÁ„o CNAER"
		lRet := .F.
	Endif
Elseif nVld == 48 // ValidaÁ„o Cid SUS
	If Type("cCodProSus") # "U" .And. !Empty(cCodProSus)
		DbSelectArea("GHH")
		DbSetOrder(1)
		If DbSeek(xFilial("GHH") + cCodProSus + &(ReadVar()))
			lRet := .T.
		Else
			HS_MsgInf("CID incompativel com o permitido para o procedimento!", STR0034, "ValidaÁ„o CID") //"CNAER n„o encontrado."###"AtenÁ„o"###"ValidaÁ„o CNAER"
			lRet := .F.
		EndIf
	Endif
EndIf

DbSelectArea(cAliasOld)

Return(lRet)


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥HS_EXTM24 ≥ Autor ≥ Robson Ramiro A. Olive≥ Data ≥ 16.03.05 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Chama Extrato do paciente                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ HS_EXTM24()                                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAHSP                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function HS_EXTM24(cAliasM24, nRegM24, nOpcM24)
 Local cCodPac := ""

 HS_PosSX1({{"HSP24B", "01", GCY->GCY_REGGER}})

 If !Pergunte("HSP24B", .T.)
 	Return()
 EndIf

 If !Empty(MV_PAR01) .and. MV_PAR01 <> GCY->GCY_REGGER
  cCodPac := MV_PAR01
 Else
  cCodPac := GCY->GCY_REGGER
 Endif

 HS_EXTM24C(cCodPac, "P", nOpcM24)

Return(Nil)
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥HS_LegM24 ≥ Autor ≥ Microsiga                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Legenda dos atendimentos                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAHSP                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function HS_LegM24()
Local lHsM24Leg := ExistBlock("HSM24LEG")
Local aLegM24 := {}

If cGcyAtendi == "3"
	aLegM24 := {{"BR_VERDE"   , STR0069}, ;//"Recepcao"
	{"BR_AMARELO" , STR0210}, ;//"Evas„o"
	{"BR_AZUL"    , STR0070}, ;//"Espera"
	{"BR_LARANJA" , STR0065}, ;//"Repouso"
	{"BR_CINZA"   , STR0068}}  //"Cancelado"
Else
	aLegM24 := {{"BR_VERDE"   , STR0069}, ;//"Recepcao"
	{"BR_AMARELO" , STR0067}, ;//"Alta MÈdica"
	{"BR_VERMELHO", STR0066}, ;//"Admitido C.C./C.O."
	{"BR_AZUL"    , STR0070}, ;//"Espera"
	{"BR_LARANJA" , STR0065}, ;//"Repouso"
	{"BR_CINZA"   , STR0068}}  //"Cancelado"
EndIf

If lHsM24Leg
	aLegM24 := Execblock("HSM24LEG", .F., .F., aLegM24)
Endif

BrwLegenda(cCadastro, STR0211, aLegM24) //"Legenda"

Return(Nil)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥HS_M24Kit ≥ Autor ≥ Microsiga                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Detalhamento dos kits                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAHSP                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function HS_M24Kit()
Local aArea   := GetArea()
Local nForDes := 0, nPosDes := 0, nQtdDes := oGDMM:aCols[oGDMM:nAt, nMMQtdDes]
Local aRMMOld := aClone(__aRMatMed), aRTDOld := aClone(__aRTaxDia), nRDes := 0
Local cCodLoc := IIF(nMMCodLoc>0, oGDMM:aCols[oGDMM:nAt, nMMCodLoc], "")
Local cNomLoc := IIF(nMMCodLoc>0, oGDMM:aCols[oGDMM:nAt, nMMNomLoc], "")
Local dDatMM  := IIF(nMMCodLoc>0, oGDMM:aCols[oGDMM:nAt, nMMDatDes], "")
Local aMMKit  := __aIteKit[1]
Local aTDKit  := __aIteKit[2]
Local nUMM    := len(oGDMM:aHeader) + 1
Local nUTD    := Len(oGDTD:aHeader) + 1

If FunName() <> "HSPAHM19"
	DbSelectArea("GCU")
	DbSetOrder(1)
	DbSeek(xFilial("GCU") + cGcuCodTpG/*oGDGCZ:aCols[oGDGCZ:nAt, nGCZCODTPG]*/) // + oGDGCZ:aCols[oGDGCZ:nAt, nGCZCODPLA])
EndIf

//Materiais/Medicamentos
If IIF(FunName() <> "HSPAHM19" , GCU->GCU_MATMED == "1", .T.) .and. Len(aMMKit) > 0
	For nForDes := 1 To Len(aMMKit)
		If nMMCodLoc == 0
			nPosDes := aScan(oGDMM:aCols, {| aVet | !aVet[nUMM] .And. aVet[nMMCodDes] == PadR(aMMkit[nForDes, 1], Len(&(cPrefiMM + "_CODDES")))})
		Else
			nPosDes := aScan(oGDMM:aCols, {| aVet | !aVet[nUMM] .And. aVet[nMMCodDes] == PadR(aMMkit[nForDes, 1], Len(&(cPrefiMM + "_CODDES"))) .And. aVet[nMMCodLoc] == cCodLoc })
		Endif
		nPosDes := IIf(nPosDes == 0, aScan(oGDMM:aCols, {| aVet | !aVet[nUMM] .And. Empty(aVet[nMMCodDes])}), nPosDes)
		If nPosDes == 0
			oGDMM:AddLine(.F., .F.)
			oGDMM:lNewLine := .F.
			nPosDes := Len(oGDMM:aCols)
		Else
			If FunName() <> "HSPAHM19" .And. FS_SolAtd(nPosDes)
				If (nPosDes := aScan(oGDMM:aCols, {| aVet | !aVet[nUMM] .And. aVet[nMMCodDes] == PadR(aMMkit[nForDes, 1], Len(&(cPrefiMM + "_CODDES"))) .And. aVet[nMMStaReg] == "BR_VERMELHO"})) == 0
					If !EMPTY(oGDMM:aCols[oGDMM:nAt, nMMCodDes])
						oGDMM:AddLine(.F., .F.)
						oGDMM:lNewLine := .F.
						nPosDes := Len(oGDMM:aCols)
					Else
						nPosDes := oGDMM:nAt
					EndIf
				EndIf
			EndIf

			If nPosDes > 0 .And. FunName() <> "HSPAHM19"
				DbselectArea("GBI")
				DbSetOrder(1)
				DbSeek(xFilial("GBI") + aMMkit[nForDes, 1])

				DbselectArea("GAF")
				DbSetOrder(4) //CCOKIT
				If DbSeek(xFilial("GAF") + aMMkit[nForDes, 1]) .And. GAF->GAF_CODKIT == aMMkit[nForDes, 3] .And. ;
					GBI->GBI_TIPO <> "4"
					&("M->" + PrefixoCpo(cAliasMM) + "_CODBAR") := SPACE(Len(&("M->" + PrefixoCpo(cAliasMM) + "_CODBAR")))
				EndIf
			EndIf
		EndIf

		If !Empty(oGDMM:aCols[nPosDes, nMMCodDes])
			oGDMM:aCols[nPosDes, nMMQtdDes] += (nQtdDes * aMMkit[nForDes, 2])
		Else
			oGDMM:aCols[nPosDes, nMMQtdDes] := (nQtdDes * aMMkit[nForDes, 2])
		EndIf
		dDatMM  := oGDMM:aCols[oGDMM:nAt, nMMDatDes]
		If nMMCodLoc > 0
			oGDMM:aCols[nPosDes, nMMCodLoc] := cCodLoc
			oGDMM:aCols[nPosDes, nMMNomLoc] := cNomLoc

		Endif
		oGDMM:aCols[nPosDes, nMMCodDes] := PadR(aMMkit[nForDes, 1], Len(&(cPrefiMM + "_CODDES")))
		oGDMM:aCols[nPosDes, nMMCodKit] := aMMkit[nForDes, 3]
		oGDMM:aCols[nPosDes, nMMDesKit] := aMMkit[nForDes, 4]
		oGDMM:aCols[nPosDes, nMMDatDes] := dDatMM
		If FunName() <> "HSPAHM19"
			oGDMM:aCols[nPosDes, nMMCodBar] := HS_IniPadr("SB1", 1, PadR(aMMkit[nForDes, 1], Len(SB1->B1_COD)), "B1_CODBAR",,.F.)
		EndIf

		For nRDes := 1 To Len(__aRMatMed)
			__aRMatMed[nRDes, 1] := StrTran(__aRMatMed[nRDes, 1], "oGDMM:nAt", AllTrim(Str(nPosDes)))
		Next

		If FunName() <> "HSPAHM19"
			HS_VMatMed(cGczCodPla/*oGDGcz:aCols[oGDGcz:nAt, nGczCodPla]*/, oGDMM:aCols[nPosDes, nMMCodDes], cGcsArmSet, .F., .F., {.F., oGDMM:aCols[nPosDes, nMMQtdDes]},/*lMsg*/, /*dVigencia*/,__cCtrEst, oGDMM:aCols[nPosDes, nMMCodCrm], oGDMM:aCols[nPosDes, nMMHorDes], {cGcyAtendi, M->GCY_CARATE})
		Else
			HS_VMatMed(M->GO0_CODPLA, oGDMM:aCols[nPosDes, nMMCodDes], , , , , , M->GO0_DATPRE, oGDMM:aCols[nPosDes, nMMCodLoc])
		EndIf

		__aRMatMed := aClone(aRMMOld)
	Next
Endif

//Taxas e Diarias
If IIF(FunName() <> "HSPAHM19" , GCU->GCU_TAXDIA == "1", .T.)  .and. Len(aTDKit) > 0  //O tipo de guia permite taxas/diarias

	For nForDes := 1 To Len(aTDKit)
		If nTDCodLoc == 0
			nPosDes := aScan(oGDTD:aCols, {| aVet | !aVet[nUTD] .And. aVet[nTDCodDes] == PadR(aTDkit[nForDes, 1], Len(&(cPrefiTD + "_CODDES")))})
		Else
			nPosDes := aScan(oGDTD:aCols, {| aVet | !aVet[nUTD] .And. aVet[nTDCodDes] == PadR(aTDkit[nForDes, 1], Len(&(cPrefiTD + "_CODDES"))) .And. aVet[nTDCodLoc] == cCodLoc })
		Endif
		nPosDes := IIf(nPosDes == 0, aScan(oGDTD:aCols, {| aVet | !aVet[nUTD] .And. Empty(aVet[nTDCodDes])}), nPosDes)
		If nPosDes == 0
			oGDTD:AddLine(.F., .F.)
			oGDTD:lNewLine := .F.
			nPosDes := Len(oGDTD:aCols)
		EndIf

		If !Empty(oGDTD:aCols[nPosDes, nTDCodDes])
			oGDTD:aCols[nPosDes, nTDQtdDes] += (nQtdDes * aTDkit[nForDes, 2])
		Else
			oGDTD:aCols[nPosDes, nTDQtdDes] := (nQtdDes * aTDkit[nForDes, 2])
		EndIf
		If nTDCodLoc > 0 .and. Empty(oGDTD:aCols[nPosDes, nTDCodLoc])
			oGDTD:aCols[nPosDes, nTDCodLoc] := cCodLoc
			oGDTD:aCols[nPosDes, nTDNomLoc] := cNomLoc
		Endif
		oGDTD:aCols[nPosDes, nTDCodDes] := PadR(aTDKit[nForDes, 1], Len(&(cPrefiTD + "_CODDES")))
		oGDTD:aCols[nPosDes, nTDCodKit] := aTDkit[nForDes, 3]
		oGDTD:aCols[nPosDes, nTDDesKit] := aTDkit[nForDes, 4]

		For nRDes := 1 To Len(__aRTaxDia)
			__aRTaxDia[nRDes, 1] := StrTran(__aRTaxDia[nRDes, 1], "oGDTD:nAt", AllTrim(Str(nPosDes)))
		Next

		If FunName() <> "HSPAHM19"
			HS_VldTaxD(cGczCodPla, cCodLoc, oGDTD:aCols[nPosDes, nTDCodDes],,,,,HS_RetCrm(oGDTD:aCols, oGDTD:nAt, nTDCodCrm, M->GCY_CODCRM), oGDTD:aCols[nPosDes, nTDHorDes], {cGcyAtendi, M->GCY_CARATE})
		Else
			HS_VldTaxD(M->GO0_CODPLA, cCodLoc, oGDTD:aCols[nPosDes, nTDCodDes])
		EndIf

		__aRTaxDia := aClone(aRTDOld)
	Next

Endif

oGDMM:oBrowse:Refresh()
oGDTD:oBrowse:Refresh()


Return(Nil)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥HS_M24Pct ≥ Autor ≥ Microsiga                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Detalhamento dos proced. padrao                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAHSP                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function HS_M24Pct(cOriPct,nPRStaReg)
Local nForPct := 0, aRPrOld := aClone(__aRProced), aRMMOld := aClone(__aRMatMed), aRTDOld := aClone(__aRTaxDia), aRValPr := {}, aRMntEqp := {}
Local nPosDes := 0, nQtdDes := 0, cCodLoc := "", nRDes := 0, dDatDes := CToD(" "), cHorDes := "", cCodDes := ""
Local nUMM := Len(oGDMM:aHeader) + 1
Local nUPR := Len(oGDPR:aHeader) + 1
Local nUTD := Len(oGDTD:aHeader) + 1
Local cMsgErro := ""
Local cOldReadV := __ReadVar, cAlias := SubStr(__ReadVar, 4, 3)

Default nPRStaReg := 0

nQtdDes := IIf(cOriPct == "P", oGDPr:aCols[oGDPR:nAt, nPRQtdDes], oGDTD:aCols[oGDTD:nAt, nTDQtdDes])
dDatDes := IIf(cOriPct == "P", oGDPr:aCols[oGDPR:nAt, nPRDatDes], oGDTD:aCols[oGDTD:nAt, nTDDatDes])
cHorDes := IIf(cOriPct == "P", oGDPr:aCols[oGDPR:nAt, nPRHorDes], oGDTD:aCols[oGDTD:nAt, nTDHorDes])

cCodLoc := IIf(cOriPct == "P", IIf(nPRCodLoc > 0, oGDPr:aCols[oGDPR:nAt, nPRCodLoc], ""), IIf(nTDCodLoc > 0, oGDTD:aCols[oGDTD:nAt, nTDCodLoc], ""))
cCodLoc := IIf(Empty(cCodLoc), cLctCodLoc, cCodLoc)

aSort(__aItePct,,, {| X, Y | X[7] > Y[7]}) // Ordena para colocar o item principal na primeira linha do __aItePct

For nForPct := 1 To Len(__aItePct)
	If     __aItePct[nForPct, 1] == "0" // Materiais e Medicamentos
		If (nPosDes := aScan(oGDMM:aCols, {| aVet | !aVet[nUMM] .And. Empty(aVet[nMMCodDes])})) == 0
			oGDMM:AddLine(.F., .F.)
			oGDMM:lNewLine := .F.
			nPosDes := Len(oGDMM:aCols)
		EndIf

		oGDMM:nAt := nPosDes
		If Type("nMMStaReg") # "U" .And. nMMStaReg > 0
			oGDMM:aCols[oGDMM:nAt, nMMStaReg] := "BR_VERMELHO"
		Endif
		cCodDes := PadR(AllTrim(__aItePct[nForPct, 2]), Len(&(cPrefiMM + "_CODDES")))
		If !Empty(oGDMM:aCols[nPosDes, nMMCodDes])
			oGDMM:aCols[nPosDes, nMMQtdDes] += (nQtdDes * __aItePct[nForPct, 3])
		Else
			oGDMM:aCols[nPosDes, nMMQtdDes] := (nQtdDes * __aItePct[nForPct, 3])
		EndIf

		If !HS_VMatMed(cGczCodPla, cCodDes, cGcsArmSet, .F., .F., {.F., oGDMM:aCols[nPosDes, nMMQtdDes]},,,cCodLoc, IIF(Type("nMMCodCrm") # "U" .And. nMMCodCrm > 0, oGDMM:aCols[nPosDes, nMMCodCrm], NIL), ;
			IIF(Type("nMMHorDes") # "U" .And. nMMHorDes > 0, oGDMM:aCols[nPosDes, nMMHorDes], NIL), {cGcyAtendi})
			aDel(oGDMM:aCols, Len(oGDMM:aCols))
			aSize(oGDMM:aCols, Len(oGDMM:aCols) - 1)
			If Len(oGDMM:aCols) == 0
				oGDMM:AddLine(.F., .F.)
				oGDMM:lNewLine := .F.
			EndIf
			Loop
		EndIf

		oGDMM:aCols[nPosDes, nMMCodDes] := cCodDes
		oGDMM:aCols[nPosDes, nMMCodPct] := __aItePct[nForPct, 5]
		oGDMM:aCols[nPosDes, nMMDesPct] := __aItePct[nForPct, 6]

		For nRDes := 1 To Len(__aRMatMed)
			__aRMatMed[nRDes, 1] := StrTran(__aRMatMed[nRDes, 1], "oGDMM:nAt", AllTrim(Str(nPosDes)))
		Next

		If Type("nMMCodLoc") # "U" .And. nMMCodLoc > 0
			oGDMM:aCols[nPosDes, nMMCodLoc] := cCodLoc
			oGDMM:aCols[nPosDes, nMMNomLoc] := HS_IniPadr("GCS", 1, cCodLoc, "GCS_NOMLOC",,.F.)
		EndIf

		If Type("nMMDatDes") # "U" .And. nMMDatDes > 0
			oGDMM:aCols[nPosDes, nMMDatDes] := dDatDes
		EndIf

		If Type("nMMHorDes") # "U" .And. nMMHorDes > 0
			oGDMM:aCols[nPosDes, nMMHorDes] := cHorDes
		EndIf

	ElseIf __aItePct[nForPct, 1] == "1" // Procedimentos
		If (__aItePct[nForPct, 7]) // Se verdadeiro indica que È o procedimento pricipal do pacote
			nPosDes := oGDPr:nAt
		Else
			If (nPosDes := aScan(oGDPR:aCols, {| aVet | !aVet[nUPR] .And. Empty(aVet[nPRCodDes])})) == 0
				oGDPR:AddLine(.F., .F.)
				oGDPR:lNewLine := .F.
				nPosDes := Len(oGDPR:aCols)
			EndIf
		EndIf

		oGDPR:nAt := nPosDes
		If Type("nPrStaReg") # "U" .And. nPrStaReg > 0
			oGDPR:aCols[oGDPR:nAt, nPRStaReg] := "BR_VERMELHO"
		Endif

		cCodDes := PadR(AllTrim(__aItePct[nForPct, 2]), Len(&(cPrefiPR + "_CODDES")))
		oGDPR:aCols[nPosDes, nPRCodPct] := __aItePct[nForPct, 5]
		oGDPR:aCols[nPosDes, nPRDesPct] := __aItePct[nForPct, 6]

		aRValPr := {}
		aRMntEqp := HS_MntEqp(oGDPr, oGDTD, cCodDes)
		If !aRMntEqp[1] //nao tem equipe
			aRValPr := HS_VProHon(cGczCodPla, cCodLoc, cCodDes)
		ElseIf !aRMntEqp[2] //Tem equipe mas tem inconsistencia nos proced.
			Loop
		EndIf

		If Len(aRValPr) > 0 .And. !aRValPr[1]
			aDel(oGDPR:aCols, Len(oGDPR:aCols))
			aSize(oGDPR:aCols, Len(oGDPR:aCols) - 1)
			If Len(oGDPR:aCols) == 0
				oGDPR:AddLine(.F., .F.)
				oGDPR:lNewLine := .F.
			EndIf
			Loop
		EndIf

		oGDPR:aCols[nPosDes, nPRQtdDes] := (nQtdDes * __aItePct[nForPct, 3])
		oGDPR:aCols[nPosDes, nPRCodDes] := cCodDes

		If Type("nPRSLaudo") # "U" .And. nPRSLaudo > 0
			HS_SLaudo(.F.,cCodDes)
		EndIf

		If Type("nPRCodLoc") # "U" .And. nPRCodLoc > 0
			oGDPR:aCols[nPosDes, nPRCodLoc] := cCodLoc
			oGDPR:aCols[nPosDes, nPRNomLoc] := HS_IniPadr("GCS", 1, cCodLoc, "GCS_NOMLOC",,.F.)
		EndIf

		If Type("nPRDatDes") # "U" .And. nPRDatDes > 0
			oGDPR:aCols[nPosDes, nPRDatDes] := dDatDes
		EndIf

		If Type("nPRHorDes") # "U" .And. nPRHorDes > 0
			oGDPR:aCols[nPosDes, nPRHorDes] := cHorDes
		EndIf

		If Type("nPRCODCRM") # "U" .And. nPRCODCRM > 0
			__ReadVar := "M->" + cAlias + "_CODCRM"
			&("M->" + cAlias + "_CODCRM") := IIF(cGcyAtendi == "3" .or. (cGcyAtendi $ "1/2/4" .and. Empty(__aItePct[nForPct, 8]) ) , M->GCY_CODCRM, __aItePct[nForPct, 8])
			If !EMPTY(&("M->" + cAlias + "_CODCRM")) .And. HS_VldM24(, 17,,,, .F.)
				If cGcyAtendi $ "1/2/3/4"
					oGDPR:aCols[nPosDes, nPRCODCRM] := M->GCY_CODCRM
					oGDPR:aCols[nPosDes, nPRNomMed] := M->GCY_NOMMED
				Else
					oGDPR:aCols[nPosDes, nPRCODCRM] := __aItePct[nForPct, 8]
					oGDPR:aCols[nPosDes, nPRNomMed] := HS_IniPadr("SRA", 11, __aItePct[nForPct, 8], "RA_NOME",,.F.)
				EndIf
			Else
				cMsgErro += "Procedimento [" + cCodDes + "] MÈdico [" + __aItePct[nForPct, 8] + "]" + Chr(13) + Chr(10)
			EndIf
		EndIf

		If Type("nPRTABELA") # "U" .And. nPRTABELA > 0 .And. Len(aRValPr) > 0 .And. aRValPr[1]
			oGDPR:aCols[nPosDes, nPRTABELA] := aRValPr[2][2][20]
		EndIf

	ElseIf __aItePct[nForPct, 1] == "2" // Taxas e Diarias
		If __aItePct[nForPct, 7] // Se verdadeiro indica que È a taxa/diaria pricipal do pacote
			nPosDes := oGDTD:nAt
		Else
			If (nPosDes := aScan(oGDTD:aCols, {| aVet | !aVet[nUTD] .And. Empty(aVet[nTDCodDes])})) == 0// .Or. (nPosDes == oGDTD:nAt)
				oGDTD:AddLine(.F., .F.)
				oGDTD:lNewLine := .F.
				nPosDes := Len(oGDTD:aCols)
			EndIf
		EndIf

		oGDTD:nAt := nPosDes
		If Type("nTDStaReg") # "U" .And. nTDStaReg > 0
			oGDTD:aCols[oGDTD:nAt, nTDStaReg] := "BR_VERMELHO"
		Endif
		cCodDes := PadR(AllTrim(__aItePct[nForPct, 2]), Len(&(cPrefiTD + "_CODDES")))
		If !IIf(FunName() <> "HSPAHM19", HS_VldTaxD(cGczCodPla, cCodLoc, cCodDes,,,,,HS_RetCrm(oGDTD:aCols, oGDTD:nAt, nTDCodCrm, M->GCY_CODCRM), oGDTD:aCols[oGDTD:nAt, nTDHorDes], {cGcyAtendi, M->GCY_CARATE}), HS_VldTaxD(cGczCodPla, cCodLoc, cCodDes))
			aDel(oGDTD:aCols, Len(oGDTD:aCols))
			aSize(oGDTD:aCols, Len(oGDTD:aCols) - 1)
			If Len(oGDTD:aCols) == 0
				oGDTD:AddLine(.F., .F.)
				oGDTD:lNewLine := .F.
			EndIf
			Loop
		EndIf

		If !Empty(oGDTD:aCols[nPosDes, nTDCodDes])
			oGDTD:aCols[nPosDes, nTDQtdDes] += (nQtdDes * __aItePct[nForPct, 3])
		Else
			oGDTD:aCols[nPosDes, nTDQtdDes] := (nQtdDes * __aItePct[nForPct, 3])
		EndIf
		oGDTD:aCols[nPosDes, nTDCodDes] := cCodDes

		oGDTD:aCols[nPosDes, nTDCodPct] := __aItePct[nForPct, 5]
		oGDTD:aCols[nPosDes, nTDDesPct] := __aItePct[nForPct, 6]

		For nRDes := 1 To Len(__aRTaxDia)
			__aRTaxDia[nRDes, 1] := StrTran(__aRTaxDia[nRDes, 1], "oGDTD:nAt", AllTrim(Str(nPosDes)))
		Next

		If Type("nTDCodLoc") # "U" .And. nTDCodLoc > 0
			oGDTD:aCols[nPosDes, nTDCodLoc] := cCodLoc
			oGDTD:aCols[nPosDes, nTDNomLoc] := HS_IniPadr("GCS", 1, cCodLoc, "GCS_NOMLOC",,.F.)
		EndIf

		If Type("nTDDatDes") # "U" .And. nTDDatDes > 0
			oGDTD:aCols[nPosDes, nTDDatDes] := dDatDes
		EndIf

		If Type("nTDHorDes") # "U" .And. nTDHorDes > 0
			oGDTD:aCols[nPosDes, nTDHorDes] := cHorDes
		EndIf

	EndIf

	__aRMatMed := aClone(aRMMOld)
	__aRTaxDia := aClone(aRTDOld)
Next

oGDMM:oBrowse:Refresh()
oGDTD:oBrowse:Refresh()
oGDPR:oBrowse:Refresh()

If !Empty(cMsgErro)
	HS_MsgInf("Especialidades incompativeis:" + Chr(13) + Chr(10) + cMsgErro, "AtenÁ„o", "ValidaÁ„o da especialidade")
EndIf

__ReadVar := cOldReadV

Return(Nil)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ HS_M24Agd ∫Autor  ≥ Microsiga         ∫ Data ≥  08/29/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Detalhamento do atendimento de agenda ambulatorial         ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ HSPAHM24                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function HS_M24Agd()// -> ESSA FUNCAO NAO PODE RECEBER PARAMETROS
Local cNomMed := ""
Local aArea := {}, cCodCon := "", nCont :=0
Local aLaudo:= {}
Local aProcAgd := {}
Local aMatMAgd := {}
Local nPosDes  := 0
Local nI := 0
Local cPrefix := IIf(cGcyAtendi == "0", "GMJ", "GM8")
Local lAteSUS := (GetMV("MV_ATESUS", , "N") == "S")
Local cCodApc := GetMV("MV_PSUSPAC")
Local cCodSol	:= ""
Local cSetor:=""
Local cQuart:=""
Local cLeito:=""
Local LEspe:=.F.
local lOriPac   := Hs_ExisDic({{"C","GM8_ORIPAC"}},.F.)  //Se o campo foi criado pelo UPDGH031
local cDoriPa := ""
Local cProcAtu := ""
Local aRVldVig	:= {{"", IIf(cGcyAtendi == "0", "GC1_TPGINT", IIf(cGcyAtendi $ "14", "GC1_TPGAMB", "GC1_TPGPAT"))},;
					{"", IIf(cGcyAtendi $ "14", "GC1_HORRTA", "GC1_HORRTP")}}
Local cCodConv
Local nForCre := 1
Private cReserv:= ""
Private cPacHSP04 :=""

lRecepAgd := .T.
If HS_ExisDic({{"C", "GCS_LSTESP"}}, .F.) .and. cGcyAtendi == "0"///lista de espera
	DbSelectArea("GCS")
	DbSetOrder(1)
	Dbseek(xFilial("GCS")+GMJ->GMJ_CODLOC)  //GCS_FILIAL+GCS_CODLOC
	If GCS->GCS_LSTESP =="1"

		If HS_CountTB("GT6", "GT6_CODLOC='"+GMJ->GMJ_CODLOC+"' AND  GT6_CODAGE <> '" + Space(TamSx3("GT6_CODAGE")[1]) + "' AND (GT6_QUARTO = '"+SPACE(TAMSX3("GT6_LEITO ")[1])+"' OR GT6_QUARTO = '"+GMJ->GMJ_QUARTO+"' )" ) > 0
			If MsgYesNo(STR0308, STR0016)
				DbSelectArea("GT6")
				GT6->(DbSetOrder(1))
				IF GT6->(DbSeek(xFilial("GT6") + GMJ->GMJ_CODLOC+ GMJ->GMJ_QUARTO))
					cQuart :=GT6->GT6_QUARTO

				Else
					If GT6->(DbSeek(xFilial("GT6") + GMJ->GMJ_CODLOC))
						If  GMJ->GMJ_QUARTO == GT6->GT6_QUARTO .or. Empty(GT6_QUARTO)
							cQuart :=GT6->GT6_QUARTO

						Endif
					Endif

				Endif

				aRegEsp:=HS_ExbLsE(GMJ->GMJ_CODLOC,cQuart,cLeito)
				If !Empty(aRegEsp)
					cGcyRegGer:=aRegEsp[1]
					cSetoEsp:=aRegEsp[3]
					cQuartEsp:=aRegEsp[4]
					cLeiEsp:=aRegEsp[5]
					cCodAge:=aRegEsp[6]
					DBSELECTAREA("GMJ")
					DBSETORDER(1)
					If DbSeek(xFilial("GMJ") + cCodAge)
						LEspe:=.T.
					Endif

				Endif
			Endif
		Endif

	Endif

Endif

cAgdFilAge := IIf(cGcyAtendi == "0", GMJ->GMJ_FILAGE, GM8->GM8_FILAGE)
cAgdCodAge := IIf(cGcyAtendi == "0", GMJ->GMJ_CODAGE, GM8->GM8_CODAGE)
cGczCodPla := IIf(cGcyAtendi == "0", GMJ->GMJ_CODPLA, GM8->GM8_CODPLA)
cGcyRegGer := IIf(cGcyAtendi == "0", GMJ->GMJ_REGGER, GM8->GM8_REGGER)

cNomMed := HS_IniPadr("SRA", 11, IIf(cGcyAtendi == "0", GMJ->GMJ_CODCRM, GM8->GM8_CODCRM), "RA_NOME",,.F.)
if lOriPac
	cDoriPa := Posicione("GD0",1,xFilial("GD0")+GM8->GM8_ORIPAC,"GD0_DORIPA")
endif

M->GCY_REGGER := cGcyRegGer
M->GCY_NOME   := IIf(cGcyAtendi == "0", GMJ->GMJ_NOMPAC, GM8->GM8_NOMPAC)
If cGcyAtendi # "0"
	M->GCY_CODLOC := GM8->GM8_CODLOC
	M->GCY_NOMLOC := HS_IniPadr("GCS", 1, GM8->GM8_CODLOC, "GCS_NOMLOC",,.F.)
Else
	M->GCY_CIDINT := GMJ->GMJ_CODPAT
	M->GCY_DCIDIN := HS_IniPadr("GAS", 1, GMJ->GMJ_CODPAT, "GAS_PATOLO",,.F.)
	M->GCY_CODLOC := GMJ->GMJ_CODLOC
	M->GCY_QUAINT := GMJ->GMJ_QUARTO
EndIf
M->GCY_CODCRM := IIf(cGcyAtendi == "0", GMJ->GMJ_CODCRM, GM8->GM8_CODCRM)
M->GCY_NOMMED := cNomMed
If lOriPac
	M->GCY_ORIPAC := GM8->GM8_ORIPAC
	M->GCY_DORIPA := cDoriPa
endif

If HS_ExisDic({{"C", "GCY_HORAGE"}}, .F.)
	M->GCY_HORAGE := GM8->GM8_HORAGE
EndIf
If HS_ExisDic({{"C", "GM8_NUMORC"}}, .F.) .AND. !Empty(GM8->GM8_NUMORC)
	DbSelectArea("GT9")
	DbSetOrder(1)
	Dbseek(xFilial("GT9") + GM8->GM8_NUMORC)
	If GT9->GT9_COBRAN == "1" .AND. cGczCodPla <> GM8->GM8_CODPLA
		cGczCodPla := IIf(cGcyAtendi == "0", GMJ->GMJ_CODPLA, GM8->GM8_CODPLA)
		HS_VldVig("GC1", "GC1_FILIAL = '" + xFilial("GC1") + "' AND GC1_CODPLA = '" + cGczCodPla + "'", "GC1_DATVIG", @aRVldVig, dDataBase)
		oGDGcz:aCols[oGDGcz:nAt, nGCZCODTPG] := aRVldVig[1][1]
		oGDGcz:aCols[oGDGcz:nAt, nGCZDESTPG] := HS_IniPadr("GCU", 1, oGDGcz:aCols[oGDGcz:nAt, nGCZCODTPG], "GCU_DESTPG",,.F.)
	EndIf
	If HS_ExisDic({{"C", "GT9_TABUTI"}}, .F.) .AND. !Empty(GT9->GT9_TABUTI)
		If Type("__cTabPrUt") # "U" .And. __cTabPrUt <> Nil
			__cTabPrUt := GT9->GT9_TABUTI
		EndIf
	EndIf
EndIf

If !Empty(M->GCY_REGGER)
	If !HS_VldM24(, 4)
		If !HS_LstAgd(cM24Par01, dDataBase, IIf(cGcyAtendi == "0", "GMJ", "GM8")) // Busca pacientes agendados.
			Return(.F.)
		EndIf
	EndIf
EndIf

If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt)
	lIncPro := .F.
Endif
If !Empty(M->GCY_CODCRM)
	HS_VldM24(, 5)
EndIf

HS_DefVar("GBH", 1, cGcyRegGer, {{"M->GCY_DTNASC", "GBH->GBH_DTNASC"}, ;
{"M->GCY_SEXO"  , "GBH->GBH_SEXO"  }})


oGDGcz:aCols[1, nGczCodPla] := cGczCodPla
oGDGcz:aCols[1, nGczDesPla] := HS_IniPadr("GCM", 2, cGczCodPla, "GCM_DESPLA",,.F.)
oGDGcz:aCols[1, nGczSqCatP] := GD4->GD4_SQCATP
oGDGcz:aCols[1, nGczDsCatP] := HS_IniPadr("GFV", 1, GD4->GD4_CODPLA + GD4->GD4_SQCATP, "GFV_NOMCAT",,.F.)
oGDGcz:aCols[1, nGCZNrSen1] := IIf(cGcyAtendi == "0", GMJ->GMJ_NRSEN1, SPACE(LEN(oGDGcz:aCols[1, nGCZNrSen1])))
oGDGcz:aCols[1, nGCZNrSen2] := IIf(cGcyAtendi == "0", GMJ->GMJ_NRSEN2, SPACE(LEN(oGDGcz:aCols[1, nGCZNrSen2])))
oGDGcz:aCols[1, nGCZNrSen3] := IIf(cGcyAtendi == "0", GMJ->GMJ_NRSEN3, SPACE(LEN(oGDGcz:aCols[1, nGCZNrSen3])))
IIF(cGcyAtendi == "0", oGDGcz:aCols[1, nGCZQtDias] := GMJ->GMJ_QTDIAS, NIL)
oGDGcz:aCols[1, nGczCodCrm] := IIf(cGcyAtendi == "0", GMJ->GMJ_CODCRM, GM8->GM8_CODCRM)
oGDGcz:aCols[1, nGczNomMed] := cNomMed

oGDGcz:aCols[1, nGczCodDes] := &(cPrefix+"->"+cPrefix+"_CODPRO")
oGDGcz:aCols[1, nGczDdespe] := Posicione("GA7",1,xFilial("GA7")+&(cPrefix+"->"+cPrefix+"_CODPRO"),"GA7_DESC")
oGDGcz:aCols[1, nGczCodPrt] := HS_RValPr(&(cPrefix+"->"+cPrefix+"_CODPRO"), cGczCodPla, M->GCY_CODLOC, Time(), "2", M->GCY_CODCRM,, {cGcyAtendi, cGcyAtendi, M->GCY_IDADE, M->GCY_SEXO, M->GCY_CARATE},, DDATABASE)[2][15]

oGDGcz:aCols[1, nGCZNrGuia] := HS_IniTISS(3, 1, cGczCodPla,oGDGcz:aCols[1, nGCZCODTPG],,oGDGcz:aHeader,oGDGcz:aCols)

If Empty(oGDGcz:aCols[1, nGCZNrGuia])
	If lAtesus .And. cGczCodPla == cCodApc
		oGDGcz:aCols[1, nGCZNrGuia] := IIf(cGcyAtendi == "0", GMJ->GMJ_NRGUIA, IIF(Hs_ExisDic({{"C","GK7_SEQAGE"}},.F.),Hs_SolApac(GCY->GCY_REGATE,"GK7_NRAPAC"),SPACE(LEN(oGDGcz:aCols[1, nGCZNrGuia]))))
	Else
		oGDGcz:aCols[1, nGCZNrGuia] := IIf(cGcyAtendi == "0", GMJ->GMJ_NRGUIA, IIF(Hs_ExisDic({{"C","GKB_SEQAGE"}},.F.),Hs_SolAgen(cAgdCodAge,"GKB_NRAUT"),SPACE(LEN(oGDGcz:aCols[1, nGCZNrGuia]))))
	EndIf
EndIf

If Empty(oGDGcz:aCols[1, nGCZNrGuia])
	oGDGcz:aCols[1, nGCZNrGuia]:= SPACE(TAMSX3("GCZ_NRGUIA")[1])  //Se o numero da Guia ainda estiver vazio, permito a digitacao
EndIf

oGDGcz:oBrowse:Refresh()


//Se for herdado da reserva... buscar materiais/medicamentos e procedimentos
//e alimentar o GE2 e GE3

If cGcyAtendi == "0" .AND. HS_ExisDic({{"T", "GNX"}})
	aArea := GetArea()
	nCont :=1
	DbSelectArea("GNX")
	DbSetOrder(2)//GNX_FILIAL+GNX_CODAGE
	If DbSeek(xFilial("GNX") + GMJ->GMJ_CODAGE)
		cCodSol := GNX->GNX_CODSOL
		cCodCon := Posicione("GCM", 2, xFilial("GCM") + cGczCodPla, "GCM_CODCON")
		DbSelectArea("GE2")
		DbSetOrder(3)//GE2_FILIAL+GE2_CODSOL+GE2_CODDES
		If DbSeek(xFilial("GE2") + cCodSol)
			While !GE2->(Eof()) .And. GE2->GE2_CODSOL == cCodSol
				IIf(nCont == 1, oGDGE2:aCols :={}, Nil)
				oGDGE2:AddLine(.F., .F.)
				oGDGE2:lNewLine := .F.
				oGDGE2:aCols[nCont, nGe2StaReg] := Iif(GE2->GE2_STATUS == "0", "BR_VERDE",IIf(GE2->GE2_STATUS == "1","BR_AMARELO",IIf(GE2->GE2_STATUS == "2","BR_AZUL",IIf(GE2->GE2_STATUS == "3","BR_VERMELHO","BR_CINZA"))))
				oGDGE2:aCols[nCont, nGE2CodDes] := GE2->GE2_CODDES
				oGDGE2:aCols[nCont, nGE2DDespe] := Posicione("SB1", 1, xFilial("SB1") + GE2->GE2_CODDES, "B1_DESC")
				oGDGE2:aCols[nCont, nGE2QtdAut] := GE2->GE2_QTDAUT
				oGDGE2:aCols[nCont, nGE2QtdSol] := GE2->GE2_QTDSOL
				nCont++
				DbSelectArea("GE2")
				DbSkip()
			End
		EndIf
		nCont :=1
		DbSelectArea("GE3")
		DbSetOrder(3)//GE2_FILIAL+GE2_CODSOL+GE2_CODDES
		If DbSeek(xFilial("GE3") + cCodSol)
			While !GE3->(Eof()) .And. GE3->GE3_CODSOL == cCodSol
				IIf(nCont == 1, oGDGE3:aCols :={}, Nil)
				oGDGE3:AddLine(.F., .F.)
				oGDGE3:lNewLine := .F.
				oGDGE3:aCols[nCont, nGe3StaReg] := Iif(GE3->GE3_STATUS == "0", "BR_VERDE",IIf(GE3->GE3_STATUS == "1","BR_AMARELO",IIf(GE3->GE3_STATUS == "2","BR_AZUL",IIf(GE3->GE3_STATUS == "3","BR_VERMELHO","BR_CINZA"))))
				oGDGE3:aCols[nCont, nGE3CodDes] := GE3->GE3_CODDES
				oGDGE3:aCols[nCont, nGE3DDespe] := Posicione("GA7", 1, xFilial("GA7") + GE3->GE3_CODDES, "GA7_DESC")

				oGDGE3:aCols[nCont, nGe3DatSol] := GE3->GE3_DATSOL
				oGDGE3:aCols[nCont, nGe3HorSol] := GE3->GE3_HORSOL
				oGDGE3:aCols[nCont, nGe3QtdSol] := GE3->GE3_QTDSOL
				oGDGE3:aCols[nCont, nGe3QtdAut] := GE3->GE3_QTDAUT
				oGDGE3:aCols[nCont, nGe3SenAut] := GE3->GE3_SENAUT
				oGDGE3:aCols[nCont, nGe3DatAut] := GE3->GE3_DATAUT
				oGDGE3:aCols[nCont, nGe3HorAut] := GE3->GE3_HORAUT
				oGDGE3:aCols[nCont, nGe3ValAut] := GE3->GE3_VALAUT
				oGDGE3:aCols[nCont, nGe3NroAut] := GE3->GE3_NROAUT
				oGDGE3:aCols[nCont, nGe3ResAut] := GE3->GE3_RESAUT
				oGDGE3:aCols[nCont, nGe3ValAut] := GE3->GE3_VALAUT
				oGDGE3:aCols[nCont, nGe3MnAuto] := GE3->GE3_MNAUTO

				nCont++
				DbSelectArea("GE3")
				DbSkip()
			End
		EndIf
	EndIf
	oGDGE2:oBrowse:Refresh()
	oGDGE3:oBrowse:Refresh()
	RestArea(aArea)
EndIf


If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt)
	aProcAgd := Hs_RtPrAgd(cAgdCodAge, GM8->GM8_CODPRO, GM8->GM8_NUMORC, GM8->GM8_ITEORC)

	For nI := 1 to len(aProcAgd)
		If !Empty(oGDPR:aCols[IIF(nI == 1,nI, oGDPR:nAt), nPRCodDes])
			oGDPR:AddLine(.T., .F.)
			oGDPR:lNewLine := .F.
		EndIf
		cProcAtu := IIf(ValType(aProcAgd[nI]) == "A",aProcAgd[nI][1],aProcAgd[nI])
		If !HS_VProced(GM8->GM8_CODPLA, cGcsCodLoc, cProcAtu)
			IF nI > 1
				aDel(oGDPR:aCols,oGDPR:nAt)
				aSize(oGDPR:aCols,Len(oGDPR:aCols)-1)
				oGDPR:Refresh()
			EndIf
			Loop
		EndIf

		If lIsCaixa .And. Type("M->GCY_CODCRM") <> "U" .And. Empty(oGDPR:aCols[nForCre, nPRPGTMED])
			cCodConv := Posicione("GCM", 2, xFilial("GCM") + cGczCodPla, "GCM_CODCON")
			While nForCre <= Len(oGDPR:aCols)
				oGDPR:aCols[nForCre, nPRPGTMED] := HM24RETCR(cCodConv,M->GCY_CODCRM,cGCZCodPla)
				nForCre++
				Loop
			Enddo
		Endif

		oGDPR:aCols[oGDPR:nAt, nPRCodDes] := cProcAtu
		IF ValType(aProcAgd[nI]) == "A"
			oGDPR:aCols[oGDPR:nAt, nPRNumOrc] := aProcAgd[nI][2]
			oGDPR:aCols[oGDPR:nAt, nPRIteOrc] := aProcAgd[nI][3]
		EndIf

		HS_DefVar("GA7", 1, cProcAtu, {{"oGDPR:aCols[oGDPR:nAt, nPRDDespe]", "GA7->GA7_DESC"  }, ;
		{"oGDPR:aCols[oGDPR:nAt, nPRCodEsp]", "GA7->GA7_CODESP"}})

		If lGFR
			oGDPR:aCols[oGDPR:nAt, nPRNomEsp] := HS_IniPadr("GFR", 1, oGDPR:aCols[oGDPR:nAt, nPRCodEsp], "GFR_DSESPE",,.F.)
		Else
			oGDPR:aCols[oGDPR:nAt, nPRNomEsp] := HS_IniPadr("SX5", 1, "EM" + oGDPR:aCols[oGDPR:nAt, nPRCodEsp], "X5_DESCRI",,.F.)
		EndIf
		oGDPR:aCols[oGDPR:nAt, nPRCodCrm] := GM8->GM8_CODCRM
		oGDPR:aCols[oGDPR:nAt, nPRNomMed] := cNomMed

		If nPRSLaudo > 0
			aLaudo     := HS_IsLaudo(cGcsCodLoc, cProcAtu)
			lGd7SLaudo := aLaudo[2]
			oGDPR:aCols[oGDPR:nAt, nPRSLaudo] := IIf(aLaudo[1], "1", "0")
			oGDPR:aCols[oGDPR:nAt, nPRCrmLau] := oGDGcz:aCols[oGDGcz:nAt, nGczCodCrm]
			oGDPR:aCols[oGDPR:nAt, nPRNMeLau] := oGDGcz:aCols[oGDGcz:nAt, nGczNomMed]
		EndIf
		//
	Next
	oGDPr:oBrowse:Refresh()

	//Materiais Agendados
	aMatMAgd := Hs_RtMMAgd(cAgdCodAge)

	For nI := 1 To len(aMatMAgd)
		If !Empty(oGDMM:aCols[IIF(nI == 1,nI, oGDMM:nAt), nMMCodDes])
			oGDMM:AddLine(.T., .F.)
			oGDMM:lNewLine := .F.
		EndIf

		If !HS_VMatMed(cGczCodPla, aMatMAgd[nI][1], cGcsArmSet)
			IF nI > 1
				aDel(oGDMM:aCols, oGDMM:nAt)
				aSize(oGDMM:aCols, Len(oGDMM:aCols)-1)
				oGDMM:Refresh()
			EndIf
			Loop
		EndIf

		If Type("nMMStaReg") # "U" .And. nMMStaReg > 0
			oGDMM:aCols[oGDMM:nAt][nMMStaReg] := "BR_VERMELHO"
		Endif
		oGDMM:aCols[oGDMM:nAt][nMMCodDes] := aMatMAgd[nI][1]
		oGDMM:aCols[oGDMM:nAt][nMMNumOrc] := aMatMAgd[nI][2]
		oGDMM:aCols[oGDMM:nAt][nMMIteOrc] := aMatMAgd[nI][3]
		oGDMM:aCols[oGDMM:nAt][nMMQtdDes] := aMatMAgd[nI][4]

		HS_DefVar("SB1", 1, aMatMAgd[nI][1], {{"oGDMM:aCols[oGDMM:nAt, nMMDDespe]", "SB1->B1_DESC"}})

	Next
	//
EndIf
lIncPro   := .T.
lRecepAgd := .F.

Return(.T.)

//Retorna Procedimentos Agendados
Function Hs_RtPrAgd(cCodAge, cCodPro, cNumOrc, cIteOrc)
Local aArea := getArea()
Local aRet  := {}
Local lExDicOrc	:= Hs_ExisDic({{"C","GO4_NUMORC"}},.F.)

Default cNumOrc := ""
Default cIteOrc := ""

If lExDicOrc .AND. !Empty(cNumOrc)
	aAdd(aRet, {cCodPro, cNumOrc, cIteOrc})
Else
	aAdd(aRet, cCodPro)
EndIf

If Hs_ExisDic({{"T","GO4"}},.F.)
	DbSelectArea("GO4")
	DbSetOrder(1) //GO4_FILIAL+GO4_CODAGE+GO4_CODPRO

	If DbSeek(xFilial("GO4")+cCodAge)

		While GO4->(!Eof()) .And. GO4->GO4_CODAGE = cCodAge .And. GO4->GO4_FILIAL = xFilial("GO4")
			If lExDicOrc .AND. !Empty(cNumOrc)
				aAdd(aRet, {GO4->GO4_CODPRO, GO4->GO4_NUMORC, GO4->GO4_ITEORC})
			Else
				aAdd(aRet, GO4->GO4_CODPRO)
			EndIf

			GO4->(DbSkip())
		EndDo

	EndIf
EndIf

RestArea(aArea)
Return(aRet)


//Retorna Procedimentos Agendados
Function Hs_RtMMAgd(cCodAge)
 Local aArea := getArea()
 Local aRet  := {}

 DbSelectArea("GEB")
 DbSetOrder(1) //GEB_FILIAL+GEB_CODAGE+GEB_ITEM+GEB_CODMAT

 If DbSeek(xFilial("GEB") + cCodAge)

  While GEB->(!Eof()) .And. GEB->GEB_CODAGE = cCodAge .And. GEB->GEB_FILIAL = xFilial("GEB")
   aAdd(aRet, {GEB->GEB_CODMAT, GEB->GEB_NUMORC, GEB->GEB_ITEORC, GEB->GEB_QTDMAT})

   GEB->(DbSkip())
  EndDo

 EndIf

 RestArea(aArea)
Return(aRet)


Function HS_M24Lote(cB8Produto, nB8Saldo, nQtdDes)
 Local lRet := .T., nForRet := 0

 If !(lRet := !(nQtdDes > nB8Saldo))
  HS_MsgInf(STR0089, STR0034, STR0148) //"A quantidade informada È maior que o saldo do lote."###"AtenÁ„o"###"ValidaÁ„o de saldo"
 Else
  If Type("__aRLote") # "U"
   For nForRet := 1 To Len(__aRLote)
    &(__aRLote[nForRet, 1]) := &(__aRLote[nForRet, 2])
   Next
  EndIf
 EndIf

Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HSPAHM24  ∫Autor  ≥Microsiga           ∫ Data ≥  08/29/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function FS_SACols(lBloqDesp,aGuiaTISS,lNrGTissAt,nAtAnt,nGczNrSeqG,nGczStatus,nGCZNUMORC)
 Local nPosACols := 0, nForGD := 0, cAliasOld := Alias()

 Default lBloqDesp := .F.

 If lBloqDesp
  oGDGcz:lUpdate := oGDGcz:aCols[oGDGcz:nAt, nGCZSTATUS] <= "2"
  oGDGcz:lDelete := oGDGcz:aCols[oGDGcz:nAt, nGCZSTATUS] <= "2"

  oGDPR:lActive  := oGDGcz:aCols[oGDGcz:nAt, nGCZSTATUS] <= "2"
  oGDPR:lInsert  := EMPTY(oGDGcz:aCols[oGDGcz:nAt, nGCZNUMORC])
  oGDPR:lUpdate  := EMPTY(oGDGcz:aCols[oGDGcz:nAt, nGCZNUMORC])
  oGDPR:lDelete  := EMPTY(oGDGcz:aCols[oGDGcz:nAt, nGCZNUMORC])

  oGDTD:lActive  := oGDGcz:aCols[oGDGcz:nAt, nGCZSTATUS] <= "2"
  oGDTD:lInsert  := EMPTY(oGDGcz:aCols[oGDGcz:nAt, nGCZNUMORC])
  oGDTD:lUpdate  := EMPTY(oGDGcz:aCols[oGDGcz:nAt, nGCZNUMORC])
  oGDTD:lDelete  := EMPTY(oGDGcz:aCols[oGDGcz:nAt, nGCZNUMORC])

  oGDMM:lActive  := oGDGcz:aCols[oGDGcz:nAt, nGCZSTATUS] <= "2"
  oGDMM:lInsert  := EMPTY(oGDGcz:aCols[oGDGcz:nAt, nGCZNUMORC])
  oGDMM:lUpdate  := EMPTY(oGDGcz:aCols[oGDGcz:nAt, nGCZNUMORC])
  oGDMM:lDelete  := EMPTY(oGDGcz:aCols[oGDGcz:nAt, nGCZNUMORC])

  If cGcyAtendi == "0" // 0-Internacao
   oGDGe2:lActive := oGDGcz:aCols[oGDGcz:nAt, nGCZSTATUS] <= "2"
   oGDGe3:lActive := oGDGcz:aCols[oGDGcz:nAt, nGCZSTATUS] <= "2"
   oGDGe8:lActive := oGDGcz:aCols[oGDGcz:nAt, nGCZSTATUS] <= "2"
  EndIf

  If cGcyAtendi <> "1" .And. cGcyAtendi <> "3" .And. cGcyAtendi <> "4"// 1-Ambulatorial e 3-Doacao
   oGDGdd:lActive := oGDGcz:aCols[oGDGcz:nAt, nGCZSTATUS] <= "2"
  EndIf
 EndIf

 cGcuCodTpg := oGDGcz:aCols[oGDGcz:nAt, nGCZCODTPG]
 cGczCodPla := oGDGcz:aCols[oGDGcz:nAt, nGCZCODPLA]
 cGczNrSeqG := oGDGcz:aCols[oGDGcz:nAt, nGCZNRSEQG]

 lNrGTissAt := aScan(aGuiaTiss,{|aVet| aVet[1] ==  oGDGcz:nAt}) > 0

 DbSelectArea("GCU")
 DbSetOrder(1)
 DbSeek(xFilial("GCU") + cGcuCodTpg)

 If     aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&4-"}) > 0 .And. GCU->GCU_MATMED == "0"
  oFolDesp:aDialogs[aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&4-"})]:lActive := .F.
 ElseIf aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&4-"}) > 0 .And. GCU->GCU_MATMED == "1"
  oFolDesp:aDialogs[aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&4-"})]:lActive := .T.
 EndIf

 If     aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&5-"}) > 0 .And. GCU->GCU_TAXDIA == "0"
  oFolDesp:aDialogs[aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&5-"})]:lActive := .F.
 ElseIf aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&5-"}) > 0 .And. GCU->GCU_TAXDIA == "1"
  oFolDesp:aDialogs[aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&5-"})]:lActive := .T.
 EndIf

 If nAtAnt # oGDGcz:nAt
  If (nPosACols := aScan(aGczGd, {| aVet | aVet[1] == nAtAnt})) == 0
   aAdd(aGczGd, {nAtAnt, {}, {}, {}, {}, {}, {}})
   nPosACols := Len(aGczGd)
  EndIf

  If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) //0-Internacao
   aGczGd[nPosACols, 2] := aClone(oGDMM:aCols)
   aGczGd[nPosACols, 3] := aClone(oGDTD:aCols)
   aGczGd[nPosACols, 4] := aClone(oGDPR:aCols)
  EndIf

  If cGcyAtendi == "0"
   aGczGd[nPosACols, 5] := aClone(oGDGE2:aCols)
   aGczGd[nPosACols, 6] := aClone(oGDGE3:aCols)
   aGczGd[nPosACols, 7] := aClone(oGDGE8:aCols)
  EndIf

  If (nPosACols := aScan(aGczGd, {| aVet | aVet[1] == oGDGcz:nAt})) > 0
   If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-Internacao
    oGDMM:SetArray(aGczGd[nPosACols, 2])
    oGDTD:SetArray(aGczGd[nPosACols, 3])
    oGDPR:SetArray(aGczGd[nPosACols, 4])
   EndIf

   If cGcyAtendi == "0"
    oGDGE2:SetArray(aGczGd[nPosACols, 5])
    oGDGE3:SetArray(aGczGd[nPosACols, 6])
    oGDGE8:SetArray(aGczGd[nPosACols, 7])
   EndIf
  Else
   If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-Internacao
    oGDMM:aCols := {}
    oGDMM:AddLine(.T., .F.)
    oGDMM:lNewLine := .F.

    oGDTD:aCols := {}
    oGDTD:AddLine(.T., .F.)
    oGDTD:lNewLine := .F.

    oGDPR:aCols := {}
    oGDPR:AddLine(.T., .F.)
    oGDPR:lNewLine := .F.
   EndIf

   If cGcyAtendi == "0"
    oGDGe2:aCols := {}
    oGDGE2:AddLine(.T., .F.)
    oGDGE2:lNewLine := .F.

    oGDGe3:aCols := {}
    oGDGE3:AddLine(.T., .F.)
    oGDGe3:lNewLine := .F.

    oGDGe8:aCols := {}
    oGDGE8:AddLine(.T., .F.)
    oGDGe8:lNewLine := .F.
   EndIf
  EndIf

  If cGcyAtendi # "0"  .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-Internacao
   oGDMM:oBrowse:Refresh()
   oGDTD:oBrowse:Refresh()
   oGDPR:oBrowse:Refresh()
  EndIf

  If cGcyAtendi == "0"
   oGDGE2:oBrowse:Refresh()
   oGDGE3:oBrowse:Refresh()
   oGDGE8:oBrowse:Refresh()
  EndIf

  nAtAnt := oGDGcz:nAt
 EndIf

 DbSelectArea(cAliasOld)
Return(.T.)

Static Function FS_VACols()
 Local lRet := .T., lRetMM := .T., lRetTD := .T., lRetPR := .T.

 If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-InternaÁ„o
  If !Empty(oGDMM:aCols[1, nMMCODDES]) .Or. Len(oGDMM:aCols) > 1
   lRetMM := oGDMM:TudoOk()
  EndIf

  If lRetMM .And. (!Empty(oGDTD:aCols[1, nTDCODDES]) .Or. Len(oGDTD:aCols) > 1)
   lRetTD := oGDTD:TudoOk()
  EndIf

  If lRetMM .And. lRetTD .And. (!Empty(oGDPR:aCols[1, nPRCODDES]) .Or. Len(oGDPR:aCols) > 1)
   lRetPR := oGDPR:TudoOk()
  EndIf

  lRet := lRetMM .And. lRetTD .And. lRetPR

 EndIf
Return(lRet)

Static Function FS_PRLFoc()
 cGbjCodEsp := Space(Len(GBJ->GBJ_ESPEC1))
 cCondAtrib := ""
Return(Nil)

Static Function FS_PRGFoc(oGDPr)
 cGbjCodEsp := oGDPR:aCols[oGDPR:nAt, nPRCODESP]
 __dDataVig := oGDPR:aCols[oGDPR:nAt, nPRDatDes]
 __cHoraAtu := oGDPR:aCols[oGDPR:nAt, nPRHorDes]
 cGA7CodPro := oGDPR:aCols[oGDPR:nAt, nPRCODDES]
 cObsCodCrm := oGDPR:aCols[oGDPR:nAt, nPRCodCrm]
 oObjFocus  := oGDPr
 cGbjTipPro := ""
 cCondAtrib := "(nPRCodVia > 0 .And. IIf(SubStr(ReadVar(), 7) == '_CODVIA', !Empty(&(ReadVar())), !Empty(oGetDados:aCols[oGetDados:nAt, nPRCodVia])) .And. !Empty(oGetDados:aCols[__nAtGD, nPRCodVia])) .Or. " + ;
               "(nPRSPrinc > 0 .And. !Empty(oGetDados:aCols[oGetDados:nAt, nPRSPrinc]) .And. oGetDados:aCols[oGetDados:nAt, nPRSPrinc] == oGetDados:aCols[__nAtGD, nPRSPrinc])"
Return(.T.)

Static Function FS_MMGFoc(oGDMM, aAlterNew, aAlterOld, nOpcM24,cOldLeiInt,cOldQuaInt,nMMCodLoc,cLctCodLoc,nMMSeqDes)
 If cAliasMM == "GD5" .And. nOpcM24 == 7
  HS_CtrlBrw(oGDMM, nMMSeqDes, aAlterNew, aAlterOld)
 EndIf
 __cCtrEst := IIF(nMMCodLoc == 0,cLctCodLoc,oGDMM:aCols[oGDMM:nAt, nMMCodLoc])
 cObsCodCrm := oGDMM:aCols[oGDMM:nAt, nMMCodCrm]
 oObjFocus  := oGDMM
 cCondAtrib := ""
Return(.T.)

Static Function FS_TDGFoc(oGDTD,nTDCodCrm)
  FS_LimpAtr()
  cObsCodCrm := oGDTD:aCols[oGDTD:nAt, nTDCodCrm]
  oObjFocus  := oGDTD
Return(.T.)

Static Function FS_LimpAtr()
 cCondAtrib := ""
Return(.T.)

Static Function FS_RetLei(cOldCodLoc,cOldQuaInt,cOldLeiInt)
 Local cAliasOld := Alias()

 If Inclui
  UnLockByName(xFilial("GAV") + cOldCodLoc + cOldQuaInt + cOldLeiInt, .T., .T., .F.)
  HSPDelFiCo("GAV",xFilial("GAV") + cOldCodLoc + cOldQuaInt + cOldLeiInt)
  UnLockByName(xFilial("GAV") + M->GCY_CODLOC + M->GCY_QUAINT + M->GCY_LEIINT, .T., .T., .F.)
  HSPDelFiCo("GAV",xFilial("GAV") + M->GCY_CODLOC + M->GCY_QUAINT + M->GCY_LEIINT)
 Endif

 DbSelectarea(cAliasOld)
Return(Nil)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_M24DF  ∫Autor  ≥Microsiga           ∫ Data ≥  08/29/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥acrescentado o parametro aHGDD por referencia               ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_M24DF(cModelo, lFolder, oGDGdd, lBuscaGb5,aHGDD,nGddCodTxd,nGddPerg,nGddQtde,nGddDesc,aCGdd)
 Local aRetDF := {}, cAliasOld := Alias(), nPTxd := 0, nUGdd := 0

 Default lFolder := .F.

 aRetDF := HS_GDesFix(,, cGczCodPla, cModelo,, .F.)

 aHGdd := aClone(aRetDF[2])

 nUGdd      := aRetDF[4] + 1
 nGddPerg   := aScan(aHGdd, {| aVet | aVet[2] == "GDD_PERG  "})
 nGddCodTxd := aScan(aHGdd, {| aVet | aVet[2] == "GDD_CODTXD"})
 nGddQtde   := aScan(aHGdd, {| aVet | aVet[2] == "GDD_QTDE  "})
 nGddDesc   := aScan(aHGdd, {| aVet | aVet[2] == "GDD_DESC  "})

 If lBuscaGb5
  DbSelectArea("GB5")
  DbSetOrder(1)
  DbSeek(xFilial("GB5") + M->GCY_REGATE) //GB5_FILIAL+GB5_REGATE+GB5_CODTXD
  While !Eof() .And. xFilial("GB5") == GB5->GB5_FILIAL .And. M->GCY_REGATE == GB5->GB5_REGATE
   If (nPTxd := aScan(aRetDF[3], {| aVet | aVet[nGddCodTxd] == GB5->GB5_CODTXD})) == 0
    aAdd(aRetDF[3], Array(nUGdd))
    nPTxd := Len(aRetDF[3])
    aRetDF[3][nPTxd][nGddCodTxd] := GB5->GB5_CODTXD
    aRetDF[3][nPTxd][nGddDesc  ] := HS_IniPadr("GAA", 1, GB5->GB5_CODTXD, "GAA_DESC",,.F.)
    aRetDF[3][nPTxd][nGddQtde  ] := GB5->GB5_QTDTXD
    aRetDF[3][nPTxd][nUGdd     ] := .F.
   EndIf

   aRetDF[3][nPTxd][nGddPerg] := IIf(GB5->GB5_STATUS == "0", "LBNO", "LBTIK")

   DbSkip()
  End
 EndIf

 DbSelectArea(cAliasOld)

 If oGDGdd # Nil
  oGDGdd:aCols := aClone(aRetDF[3])
  oGDGdd:oBrowse:Refresh()
 Else
  aCGdd := aClone(aRetDF[3])
 EndIf

 If oGDGdd # Nil
  If lFolder .And. oFolDesp:nOption # aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&6-"})
   oFolDesp:nOption := aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&6-"})
  EndIf
 EndIf

Return(aRetDF[1])



Function HS_M24When(cCpo)
 Local lRet := .T.

 If cCpo == "GCY_LOCATE"
  cGcsTipLoc := "0"
 ElseIf cCpo == "GCY_CODLOC"
  cGcsTipLoc := "34"
 ElseIf cCpo $ "GD7_CODCRM/GE7_CODCRM"
  If Empty(oGDPR:aCols[oGDPR:nAt, nPRCodAto]) .Or. HS_RAtoMed(1, oGDPR:aCols[oGDPR:nAt, nPRCodAto] + "1", .T.)[3] == "0"
   cGBJCodEsp := oGDPR:aCols[oGDPR:nAt, nPRCodEsp]
  Else
   cGBJCodEsp := SPACE(LEN(GD7->GD7_CODESP))
  EndIf
 ElseIf cCpo == "GD7_CRMLAU"
  cGBJCodEsp := SPACE(LEN(GD7->GD7_CODESP))
 ElseIf cCpo $ "GD7_DOPLER/GE7_DOPLER/GO7_DOPLER"
  lRet := HS_IniPadr("GA7", 1, oGDPR:aCols[oGDPR:nAt, nPRCodDes], "GA7_DOPLER",, .F.) == "1" // 1=Sim para dopler
 EndIf

Return(lRet)

Static Function FS_AtenOk(aGetsGcy, aTelaGcy, nOpcM24, aCposObr,nGczTATISS,nGczTIPCON,nGczDtGuia,nGCZValSen)

 Local cAliasOld := Alias(), lRet := .F., nCObr := 0, cHspMsg := "", aCposSx3 := {}, nTipD := 0
 Local cMvIdMin := GETMV("MV_IDMIN")
 Local nMvIdMax := GETMV("MV_IDMAX")
 Local cTGTISS  := GETMV("MV_IMPTISS")
 Local cVISTISS := GETMV("MV_VISTISS")
 Local nContGcz := 0

 aRotina    := aClone(aRotHM24)
 If lRet := Obrigatorio(aGetsGcy, aTelaGcy)
  If Len(aCposObr) > 0
   For nCObr := 1 To Len(aCposObr)
    If Empty(&("M->" + aCposObr[nCObr]))
     aCposSx3 := HS_CfgSx3(aCposObr[nCObr])
     If !Empty(aCposSx3[SX3->(FieldPos("X3_FOLDER"))])
      DbSelectArea("SXA")
      DbSetOrder(1)
      DbSeek("GCY" + aCposSx3[SX3->(FieldPos("X3_FOLDER"))])
      cHlpMsg := STR0071 + AllTrim(aCposSx3[SX3->(FieldPos("X3_DESCRIC"))]) + "] " + Chr(13) + Chr(10) //"Campo obrigatÛrio ["
      cHlpMsg += STR0072 + AllTrim(SXA->XA_DESCRIC) + "]" //"Pasta ["
     Else
      cHlpMsg := STR0071 + AllTrim(aCposSx3[SX3->(FieldPos("X3_DESCRIC"))]) + "]" //"Campo obrigatÛrio ["
     EndIf

     HS_MsgInf(cHlpMsg, STR0034, STR0121)//"AtenÁ„o"###"ValidaÁ„o de campos"
     lRet := .F.
     Exit
    EndIf
   Next
  EndIf

  If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3", aRotina[nOpcM24, 3] <> 7, aRotina[nOpcM24, 3] <> 4))
   If aRotina[nOpcM24, 3] # 10 .And. lRet
    lRet := oGDGCZ:TudoOk() .And. FS_VACols()
   EndIf
  EndIf

 EndIf

 If cGcyAtendi == "3"
  If lAutoriz
   If Empty(M->GCY_AUTJUD)
    HS_MsgInf(STR0174, STR0034, STR0175)//"O cÛdigo da autorizaÁ„o judicial deve ser preenchido."###"AtenÁ„o"###"ValidaÁ„o da AutorizaÁ„o"
    lRet := .F.
   EndIf
  ElseIf Val(Substr(M->GCY_IDADE, 1, 3)) < cMvIdMin
   HS_MsgInf(STR0172, STR0034, STR0173)//"O doador È menor de idade. O atendimento n„o pode ser confirmado."###"AtenÁ„o"###"Valida„o de Idade"
   lRet := .F.
  EndIf

  If M->GCY_CDMOTD $ "1/3" .And. Empty(M->GCY_DSBENE) .And. Empty(M->GCY_HOSBEN)
   HS_MsgInf(STR0182, STR0034, STR0121) //"Preencha os campos Benefici·rio e Hospital."###"AtenÁ„o"###"ValidaÁ„o dos campos"
   Return(.F.)
  ElseIf M->GCY_CDMOTD == "2" .And. Empty(M->GCY_NMBENE) .And. Empty(M->GCY_DSBENE)
   HS_MsgInf(STR0209, STR0034, STR0121) //"Preencha os campos cÛdigo benefici·rio e benefici·rio."###"AtenÁ„o"###"ValidaÁ„o dos campos"
   Return(.F.)
  EndIf

  If (Val(Substr(M->GCY_IDADE, 1, 3)) > nMvIdMax) .And. (M->GCY_NMBENE <> M->GCY_REGGER)
   HS_MsgInf(STR0178, STR0034, STR0173)//"AtenÁ„o o doador ultrapassa a idade m·xima permitida para doaÁ„o."###"AtenÁ„o"###"ValidaÁ„o de Idade"
   Return(.F.)
  EndIf

  If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3",  aRotina[nOpcM24, 3] <> 7, aRotina[nOpcM24, 3] <> 4))
   If !FS_VldInap(M->GCY_REGGER, "OK")
    Return(.F.)
   ElseIf Empty(HS_IniPadr("GGE", 1, M->GCY_CDTIPD, "GGE_INTERV",, .F. ))
    If !FS_VldPer(M->GCY_SEXO, "OK")
     Return(.F.)
    EndIf
   ElseIf !FS_VldInt("OK")
    Return(.F.)
   EndIf
  EndIf

 EndIf

 If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3",  aRotina[nOpcM24, 3] <> 7, aRotina[nOpcM24, 3] <> 4)) .And. lRet
		For nContGcz := 1 to Len(oGDGcz:aCols)
   If !(oGDGcz:aCols[nContGcz, Len(oGDGcz:aHeader)+1])
	  //AtribuiÁ„o da Variavel M->GCZ_NRGUIA para uso da Rotina HS_VLDGUI
		 If (FunName() <> "HSPAHP12" .And. !(oGDGcz:aCols[nContGcz, nGczCodPla] $ __cCodBPA+"/"+__cCodPAC+"/"+__cCodAIH)) ;
		  .Or. (FunName() $ "HSPAHP12" .And. oGDGcz:aCols[nContGcz, nGczCodPla] # __cCodBPA)
		  If (!empty(oGDGcz:aCols[nContGcz, nGCZCODPLA]))
		   M->GCZ_NRGUIA := oGDGcz:aCols[nContGcz, nGCZNrGuia]
		   If !HS_VLDGUI(oGDGcz:aCols[nContGcz, nGCZCODPLA])
		    Return(.F.)
		   EndIf
		  EndIf
		 EndIf

	   //ValidaÁ„o Somente Sus APAC
	   If FunName() == "HSPAHP12"
	    If oGDGcz:aCols[nContGcz, nGczCodPla] $ __cCodPAC
	     If Empty(oGDGcz:aCols[nContGcz, nGCZNrGuia])
	      Hs_MsgInf("Informe n˙mero do APAC","AtenÁ„o","ValidaÁ„o SUS")
	      Return(.F.)
	     ElseIf Empty(oGDGcz:aCols[nContGcz, aScan(oGDGcz:aHeader, {|aVet| aVet[2] == "GCZ_TPAPAC"})])
	      Hs_MsgInf("Informe o tipo do APAC","AtenÁ„o","ValidaÁ„o SUS")
	      Return(.F.)
      EndIf
     EndIf
    EndIf

	  //ValidaÁ„o TISS
	  If !FS_VldTISS(nContGcz,nGczTATISS,nGczTIPCON,nGczDtGuia,nGCZValSen)

	   Return(.F.)
	  EndIf
   EndIf
	 Next nContGcz
	EndIf

 If Empty(cTGTISS)
  HS_MsgInf(STR0254, STR0034, STR0163) //"Por favor preencha o par‚metro MV_IMPTISS."###"AtenÁ„o"###"ValidaÁ„o de par‚metro"
  lRet := .F.
 ElseIf Empty(cVISTISS)
  HS_MsgInf(STR0258, STR0034, STR0163) //"Por favor preencha o par‚metro MV_VISTISS."###"AtenÁ„o"###"ValidaÁ„o de par‚metro"
  lRet := .F.
 EndIf

 If HS_ExisDic({{"C", "GCY_CLISEC"}}, .F.)
	 If !Empty(M->GCY_CLISEC) .AND. Empty(M->GCY_DTCLIS)
	 	HS_MsgInf(STR0288,STR0034,STR0287)  // "Necess·rio informar a data da Clinica secund·ria do paciente!" "ATENCAO" "ValidaÁao Clinica Secund·ria"
	  	lRet := .F.
	 ElseIf Empty(M->GCY_CLISEC) .AND. !Empty(M->GCY_DTCLIS)
	 	HS_MsgInf(STR0289,STR0034,STR0287)  // "Necess·rio informar a Clinica secund·ria do paciente!" "ATENCAO" "ValidaÁao Clinica Secund·ria"
	  	lRet := .F.
	 EndIf

	 If !Empty(M->GCY_DTCLIS) .AND. lRet
	 	If M->GCY_DTCLIS < M->GCY_DATATE
	 		HS_MsgInf(STR0290,STR0034,STR0287) //"A data da Clinica secundaria do paciente n„o pode ser anterior a do atendimento!" "ATENCAO" "ValidaÁao Clinica Secund·ria"
	 		lRet := .F.
	 	EndIf
		If M->GCY_DTCLIS > dDataBase
	 		HS_MsgInf(STR0291,STR0034,STR0287) //"A data da Clinica secundaria do paciente n„o pode ser futura!" "ATENCAO" "ValidaÁao Clinica Secund·ria"
	 		lRet := .F.
	 	EndIf
	 EndIf
 EndIf
 DbSelectArea(cAliasOld)

Return(lRet)

Function HS_PRFiOk()
 If     oGDPr:oBrowse:nColPos == nPRDatDes
  __dDataVig := &(ReadVar())
 ElseIf oGDPr:oBrowse:nColPos == nPRHorDes
  __cHoraAtu := &(ReadVar())
 ElseIf oGDPr:oBrowse:nColPos == nPRCodDes
  cGA7CodPro := &(ReadVar())
 Endif
Return(.T.)

Static Function FS_PRLiOk()
 Local lRet := .F., cAliasOld := Alias()
 Local aTabPre := HS_RTabPre("GC6", cGczCodPla, oGDPR:aCols[oGDPR:nAt, nPRCodDes], oGDPR:aCols[oGDPR:nAt, nPRDatDes])
 Local cCodPan := "", nQtdAux := 0

 If Len(aTabPre) > 0
  cCodPan := HS_CodPan(oGDPR:aCols[oGDPR:nAt, nPRCodDes], aTabPre[1], oGDPR:aCols[oGDPR:nAt, nPRDatDes]) // Codigo do Porte Anestesico
  nQtdAux := HS_QtdAux(oGDPR:aCols[oGDPR:nAt, nPRCodDes], aTabPre[1], oGDPR:aCols[oGDPR:nAt, nPRDatDes]) // Quantidade de auxiliares
 EndIf

 If !(lRet := !((!Empty(cCodPan) .Or. nQtdAux > 0) .And. Empty(oGDPR:aCols[oGDPR:nAt, nPRCodAto])))
  HS_MsgInf(STR0073, STR0034, STR0147) //"O cÛdigo do ato mÈdico È obrigatÛrio para procedimentos cir˙rgicos."###"AtenÁ„o"###"ValidaÁ„o do ato mÈdico"
 EndIf

 DbSelectArea(cAliasOld)
Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_FilM24 ∫Autor  ≥Microsiga           ∫ Data ≥  16/10/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Funcao criada para executar o filtro de tela dos            ∫±±
±±∫          ≥Atendimentos (Ambulatorial, Pronto Atendimento e Internacao)∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥SIGAHSP                                                     ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_FilM24(cTipAte, lSetFilter)
Local lRet := .F.
// Local oObjMBrw := IIf(lSetFilter, GetObjBrow(), Nil)
Local oObjMBrw := GetObjBrow()
Local cAux     := ""
Local aAreaGCY := GCY->(GetArea())

HS_Sx1M24(cPergM24, cTipAte)

lFilGm1    := .T.
cGcsTipLoc := IIf(cTipAte $ "14", "1J",IIF(cTipAte <> "3",cTipAte, "C"))

If (lRet := Pergunte(cPergM24))
	cM24Par01 := MV_PAR01

	DbSelectArea("GCS")
	DbSetOrder(1)
	If DbSeek(xFilial("GCS") + cM24Par01)
		cTipAte := Iif(GCS->GCS_TIPLOC == "J", "4",cTipAte)
	EndIf

	If cTipAte <> "4"
		RestArea(aAreaGCY)
	EndIf

	If cTipAte == "0"
		cFilM24 := "GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY_LOCATE = '" + cM24Par01 + "' AND GCY_DATSAI = '" + Space(8) + "'"
	Else
		cM24Par02 := MV_PAR02
		cM24Par03 := MV_PAR03

		cFilM24 := "GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY_LOCATE  = '" + cM24Par01 + "'"
		If lAmbReab
			If cTipAte == '1' .And. SX1->(DbSeek(PADR("HSPMAA", Len(SX1->X1_GRUPO))+'04')) // Se possui a quarta pergunta do Grupo HSPMAA
				If IIf(ValType(MV_PAR04)=="C",MV_PAR04 == "2",IIf(ValType(MV_PAR04)=="N",MV_PAR04 == 2,.F.))
					cAux :=  " AND GCY_TPALTA  <> '99'  AND  GCY_TPALTA = '"+Space(Len(GCY_TPALTA))+"' "
				ElseIf  (IIf(ValType(MV_PAR04)=="C",MV_PAR04 == "1",IIf(ValType(MV_PAR04)=="N",MV_PAR04 == 1,.F.)))
					cAux :=  " AND GCY_TPALTA  <> '99'  AND  GCY_TPALTA <> '"+Space(Len(GCY_TPALTA))+"' "
				ElseIf (IIf(ValType(MV_PAR04)=="C",MV_PAR04 == "3",IIf(ValType(MV_PAR04)=="N",MV_PAR04 == 3,.F.)))
					cAux :=  " AND GCY_TPALTA  = '99' "
				EndIf
			EndIf

			cFilM24 += IIf(Empty(cM24Par02),"" , " AND GCY_DATATE >= '" + DToS(cM24Par02) + "'")
			cFilM24 += IIf(Empty(cM24Par03),"" , " AND GCY_DATATE <= '" + DToS(cM24Par03) + "'")
		Else
			If cTipAte == '1' .And. SX1->(DbSeek(PADR("HSPMAA", Len(SX1->X1_GRUPO))+'04')) // Se possui a quarta pergunta do Grupo HSPMAA
				If (cM24Par01 $ cLocReab) .Or. IIf(ValType(MV_PAR04)=="C",MV_PAR04 == "2",IIf(ValType(MV_PAR04)=="N",MV_PAR04 == 2,.F.))
					cAux :=  " AND GCY_TPALTA  <> '99'  AND  GCY_TPALTA = '"+Space(Len(GCY_TPALTA))+"' "
				ElseIf  (IIf(ValType(MV_PAR04)=="C",MV_PAR04 == "1",IIf(ValType(MV_PAR04)=="N",MV_PAR04 == 1,.F.)))
					cAux :=  " AND GCY_TPALTA  <> '99'  AND  GCY_TPALTA <> '"+Space(Len(GCY_TPALTA))+"' "
				ElseIf (IIf(ValType(MV_PAR04)=="C",MV_PAR04 == "3",IIf(ValType(MV_PAR04)=="N",MV_PAR04 == 3,.F.)))
					cAux :=  " AND GCY_TPALTA  = '99' "
				EndIf
			EndIf

			cFilM24 += IIf(Empty(cM24Par02),"" , " AND GCY_DATATE >= '" + DToS(cM24Par02) + "'")
			cFilM24 += IIf(Empty(cM24Par03),"" , " AND GCY_DATATE <= '" + DToS(cM24Par03) + "'")
		EndIf
		cFilM24 += cAux
	EndIf

	If lSetFilter
		oObjMBrw:ResetLen()
		GCY->(DbClearFilter())
		SetMBTopFilter("GCY",cFilM24,,.T.)
		oObjMBrw:GoTop()
		dBselectArea("GCY")
		GCY->(DbGoTop())
		oObjMBrw:Refresh()
	EndIf
EndIf

DbSelectArea("GCY")
cGcsTipLoc := IIf(cTipAte == "0", "34B", IIF(cTipAte == "3", "C", cTipAte))
lFilGm1    := .F.

Return(lRet)

Function HS_Sx1M24(cPerg, cTipAte)
 Local cAliasOld := Alias()

  DbSelectArea("SX1")
  DbSetOrder(1)

 If cPerg # "HSPM24" .And. cTipAte <> "0"
  DbSeek(PADR(cPerg, Len(SX1->X1_GRUPO)) + "02")
  While !Eof() .And. SX1->X1_GRUPO == cPerg
   RecLock("SX1", .F.)
    SX1->X1_CNT01 := DToC(dDataBase)
   MsUnLock()

   DbSkip()
  End
  
 DbSeek(PADR(cPerg, Len(SX1->X1_GRUPO)) + "01")
  While !Eof() .And. SX1->X1_GRUPO == PADR(cPerg, Len(SX1->X1_GRUPO))
   RecLock("SX1", .F.)
    SX1->X1_CNT01 := "  "
   MsUnLock()

   DbSkip()
  End
  
 EndIf

 DbSelectArea(cAliasOld)

Return(Nil)

Function HS_MntEqp(oGDProc, oGDTaxD, cProced)
 Local cAliasOld := Alias(), aRValPr := {}, aTabPre := {}, cCodPan := "", nForAux := 0, nPosGD := 0
 Local cCodPro   := IIf(cProced <> Nil, cProced, &(ReadVar())), aRAtoMed := {}
 Local nLSPrinc  := HS_CfgSx3(oGDProc:aHeader[nPRSPrinc, 2])[SX3->(FieldPos("X3_TAMANHO"))]
 Local nQtdAux   := 0, cDesc := "", lAtoCir := .F., lOk := .T.
 Local nAtOld    := oGDProc:nAt

 If (cProced <> Nil) .Or. (cCodPro <> Nil .And. cCodPro # oGDProc:aCols[oGDProc:nAt, nPRCodDes])
  cDesc   := HS_IniPadr("GA7", 1, cCodPro, "GA7_DESC",, .F.)
  aTabPre := HS_RTabPre("GC6", cGczCodPla, cCodPro, oGDProc:aCols[oGDProc:nAt, nPRDatDes])

  If Len(aTabPre) > 0
   cCodPan := HS_CodPan(cCodPro, aTabPre[1], oGDProc:aCols[oGDProc:nAt, nPRDatDes]) // Codigo do Porte Anestesico
   nQtdAux := HS_QtdAux(cCodPro, aTabPre[1], oGDProc:aCols[oGDProc:nAt, nPRDatDes]) // Quantidade de auxiliares
  EndIf

  If !Empty(cCodPan) .OR. nQtdAux > 0
   aRAtoMed := HS_RAtoMed(2, "011", .T.) // 1-Medico Responsavel/Cirurgi„o 1-Padrao 1-Ativo
   lOK := FS_AColsAM(oGDProc, aRAtoMed, nLSPrinc, .F., cCodPro, cDesc)
   lAtoCir := .T.
  EndIf

  If !Empty(cCodPan)
   aRAtoMed := HS_RAtoMed(2, "511", .T.) // 5-Anestesista 1-Padrao
   FS_AColsAM(oGDProc, aRAtoMed, nLSPrinc, .T., cCodPro, cDesc, oGDTaxD)
   lAtoCir := .T.
  EndIf

  For nForAux := 1 To nQtdAux
   aRAtoMed := HS_RAtoMed(2, Str(nForAux, 1) + "11", .T.) // nForAux-Auxiliares 1-Padrao 1-Ativo
   FS_AColsAM(oGDProc, aRAtoMed, nLSPrinc, .T., cCodPro, cDesc)
  Next

  oGDProc:oBrowse:Refresh()
 EndIf

 If lOk
 oGDProc:nAt := nAtOld
 EndIf

 DbSelectArea(cAliasOld)
Return({lAtoCir, lOK})

Static Function FS_AColsAM(oGDProc, aRAtoMed, nLSPrinc, lNewLine, cCodPro, cDesc, oGDTaxD)
 Local cTDPorte := ""
 Local cCodLoc := IIf(nPRCodLoc > 0 .And. !Empty(oGDProc:aCols[oGDProc:nAt, nPRCodLoc]), oGDProc:aCols[oGDProc:nAt, nPRCodLoc], cLctCodLoc)
 Local cNomLoc := HS_IniPadr("GCS", 1, cCodLoc, "GCS_NOMLOC",, .F.)
 Local cUrgDes := IIf(Type("nPRUrgDes") # "U", IIf(nPRUrgDes > 0, oGDProc:aCols[oGDProc:nAt, nPRUrgDes], "2"), "2")
 Local cCodCrm := IIf(Type("nPRCodCrm") # "U", IIf(nPRCodCrm > 0, oGDProc:aCols[oGDProc:nAt, nPRCodCrm], Space(Len(GD7->GD7_CODCRM))), Space(Len(GD7->GD7_CODCRM)))
 Local aRValPr := {}
 Local nAtAnt  := oGDPr:nAt

 If lNewLine
  oGDProc:AddLine(.F., .F.)
  oGDProc:lNewLine := .F.
  oGDPr:nAt := Len(oGDPr:aCols)
 EndIf

 If FunName() <> "HSPAHM19" //Orcamento
  If (aRValPr := HS_VProHon(cGczCodPla, cCodLoc, cCodPro,,, oGDProc:aCols[oGDProc:nAt, nPRHorDes], cUrgDes, cCodCrm, aRAtoMed[1], ;
                           {cGcyAtendi, M->GCY_ATORIG, M->GCY_IDADE, M->GCY_SEXO, M->GCY_CARATE},, oGDProc:aCols[oGDProc:nAt, nPRDatDes]))[1]
   oGDPr:nAt := nAtAnt
   cTDPorte := aRValPR[2][2][19]
   oGDProc:aCols[Len(oGDProc:aCols), nPRCodEsp] := oGDProc:aCols[oGDProc:nAt, nPRCodEsp]
   oGDProc:aCols[Len(oGDProc:aCols), nPRNomEsp] := oGDProc:aCols[oGDProc:nAt, nPRNomEsp]
   oGDProc:aCols[Len(oGDProc:aCols), nPRCodAto] := aRAtoMed[1]
   oGDProc:aCols[Len(oGDProc:aCols), nPRDesAto] := aRAtoMed[2]
   oGDProc:aCols[Len(oGDProc:aCols), nPRSPrinc] := StrZero(oGDProc:nAt, nLSPrinc)
   oGDProc:aCols[Len(oGDProc:aCols), nPROriDes] := "1" // 1-Cirurgia
   oGDProc:aCols[Len(oGDProc:aCols), nPRCodPct] := oGDProc:aCols[oGDProc:nAt, nPRCodPct]
   oGDProc:aCols[Len(oGDProc:aCols), nPRDesPct] := oGDProc:aCols[oGDProc:nAt, nPRDesPct]
   oGDProc:aCols[Len(oGDProc:aCols), nPRCodPrt] := oGDProc:aCols[oGDProc:nAt, nPRCodPrt]
   oGDProc:aCols[Len(oGDProc:aCols), nPRDesPrt] := oGDProc:aCols[oGDProc:nAt, nPRDesPrt]
  Else
   aDel(oGDProc:aCols, Len(oGDProc:aCols))
   aSize(oGDProc:aCols, Len(oGDProc:aCols) - 1)
   If Len(oGDProc:aCols) == 0
    oGDProc:AddLine(.F., .F.)
    oGDProc:lNewLine := .F.
   EndIf
   oGDProc:nAt := Len(oGDProc:aCols)
   Return(.F.)
  Endif
 EndIf

 If Type("nPRCodLoc") <> "U" .And. nPRCodLoc > 0
  oGDProc:aCols[Len(oGDProc:aCols), nPRCodLoc] := cCodLoc
  oGDProc:aCols[Len(oGDProc:aCols), nPRNomLoc] := cNomLoc
 EndIf

 oGDProc:aCols[Len(oGDProc:aCols), nPRDatDes] := oGDProc:aCols[oGDProc:nAt, nPRDatDes]
 oGDProc:aCols[Len(oGDProc:aCols), nPRHorDes] := oGDProc:aCols[oGDProc:nAt, nPRHorDes]
 oGDProc:aCols[Len(oGDProc:aCols), nPRCodDes] := cCodPro
 oGDProc:aCols[Len(oGDProc:aCols), nPRDDespe] := cDesc

 If Type("nPRCODCRM") # "U" .And. nPRCODCRM > 0 .And. cGcyAtendi == "3"
  oGDProc:aCols[Len(oGDProc:aCols), nPRCODCRM] := M->GCY_CODCRM
  oGDProc:aCols[Len(oGDProc:aCols), nPRNomMed] := M->GCY_NOMMED
 EndIf

 If Type("nPRTABELA") # "U" .And. nPRTABELA > 0 .And. aRValPr[1]
  oGDProc:aCols[Len(oGDProc:aCols), nPRTABELA] := aRValPr[2][2][20]
 EndIf

 If oGDTaxD <> Nil .And. !Empty(cTDPorte)
  If !Empty(oGDTaxD:aCols[Len(oGDTaxD:aCols), nTDCodDes])
   oGDTaxD:AddLine(.F., .F.)
   oGDTaxD:lNewLine := .F.
  EndIf

  If !IIf(FunName() <> "HSPAHM19", HS_VldTaxD(cGczCodPla, cCodLoc, cTDPorte,,,,, HS_RetCrm(oGDTD:aCols, oGDTD:nAt, nTDCodCrm, M->GCY_CODCRM), oGDTD:aCols[oGDTD:nAt, nTDHorDes], {cGcyAtendi, M->GCY_CARATE}), HS_VldTaxD(cGczCodPla, cCodLoc, cTDPorte))
   aDel(oGDTaxD:aCols, Len(oGDTaxD:aCols))
   aSize(oGDTaxD:aCols, Len(oGDTaxD:aCols) - 1)
   If Len(oGDTaxD:aCols) == 0
    oGDTaxD:AddLine(.F., .F.)
    oGDTaxD:lNewLine := .F.
   EndIf
   oGDTaxD:nAt := Len(oGDTaxD:aCols)
   Return(.F.)
  EndIf

  If Type("nTDCodLoc") <> "U" .And. nTDCodLoc > 0
   oGDTaxD:aCols[Len(oGDTaxD:aCols), nTDCodLoc] := cCodLoc
   oGDTaxD:aCols[Len(oGDTaxD:aCols), nTDNomLoc] := cNomLoc
  EndIf

  oGDTaxD:aCols[Len(oGDTaxD:aCols), nTDCodDes] := cTDPorte
  oGDTaxD:aCols[Len(oGDTaxD:aCols), nTDQtdDes] := 1
  oGDTaxD:aCols[Len(oGDTaxD:aCols), nTDDatDes] := oGDProc:aCols[oGDProc:nAt, nPRDatDes]
  oGDTaxD:aCols[Len(oGDTaxD:aCols), nTDHorDes] := oGDProc:aCols[oGDProc:nAt, nPRHorDes]

  oGDTaxD:oBrowse:Refresh()
 EndIf

Return(.T.)

Function HS_CalcVias(aCtrlVias, cAliasProc, aOrdProc, lCalcRep, aIncide, lOrcam)
Local nForDC := 0, nForVias := 0, cAliasOld := Alias(), cPict := HS_CfgSx3("GD7_VALDES")[SX3->(FieldPos("X3_PICTURE"))]
Local aMProc := {}, aChsProc := {}, nPMedi := 0, nPProc := 0, nPForDC := 0, nPForVias := 0, nMaiorVal := 0, cCodVia := "XXXXXX"
Local aValRep := {}
Local cVia	:= ""

Default lCalcRep := .F.
Default lOrcam   := .F.
Default aIncide  := {}

For nForDC := 1 To Len(aCtrlVias)
	nMaiorVal := 0
	nPForDC   := 0
	nPForVias := 0

  	aSort(aCtrlVias[nForDC][3],,, {|x, y| x[2] + TransForm(x[1], cPict) + TransForm(x[5], cPict) > y[2] + TransForm(y[1], cPict) + TransForm(y[5], cPict)})
  	For nForVias := 1 To Len(aCtrlVias[nForDC][3])
		// Retorna qual o tipo se refere esta guia de acesso
		cCodVia := Posicione("GE4",1,xFilial("GE4")+aCtrlVias[nForDC][3][nForVias][2],"GE4_VIA")
		If cCodVia == "D" // Verifia se e Diferentes Vias
			aCtrlVias[nForDC][3][nForVias][4] := HS_RPerVA(aCtrlVias[nForDC][3][nForVias][7], "#") / 100
		ElseIf cCodVia == "M" // Verifica se e Mesma Via
   			aCtrlVias[nForDC][3][nForVias][4] := HS_RPerVA(aCtrlVias[nForDC][3][nForVias][7], "=") / 100
   		Else
   			cVia := cCodVia
   		EndIf

   		If aCtrlVias[nForDC][3][nForVias][1] > nMaiorVal
    		nMaiorVal := aCtrlVias[nForDC][3][nForVias][1]
    		nPForDC   := nForDC
    		nPForVias := nForVias
			cVia      := cCodVia
   		EndIf

		FS_ACoeAto(cAliasProc, 1, aCtrlVias[nForDC][3][nForVias][3], aCtrlVias[nForDC][3][nForVias][4], lCalcRep, @aValRep, , aIncide, lOrcam)
	Next nForVias

	aMProc := aClone(aCtrlVias[nPForDC][3])
	aChsProc := {}

	While (nPProc := aScan(aMProc, {| aVet | (aVet[1] == aCtrlVias[nPForDC][3][nPForVias][1] .or. aVet[4] == 0) }, nPProc + 1)) > 0
		aAdd(aChsProc, {nPForDC, nPProc, aMProc[nPProc][1], aMProc[nPProc][5], aMProc[nPProc][4]})
	End

	If Len(aChsProc) > 1
	   	aSort(aChsProc,,, {|x, y| x[4] + x[5]  < y[4] + y[5]})
	EndIf

	nPForDC   := aChsProc[1][1]
	nPForVias := aChsProc[1][2]

	// Forco o posicionamento no procedimento de maior valor, para pegar o tipo de via Unica
	cCodVia := Posicione("GE4",1,xFilial("GE4")+aCtrlVias[nPForDC][3][nPForVias][2],"GE4_VIA")

	If cCodVia == "U"
		aCtrlVias[nPForDC][3][nPForVias][4] := HS_RPerVA(aCtrlVias[nPForDC][3][nPForVias][7], ">") / 100
		FS_ACoeAto(cAliasProc, 1, aCtrlVias[nPForDC][3][nPForVias][3], aCtrlVias[nPForDC][3][nPForVias][4], lCalcRep, aValRep, .T., aIncide, lOrcam)
	EndIf

Next nForDC

DbSelectArea(cAliasOld)
Return(Nil)

//GravaÁ„o do coeficiente dos procedimentos de acordo com o calculo de vias de acesso
Static Function FS_ACoeAto(cAliasProc, nOrdProc, cSeqDes, nCoeDes, lCalcRep, aRepasse, lMaiorVal, aIncide, lOrcam)
Local aAreaOld := GetArea()
Local nIncide  := 0, nValRep := 0, nValReb := 0
Local lValReb  := HS_ExisDic({{"C", cAliasProc + "_VALREB"}}, .F.)


Default lMaiorVal := .F.

DbSelectArea(cAliasProc)
DbSetOrder(nOrdProc)
DbSeek(xFilial(cAliasProc) + cSeqDes)

While !Eof() .And. FieldGet(FieldPos(cAliasProc + "_FILIAL")) == xFilial(cAliasProc) .And. ;
	(IIF(nOrdProc == 1, IIF(lOrcam, FieldGet(FieldPos(cAliasProc + "_NUMORC")) + FieldGet(FieldPos(cAliasProc + "_ITEM")),;
	FieldGet(FieldPos(cAliasProc + "_SEQDES"))), FieldGet(FieldPos(cAliasProc + "_SPRINC")))) == cSeqDes

	RecLock(cAliasProc, .F.)
	FieldPut(FieldPos(cAliasProc + "_COEDES"), nCoeDes)
	If lCalcRep
		If !lMaiorVal
			AADD(aRepasse, { FieldGet(FieldPos(cAliasProc + "_SEQDES")),  FieldGet(FieldPos(cAliasProc + "_VALREP")), IIF(lValReb, FieldGet(FieldPos(cAliasProc + "_VALREB")), 1)})
		Endif

		nValRep := IIF(lMaiorVal, aRepasse[Ascan(aRepasse,{ |x| x[1] == FieldGet(FieldPos(cAliasProc + "_SEQDES"))}),2], FieldGet(FieldPos(cAliasProc + "_VALREP")))
		If lValReb
			nValReb := IIF(lMaiorVal, aRepasse[Ascan(aRepasse,{ |x| x[1] == FieldGet(FieldPos(cAliasProc + "_SEQDES"))}),3], FieldGet(FieldPos(cAliasProc + "_VALREB")))
		Endif
		If !Empty(aIncide)
			nIncide := Ascan(aIncide,{ |x| x[1] == FieldGet(FieldPos(cAliasProc + "_SEQDES"))})
		Endif
		FieldPut(FieldPos(cAliasProc + "_VALREP"), (nValRep * nCoeDes) * IIF(nIncide > 0, aIncide[nIncide, 2], 1))
		If lValReb
			FieldPut(FieldPos(cAliasProc + "_VALREB"), (nValReb * nCoeDes) * IIF(nIncide > 0, aIncide[nIncide, 2], 1))
		Endif
	Endif

	MsUnLock()

	DbSkip()
End

RestArea(aAreaOld)
Return(Nil)

Function HS_RelM24(cAlias, nReg, nOpc)
 GDN->(dbSetOrder(1))
 If GDN->(DbSeek(xFilial("GDN") + GCY->GCY_LOCATE))

  HSPAHP44(.F., GCY->GCY_LOCATE, {{"GBH", 1, GCY->GCY_REGGER}, {"GSB", 1, GCY->GCY_REGGER + HS_RCodEnd(GCY->GCY_ATENDI, GCY->GCY_REGGER, GCY->GCY_REGATE)} })

 EndIf
 If ExistBlock("HSM24FCH") .And. GCY->GCY_ATENDI $ "1/2"
  Execblock("HSM24FCH",.f.,.f.,{.F.})
 Endif

Return

Static Function FS_VldDesG(cCodTpg)
 Local lRet := .T., nForProc := 0, cAliasOld := Alias(), cLstPro := "", cErro := "", nQtdPrc := 0

 DbSelectArea("GCX")
 DbSetOrder(1)

 For nForProc := 1 To Len(oGDPr:aCols)
  If !Empty(oGDPr:aCols[nForProc, nPRCodDes]) .And. !DbSeek(xFilial("GCX") + cCodTpg + oGDPr:aCols[nForProc, nPRCodDes])
   lRet := .F.
   cLstPro +=  IIf(!Empty(cLstPro), ", ", "") + oGDPr:aCols[nForProc, nPRCodDes]
   nQtdPrc++
  EndIf
 Next

 If !lRet
  If nQtdPrc > 1
   cErro := STR0090 + cLstPro + STR0091 //"Os procedimentos ["###"] n„o s„o permitidos no tipo de guia informado."
  Else
   cErro := STR0092 + cLstPro + STR0093 //"O procedimento ["###"] n„o È permitido no tipo de guia informado."
  EndIf

  HS_MsgInf(cErro, STR0034, STR0149) //"AtenÁ„o"###"ValidaÁ„o de despesas"
 Else
  DbSelectArea("GCU")
  DbSetOrder(1)
  DbSeek(xFilial("GCU") + cCodTpg)

  cErro := STR0094 //"Existem ["

  If     aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&4-"}) > 0 .And. GCU->GCU_MATMED == "0"
   If (Len(oGDMM:aCols) == 1 .And. !Empty(oGDMM:aCols[1, nMMCodDes])) .Or. Len(oGDMM:aCols) > 1
    lRet := .F.
    cErro += STR0095 //"materiais, medicamentos"
   Else
    oFolDesp:aDialogs[aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&4-"})]:lActive := .F.
   EndIf
  ElseIf aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&4-"}) > 0 .And. GCU->GCU_MATMED == "1"
   oFolDesp:aDialogs[aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&4-"})]:lActive := .T.
  EndIf

  If     aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&5-"}) > 0 .And. GCU->GCU_TAXDIA == "0"
   If (Len(oGDTD:aCols) == 1 .And. !Empty(oGDTD:aCols[1, nTDCodDes])) .Or. Len(oGDTD:aCols) > 1
    lRet := .F.
    cErro += STR0096 //"taxas, diarias"
   Else
    oFolDesp:aDialogs[aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&5-"})]:lActive := .F.
   EndIf
  ElseIf aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&5-"}) > 0 .And. GCU->GCU_TAXDIA == "1"
   oFolDesp:aDialogs[aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&5-"})]:lActive := .T.
  EndIf

  cErro +=  STR0097 //"] na guia e o tipo de guia informado n„o permite."

  If !lRet
   HS_MsgInf(cErro, STR0034, STR0149) //"AtenÁ„o"###"ValidaÁ„o de despesas"
  EndIf
 EndIf

 DbSelectArea(cAliasOld)
Return(lRet)
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± FUNCTION: FS_IniGE8() AUTOR: MARCELO JOSE                                 ±±
±± A primeira guia deve ser incluÌda automaticamente no momento da internaÁ„o±±
±± do paciente com a possibilidade do usu·rio alterar a quantidade de dias.  ±±
±± Neste caso a data do vencimento ser· calculada atravÈs da data da         ±±
±± internaÁ„o + a quantidade de dias liberados.                              ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function FS_IniGE8()
 If oGDGCZ <> Nil .And. cGcyAtendi == "0" .and. Empty(oGDGCZ:aCols[oGDGCZ:nAt, nGczNrSeqG])
  oGDGe8:aCols[1, nGe8CodCrm] := M->GCY_CODCRM
  oGDGe8:aCols[1, nGe8NomMed] := HS_IniPadr("SRA", 11, M->GCY_CODCRM, "RA_NOME",,.F.)
  oGDGe8:aCols[1, nGe8DatSol] := DDATABASE
  oGDGe8:aCols[1, nGe8QtDias] := 1
  oGDGe8:aCols[1, nGe8DatLib] := DDATABASE
  oGDGe8:aCols[1, nGe8QtdLib] := 1
  oGDGe8:aCols[1, nGe8DatVen] := DDATABASE + 1
  oGDGe8:oBrowse:Refresh()
 EndIf
Return(.T.)

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±      chama etiqueta do PRONTUARIO DO PACIENTE                           ±±
±±      MARCELO JOSE                                       30/08/2005      ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
//*** ATENCAO ESTA ETIQUETA E PARA OS GCY - MOVIMENTACAO
FUNCTION HS_ETQPRON()
 Local cNomeEtq := ALLTRIM(GETMV("MV_ETIQPRO"))
 Local oDlgEtiq, oSay1, oGet1
 Local nOpcA := 0
 Local nQtde := 1
 Local nGet1 := 1

 IF !Empty(cNomeEtq)
  /* 1o. parametro nome da etiqueta*/
  /* 2o. parametro matriz com: 1=qtde de cada etiq. parametro pergunta de/ate */
  DEFINE MSDIALOG oDlgEtiq FROM 0,0 TO 80,390 PIXEL TITLE "IMPRESSAO DE ETIQUETAS"
   oSay1:=tSay():New(20, 15,{||"Informe a quantidade de etiquetas para imprimir: "},oDlgEtiq,,,,,,.T.,CLR_BLACK,,130,100)
   oGet1:=tGet():New(20,130,{|u| if(PCount()>0,nGet1:=u,nGet1)}, oDlgEtiq, 15,10,"99",,,,,,,.T.,,,,,,,,,,"nGet1")
  ACTIVATE MSDIALOG oDlgEtiq CENTERED ON INIT EnchoiceBar(oDlgEtiq, {|| nOpcA := 1,oDlgEtiq:End()}, {|| nOpcA := 0, oDlgEtiq:End()})
  If nOpcA == 1
   If nGet1 > 0
    HSPAHR71(cNomeEtq,{nGet1,GCY->GCY_REGATE,GCY->GCY_REGATE} )
   EndIf
  EndIf
 Else
  MsgStop(STR0171, STR0034)//"Por favor informe o nome da etiqueta no par‚metro MV_ETIQPRO. OperaÁ„o cancelada."###"AtenÁ„o"
 EndIf
Return(Nil)

Function HS_PacM24(cAliasM24, nRegM24, nOpcM24)
 Local aArea := GetArea()
 Local cCodPac   := ""

 HS_PosSX1({{"HSP24B", "01", GCY->GCY_REGGER}})

 If !Pergunte("HSP24B", .T.)
 	Return()
 EndIf

 If !Empty(MV_PAR01) .and. MV_PAR01 <> GCY->GCY_REGGER
  cCodPac := MV_PAR01
 Else
  cCodPac := GCY->GCY_REGGER
 Endif

 DbSelectArea("GBH")
 DbSetOrder(1)
 If DbSeek(xFilial("GBH") + cCodPac)

  HS_A58("GBH", GBH->(RecNo()), nOpcM24)

 Else

  HS_MsgInf(STR0036, STR0034, STR0134) //"Prontu·rio n„o encontrado."###"AtenÁ„o"###"ValidaÁ„o do Prontu·rio"

 EndIf

 RestArea(aArea)
Return(Nil)

Function HS_DtSxIdP()

 If MsgYesNo(STR0170)//"Confirma processamento"
  Processa({|| FS_DtSxIdG()})
 EndIf

Return(Nil)

Static Function FS_DtSxIdG()

 DbSelectArea("GCY")
 DbSetOrder(1)
 DbSeek(xFilial("GCY"))

 ProcRegua(RecCount())

 While !Eof() .And. GCY->GCY_FILIAL == xFilial("GCY")

  IncProc(STR0169 + GCY->GCY_REGATE + STR0212 + GCY->GCY_REGGER)//"Gravando Dt. Nasc., sexo e idade no atdto "###"Paciente"

  DbSelectArea("GBH")
  DbSetOrder(1)
  If DbSeek(xFilial("GBH") + GCY->GCY_REGGER)

   RecLock("GCY", .F.)
    GCY->GCY_DTNASC := GBH->GBH_DTNASC
    GCY->GCY_SEXO   := GBH->GBH_SEXO
    GCY->GCY_IDADE  := HS_AgeGer(GBH->GBH_DTNASC, GCY->GCY_DATATE)
   MsUnLock()

  EndIf

  DbSelectArea("GCY")
  DbSkip()
 End

Return(Nil)


Static Function FS_VldEsp(cCodCrm)
 Local lRet := .T.
 Local lAltEsp := GetNewPar("MV_GHALTES",.F.) .And. Iif(ValType(cGczCodPla) <> "U",cGczCodPla $ GetNewPar("MV_PSUSBPA",""),.F.)


 If !lAltEsp
  If Empty(oGDPR:aCols[oGDPR:nAt, nPRCodAto]) .Or. HS_RAtoMed(1, oGDPR:aCols[oGDPR:nAt, nPRCodAto] + "1", .T.)[3] == "0"
   lRet := (oGDPR:aCols[oGDPR:nAt, nPRCODESP] $ HS_REspMed(cCodCrm))
  EndIf
 Else
  If (Empty(oGDPR:aCols[oGDPR:nAt, nPRCodAto]) .Or. HS_RAtoMed(1, oGDPR:aCols[oGDPR:nAt, nPRCodAto] + "1", .T.)[3] == "0") .And. !Empty(oGDPR:aCols[oGDPR:nAt, nPRCODESP])
   lRet := (oGDPR:aCols[oGDPR:nAt, nPRCODESP] $ HS_REspMed(cCodCrm))
  EndIf
 Endif

Return(lRet)

Static Function FS_ChgGD(oDesp, nCodLoc)

 If nCodLoc > 0
  HS_DefVar("GCS", 1, oDesp:aCols[oDesp:nAt, nCodLoc], {{"cGcsCodLoc", "GCS->GCS_CODLOC"}, ;
                                                        {"cGcsCodCCu", "GCS->GCS_CODCCU"}, ;
                                                        {"cGcsArmSet", "GCS->GCS_ARMSET"}, ;
                                                        {"cGcsArmFar", "GCS->GCS_ARMFAR"}})
 EndIf

Return(.T.)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥HS_M24CCES≥ Autor ≥ Mario Arizono         ≥ Data ≥ 20/01/06 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Informa se o setor do paciente e do tipo CC ou Espera .    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAHSP                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function HS_M24CCEs(cCodLoc)
 Local aArea   := GetArea()
 Local cTipLoc := ""

 DbSelectArea("GCS")
 DbSetOrder(1)
 Dbseek(xFilial("GCS")+cCodLoc)  //GCS_FILIAL+GCS_CODLOC
 cTipLoc := GCS->GCS_TIPLOC

 RestArea(aArea)

Return(cTipLoc)

Function HS_GDAtrib(oGetDados, aPosAtrib)
 Local nPosAtrib := 1, lGDAtrib := .F.
 Local nForAtrib := 0, cCndAt := ""

 Private oGDATrib := oGetDados

 For nPosAtrib := 1 To Len(aPosAtrib)
  If Len(aPosAtrib[nPosAtrib]) < 3 .Or. ;
   oGetDados:aCols[oGetDados:nAt, aPosAtrib[nPosAtrib, 1]] == IIf(oGetDados:aCols[oGetDados:nAt, Len(oGetDados:aHeader) + 1], aPosAtrib[nPosAtrib, 2], aPosAtrib[nPosAtrib, 3])
   oGetDados:aCols[oGetDados:nAt, aPosAtrib[nPosAtrib, 1]] := IIf(!oGetDados:aCols[oGetDados:nAt, Len(oGetDados:aHeader) + 1], aPosAtrib[nPosAtrib, 2], aPosAtrib[nPosAtrib, 3])
  EndIf
 Next

 If Type("cCondAtrib") <> "U" .And. !Empty(cCondAtrib)

  For nForAtrib := 1 To Len(oGetDados:aCols)
   cCndAt := cCondAtrib
   cCndAt := StrTran(cCndAt, "oGetDados", "oGDATrib")
   cCndAt := StrTran(cCndAt, "__nAtGD", AllTrim(Str(nForAtrib)))
   If oGetDados:nAt <> nForAtrib .And. &(cCndAt)
    For nPosAtrib := 1 To Len(aPosAtrib)
     If oGetDados:aCols[nForAtrib, aPosAtrib[nPosAtrib, 1]] == "BR_VERDE"
      oGetDados:aCols[nForAtrib, aPosAtrib[nPosAtrib, 1]] := "BR_AMARELO"
     EndIf
    Next
   EndIf
  Next

 EndIf

Return(.T.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_VldSUS ∫Autor  ≥Mario Arizono       ∫ Data ≥  28/07/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Valida se o plano e do SUS e preenche o Nr da Guia.         ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GH                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_VldSUS(cCodPla,cRegate)
	Local aArea   := GetArea()
	Local cNrGuia := SPACE(LEN(GCZ->GCZ_NRGUIA))

 If cMV_AteSus == "S"
  If FunName() <> "HSPAHP12"
   If cCodPla == __cCodBPA
    cNrGuia := "BPA" + cRegate
   ElseIf cCodPla == __cCodPAC
    cNrGuia := "APAC"
   Else
    cNrGuia := SPACE(LEN(GCZ->GCZ_NRGUIA))
   Endif
  Else
   If cCodPla == __cCodBPA
    cNrGuia := "BPA" + cRegate
   Else
    cNrGuia := SPACE(LEN(GCZ->GCZ_NRGUIA))
   Endif
  Endif
 Else
  cNrGuia := SPACE(LEN(GCZ->GCZ_NRGUIA))
 Endif
 RestArea(aArea)

Return(cNrGuia)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HS_VldDtMv∫Autor  ≥Cibele Peria        ∫ Data ≥  14/07/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥Valida as datas digitadas nas perguntas dos grupos HSPMAA e ∫±±
±±∫          ≥HSPMAI.                                                     ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function HS_VldDtMv(dDataI, dDataF)
 Local lRet := .T.
 If !Empty(dDataI) .And. !Empty(dDataF) .And. !(lRet := (dDataI <= dDataF))
  HS_MsgInf(STR0167, STR0034, STR0168)//"Data inv·lida"###"AtenÁ„o"###"ValidaÁ„o das perguntas"
 Endif
Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HS_CposM24∫Autor  ≥Daniel Peixoto      ∫ Data ≥  28/08/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Rotina utilizada para atualizar em tempo de execucao campos∫±±
±±∫          ≥ de data e hora quando houver virada de dia.                ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function HS_CposM24(dDatAte, lRefresh)
Local aCposGcy := {{"GCY_DATATE", "GCY_HORATE"}}
Local aCposGD  := {}
Local nCont    := 0, nCont1 := 0, nCpo := 0, nPos := 0

DEFAULT dDatAte  := DDATABASE
DEFAULT lRefresh := .T.

 //Atualiza Campos da GCY
 For nCont := 1 to Len(aCposGcy)
  For nCpo := 1 to 2
   If !EMPTY(&("M->" + aCposGcy[nCont, nCpo]))
    &("M->" + aCposGcy[nCont, nCpo]) := IIF(nCpo == 1, dDatAte, Time())
   EndIf
  Next
 Next

 If lRefresh
 oEncGcy:Refresh()
 EndIf

 If cGcyAtendi == "0" //Internacao
  aCposGD  := {{"oGDGcz", "GCZ_DCPARI", ""}, ;
               {"oGDGcz", "GCZ_VALSEN", ""}, ;
               {"oGDGcz", "GCZ_DTGUIA", ""}, ;
               {"oGDGE8", "GE8_DATSOL", ""}}
               //{"oGDGcz", "GCZ_DCPARF", ""}, ; // Este campo foi tirado do array, devido ao controle impressao da guia tiss
               //{"oGDGE2", "GE2_DATSOL", "GE2_HORSOL"}, ;  // CONTROLE EFETUADO PELA CENTRAL DE AUTORIZACOES
               //{"oGDGE3", "GE3_DATSOL", "GE3_HORSOL"}, ; // CONTROLE EFETUADO PELA CENTRAL DE AUTORIZACOES

 ElseIf cGcyAtendi $ "1/4" .Or. cGcyAtendi == "2" //Amb. ou PA
  aCposGD  := {{"oGDGcz", "GCZ_DCPARI", ""}, ;
               {"oGDGcz", "GCZ_DCPARF", ""}, ;
               {"oGDGcz", "GCZ_VALSEN", ""}, ;
               {"oGDGcz", "GCZ_DTGUIA", ""}, ;
               {"oGDMM" , "GD5_DATDES", "GD5_HORDES"}, ;
               {"oGDTD" , "GD6_DATDES", "GD6_HORDES"}, ;
               {"oGDPR" , "GD7_DATDES", "GD7_HORDES"}}
 EndIf

 //Atualiza Campos da GetDados
 For nCont := 1 to Len(aCposGD)
  For nCont1 := 1 to Len(&(aCposGD[nCont, 1]):aCols)
   For nCpo := 2 to 3
    If !EMPTY(aCposGD[nCont, nCpo]) .And. (nPos := aScan(&(aCposGD[nCont, 1]):aHeader, {|aVet| aVet[2] == aCposGD[nCont, nCpo]})) > 0
     &(aCposGD[nCont, 1]):aCols[nCont1, nPos] := IIF(nCpo == 2, dDatAte, Time())
    EndIf
   Next
  Next
  If lRefresh
  &(aCposGD[nCont, 1]):Refresh()
  EndIf
 Next

Return(Nil)



/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_VldPer ∫Autor  ≥Patricia Queiroz    ∫ Data ≥  13/11/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥Valida o periodo de doacao.                                 ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_VldPer(cSexo, cOpc)

 Local lRet      := .T.
 Local cSql      := ""
 Local dDatAte   := ""
 Local nPerDoac  := ""
 Local nMvQtdMas := GETMV("MV_QTDMAS")
 Local nMvQtdFem := GETMV("MV_QTDFEM")
 Local nMvIntFem := GETMV("MV_INTFEM")
 Local nMvIntMas := GETMV("MV_INTMAS")
 Local cDoador   := M->GCY_REGGER
 Local cAliasOld := Alias()

 Default cOpc := ""

 If M->GCY_NMBENE <> M->GCY_REGGER
  If Empty(M->GCY_AUTJUD)
   If Empty(nMvQtdMas)
    HS_MsgInf(STR0166, STR0034, STR0163)//"Por favor preencha o par‚metro que indica a quantidade de vezes que o homem pode doar sangue, em 12 meses."###"AtenÁ„o"###"ValidaÁ„o de Par‚metro"
    If !Empty(cOpc)
     Return(.F.)
    Else
     Return(.T.)
    EndIf
   EndIf

   If Empty(nMvQtdFem)
    HS_MsgInf(STR0165, STR0034, STR0163)//"Por favor preencha o par‚metro que indica a quantidade de vezes que a mulher pode doar sangue, em 12 meses."###"AtenÁ„o"###"ValidaÁ„o de Par‚metro"
    If !Empty(cOpc)
     Return(.F.)
    Else
     Return(.T.)
    EndIf
   EndIf

   If Empty(nMvIntFem)
    HS_MsgInf(STR0164, STR0034, STR0163)//"Por favor preencha o par‚metro que indica o intervalo de tempo que a mulher pode doar sangue, em 12 meses."###"AtenÁ„o"###"ValidaÁ„o de Par‚metro"
    If !Empty(cOpc)
     Return(.F.)
    Else
     Return(.T.)
    EndIf
   EndIf


   If Empty(nMvIntMas)
    HS_MsgInf(STR0162, STR0034, STR0163)//"Por favor preencha o par‚metro que indica o intervalo de tempo que o homen pode doar sangue, em 12 meses."###"AtenÁ„o"###"ValidaÁ„o de Par‚metro"
    If !Empty(cOpc)
     Return(.F.)
    Else
     Return(.T.)
    EndIf
   EndIf

   dDatAte := dDataBase - 365

   cSql := "SELECT MAX(GCY.GCY_DATATE) QRY_DATATE, COUNT(*) QRY_TOTAL "
   cSql += " FROM " + RetSqlName("GCY") + " GCY "
   cSql += "WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
   cSql += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAte) + "' AND '" + DTOS(dDataBase) + "' "
   cSql += " AND GCY.GCY_REGGER = '" + cDoador + "' AND GCY.GCY_ATENDI = '3' "

   cSQL := ChangeQuery(cSQL)
   TCQUERY cSQL NEW ALIAS "QRY"

   nPerDoac := dDataBase - STOD(QRY_DATATE)

   If (cSexo == "0" .And. QRY_TOTAL >= nMvQtdMas) .Or. (cSexo == "1" .And. QRY_TOTAL >= nMvQtdFem)
    HS_MsgInf(STR0156, STR0034, STR0157)//"O doador j· efetuou a quantidade de doaÁıes permitida para um ano."###"AtenÁ„o"###"ValidaÁ„o de DoaÁıes"
    lRet := IIF(!Empty(cOpc), .F., .T.)
   ElseIf nPerDoac < nMvIntMas .Or. nPerDoac < nMvIntFem
    HS_MsgInf(STR0158, STR0034, STR0157)//"A doaÁ„o n„o pode ser efetuada. A data da ˙ltima doaÁ„o n„o atinge o intervalo permitido."###"AtenÁ„o"###"ValidaÁ„o de DoaÁıes"
    lRet := IIF(!Empty(cOpc), .F., .T.)
   EndIf
   DbCloseArea()
  EndIf
 EndIf

 DbSelectArea(cAliasOld)

Return(lRet)


//Funcaoque monta a tela para validacao do usuario responsavel pela autorizacao da doacao
Static Function FS_Login()

Local cSenha := Space(6)
Local lRet   := .F.

DEFINE MSDIALOG oDlgS TITLE OemToAnsi(STR0159) From 3, 0 To 09, 44 Of oMainWnd //"Senha"

@ 15, 010 SAY OemToAnsi(STR0160) OF oDlgS PIXEL COLOR CLR_BLUE //"Usuario:"
@ 15, 035 MSGET OUsuario VAR cUsu SIZE 060, 4 OF oDlgS PIXEL COLOR CLR_BLACK
@ 30, 010 SAY OemToAnsi(STR0161) OF oDlgS PIXEL COLOR CLR_BLUE //"Senha:"
@ 30, 035 MSGET OSenha VAR cSenha SIZE 040, 4 PASSWORD OF oDlgS PIXEL COLOR CLR_BLACK
ACTIVATE MSDIALOG oDlgS ON INIT EnchoiceBar(oDlgS, {|| IIF(lRet := FS_Verific(@cUsu, cSenha), oDlgS:End(), Nil)}, {||lRet := .F., oDlgS:End()}) CENTER

Return(lRet)



Static Function FS_Verific(cUsu, cSenha)

Local lRet     := .T.
Local cMvResAu := GETMV("MV_RESAUTO")

If Empty(cUsu)
 PswOrder(3)
 If PswSeek(cSenha, .T.)
  cUsu := pswret(1)[1, 2]
  lRet := .T.
 Else
  HS_MsgInf(STR0153, STR0034, STR0154)//"Senha Inv·lida."###"AtenÁ„o"###"ValidaÁ„o de Senha"
  lRet := .F.
 EndIf
Else
 If !(lRet := AllTrim(cUsu) $ cMvResAu)
  HS_MsgInf(STR0155, STR0034, STR0152)//"O usu·rio informado n„o possui autorizaÁ„o."###"AtenÁ„o"###"ValidaÁ„o de Usu·rio"
 Else
  PswOrder(2)
  If PswSeek(cUsu, .T.)
   If PswName(cSenha)
    lRet := .T.
   Else
    HS_MsgInf(STR0153, STR0034, STR0154)//"Senha Inv·lida."###"AtenÁ„o"###"ValidaÁ„o de Senha"
    lRet := .F.
   EndIf
  Else
   HS_MsgInf(STR0151, STR0034, STR0152)//"Usu·rio n„o cadastrado"###"AtenÁ„o"###"ValidaÁ„o de Usu·rio"
   lRet := .F.
  EndIf
 EndIf
EndIf

Return(lRet)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_GrvCol ∫Autor  ≥Patricia Queiroz   ∫ Data ≥  27/03/07    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥FunÁ„o para gerar a Coleta.                                 ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_GrvCol(nOpcM24)

Local aArea := GetArea()

If aRotina[nOpcM24, 3] == 13 //Encaixe

 RecLock("GGO", .T.)
  GGO->GGO_CDCOLE := GetSxeNum("GGO", "GGO_CDCOLE",, 1)
  GGO->GGO_REGATE := M->GCY_REGATE
  GGO->GGO_DATATE := M->GCY_DATATE
  GGO->GGO_CDMODC := HS_IniPadr("GGE", 1, M->GCY_CDTIPD, "GGE_CDMODC",, .F.)
  GGO->GGO_SITCOL := "0"
  GGO->GGO_DATINI := dDataBase
  GGO->GGO_HORINI := Time()
  GGO->GGO_CDUSUA := cUserName
  GGO->GGO_CDCRMS := M->GCY_CODCRM
  GGO->GGO_LOCATE := M->GCY_LOCATE
  GGO->GGO_CVDOAD := "1"
  GGO->GGO_FILIAL := xFilial("GGO")
 MsUnlock()

 While __lSx8
  ConfirmSx8()
 EndDo

EndIf

RestArea(aArea)

Return(Nil)




/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_RetSet ∫Autor  ≥Mario Arizono       ∫ Data ≥  10/10/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥Retorna o setor correto para validacao do estoque.          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function HS_RetSet(cAliasMM, nSeqDes, nCodLoc, cLctoDes, nFor, aCDesp,lFound)
 Local aArea   := GetArea()
 Local cCodLoc := ""

 If ValType(lFound) == "U"
  DbSelectArea(cAliasMM)
  DbSetOrder(1)
  lFound := IIf(!Empty(aCDesp[nFor, nSeqDes]), DbSeek(xFilial(cAliasMM) + aCDesp[nFor, nSeqDes]), .F.)
 Endif

  If lFound
   cCodLoc := IIf(nCodLoc > 0 .And. !Empty(aCDesp[nFor, nCodLoc]), aCDesp[nFor, nCodLoc], &(cPrefiMM + "_CODLOC"))
  Else
   cCodLoc := IIf(nCodLoc > 0 .And. !Empty(aCDesp[nFor, nCodLoc]), aCDesp[nFor, nCodLoc], cLctoDes)
  EndIf

 RestArea(aArea)

Return(cCodLoc)



/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_VldInt ∫Autor  ≥Patricia Queiroz    ∫ Data ≥  13/11/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥Valida o periodo de doacao, para tipo de doacao especifico. ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_VldInt(cOk)

 Local lRet      := .T.
 Local cSql      := ""
 Local dDatPer   := ""
 Local nPerDoac  := ""
 Local cRegGer   := M->GCY_REGGER
 Local cTipD     := M->GCY_CDTIPD
 Local cAliasOld := Alias()
 Local nTipDo    := 0

 Default cOk := ""

 If M->GCY_NMBENE <> M->GCY_REGGER
  If Empty(M->GCY_AUTJUD)

   nTipDo := HS_IniPadr("GGE", 1, cTipD, "GGE_INTERV",, .F.)
   nTipDo := IIF(Empty(nTipDo), 0, nTipDo)

   dDatPer := dDataBase - 365

   cSql := "SELECT MAX(GCY.GCY_DATATE) QRY_DATATE, COUNT(*) QRY_TOTAL "
   cSql += " FROM " + RetSqlName("GCY") + " GCY "
   cSql += "WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
   cSql += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatPer) + "' AND '" + DTOS(dDataBase) + "' "
   cSql += " AND GCY.GCY_REGGER = '" + cRegGer + "' AND GCY.GCY_ATENDI = '3' "
   cSql += " AND GCY.GCY_CDTIPD = '" + cTipD + "' "

   cSQL := ChangeQuery(cSQL)
   TCQUERY cSQL NEW ALIAS "QRY"

   nPerDoac := dDataBase - STOD(QRY_DATATE)

   If nPerDoac < nTipDo
    HS_MsgInf(STR0201, STR0034, STR0157) //"O periÛdo para o tipo de doaÁ„o foi excedido."###"AtenÁ„o"###"ValidaÁ„o de DoaÁıes"
    lRet := IIF(!Empty(cOk), .F., .T.)
   EndIf
   DbCloseArea()
  EndIf
 EndIf

 DbSelectArea(cAliasOld)

Return(lRet)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HS_LibCol ∫Autor  ≥Patricia Queiroz    ∫ Data ≥  20/11/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥Libera a Coleta correspondente ao Atendimento.              ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function HS_LibCol()

 Local aArea := GetArea()
 Local aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local nOpca := 0
 Local oBrwGGO
 Local cCpoChave := "GGO_CDCOLE+GGO_REGATE"
 Local aItensMar := {}
 Local cFiltro := ""

 Private oDlg

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd(aObjects, {100, 100, .T., .T.})

 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)

 cFiltro := "@GGO_FILIAL = '" + xFilial("GGO") + "' AND GGO_SITCOL = '6' AND GGO_CVDOAD = '1' AND "
 cFiltro +=  "GGO_LOCATE = '" + cM24Par01 + "'"

 HS_AtvFilt("GGO", cFiltro,,, .T.)

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0215) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL //"Libera Coleta"

 	oBrwGGO := HS_MBrow(oDlg, "GGO", {aPObjs[1,1], aPObjs[1,2], aPObjs[1,4], aPObjs[1,3]-30},,,/*cCpoLeg*/, /*aResLeg*/, "GGO_MARKBR", /*aResMar*/, @aItensMar, cCpoChave, /*bViewReg*/, .T.)

 ACTIVATE MSDIALOG oDlg ON INIT {EnchoiceBar (oDlg, {|| oDlg:End() }, {|| oDlg:End() }) }

 HS_DtvFilt("GGO")

 If Len(aItensMar) > 0
  Processa({ ||HS_ProcLib(aItensMar), STR0216, STR0217 }) //"Liberando coletas..."###"Aguarde"
 EndIf

 MbrChgLoop(.F.)

 RestArea(aArea)

Return(.T.)

Function HS_ProcLib(aItens)

 Local nFor := 0

 ProcRegua(0)

 For nFor := 1 To Len(aItens)
  IncProc()

  DbSelectArea("GGO")
  DbSetOrder(1)//GGO_FILIAL+GGO_CDCOLE+GGO_REGATE
  If DbSeek(xFilial("GGO") + aItens[nFor][1])
   RecLock("GGO", .F.)
    GGO->GGO_SITCOL := "5"
    GGO->GGO_HORLIB := Time()
    GGO->GGO_DATLIB := dDataBase
   MsUnlock()
  EndIf

 Next nFor

Return(.T.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HS_CtrTer ∫Autor  ≥Sueli C. Santos     ∫ Data ≥  25/11/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function HS_CtrTer(cAliasM24, nRegM24, nOpcM24)
Local lAteSUS := (GetMV("MV_ATESUS", , "N") == "S")

DbSelectArea("GCZ")
DbSetOrder(2)
DbSeek(xFilial("GCZ") + GCY->GCY_REGATE) // GCZ_FILIAL+GCZ_REGATE

If !GCZ->(Eof())                        //MV_SUSPAC                       MV_SUSBPA
    If lAtesus .And. GCZ->GCZ_CODPLA $ __cCodPAC .OR. GCZ->GCZ_CODPLA == __cCodBPA
		Hs_CtrSes(cAliasM24, nRegM24, nOpcM24)
	Else
		Hs_CtrSesT(cAliasM24, nRegM24, nOpcM24)
	EndIf
Endif

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HS_TriM24 ∫Autor  ≥JosÈ Orfeu          ∫ Data ≥  25/11/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥PrÈ Triagem.                                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function HS_TriM24(cAliasM24, nRegM24, nOpcM24)

 Local aArea := GetArea()

 Private __cMa7Aces := "E" // ElaboraÁ„o
 Private nQtdAnm    := 0   // Quantidade de historico de anamnese
 Private nVisAnm    := 0   // 0=Visualiza anamnese de outro profissional
 Private cLocCon    := GCY->GCY_CODLOC
 Private aCodUsr    := HS_VldDAnm(.F.)//{.T., IIf(Empty(GCY->GCY_CRMANM), GCY->GCY_CODCRM, GCY->GCY_CRMANM)}

 If Len(aCodUsr) > 2
  If aCodUsr[3]
   __cMa7Aces := "C"
  EndIf
 EndIf
                                        //Indica se usu·rios sem vÌnculo funcional podem realizar a triagem nas rotinas de Atendimento
 If Empty(aCodUsr[2]) .And. GetNewPar("MV_HSTRIVI","1") == "1"
  aCodUsr[1] := .T.
  aCodUsr[2] := IIf(Empty(GCY->GCY_CRMANM), GCY->GCY_CODCRM, GCY->GCY_CRMANM)
  If Len(aCodUsr) > 2
   aCodUsr[3]:= .F.
  EndIf
 EndIf
                                      //lTriagem
  HS_MntMA7(cAliasM24,nRegM24,3,,,,,,,.T. ) // PrÈ-Triagem

 RestArea(aArea)
Return(Nil)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HS_VldOrc ∫Autor  ≥Daniel Peixoto      ∫ Data ≥  05/12/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Valida o codigo do orÁamento selecionado na pergunta HSM24A ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function HS_VldOrc()
Local lRet := .F.

 DBSelectArea("GO0")
 DbSetOrder(1) //NUMORC
 DbSeek(xFilial("GO0") + MV_PAR01)
 If !(lRet := GO0->GO0_STATUS == cGO0Status)
  HS_MsgInf(STR0189, STR0034, STR0190) //"OrÁamento j· confirmado ou rejeitado."###"AtenÁ„o"###"ValidaÁ„o do orÁamento"
 ElseIf !(lRet := GO0->GO0_ATENDI == cGO0Atendi)
  HS_MsgInf(STR0191, STR0034, STR0190) //"Tipo do OrÁamento diferente do tipo do atendimento."###"AtenÁ„o"###"ValidaÁ„o do orÁamento"
 EndIf

Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_CopyOrc∫Autor  ≥Daniel Peixoto      ∫ Data ≥  30/11/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Retorna para o atendimento todos os dados em comum com o    ∫±±
±±∫          ≥orÁamento selecionado                                       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_CopyOrc()
Local aAreaOld  := GetArea()
Local aArea     := {}
Local aVetAlias := {{"GO5", "GO5->GO5", "oGDMM", "nMM"}, {"GO6", "GO6->GO6", "oGDTD", "nTD"}, {"GO7", "GO7->GO7", "oGDPR", "nPR"}}
Local nCont     := 0, nCpo := 0, nRDes := 0, nLin := 0, nUDados := 0
Local cCposNao  := "DATDES/HORDES"
Local aROld     := {}
Local cCodBar   := "", cVPct := "", cOldReadV := ""
Local cGO0RegGer := ""

Private cAgdNomPac := Space(Len(GBH->GBH_NOME))
Private cAgdTelPac := Space(Len(GBH->GBH_TEL ))
Private cOrcSexo   := Space(Len(GBH->GBH_SEXO))
Private cOrcDtNasc := CTOD("  /  /  ")
Private cOrcCodPla := Space(Len(GCM->GCM_CODPLA))

 cGO0Status := "0"
 cGO0Atendi :=  cGcyAtendi
 If !EMPTY(M->GCY_REGGER)
  If MsgYesNo(STR0204, STR0034)//"Deseja filtrar pelo prontu·rio informado?"###"AtenÁ„o"
   cGO0RegGer :=  M->GCY_REGGER
  Else
   cGO0RegGer :=  SPACE(Len(GCY->GCY_REGGER))
  EndIf
 Else
  cGO0RegGer :=  SPACE(Len(GCY->GCY_REGGER))
 EndIf

 If !Pergunte("HSM24A", .T.)
  Return()
 EndIf

 cGO0NumOrc := MV_PAR01

 DBSelectArea("GO0")
 DbSetOrder(1) //NUMORC
 DbSeek(xFilial("GO0") + cGO0NumOrc)

 //Limpa os dados pra trazer os do OrÁamento
 M->GCY_CODCLI := SPACE(Len(GCY->GCY_CODCLI))
 M->GCY_DESCLI := SPACE(Len(GCW->GCW_DESCLI))
 M->GCY_ORIPAC := SPACE(Len(GCY->GCY_ORIPAC))
 M->GCY_DORIPA := SPACE(Len(GD0->GD0_DORIPA))
 oGDGCZ:aCols := {}
 oGDGCZ:AddLine(.F., .F.)
 oGDGCZ:lNewLine := .F.

 If cGcyAtendi == "0" //Intern.
  M->GCY_CARATE := SPACE(Len(GCY->GCY_CARATE))
  M->GCY_DCARAT := SPACE(Len(GD1->GD1_DCARAT))
 ElseIf cGcyAtendi $ "1/2/4" //Amb. ou PA  ou Clinicas
  For nCont := 1 To 3
   &(aVetAlias[nCont, 3]):aCols := {}
   &(aVetAlias[nCont, 3]):AddLine(.F., .F.)
   &(aVetAlias[nCont, 3]):lNewLine := .F.
  Next
 EndIf

 //Preenche dados da Enchoice
 DbSelectArea("SX3")
 DBSetOrder(1)
 DbSeek("GO0")
 While !Eof() .And. (SX3->X3_ARQUIVO == "GO0")
  If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
   If SX3->X3_CAMPO = "GO0_REGGER"
    If EMPTY(GO0->GO0_REGGER)
     cAgdNomPac := GO0->GO0_NOMPAC
     cAgdTelPac := GO0->GO0_FONE
     cOrcSexo   := GO0->GO0_SEXO
     cOrcDtNasc := GO0->GO0_DTNASC
     cOrcCodPla := GO0->GO0_CODPLA

     aArea := GetArea()
     If HS_EditPac(3)
      M->GCY_REGGER := GBH->GBH_CODPAC
     Else
      Return()
     EndIf
     RestArea(aArea)
    Else
     M->GCY_REGGER := GO0->GO0_REGGER
    EndIf

   ElseIf SX3->X3_CAMPO = "GO0_NOMPAC"
    M->GCY_NOME := GO0->GO0_NOMPAC

   ElseIf SX3->X3_CAMPO = "GO0_CODCRM"
    cOldReadV := __ReadVar
    __ReadVar := "M->GCY_CODCRM"
    M->GCY_CODCRM := GO0->GO0_CODCRM
    HS_VldM24(,5)
    __ReadVar := cOldReadV

   ElseIf SX3->X3_CAMPO = "GO0_NOMMED"
    M->GCY_NOMMED := HS_IniPadR("SRA", 11, GO0->GO0_CODCRM, "RA_NOME",, .F.)

   ElseIf SX3->X3_CAMPO = "GO0_CODLOC"
    M->GCY_CODLOC := GO0->GO0_CODLOC
    cGcsCodLoc := GO0->GO0_CODLOC
    cGcsArmSet := HS_IniPadR("GCS", 1, cGcsCodLoc, "GCS_ARMSET",, .F.)

   ElseIf SX3->X3_CAMPO = "GO0_NOMLOC"
    M->GCY_NOMLOC := HS_IniPadR("GCS", 1, GO0->GO0_CODLOC, "GCS_NOMLOC",, .F.)

   ElseIf SX3->X3_CAMPO = "GO0_CODPLA"
    oGDGcz:aCols[oGDGcz:nAt, nGCZCODPLA] := GO0->GO0_CODPLA
    cGczCodPla := GO0->GO0_CODPLA

   ElseIf SX3->X3_CAMPO = "GO0_DESPLA"
    oGDGcz:aCols[oGDGcz:nAt, nGCZDESPLA] := HS_IniPadR("GCM", 2, GO0->GO0_CODPLA, "GCM_DESPLA",, .F.)

   ElseIf SX3->X3_CONTEXTO <> "V"
    &("M->GCY_" + SUBSTR(SX3->X3_CAMPO, 5)) := &("GO0->" + SX3->X3_CAMPO)
   EndIf
  EndIf

  DbSelectArea("SX3")
  DbSkip()
 EndDo
 oEncGcy:Refresh()

 //Preenche Despesas qdo Atendimento Ambulatorial
 If cGcyAtendi $ "1/2/4"
  For nCont := 1 To 3
  	DbSelectArea(aVetAlias[nCont, 1])
   DBSetOrder(1)//NUMORC
   If DbSeek(xFilial(aVetAlias[nCont, 1]) + cGO0NumOrc)
    While !EOF() .And. &(aVetAlias[nCont,2] + "_FILIAL") == xFilial(aVetAlias[nCont, 1]) .And. &(aVetAlias[nCont,2] + "_NUMORC") == cGO0NumOrc
     If !Empty(&(aVetAlias[nCont, 3]):aCols[Len(&(aVetAlias[nCont, 3]):aCols), &(aVetAlias[nCont, 4] + "CODDES")])
      &(aVetAlias[nCont, 3]):AddLine(.F., .F.)
      &(aVetAlias[nCont, 3]):lNewLine := .F.
     EndIf
     nLin := Len(&(aVetAlias[nCont, 3]):aCols)
     If aVetAlias[nCont, 1] == "GO5"      //Valida MatMed
      aROld := aClone(__aRMatMed)
      For nRDes := 1 To Len(__aRMatMed)
       __aRMatMed[nRDes, 1] := StrTran(__aRMatMed[nRDes, 1], "oGDMM:nAt", AllTrim(Str(nLin)))
      Next
      __cRCodDes := StrTran(__cRCodDes, "oGDMM:nAt", AllTrim(Str(nLin)))
      cCodbar := HS_IniPadr("SB1", 1, GO5->GO5_CODDES, "B1_CODBAR",,.F.)
      &(aVetAlias[nCont, 3]):aCols[nLin, &(aVetAlias[nCont, 4] + "CODBAR")] := cCodBar
      &(aVetAlias[nCont, 3]):aCols[nLin, &(aVetAlias[nCont, 4] + "QTDDES")] := GO5->GO5_QTDDES
	  IIf(Type("__MMQtdDe") <> "U",__MMQtdDe := GO5->GO5_QTDDES,Nil)
      HS_VCodBar(cCodBar, "GD5_CODDES",, .F., HS_M24LOCK("GD5"), .F.) //Chama VCodBar sem validar Kit, pois ja foi lanÁado no orÁamento
      __cRCodDes := StrTran(__cRCodDes, AllTrim(Str(nLin)), "oGDMM:nAt")
      __aRMatMed := aClone(aROld)

     ElseIf aVetAlias[nCont, 1] == "GO6" //Valida TaxDia
      aROld := aClone(__aRTaxDia)
      For nRDes := 1 To Len(__aRTaxDia)
       __aRTaxDia[nRDes, 1] := StrTran(__aRTaxDia[nRDes, 1], "oGDTD:nAt", AllTrim(Str(nLin)))
      Next
      &(aVetAlias[nCont, 3]):aCols[nLin, &(aVetAlias[nCont, 4] + "CODDES")] := GO6->GO6_CODDES
      &(aVetAlias[nCont, 3]):aCols[nLin, &(aVetAlias[nCont, 4] + "QTDDES")] := GO6->GO6_QTDDES
      HS_VTaxDia(cGczCodPla, cGcsCodLoc, GO6->GO6_CODDES)
      __aRTaxDia := aClone(aROld)

     ElseIf aVetAlias[nCont, 1] == "GO7" //Valida Proced
      aROld := aClone(__aRProced)
      For nRDes := 1 To Len(__aRProced)
       __aRProced[nRDes, 1] := StrTran(__aRProced[nRDes, 1], "oGDPR:nAt", AllTrim(Str(nLin)))
      Next
      cVPct := __cFVPrPct
      __cFVPrPct := NIL //nao valida Proced. Pad pois ja foi lancado no orÁamento
      &(aVetAlias[nCont, 3]):aCols[nLin, &(aVetAlias[nCont, 4] + "CODDES")] := GO7->GO7_CODDES
      &(aVetAlias[nCont, 3]):aCols[nLin, &(aVetAlias[nCont, 4] + "QTDDES")] := GO7->GO7_QTDDES
      HS_VProHon(cGczCodPla, cGcsCodLoc, GO7->GO7_CODDES,,,,,,, 	{GO0->GO0_ATENDI, GO0->GO0_ATENDI, GO0->GO0_IDADE, GO0->GO0_SEXO},, oGDPR:aCols[nLin, nPRDATDES])
      __aRProced := aClone(aROld)
      __cFVPrPct := cVPct
     EndIf

     DbSelectArea(aVetAlias[nCont, 1])
     DBSkip()
    EndDo
   EndIf
   &(aVetAlias[nCont, 3]):oBrowse:Refresh()
  Next
 EndIf

 lOrc := .T.

 RestArea(aAreaOld)
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HS_DATPAT ∫Autor  ≥Mario Arizono       ∫ Data ≥  10/10/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥Retorna a Data e hora do atendimento para despesa do proce- ∫±±
±±∫          ≥dimento quando atendimento for do tipo PA.                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function HS_DATPAT(lData)
 Local aArea   := GetArea()
 Local dDatDes := CTOD("  /  /  ")
 Local cHorDes := ""

  If Type("cGcyAtendi") # "U" .And. Type("M->GCY_DATATE") # "U"
   If cGcyAtendi == "2"
    If lData
     dDatDes := M->GCY_DATATE
    Else
     cHorDes := M->GCY_HORATE
    Endif
   Else
    If lData
     dDatDes := dDataBase
    Else
     cHordes := Time()
    Endif
   Endif
  Else
   If lData
    dDatDes := dDataBase
   Else
    cHordes := Time()
   Endif
  Endif

 RestArea(aArea)
Return(IIF(lData, dDatDes, cHorDes))

Static Function FS_SolAtd(nPos)
 Local aAreaOld := GetArea()
 Local lRet     := .F.

 DbSelectArea("GD5")
 DbSetOrder(1)
 If DbSeek(xFilial("GD5") + oGDMM:aCols[nPos, nMMSeqDes]) .And. !EMPTY(GD5->GD5_SOLICI)
  DbSelectArea("GAI")
  DBSetOrder(1)
  If DBSeek(xFilial("GAI") + GD5->GD5_SOLICI) .And. GAI->GAI_FLGATE > "0" //atendida
   lRet := .T.
  EndIf
 EndIf

 RestArea(aAreaOld)
Return(lRet)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_LimpFil ∫Autor  ≥Patricia Queiroz   ∫ Data ≥  23/03/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥FunÁ„o utilizada para limpar as vari·veis d filtro da rotina∫±±
∫±±           de pesquisa HS_CONPAC.                                      ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_LimpFil(cSexo, cDtNasc, cRG, cOrgEmi, cUFEmis,cGbhDtNasc,cGbhSexo,cGbhRg, cGbhRgOrg, cGbhUFEmis,cSexoAu, cDtNascAu, cRGAu , cOrgEmiAu , cUFEmisAu )

 Local aArea   := GetArea()

 If !Empty(cRG)
  cSexoAu   := cGbhSexo
  cDtNascAu := cGbhDtNasc
  cRGAu     := cGbhRg
  cOrgEmiAu := cGbhRgOrg
  cUFEmisAu := cGbhUFEmis

  cGbhSexo   := ""
  cGbhDtNasc := ""
  cGbhRg     := ""
  cGbhRgOrg  := ""
  cGbhUFEmis := ""
 Else
  cGbhSexo   := cSexoAu
  cGbhDtNasc := cDtNascAu
  cGbhRg     := cRGAu
  cGbhRgOrg  := cOrgEmiAu
  cGbhUFEmis := cUFEmisAu
 EndIf

 RestArea(aArea)

Return(.T.)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_VldInap ∫Autor  ≥Patricia Queiroz   ∫ Data ≥  26/03/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥FunÁ„o utilizada para validar a doaÁ„o verificando a inapti_∫±±
∫±±           d„o.                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_VldInap(cRegGer, cOk)

 Local lRet     := .T.
 Local aArea    := GetArea()
 Local cSql     := ""
 Local dUltData := dDatabase - 365
 Local cCdInap  := ""
 Local nQtdDia  := 0

 Default cOk    := ""


 If M->GCY_NMBENE <> M->GCY_REGGER
  If Empty(M->GCY_AUTJUD)
   If !Empty(cCdInap := HS_IniPadr("GBH", 1, cRegGer, "GBH_CDINAP",, .F.))
    If !(lRet := !(HS_IniPadr("GGN", 1, cCdInap, "GGN_TPINAP",, .F.) == "0"))
     HS_MsgInf("Este atendimento n„o pode ser finalizado, pois o doador n„o est· apto.", "AtenÁ„o", "ValidaÁ„o do Atendimento")
    Else
     nQtdDia := HS_IniPadr("GGN", 1, cCdInap, "GGN_QTDDIA",, .F.)
     If nQtdDia == 0
      If MsgYesNo("O doador est· inapto, pois o campo que determina a quantidade de dias de bloqueio para inaptid„o tempor·ria est· vazio. Deseja continuar?", "AtenÁ„o")
       lRet := IIF(!Empty(cOk), .F., .T.)
      EndIf
     EndIf
    EndIf

    If lRet
     cSql := "SELECT MAX(GCY.GCY_DATATE) QRY_DATATE, COUNT(*) QRY_TOTAL "
     cSql += " FROM " + RetSqlName("GCY") + " GCY "
     cSql += "WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
     cSql += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dUltData) + "' AND '" + DTOS(dDataBase) + "' "
     cSql += " AND GCY.GCY_REGGER = '" + cRegGer + "' AND GCY.GCY_ATENDI = '3' "

     cSQL := ChangeQuery(cSQL)
     TCQUERY cSQL NEW ALIAS "QRY"

     DbSelectArea("QRY")

     If !Empty(QRY_DATATE)
      If (nQtdDia + STOD(QRY_DATATE)) > dDataBase
       HS_MsgInf("O doador n„o est· apto para efetuar a doaÁ„o.", "AtenÁ„o", "ValidaÁ„o de Atendimento")
       lRet := IIF(!Empty(cOk), .F., .T.)
      EndIf
     EndIf
    EndIf
    DbCloseArea()
   EndIf
  EndIf
 EndIf

 RestArea(aArea)

Return(lRet)




/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_DadComp ∫Autor  ≥Patricia Queiroz   ∫ Data ≥  27/03/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥FunÁ„o para montar a tela e apresentar o histÛrico de ende_ ∫±±
∫±±           reÁo do doador.                                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_DadComp(nOpcM24)

 Local aArea := GetArea()
 Local aHGHL := {}, aCGHL := {}
 Local oGHL
 Local cRG   := M->GCY_RG
 Local cOrgEmi := M->GCY_ORGEMI
 Local cUFEmis := M->GCY_UFEMIS


 If !Empty(cRG)

  cSql := "SELECT COUNT(*) NTOTAL "
  cSql += "FROM " + RetSqlName("GHL") + " GHL "
  cSql += "WHERE GHL.GHL_FILIAL = '" + xFilial("GHL")  + "' AND GHL.D_E_L_E_T_ <> '*' "
  cSql += "AND GHL.GHL_RG = '" + cRG + "' "
  cSql += "AND GHL.GHL_ORGEMI = '" + cOrgEmi + "' "
  cSql += "AND GHL.GHL_UFEmis = '" + cUFEmis + "' "

  cSQL := ChangeQuery(cSQL)
  TCQUERY cSQL NEW ALIAS "QRY"

  DbSelectArea("QRY")

  If QRY->NTOTAL <> 0

   HS_BDados("GHL", @aHGHL, @aCGHL,, 2,, "GHL->GHL_RG == '" + cRG + "' AND " + "GHL->GHL_ORGEMI == '" + cOrgEmi+ "' AND " + "GHL->GHL_UFEMIS == '" + cUFEmis + "' ")

   aSize    := MsAdvSize(.T.)
   aObjects := {}
   AAdd(aObjects, {100, 100, .T., .T.})

   aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
   aPObjs := MsObjSize(aInfo, aObjects, .T.)

   DEFINE MSDIALOG oDlg TITLE OemToAnsi("Dados Complementares") From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd

    oGHL := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4],,,,,,,,,,,, aHGHL, aCGHL)
    oGHL:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, oDlg:End()}, ;
                                                    {|| nOpcA := 0, oDlg:End()})
   DbCloseArea()

  Else
   HS_MsgInf(STR0218, STR0034, STR0219) //"N„o h· histÛrico para este doador."###"AtenÁ„o"###"ValidaÁ„o de Dados Complementares"
  EndIf
  DbCloseArea()
 Else
  HS_MsgInf(STR0220, STR0034, STR0219) //"Por favor preencha o RG do doador."###"AtenÁ„o"###"ValidaÁ„o de Dados Complementares"
 EndIf

 RestArea(aArea)

Return(Nil)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_GrvDado ∫Autor  ≥Patricia Queiroz   ∫ Data ≥  27/03/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥FunÁ„o para gravar os dados para historico do doador.       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_GrvDado(cRegGer, nOpcM24)

 Local aArea := GetArea()

 If aRotina[nOpcM24, 3] == 13 //Encaixe

  DbSelectArea("GBH")
  DbSetOrder(1) //GBH_FILIAL + GBH_CODPAC
  DbSeek(xFilial("GBH") + cRegGer)

  RecLock("GHL", .T.)
   GHL->GHL_REGATE := M->GCY_REGATE
   GHL->GHL_RG     := M->GCY_RG
   GHL->GHL_ORGEMI := M->GCY_ORGEMI
   GHL->GHL_UFEMIS := M->GCY_UFEMIS
   GHL->GHL_ENDATE := GBH->GBH_END
   GHL->GHL_ESTCIV := GBH->GBH_ESTCIV
   GHL->GHL_PROFIS := GBH->GBH_PROFIS
   GHL->GHL_FILIAL := xFilial("GHL")
  MsUnLock()

 EndIf

 RestArea(aArea)

Return(Nil)

Static Function FS_VldTISS(nAt,nGczTATISS,nGczTIPCON,nGczDtGuia,nGCZValSen)
 Local lRet := .T.
 Local aAreaOld := GetArea()
 Default nAt    := oGDGcz:nAt

 DbSelectArea("GCU")
 DbSetOrder(1)
 DBSeek(xFilial("GCU") + oGDGcz:aCols[nAt, nGczCODTPG])
 If !EMPTY(GCU->GCU_TGTISS)
  If GCU->GCU_TGTISS == "05" .And. EMPTY(oGDGcz:aCols[nAt, nGczCodDes])
   HS_MsgInf(STR0221, STR0034, STR0222)//"Para esse Tipo de Guia o campo ServiÁo/Princ. deve ser preenchido."###"AtenÁ„o"###"ValidaÁ„o do Tipo Guia TISS"
   lRet := .F.
  ElseIf GCU->GCU_TGTISS == "02" .And. EMPTY(oGDGcz:aCols[nAt, nGczTATISS])
   HS_MsgInf(STR0223, STR0034, STR0224)//"Para esse Tipo de Guia o campo Tipo Atendimento deve ser preenchido."###"AtenÁ„o"###"ValidaÁ„o do Tipo Atendimento"
   lRet := .F.
  ElseIf GCU->GCU_TGTISS == "01" .And. EMPTY(oGDGcz:aCols[nAt, nGczTIPCON])
   HS_MsgInf(STR0225, STR0034, STR0226)//"Para esse Tipo de Guia o campo Tipo Consulta deve ser preenchido."###"AtenÁ„o"###"ValidaÁ„o do Tipo Consulta"
   lRet := .F.
  EndIf
 Else
  HS_MsgInf(STR0255, STR0034, STR0235) //"Por favor, preencha o Tipo de Guia do TISS."###"AtenÁ„o"###"ValidaÁ„o da Guia"
  lRet := .F.
 EndIf

 If !EMPTY(oGDGcz:aCols[nAt, nGczDtGuia]) .And. lRet
  If !Empty(M->GCY_DATALT).And.(oGDGcz:aCols[nAt, nGczDtGuia] > M->GCY_DATALT)
   HS_MsgInf(STR0271, STR0034, STR0270)//"A data de emiss„o da guia n„o pode ser superior a data da alta."###"AtenÁ„o###"ValidaÁ„o data emiss„o da guia"
   lRet := .F.
  ElseIf (dDataBase < M->GCY_DATATE .And. oGDGcz:aCols[nAt, nGczDtGuia] > M->GCY_DATATE)
   HS_MsgInf(STR0272, STR0034, STR0270)//"Data de emiss„o da guia inv·lida."###"AtenÁ„o###ValidaÁ„o Data Emiss„o da Guia"
   lRet := .F.
  ElseIf (oGDGcz:aCols[nAt, nGczDtGuia] < M->GCY_DATATE)
   HS_MsgInf(STR0273,STR0034, STR0270)//"Guia emitida anterior ao atendimento"###"AtenÁ„o###ValidaÁ„o Data Emiss„o da Guia"
  EndIf
 ElseIf lRet
  HS_MsgInf(STR0274,STR0034, STR0270)//"Por favor, preencha a data de emiss„o da guia."###"AtenÁ„o###ValidaÁ„o Data Emiss„o da Guia"
  lRet := .F.
 EndIf

 If !EMPTY(oGDGcz:aCols[nAt, nGCZValSen]).And. lRet
  If (oGDGcz:aCols[nAt, nGCZValSen] < M->GCY_DATATE)
   HS_MsgInf(STR0276, STR0034, STR0275)//"Data validade da senha n„o pode ser anterior a data do atendimento"###"AtenÁ„o"###"ValidaÁ„o da data de validade da senha"
   lRet := .F.
  EndIf
 ElseIf lRet
  HS_MsgInf(STR0278,STR0034, STR0275)//"Por favor, preencha a data de validade da senha."###"AtenÁ„o"###"ValidaÁ„o da data de validade da senha"
  lRet := .F.
 EndIf

 RestArea(aAreaOld)

Return(lRet)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_VldGuia∫Autor  ≥Patricia Queiroz    ∫ Data ≥  29/05/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥FunÁ„o para validar a exclus„o da guia.                     ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_VldGuia(nGe3CodDes,nGe3CodPrt)

 Local aArea := GetArea()
 Local nReg  := 0
 Local lAtivo := .F.
 Local nV

 If Type("oGDPR") <> "U"
  If aScan(oGDPR:aCols, {| aVet | !Empty(aVet[nPRCODDES])}) > 0
   HS_MsgInf(STR0234, STR0034, STR0235) //"N„o È possÌvel excluir a guia, pois possui procedimento(s) lanÁado(s)."###"AtenÁ„o"###"ValidaÁ„o da Guia"
   Return(.F.)
  ElseIf aScan(oGDMM:aCols, {| aVet | !Empty(aVet[nMMCODDES])}) > 0
   HS_MsgInf(STR0236, STR0034, STR0235) //"N„o È possÌvel excluir a guia, pois possui material(s) e medicamento(s) lanÁado(s). Efetue a devoluÁ„o do(s) material(s) e medicamento(s) lanÁado(s)."###"AtenÁ„o"###"ValidaÁ„o da Guia"
   Return(.F.)
  ElseIf aScan(oGDTD:aCols, {| aVet | !Empty(aVet[nTDCODDES])}) > 0
   HS_MsgInf(STR0237, STR0034, STR0235) //"N„o È possÌvel excluir a guia, pois possui taxa(s) e di·ria(s) lanÁada(s)."###"AtenÁ„o"###"ValidaÁ„o da Guia"
   Return(.F.)
  EndIf

  DbSelectArea("GAI")
  DbSetOrder(2)  //GAI_FILIAL + GAI_REGATE + GAI_DATSOL
  DbSeek(xFilial("GAI") + GCY->GCY_REGATE)// .And. GAI->GAI_FLGATE <> "2"
  While !Eof() .And. GAI->GAI_REGATE == GCY->GCY_REGATE
   If GAI->GAI_FLGATE $ "0/1"
    nReg++
   EndIf
   DbSkip()
  End
  If nReg > 0
   HS_MsgInf(STR0292, STR0034, STR0235) //"N„o È possÌvel excluir a guia, pois h· material(s) e medicamento(s) com solicitaÁ„o em aberto."###"AtenÁ„o"###"ValidaÁ„o da Guia"
   Return(.F.)
  EndIf

  DbSelectArea("GBD")
  DbSetOrder(2) //GBD_FILIAL + GBD_REGATE
  DbSeek(xFilial("GBD" + GCY->GCY_REGATE)) //.And. GBD->GBD_FLGDEV <> "2"
  While !Eof() .And. GBD->GBD_REGATE == GCY->GCY_REGATE
   If GBD->GBD_FLGDEV <> "2"
    nReg++
   EndIf
   DbSkip()
  End
  If nReg > 0
   HS_MsgInf(STR0243, STR0034, STR0235) //"N„o È possÌvel excluir a guia, pois h· material(s) e medicamento(s) com solicitaÁ„o de devoluÁ„o em aberto."###"AtenÁ„o"###"ValidaÁ„o da Guia"
   Return(.F.)
  EndIf
 EndIf

 If Type("oGDGE2") <> "U"
  If aScan(oGDGE2:aCols, {| aVet | !Empty(aVet[nGE2CODDES]) .AND. aVet[nGE2STAREG] <> "BR_VERDE" }) > 0
   HS_MsgInf(STR0238, STR0034, STR0235) //"N„o È possÌvel excluir a guia, pois possui autorizaÁ„o de guia - mat/med lanÁada."###"AtenÁ„o"###"ValidaÁ„o da Guia"
   Return(.F.)
  ElseIf aScan(oGDGE3:aCols, {| aVet | !Empty(aVet[nGE3CODDES]) .AND. aVet[nGE3STAREG] <> "BR_VERDE" }) > 0
   HS_MsgInf(STR0239, STR0034, STR0235) //"N„o È possÌvel excluir a guia, pois possui autorizaÁ„o de guia - Proced lanÁada."###"AtenÁ„o"###"ValidaÁ„o da Guia"
   Return(.F.)
  ElseIf aScan(oGDGE8:aCols, {| aVet | !Empty(aVet[nGE8CODCRM])}) > 0
   HS_MsgInf(STR0240, STR0034, STR0235) //"N„o È possÌvel excluir a guia, pois possui prorrogaÁ„o de guia lanÁada."###"AtenÁ„o"###"ValidaÁ„o da Guia"
   Return(.F.)
  EndIf
 EndIf

 If Type("oGDGcz") <> "U"

	For nV := 1 To Len(oGDGcz:ACOLS)

		If oGDGcz:nAt <> nV .And. oGDGcz:ACOLS[nV][Len(oGDGcz:ACOLS[nV])] == .F.

			lAtivo := .T.  //Ha pelo menos um registro sem deletar no aCols

		EndIf

	Next nV

	If ! lAtivo
	   HS_MsgInf(STR0316, STR0034, STR0235) //"N„o È permitido ficar sem guias. … necess·rio criar outra guia antes."###"AtenÁ„o"###"ValidaÁ„o da Guia"
	   Return(.F.)
	EndIf

 EndIf

 RestArea(aArea)

Return(.T.)



/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_MatMed ∫Autor  ≥Patricia Queiroz    ∫ Data ≥  22/06/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥FunÁ„o para validar a exclus„o de Mat/Med.                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_MatMed(oGDMM)

 Local aArea   := GetArea()
 Local lRet    := .T.
 Local cMovest := UPPER(GetMv("MV_AUDMEST"))
 Local lMovEst := .F.
 Local lFound  := .F.
 Local lDelOld := oGDMM:lDelete

 If !Empty(oGDMM:aCols[oGDMM:nAt, nMMCODDES])

  //Verifica se È um lancamento novo
  (cAliasMM)->(DbSetOrder(1))
  If (lFound  := ((cAliasMM)->(DbSeek(xFilial(cAliasMM) + oGDMM:aCols[oGDMM:nAt, nMMSEQDES]))))

   If !Empty(&( cPrefiMM + "_NUMSEQ")) .Or.;
      HS_CONEST(oGDMM:aCols[oGDMM:nAt, nMMCODDES], HS_RetSet(cAliasMM, nMMSeqDes, nMMCodLoc, cLctCodLoc, oGDMM:nAt, oGDMM:aCols, lFound))[1] .And. ;
      IIf(FunName() == "HSPAHP12", cMovest == "S", .T.) // Validacao da movimentacao do estoque para auditoria
    lMovEst := .T.
   EndIf

   If lMovEst
    If !oGDMM:aCols[oGDMM:nAt, Len(oGDMM:aHeader) + 1]
     lRet := .F.
     HS_MsgInf(STR0244, STR0034, STR0245)//"N„o È possÌvel excluir este material/medicamento, pois movimenta estoque. Efetue a devoluÁ„o deste material/medicamento."###"AtenÁ„o"###"ValidaÁ„o de Material/Medicamento"
    EndIf
   Else
    lRet := .T.
   EndIf
  EndIf

  If lRet
   If oGDMM:aCols[oGDMM:nAt, Len(oGDMM:aHeader) + 1]
    oGDMM:aCols[oGDMM:nAt, nMMQDevol] := 0
   EndIf
   oGDMM:lDelete := .T.

   HS_GDAtrib(oGDMM, {{nMMStaReg, "BR_CINZA", "BR_VERDE"}})

   oGDMM:DelLine()
   oGDMM:lDelete := lDelOld
  EndIf

 EndIf

 RestArea(aArea)

Return(lRet)

Static Function FS_GczGFoc()
 cGbjCodEsp := Space(Len(GBJ->GBJ_ESPEC1))
 cGbjTipPro := "0127"
 cObsCodCrm := oGDGcz:aCols[oGDGcz:nAt, nGCZCodCrm]
 If ValType("M->GCY_LOCATE") # "U"
  cGcsCodLoc := M->GCY_LOCATE
 EndIf
 oObjFocus  := oGDGcz
Return(.T.)

Static Function FS_GczLFoc()
 cGbjTipPro := SPACE(LEN(GBJ->GBJ_TIPPRO))
 If ValType("M->GCY_CODLOC") # "U"
  cGcsCodLoc := M->GCY_CODLOC
 EndIf
Return(Nil)

Static Function FS_MLegMB(aResLeg)
 Local aLegGav := {}, nLeg := 1

 For nLeg := 1 To Len(aResLeg)
  aAdd(aLegGav, {aResLeg[nLeg][2], aResLeg[nLeg][3]})
 Next

 BrwLegenda("Mapa de leitos", STR0211, aLegGav) //"Legenda"
Return(Nil)





/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_ClTxSrv∫Autor  ≥Patricia Queiroz    ∫ Data ≥  27/10/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥FunÁ„o para calcular o valor da taxa de servico sobre as des∫±±
±±∫           pesas de matrial e taxa/diaria.                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_ClTxSrv(cAlias, cRegAte)

 Local aArea  := GetArea()
 Local cSql   := ""

 cSql := "SELECT GCZ.GCZ_NRSEQG NRSEQG "
 cSql += "FROM " + RetSqlName("GCZ") + " GCZ "
 cSql += "WHERE GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_REGATE = '" + cRegAte + "' "

 cSql := ChangeQuery(cSql)
 TCQUERY cSql NEW ALIAS "QRYGCZ"

 DbSelectArea("QRYGCZ")
 DbGoTop()

 While !Eof() // funcao para calculo da taxa/servico
  HS_VlTxSer(cAlias, QRYGCZ->NRSEQG)
  DbSkip()
 End

 DbSelectArea("QRYGCZ")
 DbCloseArea()

 RestArea(aArea)

Return(Nil)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_AddLin ∫Autor  ≥Mario Arizono       ∫ Data ≥  11/11/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥FunÁ„o para replicar data, hora e setor da linha anterior   ∫±±
±±∫           para nova linha adicionada.                                 ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function FS_AddLin(oGet, nCodLoc, nNomLoc, nDatDes, nHordes)
 oGet:AddLine(.T., .F.)
 If len(oGet:aCols) > 0
  If nCodLoc > 0
   oGet:aCols[oGet:nAt, nCodLoc] := oGet:aCols[oGet:nAt - 1, nCodLoc]
  Endif
  If nNomLoc > 0
   oGet:aCols[oGet:nAt, nNomLoc] := oGet:aCols[oGet:nAt - 1, nNomLoc]
  Endif

  If nDatDes > 0
   oGet:aCols[oGet:nAt, nDatDes] := oGet:aCols[oGet:nAt - 1, nDatDes]
  Endif

  If nHordes > 0
   oGet:aCols[oGet:nAt, nHordes] := oGet:aCols[oGet:nAt - 1, nHordes]
  Endif

 Endif

Return(.T.)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_MostObs∫Autor  ≥Mario Arizono       ∫ Data ≥  13/11/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥FunÁ„o para mostrar observacoes referentes ao mÈdico, proce-∫±±
±±∫           dimento e plano, dependendo de onde estiver o foco.         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function FS_MostObs(cCpoFil, cTabFil, cMsg, nOpcM24, lVldPla)
 Local aArea   := GetArea()
 Local cCpoObs := ""

 Default lVldPla := .F.

 If lVldPla
  cCpoFil := HS_IniPadr("GCM", 2, cCpoFil, "GCM_CODCON",, .F.)
 Endif

 If !Empty(cCpoFil)
  cCpoObs := HS_IniPadr(cTabFil, 1, cCpoFil, cTabFil + "_OBSERV",, .F.)
  If !Empty(cCpoObs)
  	HS_MsgInf(cCpoObs, STR0034, "ObservaÁ„o referente ao" + cMsg + "informado.")//atencao
  Else
   HS_MsgInf("Nenhuma observaÁ„o foi encontrada para o " + cMsg + "informado.", STR0034, "ValidaÁ„o ObservaÁ„o" )
  Endif
 Else
  HS_MsgInf("Nenhum " + cMsg + "foi encontrado para visualizaÁ„o de sua respectiva observaÁ„o.", STR0034, "ValidaÁ„o ObservaÁ„o" )//atencao
 Endif

 If Type("oObjFocus:oBrowse") <> "U"
  oObjFocus:OBrowse:SetFocus()
 Endif

 RestArea(aArea)
Return(Nil)

Static Function FS_GrFGcy()
 cObsCodCrm := M->GCY_CODCRM
 oObjFocus  := oEncGcy
Return(.T.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FS_IncMedS∫Autor  ≥Mario Arizono       ∫ Data ≥  26/08/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥FunÁ„o para incluir mÈdico solicitante nos atendimentos     ∫±±
±±∫           ambulatoriais, caso o medico da guia nao esteja preenchido. ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function FS_IncMedS()
 Local aArea   := GetArea(), aGets := {}, aTela := {}
 Local lRet    := .T.
 Local oCodCrm, oDesCrm, oEspeci, oDesEsp, oDlg
 Local cCodCrm  := Criavar("RA_CODIGO")
 Local cDesCrm  := CriaVar("RA_NOME")
 Local cEspeci  := CriaVar("GBJ_ESPEC1")
 Local cDesEsp  := Criavar("GFR_DSESPE")
 Local nOpcA    := 0, nPos := 0
 Local cPreSoli := GetMV("MV_CPSOLIC",,"")
 Local cMatSra	:=	""
 Local lReturn := .F.

	If Ascan(oGDGcz:aCols,{ | aVet | Empty(aVet[nGczCodCrm])}) > 0

  aSize := MsAdvSize(.T.)
	 aObjects := {}
	 AAdd( aObjects, { 100, 100, .T., .T.,.T. } )
	 aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	 aPObj := MsObjSize( aInfo, aObjects, .T. )


  DEFINE MSDIALOG oDlg TITLE "MÈdico Solicitante" From 09, 00 to 20, 90 of oMainWnd

   oPanMed	:=	tPanel():New(aPObj[1, 1], aPObj[1, 2],,,,,,,, aPObj[1, 3], aPObj[1, 4])

   @ 015, 010 Say "CÛdigo CRM" Size 030, 009 Of oPanMed Pixel COLOR CLR_BLUE
 	 @ 023, 045 MsGet oCodCrm VAR cCodCrm Picture "@!" Valid ExistChav("SRA",cCodCrm,11) Size 030, 009 OF oCodCrm Pixel
 	 @ 023, 090 MsGet oDesCrm VAR cDesCrm Picture "@!" Valid Texto(cDesCrm) .And. FHIST(cDesCrm) Size 200, 009 OF oDesCrm Pixel
   @ 042, 005 Say "Especialidade" Size 035, 009 Of oPanMed Pixel COLOR CLR_BLUE
 	 @ 050, 045 MsGet oEspeci VAR cEspeci PICTURE "@!" Valid FS_VEspMed(cEspeci, @cDesEsp) F3 "GFR001" Size 020, 009 OF oEspeci Pixel
 	 @ 050, 090 MsGet oDesEsp VAR cDesEsp PICTURE "@!" When .F. Size 200, 009 OF oDesEsp Pixel

	 ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, 	{||nOpcA := 1, IIF(FS_VLDCPO(cCodCrm, cDesCrm, cEspeci), oDlg:End(), nOpcA == 0) }, ;
																																																																		{|| nOpcA := 0, oDlg:End()})

 Else
  HS_MsgInf("Toda(s) guias est„o com profissional preenchido.", STR0034, "ValidaÁ„o profissional da guia." )//atencao
  lret := .F.
 Endif


If lRet .And. nOpcA == 1
    //GRAVA CADASTRO DE FUNCIONARIOS  -- SRA
	Begin Transaction

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//| Ponto de entrada para alterar a Matricula do Medico      |
		//| na inclusao do Medico Solicitante                        |
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	
		If ExistBlock("HSM24MSO")
			cMatSra := ExecBlock("HSM24MSO",.F.,.F.,{cMatSra})
	
			If ValType( cMatSra ) <> "C" .OR. EMPTY(cMatSra)
				lReturn := .T.
				lRet := .F.
				DisarmTransaction()
				Break
			Else
				DbselectArea("SRA")
				DbSetOrder(1) // RA_FILIAL + RA_MAT
				If lAchouSra := DBSeek(xFilial("SRA") + cMatSra)
					HS_MsgInf(STR0315, STR0034, STR0135) //###"AtenÁ„o"###"ValidaÁ„o do MÈdico"
					lReturn := .T.
					lRet := .F.
					DisarmTransaction()
					Break
				Endif
			EndIf
		Else
			cMatSra := HS_VSxeNum("SRA", "M->RA_MAT", 1)
			ConfirmSx8()
		Endif
	
	  	RecLock("SRA", .T.)
	  	SRA->RA_FILIAL  := xFilial("SRA")
	  	SRA->RA_CODIGO  := cCodCrm
		SRA->RA_MAT     := cMatSra
	  	SRA->RA_NOME    := cDesCrm
	  	SRA->RA_CC      := cGcsCodCCu
	  	SRA->RA_CATFUNC := "A"
	  	MsUnlock()
	
		RecLock("GBJ", .T.)
		GBJ->GBJ_FILIAL := xFilial("GBJ")
		GBJ->GBJ_CRM    := cCodCrm
		GBJ->GBJ_ESPEC1 := cEspeci
		GBJ->GBJ_TIPPRO := "2"
	    GBJ->GBJ_CODPRE := cPreSoli
		GBJ->GBJ_STATUS := "1"
		MsUnlock()

    End Transaction
    
    If !lReturn
	    For nPos := 1 to len(oGdGcz:aCols)
		  If Empty(oGDGcz:aCols[nPos, nGCZCodCrm])
		  	oGDGcz:aCols[nPos, nGCZCodCrm] := cCodCrm
	 	  	oGDGcz:aCols[nPos, nGCZNomMed] := cDesCrm
		  Endif
	    Next
	
	    oGdGcz:oBrowse:Refresh()
    EndIf
 Endif
  
RestArea(aArea)
Return(lRet)

Static Function FS_VLDCPO(cCodCrm, cDesCrm, cEspeci)
 Local lRet := .T.

 If Empty(cCodCrm) .Or. Empty(cDesCrm) .Or. Empty(cEspeci)
  HS_MsgInf("Existem campos sem preenchimento, por favor verifique.", STR0034, STR0135) //###"AtenÁ„o"###"ValidaÁ„o do MÈdico"
  lRet := .F.
 Endif

Return (lRet)


Static Function 	FS_VEspMed(cCodEsp, cDesEsp)
 Local lRet := .T.
 Local aArea := GetArea()

 If EMPTY(cCodesp)
   HS_MsgInf(STR0060, STR0034, STR0146) //"Especialidade n„o encontrada."###"AtenÁ„o"###"ValidaÁ„o da especialidade"
 Else
  cDesEsp := HS_IniPadr("GFR", 1, cCodesp, "GFR_DSESPE",, .F.)

  If Empty(cDesEsp)
  	HS_MsgInf(STR0060, STR0034, STR0146) //"Especialidade n„o encontrada."###"AtenÁ„o"###"ValidaÁ„o da especialidade"
  	lRet := .F.
  Endif
 EndIf

 RestArea(aArea)

Return(lRet)
//GRAVA SOLICITACAO DE AUTORIZACAO NA GNX
Static Function FS_GrvSol(cRegAte,aGE3,aGE2,cCodigo)
Local i       := 0
Local aHProc  := {{"","GE3_FILIAL"},{"","GE3_DATSOL"},{"","GE3_HORSOL"},{"","GE3_QTDSOL"},{"","GE3_CODDES"},{"","GE3_CODPRT"},;
{"","GE3_SEQDES"},{"","GE3_LOGARQ"},{"","GE3_STATUS"},{"","GE3_REGATE"},{"","GE3_NSEQGD"},{"","GE3_NRSEQG"}}
Local aCProc  := {}
Local aHMat   := {{"","GE2_FILIAL"},{"","GE2_DATSOL"},{"","GE2_HORSOL"},{"","GE2_QTDSOL"},{"","GE2_CODDES"},{"","GE2_CODPRT"},;
{"","GE2_SEQDES"},{"","GE2_LOGARQ"},{"","GE2_STATUS"},{"","GE2_REGATE"},{"","GE2_NSEQGD"},{"","GE2_NRSEQG"}}
Local aCMat   := {}
Local cCodSol := ""

Default cCodigo := ""

For i := 1 to Len(aGE3)
	AADD(aCProc,{xFilial("GE3"),dDataBase,Time(),aGE3[i][2],aGE3[i][1],,GetSXEnum("GE3","GE3_SEQDES",, 1),HS_LogArq(),"0",cRegAte,aGE3[i][3],aGE3[i][4]})
Next i
For i := 1 to Len(aGE2)
	AADD(aCMat,{xFilial("GE2"),dDataBase,Time(),aGE2[i][2],aGE2[i][1],,GetSXEnum("GE2","GE2_SEQDES",, 1),HS_LogArq(),"0",cRegAte,aGE2[i][3],aGE2[i][4]})
Next i

DbSelectArea("GCY")
DbSetOrder(1)
If DbSeek(xFilial("GCY") + cRegAte)
	//HS_GRVGNX(cRegGer,cNomPac,cCodUsu,cCodAge,cRegAte,cCodPla,cCarInt,cTipInt,cRegInt,cDiaSol,cIndCli,dDtpAdm,dDatAdm,aHProc,aCProc,aHMat,aCMat,cCodCrm,cCodCid,cTdTiss)
	cCodSol := HS_GRVGNX(GCY->GCY_REGGER,GCY->GCY_NOME,Substring(cUsuario,7,15),,cRegAte, HS_IniPadr("GCZ", 2, cRegAte, "GCZ_CODPLA",,.F.),"E","2",GCY->GCY_REGIME,"1",HS_IniPadr("GCZ", 2, cRegAte, "GCZ_INDCLI",,.F.),,,aHProc,aCProc,aHMat,aCmat,GCY->GCY_CODCRM,GCY->GCY_CIDINT,HS_IniPadr("GCZ", 2, cRegAte, "GCZ_TDTISS",,.F.),cCodSol)
EndIf

Return(Nil)

 // Verifica se o procedimento necessita de autorizacao para envio ao Controle de Autorizacoes
Static Function FS_CrAuto(cAlias, cCodPla, cCodDes,cSeqDes,cTip,cQtdDes,lAlter,cNrSeqG)
Local cAliasGE := IIf(cTip == "4", "GE3","GE2")

Default cQtdDes := "1"
Default cSeqDes := ""
Default cNrSeqG	:= ""

If FunName() # "HSPAHP12" .AND. Type("__aGeISol") # "U" .AND. Type("__aGeMSol") # "U" .AND. Type("lOpcOk") # "U"
 	If lOpcOk
 		If (lAut := Hs_DespAut(cAlias, cCodPla, cCodDes, , cTip)) .AND. !lAlter
			If MsgYesNo("Procedimento / Mat/Med [" + cCodDes + "] requer autorizaÁ„o, Deseja envia-lo para o Controle de SolicitaÁıes? ") //"Procedimento requer autorizaÁ„o, Deseja envia-lo para o Controle de SolicitaÁıes? "
				If !HS_ExisDic({{"T", "GNX"}},.F.)
					HS_MsgInf("Para utilizar essa rotina execute o atualizador GH147276 (Controle de AutorizaÁıes). Consulte suporte para mais detalhes", STR0013, STR0194) //"Para utilizar essa rotina execute o atualizador GH147276 (Controle de AutorizaÁıes). Consulte suporte para mais detalhes", "Atencao", "Validacao Dicionarios"
				Else
					If cTip == "4"
						AADD(__aGeISol,{cCodDes,cQtdDes,cSeqDes,cNrSeqG})//Procedimento, Qtde,
					Else
						AADD(__aGeMSol,{cCodDes,cQtdDes,cSeqDes,cNrSeqG})
					EndIf
				EndIf
			EndIf
		ElseIf lAlter .AND. HS_ExisDic({{"T", "GNX"}},.F.)
			DbSelectArea(cAliasGE)
			DbSetOrder(4) // GE2_FILIAL+GE2_NSEQGD+GE2_STATUS
			If DbSeek(xFilial(cAliasGE) + cSeqDes + "0") // Atualiza somente se status for igual a pendente
				RecLock(cAliasGE, .F.)
					&(cAliasGE + "->" + cAliasGE + "_QTDSOL") := cQtdDes
				MsUnlock()
			EndIf
		EndIf
	EndIf
 EndIF
Return(Nil)

Static Function FS_VSOLGE(cRegAte)
Local aArea 	:= GetArea()
Local cCodSol 	:= ""
Local cSql		:= ""

cSql := " SELECT GMJ_CODAGE FROM " + RetSqlName("GMJ") +  " GMJ WHERE GMJ_REGATE = '" + cRegAte + "'"
cSql += " AND GMJ.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.D_E_L_E_T_ <> '*' "

cSQL := ChangeQuery(cSQL)
TCQUERY cSQL NEW ALIAS "TMPGNX"

If !TMPGNX->(Eof()) .AND. HS_ExisDic({{"T", "GNX"}})
	DbSelectArea("GNX")
	DbSetOrder(2)//GNX_FILIAL+GNX_CODAGE
	If DbSeek(xFilial("GNX") + TMPGNX->GMJ_CODAGE)
		cCodSol := GNX->GNX_CODSOL
	EndIf
EndIf

TMPGNX->(DbCloseArea())

RestArea(aArea)
Return(cCodSol)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ HS_TDEXAIH   ≥ Autor ≥  Rogerio Tabosa       ≥Data  ≥ 05/01/10 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Retorna o Tipo e Descricao do Documento do Executante          ≥±±
±±≥          ≥ para efeito no Layout de arquivo texto AIH                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ HS_TDEXAIH( )                                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ Nenhum												      	  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Function HS_TDEXAIH(cCodCrm)
Local aArea 	:= GetArea()
Local cTipDoc 	:= ""
Local cDesDoc 	:= ""

DbSelectArea("GBJ")
DbSetOrder(1)    // FILIAL + CRM
If DbSeek(xFilial("GBJ") + cCodCrm)
	DbSelectArea("GAZ")
	DbSetOrder(1)
	If DbSeek(xFilial("GAZ") + GBJ->GBJ_CODPRE)
		If !Empty(GAZ->GAZ_TDEAIH)    // 1=CPF Prof;2=CNPJ;3=CNES
			cTipDoc := GAZ->GAZ_TDEAIH
			If cTipDoc == "1"
				cDesDoc := GBJ->GBJ_CIC
			ElseIf cTipDoc == "3"
				cDesDoc := GAZ->GAZ_CGCPRE
			ElseIf cTipDoc == "5"
				cDesDoc := GAZ->GAZ_CNES
			EndIf
		ElseIf !Empty(GBJ->GBJ_TDEAIH)
			cTipDoc := GBJ->GBJ_TDEAIH
			If cTipDoc == "1"
				cDesDoc := GBJ->GBJ_CIC
			ElseIf cTipDoc == "3"
				cDesDoc := GAZ->GAZ_CGCPRE
			ElseIf cTipDoc == "5"
				cDesDoc := GBJ->GBJ_CNES
			EndIf
		EndIf
	EndIf
EndIf

If Empty(cTipDoc) .OR. Empty(cDesDoc)
	cDesDoc := GetMv("MV_HSPCNES",,"")
	cTipDoc := IIf(Empty(cDesDoc),"","3")
EndIf


RestArea(aArea)
Return({cTipDoc, cDesDoc})

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ FS_PROCPLS   ≥ Autor ≥  Rogerio Tabosa       ≥Data  ≥ 29/09/10 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Atribui os codigos da proc e tabela do PLs para filtro Face/Regi±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ FS_PROCPLS( )                                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ Nenhum												      	  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Static Function FS_PROCPLS(cCodPro)
Local aArea := GetArea()
Local lIntegr	:= GetMv("MV_HSPPLS")
If Type("cProPls") == "C" .AND. Type("cTabPls")  == "C"  .AND. lIntegr
	DbSelectArea("GA7")
	DbSetorder(1)
	If DbSeek(xFilial("GA7") + cCodPro)
		cProPls := GA7->GA7_PROPLS
		cTabPls := GA7->GA7_TABPLS
	EndIf
Endif
RestArea(aArea)
Return(.T.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥Fs_RefDes ∫Autor  ≥Microsiga           ∫ Data ≥  28/12/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Funcao criada para refazer a descricao da guia, caso haja   ∫±±
±±∫          ≥uma mensagem de critica.                                    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ SIGAHSP                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function Fs_RefDes(cGcuApoio)
Local aArea := GetArea()

oGDGcz:aCols[oGDGcz:nAt, nGczNrGuia] := PadR(cGcuApoio,oGDGcz:aHeader[nGczNrGuia][4])
oGDGcz:aCols[oGDGcz:nAt, nGCZDsGuia] := Posicione("GCU",1,xFilial("GCU") + cGcuApoio, "GCU_DESTPG")
oGDGcz:oBrowse:Refresh()

RestArea(aArea)
Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥FS_vldQtdProc    ≥Autor≥Saude               ≥Data≥04/07/2011≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥Verifica se o procedimento inserido na aba "3-Procedimentos"≥±±
±±≥          ≥na opcao "Guias" ultrapassa a qtd. maxima de agendamentos   ≥±±
±±≥          ≥Verifica se a qtd inserida (para procedimento ja inserido)  ≥±±
±±≥          ≥ultrapassa qtde maxima de agendamentos permitidos           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ FS_vldQtdProc()                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Argumentos≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ logico - Permite ou nao a inclusao do procedimento / qtd   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ SIGAHSP                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

function FS_vldQtdProc()

local aArea      := getArea()
local cCodSolApa := ""
local cCodSolSes := ""
local cCodPac    := M->GCY_REGGER
local nQtdProAgd := 0
local nQtdmaxPro := 0
local lRet       := .T.
local cCodProced := ""
local nQtdSolici := 0
local nQtdGrid   := 0
local nI         := 0
local lAgdmtps   := SuperGetMv("MV_AGDMTPS",nil,.F.)
local lAgdmSes   := SuperGetMv("MV_AGDMSES",nil,.F.)
local lApac      := .F.
local lSessoes   := .F.
local cProcAge   := ""


//if SuperGetMv("MV_ATESUS",nil,"N") <> "S" .or. !lAgdmtps .or. !lAgdmSes
if !lAgdmtps .and. !lAgdmSes
	restArea(aArea)
	return .T.
else
	if readVar() == "M->GD7_QTDDES"
		if empty(oGDPR:aCols[oGDPR:nAt, nPRCODDES])
			restArea(aArea)
			return .T.
		endif
		cCodProced := oGDPR:aCols[oGDPR:nAt, nPRCODDES]
		nQtdSolici := &(readVar())
	elseif readVar() == "M->GD7_CODDES"
		cCodProced := &(readVar())
		nQtdSolici := oGDPR:aCols[oGDPR:nAt, nPRQTDDES]
	else
		restArea(aArea)
		return .T.
	endif

	DbSelectArea("GM8")
	DbSetOrder(10)
	DbSeek(xFilial("GM8") + cCodPac )
	While !EOF() .And. GM8->GM8_REGGER == M->GCY_REGGER
		If GM8->GM8_REGATE == M->GCY_REGATE
			cProcAge   := GM8->GM8_CODPRO
			if !empty(GM8->GM8_SOLICI)
				lApac := .T.
				cCodSolApa := GM8->GM8_SOLICI
				exit
			elseif !empty(GM8->GM8_SOLGKB)
				lSessoes := .T.
				cCodSolSes := GM8->GM8_SOLGKB
				exit
			endif
		EndIf
		DbSkip()
	EndDo

	//Para solicitacao de Apac (HSPAHM12) / Solicitacao de sessoes (HSPAHM13)
	if !empty(cCodSolApa) .or. !empty(cCodSolSes)
        if lApac
			//Quantidade de procedimentos agendados para essa solicitacao de APAC (HSPAHM12)
			nQtdProAgd := hs_qtProAg(cCodSolApa, cCodProced)
			//Quantidade maxima de agendamentos para o procedimento
			nQtdMaxPro := hs_qtMaxPr(cCodProced)
		elseif lSessoes
			//Quantidade de procedimentos agendados para essa solicitacao de Sessao (HSPAHM13)
			nQtdProAgd := hs_qtProAg(cCodSolSes, cCodProced, "S")
			//Quantidade maxima de agendamentos para o procedimento
			nQtdMaxPro := Posicione("GKB", 1, xFilial("GKB") + cCodSolSes, "GKB_QTDSOL")
		endif

		for nI := 1 to len(oGDPR:aCols)
			   //procedimento grid == proced. digitado         status == vermelho                                  linha verificada <> linha atual     linha nao foi excluida
			if oGDPR:aCols[nI, nPRCODDES] == cCodProced .and. alltrim(oGDPR:aCols[nI, nPRStareg]) == "BR_VERMELHO" .and. nI <> oGDPR:nAt .and. !oGDPR:aCols[nI, len(oGDPR:aCols[nI])]
				nQtdGrid += oGDPR:aCols[nI, nPRQTDDES]
			endif
		next nI

		if nQtdProAgd + nQtdSolici + nQtdGrid <= nQtdMaxPro
			lRet := .T.
		else
			if cProcAge == cCodProced
				HS_MsgInf(OemToAnsi(STR0310 + " (" + cValToChar(nQtdSolici) + ") " + ;//"O numero de sessıes definido"
				iIf(nQtdProAgd > 0 , "+ " + STR0311 + " (" + cValToChar(nQtdProAgd) + ") ","") + ;//"a quantidade j· agendada"
				iIf(nQtdGrid > 0 , "+ " + STR0312 + " (" + cValToChar(nQtdGrid) + ") ","") +; //"a quantidade j· inserida no grid"
				STR0313 + " (" + cValToChar(nQtdMaxPro) + ") " + iIf(lApac, STR0317, iIf(lSessoes, STR0318,"")) + ". " + ; //" na solicitaÁ„o de APAC (HSPAHM12)" ### " na solicitaÁ„o de sessıes (HSPAHM13)"
				STR0314 + "!"),STR0034,STR0235)  //"O numero de sessoes definido (n) + a quantidade j· agendada (n) deste procedimento ultrapassa a quantidade m·xima permitida (XXXXXXXXXX). Verifique!" ### "AtenÁ„o" ### "ValidaÁ„o da Guia"
				lRet := .F.
			endif
		endif
	else
		lRet := .T.
	endif
endif

restArea(aArea)
return lRet
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HM24RETCR ∫Autor  ≥Microsiga           ∫ Data ≥  21/06/2013 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ SIGAHSP                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function HM24RETCR(cCodCon,cCodCrm,cCodPla)
Local aArea 		:= GetArea()
Local cCredMed		:= ""
Local cCodPre		:= ""
Local dDataBase		:= Date()
Default cCodCon 	:= ""
Default cCodPla 	:= ""
Default cCodCrm 	:= ""

GBJ->(DbSetOrder(1))
If GBJ->(DbSeek(xFilial("GBJ")+cCodCon)	)
	cCodPre := GBJ->GBJ_CODPRE
Endif

GAY->(DbSetOrder(7))//GAY_FILIAL+GAY_CODCON+GAY_CODCRM+GAY_CODPLA
If GAY->(DbSeek(xFilial("GAY")+cCodPre))
	GDJ->(DbSetOrder(1))//GDJ_FILIAL+GDJ_CODSEQ+GDJ_ITEVIG
	If GDJ->(DbSeek(xFilial("GDJ")+GAY->GAY_CODSEQ))
		While !GDJ->(Eof()) .And. GDJ->GDJ_CODSEQ == GAY->GAY_CODSEQ
			If dDataBase >= GDJ->GDJ_DATVIG
				cCredMed := GDJ->GDJ_TIPREC
				Exit
			Endif
			GAY->(DbSkip())
		Enddo
	Endif
Endif

RestArea(aArea)

Return (cCredMed)

