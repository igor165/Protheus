#INCLUDE "HSPAHM24.ch"
#include "protheus.ch"
#INCLUDE "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHAIH  บAutor  ณMicrosiga           บ Data ณ  12/19/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSPAIHAI(aExecAHI) // Interna็ใo    
       
 Private aRotAIH := {{OemtoAnsi(STR0001), "axPesqui" , 1, 01} , ; // 01 //"&0-Pesquisar"
                   {OemtoAnsi(STR0002), "HS_RecM24", 2, 02} , ; // 02 //"&1-Consultar"
                   {OemtoAnsi(STR0003), "HS_RecM24", 3, 03} , ; // 03 //"&U-R.Cirurgica"
                   {OemtoAnsi(STR0004), "HS_VAltPac",4, 04} , ; // 04 //"&3-Alterar"
                   {OemtoAnsi(STR0005), "HS_P36Can", 5, 02} , ; // 05 //"&4-Cancelar"
                   {OemtoAnsi(STR0006), "HS_P36Ret", 6, 04} , ; // 06 //"&5-Retornar"
                   {OemtoAnsi(STR0007), "HS_RecAIH", 7, 04} , ; // 07 //"&6-Guias"
                   {OemtoAnsi(STR0019), "HS_M30Tra", 8, 03}, ; // 10 //"&F-Transfere"
                   {OemtoAnsi(STR0010), "HS_MdLM24", 9, 02}, ; // 11 //"&O-Modif.Leito"
                   {OemtoAnsi(STR0102), "HS_PesMed", 10, 04}, ; // 12 //"&M-M้dico"
                   {OemtoAnsi(STR0012), "HS_RecM24", 11, 03}, ; // 13 //"&R-Rec. Normal"
                   {OemtoAnsi(STR0013), "HS_RNAIH", 12, 02}, ; // 14 //"&N-RN"
                   {OemtoAnsi(STR0104), "HS_PacM24", 13, 04}, ; // 17 //"&C-Paciente"
                   {OemtoAnsi(STR0015), "HS_LegM24", 14, 02}, ; // 18 //"&L-Legenda"
                   {OemtoAnsi(STR0283), "HSPAHM08(GCY->GCY_REGATE)", 19, 02}}// "Pedido de Exames"
                   

                   
 Private cM24Par01 := ""
 Private cCadastro := STR0016 //"Interna็ใo"
 Private cAgdFilAge := ""
 Private cAgdCodAge := ""
 Private cCodSol   := ""
 Private cPergAIH  := "HSPAIH"
 Private cPergOPM  := "HSPOPM" 
 Private cPergDia :=  "HSPDIA" 
 Private cPergLaq :=  "HSPLAQ" 
 Private cPergReg :=  "HSPREG"
 Private __cRetMet := "" 
 
 AjustaSXB()
      
 HSPAHAIH("0", aRotAIH, aExecAHI)
 
Return(Nil)
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHAIH  บAutor  ณMicrosiga           บ Data ณ  12/19/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function HSPAHAIH(cTipAte, aRotAIH, aExecAHI) //Inicio
 Local aCorAIH := {}/*, nLinha := 0*/
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
 Private cAliasTD := IIf(aExecAHI == Nil .Or. aExecAHI[3] == "P", "GD6", "GE6")
 Private cAliasPR := IIf(aExecAHI == Nil .Or. aExecAHI[3] == "P", "GD7", "GE7")
 Private cPrefiPR := IIf(aExecAHI == Nil .Or. aExecAHI[3] == "P", "GD7->GD7", "GE7->GE7")
 
 Private lIsCaixa := IsCaixaLoja(xNumCaixa())
  
 Private aVarDef := {{"cGcsCodLoc"   , "GCS->GCS_CODLOC"}, ;
                     {"cGcsCodCCu"   , "GCS->GCS_CODCCU"}, ;
                     {"cGcsArmSet"   , "GCS->GCS_ARMSET"}, ;
                     {"cGcsArmFar"   , "GCS->GCS_ARMFAR"}, ;
                     {"M->GCY_NOMLOC", "GCS->GCS_NOMLOC"}}
 
 Private cFilM24 := "", lFilGm1 := .F. // Sera utilizada no filtro da consulta padrใo GCS

 Private cGczNrSeqG := Space(Len(GCZ->GCZ_NRSEQG))
 Private cLctCodLoc := Space(Len(GCS->GCS_CODLOC))
 Private cLctNrSeqG := Space(Len(GCZ->GCZ_NRSEQG))
 Private cGcyRegGer := Space(Len(GCY->GCY_REGGER))
 Private cGbjCodEsp := Space(Len(GBJ->GBJ_ESPEC1))
 Private cGbjTipPro := Space(Len(GBJ->GBJ_TIPPRO))
 Private cGbjTipAut := Space(Len(GBJ->GBJ_TIPPRO))
 Private cGcuCodTpg := Space(Len(GCU->GCU_CODTPG))
 Private cGczCodPla := Space(Len(GCZ->GCZ_CODPLA))
 Private cGcsCodLoc := Space(Len(GCS->GCS_CODLOC))
 Private cGcsCodCCu := Space(Len(GCS->GCS_CODCCU))
 Private cGA7CodPro := Space(Len(GA7->GA7_CODPRO))                                                 
 Private cObsCodCrm := Space(Len(GBJ->GBJ_CRM))
 Private oObjFocus                
 Private cPreNatal , cQtdVivo, cQtdMorto
 Private cQtdAlta, cQtdTransf, cSdObito
 
 Private __cFCdBKit := "HS_M24Kit()"                 // Sera utilizado dentro da fun็ใo de valida็ใo do c๓digo de barras do 
 Private __cFVPrPct := "HS_M24Pct()"
 Private __cFMntEqp := "HS_MntEqp(oGDPr, oGDTD)"

                                                          
 Private __aRProced := {{"oGDPR:aCols[oGDPR:nAt, nPRDDESPE]",     "06"}, ; // Sera utilizado dentro da fun็ใo de valida็ใo do
                        {"oGDPR:aCols[oGDPR:nAt, nPRCODESP]",     "07"}, ; // procedimento. HS_VProced()
                        {"oGDPR:aCols[oGDPR:nAt, nPRNOMESP]",     "08"}, ; // 
                        {"oGDPR:aCols[oGDPR:nAt, nPRINCIDE]", "02, 16"}, ;
                        {"oGDPR:aCols[oGDPR:nAt, nPRCODPRT]", "02, 15"}, ;
                        {"oGDPR:aCols[oGDPR:nAt, nPRDESPRT]", "02, 18"},;
                        {"oGDPR:aCols[oGDPR:nAt, nPRTABELA]", "02, 20"},;
                        {"oGDPR:aCols[oGDPR:nAt, nPRValTot]", "02, 04"}}
 
 Private cGcyAtendi := cTipAte //0-Interna็ใo  1-Ambulatorial  2-Pronto Atendimento 3-Atendimento Doacao
 Private cGcsTipLoc := IIf(cTipAte == "0", IIF(FunName() == "HSPAHP12" .And. HS_TemRN(GCY->GCY_REGATE), "348B", "34B"), IIF(cTipAte == "3", "C", cTipAte))
 Private aRotina    := aClone(aRotAIH)                          
 
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
 
 Private cStatusGAV := "0" // Var usada na funcao de filtro

  
 If !HS_ExisDic(aCampos)
  Return(Nil)
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
   		Hs_MsgInf(STR0247,STR0034,STR0248)//"Parametro MV_VLDGUIA preenchido com conteudo invalido"###"Aten็ใo"##"Valida็ใo parametro MV_VLDGUIA"
  		Return()
  	EndIf
EndIf
 
If aExecAHI <> Nil .And. aExecAHI[3] == "F"
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
  	aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVALDES]", "02, 01, 01"})
  	aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVFILME]", "02, 03"})
  	aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRPGTMED]", "09, 01"})
  	aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVALREP]", "09, 14"})
 
  	If HS_ExisDic({{"C", cAliasPR+"_VALREB"}},.F.)
   		aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVALREB]", "09, 14"})
  	EndIf
  
  	Iif( cAliasPR <> "GD7", aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRCOEDES]", "16, 02"}), Nil)
  	
EndIf

   
If cTipAte == "0" 
  aCorM24 := {{"GCY->GCY_TPALTA  # '99'  .AND.  EMPTY(GCY->GCY_TPALTA) .AND.   HS_M24CCEs(GCY->GCY_CODLOC) == '4'" , "BR_VERMELHO"},; //Admitido no C.C./C.O.
              {"GCY->GCY_TPALTA  # '99'  .AND.  !EMPTY(GCY->GCY_TPALTA)"                                           ,  "BR_AMARELO"},; //Alta Medica
              {"GCY->GCY_TPALTA  # '99'  .AND.  EMPTY(GCY->GCY_TPALTA) .AND. !(HS_M24CCEs(GCY->GCY_CODLOC) $ '4B')", "BR_VERDE"   },; //Recepcao 
              {"GCY->GCY_TPALTA  # '99'  .AND.  EMPTY(GCY->GCY_TPALTA) .AND.   HS_M24CCEs(GCY->GCY_CODLOC) == 'B'" , "BR_AZUL"    },; //Espera 
              {"GCY->GCY_TPALTA == '99'"                                                                           , "BR_CINZA"   }}  //Cancelado
Else
  aCorM24 := {{"GCY->GCY_TPALTA  # '99'  .AND. !EMPTY(GCY->GCY_TPALTA)"                                            , "BR_AMARELO" },; //Alta Medica
              {"GCY->GCY_TPALTA  # '99'  .AND.  EMPTY(GCY->GCY_TPALTA)   .AND.  EMPTY(GCY->GCY_LEIINT)"            , "BR_VERDE"   },; //Recepcao
              {"GCY->GCY_TPALTA  # '99'  .AND.  EMPTY(GCY->GCY_TPALTA)   .AND. !EMPTY(GCY->GCY_LEIINT)"            , "BR_LARANJA" },; //Repouso
              {"GCY->GCY_TPALTA == '99'"                                                                           , "BR_CINZA"   }} //Cancelado  
Endif                                   
DbSelectArea("GCY")
DbSetOrder(13) // GCY_FILIAL + GCY_LOCATE + GCY_DATSAI + GCY_DATATE
 
If aExecAHI == Nil
	If FS_FilM24(cTipAte, .F.)
   		mBrowse(06, 01, 22, 75, "GCY",,,,,, aCorM24,,,,,,,, cFilM24)
  	EndIf 
Else                      
	cLctCodLoc := aExecAHI[5] // Codigo do Setor
  	cLctNrSeqG := aExecAHI[6] // Numero da guia
  	lOrigemExt := .T.
   	nLinha := aScan(aRotina, {|aVet| aVet[3] == aExecAHI[4]})
   	&(aRotina[nLinha, 2] + "('GCY', " + AllTrim(Str(GCY->(RecNo()))) + ", " + AllTrim(Str(nLinha)) + ")")
EndIf 
 
SetKey(VK_F12, bKeyF12)

Return(Nil)                                                         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHAIH  บAutor  ณMicrosiga           บ Data ณ  12/19/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_RecAIH(cAliasAIH, nRegAIH, nOpcAIH)
 Local oDlgAten, nOpcAten := 0, nCntFor := 0, lIncOld := Inclui
 Local nGDOpc := IIf(Inclui .Or. aRotina[nOpcAIH, 3] == 7, GD_INSERT + GD_UPDATE + GD_DELETE, 0) // 7-Guias
 Local aBtnBar := {}, cOldRegAte := "", oBrwLei
 Local aCorLeito := {{"GAV->GAV_STATUS == '0' .Or. GAV->GAV_STATUS == ' '", "BR_VERDE"   , HS_RDescrB("GAV_STATUS", "0")},;
             		 {"GAV->GAV_STATUS == '2'"                            , "BR_VERMELHO", HS_RDescrB("GAV_STATUS", "1")},;
             		 {"GAV->GAV_STATUS == '1'"                            , "BR_MARROM"  , HS_RDescrB("GAV_STATUS", "2")},;
					 {"GAV->GAV_STATUS == '3'"                            , "BR_BRANCO"  , HS_RDescrB("GAV_STATUS", "3")},;
             		 {"GAV->GAV_STATUS == '4'"                            , "BR_PRETO"   , HS_RDescrB("GAV_STATUS", "4")},;
					 {"GAV->GAV_STATUS == '5'"                            , "BR_CINZA"   , HS_RDescrB("GAV_STATUS", "5")}}
                     
 Local aCposAlt := {}, aCposObr := {}, aGcyAIH := {}, aCpoGD7 :={} , aGcyGe3 := {}, aGczAlt := {}
 Local aSize := {}, aObjects := {}, aInfo := {}, aPFolder := {}, aPObjs := {}, aPMBrow := {}
 Local bKeyF4, bKeyF5, bKeyF7, bKeyF8, bKeyF12 := SetKey(VK_F12)
 Local bKeyF6 := SetKey(VK_F6, {|| FS_MostObs(cGczCodPla, "GA9", " plano ", nOpcAIH, .T.)})
 Local bKeyF9 := SetKey(VK_F9, {|| FS_MostObs(cGa7CodPro, "GA7", " procedimento ", nOpcAIH)})
 Local bKeyF10 := SetKey(VK_F10, {|| FS_MostObs(cObsCodCrm, "GBJ", " m้dico ", nOpcAIH)})
 Local nGuias := 0
 Local cGcyAtOrig := cGcyAtendi, cGcsTLOld := cGcsTipLoc
 Local cRegAteOri := GCY->GCY_REGATE

 Local aCpoAltPR := {}
 Local aCpoAltPG := {}
// Local aCpoVisTD := {}, cCpoNaoTD := ""
 Local aCpoVisPR := {}, cCpoNaoPR := ""
 Local aConEst   := {}
 Local aAlterOld := {"GD5_QDEVOL", "GD5_VALDES", "GD5_DESPER", "GD5_DESVAL", "GD5_DESOBS"}, aAlterNew := {}, nFCpoAlt := 0 
 Local lFichas   := .F., cCondGcz := "", lAchou:= .T. //,lIsCaixa := .T.
 Local aCBrwPac  := {"GAV_REGATE", "GAV_REGGER", "GAV_NOME  ", "GAV_DATATE", "GAV_HORATE", "GAV_CODCRM", ;
                     "GAV_MEDICO", "GAV_CODLOC", "GAV_NOMLOC", "GAV_QUARTO", "GAV_LEITO ", "GAV_SEXO  ", ;
                     "GAV_MOTINT", "GAV_DMTINT" }
                     
 Local oGDGb1, aHGb1 := {}, aCGb1 := {}
 Local aMLocksSb2 := {}, aMLocksSb3 := {}, nItens := 0, nForGuia := 0, nForMM := 0, nPosGD := 0, aCDesp := {}, nPos:= 0, nPos2 := 0
 
 Local cMovest    := UPPER(GetMv("MV_AUDMEST"))
 Local lNewDayAte := IIF(HS_VldSx6({{"MV_NEWDATE",{"L","T/F","$"}}},.F.), GetMv("MV_NEWDATE"),.T.) 
 
 Local aHGCZ := {}, aCGCZ := {}, aGczC:= {}  ,aDGcz := {}
 Local aHPR  := {}, aCPR  := {}
 Local aHGE2 := {}, aCGE2 := {}  
 Local aHGE3 := {}, aCGE3 := {}  
 
 
 Local oPPesq, aOPesq := {}
 Local lOkM24 := .T.
 
 Local nY := 0 , nX:= 0
 
 Private aHGE8 := {}, aCGE8 := {}
 Private oGDGcz, oGDTD, oGDPR //, oGDGE2, oGDGE3
 
 Private lAltCodLoc := IIf(cGcyAtendi == "0" .And. aRotina[nOpcAIH, 4] == 3, .T., .F.)                    
                                              
 Private oFolAten, oFolAten2, oFolDesp, oEncGcy, oGD7, aGets := {}, aTela := {}
 Private aGetsGcy := {}, aTelaGcy := {}
 
 Private cGbhDtNasc := CToD(""), cGbhSexo := "", cGbhRg := "", cGbhRgOrg := "", cGbhUFEmis := "",cSexoAu := "", cDtNascAu := "", cRGAu := "", cOrgEmiAu := "", cUFEmisAu := ""
 Private cOldCodLoc := "", cOldQuaInt := "",  cOldLeiInt := "", cGavModelo := ""
 
 Private nGCZNRSEQG := 0, nGCZCODTPG := 0, nGCZDESTPG := 0, nGCZCODPLA := 0, nGCZDESPLA := 0, nGczCodCrm := 0, nGczNomMed := 0, nGczStatus := 0
 Private nGczSqCatP := 0, nGczDsCatP := 0, nGczCodDes := 0, nGczCodPrt := 0, nGczTATISS := 0, nGczTIPCON := 0, nGczINDCLI := 0
 Private nGCZNrGuia := 0, nGCZNrSen1 := 0, nGCZNrSen2 := 0, nGCZNrSen3 := 0, nGCZQtDias := 0, nGczIdGuia := 0, nGczNumOrc := 0, nGczDdespe := 0
 Private nGCZDtGuia := 0, nGCZValSen := 0, nGCZTedVlr := 0, nGCZTedUnd := 0, nGCZCPFGES := 0
 
 Private nTDSeqDes := 0, nTDQtdDes := 0, nTDCODDES := 0, nTDDDESPE := 0, nTDCodPct := 0, nTDDesPct := 0, ;
         nTDCodKit := 0, nTDDesKit := 0, nTDDatDes := 0, nTDHorDes := 0, nTDCodLoc := 0, nTDNomLoc := 0, ;
         nTDValDes := 0, nTDPCuDes := 0, nTDStaReg := 0, nTDCodTxc := 0, nTDDesTxc := 0, nTDTABELA := 0, ;
         nTDDesPer := 0, nTDDesVal := 0, nTDDesObs := 0, nTDValTot := 0, nTDTotDsc := 0, nTDCODCRM := 0, ;
         nTDNOMCRM := 0, nTDPGTMED := 0, nTDREPAMB := 0, nTDREPINT := 0, nTDVALREP := 0, nTDVALREB := 0
         
 Private nPRSeqDes := 0, nPRQTDDES := 0, nPRCODDES := 0, nPRDDESPE := 0, nPRCODESP := 0, nPRNOMESP := 0, ;
         nPRCODCRM := 0, nPRNomMed := 0, nPRCODATO := 0, nPRDesAto := 0, nPRCodPct := 0, nPRDesPct := 0, ;
         nPRCodKit := 0, nPRDesKit := 0, nPRDatDes := 0, nPRHorDes := 0, nPRCodLoc := 0, nPRNomLoc := 0, ;
         nPRSPrinc := 0, nPRCodVia := 0, nPRCOEFAM := 0, nPRVALDES := 0, nPRVFILME := 0, nPRVCUSOP := 0, ;
         nPRPCUDES := 0, nPRURGDES := 0, nPRCOECHP := 0, nPRQTDCHP := 0, nPRPGTMED := 0, nPRCOECHM := 0, ;
         nPRREPAMB := 0, nPRVALREP := 0, nPRSLaudo := 0, nPRCrmLau := 0, nPRNMeLau := 0, nPRINCIDE := 0, ;
         nPRCoeDes := 0, nPROriDes := 0, nPRStaReg := 0, nPRCodPrt := 0, nPRDesPrt := 0,;
         nPRCdGAte := 0, nPRDsGAte := 0, nPRCdTAte := 0, nPRDsTAte := 0, nPRCodCid := 0, ;
         nPRCidSec := 0, nPrVlrCos := 0, nPRTABELA := 0, nPrVguiaI := 0, nPrVguiaF := 0, nPRDesPer := 0, ;
         nPRDesVal := 0, nPrDesObs := 0, nPRValTot := 0, nPrTotDsc := 0, nPRVALREB := 0, nPRCnpjFo := 0,;
         nPRNFOpm  := 0, nPRLote   := 0, nPRSerie  := 0, nPRCNPJFa := 0, nPRAnvisa := 0, ;
         nCompetD  := 0 ,nQtdFil   := 0, nCidInd   := 0, nGrauInstr:= 0, nMetContr1:= 0, nMetContr2:= 0, ;
         nGestRis  := 0         

 Private nGe2CodDes := 0, nGe2DDespe := 0, nGe2QtdSol := 0, nGe2QtdAut := 0, nGe2SeqDes := 0, nGe2StaReg := 0, nGe2DatSol := 0
 Private nGe3CodDes := 0, nGe3DDespe := 0, nGe3QtdSol := 0,nGe3SeqDes := 0, nGe3CodPrt := 0, nGe3StaReg := 0, nGe3DatSol := 0
  
 Private aGczGd := {}, nAtAnt := 1, aPDesp := {}, cMvLocCont := AllTrim(GetMv("MV_LOCCONT"))
 
 Private cCamposNao := ""
 
 Private cGO0Status := ""
 Private cGO0Atendi := ""
 Private cGO0RegGer := ""
  
 Private cCondAtrib := ""
 
 Private lNrGTissAt := .F.
 
 Private aGuiaTISS := {}
 Private aGE2Sol   := {}
 Private aGE3Sol   := {}
 
 Private lRecepAgd := .F.
 
 Private dDatAte   := CTOD("")
  

