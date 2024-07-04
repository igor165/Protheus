#INCLUDE "HSPAHF04.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±   	
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHF04  º Autor ³ Gilson da Silva    º Data ³  16/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Imprime Ficha de CCIH                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHF04()
Local cCab01    := ""

cTitulo   := STR0002 //"C. C. I. H."
cNomeRel  := "HSPAHF04"
nLin      := 0

GBH->(DbSetOrder(1))
GBH->(DbSeek(xFilial("GBH")+ GCY->GCY_REGGER))

GCZ->(DbSetOrder(2))
GCZ->(DbSeek(xFilial("GCZ")+ GCY->GCY_REGATE))

If nLastKey == 27
	Return(nil)
Endif

nTipo := If(aReturn[4]==1,15,18)

cCAB01 := STR0001 //"FORMULARIO DE COMISSAO DE CONTROLE DE INFECÇÃO HOSPITALAR"

Cabec(cTitulo,	cCab01, "", cNomeRel, H44GetTam(), H44GetTip()) 

@ PROW()+01,00     PSAY PADC(SM0->M0_NOMECOM,132)
@ PROW()+02,00     PSAY STR0006 // "1- IDENTIFICACAO"
@ PROW()   ,00     PSAY STR0006 // "1- IDENTIFICACAO"
@ PROW()+01,00     PSAY STR0007 + GCY->GCY_NOME // "NOME..: "
@ PROW(),PCOL()+04 PSAY STR0008 + IIF(POSICIONE("GBH",1,XFILIAL("GBH")+GCY->GCY_REGGER,"GBH_SEXO")=="0",STR0003,STR0004) // "SEXO:" // "Masculino","Feminino"
@ PROW(),PCOL()+04 PSAY STR0009 + STR(Calc_anos(GBH->GBH_DTNASC,GCY->GCY_DATATE)) PICTURE "9999" // "IDADE: "
@ PROW()+01,00     PSAY STR0010 + SUBSTR(GBH->GBH_CORPEL,1,1) // "COR: "
@ PROW(),PCOL()+04 PSAY STR0011 + GCY->GCY_REGATE // "REGISTRO: "
@ PROW(),PCOL()+04 PSAY STR0012 + POSICIONE("GCS",1,XFILIAL("GCS")+GCY->GCY_CODLOC,"GCS_NOMLOC") // "SETOR: "
@ PROW()+01,00     PSAY STR0013 + SUBSTR(Posicione("GA9",1, xFilial("GA9") + GCZ->GCZ_CODCON, "GA9_NOME"),1,30)// "CONVENIO: "
@ PROW(),PCOL()+05 PSAY STR0106 + SUBSTR(Posicione("GCM",2, xFilial("GCM") + GCZ->GCZ_CODPLA, "GCM_DESPLA"),1,30) //"PLANO:  "
@ PROW(),PCOL()+04 PSAY STR0014 + SUBSTR((HS_RDescrB("GCY_ATENDI", GCY->GCY_ATENDI)),1,15) //"TP ATENDIMENTO: "
@ PROW(),PCOL()+04 PSAY STR0015 + GCY->GCY_QUAINT+"/"+GCY->GCY_LEIINT // "QUARTO: "
@ PROW()+1,00      PSAY STR0016 // "R.N. Peso ao Nascer:    (  ) < 1.500g      (  ) 1.501g a 2.500g    (  ) > 2.500g"
@ prow()+1,00      PSAY REPLICATE("-",132)
@ PROW()+1,00      PSAY STR0017 // "2- DADOS DA HOSPITALIZACAO      Inter.Anterior neste Hospital   Sim(  )  Nao(  )"
@ PROW()  ,00      PSAY STR0018 // "2- DADOS DA HOSPITALIZACAO"
@ PROW()+1,00      PSAY STR0019 // "2.1.DIAGNOSTICO PRINCIPAL:______________________________________________________"
@ PROW()+1,00      PSAY STR0020 // "2.2.DIAGNOSTICO(S) SECUNDÁRIO(S)________________________________________________"
@ prow()+1,00      PSAY "________________________________________________________________________________"
@ PROW()+1,00      PSAY STR0021 // "2.3.CIRURGIA:___________________________________________________________________"
@ PROW()+1,00      PSAY STR0022 // "Porte Cirurgia      Classificacao da Cirurgia               Situacao            "
@ PROW()+1,00      PSAY STR0023 // "2.3.1.GRANDE  ( )   2.3.4 LIMPA                      ( )  2.3.8  ELETIVA     ( )"
@ PROW()+1,00      PSAY STR0024 // "2.3.2.MEDIA   ( )   2.3.5 POTENCIALMETE CONTAMINADA  ( )  2.3.9  URGENCIA    ( )"
@ PROW()+1,00      PSAY STR0025 // "2.3.3.PEQUENA ( )   2.3.6 CONTAMINADA                ( )  2.3.10 EMERGENCIA  ( )"
@ PROW()+1,00      PSAY STR0026 // "                    2.3.7 INFECTADA                  ( )                        "
@ prow()+1,00      PSAY REPLICATE("-",132)
@ PROW()+1,00      PSAY STR0027 // "3- PROCEDIMENTOS DIAGNOSTICOS/TERAPEUTICOS"
@ PROW()  ,00      PSAY STR0027 // "3- PROCEDIMENTOS DIAGNOSTICOS/TERAPEUTICOS"
@ PROW()+1,00      PSAY STR0028 // "3.1.ANTIMICROBIANO     ( ) 3.8. DRENOS              ( )  3.15.FUNCAO LOMBAR  ( )"
@ PROW()+1,00      PSAY STR0029 // "3.2.ASPIRACAO          ( ) 3.9. ENDOSCOPIA          ( )  3.16.FUNCAO PLEURAL ( )"
@ PROW()+1,00      PSAY STR0030 // "3.3.BIOPSIA            ( ) 3.10.ENTUB. ENDOTRAQUIAL ( )  3.17.RESP.MECANICO  ( )"
@ PROW()+1,00      PSAY STR0031 // "3.4.CATETER VENOSO     ( ) 3.11.HEMODIALISE         ( )  3.18.TERAPIA VENOSA ( )"
@ PROW()+1,00      PSAY STR0032 // "3.5.CATETER VESICAL    ( ) 3.12.NEBULIZACAO         ( )  3.19.TRAQUEOSTOMIA  ( )"
@ PROW()+1,00      PSAY STR0033 // "3.6.CORTICOIDE         ( ) 3.13.NUTR.PARENTERAL     ( )  3.20.TRANSF.SANGUE  ( )"
@ PROW()+1,00      PSAY STR0034 // "3.7.DIALISE PERITONIAL ( ) 3.14.PARACENTESE         ( )  3.21.OUTROS         ( )"
@ PROW()+1,00      PSAY STR0035 // "Anotar (S)=Sem Infecao, (A)= Infeccao antes procedimento, (D) apos Procedimento "
@ prow()+1,00      PSAY REPLICATE("-",132)
@ PROW()+1,00      PSAY STR0036 // "4-EXAMES MICROBIOLOGICOS: CULTURA( ) CULTURA c/ANTIBIOGRAMA( ) BACTERIOSCOPIA( )"
@ PROW()  ,00      PSAY STR0037 // "4-EXAMES MICROBIOLOGICOS:"
@ PROW()+1,00      PSAY STR0038 // "4.1.SECRECOES      ( )     4.3.URINA         ( )       4.5.LIQUOR            ( )"
@ PROW()+1,00      PSAY STR0039 // "4.2.SANGUE         ( )     4.4.FEZES         ( )       4.6.OUTROS            ( )"
@ PROW()+1,00      PSAY STR0040 // "                                                       4.7.NAO REALIZOU      ( )"
@ prow()+1,00      PSAY REPLICATE("-",132)
@ PROW()+1,00      PSAY STR0041 // "5-DADOS REFERENTES A INFECCAO"
@ PROW()  ,00      PSAY STR0041 // "5-DADOS REFERENTES A INFECCAO"
@ prow()+1,00      PSAY "---------------------------+-----------+-----------+-----------+----------------"
@ PROW()+1,00      PSAY STR0042 // "LOCALIZACAO TIPOGRAFICA    | NA INTER. | Apos 72Hs | Apos Alta |MICROORG.ISOLADO"
@ prow()+1,00      PSAY "---------------------------+-----------+-----------+-----------+----------------"
@ prow()+1,00      PSAY STR0043 // "5.1. CARDIOVASCULAR    ( ) |    ( )    |    ( )    |    ( )    |"
@ prow()+1,00      PSAY STR0044 // "5.2. CIRURGICA         ( ) |    ( )    |    ( )    |    ( )    |"
@ prow()+1,00      PSAY STR0045 // "5.3. COLO UMBILICAL    ( ) |    ( )    |    ( )    |    ( )    |"
@ prow()+1,00      PSAY STR0046 // "5.4. CUTANEA           ( ) |    ( )    |    ( )    |    ( )    |"
@ prow()+1,00      PSAY STR0047 // "5.5. GASTRO INTESTINAL ( ) |    ( )    |    ( )    |    ( )    |"
@ prow()+1,00      PSAY STR0048 // "5.6. GENITAL           ( ) |    ( )    |    ( )    |    ( )    |"
@ prow()+1,00      PSAY STR0049 // "5.7. OCULAR            ( ) |    ( )    |    ( )    |    ( )    |"
@ prow()+1,00      PSAY STR0050 // "5.8. OSTEO-ARTICULAR   ( ) |    ( )    |    ( )    |    ( )    |"
@ prow()+1,00      PSAY STR0051 // "5.9. OUVIDO            ( ) |    ( )    |    ( )    |    ( )    |"
@ prow()+1,00      PSAY STR0052 // "5.10.PUERPERAL         ( ) |    ( )    |    ( )    |    ( )    |"
@ prow()+1,00      PSAY STR0053 // "5.11.SEPTICETEMIA      ( ) |    ( )    |    ( )    |    ( )    |"
@ prow()+1,00      PSAY STR0054 // "5.12.TRATO RESP.INF.   ( ) |    ( )    |    ( )    |    ( )    |"
@ prow()+1,00      PSAY STR0055 // "5.13.TRATO RESP.SUP.   ( ) |    ( )    |    ( )    |    ( )    |"
@ prow()+1,00      PSAY STR0056 // "5.14.URINARIA          ( ) |    ( )    |    ( )    |    ( )    |"
@ prow()+1,00      PSAY STR0057 // "5.15.OUTRAS            ( ) |    ( )    |    ( )    |    ( )    |"
@ prow()+1,00      PSAY REPLICATE("-",132)
@ prow()+1,00      PSAY STR0058 // "6- USO DE ANTIBIOTICO"
@ prow()  ,00      PSAY STR0058 // "6- USO DE ANTIBIOTICO"
@ prow()+1,00      PSAY STR0059 // "6.1.SIM  (  )     NAO (  )"
@ prow()+1,00      PSAY STR0060 // "6.2.ANTIMICROBIANO(S) UTILIZADO(S):___________________________________________"
@ prow()+1,00      PSAY STR0061 // "6.3.PROFILATICO CLINICO  (  )             CIRURGICO  (  )"
@ prow()+1,00      PSAY STR0062 // "6.4.TERAPEUTICO DE ACORDO COM CULTURA E ANTIBIOGRAMA (  )        EMPIRICO (  )"

