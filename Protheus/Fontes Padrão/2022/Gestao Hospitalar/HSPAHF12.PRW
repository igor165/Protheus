#INCLUDE "HSPAHF12.CH"
#include "protheus.CH"
#include "colors.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSPAHF12 º Autor ³ GILSON DA SILVA    º Data ³06/05/2005   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ficha Atendimento Ambulatorial SUS                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Modulo Gestao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPAHF12()

Local cCab01    := ""

cTitulo   := STR0002 //"FICHA DE ATENDIMENTO AMBULATORIAL SUS"
cNomeRel  := "HSPAHF12"
nLin      := 0

GBH->(DbSetOrder(1))
GBH->(DbSeek(xFilial("GBH")+ GCY->GCY_REGGER))

If nLastKey == 27
	Return(nil)
Endif

nTipo := If(aReturn[4]==1,15,18)

cCAB01 := STR0001 //"F I C H A      D E      A T E N D I M E N T O     A M B U L A T O R I A L       S U S "

Cabec(cTitulo,	cCab01, "", cNomeRel, H44GetTam(), H44GetTip())


@ prow()   , 00  pSay PADC(STR0005,132) //"SUS - SISTEMA UNICO DE SAUDE  - Ministerio da Saude"
@ prow()+1 , 00  pSay PADC(STR0003,132) //"Secretaria Especial de Protecao Social - Secretaria Executiva de Saude"

@ prow()+02, 00  pSay PADC(STR0006,132) //"ATENDIMENTO MEDICO AMBULATORIAL"
@ prow()   , 00  pSay PADC(STR0006,132) //"ATENDIMENTO MEDICO AMBULATORIAL"

@ prow()+01, 00    pSay Replicate("-",132)
@ prow()+01, 00    pSay STR0007 + SM0->M0_NOMECOM //"Unidade..: "
@ prow()+01, 00    pSay STR0008 + Alltrim(SM0->M0_ENDCOB) + " - " + Alltrim(SM0->M0_BAIRCOB) + " - " + Alltrim(SM0->M0_CIDCOB) + " - " + Alltrim(SM0->M0_ESTCOB) //"Endereco.: "