If aRotina[nOpcAIH, 3] == 10 
 	If GCY->(Eof())
   		Help("", 1, "ARQVAZIO")
	   lOkM24 := .F.
  
  	ElseIf !Empty(GCY->GCY_TPALTA) .And. GCY->GCY_TPALTA <> "99"
   		HS_MsgInf(STR0231, STR0034, STR0232) //"Impossํvel realizar a transfer๊ncia pois	paciente jแ estแ com alta."###"Aten็ใo"###"Transfer๊ncia"
   		lOkM24 := .F.
  
  	ElseIf HS_CountTB("GAI", "GAI_REGATE = '" + GCY->GCY_REGATE + "' AND GAI_FLGATE IN ('0', '1')") > 0		
  		HS_MsgInf(STR0284, STR0034, STR0232) //"Impossํvel realizar a transfer๊ncia pois	paciente possui solicita็๕es de materiais e medicamentos em aberto."###"Aten็ใo"###"Transfer๊ncia"
   		lOkM24 := .F.
  	EndIf 
 
ElseIf StrZero(nOpcAIH, 2) $ IIf(cGcyAtendi == "0",  "04/07", "04/07/10") .And. GCY->GCY_TPALTA == "99"
 	HS_MsgInf(STR0098, STR0034, aRotina[nOpcAIH, 1]) //"Atendimento cancelado nใo pode ser alterado!"
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

