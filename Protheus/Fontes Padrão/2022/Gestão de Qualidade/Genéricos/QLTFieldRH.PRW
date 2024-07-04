#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} QLTFieldRH
Retorna os campos para compatibilização da integração RH x Qualidade

Observações do Frame:
Nao colocar a consistencia de Integracao Quality x GPE (parametro) no aumento do campo - ORIENTACAO DO FRAMEWORK...
Nao utilizar TAMSX3 - dara problemas com aumento de campos - instrucoes FRAMEWORK

Momentos onde essa rotina é chamada na alteração da Gestão de Empresas(SIGACFG), 
ciação de base do zero ou recriando o grupo de empresas e execução do UPDDISTR

Observações do Quality: 
Na issue DMANQUALI-4728 Padronizamos o tamanho em 27 caracteres(máximo que os campos de Matricula poderá chegar),
com isso não será mais necessário que sejá retornados as matriculas no array aFields a partir do release 12.1.2210,
apenas na release inferiores a 12.1.2210 e que o tamanho dos campos de matricula não estejam em 27 caracteres ou maior.

Lógica aplicada no tamanho máximo: 
Tamanho matricula padrão 10 caractes + 5 caracteres tamanho máximo do grupo de campos(121) + 12 caracteres o tamanho máximo da filial.

