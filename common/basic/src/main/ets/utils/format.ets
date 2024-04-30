export const DateFormat = (date: Date) => {
  // 2023-12-23 05:12
  return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate()
    .toString()
    .padStart(2, '0')} ${date.getHours()
    .toString()
    .padStart(2, '0')}:${date.getMinutes()
    .toString()
    .padStart(2, '0')}`
}