If cGcyAtendi $ "0/1/2" .And. StrZero(nOpcAIH, 2) $ "03/07/"+IIF(cGcyAtendi # "2","13","")
	Aadd(aBtnBar, {"BMPUSER",{||If(HS_SeekRet("GBH","cGcyRegGer", 1, .F., "GCY_REGGER", "GBH_CODPAC",,, .T.), HS_Paciente(nRegAIH,nOpcAIH),"") },OemToAnsi("Dados do Paciente"), OemToAnsi("Paciente")}) //"Dados Paciente"###"Paciente"     		
	Aadd(aBtnBar, {"BMPUSER",{||HS_RNAIH()},OemToAnsi("Dados RN"), OemToAnsi("RN")}) //"Dados RN"###"Rn"
ElseIf (cGcyAtendi == "3" .And. StrZero(aRotina[nOpcAIH, 3],2) $ "13/02/07")
	Aadd(aBtnBar, {"NOTE_OCEAN", {|| FS_DadComp(nOpcAIH) }, STR0213, STR0214}) //"Doa็ใo"###"Dados"
EndIf 

If FunName() == "HSPAHM30"  // se a rotina for chamada do posto de enfermagem seleciona campos para alterar
  aCpoAltPR := {"GE3_DATSOL","GE3_HORSOL","GE3_QTDSOL","GE3_CODDES","GE3_DDESPE"}
Else
  aCpoAltPR := Nil
EndIf
  
If FunName() <> "HSPAHP12" // Se nao for chamado da rotina de faturamento bloqueia alteracao dos campos
  	aCpoVisPR := {cAliasPR + "_CODLOC", IIF(cGcyAtendi == "2" , cAliasPR + "_HORDES", Nil), IIF(cGcyAtendi == "2", cAliasPR + "_DATDES", Nil), cAliasPR + "_VALDES", ;
                cAliasPR + "_VFILME"}
 
  	cCpoNaoPR := cAliasPR + "_CODLOC/" + cAliasPR + "_NOMLOC/" 
  	cCpoNaoPR += cAliasPR + "_CGCFOR/" + cAliasPR + "_NNFFOR/"
  	cCpoNaoPR += cAliasPR + "_CDGATE/" + cAliasPR + "_DSGATE/" + cAliasPR + "_CDTATE/" + cAliasPR + "_DSTATE/"
  	cCpoNaoPR += cAliasPR + "_CODCID/" + cAliasPR + "_CIDSEC/" + cAliasPR + "_CNPJFO/" +  cAliasPR + "_NFOPM/" 
  	cCpoNaoPR += cAliasPR + "_LOTOPM/" + cAliasPR + "_SEROPM/" + cAliasPR + "_CNPJFA/" +  cAliasPR + "_ANVOPM/"   
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
    cCpoNaoPR := cAliasPR + "_CGCFOR/" + cAliasPR + "_NNFFOR/"
    cCpoNaoPR += cAliasPR + "_CDGATE/" + cAliasPR + "_DSGATE/" + cAliasPR + "_CDTATE/" + cAliasPR + "_DSTATE/"
    cCpoNaoPR += cAliasPR + "_CODCID/" + cAliasPR + "_CIDSEC/" 
 EndIf
  
If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3",  aRotina[nOpcAIH, 3] <> 7, aRotina[nOpcAIH, 3] <> 4))
	aSize := MsAdvSize(.T.)
  	aObjects := {}	
  	AAdd( aObjects, { 100, 100, .T., .T., .T. } )	

  	aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
  	aPFolder := MsObjSize( aInfo, aObjects )
	                       
	aObjects := {}	
  /* anterior
  	AAdd( aObjects, { 100, 050, .T., .T. } )	
  	AAdd( aObjects, { 100, 015, .T., .T. } )	
  	AAdd( aObjects, { 100, 030, .T., .T., .T. } )	 
  	AAdd( aObjects, { 100, 005, .T., .T., .T. } )	 
  */	
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
 
 
   
 If aRotina[nOpcAIH, 3] == 10 // 10-Transferencia do setor ambulatorial para o setor de interna็ใo
 	cGcsTipLoc := "34" // 3-Posto de enfermagem e 4-Centro Cirurgico
  	cGcyAtOrig := cGcyAtendi
  	cGcyAtendi := "0"
  	Inclui     := .F.
  	nGDOpc     := GD_UPDATE
 EndIf 

 RegToMemory("GCY", .F.)

aGcyAIH := {"GCY_REGATE", "GCY_NOME", "GCY_DTNASC", "GCY_HORATE", "GCY_REGGER", "GCY_SEXO", "GCY_IDADE", "GCY_DATATE","GCY_CODCRM",; 
"GCY_NOMMED","GCY_DESCLI", "GCY_CODCLI",, "GCY_ORIPAC", "GCY_DORIPA", "GCY_DCARAT", "GCY_CARATE", "GCY_REGIME",;
"GCY_NOMRES","GCY_CODRES","GCY_CODEMP", "GCY_CODLOC", "GCY_NOMLOC", "GCY_EMPRES", "GCY_QUAINT", "GCY_LEIINT", "GCY_DATALT",; 
"GCY_HORALT", "GCY_DESALT","GCY_CIDALT", "GCY_DESCID", "GCY_CIDCMP", "GCY_DESCMP","GCY_CIDINT", "GCY_DCIDIN","GCY_ACITRA","GCY_MODAIH", "GCY_CDPREV", "GCY_CNASUS","GCY_DESCNA"}	
 
aCposObr := {"GCY_QUAINT", "GCY_REGIME"} 


If cMV_AteSus= "S"  
	// Campos que nao serao apresentados na tela
	aGcyGe3 := {"GE3_DATAUT", "GE3_HORAUT", "GE3_QTDAUT", "GE3_VALAUT", "GE3_NROAUT", "GE3_SENAUT", "GE3_RESAUT"}
EndIf

If(FunName() == "HSPAHP12" .And. M->GCY_TPALTA <> '99' .And. !Empty(M->GCY_DATALT))
	aCposAlt := {"GCY_MODAIH","GCY_DATALT","GCY_HORALT", "GCY_TPALTA", "GCY_CIDALT", "GCY_CIDCMP", "GCY_CIDCO1", "GCY_CIDCO2", "GCY_CIDINT", "GCY_CRMALT", "GCY_OBSALT", "GCY_OBTDOC", "GCY_CDTIPD", "GCY_DSTIPD", "GCY_CDMOTD", "GCY_NMBENE", "GCY_DSBENE", "GCY_HOSBEN", ;
             	"GCY_AUTJUD","GCY_CODEMP","GCY_ACITRA","GCY_CDPREV", "GCY_CNASUS", "GCY_DESCNA"}
ElseIf(FunName() == "HSPAHP12" .And. M->GCY_TPALTA <> '99') //.And. !Empty(M->GCY_DATALT))
	aCposAlt := {"GCY_CIDCMP", "GCY_CIDINT"}
	//aCposAlt := {"GCY_MODAIH","GCY_TPALTA", "GCY_CIDCMP", "GCY_CIDCO1", "GCY_CIDCO2", "GCY_CIDINT", "GCY_CODEMP","GCY_ACITRA"}	
EndIf

                                                
If aRotina[nOpcAIH, 4] == 3
	&("M->" + SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
Else
	&("M->" + SX3->X3_CAMPO) := IIf(SX3->X3_CONTEXT == "V", CriaVar(SX3->X3_CAMPO), GCY->(FieldGet(GCY->(FieldPos(SX3->X3_CAMPO)))))
EndIf

aCpoGD7 := {"GD7_CODLOC","GD7_NOMLOC","GD7_DATDES","GD7_HORDES","GD7_CODDES","GD7_DDESPE","GD7_CODCRM","GD7_NOMMED", "GD7_DESPRT"}
For nCntFor := 1 To Len(aCpoGD7)
	M->(aCpoGD7[nCntFor]) := aCpoGD7[nCntFor]
Next
                   

 DbSelectArea("SX3")
 DbSetOrder(1) 
 DbSeek("GD7")
 While SX3->(!Eof()) .And. (SX3->X3_ARQUIVO == "GD7" )
 	wVar := "M->" + x3_campo
  	&wVar:= CriaVar(x3_campo) // executa x3_relacao
  	DbSkip()
 EndDo
 
  
 cGcyRegGer := M->GCY_REGGER
 cGbhDtNasc := M->GCY_DTNASC
 cGbhSexo   := M->GCY_SEXO

If aRotina[nOpcAIH, 4] == 3
	If aRotina[nOpcAIH, 3] == 10 // 10-Transferencia do setor ambulatorial para o setor de interna็ใo
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
 
cOldRegAte := M->GCY_REGATE
             
If aRotina[nOpcAIH, 4] <> 3                               
	cCondGcz := "GCZ->GCZ_REGATE == '" + M->GCY_REGATE + "'"
           
  	If FunName() $ "HSPAHP12/HSPAHA80" // Auditoria de contas    
   		cCondGcz += " .And. GCZ->GCZ_NRSEQG == '" + cLctNrSeqG + "'"
  	Else          
   		If aRotina[nOpcAIH, 4] <> 2 //Consultar
    		cCondGcz += " .And. GCZ->GCZ_STATUS == '0'"
   		EndIf 
  	EndIf 
EndIf
 
// Monta aHeader e aCols com informa็๕es do arquivo de GUIAS do atendimento                                                                
cCamposNao := "GCZ_DATATE/GCZ_NOME  "

 /* Nใo Apresenta Campos do APAC, se o plano nใo for APAC */
 If FunName() <> "HSPAHP12" .Or. !(GCZ->GCZ_CODPLA <> __cCodAIH)
 	cCamposNao += "/GCZ_NRSEN2/GCZ_NRSEN3/GCZ_INDCLI/GCZ_CPRAU1/GCZ_DPRAU1/GCZ_CPRAU2/GCZ_DPRAU2/GCZ_CPRAU3/GCZ_DPRAU3/GCZ_CPRAU4/GCZ_DPRAU4" +;
	 			  "/GCZ_CPRAU5/GCZ_DPRAU5/GCZ_CODAUT"
 EndIf
 
/* Nใo Apresenta Campos do AIH, se o plano nใo for AIH */
If FunName() <> "HSPAHP12" .Or. (GCZ->GCZ_CODPLA <> __cCodAIH)
 	cCamposNao += "/GCZ_CMCAIH/GCZ_DMCAIH/GCZ_IDGUIA/GCZ_AIHANT/GCZ_AIHPOS/GCZ_CDCBOR/GCZ_DSCBOR" + ;
	 			  "/GCZ_CDCCNA/GCZ_DESCNA/GCZ_TPVINC/GCZ_RNNVIV/GCZ_RNNOBI/GCZ_RNALTA/GCZ_RNTRAN/GCZ_RNOBIT" + ;
	 			  "/GCZ_CPRAU1/GCZ_DPRAU1/GCZ_CPRAU2/GCZ_DPRAU2/GCZ_CPRAU3/GCZ_DPRAU3/GCZ_CPRAU4/GCZ_DPRAU4" + ;
	 			  "/GCZ_CPRAU5/GCZ_DPRAU5/GCZ_DIASAC/GCZ_DTADIA/GCZ_CPFAUD/GCZ_MESINI/GCZ_MESANT/GCZ_MESALT" + ;
	 			  "/GCZ_IDAUTE/GCZ_CPFGES/GCZ_CODAUT"
 EndIf

 /* Nใo Apresenta Campos do APAC, se o plano nใo for APAC */
 If FunName() <> "HSPAHP12" .Or. !(GCZ->GCZ_CODPLA $ __cCodPAC)
 	cCamposNao += "/GCZ_TPAPAC/GCZ_CMCPAC/GCZ_VGUIAI/GCZ_VGUIAF
 EndIf

 If FunName() <> "HSPAHP12" // Alteracao para nao permitir que sejam lancadas novas guias no atendimento
	If !Empty(M->GCY_TPALTA)
   		nGDOpc := 0
	Endif 
Endif
 
 HS_BDados("GCZ", @aHGCZ, @aCGCZ,, 2, M->GCY_REGATE, IIf(Empty(cCondGcz), Nil, cCondGcz),,,,, cCamposNao,,,,,,,,,,,,,, IIF(aRotina[nOpcAIH, 3] == 10, {"GCZ_CODTPG"}, Nil))
 
 // Faz a alteracao da posicao do Num da Aih para facilitar o cadastro no momento da digitacao
aGczC:= aClone(aHGCZ)  
aDGcz:= aClone(aCGCZ) 
If Len(aHGCZ)>0           
	nPos  := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_NUMAIH"}) 
	If nPos > 0      
		aDel(aHGCZ, nPos)
		For nGuias := 1 To Len(aCGcz)		
			aDel(aCGCZ[nGuias], nPos)			
		Next
	EndIf               

	nPos  := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_NRSEN1"})
	aIns(aHGCZ, nPos)
	nPos2  := aScan(aGczC, {|aVet| aVet[2] == "GCZ_NUMAIH"}) 
	aHGCZ[nPos] := aGczC[nPos2]
		
	For nGuias := 1 To Len(aCGcz)
		aIns(aCGCZ[nGuias], nPos) 
		aCGCZ[nGuias][nPos] := aDGcz[nGuias][nPos2]		
	Next
EndIf

 nGCZNRSEQG := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_NRSEQG"})
 nGCZCODTPG := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_CODTPG"})
 nGCZDESTPG := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_DESTPG"})
 nGCZCODPLA := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_CODPLA"})
 nGCZDESPLA := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_DESPLA"})
 nGCZCODCRM := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_CODCRM"})
 nGCZNOMMED := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_NOMMED"})
 nGczStatus := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_STATUS"})
 nGCZNrGuia := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_NRGUIA"})
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
 nGCZRnnViv := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_RNNVIV"})
 nGCZRnnObi := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_RNNOBI"})
 nGCZRnAlta := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_RNALTA"})
 nGCZRnTran := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_RNTRAN"})
 nGCZRnObit := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_RNOBIT"})
 nGCZSisPre := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_SISAIH"})
 nGCZCPFGES := aScan(aHGCZ, {|aVet| aVet[2] == "GCZ_CPFGES"}) 
               
If aRotina[nOpcAIH, 3] <> 7 .And. cGcyAtendi <> "1" .And. cGcyAtendi <> "3" // 7-Despesas e 1-Atendimento Ambulatorial e 3-Doacao
  	// Monta aHeader e aCols com informa็๕es do arquivo de movimenta็ใo de leito do atendimento
	HS_BDados("GB1", @aHGB1, @aCGB1,, 5, M->GCY_REGATE, "GB1->GB1_REGATE == '" + M->GCY_REGATE + "'")
EndIf 
 
If aRotina[nOpcAIH, 4] == 3                                       
	If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-Interna็ใo                                                

   		// Monta aHeader e aCols com informa็๕es das despesas com procedimentos
   		HS_BDados(cAliasPR, @aHPR, @aCPR,, 2,, Nil, .T.,,,, cCpoNaoPR,,,,,, .T.,,,,,,,, aCpoVisPR)
  	EndIf
  
  	If cGcyAtendi == "0"
   		// Monta aHeader e aCols com informa็๕es das autoriza็๕es de materiais e medicamentos especiais
   		HS_BDados("GE2", @aHGE2, @aCGE2,, 2, "", Nil, .T.)
   		// Monta aHeader e aCols com informa็๕es das autoriza็๕es de materiais e medicamentos especiais
	   HS_BDados("GE3", @aHGE3, @aCGE3,, 2, "", Nil, .T.)
  	EndIf             
  	
Else      
	For nGuias := 1 To Len(aCGcz)
   		If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-Interna็ใo
    		aHTD := {}; aCTD := {}
    		aHPR := {}; aCPR := {}
   
    		IF FunName() == "HSPAHP12" .And. cMV_AteSus == "S"
   	 			HS_INIGSUS(cAliasPr,aCGcz[nGuias, nGczNrSeqG],	aCGcz[nGuias, nGczCodPla])
    		Endif 
    
    		// Monta aHeader e aCols com informa็๕es das despesas com procedimentos                                                                                                                           
    		HS_BDados(cAliasPR, @aHPR, @aCPR,, 2,, cPrefiPR + "_NRSEQG == '" + aCGcz[nGuias, nGczNrSeqG] + IIf(FunName() == "HSPAHP12", "'", "' .And. " + cPrefiPR + "_CODLOC == '" + cLctCodloc + "'"), .T.,,,, cCpoNaoPR,,,,,, .T.,,,,,,,, aCpoVisPR)
    			// Retiro a validacao de obrigatorio pois a procedimento para o AIH q nao terao valor como nos casos de procedimentos de laboratorio                                                                                                                         
    		If Len(aHPR)>0 
       	   		nPos := aScan(aHPR, {|aVet| aVet[2] == "GE7_QTDCHP"})
       	   		If nPos > 0 .And. valtype(aHPR[nPos][17]) == "L"
    				aHPR[nPos][17] := .F.
     			EndIf
 		    EndIf	
   		EndIf
   
   		If cGcyAtendi == "0"
    		aHGE2 := {}; aCGE2 := {}
   		    aHGE3 := {}; aCGE3 := {}
    
    		// Monta aHeader e aCols com informa็๕es das autoriza็๕es de materiais e medicamentos especiais
    		HS_BDados("GE2", @aHGE2, @aCGE2,, 2,, "GE2->GE2_NRSEQG == '" + aCGcz[nGuias, nGczNrSeqG] + "'", .T.)

  	  		// Monta aHeader e aCols com informa็๕es das autoriza็๕es de materiais e medicamentos especiais
   			HS_BDados("GE3", @aHGE3, @aCGE3,, 2,, "GE3->GE3_NRSEQG == '" + aCGcz[nGuias, nGczNrSeqG] + "'", .T.)
           
            // Exclui os campos conforme o Array aGcyGe3 onde estao inseridos os campos que nao devem ser apresentados na tela
            If Len(aHGE3)>0 
           		For nX:= 1 to Len(aGcyGe3) 
        	   		nPos := aScan(aHGE3, {|aVet| aVet[2] == aGcyGe3[nX]})
       		   		If nPos > 0
    					aDel(aHGE3, nPos)
    					aDel(aCGE3[1], nPos)
     				EndIf
	    		Next               	    	
	            aSize(aHGE3,Iif((len(aHGE3) - len(aGcyGe3))>0 ,len(aHGE3) - len(aGcyGe3),1))
   	            aSize(aCGE3[1],len(aHGE3)+1)
		    EndIf	
      	  
   		EndIf
                
   		aAdd(aGczGd, {nGuias, {}, {}, {}, {}, {}, {}})
   
   		If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-Interna็ใo
    		aGczGd[Len(aGczGd), 3] := aClone(aCTD)
    		aGczGd[Len(aGczGd), 4] := aClone(aCPR)
   		EndIf                                  
   
   		If cGcyAtendi == "0"
    		aGczGd[Len(aGczGd), 5] := aClone(aCGE2)
   		    aGczGd[Len(aGczGd), 6] := aClone(aCGE3)
   		EndIf 
  	Next                       
  
  	nAtAnt := Len(aGczGd)
EndIf
                                                                                
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
  nPRCNPJFo := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CNPJFO"})
  nPRNFOpm  := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_NFOPM "})
  nPRLote   := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_LOTOPM"})
  nPRSerie  := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_SEROPM"})
  nPRCNPJFa := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CNPJFA"})
  nPRAnvisa := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_ANVOPM"})
  nCompetD  := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_COMPD "}) 
  nQtdFil   := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_QTFILH"})
  nCIDInd   := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CIDIND"})
  nGrauInst := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_GRINST"})
  nMetContr1:= aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_MCONT1"}) 
  nMetContr2:= aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_MCONT2"}) 
  nGestRis  := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_GESTR "}) 
   
 EndIf
 nPRTABELA := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_TABELA"}) 
 nPRDESPER := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DESPER"}) 
 nPRDESVAL := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DESVAL"}) 
 nPRDESOBS := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DESOBS"})  
 nPRVALTOT := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_VALTOT"}) 
 nPRTOTDSC := aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_TOTDSC"})  
                                                                               
 nGe2StaReg := aScan(aHGE2, {|aVet| aVet[2] == "HSP_STAREG"})
 nGe2CodDes := aScan(aHGE2, {|aVet| aVet[2] == "GE2_CODDES"})
 nGe2DDespe := aScan(aHGE2, {|aVet| aVet[2] == "GE2_DDESPE"}) 
 nGe2QtdAut := aScan(aHGE2, {|aVet| aVet[2] == "GE2_QTDAUT"})
 nGe2QtdSol := aScan(aHGE2, {|aVet| aVet[2] == "GE2_QTDSOL"})
 nGe2SeqDes := aScan(aHGE2, {|aVet| aVet[2] == "GE2_SEQDES"})
 nGe2DatSol := aScan(aHGE2, {|aVet| aVet[2] == "GE2_DATSOL"})
 
 nGe3StaReg := aScan(aHGE3, {|aVet| aVet[2] == "HSP_STAREG"})
 nGe3CodDes := aScan(aHGE3, {|aVet| aVet[2] == "GE3_CODDES"})
 nGe3DDespe := aScan(aHGE3, {|aVet| aVet[2] == "GE3_DDESPE"})
 nGe3CodPrt := aScan(aHGE3, {|aVet| aVet[2] == "GE3_CODPRT"})
 nGe3SeqDes := aScan(aHGE3, {|aVet| aVet[2] == "GE3_SEQDES"})
 nGe3DatSol := aScan(aHGE3, {|aVet| aVet[2] == "GE3_DATSOL"})
 
If !Inclui
	HS_IniPadr("GCY", 1, cOldRegAte, "GCY_NOME",,.F.)
  	cGavModelo := HS_IniPadr("GAV", 1, M->GCY_CODLOC + M->GCY_QUAINT + M->GCY_LEIINT, "GAV_MODELO",,.F.)
EndIf
 
If aRotina[nOpcAIH, 3] == 7 // 7-Guias
	Inclui := .T.
EndIf
  
 
Define MsDialog oDlgAten Title OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd PIXEL
If aRotina[nOpcAIH, 3] == 7 .Or. cGcyAtendi == "1" .Or. cGcyAtendi == "3"// 1-Atendimento Ambulatorial ou 3-Atendimento Doacao
	@ aPFolder[1, 1], aPFolder[1, 2] FOLDER oFolAten SIZE aPFolder[1, 3], aPFolder[1, 4]+10 Pixel OF oDlgAten Prompts STR0025//,"Internacao"//,"Procedimento Realizado" //"&1-Dados Gerais"
Else
	@ aPFolder[1, 1], aPFolder[1, 2] FOLDER oFolAten SIZE aPFolder[1, 3], aPFolder[1, 4]+10 Pixel OF oDlgAten Prompts STR0025, STR0026, STR0087 //"&1-Dados Gerais"###"&2-Mapa de leitos" //"Movimenta็ใo de leito"
EndIf 

// Dados do atendimento
aGets := {}
aTela := {}
oEncGcy := MsMGet():New("GCY", nRegAIH, 7,,,, aGcyAIH, IIF(aRotina[nOpcAIH, 3] <> 4, {aPObjs[1, 1], aPObjs[1, 2]-10, aPObjs[1, 3], aPObjs[1, 4]-04}, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}), aCposAlt, 2,,,, oFolAten:aDialogs[1])
oEncGcy:oBox:Align := CONTROL_ALIGN_TOP
oEncGcy:oBox:bSetGet :=  {|| IIF(SUBSTR(Readvar(),4,3) == "GCY", FS_GrFGcy(), .T.)} 
 	
aGetsGcy := aClone(aGets)
aTelaGcy := aClone(aTela)

 	
// Dados das Guias
If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3",  aRotina[nOpcAIH, 3] <> 7, aRotina[nOpcAIH, 3] <> 4))
    oGDGCZ := MsNewGetDados():New(aPObjs[2, 1]+2, aPObjs[2, 2]-09, aPObjs[2, 3]+2, aPObjs[2, 4]-04, nGDOpc,,,,,, 99999,,,, oFolAten:aDialogs[1], aHGCZ, aCGCZ)
   	oGDGcz:oBrowse:Align := CONTROL_ALIGN_TOP
   	oGDGCZ:bChange  	    := {|| FS_SACols(FunName() == "HSPAHP12")}
   	oGDGCZ:bLinhaOk 	    := {|| FS_VACols()} 
   	oGDGCZ:oBrowse:bGotFocus :=  {|| FS_GczGFoc()} 
   	oGDGCZ:oBrowse:bLostFocus := {|| FS_GczLFoc()} 
   	oGDGCZ:oBrowse:bDelete := {|| IIF(FS_VldGuia(), oGDGCZ:DelLine(), Nil)}
  
	If cGcyAtendi == "0" // 0-Interna็ใo        
    	If lOrigemExt 
     		@ aPObjs[3, 1]+04, aPObjs[3, 2]-09 FOLDER oFolDesp SIZE aPObjs[3, 3]+04, aPObjs[3, 4]-10 Pixel OF oFolAten:aDialogs[1] Prompts  STR0027 //"&3-Procedimentos"
    	EndIf 
   	EndIF                                                                                         
   	oFolDesp:Align := CONTROL_ALIGN_ALLCLIENT
 	If aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&3-"}) > 0   
 	   aAdd(aOPesq, {"oGDPR", "03"})
    	oGDPR := MsNewGetDados():New(aPDesp[1, 1], aPDesp[1, 2], aPDesp[1, 3], aPDesp[1, 4], nGDOpc,,,,, /*nFreeze*/, 99999,,,, oFolDesp:aDialogs[aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&3-"})], aHPR, aCPR)
    	oGDPR:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT
    	If aRotina[nOpcAIH, 4] == 3 .Or. aRotina[nOpcAIH, 4] == 4
     		oGDPR:oBrowse:bLostFocus := {|| FS_PRLFoc()}
		    oGDPR:oBrowse:bGotFocus  := {|| FS_PRGFoc(oGDPr)}
     		oGDPR:bChange            := {|| FS_PRGFoc(oGDPr), FS_ChgGD(oGDPR, nPRCodLoc)}
     		oGDPR:oBrowse:bAdd       := {|| FS_AddLin( oGDPr, nPRCodLoc, nPRNomLoc, nPrDatDes, nPrHordes ) }
       		oGDPR:bLinhaOk           := {|| IIF(oGDPR:aCols[oGDPR:nAt, nPRStareg] <> "BR_VERDE", !EMPTY(oGDPR:aCols[oGDPR:nAt, nPRCODDES]) .And. HS_VDatDes(oGDPR:aCols[oGDPR:nAt, nPRDatDes],SUBSTR(oGDPR:aCols[oGDPR:nAt, nPRHorDes], 1, 5)),.T.) .And. FS_PRLiOk() .And. HS_SLaudo(.T.) .And. ;
                                     HS_VldPLS(HS_IniPadR("GD4", 1, M->GCY_REGGER + oGDGcz:aCols[oGDGcz:nAt, nGCZCODPLA], "GD4_MATRIC",, .F.), ;
                                              M->GCY_NOME, M->GCY_DTNASC, oGDGcz:aCols[oGDGcz:nAt, nGCZCODPLA], oGDPR:aCols[oGDPR:nAt, nPRCODDES], ; 
                                              oGDPR:aCols[oGDPR:nAt, nPRQtdDes], oGDPR:aCols[oGDPR:nAt, nPRDatDes], oGDPR:aCols[oGDPR:nAt, nPRHorDes], ;
                                              M->GCY_CIDINT, HS_IniPadR("GA7", 1, oGDPR:aCols[oGDPR:nAt, nPRCODDES], "GA7_CODESP",, .F.), ;
                                              oGDPR:aCols[oGDPR:nAt, nPRCodCRM], oGDPR:aCols[oGDPR:nAt, nPRCodCRM])}
                                          
     		oGDPR:cFieldOk           := "HS_PRFiOk() .And. HS_GDAtrib(oGDPR, {{nPRStaReg, 'BR_AMARELO', 'BR_VERDE'}})"
     		oGDPR:oBrowse:bDelete    := {|| HS_GDAtrib(oGDPR, {{nPRStaReg, "BR_CINZA", "BR_VERDE"}}), Iif(HS_DelInci() .And. HS_VExcLau(),{oGDPr:DelLine(),oGDPr:oBrowse:Refresh()},Nil)}
    	EndIf
   EndIf
EndIf  
 
   If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3",  aRotina[nOpcAIH, 3] <> 7, aRotina[nOpcAIH, 3] <> 4))
   oPPesq	:=	tPanel():New(aPObjs[4, 1], aPObjs[4, 2],, oFolAten:aDialogs[1],,,,,, aPObjs[4, 3], aPObjs[4, 4])
   oPPesq:Align := CONTROL_ALIGN_BOTTOM  

   aSort(aOPesq,,, {| X, Y | X[2] < Y[2]})
   oFolDesp:bChange:= {|| HS_GDPesqu(,, &(aOPesq[oFolDesp:nOption, 1]), oPPesq, 001, .T.) }
  
   HS_GDPesqu(,, &(aOPesq[oFolDesp:nOption, 1]), oPPesq, 001, .T.)
  EndIf
  
 Activate MsDialog oDlgAten ON INIT {IIF(StrZero(aRotina[nOpcAIH, 3], 2) $ IIF(cGcyAtendi == "2", "03", "03/13") .And. lNewDayAte, ChkNewDay(@oDlgAten, .F., "HS_CposM24", .T.), Nil), ;
                                     EnChoiceBar(oDlgAten, {|| nOpcAten := 1, IIf(FS_AtenOk(aGetsGcy, aTelaGcy, nOpcAIH, aCposObr), oDlgAten:End(), nOpcAten := 0)}, ;
                                                           {|| nOpcAten := 0, oDlgAten:End()},, aBtnBar), ;
                                     IIf(IIF(aRotina[nOpcAIH, 3] == 7, FS_GczGFoc(), .T.) .And. !FS_LstAgd(nOpcAIH), oDlgAten:End(), .T.)}

If aRotina[nOpcAIH, 3] == 7
	Inclui := .T.
EndIf

IF nOpcAten == 0
	FS_RetLei()

	While __lSx8
   		RollBackSxe()
  	End            
Else  
	If aRotina[nOpcAIH, 4] # 2 // Caso nใo seja consulta entra na fun็ใo de grava็ใo
   		If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3",  aRotina[nOpcAIH, 3] <> 7, aRotina[nOpcAIH, 3] <> 4))
    		If (nPosGD := aScan(aGczGd, {| aVet | aVet[1] == oGDGcz:nAt})) == 0
     			aAdd(aGczGd, {oGDGcz:nAt, {}, {}, {}, {}, {}, {}})
     			nPosGD := Len(aGczGd)
    		EndIf
           
    		If aRotina[nOpcAIH, 4] == 3 .And. dDataBase <> Date() 
     			If MsgYesNo(STR0285, STR0034) //"Deseja gravar o atendimento com a data retroativa?"###"Aten็ใo"
      				dDatAte := dDataBase
     			Else
      				dDatAte := Date()
      				HS_CposM24(dDatAte, .F.)
     			EndIf
    		Else
     			dDatAte := M->GCY_DATATE
    		EndIf  

    		If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-Interna็ใo        
     			aGczGd[nPosGD, 4] := aClone(oGDPR:aCols) 
    		EndIf

	    	For nForGuia := 1 To Len(aGczGD)
	     		aCDesp := aClone(aGczGD[nForGuia, 2])	    	
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
	 		   		Execblock("HSM24BTR", .F., .F.,{nOpcAIH})
	 	   		EndIf
	   
	     		FS_GrvAIH(nOpcAIH, cRegAteOri)
	     
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
	    
	       	End Transaction 
	  
	    	While __lSx8
	     		ConfirmSx8()
	    	End  
	   
	    	lFichas := .F.           
	    	If cGcyAtendi == "0"    //Internacao
	     		If nOpcAIH == 3 .Or. nOpcAIH == 13
	      			lFichas := .T.
	     		EndIf
	    	ElseIf cGcyAtendi == "1"  //Ambulatorio
	     		If nOpcAIH == 3 .Or. nOpcAIH == 13
	      			lFichas := .T.
	     		EndIf    
	    	ElseIf cGcyAtendi == "2"   //Pronto Atendimento
	     		If nOpcAIH == 3 
	      			lFichas := .T.
	     		EndIf      
	    	ElseIf cGcyAtendi == "3"   //Atendimento Doacao
	     		If aRotina[nOpcAIH, 4] == 3 .Or. aRotina[nOpcAIH, 4] == 13
	      			lFichas := .T.
	     		EndIf                        
	    	EndIf 
	   
	    	If lFichas 
	     		GDN->(dbSetOrder(1))
	     		If GDN->(DbSeek(xFilial("GDN") + M->GCY_LOCATE))
	  	 			 HSPAHP44(.T., GCY->GCY_LOCATE, {{"GBH", 1, M->GCY_REGGER}})
	  			EndIf
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

If StrZero(nOpcAIH, 2) $ "08/10"
	MBrChgLoop(.F.)
EndIf

If ((Type("__aGeISol") # "U" .AND. Len(__aGeISol) > 0) .OR. (Type("__aGeMSol") # "U" .AND. Len(__aGeMSol) > 0))   .AND. nOpcAten <> 0
	FS_GrvSol(M->GCY_REGATE,__aGeISol,__aGeMSol)
EndIf

Return(nOpcAten == 1)   


Static Function FS_RetLei()
 Local cAliasOld := Alias()
 
 If Inclui
  UnLockByName(xFilial("GAV") + cOldCodLoc + cOldQuaInt + cOldLeiInt, .T., .T., .F.)
  UnLockByName(xFilial("GAV") + M->GCY_CODLOC + M->GCY_QUAINT + M->GCY_LEIINT, .T., .T., .F.)
 Endif                  
 
 DbSelectarea(cAliasOld)
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHAIH  บAutor  ณMicrosiga           บ Data ณ  12/19/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_SACols(lBloqDesp)
 Local nPosACols := 0, nForGD := 0, cAliasOld := Alias()
 
 Default lBloqDesp := .F.
 
If lBloqDesp
	oGDGcz:lUpdate := oGDGcz:aCols[oGDGcz:nAt, nGCZSTATUS] <= "2"
  	oGDGcz:lDelete := oGDGcz:aCols[oGDGcz:nAt, nGCZSTATUS] <= "2" 
  
  	oGDPR:lActive  := oGDGcz:aCols[oGDGcz:nAt, nGCZSTATUS] <= "2"
  	oGDPR:lInsert  := EMPTY(oGDGcz:aCols[oGDGcz:nAt, nGCZNUMORC])  
  	oGDPR:lUpdate  := EMPTY(oGDGcz:aCols[oGDGcz:nAt, nGCZNUMORC])
	oGDPR:lDelete  := EMPTY(oGDGcz:aCols[oGDGcz:nAt, nGCZNUMORC])
     
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
 
If aScan(oFolDesp:aPrompts, {| cVet | SubStr(cVet, 1, 3) == "&5-"}) > 0 .And. GCU->GCU_TAXDIA == "0"
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
   		aGczGd[nPosACols, 4] := aClone(oGDPR:aCols)
  	EndIf
 
  	If (nPosACols := aScan(aGczGd, {| aVet | aVet[1] == oGDGcz:nAt})) > 0
   		If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-Internacao
       		oGDPR:SetArray(aGczGd[nPosACols, 4])
   		EndIf               
	   
  	Else                                
   		If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-Internacao
    		oGDPR:aCols := {}
    		oGDPR:AddLine(.T., .F.)
    		oGDPR:lNewLine := .F.    
   		EndIf 
            
	EndIf   
                                      
	If cGcyAtendi # "0"  .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-Internacao
   		oGDPR:oBrowse:Refresh()
  	EndIf
  
  	nAtAnt := oGDGcz:nAt                                 
EndIf 
 
DbSelectArea(cAliasOld)
Return(.T.)           


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHAIH  บAutor  ณMicrosiga           บ Data ณ  12/19/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function FS_PRGFoc(oGDPr)
cGbjCodEsp := oGDPR:aCols[oGDPR:nAt, nPRCODESP]
__dDataVig := oGDPR:aCols[oGDPR:nAt, nPRDatDes]
__cHoraAtu := oGDPR:aCols[oGDPR:nAt, nPRHorDes]
cGA7CodPro := oGDPR:aCols[oGDPR:nAt, nPRCODDES]  
cObsCodCrm := oGDPR:aCols[oGDPR:nAt, nPRCodCrm] 
oObjFocus  := oGDPr
cGbjTipPro := ""
cGbjTipAut := ""
cCondAtrib := "(nPRCodVia > 0 .And. IIf(SubStr(ReadVar(), 7) == '_CODVIA', !Empty(&(ReadVar())), !Empty(oGetDados:aCols[oGetDados:nAt, nPRCodVia])) .And. !Empty(oGetDados:aCols[__nAtGD, nPRCodVia])) .Or. " + ;
               "(nPRSPrinc > 0 .And. !Empty(oGetDados:aCols[oGetDados:nAt, nPRSPrinc]) .And. oGetDados:aCols[oGetDados:nAt, nPRSPrinc] == oGetDados:aCols[__nAtGD, nPRSPrinc])"
Return(.T.)
               

Static Function FS_ChgGD(oDesp, nCodLoc)
  
If nCodLoc > 0
	HS_DefVar("GCS", 1, oDesp:aCols[oDesp:nAt, nCodLoc], {{"cGcsCodLoc", "GCS->GCS_CODLOC"}, ;
                                                        {"cGcsCodCCu", "GCS->GCS_CODCCU"}, ;
                                                        {"cGcsArmSet", "GCS->GCS_ARMSET"}, ;
                                                        {"cGcsArmFar", "GCS->GCS_ARMFAR"}})
EndIf 
 
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHAIH  บAutor  ณMicrosiga           บ Data ณ  12/19/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_GczGFoc()

cGbjCodEsp := Space(Len(GBJ->GBJ_ESPEC1))
cGbjTipPro := "0127"
cGbjTipAut := "8"
cObsCodCrm := oGDGcz:aCols[oGDGcz:nAt, nGCZCodCrm] 
If ValType("M->GCY_LOCATE") # "U" 
	cGcsCodLoc := M->GCY_LOCATE
EndIf 
 oObjFocus  := oGDGcz

Return(.T.)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHAIH  บAutor  ณMicrosiga           บ Data ณ  12/19/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_GczLFoc()

cGbjTipPro := SPACE(LEN(GBJ->GBJ_TIPPRO))
cGbjTipAut := SPACE(LEN(GBJ->GBJ_TIPPRO))
If ValType("M->GCY_CODLOC") # "U" 
	cGcsCodLoc := M->GCY_CODLOC
EndIf 

Return(Nil)
                               
Static Function FS_LstAgd(nOpcAIH)
  // Agenda ambulatorial, Cirurgica e Doacao
  If cGcyAtendi == "1" .And. aRotina[nOpcAIH, 3] == 3 .Or. ; // 3-Recep็ใo da agenda ambulatorial
     cGcyAtendi == "0" .And. aRotina[nOpcAIH, 3] == 3 .Or. ; // 3-Recep็ใo Cirurgica
     cGcyAtendi == "3" .And. aRotina[nOpcAIH, 3] == 3        // 3-Doacao     
   If !HS_LstAgd(cM24Par01, dDataBase, IIf(cGcyAtendi == "0", "GMJ", "GM8")) // Busca pacientes agendados.
    Return(.F.)
   EndIf       
   oEncGcy:Refresh()
  EndIf
Return(.T.)  

Static Function FS_PRLFoc()
 cGbjCodEsp := Space(Len(GBJ->GBJ_ESPEC1))
 cCondAtrib := ""
Return(Nil)

Static Function FS_PRLiOk()
 Local lRet := .F., cAliasOld := Alias()
 Local aTabPre := HS_RTabPre("GC6", cGczCodPla, oGDPR:aCols[oGDPR:nAt, nPRCodDes], oGDPR:aCols[oGDPR:nAt, nPRDatDes])
 Local cCodPan := "", nQtdAux := 0
 
 If Len(aTabPre) > 0
  cCodPan := HS_CodPan(oGDPR:aCols[oGDPR:nAt, nPRCodDes], aTabPre[1], oGDPR:aCols[oGDPR:nAt, nPRDatDes]) // Codigo do Porte Anestesico
  nQtdAux := HS_QtdAux(oGDPR:aCols[oGDPR:nAt, nPRCodDes], aTabPre[1], oGDPR:aCols[oGDPR:nAt, nPRDatDes]) // Quantidade de auxiliares
 EndIf
 
 If !(lRet := !((!Empty(cCodPan) .Or. nQtdAux > 0) .And. Empty(oGDPR:aCols[oGDPR:nAt, nPRCodAto])))
  HS_MsgInf(STR0073, STR0034, STR0147) //"O c๓digo do ato m้dico ้ obrigat๓rio para procedimentos cir๚rgicos."###"Aten็ใo"###"Valida็ใo do ato m้dico"	
 EndIf
 	 
 DbSelectArea(cAliasOld)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHAIH  บAutor  ณMicrosiga           บ Data ณ  12/19/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_VACols()
 Local lRet := .T.,lRetTD := .T., lRetPR := .T.
                         
 If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-Interna็ใo
 
	If lRetTD .And. (!Empty(oGDPR:aCols[1, nPRCODDES]) .Or. Len(oGDPR:aCols) > 1)
   		lRetPR := oGDPR:TudoOk()
  	EndIf                      
  
  	lRet := lRetPR
 EndIf 
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_AddLin บAutor  ณMario Arizono       บ Data ณ  11/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFun็ใo para replicar data, hora e setor da linha anterior   บฑฑ 
ฑฑบ           para nova linha adicionada.                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 

Static Function FS_AddLin(oGet, nCodLoc, nNomLoc, nDatDes, nHordes)
 oGet:AddLine(.T., .F.)
 If len(oGet:aCols) > 0
  If nCodLoc > 0
   oGet:aCols[oGet:nAt, nCodLoc] := oGet:aCols[oGet:nAt - 1, nCodLoc]
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHAIH  บAutor  ณMicrosiga           บ Data ณ  12/19/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_GrFGcy()
 cObsCodCrm := M->GCY_CODCRM 
 oObjFocus  := oEncGcy
Return(.T.)     

Static Function FS_AtenOk(aGetsGcy, aTelaGcy, nOpcAIH, aCposObr)
 Local cAliasOld := Alias(), lRet := .F., nCObr := 0, cHspMsg := "", aCposSx3 := {}, nTipD := 0
 Local cMvIdMin := GETMV("MV_IDMIN")
 Local nMvIdMax := GETMV("MV_IDMAX")
 Local nContGcz := 0     
 
 If lRet := Obrigatorio(aGetsGcy, aTelaGcy)
  If Len(aCposObr) > 0
   For nCObr := 1 To Len(aCposObr)
    If Empty(&("M->" + aCposObr[nCObr]))
     aCposSx3 := HS_CfgSx3(aCposObr[nCObr])
     If !Empty(aCposSx3[SX3->(FieldPos("X3_FOLDER"))])
      DbSelectArea("SXA")
      DbSetOrder(1)                                 
      DbSeek("GCY" + aCposSx3[SX3->(FieldPos("X3_FOLDER"))])
      cHlpMsg := STR0071 + AllTrim(aCposSx3[SX3->(FieldPos("X3_DESCRIC"))]) + "] " + Chr(13) + Chr(10) //"Campo obrigat๓rio ["
      cHlpMsg += STR0072 + AllTrim(SXA->XA_DESCRIC) + "]" //"Pasta ["
     Else                                                 
      cHlpMsg := STR0071 + AllTrim(aCposSx3[SX3->(FieldPos("X3_DESCRIC"))]) + "]" //"Campo obrigat๓rio ["
     EndIf
      
     HS_MsgInf(cHlpMsg, STR0034, STR0121)//"Aten็ใo"###"Valida็ใo de campos" 
     lRet := .F.
     Exit
    EndIf
   Next
  EndIf
 
  If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3", aRotina[nOpcAIH, 3] <> 7, aRotina[nOpcAIH, 3] <> 4 ))
     If aRotina[nOpcAIH, 3] # 10 .And. lRet
    lRet := oGDGCZ:TudoOk() .And. FS_VACols()
   EndIf 
  EndIf 
   
 EndIf 
 
 If cGcyAtendi == "3"
 	If lAutoriz
   		If Empty(M->GCY_AUTJUD)                                        
    		HS_MsgInf(STR0174, STR0034, STR0175)//"O c๓digo da autoriza็ใo judicial deve ser preenchido."###"Aten็ใo"###"Valida็ใo da Autoriza็ใo"
    		lRet := .F.
   		EndIf 
  	ElseIf Val(Substr(M->GCY_IDADE, 1, 3)) < cMvIdMin  
   		HS_MsgInf(STR0172, STR0034, STR0173)//"O doador ้ menor de idade. O atendimento nใo pode ser confirmado."###"Aten็ใo"###"Validaใo de Idade"  
   		lRet := .F.
  	EndIf 
  
  	If M->GCY_CDMOTD $ "1/3" .And. Empty(M->GCY_DSBENE) .And. Empty(M->GCY_HOSBEN)
   		HS_MsgInf(STR0182, STR0034, STR0121) //"Preencha os campos Beneficiแrio e Hospital."###"Aten็ใo"###"Valida็ใo dos campos"
   		Return(.F.)
  	ElseIf M->GCY_CDMOTD == "2" .And. Empty(M->GCY_NMBENE) .And. Empty(M->GCY_DSBENE)
   		HS_MsgInf(STR0209, STR0034, STR0121) //"Preencha os campos c๓digo beneficiแrio e beneficiแrio."###"Aten็ใo"###"Valida็ใo dos campos"
   		Return(.F.)   
  	EndIf  
  
  	If (Val(Substr(M->GCY_IDADE, 1, 3)) > nMvIdMax) .And. (M->GCY_NMBENE <> M->GCY_REGGER)
   		HS_MsgInf(STR0178, STR0034, STR0173)//"Aten็ใo o doador ultrapassa a idade mแxima permitida para doa็ใo."###"Aten็ใo"###"Valida็ใo de Idade"   
   		Return(.F.)
  	EndIf
  
  	If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3",  aRotina[nOpcAIH, 3] <> 7, aRotina[nOpcAIH, 3] <> 4))
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
 
 If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3",  aRotina[nOpcAIH, 3] <> 7, aRotina[nOpcAIH, 3] <> 4)) .And. lRet
		For nContGcz := 1 to Len(oGDGcz:aCols) 
 
	   //Atribui็ใo da Variavel M->GCZ_NRGUIA para uso da Rotina HS_VLDGUI
		  If (FunName() <> "HSPAHP12" .And. !(oGDGcz:aCols[nContGcz, nGczCodPla] $ __cCodBPA+"/"+__cCodPAC+"/"+__cCodAIH)) ;
		   .Or. (FunName() $ "HSPAHP12" .And. oGDGcz:aCols[nContGcz, nGczCodPla] # __cCodBPA) 
		   If (!empty(oGDGcz:aCols[nContGcz, nGCZCODPLA]))
		    M->GCZ_NRGUIA := oGDGcz:aCols[nContGcz, nGCZNrGuia]
		    If !HS_VLDGUI(oGDGcz:aCols[nContGcz, nGCZCODPLA])  
		     Return(.F.)
		    EndIf  
		   EndIf 
		  EndIf 
  
	 Next nContGcz
	EndIf
	
 	 
 DbSelectArea(cAliasOld)
 
Return(lRet)                                    

Static Function FS_GrvAIH(nOpcAIH, cRegAteOri) 

 If aRotina[nOpcAIH, 4] == 3 // Incluisใo
 
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
 RecLock("GCY", aRotina[nOpcAIH, 4] == 3)
  HS_GrvCpo("GCY")
  GCY->GCY_CODUSU := cUsu
  If aRotina[nOpcAIH, 4] == 3
   GCY->GCY_DATATE := dDatAte
  EndIf 
 MsUnLock()
 
 If cGcyAtendi == "3"
  FS_GrvCol(nOpcAIH) // Gera Coleta
  If aRotina[nOpcAIH, 3] == 13
   FS_GrvDado(M->GCY_REGGER, nOpcAIH) //Grava dados do hist๓rico
  EndIf 
 EndIf
 
 If (cGcyAtendi == "1" .And. aRotina[nOpcAIH, 4] == 3) // 3-Agenda Ambulatorial
  DbSelectArea("GM8")
  DbSetOrder(1)
  If DbSeek(xFilial("GM8") + cAgdCodAge) //GM8/1
   RecLock("GM8", .F.)
    GM8->GM8_STATUS := "3" // Atendido
    GM8->GM8_REGATE := M->GCY_REGATE
   MsUnLock()
  EndIf
 ElseIf (cGcyAtendi == "0" .And. aRotina[nOpcAIH, 4] == 3) // 3-Agenda Cirurgica
  DbSelectArea("GMJ")
  DbSetOrder(1)
  If DbSeek(xFilial("GMJ") + cAgdCodAge) //GMJ/1
   RecLock("GMJ", .F.)
    GMJ->GMJ_STATUS := "3" // Atendido
    GMJ->GMJ_REGATE := M->GCY_REGATE
   MsUnLock()
  EndIf
 Endif
 
 // 4-Altera็ใo 
 // 10-Transferencia de Leito(Interna็ใo) ou Tranferencia AMB/PA para interna็ใo
  If (IIF(FunName() <> "HSPAHP12" .And. cGcyAtendi == "3",  aRotina[nOpcAIH, 3] <> 7, aRotina[nOpcAIH, 3] <> 4))
  If StrZero(aRotina[nOpcAIH, 3],2) <> "04" 
   FS_GrvGuia(aRotina[nOpcAIH, 4] == 3, nOpcAIH)
  EndIf 
 EndIf 
 
 If cGcyAtendi <> "1" // Atendimento Ambulatorial      
  If (aRotina[nOpcAIH, 4] == 3 .OR. aRotina[nOpcAIH, 4] == 4) .And. !Empty(M->GCY_CODLOC) .And. !Empty(M->GCY_QUAINT)
   DbSelectArea("GAV")
   DbSetOrder(1)
   If DbSeek(xFilial("GAV") + M->GCY_CODLOC + M->GCY_QUAINT + M->GCY_LEIINT) 
    If aRotina[nOpcAIH, 4] == 3 .Or. aRotina[nOpcAIH, 3] == 4 //Inclusao ou opcao = Alterar
     HS_GrvMovH(M->GCY_REGATE, M->GCY_CODLOC, M->GCY_QUAINT, M->GCY_LEIINT, IIF(aRotina[nOpcAIH, 4] == 3,"0","9") , M->GCY_DATATE, M->GCY_HORATE,,,,, .F.) 
    EndIf
   EndIf
  EndIf
 EndIf                   
       
 If aRotina[nOpcAIH, 4] == 3 // Inclusใo 
  HS_GEndPro(M->GCY_LOCATE, M->GCY_REGGER, M->cGcyAtendi)
 EndIf 
 
 If aRotina[nOpcAIH, 3] == 10 //transferencia, da alta no atendimento original
  DbSelectArea("GCY")
  DbSetOrder(1)
  DbSeek(xFilial("GCY") + cRegAteOri)
  RecLock("GCY", .F.)
   GCY->GCY_ATEDST := M->GCY_REGATE
  MsUnLock()
  HS_AltM24()
 EndIf
 
Return(Nil)       

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvGuiaบ Autor ณ Jose Orfeu         บ Data ณ  18/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava guias do atendimento                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvGuia(lInclui, nOpcAIH)
 Local nForGcz := 0, cAliasOld := Alias(), nPosGD := 0, lFound := .F., nPosGPar := 0 
 Local aCtrlVias := {}, aIncide := {}, aDespExcec := {{cAliasPR, {}}}, cGa9TipCon := ""
 Local nUGcz := Len(oGDGcz:aHeader) + 1
 Local nPGuia,nForVDes := 0
 Local cCoddes   := " "
 
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
    
    If (oGDGcz:aCols[nForGcz, nGCZCODPLA] $ __cCodPAC).And.(Empty(GCZ->GCZ_VGUIAI)).And.(Empty(GCZ->GCZ_VGUIAF))
     GCZ->GCZ_VGUIAI := M->GCY_DATATE 
     GCZ->GCZ_VGUIAF := M->GCY_DATATE + nMv_VldGui    
    EndIf
   
    GCZ->GCZ_CODCON := HS_IniPadr("GCM", 2, oGDGcz:aCols[nForGcz, nGCZCODPLA], "GCM_CODCON",,.F.)
                   
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
   
   If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-Interna็ใo                        
    If (cGa9TipCon := HS_RCfgCP(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, "_TIPCON")) == "1" // 1-Particular
     nPosGPar := nPosGD
    EndIf
    
    HS_GrvGD(cAliasPR, 1, nPosGD, 4, oGDPR:aHeader, "M->" + PrefixoCpo(cAliasPR) + "_SEQDES", lInclui, nPRSeqDes, nPRCodDes, nPRCodLoc, @aCtrlVias, @aDespExcec, cGa9TipCon, nPRStaReg, ,@aIncide)
   EndIf

 Else        
   If lFound
    If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-Interna็ใo
     FS_DelGD(cAliasPR, 2, GCZ->GCZ_NRSEQG, cPrefiPR + "_NRSEQG == '" + GCZ->GCZ_NRSEQG + "'")
    EndIf
    
    If cGcyAtendi == "0"
     FS_DelGD("GE2", 2, GCZ->GCZ_NRSEQG, "GE2->GE2_NRSEQG == '" + GCZ->GCZ_NRSEQG + "'")
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
  
 // Caso tenha despesas que estใo definidas como exce็ใo para o convenio da guia 
 // cria uma nova guia com convenio definido como particular para lan็ar as despesas
 // aDespExcec := {{cAliasMM, {}}, {cAliasTD, {}}, {cAliasPR, {}}}
 If (Len(aDespExcec[1][2]) > 0 ) .And. ;
    (cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt)) // 0-Interna็ใo
  If nPosGPar > 0 .Or. HS_IGuiaP(M->GCY_REGATE, M->GCY_REGGER, "0", M->GCY_ATENDI, M->GCY_DATATE, M->GCY_LOCATE)
                       
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
   
   aGczGd[nPosGPar, 2] := aClone(aDespExcec[1][2]) // Procedimentos

   HS_GrvGD(cAliasPR, 1, nPosGPar, 4, oGDPR:aHeader, "M->" + PrefixoCpo(cAliasPR) + "_SEQDES", lInclui, nPRSeqDes, nPRCodDes, nPRCodLoc, @aCtrlVias,,, nPrStaReg, ,@aIncide)
  EndIf 
 EndIf
                    
 If cGcyAtendi # "0" .Or. (cGcyAtendi == "0" .And. lOrigemExt) // 0-Interna็ใo
  HS_CalcVias(aCtrlVias, cAliasPR, {1, IIf(cAliasPr == "GD7", 5, 7)}, .T., aIncide) // Efetua calculo de vias
 EndIf
                

 DbSelectArea(cAliasOld)
Return(Nil)   

Static Function FS_DelGD(cAlias, nOrdem, cChave, cCond)
 cCond := StrTran(cCond, cAlias + "->", "")
 cCond := StrTran(cCond, "==", "=")
 cCond := StrTran(cCond, ".", "")
 TCSQLExec("UPDATE " + RetSqlName(cAlias) + " SET D_E_L_E_T_ = '*' WHERE " + PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial(cAlias) + "' AND " + cCond)
Return(Nil)                          

    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHAIH  บAutor  ณMicrosiga           บ Data ณ  01/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

// Valida็๕es de todos os campos dos atendimentos
Function HS_VldAIH(cChave, nVld, lVldEmpty, cCpoDesc, dDataMM, lMsg, lRetorno)
 Local lRet := .T., cAliasOld := Alias(), cSexoQuarto := "", aRet := {}, nCont := 0, nPosDes := 0, cOldReadV := "", nTab := 0, nPos := 0
 Local aRVldVig	:= {{ 0, IIf(cGcyAtendi == "1", "GC1_NDIASR", "GC1_NDIASP")}, ;
                    {"", IIf(cGcyAtendi == "0", "GC1_TPGINT", IIf(cGcyAtendi == "1", "GC1_TPGAMB", "GC1_TPGPAT"))},;
                    {"", IIf(cGcyAtendi == "1", "GC1_HORRTA", "GC1_HORRTP")}}
                    
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
 Local cVldCrm := "", cVldUsr := ""
 Local cHoraMM := ""
 Local  aTabs := {"PR", "TD"}                    
 Local  oObj  
 Local cGA1Cod := ""
 Local cMvPRPARTO := GetMV("MV_PRPARTO")

 
 Default lMsg := .T.
 Default lRetorno := .F.
 
 If lRetorno
  aRVldVig[2][2] := "GC1_TPGRET"            
 EndIf           
 
 If nVld == 1 // Valida็ใo do Setor
  lRet := IIf(Empty(cChave) .And. !lVldEmpty, .T., HS_VldCSet(cChave, IIf(cCpoDesc == Nil, "M->GCY_NOMLOC", cCpoDesc), cGcsTipLoc, HS_RDescrB("GCY_ATENDI", cGcyAtendi)))
  If !lFilGm1
   If Empty(cChave)
    M->GCY_QUAINT := Space(Len(GCY->GCY_LEIINT))
    M->GCY_LEIINT := Space(Len(GCY->GCY_LEIINT))
   EndIf 
   HS_VldAIH(, 9)
  EndIf 
 ElseIf nVld == 2 // Valida็ใo da data de nascimento do paciente
  cGbhDtNasc := M->GCY_DTNASC
  lRet := .T.
 ElseIf nVld == 3 // Valida็ใo do sexo do paciente         
  If (lRet := Vazio()) .Or. (lRet := Pertence("01"))
   cGbhSexo := M->GCY_SEXO
  EndIf   
 ElseIf nVld == 4 // Valida็ใo do prontuแrio do paciente 
  IF     lRet := Empty(M->GCY_REGGER)
	  HS_MsgInf(STR0035, STR0034, STR0134) //"O prontuแrio ้ obrigat๓rio."###"Aten็ใo"###"Valida็ใo do Prontuแrio"
  ElseIf !(lRet := HS_SeekRet("GBH", "M->GCY_REGGER", 1, .F.,,,,, .T.))
   HS_MsgInf(STR0036, STR0034, STR0134) //"Prontuแrio nใo encontrado."###"Aten็ใo"###"Valida็ใo do Prontuแrio"
  ElseIf (lRet := IIf(cGCYAtendi <> "3", HS_VAltPac(M->GCY_REGGER), .T.) )
   If cGcyAtendi == "3" // 3-Doacao
    DbSelectArea("GBH")
    DbSetOrder(1) // GBH_FILIAL + GBH_CODPAC
    DbSeek(xFilial("GBH") + M->GCY_REGGER)
    cIdade := HS_A58Age(GBH->GBH_DTNASC)
    cSexo  := GBH->GBH_SEXO
    If Empty(nMvIdMin)
     HS_MsgInf(STR0181, STR0034, STR0173)//"Por favor preencha o parโmetro que indica a idade mํnima para doa็ใo."###"Aten็ใo"###"Valida็ใo da Idade"
     Return(.F.)
    ElseIf lRet := Val(Substr(cIdade, 1, 3)) < nMvIdMin
     If lAutoriz := MsgYesNo(STR0180, STR0173)//"O doador ้ menor de idade. Deseja autorizแ-lo?"###"Valida็ใo de Idade"   
      If !FS_Login()
       Return(.F.)
      EndIf
     EndIf
    ElseIf Empty(nMvIdMax)
     HS_MsgInf(STR0179, STR0034, STR0173)//"Por favor preencha o parโmetro que indica a idade mแxima para doa็ใo."###"Aten็ใo"###"Valida็ใo da Idade"
     Return(.F.)
    ElseIf lRet := Val(Substr(cIdade, 1, 3)) > nMvIdMax
     If lAutoriz := MsgYesNo(STR0203, STR0173)//"Aten็ใo o doador ultrapassa a idade mแxima permitida para doa็ใo. Deseja Autorizแ-lo."###"Valida็ใo de Idade"
      If !FS_Login()
       Return(.F.)
      EndIf
     EndIf
    EndIf

   EndIf  
  
   DbSelectArea("GD4")
   If cGcyAtendi == "3" //Doacao
   
    cMVDoaPlPd := AllTrim(GetMV("MV_DOAPLPD"))
    DbSetOrder(4) // Procurar por plano padrao para doa็ใo
   	If DbSeek(xFilial("GD4") + M->GCY_REGGER + "1") // pega convenio/plano padrao do paciente
   	 If !HS_VPlaSet(cGcsCodLoc, GD4->GD4_CODPLA, .F.) // Verifica se o plano eh permitido no setor
   	  If !HS_VPlaSet(cGcsCodLoc, cMVDoaPlPd, .F.)
   	   HS_MsgInf(STR0205 + cMVDoaPlPd + STR0206 + cGcsCodLoc + STR0207, STR0034, STR0134) //"Plano [" ### "] nใo permitido no Setor [" ### "] Verificar plano padrใo para doa็ใo no parโmetro MV_DOAPLPD."###"Aten็ใo"###"Valida็ใo do Prontuแrio"
   	   Return(.F.)
   	  EndIf
   	  lRetPlano := .F.   	 
   	 EndIf
   	Else //Nใo achou plano padrao para doacao. Deve pegar do parametro

  	  If !HS_VPlaSet(cGcsCodLoc, cMVDoaPlPd, .F.)
  	   HS_MsgInf(STR0205 + cMVDoaPlPd + STR0206 + cGcsCodLoc + STR0207, STR0034, STR0134)//"Plano [" ### "] nใo permitido no Setor [" ### "] Verificar plano padrใo para doa็ใo no parโmetro MV_DOAPLPD."###"Aten็ใo"###"Valida็ใo do Prontuแrio"
  	   Return(.F.)
  	  EndIf
  	  lRetPlano := .F.
    EndIf
   Else // cGcyAtendi <> "3" nao eh doacao - execucao normal dos outros atendimentos
    DbSetOrder(2)
  	 DbSeek(xFilial("GD4") + M->GCY_REGGER + "1") // pega convenio/plano padrao do paciente

  	 If !HS_VPlaSet(cM24Par01, GD4->GD4_CODPLA, .F.)
 	   HS_MsgInf(STR0205 + GD4->GD4_CODPLA + STR0206 + cM24Par01 + "]", STR0034, STR0134)//"Plano [" ### "] nใo permitido no Setor [" ###"Aten็ใo"###"Valida็ใo do Prontuแrio"
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
  			MsgStop(STR0108) //"Nใo existe data de vig๊ncia para o plano."
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
    M->GCY_MATRIC := IIf(lRet, IIF(cGczCodPla == GD4->GD4_CODPLA,GD4->GD4_MATRIC, "") , Space(Len(GCY->GCY_MATRIC )))
    If cGcyAtendi == "3"
     M->GCY_RG     := IIf(lRet, GBH->GBH_RG                              , Space(Len(GCY->GCY_RG    )))
     M->GCY_ORGEMI := IIf(lRet, GBH->GBH_ORGEMI                          , Space(Len(GCY->GCY_ORGEMI)))
     M->GCY_UFEMIS := IIf(lRet, GBH->GBH_UFEMIS                          , Space(Len(GCY->GCY_UFEMIS)))
    EndIf
    
    cGbhDtNasc    := M->GCY_DTNASC
    cGbhSexo      := M->GCY_SEXO    
   EndIf  
  EndIf
  
 ElseIf nVld == 5 // Valida็ใo do CRM do m้dico
  IF     !(lRet := !Empty(M->GCY_CODCRM))
   HS_MsgInf(STR0037, STR0034, STR0135) //"O CRM do profissional ้ obrigat๓rio."###"Aten็ใo"###"Valida็ใo do M้dico"
  ElseIf !(lRet := HS_SeekRet("SRA","M->GCY_CODCRM", 11, .F., "GCY_NOMMED", "RA_NOME",,, .T.)) .Or. ;
         !(lRet := HS_SeekRet("GBJ","M->GCY_CODCRM",  1, .F.,,,,, .T.))
   HS_MsgInf(STR0038, STR0034, STR0135) //"CRM do profissional nใo encontrado."###"Aten็ใo"###"Valida็ใo do M้dico"
  ElseIf GBJ->GBJ_STATUS # "1"
    HS_MsgInf(STR0061, STR0034, STR0135) //"M้dico encontra-se inativo em seu cadastro."###"Aten็ใo"###"Valida็ใo do M้dico"
    lRet := .F.
  Else      
   FS_IniGE8() // INICIALIZA PRORROGACAO DE GUIAS           
   M->GCY_CODCLI := GBJ->GBJ_CODCLI
   M->GCY_DESCLI := HS_IniPadr("GCW", 1, GBJ->GBJ_CODCLI, "GCW_DESCLI",,.F.)
   If oGDPR # Nil .And. !Empty(IIf(cGcyAtendi == "1", GBJ->GBJ_CODPRO, GBJ->GBJ_CPROPA)) .And. ;
      !Empty(HS_IniPadr("GA7", 1, IIf(cGcyAtendi == "1", GBJ->GBJ_CODPRO, GBJ->GBJ_CPROPA), "GA7_CODPRO",,.F.))
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
   
   EndIf
	 EndIf           
	ElseIf nVld == 6 // Valida็ใo do c๓digo da clinica
  IF     !(lRet := !Empty(M->GCY_CODCLI))
   HS_MsgInf(STR0039, STR0034, STR0136) //"O c๓digo da clํnica ้ obrigat๓rio."###"Aten็ใo"###"Valida็ใo da Clํnica"
  ElseIf !(lRet := HS_SeekRet("GCW","M->GCY_CODCLI", 1, .F., "GCY_DESCLI", "GCW_DESCLI",,, .T.))
   HS_MsgInf(STR0040, STR0034, STR0136) //"Clํnica nใo encontrada."###"Aten็ใo"###"Valida็ใo da Clํnica"
	 EndIf           
	ElseIf nVld == 7 // Valida็ใo da origem do paciente
  IF     !(lRet := !Empty(M->GCY_ORIPAC))
   HS_MsgInf(STR0041, STR0034, STR0137) //"O c๓digo da origem do paciente ้ obrigat๓rio."###"Aten็ใo"###"Valida็ใo da origem do Paciente"
  ElseIf !(lRet := HS_SeekRet("GD0","M->GCY_ORIPAC", 1, .F., "GCY_DORIPAC", "GD0_DORIPA",,, .T.))
   HS_MsgInf(STR0042, STR0034, STR0137) //"Origem do paciente nใo encontrada."###"Aten็ใo"###"Valida็ใo da origem do Paciente"
	 EndIf           
	ElseIf nVld == 8 // Valida็ใo do carater do atendimento
  IF !(lRet := !Empty(M->GCY_CARATE))
   HS_MsgInf(STR0043, STR0034, STR0138) //"O c๓digo do carater do atendimento ้ obrigat๓rio."###"Aten็ใo"###"Valida็ใo do carater do atendimento."
  ElseIf !(lRet := HS_SeekRet("GD1","M->GCY_CARATE", 1, .F., "GCY_DCARAT", "GD1_DCARAT",,, .T.))
   HS_MsgInf(STR0044, STR0034, STR0138) //"Carater do atendimento nใo encontrado."###"Aten็ใo"###"Valida็ใo do carater do atendimento."
	 EndIf                                  
	ElseIf nVld == 9 // Valida็ใo do quarto do atendimento
	 If ReadVar() == "M->GCY_QUAINT" .And. !Empty(M->GCY_QUAINT)
	  M->GCY_CODLOC := GAV->GAV_CODLOC
	 EndIf 
	 
	 HS_DefVar("GCS", 1, M->GCY_CODLOC, aVarDef)
	 
	 If Empty(M->GCY_QUAINT)
   M->GCY_LEIINT := Space(Len(GCY->GCY_LEIINT))
   Return(.T.)
  EndIf 
  
  If     !HS_SeekRet("GAV","M->GCY_CODLOC+M->GCY_QUAINT+M->GCY_LEIINT", 1, .F.,,,,, .T.)
   HS_MsgInf(STR0045, STR0034, STR0139) //"Quarto nใo encontrado."###"Aten็ใo"###"Valida็ใo do quarto"
   Return(.F.)
  ElseIf !(GAV->GAV_STATUS $ "05") .And. GAV->GAV_REGATE # M->GCY_REGATE
   HS_MsgInf(STR0046, STR0034, STR0139) //"Quarto ocupado."###"Aten็ใo"###"Valida็ใo do quarto"
	  Return(.F.)                      
	 ElseIf GAV->GAV_TIPO == "6"
   HS_MsgInf(STR0100, STR0034, STR0140)//"Tipo de quarto nใo permitido!"###"Aten็ใo"###"Validaใo de Interna็ใo"
   Return(.F.) 
  Else
		 cSexoQuarto := HS_Sexo_Quarto(M->GCY_CODLOC, M->GCY_QUAINT)
   If !Empty(cSexoQuarto) .And. cSexoQuarto != "2" .And. cSexoQuarto != HS_IniPadr("GBH", 1, M->GCY_REGGER, "GBH_SEXO",,.F.)
    HS_MsgInf(STR0047 + X3COMBO("GAV_SEXO", cSexoQuarto), STR0034, STR0141) //"Quarto invแlido - jแ ocupado por paciente de sexo "###"Aten็ใo"###"Valida็ใo do sexo do paciente"
    Return(.F.)
   ElseIf !LockByName(xFilial("GAV") + M->GCY_CODLOC + M->GCY_QUAINT + M->GCY_LEIINT, .T., .T., .F.)   //Trava  o novo leito no semaforo
    HS_MsgInf(STR0280, STR0034, STR0139) //"Este leito encontra-se bloqueado por outro usuแrio."###"Aten็ใo"###"Valida็ใo do sexo do paciente"
    Return(.F.)
   Else
    
    If cOldCodLoc + cOldQuaInt + cOldLeiInt <> M->GCY_CODLOC + M->GCY_QUAINT + M->GCY_LEIINT
     UnLockByName(xFilial("GAV") + cOldCodLoc + cOldQuaInt + cOldLeiInt, .T., .T., .F.) //Libera o leito antigo no semaforo
    EndIf
	   
    DbSelectArea("GCY")         
    cOldCodLoc := M->GCY_CODLOC
    cOldQuaInt := M->GCY_QUAINT
    cOldLeiInt := M->GCY_LEIINT
    cGavModelo := GAV->GAV_MODELO
   EndIf
  Endif
 ElseIf nVld == 10 // Valida็ใo do codigo da via de acesso.
  IF !Empty(&(ReadVar())) .And. !(lRet := HS_SeekRet("GE4","'" + &("M->" + PrefixoCpo(cAliasPR) + "_CODVIA") + "'", 1, .F., PrefixoCpo(cAliasPR) + "_DESVIA", "GE4_DESVIA",,, .T.))
	  HS_MsgInf(STR0088, STR0034, STR0142) //"Via de acesso nใo encontrada."###"Aten็ใo"###"Valida็ใo da via de acesso"
	 EndIf
 ElseIf nVld == 11 // Valida็ใo do campo GCY_ACITRA
  If M->GCY_ACITRA # "1"
   M->GCY_CODEMP := Space(Len(M->GCY_CODEMP))
   M->GCY_EMPRES := Space(Len(M->GCY_EMPRES))
   lRet := .T.
  Else
   lRet := Pertence("01")
  EndIf 
 Elseif nVld == 12 // Valida็ใo do Codigo da Empresa
  If M->GCY_ACITRA == "1" .And. !Empty(M->GCY_CODEMP) .And. !HS_SeekRet("GAE", "M->GCY_CODEMP", 1, .F., "GCY_EMPRES", "GAE_NOME",,, .T.)
   HS_MsgInf(STR0048, STR0034, STR0143) //"Empresa nใo encontrada."###"Aten็ใo"###"Valida็ใo da empresa"
   lRet := .F.
  Endif           
 Elseif nVld == 13 // Valida็ใo do Codigo do Plano do Convenio
  cGczCodPla := M->GCZ_CODPLA
  IF !(lRet := !Empty(M->GCZ_CODPLA))
   HS_MsgInf(STR0049, STR0034, STR0144) //"O c๓digo do plano de conv๊nio ้ obrigat๓rio."###"Aten็ใo"###"Valida็ใo do plano"
  ElseIf !(lRet := HS_SeekRet("GCM","M->GCZ_CODPLA", 2, .F., "GCZ_DESPLA", "GCM_DESPLA",,, .T.))
   HS_MsgInf(STR0050, STR0034, STR0144) //"Plano de conv๊nio nใo encontrado."###"Aten็ใo"###"Valida็ใo do plano"
  ElseIf !(lRet := HS_SeekRet("GCV", "oGDGcz:aCols[oGDGcz:nAt, nGczCodTpg]+M->GCZ_CODPLA", 1, .F.,,,,, .T.))
   HS_MsgInf(STR0051, STR0034, STR0144) //"Plano de conv๊nio nใo permitido para o tipo de guia selecionado."###"Aten็ใo"###"Valida็ใo do plano"
  ElseIf !(lRet := !HS_SeekRet("GM0","M->GCY_CODLOC+M->GCZ_CODPLA", 1, .F.,,,,, .T.))
   HS_MsgInf(STR0052, STR0034, STR0144) //"Plano de conv๊nio nใo permitido para o setor selecionado."###"Aten็ใo"###"Valida็ใo do plano"
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
     HS_MsgInf(STR0053, STR0034, STR0144) //"Paciente nใo possui o plano de conv๊nio informado."###"Aten็ใo"###"Valida็ใo do plano"
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
  
 Elseif nVld == 14 // Valida็ใo do tipo de guia     
  cGcuCodTpg := M->GCZ_CODTPG
  IF     !(lRet := !Empty(M->GCZ_CODTPG))
   HS_MsgInf(STR0054, STR0034, STR0145) //"O c๓digo do tipo de guia ้ obrigat๓rio."###"Aten็ใo"###"Valida็ใo do tipo de guia"
  ElseIf !(lRet := HS_SeekRet("GCU","M->GCZ_CODTPG", 1, .F., "GCZ_DESTPG", "GCU_DESTPG",,, .T.))
   HS_MsgInf(STR0055, STR0034, STR0145) //"Tipo de guia nใo encontrado."###"Aten็ใo"###"Valida็ใo do tipo de guia"
  ElseIf !(lRet := (GCU->GCU_TPGUIA $ IIf(cGcyAtendi == "0", "06", IIf(cGcyAtendi == "1","01235", IIf(cGcyAtendi == "2","045","012345")))))
   HS_MsgInf(STR0056, STR0034, STR0145) //"Tipo de guia nใo permitido no setor."###"Aten็ใo"###"Valida็ใo do tipo de guia"
  ElseIf !(lRet := Empty(oGDGcz:aCols[oGDGcz:nAt, nGczCodPla]) .Or. HS_SeekRet("GCV", "M->GCZ_CODTPG+oGDGcz:aCols[oGDGcz:nAt, nGczCodPla]", 1, .F.,,,,, .T.))
   HS_MsgInf(STR0057, STR0034, STR0145) //"Tipo de guia nใo permitido para o plano selecionado."###"Aten็ใo"###"Valida็ใo do tipo de guia"
  Else
   lRet := IIf(cGcyAtendi == "0", .T., FS_VldDesG(M->GCZ_CODTPG)) // Verifica se existem procedimentos lan็ados na guia que nใo sใo permitidos no tipo de guia informado 
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
    oGDGcz:aCols[oGDGcz:nAt, nGczNrGuia] :=  cGczNrGuia
    oGDGcz:oBrowse:Refresh()   
   EndIf
  EndIf
	Elseif nVld == 15 // Valida็ใo do c๓digo do m้dico (CRM)
 If !Vazio() .And. (!(lRet := HS_SeekRet("SRA","M->GCZ_CODCRM", 11, .F., "GCZ_NOMMED", "RA_NOME",,, .T.)) .Or. ;
                     !(lRet := HS_SeekRet("GBJ","M->GCZ_CODCRM",  1, .F.,,,,, .T.)))
   
   
   aCadPro := HS_CadPro(, oGDGcz, nGCZCODCRM, nGCZNOMMED,,, .T.)
	  
  If aCadPro[1] 
   lRet := .T.
  Else
   HS_MsgInf(aCadPro[2], STR0034, STR0135) //"O CRM do profissional ้ obrigat๓rio."###"Aten็ใo"###"Valida็ใo do M้dico" 
  Endif 
 ElseIf GBJ->GBJ_STATUS # "1"
   HS_MsgInf(STR0061, STR0034, STR0135) //"M้dico encontra-se inativo em seu cadastro."###"Aten็ใo"###"Valida็ใo do M้dico"
   lRet := .F.
  ElseIf !(GBJ->GBJ_TIPPRO $ "0/1/2")
   HS_MsgInf(STR0246, STR0034, STR0135) //"Profissional nใo ้ do tipo m้dico em seu cadastro. Verifique."###"Aten็ใo"###"Valida็ใo do M้dico"
   lRet := .F.
  Else
   cObsCodCrm := &(ReadVar())
  EndIf                                                                  
	Elseif nVld == 16 // Valida็ใo da especialidade do m้dico que executou o procedimento
	 IF     !(lRet := !Empty(&("M->" + PrefixoCpo(cAliasPR) + "_CODESP")))
   HS_MsgInf(STR0059, STR0034, STR0146) //"A especialidade do profissional ้ obrigat๓ria."###"Aten็ใo"###"Valida็ใo da especialidade"
  Else
   If lGFR .And. !(lRet := HS_SeekRet("GFR", &("M->" + PrefixoCpo(cAliasPR) + "_CODESP"), 1, .F., PrefixoCpo(cAliasPR) + "_NOMESP", "GFR_DSESPE"))
    HS_MsgInf(STR0060, STR0034, STR0146) //"Especialidade nใo encontrada."###"Aten็ใo"###"Valida็ใo da especialidade"
   ElseIf !lGFR .And. !(lRet := HS_SeekRet("SX5", "'EM" + &("M->" + PrefixoCpo(cAliasPR) + "_CODESP") +"'", 1, .F., PrefixoCpo(cAliasPR) + "_NOMESP", "X5_DESCRI"))
    HS_MsgInf(STR0060, STR0034, STR0146) //"Especialidade nใo encontrada."###"Aten็ใo"###"Valida็ใo da especialidade"
   Endif 
	 EndIf
	/*
	ElseIf nVld == 17 // Valida็ใo CRM do m้dico que executou o procedimento
		 If ReadVar() $ "M->" + PrefixoCpo(cAliasPR) + "_CODCRM/M->" + PrefixoCpo(cAliasPR) + "_CRMLAU" //Valida็ใo para Procedimento
   			If !(lRet := !Empty(&(ReadVar())))
    			HS_MsgInf(STR0037, STR0034, STR0135) //"O CRM do profissional ้ obrigat๓rio."###"Aten็ใo"###"Valida็ใo do M้dico"
   			ElseIf !(lRet := HS_SeekRet("SRA", "'" + &(ReadVar()) + "'", 11, .F., IIF(ReadVar() == "M->GD7_CRMLAU", PrefixoCpo(cAliasPR) + "_NMELAU", PrefixoCpo(cAliasPR) + "_NOMMED"), "RA_NOME",,, IIF(ReadVar() == "M->GD7_CRMLAU",.F.,.T.))) .Or. ;
          		!(lRet := HS_SeekRet("GBJ", "'" + &(ReadVar()) + "'",  1, .F.,,,,, .T.))
    			HS_MsgInf(STR0058, STR0034, STR0135) //"Profissional nใo encontrado."###"Aten็ใo"###"Valida็ใo do M้dico"
   			ElseIf !(lRet := !(GBJ->GBJ_STATUS # "1"))
    			HS_MsgInf(STR0061, STR0034, STR0135) //"O profissional estแ inativo"###"Aten็ใo"###"Valida็ใo do M้dico"
   			ElseIf SUBSTR(ReadVar(), 8) == "CODCRM"                   
    			If !(lRet := FS_VldEsp( &(ReadVar()) ))
     				If lMsg
      					HS_MsgInf(STR0062, STR0034, STR0135) //"A especialidade do profissional ้ invแlida para o procedimento."###"Aten็ใo"###"Valida็ใo do M้dico"
     				EndIf
    			ElseIf cAliasPR == "GE7" .Or. (cAliasPR == "GD7" .And. FunName() == "HSPAHP12") .Or. lIsCaixa

     				lVldPreco := !(oGDGcz:aCols[oGDGcz:nAt, nGczCodPla] $ __cCodBPA+"/"+__cCodPAC+"/"+__cCodAIH)
     
     				If lRet := HS_VProHon(cGczCodPla, IIF(lIsCaixa, cGcsCodLoc, oGDPR:aCols[oGDPR:nAt, nPRCODLOC]), oGDPR:aCols[oGDPR:nAt, nPRCODDES], lVldPreco,, ;
                        oGDPR:aCols[oGDPR:nAt, nPRHORDES], "2", &(ReadVar()), ;
                        oGDPR:aCols[oGDPR:nAt, nPRCODATO], {cGcyAtendi, M->GCY_ATORIG, M->GCY_IDADE, M->GCY_SEXO, M->GCY_CARATE},, oGDPR:aCols[oGDPR:nAt, nPRDATDES])[1]
       					lRet := HS_CalcDsc()
     				EndIf                   
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
    			EndIf
   			EndIf
	 	EndIf    
		If lret
   			cObsCodCrm := &(ReadVar())
  		Endif 
	*/
	ElseIf nVld == 18 // Codigo do Ato M้dico
	 IF !(lRet := HS_SeekRet("GMC","'" + &("M->" + PrefixoCpo(cAliasPR) + "_CODATO") + "'", 1, .F., PrefixoCpo(cAliasPR) + "_DESATO", "GMC_DESATO",,, .T.))
	  HS_MsgInf(STR0063, STR0034, STR0147) //"Ato m้dico nใo encontrado."###"Aten็ใo"###"Valida็ใo do ato m้dico"
  ElseIf !(lRet := !(GMC->GMC_IDEATI # "1"))
   HS_MsgInf(STR0064, STR0034, STR0147) //"Ato m้dico estแ inativo."###"Aten็ใo"###"Valida็ใo do ato m้dico"
	 EndIf     
	ElseIf nVld == 19
	 IF !(lRet := (Empty(&("M->" + PrefixoCpo(cAliasPR) + "_CRMLAU")) .Or. ;
	               HS_SeekRet("SRA","'" + &("M->" + PrefixoCpo(cAliasPR) + "_CRMLAU") + "'", 11, .F., PrefixoCpo(cAliasPR) + "_NMELAU", "RA_NOME",,, .T.)))
   HS_MsgInf(STR0058, STR0034, STR0135) //"Profissional nใo encontrado."###"Aten็ใo"###"Valida็ใo do M้dico"
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
		HS_MsgInf(STR0109, STR0034, STR0110) //"A Data do lan็amento da despesa ้ menor ou igual ao ๚ltimo fechamento de estoque, nใo serแ possํvel efetuar o lan็amento."###"Aten็ใo"###"Lan็amento Mat/Med"
   Else 
		If !EMPTY(M->GCY_TPALTA) .And. !Empty(oGDGcz:aCols[oGDGcz:nAt, nGCZNRSEQG]) 
  			If FunName() <> "HSPAHP12"
      			DbSelectArea("GCZ")
      			DbSetOrder(2) //filial+regate
      			If DbSeek(xFilial("GCZ")+ M->GCY_REGATE + "0" + oGDGcz:aCols[oGDGcz:nAt, nGCZNRSEQG]) 
       				If cMvMMAlt == "N"
        				HS_MsgInf(STR0111, STR0034, STR0110) //"Atendimento nใo pode ter movimenta็๕es de mat/med."###"Aten็ใo"###"Lan็amento Mat/Med"
        				Return .F.
       				Endif  
     			Else
       				HS_MsgInf(STR0132, STR0034, STR0110)//"Nใo existe  guia em aberto para este atendimento."###"Aten็ใo"###"Lan็amento Mat/Med"
       				Return .F.
      			Endif 
     		Endif  
		Endif 
    	If !HS_VldHora(cHoraMM)
 	   		HS_MsgInf("A hora do lan็amento da despesa [" + cHoraMM + "] deve estar ente 00:00 e 23:59.", "Aten็ใo", "Lan็amento de despesas")
 	   		lRet := .F.
 	  	ElseIf !(lRet := !(dDataMM  < M->GCY_DATATE .Or. (dDataMM  == M->GCY_DATATE .And. cHoraMM < M->GCY_HORATE)))
     		HS_MsgInf(STR0112, STR0034, STR0110)  //"Despesa nใo pode ser lan็ada com data anterior a data do atendimento."###"Aten็ใo"###"Lan็amento Mat/Med"
    	ElseIf !Empty(M->GCY_DATALT) .AND. !(lRet := !(dDataMM   > M->GCY_DATALT .Or. (dDataMM  == M->GCY_DATALT .And. cHoraMM > M->GCY_HORALT)))
     		HS_MsgInf(STR0113, STR0034, STR0110) //"Despesa nใo pode ser lan็ada com data posterior a data da alta."###"Aten็ใo"###"Lan็amento Mat/Med"
    	ElseIf !(lRet := !(dDataMM  > dDataBase .Or. (dDataMM  == dDataBase .And. cHoraMM > Time())))
     		HS_MsgInf(STR0133, STR0034, STR0110) //"Despesa nใo pode ser lan็ada com data posterior a data corrente.""###"Aten็ใo"###"Lan็amento Mat/Med"
    	Endif
  	Endif
 Endif 

 ElseIf nVld == 21  //Codigo Motivo Cobranca AIH
	 If !(lRet := HS_SeekRet("GH8","M->GCZ_CMCAIH",1,.F.,"GCZ_DMCAIH","GH8_DMCAIH",,.T.) )
		 HS_MsgInf(STR0114, STR0034, STR0115) //"Motivo de Cobran็a nใo cadastrado."###"Aten็ใo"###"Cadastro Motivo de Cobran็a"
 	EndIf
	
 ElseIf nVld == 22 //Codigo Oficio
 	If !(lRet := HS_SeekRet("GH2","M->GCZ_CDCBOR",1,.F.,"GCZ_DSCBOR","GH2_DSCBOR",,.T.) )
 		HS_MsgInf(STR0116, STR0034, STR0117) //"Ofํcio nใo cadastrado"###"Aten็ใo"###"Cadastro Ofํcio"
 	EndIf
 	
 ElseIf nVld == 23 //Codigo Nac. Atv Economica
 	If !(lRet := HS_SeekRet("GHB","M->GCZ_CDCCNA",1,.F.,"GCZ_DESCNA","GHB_DESCNA",,.T.) )
 		HS_MsgInf(STR0118, STR0034, STR0119) //"C๓digo nacional de atividade econ๔mica nใo cadastrado."###"Aten็ใo"###"Cadastro Nac. Ativ. Econ."
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
 	 	HS_MsgInf(STR0120, STR0034, STR0121) //"Data da Autoriza็ใo inferior a data do Atendimento."###"Aten็ใo"###"Valida็ใo de campos"
 	 ElseIf !(lRet := M->GCZ_DATAUT <= DDATABASE)
 		 HS_MsgInf(STR0122, STR0034, STR0121) //"Data da Autoriza็ใo superior a data atual."###"Aten็ใo"###"Valida็ใo de campos"
  	EndIf
  ElseIf !(lRet := !(!Empty(GCY->GCY_DATALT) .And. M->GCZ_DATAUT >	GCY->GCY_DATALT))
   HS_MsgInf(STR0259, STR0034, STR0260)  //"Data de autoriza็ใo superior a data da alta."###"Aten็ใo"###"Valida็ใo da data de autoriza็ใo"
  EndIf
	
 ElseIf nVld == 26 //Proced. Autor.
  If ReadVar() == "M->GCZ_CPRAU1"
   If !(lRet := HS_SeekRet("GA7","M->GCZ_CPRAU1",1,.F.,"GCZ_DPRAU1","GA7_DESC",,.T.) )
 	 	HS_MsgInf(STR0123, STR0034, STR0124) //"C๓digo do Procedimento nใo cadastrado."###"Aten็ใo"###"Cadastro Procedimento"
 	 EndIf	
 	ElseIf ReadVar() == "M->GCZ_CPRAU2"
   If !(lRet := HS_SeekRet("GA7","M->GCZ_CPRAU2",1,.F.,"GCZ_DPRAU2","GA7_DESC",,.T.) )
 	 	HS_MsgInf(STR0123, STR0034, STR0124) //"C๓digo do Procedimento nใo cadastrado."###"Aten็ใo"###"Cadastro Procedimento"
 	 EndIf
  ElseIf ReadVar() == "M->GCZ_CPRAU3"
   If !(lRet := HS_SeekRet("GA7","M->GCZ_CPRAU3",1,.F.,"GCZ_DPRAU3","GA7_DESC",,.T.) )
 	 	HS_MsgInf(STR0123, STR0034, STR0124) //"C๓digo do Procedimento nใo cadastrado."###"Aten็ใo"###"Cadastro Procedimento"
 	 EndIf		 	
  ElseIf ReadVar() == "M->GCZ_CPRAU4"
   If !(lRet := HS_SeekRet("GA7","M->GCZ_CPRAU4",1,.F.,"GCZ_DPRAU4","GA7_DESC",,.T.) )
 	 	HS_MsgInf(STR0123, STR0034, STR0124) //"C๓digo do Procedimento nใo cadastrado."###"Aten็ใo"###"Cadastro Procedimento"
 	 EndIf		 
 	ElseIf ReadVar() == "M->GCZ_CPRAU5"
   If !(lRet := HS_SeekRet("GA7","M->GCZ_CPRAU5",1,.F.,"GCZ_DPRAU5","GA7_DESC",,.T.) )
 	 	HS_MsgInf(STR0123, STR0034, STR0124) //"C๓digo do Procedimento nใo cadastrado."###"Aten็ใo"###"Cadastro Procedimento"
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
	  	HS_MsgInf(STR0125, STR0034, STR0126) //"C๓digo do CID nใo cadastrado."###"Aten็ใo"###"Lan็amento de Despesas"
 	 EndIf	
   If!(lRet := HS_SeekRet("GHH","'" + oGDPR:aCols[oGDPR:nAt, nPRCODDES] + &("M->" + PrefixoCpo(cAliasPR) + "_CODCID") + "'", 1, .F.,,,,.T.))
	  	HS_MsgInf(STR0183 + " [" + oGDPR:aCols[oGDPR:nAt, nPRCODDES] + "]", STR0034, STR0126) //"O CID informado nao estแ relacionado com o procedimento"###"Aten็ใo"###"Lan็amento de Despesas"
 	 EndIf	 	 
 	ElseIf ReadVar() == "M->" + PrefixoCpo(cAliasPR) + "_CIDSEC"
   If !(Empty(&("M->" + PrefixoCpo(cAliasPR) + "_CIDSEC")))
	   If!(lRet := HS_SeekRet("GAS","'" + &("M->" + PrefixoCpo(cAliasPR) + "_CIDSEC") + "'", 1, .F.,,,,.T.))
		  	HS_MsgInf(STR0125, STR0034, STR0126) //"C๓digo do CID nใo cadastrado."###"Aten็ใo"###"Lan็amento de Despesas"
	 	 EndIf	
	   If!(lRet := HS_SeekRet("GHH","'" + oGDPR:aCols[oGDPR:nAt, nPRCODDES] + &("M->" + PrefixoCpo(cAliasPR) + "_CIDSEC") + "'", 1, .F.,,,,.T.))
		  	HS_MsgInf(STR0183 + " [" + oGDPR:aCols[oGDPR:nAt, nPRCODDES] + "]", STR0034, STR0126) //"O CID informado nao estแ relacionado com o procedimento"###"Aten็ใo"###"Lan็amento de Despesas"
	 	 EndIf 	 
	 	EndIf 
 	
 	ElseIf ReadVar() == "M->" + PrefixoCpo(cAliasPR) + "_CDGATE"
 	 If !(lRet := HS_SeekRet("GH3","'" + &("M->" + PrefixoCpo(cAliasPR) + "_CDGATE") + "'", 1, .F., PrefixoCpo(cAliasPR) + "_DSGATE", "GH3_DSGATE",,.T.))
	  	HS_MsgInf(STR0128, STR0034, STR0126) //"C๓digo do grupo de atendimento nใo cadastrado."###"Aten็ใo"###"Lan็amento de Despesas"
   ElseIf !(lRet := HS_SeekRet("GHF","'" + oGDPR:aCols[oGDPR:nAt, nPRCODDES] + &("M->" + PrefixoCpo(cAliasPR) + "_CDGATE") + "'", 1, .F.,,,,.T.))
	  	HS_MsgInf(STR0185 + " [" + oGDPR:aCols[oGDPR:nAt, nPRCODDES] + "]", STR0034, STR0126) //"O Grupo de Atendimento informado nใo estแ relacionado com o procedimento."###"Aten็ใo"###"Lan็amento de Despesas"
 	 Else
    cCodFEta := HS_FEtaria(M->GCY_REGATE)
  	 aRetGAte := HS_RetGAte(oGDPR:aCols[oGDPR:nAt, nPRCODDES], cCodFEta)
  	 If aRetGAte[2] .And. !(lRet := &(ReadVar()) == aRetGAte[1]) //tem relacionamento com faixa etaria
   	 HS_MsgInf(STR0208, STR0034, STR0126)
  	 EndIf
 	 EndIf	 	 
 	
 	ElseIf ReadVar() == "M->" + PrefixoCpo(cAliasPR) + "_CDTATE"
 	 If!(lRet := HS_SeekRet("GH4","'" + &("M->" + PrefixoCpo(cAliasPR) + "_CDTATE") + "'", 1, .F., PrefixoCpo(cAliasPR) + "_DSTATE", "GH4_DSTATE",,.T.))
	  	HS_MsgInf(STR0129, STR0034, STR0126) //"C๓digo do tipo de atendimento nใo cadastrado."###"Aten็ใo"###"Lan็amento de Despesas"
 	 EndIf
   If!(lRet := HS_SeekRet("GHG","'" + oGDPR:aCols[oGDPR:nAt, nPRCODDES] + &("M->" + PrefixoCpo(cAliasPR) + "_CDTATE") + "'", 1, .F.,,,,.T.))
	  	HS_MsgInf(STR0186 + " [" + oGDPR:aCols[oGDPR:nAt, nPRCODDES] + "]", STR0034, STR0126) //"O Tipo de Atendimento informado nใo estแ relacionado com o procedimento."###"Aten็ใo"###"Lan็amento de Despesas"
 	 EndIf	 	 
 	Endif 

 ElseIf nVld == 30
  If cMv_Atesus == "S" 
   If FunName() <> "HSPAHP12" .AND. oGDGcz:aCols[oGDGcz:nAt, nGczCodPla] $ __cCodBPA+"/"+__cCodPAC+"/"+__cCodAIH
    HS_MsgInf(STR0130, STR0034, STR0131) //"Altera็ใo nใo permitida para este plano."###"Aten็ใo"###"Valida็ใo Nr guia"
    lRet := .F. 
   ElseIf FunName() == "HSPAHP12" .AND. oGDGcz:aCols[oGDGcz:nAt, nGczCodPla] == __cCodBPA
    HS_MsgInf(STR0130, STR0034, STR0131) //"Altera็ใo nใo permitida para este plano."###"Aten็ใo"###"Valida็ใo Nr guia"
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
    HS_MsgInf("Este doador nใo existe", "Aten็ใo", "Valida็ใo de doador")
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
   HS_MsgInf(STR0176, STR0034, STR0177)//"Este tipo de doa็ใo nใo existe."###"Aten็ใo"###"Valida็ใo de Tipo de Doa็ใo"
  ElseIf !(lRet := FS_VldInt())
   Return(.F.)
  EndIf
 ElseIf nVld == 33 // Valida็ใo do RG do paciente
 
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

				// Retorna os Valores da Altera็ใo do Paciente
	  	M->GCY_RG     := cGbhRg
	  	M->GCY_RGORG  := cGbhRgOrg
	  	M->GCY_UFEmis := cGbhUFEmis
    HS_VldAIH(, 4)                
   Else                     
    // Funcao que limpa o historico de conteudo dos parametros
    HS_PosSX1({{"HSM24D", "01", Nil}, {"HSM24D", "02", Nil}, {"HSM24D", "03", Nil}, {"HSM24D", "04", Nil}, {"HSM24D", "05", Nil}, {"HSM24D", "06", Nil}, {"HSM24D", "07", Nil}, {"HSM24D", "08", Nil}})
    
    If Pergunte("HSM24D", .T.)
     cFiltro := HS_FilRG()
     If lRet := HS_ConPac(, .F., cFiltro)
      M->GCY_REGGER := GBH->GBH_CODPAC
      lRet := HS_VldAIH(, 4)
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
 
 ElseIf nVld == 34 // Valida็ใo do CODDES TISS
  If !EMPTY(M->GCZ_CODDES) .And. !(lRet := HS_SeekRet("GA7", "M->GCZ_CODDES", 1, .F., "GCZ_DDESPE", "GA7_DESC",,, .T.))
   HS_MsgInf(STR0123, STR0034, STR0121) //"C๓digo do Procedimento nใo cadastrado."###"Aten็ใo"###"Valida็ใo de campos" 
  ElseIf !EMPTY(M->GCZ_CODDES) .And. !(lRet := HS_SeekRet("GCX", "oGDGcz:aCols[oGDGcz:nAt, nGCZCODTPG]+M->GCZ_CODDES", 1, .F.,,,,,.T.)) 
 		HS_MsgInf(STR0092 + AlLTrim(M->GCZ_CODDES) + STR0093 , STR0013, STR0157) // "Aten็ใo" //"O procedimento ["###"] nใo ้ permitido no tipo de guia informado" //"Procedimento"
	 ElseIf !EMPTY(M->GCZ_CODDES) .And. !(lRet := HS_SeekRet("GM2", "M->GCY_LOCATE+M->GCZ_CODDES", 1, .F.,,,,,.T.)) 
  	HS_MsgInf(STR0092 + AlLTrim(M->GCZ_CODDES) +  STR0279, STR0013, STR0157)  //"O procedimento ["###"] nใo ้ permitido no setor."
  Else
   aRValDes := HS_RValPr(M->GCZ_CODDES, oGDGcz:aCols[oGDGcz:nAt, nGczCodPla], M->GCY_LOCATE, Time(), "2", "",, {M->GCY_ATENDI, M->GCY_ATORIG, M->GCY_IDADE, M->GCY_SEXO, M->GCY_CARATE},, DDATABASE)
   oGDGcz:aCols[oGDGcz:nAt, nGczCodPrt] := aRValDes[2][15]
  EndIf

 ElseIf nVld == 35 // Valida็ใo do TATIS 
  If !EMPTY(M->GCZ_TATISS) .And. !(lRet := HS_SeekRet("G08", "M->GCZ_TATISS", 1, .F., "GCZ_DTATIS", "G08_DESCRI",,, .T.))
   HS_MsgInf(STR0129, STR0034, STR0121) //"C๓digo do tipo de atendimento nใo cadastrado."###"Aten็ใo"###"Valida็ใo de campos"
  EndIf
 
 ElseIf nVld == 36 // Valida็ใo do TIPCON 
  If !EMPTY(M->GCZ_TIPCON) .And. !(lRet := HS_SeekRet("G12", "M->GCZ_TIPCON", 1, .F., "GCZ_DTIPCO", "G12_DESCRI",,, .T.))
   HS_MsgInf(STR0229, STR0034, STR0121) //"Tipo de Consulta nใo encontrado"###"Aten็ใo"###"Valida็ใo de campos"
  EndIf 
 
 ElseIf nVld == 37
  If !Vazio() .And. (!(lRet := HS_SeekRet("SRA","M->GCY_CRMALT", 11, .F., "GCY_MEDALT", "RA_NOME",,, .T.)) .Or. ;
                     !(lRet := HS_SeekRet("GBJ","M->GCY_CRMALT",  1, .F.,,,,, .T.)))
   
   HS_MsgInf(STR0038, STR0034, STR0135) //"CRM do profissional nใo encontrado."###"Aten็ใo"###"Valida็ใo do M้dico"
	 
	 ElseIf GBJ->GBJ_STATUS # "1"
   HS_MsgInf(STR0061, STR0034, STR0135) //"M้dico encontra-se inativo em seu cadastro."###"Aten็ใo"###"Valida็ใo do M้dico"
   lRet := .F.                                                                           
  EndIf                                                                  
 
 ElseIf nVld == 38 // Valida็ใo do CODDES
 	If SubStr(ReadVar(), 4, 3) $ "GD7/GE7"                                         
   		If (lRet := HS_VProced(cGczCodPla, cGcsCodLoc, &(ReadVar()),,,,,,,,, oGDPR:aCols[oGDPR:nAt, nPRDATDES])) .And. !EMPTY(&(ReadVar()))
	   		oGDPR:aCols[oGDPR:nAt, nPRCODCRM] := SPACE(Len(GD7->GD7_CODCRM))
 	  		oGDPR:aCols[oGDPR:nAt, nPRNOMMED] := SPACE(Len(SRA->RA_NOME))
    		lRet := HS_CalcDsc()
   		EndIf 
  	EndIf   
 
  	If lRet .And. cGcyAtendi $ '1/2' 
   		HS_VldAuto(&("oGD"+IIF(SubStr(ReadVar(), 4, 3) $ "GD7/GE7","PR","MM")+":aCols[oGD"+IIF(SubStr(ReadVar(), 4, 3) $ "GD7/GE7","PR","MM")+":nAt, n"+IIF(SubStr(ReadVar(), 4, 3) $ "GD7/GE7","PR","MM")+"DatDes]"))
  	EndIf
  
 ElseIf nVld == 39 // Valida็ใo do Data Inicial e Final da Guia quando Atendimento for APAC
  If ReadVar() == "M->GCZ_VGUIAI"
   If (!Empty(oGDGcz:aCols[oGDGcz:nAt, nPrVguiaI])) .And. (!Empty(oGDGcz:aCols[oGDGcz:nAt, nPrVguiaF]))
    If M->GCZ_VGUIAI >  oGDGcz:aCols[oGDGcz:nAt, nPrVguiaF]
     Hs_MsgInf(STR0167, STR0034, STR0249)//"Data invแlida"###"Aten็ใo"###"Valida็ใo da vแlida da guia SUS APAC"
     lRet := .F. 
    EndIf
   EndIf       
  ElseIf ReadVar() == "M->GCZ_VGUIAF"
   If (!Empty(oGDGcz:aCols[oGDGcz:nAt, nPrVguiaI])) .And. (!Empty(oGDGcz:aCols[oGDGcz:nAt, nPrVguiaF]))
    If oGDGcz:aCols[oGDGcz:nAt, nPrVguiaI] >  M->GCZ_VGUIAF
     Hs_MsgInf(STR0167, STR0034, STR0249)//"Data invแlida"###"Aten็ใo"###"Valida็ใo da vแlida da guia SUS APAC"
     lRet := .F. 
    EndIf
   EndIf   
  ElseIf ReadVar() == "M->GCZ_TPAPAC"    
	  If M->GCZ_TPAPAC # GCZ->GCZ_TPAPAC
	   If M->GCZ_TPAPAC $ "13" 
	    If HS_CountTB("GCZ", "GCZ_NRGUIA  = '" + oGDGcz:aCols[oGDGcz:nAt, nGCZNrGuia] + "' AND GCZ_TPAPAC = '"+M->GCZ_TPAPAC+"'")  > 0 
	     Hs_MsgInf(STR0251,STR0034,STR0250)//"N๚mero da guia jแ cadastrado com esse tipo de APAC."###Aten็ใo###"Valida็ใo Nr. da Guia APAC"
	     lRet := .F. 
	    EndIf
	   ElseIf (M->GCZ_TPAPAC == "2")   
	    If (HS_CountTB("GCZ", "GCZ_NRGUIA  = '" + oGDGcz:aCols[oGDGcz:nAt, nGCZNrGuia] + "' AND GCZ_TPAPAC = '1' ")  == 0)//.Or.(GCZ->GCZ_TPAPAC == "1") 
	     Hs_MsgInf(STR0252,STR0034,STR0250)//"Nใo hแ guia inicial para essa guia."###Aten็ใo###"Valida็ใo Nr. da Guia APAC"
	    EndIf
	   EndIf 
   EndIf
  ElseIf ReadVar() == "M->GCZ_CMCPAC"    
   If HS_CountTB("GH7", "GH7_CMCPAC  = '" + M->GCZ_CMCPAC + "'")  == 0 
    Hs_MsgInf(STR0114,STR0034,STR0253)//"Motivo de Cobran็a nใo cadastrado."###Aten็ใo###"Valida็ใo Motivo de Cobran็a"
    lRet := .F.                                                                                                             
   EndIf   
  EndIf
  
 ElseIf nVld == 40 // Valida็ใo dos Valores de Desconto
  lRet := Positivo() .And. HS_CalcDsc() //Calcula Desconto e Valida se usuario pode aplicar o desc.
 
 ElseIf nVld == 41 //Valida็ใo da Obs. do desconto
  If ReadVar() $ "M->GD5_DESOBS/M->GE5_DESOBS"
   lRet := oGDMM:aCols[oGDMM:nAt, nMMDESVAL] > 0
  ElseIf ReadVar() $ "M->GD7_DESOBS/M->GE7_DESOBS"
   lRet := oGDPR:aCols[oGDPR:nAt, nPRDesVal] > 0 
  EndIf
  If !lRet
   HS_MsgInf(STR0268, STR0034, STR0269)//"Impossํvel preencher o campo Observa็ใo do desconto, pois o valor do desconto estแ zerado."###"Aten็ใo"###"Valida็ใo de Desconto"
  EndIf 
  
 ElseIf nVld == 42 //Valida็ใo do PGTMED
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
   	HS_MsgInf("O procedimento Padrใo [" + AlLTrim(&(ReadVar())) + "] nใo estแ lan็ado na conta", STR0013, STR0157)  
   Else
    HS_SeekRet("GA1", "'" + &("M->" + SubStr(ReadVar(), 4, 3) + "_CODPCT") + "'", 1, .F., SubStr(ReadVar(), 4, 3) + "_DESPCT", "GA1_DESC",,,.T.)
   EndIf
  EndIf 

 EndIf

 DbSelectArea(cAliasOld)                                                                     

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MostObsบAutor  ณMario Arizono       บ Data ณ  13/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFun็ใo para mostrar observacoes referentes ao m้dico, proce-บฑฑ 
ฑฑบ           dimento e plano, dependendo de onde estiver o foco.         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
  	HS_MsgInf(cCpoObs, STR0034, "Observa็ใo referente ao" + cMsg + "informado.")//atencao
  Else
   HS_MsgInf("Nenhuma observa็ใo foi encontrada para o " + cMsg + "informado.", STR0034, "Valida็ใo Observa็ใo" )
  Endif
 Else
  HS_MsgInf("Nenhum " + cMsg + "foi encontrado para visualiza็ใo de sua respectiva observa็ใo.", STR0034, "Valida็ใo Observa็ใo" )//atencao
 Endif
 
 If Type("oObjFocus:oBrowse") <> "U"
  oObjFocus:OBrowse:SetFocus()
 Endif
 
 RestArea(aArea)
Return(Nil)
                 
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HS_PrParto บAutor  ณSueli C. Santos     บ Data ณ             บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       |HS_PrParto                                                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_PrParto()    

Local nPreNatal := 0 , nQtdVivo := 0, nQtdMorto := 0
Local nQtdAlta := 0, nQtdTransf := 0, nSdObito  := 0
Local lPerg := .F.      

Local aRet := {}
Local aParamBox := {}

aAdd(aParamBox,{1,"SISPRENATAL ",Substr(oGDGCZ:aCols[oGDGCZ:nAt, nGCZSisPre],1,11) + Space(11 - len(Substr(oGDGCZ:aCols[oGDGCZ:nAt, nGCZSisPre],1,11))),"","","","",0,.F.})
aAdd(aParamBox,{1,"Qtd Nasc. Vivos ",Substr(Alltrim(str(oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnnViv])),1,1)+ Space(1 - Len(Substr(Alltrim(str(oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnnViv])),1,1))),"9","","","",0,.F.})
aAdd(aParamBox,{1,"Qtd Nasc. Mortos ",Substr(Alltrim(str(oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnnObi])),1,1)+ Space(1 - Len(Substr(Alltrim(str(oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnnObi])),1,1))),"9","","","",0,.F.})
aAdd(aParamBox,{1,"Alta ",Substr(Alltrim(str(oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnAlta])),1,1)+ Space(1 - Len(Substr(Alltrim(str(oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnAlta])),1,1))),"9","","","",0,.F.})
aAdd(aParamBox,{1,"Transferencia  ",Substr(Alltrim(str(oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnTran])),1,1) + Space(1 - Len(Substr(Alltrim(str(oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnTran])),1,1))),"9","","","",0,.F.})
aAdd(aParamBox,{1,"Saida por Obito ",Substr(Alltrim(str(oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnObit])),1,1)+ Space(1 - Len(Substr(Alltrim(str(oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnObit])),1,1))),"9","","","",0,.F.})
      
