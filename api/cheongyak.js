export const config = { runtime: "edge" };

export default async function handler(req) {
  const { searchParams } = new URL(req.url);
  const type = searchParams.get("type") || "apt";
  const sido = searchParams.get("sido") || "";
  const page = searchParams.get("pageNo") || "1";
  const perPage = searchParams.get("numOfRows") || "10";

  const API_KEY = "ce12d20cefc1e376aa65c2ab8111cb5a249fbcbe8b9fa5b85afdbeb00a9ee681";

  const endpoints = {
    apt:      "https://api.odcloud.kr/api/ApplyhomeInfoDetailSvc/v1/getAPTLttotPblancDetail",
    officetel:"https://api.odcloud.kr/api/ApplyhomeInfoDetailSvc/v1/getUrbtyOfctlLttotPblancDetail",
    urban:    "https://api.odcloud.kr/api/ApplyhomeInfoDetailSvc/v1/getUrbtyOfctlLttotPblancDetail",
    lodging:  "https://api.odcloud.kr/api/ApplyhomeInfoDetailSvc/v1/getUrbtyOfctlLttotPblancDetail",
  };

  const base = endpoints[type] || endpoints.apt;
  
  let url = `${base}?serviceKey=${API_KEY}&page=${page}&perPage=${perPage}`;
  if (sido) url += `&cond[SUBSCRPT_AREA_CODE_NM::EQ]=${encodeURIComponent(sido)}`;

  const res = await fetch(url, {
    headers: { "Authorization": `Bearer ${API_KEY}` }
  });
  const data = await res.json();

  return new Response(JSON.stringify(data), {
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
}
