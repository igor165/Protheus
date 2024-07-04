#INCLUDE "HSPAHF05.ch"
#include "protheus.CH"
#include "colors.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSPAHF05 º Autor ³ Gilson da Silva    º Data ³  05/05/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Laudo Médico                                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Modulo Gestao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPAHF05()
Local cCab01    := ""

cTitulo   := STR0002 //"LAUDO MEDICO"
cNomeRel  := "HSPAHF05"
nLin      := 0

GBH->(DbSetOrder(1))
GBH->(DbSeek(xFilial("GBH")+ GCY->GCY_REGGER))

GCZ->(DbSetOrder(2))
GCZ->(DbSeek(xFilial("GCZ")+ GCY->GCY_REGATE))

If nLastKey == 27
	Return(nil)
Endif

nTipo := If(aReturn[4]==1,15,18)

cCAB01 := STR0001 //"F O R M U L A R I O     P A R A     L A U D O      M E D I C O "

Cabec(cTitulo,	cCab01, "", cNomeRel, H44GetTam(), H44GetTip())

@ PROW()   ,00     PSAY PADC(STR0003,132)  // "S U S  -  S i s t e m a   U n i c o   d e   S a u d e"
@ PROW()   ,00     PSAY PADC(STR0003,132)  // "S U S  -  S i s t e m a   U n i c o   d e   S a u d e"
@ PROW()+01,00     PSAY PADC(STR0004,132)  // "Ministerio da Saude"
@ PROW()   ,00     PSAY PADC(STR0004,132)  // "Ministerio da Saude"
@ PROW()+01,00     PSAY PADC(STR0005 + aDadosEmp[5],132)  // "GOVERNO DO ESTADO "
@ PROW()+01,00     PSAY PADC(STR0006,132)  // "Secretaria Especial de Protecao Social - Secretaria Executiva de Saude"
@ PROW()+02,00     PSAY PADC(STR0007,132)  // "LAUDO MEDICO PARA EMISSAO DE AIH"
@ PROW()   ,00     PSAY PADC(STR0007,132)  // "LAUDO MEDICO PARA EMISSAO DE AIH"
@ PROW()+02,00     PSAY STR0008 + aDadosEmp[1] // "Prontuario:_____________   Hospital: "
@ PROW()+02,00     PSAY STR0009  // "1-Codigo de Autorizacao:_______________"
@ PROW()+01,00     PSAY STR0010  // "2-Unidade de Origem:_________________________________  3-CNPJ:__________________"
@ PROW()+01,00     PSAY STR0011  // "4-Unidade de Destino:________________________________  5-CNPJ:__________________"
@ PROW()+01,00     PSAY STR0012 + GCY->GCY_NOME // "6-Nome do Paciente: "
@ PROW()+01,00     PSAY STR0013 + strzero(Calc_anos(GBH->GBH_DTNASC, GCY->GCY_DATATE),3,0) // "7-Idade: "
@ PROW() ,PCOL()+5 PSAY STR0014 + dtoc(POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_DTNASC")) // "8-Data Nasc.: "
@ PROW(),PCOL()+17 PSAY STR0015 + IIF(POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_SEXO")=="0",STR0047,STR0048) // "9-Sexo.: " // "Masculino","Feminino"
@ PROW()+01,00     PSAY STR0016 + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_END") // "10-Endereco.: "
@ PROW() ,PCOL()+2 PSAY STR0017 + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_BAIRRO") // "11-Bairro: "
@ PROW()+01,00     PSAY STR0018 + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_CEP") // "12-CEP: "
@ PROW() ,PCOL()+2 PSAY STR0019 + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_MUN") // "13-Municipio:"
@ PROW() ,PCOL()+5 PSAY STR0020 + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_EST") // "14-U.F.:"
@ PROW()+01,00     PSAY STR0021 + iif(empty(POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_RG")),"________________",GBH->GBH_RG) // "15-Tipo DOC.:__________     16-Numero Doc.: "
@ PROW()+01,00     PSAY STR0022 + Posicione("GFD",1,xFilial("GFD")+GCY->GCY_CODRES, "GFD_NOME")  // "17-Nome do Responsavel: "
@ PROW()+01,00     PSAY STR0023 // "18-Med.Solic.:______________________________ 19-CPF Dir.Clinico:________________"
@ PROW()+01,00     PSAY STR0024 + GCY->GCY_QUAINT+"/"+GCY->GCY_LEIINT + STR0025 // "     21-Enfermaria No.: _______"
@ PROW()+01,00     PSAY STR0026 + DTOC(GCY->GCY_DATATE) // "22-Carater da Internacao:______________     23-Data da Internacao: "
@ prow()+1,00      PSAY Replicate("-",132)
@ PROW()+01,00     PSAY PADC(STR0027,132)  // "Preencher em caso de Acidente de Transito"
@ PROW()   ,00     PSAY PADC(STR0028,132)  // "Preencher em caso de Acidente de Transito"
@ PROW()+02,00     PSAY STR0029 // "24-Causa Externa:__________________________ 25-CNPJ da Segur.:__________________"
@ PROW()+01,00     PSAY STR0030 // "26-Nro. do Bilhete:________________________ 27-Serie:___________________________"
@ prow()+1,00      PSAY Replicate("-",132)
@ PROW()+01,00     PSAY PADC(STR0030,132)  // "Preencher em caso de Acidente de Trabalho"
@ PROW()   ,00     PSAY PADC(STR0030,132)  // "Preencher em caso de Acidente de Trabalho"
@ PROW()+02,00     PSAY STR0031 // "28-Comunicado Acidente Trabalho_________________________________________________"
@ PROW()+01,00     PSAY STR0032 // "29-CNPJ do Empregador:__________________________________"
@ prow()+1,00      PSAY Replicate("-",132)
@ PROW()+1,00      PSAY PADC(STR0033,132)  // "LAUDO TECNICO E JUSTIFICATIVA DA INTERNACAO"
@ PROW()  ,00      PSAY PADC(STR0033,132)  // "LAUDO TECNICO E JUSTIFICATIVA DA INTERNACAO"
@ prow()+1,00      PSAY Replicate("-",132)
@ PROW()+01,00     PSAY STR0034 // "30-Principais Sinais e Sintomas Clinicos:                                       "
@ PROW()+04,00     PSAY STR0035 // "31-Condicoes que justificam a Internacao:                                       "
@ PROW()+04,00     PSAY STR0036 // "32-Principais Resultados de Provas Diagnosticas:                                "
@ PROW()+04,00     PSAY STR0037 // "33-Diagnostico Inicial:                   34-CID:                               "
@ prow()+3,00      PSAY Replicate("-",132)
@ PROW()+01,00     PSAY STR0038 // "35-Clinica:   1-Cirurgica  (  )    2-Obstetrica   (  )    3-Medica          (  )"
@ PROW()+01,00     PSAY STR0039 // "              4-F.P.T      (  )    5-Psiquiátrica (  )    6-Tsiopneumológica(  )"
@ PROW()+01,00     PSAY STR0040 // "              7-Pediátrica (  )    8-Reabilitacao (  )    8-Outros          (  )"
@ prow()+1,00      PSAY Replicate("-",132)
@ PROW()+1,00      PSAY STR0041 // "36-Proc.Solicitado:__________________________________ 37-Cod.Proc:______________"
@ prow()+1,00      PSAY Replicate("-",132)
@ PROW()+2,00      PSAY STR0042 // "38-Medico Solic.:_________________________ 39-Dir.Clinico:______________________"
@ PROW()+1,00      PSAY STR0043 // "                    Assinatura/carimbo                       Assinatura/carimbo "
@ PROW()+2,00      PSAY STR0044 // "40-CPF Med.Supervisor:____________________ 41-Med.Supervisor:___________________"
@ PROW()+1,00      PSAY STR0045 // "                                                             Assinatura/carimbo "
@ PROW()+1,00      PSAY STR0046 // "42-Data da Autorizacao: _____/_____/_____                                       "
Return()