If lPerg := ParamBox(aParamBox," Dados Complementares de Parto ",@aRet)
     While lPerg .And. Iif ( Valtype(MV_PAR02)=="C" , Val(MV_PAR02) <> Val(MV_PAR04) + Val(MV_PAR05) + Val(MV_PAR06),  MV_PAR02 <> MV_PAR04 + MV_PAR05 + MV_PAR06)
  		HS_MsgInf( "Quantidade de Vivos Diferente da Quantidade de Alta + Transf. + Obito","Dados Complementares",STR0034)
 		lPerg := ParamBox(aParamBox," Dados Complementares de Parto ",@aRet)
	   	dbSkip()		 
   End  
   
  	nPreNatal  := MV_PAR01
    nQtdVivo   := MV_PAR02
    nQtdMorto  := MV_PAR03
    nQtdAlta   := MV_PAR04
    nQtdTransf := MV_PAR05
    nSdObito   := MV_PAR06 
EndIF
    
If lPerg 
	If ValType(nQtdVivo)=="C"
	    oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnnViv] := Val(nQtdVivo)
	    oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnnObi] := Val(nQtdMorto) 
	    oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnAlta] := Val(nQtdAlta)
	    oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnTran] := Val(nQtdTransf) 
	    oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnObit] := Val(nSdObito)
	    oGDGCZ:aCols[oGDGCZ:nAt, nGCZSisPre] := nPreNatal
	    oGDGCZ:oBrowse:Refresh() 
	 Else
    	oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnnViv] := nQtdVivo
	    oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnnObi] := nQtdMorto 
	    oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnAlta] := nQtdAlta
	    oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnTran] := nQtdTransf
	    oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnObit] := nSdObito
	    oGDGCZ:aCols[oGDGCZ:nAt, nGCZSisPre] := nPreNatal
	    oGDGCZ:oBrowse:Refresh() 
	 EndIf