@ prow()+01, 00    pSay Replicate("-",132)
@ prow()+01, 00    pSay STR0004 + GCY->GCY_REGGER + "   " + GCY->GCY_NOME //"Paciente: "
@ prow()   , 60    pSay STR0009 + Alltrim(str(Calc_anos(GBH->GBH_DTNASC, GCY->GCY_DATATE))) //"Idade.: "
@ prow()+01, 00    pSay STR0010 + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_END") //"Endereco: "
@ prow()   , 60    pSay STR0011 + DTOC(GBH->GBH_DTNASC) //"Nasc..: "
@ prow()+01, 00    pSay STR0012 + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_BAIRRO") //"Bairro..: "
@ prow()   , 60    pSay STR0013 + IIF(POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_SEXO")=="0",STR0043,STR0044) //"Sexo..: "###"Masculino"###"Feminino"
@ prow()+01, 00    pSay STR0014 + AllTrim(POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_MUN")) + "-" + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_EST") //"Municip.: "
@ prow()   , 60    pSay STR0015 + POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_RG") //"No.Doc: "
@ prow()+01, 00    pSay STR0045 + Alltrim(GCY->GCY_CODCRM) + "-" + POSICIONE("SRA", 11, XFILIAL("SRA") + GCY->GCY_CODCRM,"RA_NOME")

@ prow()+01, 00 pSay Replicate("-",132)
@ prow()+01, 00 pSay STR0016 + GCY->GCY_REGATE + STR0017 + DTOC(GCY->GCY_DATATE)+ STR0018 //"CONTA: "###" |  Data Atendimento: "###"  |  PROCEDIMENTO:"
@ prow()+01, 00 pSay Replicate("-",132)

@ prow()+01, 00 pSay STR0019 //"MOTIVO DO ATENDIMENTO:"
@ prow()+02, 00 pSay STR0020 //"DESCRICAO SUMARIA DO EXAME CLINICO:"

@ prow()+01, 00 pSay Replicate("-",132)
@ prow()+01, 00 pSay STR0021 //"Diagnostico:                                                 CID:"

@ prow()+01, 00 pSay Replicate("-",132)
@ prow()+01, 00 pSay STR0022 //"Natureza do Atendimento:"
@ prow()+01, 00 pSay STR0023 //"___Clin    ___Ciru   ____Obst  ____Pedi   ___Psiq   ____Tisi   ____Odon"
@ prow()+01, 00 pSay STR0024 //"___Outro   ___Acidente em geral           ___Acidente de Trabalho"

@ prow()+01, 00 pSay Replicate("-",132)
@ prow()+01, 00 pSay STR0025 //"Medicacao:       ___Prescrita                    ___Aplicada"
@ prow()+01, 00 pSay Replicate("-",032)
@ prow()+01, 00 pSay STR0026 //"Encaminhamento:  ___P/ resid  ___P/ Amb.Publico  ___Intern  ___Obito  ___Outros"

@ prow()+01, 00 pSay Replicate("-",132)
@ prow()+01, 00 pSay STR0039 //"                                                                     | POLEGAR |"
@ prow()+01, 00 pSay "                                                                     |         |"
@ prow()+01, 00 pSay "                                                                     |         |"
@ prow()+01, 00 pSay "______________________________       _____________________________   |         |"
@ prow()+01, 00 pSay STR0027 //"Carimbo e Ass. do Profissional        Ass do Paciente/Responsavel    |         |"

@ prow()+01, 00 pSay Replicate("-",132)
@ prow()+01, 00 pSay padc(STR0028,132) //"CONTA DO ATENDIMENTO MEDICO AMBULATORIAL DE URGENCIA"
@ prow()   , 00 pSay padc(STR0028,132) //"CONTA DO ATENDIMENTO MEDICO AMBULATORIAL DE URGENCIA"
@ prow()+01, 00 pSay Replicate("-",80)

@ prow()+01, 00 pSay STR0029 //"SERVICOS PROFISSIONAIS:      1-Cosulta        2-Imobilizacao   3-Curativo"
@ prow()+01, 00 pSay STR0040 //"                             4-Peq.Sirurgia   5-Outros         6-At.Odontologico"
@ prow()+01, 00 pSay STR0030 //"Descricao do Procediemnto                                                      "
@ prow()+01, 00 pSay "______  ________________________________________________________________________"
@ prow()+01, 00 pSay "______  ________________________________________________________________________"

@ prow()+02, 00 pSay STR0031 //"RECUSROS COMPLEMENTARES:       1-Exame Lab     2-Raios X        3-Oxigenoterapia"
@ prow()+01, 00 pSay STR0041 //"                               4-Hemoterapia   5-Rehidratacao   6-Outros        "
@ prow()+01, 00 pSay STR0032 //"Descricao do Procedimento        Codigo  |  Descricao do Procedimento     Codigo"
@ prow()+01, 00 pSay "____  _________________________  ______  |  ____  _______________________ ______"
@ prow()+01, 00 pSay "____  _________________________  ______  |  ____  _______________________ ______"

@ prow()+02, 00 pSay STR0033 //"MATERIAIS E MEDICAMENTOS:      1-Materiais      2-Medicamentos    3-Remocao     "
@ prow()+01, 00 pSay STR0042 //"                               4-Outros                                         "
@ prow()+01, 00 pSay STR0034 //"Descricao do Procedimento       Qtd   |  Descricao do Procedimento         Qtd  "
@ prow()+01, 00 pSay "___  _________________________  ____  |  ___  __________________________  ______"
@ prow()+01, 00 pSay "___  _________________________  ____  |  ___  __________________________  ______"

@ prow()+02, 00 pSay "______________________________________          ________________________________"
@ prow()+01, 00 pSay STR0035 //"   Diretor Responsavel p/ Informacao               Assinatura do Responsavel    "
@ prow()+01, 00 pSay CHR(15) + Replicate("-",132)
@ prow()+01, 00 pSay STR0036 //"Preencha  Legivelmente todos  os  campos sob pena  de nao  ser considerado o atendimento. Assinale com X as quadriculas precedidas de"
@ prow()+01, 00 pSay STR0037 //"numeros  marcando  a  alternativa.  Sao  responsaveis  pela  informacao o  medico ou odontologo assistente e os diretores da entidade"
@ prow()+01, 00 pSay STR0038 + chr(18) //"conveniente ou contratada. A declaracao  falsa  e/ou fraude sujeita os infratores as sancoes dos artigos 171 e/ou 298 do Codigo Penal"

Return()