@type  Function
@author rafael.kleestadt
@since 22/08/2022
@version 1.0
@param param_name, param_type, param_descr
@return aFields, matriz, matriz contendo em cada posição um array com tabela, campo, tamanho e posição do campo no array
@example
(examples)
@see (links_or_references)
/*/
Function QLTFieldRH()
Local aFields := {}
Local nPsCpo  := 2
Local nTmCag  := 9
Local nTmCpo  := 27
Local nTmDet  := 20

//MATRICULA
aadd(aFields, {"QAA", "QAA_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QAB", "QAB_MATD"  , nTmCpo, nPsCpo})
aadd(aFields, {"QAB", "QAB_MATP"  , nTmCpo, nPsCpo})
aadd(aFields, {"QAD", "QAD_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QAE", "QAE_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QAF", "QAF_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QAG", "QAG_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QD0", "QD0_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QD1", "QD1_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QD1", "QD1_MATBX" , nTmCpo, nPsCpo})
aadd(aFields, {"QD4", "QD4_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QD4", "QD4_MATBX" , nTmCpo, nPsCpo})
aadd(aFields, {"QD7", "QD7_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QD8", "QD8_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QD9", "QD9_DESMAT", nTmCpo, nPsCpo})
aadd(aFields, {"QD9", "QD9_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QDA", "QDA_MAT1"  , nTmCpo, nPsCpo})
aadd(aFields, {"QDA", "QDA_MAT2"  , nTmCpo, nPsCpo})
aadd(aFields, {"QDA", "QDA_MAT3"  , nTmCpo, nPsCpo})
aadd(aFields, {"QDE", "QDE_MATDES", nTmCpo, nPsCpo})
aadd(aFields, {"QDE", "QDE_MATSOL", nTmCpo, nPsCpo})
aadd(aFields, {"QDF", "QDF_MATANT", nTmCpo, nPsCpo})
aadd(aFields, {"QDF", "QDF_MATNOV", nTmCpo, nPsCpo})
aadd(aFields, {"QDF", "QDF_MATOP" , nTmCpo, nPsCpo})
aadd(aFields, {"QDG", "QDG_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QDH", "QDH_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QDN", "QDN_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QDP", "QDP_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QDP", "QDP_MATBX" , nTmCpo, nPsCpo})
aadd(aFields, {"QDP", "QDP_MATELA", nTmCpo, nPsCpo})
aadd(aFields, {"QDR", "QDR_MATDE" , nTmCpo, nPsCpo})
aadd(aFields, {"QDR", "QDR_MATPAR", nTmCpo, nPsCpo})
aadd(aFields, {"QDR", "QDR_MATRES", nTmCpo, nPsCpo})
aadd(aFields, {"QDS", "QDS_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QDS", "QDS_MATBX" , nTmCpo, nPsCpo})
aadd(aFields, {"QDU", "QDU_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QDU", "QDU_MATBX" , nTmCpo, nPsCpo})
aadd(aFields, {"QDZ", "QDZ_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QE5", "QE5_RESPON", nTmCpo, nPsCpo})
aadd(aFields, {"QEK", "QEK_RESPLU", nTmCpo, nPsCpo})
aadd(aFields, {"QEK", "QEK_SOLIC" , nTmCpo, nPsCpo})
aadd(aFields, {"QEP", "QEP_SOLIC" , nTmCpo, nPsCpo})
aadd(aFields, {"QER", "QER_ENSR"  , nTmCpo, nPsCpo})
aadd(aFields, {"QF2", "QF2_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QF2", "QF2_MATQLD", nTmCpo, nPsCpo})
aadd(aFields, {"QF3", "QF3_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QF7", "QF7_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QI2", "QI2_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QI2", "QI2_MATRES", nTmCpo, nPsCpo})
aadd(aFields, {"QI3", "QI3_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QI4", "QI4_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QI5", "QI5_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QIE", "QIE_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QIF", "QIF_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QIG", "QIG_MATDE" , nTmCpo, nPsCpo})
aadd(aFields, {"QIG", "QIG_MATPAR", nTmCpo, nPsCpo})
aadd(aFields, {"QIG", "QIG_MATRES", nTmCpo, nPsCpo})
aadd(aFields, {"QK6", "QK6_CODRES", nTmCpo, nPsCpo})
aadd(aFields, {"QK8", "QK8_CODRES", nTmCpo, nPsCpo})
aadd(aFields, {"QKE", "QKE_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QKG", "QKG_RESP"  , nTmCpo, nPsCpo})
aadd(aFields, {"QKI", "QKI_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QKP", "QKP_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QKQ", "QKQ_RESP"  , nTmCpo, nPsCpo})
aadd(aFields, {"QKR", "QKR_RESP"  , nTmCpo, nPsCpo})
aadd(aFields, {"QKR", "QKR_RESPOR", nTmCpo, nPsCpo})
aadd(aFields, {"QKS", "QKS_RESP"  , nTmCpo, nPsCpo})
aadd(aFields, {"QKS", "QKS_RESPOR", nTmCpo, nPsCpo})
aadd(aFields, {"QKT", "QKT_RESP"  , nTmCpo, nPsCpo})
aadd(aFields, {"QKT", "QKT_RESPOR", nTmCpo, nPsCpo})
aadd(aFields, {"QKU", "QKU_RESP"  , nTmCpo, nPsCpo})
aadd(aFields, {"QKU", "QKU_RESPOR", nTmCpo, nPsCpo})
aadd(aFields, {"QKV", "QKV_RESP"  , nTmCpo, nPsCpo})
aadd(aFields, {"QKV", "QKV_RESPOR", nTmCpo, nPsCpo})
aadd(aFields, {"QKW", "QKW_RESP"  , nTmCpo, nPsCpo})
aadd(aFields, {"QKW", "QKW_RESPOR", nTmCpo, nPsCpo})
aadd(aFields, {"QKX", "QKX_RESP"  , nTmCpo, nPsCpo})
aadd(aFields, {"QKX", "QKX_RESPOR", nTmCpo, nPsCpo})
aadd(aFields, {"QKY", "QKY_RESP1" , nTmCpo, nPsCpo})
aadd(aFields, {"QKY", "QKY_RESP2" , nTmCpo, nPsCpo})
aadd(aFields, {"QKY", "QKY_RESP3" , nTmCpo, nPsCpo})
aadd(aFields, {"QM1", "QM1_RDISTR", nTmCpo, nPsCpo})
aadd(aFields, {"QM2", "QM2_RESP"  , nTmCpo, nPsCpo})
aadd(aFields, {"QM4", "QM4_RESP"  , nTmCpo, nPsCpo})
aadd(aFields, {"QM5", "QM5_ENSR"  , nTmCpo, nPsCpo})
aadd(aFields, {"QM6", "QM6_RESP"  , nTmCpo, nPsCpo})
aadd(aFields, {"QMD", "QMD_RESP"  , nTmCpo, nPsCpo})
aadd(aFields, {"QME", "QME_RESP"  , nTmCpo, nPsCpo})
aadd(aFields, {"QML", "QML_RESCOL", nTmCpo, nPsCpo})
aadd(aFields, {"QML", "QML_RESRET", nTmCpo, nPsCpo})
aadd(aFields, {"QMU", "QMU_RESP"  , nTmCpo, nPsCpo})
aadd(aFields, {"QMZ", "QMZ_RESP"  , nTmCpo, nPsCpo})
aadd(aFields, {"QMZ", "QMZ_VENDED", nTmCpo, nPsCpo})
aadd(aFields, {"QN4", "QN4_RESENT", nTmCpo, nPsCpo})
aadd(aFields, {"QN4", "QN4_RESSAI", nTmCpo, nPsCpo})
aadd(aFields, {"QN5", "QN5_RESOBR", nTmCpo, nPsCpo})
aadd(aFields, {"QP5", "QP5_RESPON", nTmCpo, nPsCpo})
aadd(aFields, {"QPR", "QPR_ENSR"  , nTmCpo, nPsCpo})
aadd(aFields, {"QU1", "QU1_CODAUD", nTmCpo, nPsCpo})
aadd(aFields, {"QUA", "QUA_MAT"   , nTmCpo, nPsCpo})
aadd(aFields, {"QUB", "QUB_AUDLID", nTmCpo, nPsCpo})
aadd(aFields, {"QUC", "QUC_CODAUD", nTmCpo, nPsCpo})
aadd(aFields, {"QUD", "QUD_CODAUD", nTmCpo, nPsCpo})
aadd(aFields, {"QUH", "QUH_CODAUD", nTmCpo, nPsCpo})
aadd(aFields, {"QUM", "QUM_CODAUD", nTmCpo, nPsCpo})
aadd(aFields, {"QUN", "QUN_MATPAR", nTmCpo, nPsCpo})
aadd(aFields, {"QUN", "QUN_MATRES", nTmCpo, nPsCpo})
aadd(aFields, {"QUP", "QUP_RESP"  , nTmCpo, nPsCpo})

//CARGOS
aadd(aFields, {"QAA", "QAA_CODFUN", nTmCag, nPsCpo})
aadd(aFields, {"QAC", "QAC_CARGO" , nTmCag, nPsCpo})
aadd(aFields, {"QAC", "QAC_FUNCAO", nTmCag, nPsCpo})
aadd(aFields, {"QD1", "QD1_CARGO" , nTmCag, nPsCpo})
aadd(aFields, {"QD8", "QD8_CARGO" , nTmCag, nPsCpo})
aadd(aFields, {"QD8", "QD8_CARGO" , nTmCag, nPsCpo})
aadd(aFields, {"QDD", "QDD_CARGOA", nTmCag, nPsCpo})
aadd(aFields, {"QDM", "QDM_CARGO" , nTmCag, nPsCpo})
aadd(aFields, {"QDN", "QDN_CARGO" , nTmCag, nPsCpo})
aadd(aFields, {"QDN", "QDN_CARGO" , nTmCag, nPsCpo})
aadd(aFields, {"QF2", "QF2_DEPTOE", nTmCag, nPsCpo})

//DEPTO	
aadd(aFields, {"QAA", "QAA_CC"    , nTmDet, nPsCpo})
aadd(aFields, {"QAB", "QAB_CCD"   , nTmDet, nPsCpo})
aadd(aFields, {"QAB", "QAB_CCP"   , nTmDet, nPsCpo})
aadd(aFields, {"QAD", "QAD_CUSTO" , nTmDet, nPsCpo})
aadd(aFields, {"QD0", "QD0_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QD1", "QD1_DEPBX" , nTmDet, nPsCpo})
aadd(aFields, {"QD1", "QD1_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QD2", "QD2_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QD2", "QD2_MODELO", nTmDet, nPsCpo})
aadd(aFields, {"QD4", "QD4_DEPBX" , nTmDet, nPsCpo})
aadd(aFields, {"QD8", "QD8_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QDD", "QDD_DEPTOA", nTmDet, nPsCpo})
aadd(aFields, {"QDG", "QDG_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QDH", "QDH_DEPTOD", nTmDet, nPsCpo})
aadd(aFields, {"QDH", "QDH_DEPTOE", nTmDet, nPsCpo})
aadd(aFields, {"QDJ", "QDJ_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QDL", "QDL_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QDM", "QDM_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QDN", "QDN_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QDP", "QDP_DEPBX" , nTmDet, nPsCpo})
aadd(aFields, {"QDP", "QDP_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QDR", "QDR_DEPDE" , nTmDet, nPsCpo})
aadd(aFields, {"QDR", "QDR_DEPPAR", nTmDet, nPsCpo})
aadd(aFields, {"QDR", "QDR_DEPRES", nTmDet, nPsCpo})
aadd(aFields, {"QDS", "QDS_DEPBX" , nTmDet, nPsCpo})
aadd(aFields, {"QDS", "QDS_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QDT", "QDT_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QDU", "QDU_DEPBX" , nTmDet, nPsCpo})
aadd(aFields, {"QDU", "QDU_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QDZ", "QDZ_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QF3", "QF3_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QI2", "QI2_DESDEP", nTmDet, nPsCpo})
aadd(aFields, {"QI2", "QI2_MATDEP", nTmDet, nPsCpo})
aadd(aFields, {"QI2", "QI2_ORIDEP", nTmDet, nPsCpo})
aadd(aFields, {"QM1", "QM1_DISTR" , nTmDet, nPsCpo})
aadd(aFields, {"QM2", "QM2_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QM9", "QM9_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QML", "QML_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"QMZ", "QMZ_LOCAL" , nTmDet, nPsCpo})
aadd(aFields, {"QN4", "QN4_DEPREN", nTmDet, nPsCpo})
aadd(aFields, {"QN4", "QN4_DEPRSA", nTmDet, nPsCpo})
aadd(aFields, {"QN5", "QN5_DEPOBR", nTmDet, nPsCpo})
aadd(aFields, {"QUH", "QUH_CCUSTO", nTmDet, nPsCpo})
aadd(aFields, {"QUM", "QUM_CCUSTO", nTmDet, nPsCpo})
aadd(aFields, {"QUO", "QUO_DEPTO" , nTmDet, nPsCpo})
aadd(aFields, {"SB1", "B1_CODQAD" , nTmDet, nPsCpo})

Return aFields