EndIf   

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HS_PrOPM  บAutor  ณSueli C. Santos     บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       |HSPAIH                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_PrcOPM()    

Local nCnpjForn := 0, cNFiscal := "", cLote := ""
Local cSerie    := "", nCnpjFabric := 0, cRegAnvisa  := ""
local lPerg := .F.

Local aRet := {}
Local aParamBox := {}

aAdd(aParamBox,{1,"CNPJ Fornecedor ",Substr(oGDPR:aCols[oGDPR:nAt, nPRCnpjFo],1,14) + Space(14 - len(Substr(oGDPR:aCols[oGDPR:nAt, nPRCnpjFo],1,14))),"","","","",0,.F.})
aAdd(aParamBox,{1,"Nบ Nota Fiscal ",Substr(oGDPR:aCols[oGDPR:nAt, nPRNFOpm],1,11) + Space(11 - len(Substr(oGDPR:aCols[oGDPR:nAt, nPRNFOpm],1,11))),"","","","",0,.F.})
aAdd(aParamBox,{1,"Lote ",Substr(oGDPR:aCols[oGDPR:nAt, nPRLote],1,10) + Space(10 - len(Substr(oGDPR:aCols[oGDPR:nAt, nPRLote],1,10))),"","","","",0,.F.})
aAdd(aParamBox,{1,"Serie ",Substr(oGDPR:aCols[oGDPR:nAt, nPRSerie],1,4) + Space(4 - len(Substr(oGDPR:aCols[oGDPR:nAt, nPRSerie],1,4))),"","","","",0,.F.})
aAdd(aParamBox,{1,"CNPJ Fabricante ",Substr(oGDPR:aCols[oGDPR:nAt, nPRCNPJFa],1,14) + Space(14 - len(Substr(oGDPR:aCols[oGDPR:nAt, nPRCNPJFa],1,14))),"","","","",0,.F.})
aAdd(aParamBox,{1,"Reg. Prod. ANVISA ",Substr(oGDPR:aCols[oGDPR:nAt, nPRAnvisa],1,20) + Space(20 - len(Substr(oGDPR:aCols[oGDPR:nAt, nPRAnvisa],1,20))),"","","","",0,.F.})
    