cCAB01 := STR0001 //"FORMULARIO DE COMISSAO DE CONTROLE DE INFECÇÃO HOSPITALAR"
Cabec(cTitulo,	cCab01, "", cNomeRel, Tamanho, nTipo)

@ PROW()+02,00     PSAY STR0063 // "7- CONDICOES DE SAIDAS"
@ PROW()   ,00     PSAY STR0063 // "7- CONDICOES DE SAIDAS"
@ PROW()+01,00     PSAY STR0064 // "7.1.CURADO  (  )           7.2.MELHORADO  (  )        7.3.INALTERADO  (  )"
@ PROW()+01,00     PSAY STR0065 // "Data da Alta ____/____/____"
@ prow()+1,00      PSAY REPLICATE("-",132)
@ PROW()+01,00     PSAY STR0066 // "8- TIPO DE ALTA"
@ PROW()   ,00     PSAY STR0066 // "8- TIPO DE ALTA"
@ PROW()+01,00     PSAY STR0067 // "       (  ) INICIATIVA MEDICA    (  ) TRANSFERENCIA      (  ) A PEDIDO          "
@ PROW()+01,00     PSAY STR0068 // "       (  ) INDISCIPLINA         (  ) ABANDONO           (  ) OBITO             "
@ PROW()+01,00     PSAY STR0069 // "                                                         (  ) OBITO POR INFECCAO"
@ prow()+1,00      PSAY REPLICATE("-",132)
@ PROW()+01,00     PSAY STR0070 // "9- MEDICO ASSISTENTE:___________________  ASS._________________  CRM:___________"
@ PROW()   ,00     PSAY STR0070 // "9- MEDICO ASSISTENTE:___________________  ASS._________________  CRM:___________"
@ PROW()+01,00     PSAY STR0071 // "   EMFER. ASSISTENTE:___________________  ASS._________________  COREN:_________"
@ prow()+1,00      PSAY REPLICATE("-",132)
@ PROW()+01,00     PSAY STR0072 // "10- BACTERIAS"
@ PROW()   ,00     PSAY STR0072 // "10- BACTERIAS"
@ PROW()+01,00     PSAY STR0073 // "10.1.Acinetobacter SP                10.24.Pseudomonas SP                       "
@ PROW()+01,00     PSAY STR0074 // "10.2.Alcaligenes SP                     10.25.Pseudomonas Aeruginosa            "
@ PROW()+01,00     PSAY STR0075 // "10.3.Bordetella SP                      10.26.Salmonella SP                     "
@ PROW()+01,00     PSAY STR0076 // "10.4.Citrobacter SP                     10.27.Salmonella Enteridis              "
@ PROW()+01,00     PSAY STR0077 // "10.5.Clostridium SP                     10.28.Salmodella Typi                   "
@ PROW()+01,00     PSAY STR0078 // "10.6.Corynebacterium Difteriae          10.29.Serratia SP                       "
@ PROW()+01,00     PSAY STR0079 // "10.7.Edwardsiella                       10.30.Shigella SP                       "
@ PROW()+01,00     PSAY STR0080 // "10.8.Escherichia Coli                   10.31.Shigella Dysenteriae (Sub Grupo A)"
@ PROW()+01,00     PSAY STR0081 // "10.9.E. Coli. Enteroinvasora            10.32.Shigella Boydii (Sub Grupo C)     "
@ PROW()+01,00     PSAY STR0082 // "10.10.E.Coli. EnteroPatogênico          10.33.Shigella Flexneri (Sub Grupo B)   "
@ PROW()+01,00     PSAY STR0083 // "10.11.EnteroBacter SP                   10.34.Shigella Sonnei (Sub Grupo D)     "
@ PROW()+01,00     PSAY STR0084 // "10.12.Haemophilus                    10.35.Staphylococcus Auraus                "
@ PROW()+01,00     PSAY STR0085 // "10.13.Klebsiella                     10.36.Staphylococcus Epidemidis            "
@ PROW()+01,00     PSAY STR0086 // "10.14.Lactobacillus SP                  10.37.Staphylococcus SaproPhyticus      "
@ PROW()+01,00     PSAY STR0087 // "10.15.Listeria Monocytogenes            10.38.Staphylococcus SP                 "
@ PROW()+01,00     PSAY STR0088 // "10.16.Myco Bacterium SP              10.39.Streptococcus SP                     "
@ PROW()+01,00     PSAY STR0089 // "10.17.Neisseria Meningitidis            10.40.Streptococcus - nao Hemolítico    "
@ PROW()+01,00     PSAY STR0090 // "10.18.Neisseria Gonoraheae              10.41.Streptococcus Virindas            "
@ PROW()+01,00     PSAY STR0091 // "10.19.Proteus SP                        10.42.Streptococcus Beta Hemolitico (A) "
@ PROW()+01,00     PSAY STR0092 // "10.20.Proteus Morganii                  10.43.Streptococcus Beta Hemolitico     "
@ PROW()+01,00     PSAY STR0093 // "10.21.Proteus Rettgeri               10.44.Streptococcus Fecalis                "
@ PROW()+01,00     PSAY STR0094 // "10.22.Proteus Vulgaris                  10.45.Streptococcus Pneumoniea          "
@ PROW()+01,00     PSAY STR0095 // "10.23.Providencia SP                    10.46.Outros                            "
@ prow()+1,00      PSAY REPLICATE("-",132)
@ PROW()+01,00     PSAY STR0096 // "11- VIRUS"
@ PROW()   ,00     PSAY STR0096 // "11- VIRUS"
@ PROW()+01,00     PSAY STR0097 // "11.1.Virus A da Hepatite (  ) 11.3.Virus nao A nao B da Hepatite 11.5.Outros ( )"
@ PROW()+01,00     PSAY STR0098 // "11.2.Virus B da Hepatite (  ) 11.4.Virus HTLV 3                                 "
@ prow()+1,00      PSAY REPLICATE("-",132)
@ PROW()+01,00     PSAY STR0099 // "12- FUNGOS"
@ PROW()   ,00     PSAY STR0099 // "12- FUNGOS"
@ PROW()+01,00     PSAY STR0100 // "12.1.Candida Albicans    (  ) 12.3.Criptococcus Neoformans      12.5.Outros (  )"
@ PROW()+01,00     PSAY STR0101 // "12.2.Candida Outras      (  ) 12.4.Criptococcus SP                              "
@ prow()+1,00      PSAY REPLICATE("-",132)
@ PROW()+01,00     PSAY STR0102 // "13- TIPO DE INFECCAO"
@ PROW()   ,00     PSAY STR0102 // "13- TIPO DE INFECCAO"
@ PROW()+01,00     PSAY STR0103 // "    (  ) Infeccao Comunitaria      (  ) Nao Houve Infeccao          "
@ PROW()+01,00     PSAY STR0104 // "    (  ) Infeccao Hospitalar       (  ) Infeccao de Outro Hospital *"
@ prow()+1,00      PSAY REPLICATE("-",132)
@ PROW()+01,00     PSAY STR0105 // "* ESPECIFICAR O HOSPITAL E A TOPOGRAFIA DA INFECCAO"
@ PROW()   ,00     PSAY STR0105 // "* ESPECIFICAR O HOSPITAL E A TOPOGRAFIA DA INFECCAO"
@ prow()+1,00      PSAY "________________________________________________________________________________"
@ prow()+1,00      PSAY "________________________________________________________________________________"
@ prow()+1,00      PSAY "________________________________________________________________________________"
@ prow()+1,00      PSAY "________________________________________________________________________________"
@ prow()+1,00      PSAY "________________________________________________________________________________"
@ prow()+1,00      PSAY "________________________________________________________________________________"
RETURN
