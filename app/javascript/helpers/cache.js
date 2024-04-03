const MILLISECONDS_IN_DAY = 86400000;

const refreshCache = async (cacheKey, expirationTime, fetchFunction) => {
  const result = await fetchFunction();

  const jsonValue = JSON.stringify({
    data: result,
    expires_at: Date.now() + expirationTime,
  });
  await localStorage.setItem(cacheKey, jsonValue);

  return result;
};

export const fetchFromCache = async (
  cacheKey,
  fetchFunction,
  expirationTime = MILLISECONDS_IN_DAY,
  useCache = true
) => {
  // if no using cache
  if (!useCache) {
    return refreshCache(cacheKey, expirationTime, fetchFunction);
  }

  const jsonValue = await localStorage.getItem(cacheKey);
  const parsedJsonValue = jsonValue != null ? JSON.parse(jsonValue) : null;

  // if not expired -> return data from cache
  if (parsedJsonValue && parsedJsonValue.expires_at > Date.now()) {
    return parsedJsonValue.data;
  }

  // if cache is expired or no value in cache
  return refreshCache(cacheKey, expirationTime, fetchFunction);
};