If lPerg := ParamBox(aParamBox," Dados Complementares de Material ",@aRet)
   	nCnpjForn  := MV_PAR01
    cNFiscal   := MV_PAR02
    cLote  	   := MV_PAR03
    cSerie     := MV_PAR04
    nCnpjFabric:= MV_PAR05
    cRegAnvisa := MV_PAR06 
Endif


If lPerg
    oGDPR:aCols[oGDPR:nAt, nPRCnpjFo] := nCnpjForn 
    oGDPR:aCols[oGDPR:nAt, nPRNFOpm]  := cNFiscal 
    oGDPR:aCols[oGDPR:nAt, nPRLote]   := cLote 
    oGDPR:aCols[oGDPR:nAt, nPRSerie]  := cSerie 
    oGDPR:aCols[oGDPR:nAt, nPRCNPJFa] := nCnpjFabric
    oGDPR:aCols[oGDPR:nAt, nPRAnvisa] := cRegAnvisa
    oGDPR:oBrowse:Refresh()  
EndIf
  
    
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HS_PrcDia บAutor  ณSueli C. Santos     บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       |HSPAIH                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_PrcDia ()    

Local nQtDia := 0, nCompD := ""
Local lPerg := .F.
Local aRet := {}
Local aParamBox := {}


aAdd(aParamBox,{1,"Inf. Quant  ",Alltrim(str(oGDPR:aCols[oGDPR:nAt, nPRQTDDES] ))+ Space(2 - Len(Alltrim(str(oGDPR:aCols[oGDPR:nAt, nPRQTDDES])))),"99","","","",0,.F.})
aAdd(aParamBox,{1,"Competencia (MM/AAAA) ",Substr(Alltrim(oGDPR:aCols[oGDPR:nAt, nCompetD]),1,7) + Space(7 - len(Substr(Alltrim(oGDPR:aCols[oGDPR:nAt, nCompetD]),1,7))),"99/9999","","","",0,.F.})

If lPerg := ParamBox(aParamBox," Dados Complementares de Diarias ",@aRet)
	while lPerg  
	If  Val(MV_PAR01) > Day(Lastday(dDataBase))
  		HS_MsgInf( "Quantidade de Dias maior que a quantidade de dias mes","Dados Complementares",STR0034)
 		lPerg := ParamBox(aParamBox," Dados Complementares de Diarias ")
	ElseIf !(MV_PAR02 <= Substr(Dtos(GCZ->GCZ_DATATE),5,2) + "/" + Substr(Dtos(GCZ->GCZ_DATATE),1,4) .And. MV_PAR02 >= Substr(Dtos(IIF(Empty(GCZ->GCZ_DCPARF), GCY->GCY_DATALT, GCZ->GCZ_DCPARF)),5,2) + "/" + Substr(Dtos(IIF(Empty(GCZ->GCZ_DCPARF), GCY->GCY_DATALT, GCZ->GCZ_DCPARF)),1,4))
  		HS_MsgInf( "Competencia Informada esta fora do intervalo de Internacao","Dados Complementares",STR0034)
 		lPerg := ParamBox(aParamBox," Dados Complementares de Diarias ")	   	
    Else
    	lPerg := .F.
    EndIf
	   	dbSkip()		 
   End  
    nQtDia  := Val(MV_PAR01)
    nCompD  := MV_PAR02
EndIF

If nQtDia > 0
    oGDPR:aCols[oGDPR:nAt, nPRQTDDES] := nQtDia 
    oGDPR:aCols[oGDPR:nAt, nCompetD]  := nCompD 
    oGDPR:oBrowse:Refresh()  
EndIf

Return()  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HS_PrcLaq บAutor  ณSueli C. Santos     บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       |HSPAIH                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_PrcLaq()    

Local nQtdFilh := 0, cCidInd := "", cGrau := ""
Local cContr1 := "", cContr2 := "", cGestR := ""
local lPerg := .F.
Local aCombo := {"1 - Analfabeto","2 - 1บ Grau","3 - 2บ Grau","4 - 3บ Grau"}
Local aCombo2 := {"SIM","NAO"}

Local aRet := {}
Local aParamBox := {}

aAdd(aParamBox,{1,"Quant. Filhos ",Alltrim(Str(oGDPR:aCols[oGDPR:nAt, nQtdFil])) + Space(2 - len(Alltrim(oGDPR:aCols[oGDPR:nAt, nQtdFil]))),"","","","",0,.F.})
aAdd(aParamBox,{1,"CID Indicacao  ",Alltrim(oGDPR:aCols[oGDPR:nAt, nCidInd]) + Space(6 - len(Alltrim(oGDPR:aCols[oGDPR:nAt, nCidInd]))),"","","GAS","",0,.F.}) 
aAdd(aParamBox,{2,"Grau Instrucao ",Alltrim(oGDPR:aCols[oGDPR:nAt, nGrauInst]) + Space(1 - len(Alltrim(oGDPR:aCols[oGDPR:nAt, nGrauInst]))),aCombo,50,"",.F.})
aAdd(aParamBox,{1,"Met. Contrac1 ",Alltrim(oGDPR:aCols[oGDPR:nAt, nMetContr1]) + Space(2 - len( Alltrim(oGDPR:aCols[oGDPR:nAt, nMetContr1]))),"","","HSPLAQ","",0,.F.})
aAdd(aParamBox,{1,"Met. Contrac2",Alltrim(oGDPR:aCols[oGDPR:nAt, nMetContr2]) + Space(2 - len(Alltrim(oGDPR:aCols[oGDPR:nAt, nMetContr2]))),"","","HSPLAQ","",0,.F.})
aAdd(aParamBox,{2,"Gest. Alto Risco ",Alltrim(oGDPR:aCols[oGDPR:nAt, nGestRis]) ,aCombo2,50,"",.F.})   
 
If lPerg := ParamBox(aParamBox," Dados Complementares de Laqueadura ",@aRet)
   	nQtdFilh := Val(MV_PAR01)
    cCidInd  := MV_PAR02
    cGrau  	 := MV_PAR03
    cContr1  := MV_PAR04
    cContr2  := MV_PAR05
    cGestR   := MV_PAR06 
EndIF

If lPerg
    oGDPR:aCols[oGDPR:nAt, nQtdFil]   := nQtdFilh 
    oGDPR:aCols[oGDPR:nAt, nCidInd]   := Iif(Valtype(cCidInd)=="N",Alltrim(str(cCidInd)),cCidInd)
    oGDPR:aCols[oGDPR:nAt, nGrauInst] := Iif(Valtype(cGrau)=="N" ,Alltrim(str(cGrau)),cGrau)
    oGDPR:aCols[oGDPR:nAt, nMetContr1]:= Iif(Valtype(cContr1)=="N" ,Alltrim(str(cContr1)),cContr1)
    oGDPR:aCols[oGDPR:nAt, nMetContr2]:= Iif(Valtype(cContr2)=="N" ,Alltrim(str(cContr2)),cContr2)
    oGDPR:aCols[oGDPR:nAt, nGestRis]  := Iif(Valtype(cGestR)=="N", Alltrim(str(cGestR)),cGestR)
    oGDPR:oBrowse:Refresh()  
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HS_PrcReg บAutor  ณSueli C. Santos     บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       |HSPAIH                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_PrcReg()    

Local cNomeRN := "", cCartorio := "", cLivro := ""
Local cFolha := "", cTermo := "", cNDN := "" , cEmissao :=""
Local lPerg := .F.
Local cCart := GetMv("MV_NOMCART", , "")
/*
Local aRet := {}
Local aParamBox := {}

aAdd(aParamBox,{1,"Nome Recem-Nato ",Alltrim(GB2->GB2_NOMREG) + Space(40 - len(Alltrim(GB2->GB2_NOMREG))),"","","","",0,.F.})
aAdd(aParamBox,{1,"Cartorio ",Alltrim(GB2->GB2_NOMCAR) + Space(20 - len(Alltrim(GB2->GB2_NOMCAR))),"","","","",0,.F.}) 
aAdd(aParamBox,{1,"Livro ",Alltrim(GB2->GB2_LIVRO) + Space(8 - len(Alltrim(GB2->GB2_LIVRO))),"","","","",0,.F.})
aAdd(aParamBox,{1,"Folha ",Alltrim(GB2->GB2_FOLHA) + Space(4 - len(Alltrim(GB2->GB2_FOLHA))),"","","","",0,.F.})
aAdd(aParamBox,{1,"Termo",Alltrim(GB2->GB2_TERMO) + Space(8 - len(Alltrim(GB2->GB2_TERMO))),"","","","",0,.F.})
aAdd(aParamBox,{1,"Nบ do DN ",Alltrim(GB2->GB2_DN) + Space(8 - len(Alltrim(GB2->GB2_DN))),"","","","",0,.F.})  
aAdd(aParamBox,{1,"Data Emissao ",Alltrim(GB2->GB2_DTREG) + Space(8 - len(Alltrim(GB2->GB2_DTREG))),"","DD/MM/AA","","",0,.F.})

If lPerg := ParamBox(aParamBox," Dados Complementares de Laqueadura ",@aRet)                    
*/
                     
dbSelectArea("GB2")
dbSetOrder(2)
DbSeek(xFilial("GB2")+M->GCY_REGATE)                   
If !GB2->(Eof())

	dbSelectArea("SX1")
	dbSetOrder(1)
	If DbSeek(cPergReg)
   		DbSeek(PADR(cPergReg, Len(SX1->X1_GRUPO)) + "01")
  		RecLock("SX1", .F.)  
   	   		SX1->X1_CNT01 := GB2->GB2_NOMREG 
  		MsUnLock()
  
  		DbSeek(PADR(cPergReg, Len(SX1->X1_GRUPO)) + "02")
		If !Empty(GB2->GB2_NOMCAR)
   			RecLock("SX1", .F.)  
   				SX1->X1_CNT01 := GB2->GB2_NOMCAR
	  		MsUnLock()
	 	Else
	 		RecLock("SX1", .F.)  
   				SX1->X1_CNT01 := cCart
	  		MsUnLock()
	 	EndIf
  
  		DbSeek(PADR(cPergReg, Len(SX1->X1_GRUPO)) + "03")
  		RecLock("SX1", .F.)  
		  	SX1->X1_CNT01 := GB2->GB2_LIVRO
		MsUnLock()
  
  		DbSeek(PADR(cPergReg, Len(SX1->X1_GRUPO)) + "04")
  		RecLock("SX1", .F.)  
  			SX1->X1_CNT01 := GB2->GB2_FOLHA
 		 MsUnLock()
 
  		DbSeek(PADR(cPergReg, Len(SX1->X1_GRUPO)) + "05")
 		RecLock("SX1", .F.)  
		  	SX1->X1_CNT01 := GB2->GB2_TERMO
 		 MsUnLock()    
  
 		DbSeek(PADR(cPergReg, Len(SX1->X1_GRUPO)) + "06")
 		RecLock("SX1", .F.)  
  			SX1->X1_CNT01 := GB2->GB2_DN
 		MsUnLock() 
 		
 		DbSeek(PADR(cPergReg, Len(SX1->X1_GRUPO)) + "07")
 		RecLock("SX1", .F.)  
  			SX1->X1_CNT01 := Dtos(GB2->GB2_DTREG)
 		MsUnLock()
	EndIf   
Else
	dbSelectArea("SX1")
	dbSetOrder(1)
	If DbSeek(cPergReg)
  		DbSeek(PADR(cPergReg, Len(SX1->X1_GRUPO)) + "01")
  		RecLock("SX1", .F.)  
   	   		SX1->X1_CNT01 := "" 
  		MsUnLock()
   		DbSeek(PADR(cPergReg, Len(SX1->X1_GRUPO)) + "02")
		RecLock("SX1", .F.)  
   			SX1->X1_CNT01 := cCart
		MsUnLock()  
  
  		DbSeek(PADR(cPergReg, Len(SX1->X1_GRUPO)) + "03")
  		RecLock("SX1", .F.)  
		  	SX1->X1_CNT01 := ""
		MsUnLock()
  
  		DbSeek(PADR(cPergReg, Len(SX1->X1_GRUPO)) + "04")
  		RecLock("SX1", .F.)  
  			SX1->X1_CNT01 := ""
 		 MsUnLock()
 
  		DbSeek(PADR(cPergReg, Len(SX1->X1_GRUPO)) + "05")
 		RecLock("SX1", .F.)  
		  	SX1->X1_CNT01 := ""
 		 MsUnLock()    
  
 		DbSeek(PADR(cPergReg, Len(SX1->X1_GRUPO)) + "06")
 		RecLock("SX1", .F.)  
  			SX1->X1_CNT01 := ""
 		MsUnLock() 
 		
 		DbSeek(PADR(cPergReg, Len(SX1->X1_GRUPO)) + "07")
 		RecLock("SX1", .F.)  
  			SX1->X1_CNT01 := ""
		MsUnLock()
	EndIf
EndIf

If !Hs_ExisDic({{"C","GCZ_RNNVIV"}},.F.)  .Or. oGDGCZ:aCols[oGDGCZ:nAt, nGCZRnnViv] == 0
	MsgAlert("Nao pode haver Incentivo pois a Informacao de Nascidos vivos esta zerada ")	 
	Return 
EndIf	

If (lPerg := Pergunte(cPergReg,," Dados Complementares de Regsitro Civil "))   
   	cNomeRN  := MV_PAR01
    cCartorio:= MV_PAR02
    cLivro   := MV_PAR03
    cFolha   := MV_PAR04
    cTermo   := MV_PAR05
    cNDN     := MV_PAR06 
    cEmissao := MV_PAR07 
EndIF

If lPerg
dbSelectArea("GB2")
dbSetOrder(2)
	If DbSeek(xFilial("GB2")+M->GCY_REGATE)
		RecLock("GB2",.F.) 
		GB2->GB2_NOMREG := MV_PAR01
		GB2->GB2_NOMCAR := MV_PAR02
		GB2->GB2_LIVRO  := MV_PAR03
		GB2->GB2_FOLHA  := MV_PAR04
		GB2->GB2_TERMO  := MV_PAR05
		GB2->GB2_DN     := MV_PAR06
		GB2->GB2_DTREG  := MV_PAR07	
	EndIf
EndIf	  

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldGuiaบAutor  ณPatricia Queiroz    บ Data ณ  29/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFun็ใo para validar a exclusใo da guia.                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                           
Static Function FS_VldGuia()

Local aArea := GetArea()
Local nReg  := 0
 
If Type("oGDPR") <> "U"
 	If aScan(oGDPR:aCols, {| aVet | !Empty(aVet[nPRCODDES])}) > 0
   		HS_MsgInf(STR0234, STR0034, STR0235) //"Nใo ้ possํvel excluir a guia, pois possui procedimento(s) lan็ado(s)."###"Aten็ใo"###"Valida็ใo da Guia"
   		Return(.F.)
  	EndIf 

  	DbSelectArea("GAI")
  	DbSetOrder(2)  //GAI_FILIAL + GAI_REGATE + GAI_DATSOL
  	DbSeek(xFilial("GAI") + GCY->GCY_REGATE)// .And. GAI->GAI_FLGATE <> "2"
  	While !Eof() .And. GAI->GAI_REGATE == GCY->GCY_REGATE
   		If GAI->GAI_FLGATE <> "2"
    		nReg++
   		EndIf
   		DbSkip()
  	End
  
  	If nReg > 0
   		HS_MsgInf(STR0242, STR0034, STR0235) //"Nใo ้ possํvel excluir a guia, pois hแ material(s) e medicamento(s) com solicita็ใo em aberto."###"Aten็ใo"###"Valida็ใo da Guia"
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
   		HS_MsgInf(STR0243, STR0034, STR0235) //"Nใo ้ possํvel excluir a guia, pois hแ material(s) e medicamento(s) com solicita็ใo de devolu็ใo em aberto."###"Aten็ใo"###"Valida็ใo da Guia"
  		Return(.F.)
  	EndIf   
EndIf 

RestArea(aArea)

Return(.T.)  

Function HS_MetCon()
 Local aMetCon := {}
 Local cMetCon := ""
 Local oMetCon
 Local oDlgFic
 Local lRet := .F.                
  
 
 aMetCon := {{'01','LAM'} , {'02','OGINUS-KNAUS'} , {'03','TEMP. BASAL'}, {'04','BILLINGS'},;
			{'05','CINTO TERMICO'}, {'06','DIU'}, {'07','DIAFRAGMA'}, {'08','PRESERVATIVO'},{'09','ESPERMICIDA'},;
			{'10','HORMONIO ORAL'}, {'11','HORMONIO INJETAVEL'}, {'12','COITO INTERROMPIDO'}}
 
 If Empty(aMetCon)
 	Return(lRet)
 EndIf
 Define MsDialog oDlgFic Title OemToAnsi("") From 000, 000 To 500, 850 Of oMainWnd PIXEL 
  @ 005, 005 LISTBOX oMetCon VAR cMetCon FIELDS HEADER "Metodo", "Descri็ao" SIZE 300, 150 OF oDlgFic PIXEL ;  //"MetCon"##"Nome"##"Qtd.Vias"##"Modo"##"Qtd.Linhas"##"Tp.Fonte"##"Tam.Linha"
             ON DBLCLICK (__cRetMet := aMetCon[oMetCon:nAt, 01], lRet := .T., oDlgFic:End())
  oMetCon:Align := CONTROL_ALIGN_ALLCLIENT

  oMetCon:SetArray(aMetCon)

  oMetCon:bLine := {|| {aMetCon[oMetCon:nAt, 01], ;
                        aMetCon[oMetCon:nAt, 02]}}
 Activate MsDialog oDlgFic Centered

Return(lRet)   

Function HS_RetMet()
 &(Readvar()) := __cRetMet
Return(.T.)                        
                    
Static Function FS_MLegMB(aResLeg)
 Local aLegGav := {}, nLeg := 1
 
 For nLeg := 1 To Len(aResLeg)
  aAdd(aLegGav, {aResLeg[nLeg][2], aResLeg[nLeg][3]})
 Next
 
 BrwLegenda("Mapa de leitos", STR0211, aLegGav) //"Legenda"
Return(Nil)  
                      
Static Function HS_Paciente(nRegAIH,nOpcAIH)

If(HS_A58('GBH', GBH->(RecNo()), 4))
	M->GCY_NOME   := GBH->GBH_NOME
	M->GCY_DTNASC := GBH->GBH_DTNASC
	M->GCY_IDADE  := HS_AgeGer(GBH->GBH_DTNASC, M->GCY_DATATE)
	M->GCY_SEXO   := GBH->GBH_SEXO
	
oEncGcy:oBox:Refresh()
Endif

Return()   

Static Function HS_RNAIH()

If HS_RNAM24('GCY', GCY->(RecNo()),14)      
   	M->GCY_NOMMED := HS_IniPadr("SRA", 11, M->GCY_CODCRM, "RA_NOME",,.F.)  
   	M->GCY_DESCLI := HS_IniPadr("GCW", 1, M->GCY_CODCLIGCW, "GCW_DESCLI",,.F.)
   	M->GCY_DORIPA     := HS_IniPadr("GD0", 1, M->GCY_ORIPACGDO,"GD0_DORIPA",,.F.)
   	M->GCY_DCARAT     := HS_IniPadr("GD1", 1, M->GCY_CARATEGD1,"GD1_DCARAT",,.F.)
oEncGcy:oBox:Refresh()
Endif



Static Function AjustaSXB()

DbSelectarea("SXB")
SXB->(dbSetOrder(1))

If SXB->(MsSeek("HSPLAQ101RE"))
	If Empty(XB_CONTEM)
		RecLock("SXB",.F.)
		Replace XB_CONTEM With "GMV"
		MsUnLock()
	Endif
End

Return

